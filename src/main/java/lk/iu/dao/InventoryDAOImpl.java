package lk.iu.dao;

import jakarta.enterprise.context.ApplicationScoped;
import lk.iu.model.InventoryLog;
import lk.iu.util.DBConnectionUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ApplicationScoped
public class InventoryDAOImpl implements InventoryDAO {

    @Override
    public Map<String, Integer> getInventoryStats() throws SQLException {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("in_stock", 0);
        stats.put("low_stock", 0);
        stats.put("out_of_stock", 0);

        String sql = "SELECT " +
                     "  COUNT(CASE WHEN stock_quantity >= 10 THEN 1 END) as in_stock, " +
                     "  COUNT(CASE WHEN stock_quantity > 0 AND stock_quantity < 10 THEN 1 END) as low_stock, " +
                     "  COUNT(CASE WHEN stock_quantity = 0 THEN 1 END) as out_of_stock " +
                     "FROM products";

        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("in_stock", rs.getInt("in_stock"));
                    stats.put("low_stock", rs.getInt("low_stock"));
                    stats.put("out_of_stock", rs.getInt("out_of_stock"));
                }
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
        return stats;
    }

    @Override
    public int updateStock(int productId, int addedStock) throws SQLException {
        String sql = "UPDATE products SET stock_quantity = stock_quantity + ? WHERE product_id = ? RETURNING stock_quantity";
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, addedStock);
                ps.setInt(2, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt("stock_quantity");
                    }
                }
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
        return -1; // Product not found
    }

    @Override
    public void addInventoryLog(InventoryLog log) throws SQLException {
        String sql = "INSERT INTO inventory_logs (product_id, previous_stock, new_stock, updated_by, updated_at) " +
                     "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, log.getProductId());
                ps.setInt(2, log.getPreviousStock());
                ps.setInt(3, log.getNewStock());
                ps.setString(4, log.getUpdatedBy());
                ps.executeUpdate();
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }

    @Override
    public List<InventoryLog> getInventoryHistory(int productId) throws SQLException {
        String sql = "SELECT log_id, product_id, previous_stock, new_stock, updated_by, updated_at " +
                     "FROM inventory_logs WHERE product_id = ? ORDER BY updated_at DESC";
        List<InventoryLog> logs = new ArrayList<>();
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        InventoryLog log = new InventoryLog();
                        log.setLogId(rs.getInt("log_id"));
                        log.setProductId(rs.getInt("product_id"));
                        log.setPreviousStock(rs.getInt("previous_stock"));
                        log.setNewStock(rs.getInt("new_stock"));
                        log.setUpdatedBy(rs.getString("updated_by"));
                        log.setUpdatedAt(rs.getTimestamp("updated_at"));
                        logs.add(log);
                    }
                }
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
        return logs;
    }
}
