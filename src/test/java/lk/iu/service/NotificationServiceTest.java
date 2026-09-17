package lk.iu.service;

import lk.iu.dao.NotificationDAO;
import lk.iu.model.Notification;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * NotificationServiceTest — Unit tests for @Asynchronous notification delivery.
 *
 * <h2>Test Strategy</h2>
 * <p>Because {@code @Asynchronous} container interception is unavailable outside an EJB
 * container, the tests call the service method directly (no container wrapping). This means
 * the Future returned by {@code addNotificationAsync()} resolves synchronously in the test
 * JVM — which is correct for unit testing business logic in isolation.
 *
 * <p>The async retry logic is fully testable because it uses standard Java (Thread.sleep,
 * AtomicInteger) rather than container-specific APIs.
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("NotificationService — Unit Tests")
public class NotificationServiceTest {

    @Mock
    private NotificationDAO notificationDAO;

    private NotificationServiceImpl notificationService;

    @BeforeEach
    public void setUp() {
        notificationService = new NotificationServiceImpl(notificationDAO);
    }

    // ── Synchronous addNotification tests ────────────────────────────────────

    @Test
    @DisplayName("addNotification — success path delegates to DAO and returns true")
    public void testAddNotification_Success() throws SQLException {
        Notification notification = buildNotification(1, "Order Update", "ORDER");
        when(notificationDAO.addNotification(notification)).thenReturn(true);

        boolean result = notificationService.addNotification(notification);

        assertTrue(result);
        verify(notificationDAO, times(1)).addNotification(notification);
    }

    @Test
    @DisplayName("addNotification — DAO failure propagates SQLException")
    public void testAddNotification_DaoThrowsSQLException() throws SQLException {
        Notification notification = buildNotification(1, "Order Update", "ORDER");
        when(notificationDAO.addNotification(any())).thenThrow(new SQLException("DB down"));

        assertThrows(SQLException.class, () -> notificationService.addNotification(notification));
    }

    // ── @Asynchronous addNotificationAsync tests ─────────────────────────────

    @Test
    @DisplayName("addNotificationAsync — returns Future<true> on DAO success")
    public void testAddNotificationAsync_Success() throws Exception {
        Notification notification = buildNotification(2, "Shipped", "ORDER");
        when(notificationDAO.addNotification(notification)).thenReturn(true);

        // In unit test context, @Asynchronous method executes synchronously (no container)
        Future<Boolean> future = notificationService.addNotificationAsync(notification);

        assertNotNull(future, "Future should not be null");
        Boolean result = future.get(5, TimeUnit.SECONDS);
        assertTrue(result, "Async notification should return true on DAO success");
        verify(notificationDAO, times(1)).addNotification(notification);
    }

    @Test
    @DisplayName("addNotificationAsync — returns Future<false> on DAO SQL exception (no rethrow)")
    public void testAddNotificationAsync_DaoFailure_ReturnsFalse() throws Exception {
        Notification notification = buildNotification(3, "Payment Confirmed", "PAYMENT");
        when(notificationDAO.addNotification(any())).thenThrow(new SQLException("Connection lost"));

        Future<Boolean> future = notificationService.addNotificationAsync(notification);

        assertNotNull(future);
        Boolean result = future.get(5, TimeUnit.SECONDS);
        assertFalse(result, "Async notification should return false when DAO throws — no exception propagated to caller");
    }

    // ── addNotificationAsyncWithRetry tests ──────────────────────────────────

    @Test
    @DisplayName("addNotificationAsyncWithRetry — succeeds on first attempt")
    public void testAsyncWithRetry_SuccessFirstAttempt() throws Exception {
        Notification notification = buildNotification(4, "Delivered", "ORDER");
        when(notificationDAO.addNotification(notification)).thenReturn(true);

        Future<Boolean> future = notificationService.addNotificationAsyncWithRetry(notification);
        Boolean result = future.get(10, TimeUnit.SECONDS);

        assertTrue(result, "Should succeed on first attempt without retrying");
        verify(notificationDAO, times(1)).addNotification(notification);
    }

    @Test
    @DisplayName("addNotificationAsyncWithRetry — succeeds on second attempt after one SQL failure")
    public void testAsyncWithRetry_SuccessOnSecondAttempt() throws Exception {
        Notification notification = buildNotification(5, "Processing", "ORDER");
        when(notificationDAO.addNotification(notification))
                .thenThrow(new SQLException("Transient error")) // attempt 1 fails
                .thenReturn(true);                               // attempt 2 succeeds

        Future<Boolean> future = notificationService.addNotificationAsyncWithRetry(notification);
        Boolean result = future.get(10, TimeUnit.SECONDS);

        assertTrue(result, "Should succeed on second attempt after one transient failure");
        verify(notificationDAO, times(2)).addNotification(notification);
    }

    @Test
    @DisplayName("addNotificationAsyncWithRetry — returns false after exhausting all 3 retry attempts")
    public void testAsyncWithRetry_AllRetriesExhausted() throws Exception {
        Notification notification = buildNotification(6, "Cancelled", "ORDER");
        when(notificationDAO.addNotification(any()))
                .thenThrow(new SQLException("DB unavailable"));

        Future<Boolean> future = notificationService.addNotificationAsyncWithRetry(notification);
        Boolean result = future.get(10, TimeUnit.SECONDS);

        assertFalse(result, "Should return false after all 3 retry attempts are exhausted");
        // 3 attempts total (MAX_RETRY_ATTEMPTS = 3)
        verify(notificationDAO, times(3)).addNotification(notification);
    }

    // ── Query tests ───────────────────────────────────────────────────────────

    @Test
    @DisplayName("getNotificationsByUserId — returns DAO result list")
    public void testGetNotificationsByUserId() throws SQLException {
        int userId = 10;
        List<Notification> expected = Arrays.asList(
                buildNotification(userId, "Test 1", "ORDER"),
                buildNotification(userId, "Test 2", "ORDER")
        );
        when(notificationDAO.getNotificationsByUserId(userId)).thenReturn(expected);

        List<Notification> result = notificationService.getNotificationsByUserId(userId);

        assertSame(expected, result);
        assertEquals(2, result.size());
        verify(notificationDAO).getNotificationsByUserId(userId);
    }

    @Test
    @DisplayName("getNotificationCountByUserId — returns count from DAO")
    public void testGetNotificationCountByUserId() throws SQLException {
        when(notificationDAO.getNotificationCountByUserId(7)).thenReturn(5);

        int count = notificationService.getNotificationCountByUserId(7);

        assertEquals(5, count);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private Notification buildNotification(int userId, String title, String type) {
        Notification n = new Notification();
        n.setUserId(userId);
        n.setTitle(title);
        n.setMessage("Test message for " + title);
        n.setNotificationType(type);
        return n;
    }
}
