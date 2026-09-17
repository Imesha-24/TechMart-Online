package lk.iu.service;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.ejb.EJB;
import jakarta.ejb.Local;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import lk.iu.dao.OrderDAO;
import lk.iu.model.Notification;
import lk.iu.model.Order;
import lk.iu.model.OrderItem;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.logging.Level;
import java.util.logging.Logger;

@Stateless
@Local(OrderService.class)
public class OrderServiceImpl implements OrderService {

    private static final Logger LOG = Logger.getLogger(OrderServiceImpl.class.getName());

    private static final long ASYNC_NOTIFICATION_TIMEOUT_MS = 3000L;

    @Inject
    private OrderDAO orderDAO;

    @EJB
    private NotificationService notificationService;

    public OrderServiceImpl() {
    }

    public OrderServiceImpl(OrderDAO orderDAO) {
        this.orderDAO = orderDAO;
    }

    public OrderServiceImpl(OrderDAO orderDAO, NotificationService notificationService) {
        this.orderDAO = orderDAO;
        this.notificationService = notificationService;
    }

    @PostConstruct
    public void onCreate() {
        LOG.info("[OrderService] @PostConstruct — @Stateless bean instance checked out of pool. "
                + "Container-managed transaction context will wrap each business method.");
    }

    @PreDestroy
    public void onDestroy() {
        LOG.fine("[OrderService] @PreDestroy — @Stateless bean instance being returned to GC. "
                + "Pool shrinkage in response to reduced load or container resource pressure.");
    }

    @Override
    public boolean createOrder(Order order, List<OrderItem> items) {
        try {
            int orderId = orderDAO.createOrder(order, items);
            return orderId > 0;
        } catch (SQLException e) {
            LOG.severe("[OrderService] createOrder failed: " + e.getMessage());
            return false;
        }
    }

    @Override
    public List<Order> getOrdersByUserId(int userId) {
        try {
            return orderDAO.getOrdersByUserId(userId);
        } catch (SQLException e) {
            LOG.severe("[OrderService] getOrdersByUserId failed: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    @Override
    public List<OrderItem> getOrderItems(int orderId) throws SQLException {
        return orderDAO.getOrderItems(orderId);
    }

    @Override
    public List<Order> getAllOrders(String statusFilter, String search) throws SQLException {
        return orderDAO.getAllOrders(statusFilter, search);
    }

    @Override
    public Map<String, Integer> getOrderStats() throws SQLException {
        return orderDAO.getOrderStats();
    }

    @Override
    public void updateOrderStatus(int orderId, int statusId) throws SQLException {
        orderDAO.updateOrderStatus(orderId, statusId);

        Order order = orderDAO.getOrderById(orderId);
        if (order != null) {
            String title;
            String statusMsg;
            switch (statusId) {
                case 1 -> { title = "Order Pending";    statusMsg = "Your order #" + orderId + " is pending confirmation."; }
                case 2 -> { title = "Order Processing"; statusMsg = "Your order #" + orderId + " is currently being processed."; }
                case 3 -> { title = "Order Paid";       statusMsg = "Payment for your order #" + orderId + " has been received."; }
                case 4 -> { title = "Order Shipped";    statusMsg = "Your order #" + orderId + " has been shipped."; }
                case 5 -> { title = "Order Delivered";  statusMsg = "Your order #" + orderId + " has been delivered successfully."; }
                case 6 -> { title = "Order Cancelled";  statusMsg = "Your order #" + orderId + " has been cancelled."; }
                default -> { title = "Order Updated";   statusMsg = "Your order #" + orderId + " status has been updated."; }
            }

            Notification notification = new Notification();
            notification.setUserId(order.getUserId());
            notification.setTitle(title);
            notification.setMessage(statusMsg);
            notification.setNotificationType("ORDER");

            Future<Boolean> asyncResult = notificationService.addNotificationAsync(notification);
            try {
                Boolean delivered = asyncResult.get(ASYNC_NOTIFICATION_TIMEOUT_MS, TimeUnit.MILLISECONDS);
                if (Boolean.TRUE.equals(delivered)) {
                    LOG.info("[OrderService] Async notification delivered for order #" + orderId);
                } else {
                    LOG.warning("[OrderService] Async notification returned false for order #" + orderId
                            + " — DAO insert may have failed. Order status persisted successfully.");
                }
            } catch (TimeoutException e) {
                asyncResult.cancel(true);
                LOG.warning("[OrderService] Async notification timed out after " + ASYNC_NOTIFICATION_TIMEOUT_MS
                        + "ms for order #" + orderId + ". Order status committed; notification may arrive late.");
            } catch (Exception e) {
                LOG.log(Level.SEVERE, "[OrderService] Async notification failed for order #" + orderId
                        + ". Order status committed; notification lost.", e);
            }
        }
    }

    @Override
    public Order getOrderById(int orderId) throws SQLException {
        return orderDAO.getOrderById(orderId);
    }
}
