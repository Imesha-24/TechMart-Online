package lk.iu.service;

import jakarta.ejb.AsyncResult;
import lk.iu.dao.OrderDAO;
import lk.iu.model.Notification;
import lk.iu.model.Order;
import lk.iu.model.OrderItem;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Future;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * OrderServiceTest — Unit tests for order operations and async notification dispatch.
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("OrderService — Unit Tests")
public class OrderServiceTest {

    @Mock
    private OrderDAO orderDAO;

    @Mock
    private NotificationService notificationService;

    private OrderService orderService;

    @BeforeEach
    public void setUp() {
        orderService = new OrderServiceImpl(orderDAO, notificationService);
    }

    @Test
    @DisplayName("createOrder — success path")
    public void testCreateOrder_Success() throws SQLException {
        Order order = new Order();
        order.setUserId(1);
        order.setTotalAmount(new BigDecimal("150.00"));

        List<OrderItem> items = new ArrayList<>();
        items.add(new OrderItem());

        when(orderDAO.createOrder(order, items)).thenReturn(100);

        boolean result = orderService.createOrder(order, items);

        assertTrue(result);
        verify(orderDAO).createOrder(order, items);
    }

    @Test
    @DisplayName("createOrder — DAO throws SQLException, returns false safely")
    public void testCreateOrder_DaoFailure() throws SQLException {
        Order order = new Order();
        List<OrderItem> items = new ArrayList<>();

        when(orderDAO.createOrder(any(), any())).thenThrow(new SQLException("DB constraint violation"));

        boolean result = orderService.createOrder(order, items);

        assertFalse(result, "Service should return false when DAO throws exception");
    }

    @Test
    @DisplayName("updateOrderStatus — updates status and dispatches async notification successfully")
    public void testUpdateOrderStatus_WithSuccessfulAsyncNotification() throws Exception {
        int orderId = 55;
        int statusId = 4; // Shipped
        int userId = 7;

        Order order = new Order();
        order.setOrderId(orderId);
        order.setUserId(userId);

        when(orderDAO.getOrderById(orderId)).thenReturn(order);

        // Mock the async notification to return a successful Future
        Future<Boolean> successfulFuture = new AsyncResult<>(true);
        when(notificationService.addNotificationAsync(any(Notification.class))).thenReturn(successfulFuture);

        orderService.updateOrderStatus(orderId, statusId);

        // Verify DAO status update
        verify(orderDAO).updateOrderStatus(orderId, statusId);

        // Verify Notification was dispatched
        ArgumentCaptor<Notification> notifCaptor = ArgumentCaptor.forClass(Notification.class);
        verify(notificationService).addNotificationAsync(notifCaptor.capture());

        Notification dispatched = notifCaptor.getValue();
        assertEquals(userId, dispatched.getUserId());
        assertEquals("Order Shipped", dispatched.getTitle());
        assertTrue(dispatched.getMessage().contains("order #55"));
    }

    @Test
    @DisplayName("updateOrderStatus — async notification failure does NOT rollback order status update")
    public void testUpdateOrderStatus_WithAsyncNotificationFailure() throws Exception {
        int orderId = 56;
        int statusId = 2; // Processing
        
        Order order = new Order();
        order.setOrderId(orderId);
        order.setUserId(3);

        when(orderDAO.getOrderById(orderId)).thenReturn(order);

        // Mock the async notification to return a failed Future (simulating DAO failure in async thread)
        Future<Boolean> failedFuture = new AsyncResult<>(false);
        when(notificationService.addNotificationAsync(any())).thenReturn(failedFuture);

        orderService.updateOrderStatus(orderId, statusId);

        // Even though notification failed, the status update must still happen
        verify(orderDAO).updateOrderStatus(orderId, statusId);
        verify(notificationService).addNotificationAsync(any());
    }
}
