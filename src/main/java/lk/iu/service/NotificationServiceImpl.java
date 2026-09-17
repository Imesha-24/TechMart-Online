package lk.iu.service;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.ejb.AsyncResult;
import jakarta.ejb.Asynchronous;
import jakarta.ejb.Local;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import lk.iu.dao.NotificationDAO;
import lk.iu.model.Notification;

import java.sql.SQLException;
import java.util.List;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Level;
import java.util.logging.Logger;

@Stateless
@Local(NotificationService.class)
public class NotificationServiceImpl implements NotificationService {

    private static final Logger LOG = Logger.getLogger(NotificationServiceImpl.class.getName());

    private static final int MAX_RETRY_ATTEMPTS = 3;

    private static final long RETRY_BASE_DELAY_MS = 100L;

    private final AtomicInteger asyncDispatchCount = new AtomicInteger(0);

    @Inject
    private NotificationDAO notificationDAO;

    public NotificationServiceImpl() {
    }

    public NotificationServiceImpl(NotificationDAO notificationDAO) {
        this.notificationDAO = notificationDAO;
    }

    @PostConstruct
    public void onCreate() {
        LOG.info("[NotificationService] @PostConstruct — @Stateless bean ready. "
                + "Container async thread pool will handle @Asynchronous method dispatch.");
    }

    @PreDestroy
    public void onDestroy() {
        LOG.info("[NotificationService] @PreDestroy — @Stateless bean retiring. "
                + "Total async dispatches handled by this instance: " + asyncDispatchCount.get());
    }

    @Override
    public boolean addNotification(Notification notification) throws SQLException {
        return notificationDAO.addNotification(notification);
    }

    @Override
    @Asynchronous
    public Future<Boolean> addNotificationAsync(Notification notification) {
        asyncDispatchCount.incrementAndGet();
        LOG.fine("[NotificationService] @Asynchronous addNotificationAsync — executing in container thread pool.");
        try {
            boolean result = notificationDAO.addNotification(notification);
            return new AsyncResult<>(result);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "[NotificationService] Async notification failed (no retry): userId="
                    + notification.getUserId(), e);
            return new AsyncResult<>(false);
        }
    }

    @Override
    @Asynchronous
    public Future<Boolean> addNotificationAsyncWithRetry(Notification notification) {
        asyncDispatchCount.incrementAndGet();
        LOG.fine("[NotificationService] @Asynchronous addNotificationAsyncWithRetry — retries up to "
                + MAX_RETRY_ATTEMPTS + " attempts.");

        for (int attempt = 1; attempt <= MAX_RETRY_ATTEMPTS; attempt++) {
            // Check if caller has cancelled this Future
            if (Thread.currentThread().isInterrupted()) {
                LOG.warning("[NotificationService] Async retry cancelled by caller on attempt " + attempt
                        + " for userId=" + notification.getUserId());
                return new AsyncResult<>(false);
            }
            try {
                boolean result = notificationDAO.addNotification(notification);
                if (result) {
                    LOG.info("[NotificationService] Notification delivered on attempt " + attempt
                            + " for userId=" + notification.getUserId());
                    return new AsyncResult<>(true);
                }
            } catch (SQLException e) {
                long delay = RETRY_BASE_DELAY_MS * (1L << (attempt - 1)); // exponential backoff
                LOG.warning("[NotificationService] Attempt " + attempt + "/" + MAX_RETRY_ATTEMPTS
                        + " failed for userId=" + notification.getUserId()
                        + ". Retrying in " + delay + "ms. Error: " + e.getMessage());
                try {
                    Thread.sleep(delay);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt(); // restore interrupt flag
                    LOG.warning("[NotificationService] Retry sleep interrupted for userId="
                            + notification.getUserId() + ". Aborting retries.");
                    return new AsyncResult<>(false);
                }
            }
        }
        LOG.severe("[NotificationService] All " + MAX_RETRY_ATTEMPTS + " retry attempts exhausted "
                + "for userId=" + notification.getUserId() + ". Notification lost — consider JMS for guaranteed delivery.");
        return new AsyncResult<>(false);
    }

    @Override
    public List<Notification> getNotificationsByUserId(int userId) throws SQLException {
        return notificationDAO.getNotificationsByUserId(userId);
    }

    @Override
    public int getNotificationCountByUserId(int userId) throws SQLException {
        return notificationDAO.getNotificationCountByUserId(userId);
    }
}
