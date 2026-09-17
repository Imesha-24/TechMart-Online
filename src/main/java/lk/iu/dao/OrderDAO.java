package lk.iu.dao;

import lk.iu.model.Order;
import lk.iu.model.OrderItem;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public interface OrderDAO {
    

    int createOrder(Order order, List<OrderItem> items) throws SQLException;

    List<Order> getOrdersByUserId(int userId) throws SQLException;

    List<OrderItem> getOrderItems(int orderId) throws SQLException;

    List<Order> getAllOrders(String statusFilter, String search) throws SQLException;

    Map<String, Integer> getOrderStats() throws SQLException;

    void updateOrderStatus(int orderId, int statusId) throws SQLException;

    Order getOrderById(int orderId) throws SQLException;
}
