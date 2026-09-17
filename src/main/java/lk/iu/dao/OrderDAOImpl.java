package lk.iu.dao;

import jakarta.enterprise.context.ApplicationScoped;
import lk.iu.model.Order;
import lk.iu.model.OrderItem;
import lk.iu.model.Product;
import lk.iu.util.DBConnectionUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ApplicationScoped
public class OrderDAOImpl implements OrderDAO {

    @Override
    public int createOrder(Order order, List<OrderItem> items) throws SQLException {
        String insertOrderSql = "INSERT INTO orders (user_id, total_amount, status_id) VALUES (?, ?, ?)";
        String insertOrderItemSql = "INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (?, ?, ?, ?)";
        
        Connection conn = null;
        PreparedStatement orderStmt = null;
        PreparedStatement itemStmt = null;
        ResultSet generatedKeys = null;
        int orderId = -1;

        try {
            conn = DBConnectionUtil.getConnection();
            conn.setAutoCommit(false); // Start transaction

            orderStmt = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS);
            orderStmt.setInt(1, order.getUserId());
            orderStmt.setBigDecimal(2, order.getTotalAmount());
            orderStmt.setInt(3, order.getStatusId()); // Default status ID (e.g., 1 for Pending)
            orderStmt.executeUpdate();

            generatedKeys = orderStmt.getGeneratedKeys();
            if (generatedKeys.next()) {
                orderId = generatedKeys.getInt(1);
                order.setOrderId(orderId);
            } else {
                throw new SQLException("Creating order failed, no ID obtained.");
            }

            itemStmt = conn.prepareStatement(insertOrderItemSql);
            for (OrderItem item : items) {
                itemStmt.setInt(1, orderId);
                itemStmt.setInt(2, item.getProductId());
                itemStmt.setInt(3, item.getQuantity());
                itemStmt.setBigDecimal(4, item.getUnitPrice());
                itemStmt.addBatch();
            }
            itemStmt.executeBatch();

            conn.commit(); // Commit transaction
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback on error
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw e;
        } finally {
            if (generatedKeys != null) generatedKeys.close();
            if (itemStmt != null) itemStmt.close();
            if (orderStmt != null) orderStmt.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
        return orderId;
    }

    @Override
    public List<Order> getOrdersByUserId(int userId) throws SQLException {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT o.*, os.status_name FROM orders o " +
                     "LEFT JOIN order_status os ON o.status_id = os.status_id " +
                     "WHERE o.user_id = ? ORDER BY o.order_date DESC";
                     
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getInt("order_id"));
                    order.setUserId(rs.getInt("user_id"));
                    order.setTotalAmount(rs.getBigDecimal("total_amount"));
                    order.setOrderDate(rs.getTimestamp("order_date"));
                    order.setStatusId(rs.getInt("status_id"));
                    order.setStatusName(rs.getString("status_name"));
                    
                    // fetch items
                    order.setOrderItems(getOrderItems(order.getOrderId()));
                    orders.add(order);
                }
            }
        }
        return orders;
    }

    @Override
    public List<OrderItem> getOrderItems(int orderId) throws SQLException {
        List<OrderItem> items = new ArrayList<>();
        String sql = "SELECT oi.*, p.product_name, p.image_url FROM order_items oi " +
                     "LEFT JOIN products p ON oi.product_id = p.product_id " +
                     "WHERE oi.order_id = ?";
                     
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, orderId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setOrderItemId(rs.getInt("order_item_id"));
                    item.setOrderId(rs.getInt("order_id"));
                    item.setProductId(rs.getInt("product_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setUnitPrice(rs.getBigDecimal("unit_price"));
                    
                    Product product = new Product();
                    product.setProductId(rs.getInt("product_id"));
                    product.setProductName(rs.getString("product_name"));
                    product.setImageUrl(rs.getString("image_url"));
                    
                    item.setProduct(product);
                    items.add(item);
                }
            }
        }
        return items;
    }

    @Override
    public List<Order> getAllOrders(String statusFilter, String search) throws SQLException {
        List<Order> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT o.*, os.status_name, u.full_name as customer_name, u.email as customer_email, " +
            "p.payment_method, p.payment_status " +
            "FROM orders o " +
            "LEFT JOIN order_status os ON o.status_id = os.status_id " +
            "LEFT JOIN users u ON o.user_id = u.user_id " +
            "LEFT JOIN payments p ON o.order_id = p.order_id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !statusFilter.equals("All Status")) {
            sql.append(" AND o.status_id = ?");
            params.add(Integer.parseInt(statusFilter));
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (CAST(o.order_id AS TEXT) ILIKE ? OR u.full_name ILIKE ? OR u.email ILIKE ?)");
            String searchPattern = "%" + search + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        sql.append(" ORDER BY o.order_date DESC");

        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
             
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getInt("order_id"));
                    order.setUserId(rs.getInt("user_id"));
                    order.setTotalAmount(rs.getBigDecimal("total_amount"));
                    order.setOrderDate(rs.getTimestamp("order_date"));
                    order.setStatusId(rs.getInt("status_id"));
                    order.setStatusName(rs.getString("status_name"));
                    order.setCustomerName(rs.getString("customer_name"));
                    order.setCustomerEmail(rs.getString("customer_email"));
                    order.setPaymentMethod(rs.getString("payment_method"));
                    order.setPaymentStatus(rs.getString("payment_status"));
                    
                    // fetch items (could optimize this with a single query, but N+1 is fine for now)
                    order.setOrderItems(getOrderItems(order.getOrderId()));
                    orders.add(order);
                }
            }
        }
        return orders;
    }

    @Override
    public Map<String, Integer> getOrderStats() throws SQLException {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("pending", 0);
        stats.put("processing", 0);
        stats.put("shipped", 0);
        stats.put("delivered", 0);

        String sql = "SELECT " +
                     "  COUNT(CASE WHEN status_id = 1 THEN 1 END) as pending, " +
                     "  COUNT(CASE WHEN status_id = 2 THEN 1 END) as processing, " +
                     "  COUNT(CASE WHEN status_id = 4 THEN 1 END) as shipped, " +
                     "  COUNT(CASE WHEN status_id = 5 THEN 1 END) as delivered " +
                     "FROM orders";

        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                stats.put("pending", rs.getInt("pending"));
                stats.put("processing", rs.getInt("processing"));
                stats.put("shipped", rs.getInt("shipped"));
                stats.put("delivered", rs.getInt("delivered"));
            }
        }
        return stats;
    }

    @Override
    public void updateOrderStatus(int orderId, int statusId) throws SQLException {
        String sql = "UPDATE orders SET status_id = ? WHERE order_id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, statusId);
            stmt.setInt(2, orderId);
            stmt.executeUpdate();
        }
    }

    @Override
    public Order getOrderById(int orderId) throws SQLException {
        String sql = "SELECT o.*, os.status_name, u.full_name as customer_name, u.email as customer_email, " +
                     "p.payment_method, p.payment_status " +
                     "FROM orders o " +
                     "LEFT JOIN order_status os ON o.status_id = os.status_id " +
                     "LEFT JOIN users u ON o.user_id = u.user_id " +
                     "LEFT JOIN payments p ON o.order_id = p.order_id " +
                     "WHERE o.order_id = ?";

        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, orderId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getInt("order_id"));
                    order.setUserId(rs.getInt("user_id"));
                    order.setTotalAmount(rs.getBigDecimal("total_amount"));
                    order.setOrderDate(rs.getTimestamp("order_date"));
                    order.setStatusId(rs.getInt("status_id"));
                    order.setStatusName(rs.getString("status_name"));
                    order.setCustomerName(rs.getString("customer_name"));
                    order.setCustomerEmail(rs.getString("customer_email"));
                    order.setPaymentMethod(rs.getString("payment_method"));
                    order.setPaymentStatus(rs.getString("payment_status"));
                    order.setOrderItems(getOrderItems(order.getOrderId()));
                    return order;
                }
            }
        }
        return null;
    }
}
