package lk.iu.dao;

import jakarta.enterprise.context.ApplicationScoped;
import lk.iu.util.DBConnectionUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

@ApplicationScoped
public class DashboardDAOImpl implements DashboardDAO {


    @Override
    public int getTotalProducts() throws SQLException {
        return queryInt("SELECT COUNT(*) FROM products");
    }

    @Override
    public int getProductsThisMonth() throws SQLException {
        return queryInt(
            "SELECT COUNT(*) FROM products " +
            "WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE)");
    }

    @Override
    public int getTotalOrders() throws SQLException {
        return queryInt("SELECT COUNT(*) FROM orders");
    }

    @Override
    public int getOrdersThisMonth() throws SQLException {
        return queryInt(
            "SELECT COUNT(*) FROM orders " +
            "WHERE DATE_TRUNC('month', order_date) = DATE_TRUNC('month', CURRENT_DATE)");
    }

    @Override
    public BigDecimal getTotalRevenue() throws SQLException {
        return queryBigDecimal(
            "SELECT COALESCE(SUM(amount), 0) FROM payments WHERE payment_status = 'COMPLETED'");
    }

    @Override
    public BigDecimal getRevenueThisMonth() throws SQLException {
        return queryBigDecimal(
            "SELECT COALESCE(SUM(amount), 0) FROM payments " +
            "WHERE payment_status = 'COMPLETED' " +
            "AND DATE_TRUNC('month', payment_date) = DATE_TRUNC('month', CURRENT_DATE)");
    }

    @Override
    public int getTotalUsers() throws SQLException {
        return queryInt("SELECT COUNT(*) FROM users");
    }

    @Override
    public int getUsersThisMonth() throws SQLException {
        return queryInt(
            "SELECT COUNT(*) FROM users " +
            "WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE)");
    }


    @Override
    public Map<Integer, BigDecimal> getMonthlyRevenue(int year) throws SQLException {
        String sql =
            "SELECT EXTRACT(MONTH FROM payment_date)::int AS month, " +
            "       COALESCE(SUM(amount), 0) AS revenue " +
            "FROM payments " +
            "WHERE payment_status = 'COMPLETED' " +
            "  AND EXTRACT(YEAR FROM payment_date) = ? " +
            "GROUP BY month ORDER BY month";

        Map<Integer, BigDecimal> result = new LinkedHashMap<>();
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, year);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    result.put(rs.getInt("month"), rs.getBigDecimal("revenue"));
                }
            }
        }
        return result;
    }

    @Override
    public List<Map<String, Object>> getMonthlySalesLast6Months() throws SQLException {
        String sql =
            "SELECT TO_CHAR(DATE_TRUNC('month', o.order_date), 'Mon') AS month_label, " +
            "       DATE_TRUNC('month', o.order_date) AS month_start, " +
            "       COUNT(o.order_id) AS order_count, " +
            "       COALESCE(SUM(o.total_amount), 0) AS sales_total " +
            "FROM orders o " +
            "WHERE o.order_date >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '5 months' " +
            "GROUP BY month_start, month_label " +
            "ORDER BY month_start";

        List<Map<String, Object>> rows = new ArrayList<>();
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("month",      rs.getString("month_label"));
                row.put("orderCount", rs.getInt("order_count"));
                row.put("salesTotal", rs.getBigDecimal("sales_total"));
                rows.add(row);
            }
        }
        return rows;
    }


    @Override
    public Map<String, Integer> getInventoryStatus() throws SQLException {
        String sql =
            "SELECT " +
            "  COUNT(CASE WHEN stock_quantity >= 10 THEN 1 END)             AS in_stock, " +
            "  COUNT(CASE WHEN stock_quantity > 0 AND stock_quantity < 10 THEN 1 END) AS low_stock, " +
            "  COUNT(CASE WHEN stock_quantity = 0 THEN 1 END)              AS out_of_stock " +
            "FROM products";

        Map<String, Integer> stats = new LinkedHashMap<>();
        stats.put("in_stock", 0);
        stats.put("low_stock", 0);
        stats.put("out_of_stock", 0);

        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                stats.put("in_stock",      rs.getInt("in_stock"));
                stats.put("low_stock",     rs.getInt("low_stock"));
                stats.put("out_of_stock",  rs.getInt("out_of_stock"));
            }
        }
        return stats;
    }

    @Override
    public List<Map<String, Object>> getRecentOrders(int limit) throws SQLException {
        String sql =
            "SELECT o.order_id, u.full_name AS customer_name, " +
            "       (SELECT COUNT(*) FROM order_items oi WHERE oi.order_id = o.order_id) AS item_count, " +
            "       o.total_amount, os.status_name, o.order_date " +
            "FROM orders o " +
            "LEFT JOIN users u ON o.user_id = u.user_id " +
            "LEFT JOIN order_status os ON o.status_id = os.status_id " +
            "ORDER BY o.order_date DESC " +
            "LIMIT ?";

        List<Map<String, Object>> rows = new ArrayList<>();
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("orderId",      rs.getInt("order_id"));
                    row.put("customerName", rs.getString("customer_name"));
                    row.put("itemCount",    rs.getInt("item_count"));
                    row.put("totalAmount",  rs.getBigDecimal("total_amount"));
                    row.put("statusName",   rs.getString("status_name"));
                    row.put("orderDate",    rs.getTimestamp("order_date"));
                    rows.add(row);
                }
            }
        }
        return rows;
    }


    private int queryInt(String sql) throws SQLException {
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private BigDecimal queryBigDecimal(String sql) throws SQLException {
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
        }
    }
}
