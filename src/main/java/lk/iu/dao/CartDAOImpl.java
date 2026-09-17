package lk.iu.dao;

import jakarta.enterprise.context.ApplicationScoped;
import lk.iu.model.CartItem;
import lk.iu.model.Product;
import lk.iu.util.DBConnectionUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


@ApplicationScoped
public class CartDAOImpl implements CartDAO {

    @Override
    public int getOrCreateCartId(int userId) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            
            // 1. Check if cart exists
            String checkSql = "SELECT cart_id FROM carts WHERE user_id = ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, userId);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt("cart_id");
                    }
                }
            }

            // 2. If not found, create new cart
            String insertSql = "INSERT INTO carts (user_id) VALUES (?) RETURNING cart_id";
            try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                insertStmt.setInt(1, userId);
                try (ResultSet rsInsert = insertStmt.executeQuery()) {
                    if (rsInsert.next()) {
                        return rsInsert.getInt("cart_id");
                    }
                }
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
        throw new SQLException("Failed to retrieve or create cart for user_id: " + userId);
    }

    @Override
    public void addItem(int cartId, int productId, int quantity) throws SQLException {
        String sql = "INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (?, ?, ?) " +
                     "ON CONFLICT (cart_id, product_id) " +
                     "DO UPDATE SET quantity = cart_items.quantity + EXCLUDED.quantity";

        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, cartId);
                stmt.setInt(2, productId);
                stmt.setInt(3, quantity);
                stmt.executeUpdate();
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }

    @Override
    public void updateItemQuantity(int cartId, int productId, int quantity) throws SQLException {
        String sql = "UPDATE cart_items SET quantity = ? WHERE cart_id = ? AND product_id = ?";
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, quantity);
                stmt.setInt(2, cartId);
                stmt.setInt(3, productId);
                stmt.executeUpdate();
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }

    @Override
    public void removeItem(int cartId, int productId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE cart_id = ? AND product_id = ?";
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, cartId);
                stmt.setInt(2, productId);
                stmt.executeUpdate();
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }

    @Override
    public void clearCart(int cartId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE cart_id = ?";
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, cartId);
                stmt.executeUpdate();
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }

    @Override
    public List<CartItem> getCartItems(int cartId) throws SQLException {
        List<CartItem> items = new ArrayList<>();
        String sql = "SELECT ci.cart_item_id, ci.cart_id, ci.product_id, ci.quantity, " +
                     "p.product_name, p.price, p.stock_quantity, p.image_url, " +
                     "c.category_name, b.brand_name " +
                     "FROM cart_items ci " +
                     "JOIN products p ON ci.product_id = p.product_id " +
                     "LEFT JOIN categories c ON p.category_id = c.category_id " +
                     "LEFT JOIN brands b ON p.brand_id = b.brand_id " +
                     "WHERE ci.cart_id = ? ORDER BY ci.cart_item_id DESC";

        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, cartId);
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        CartItem item = new CartItem();
                        item.setCartItemId(rs.getInt("cart_item_id"));
                        item.setCartId(rs.getInt("cart_id"));
                        item.setProductId(rs.getInt("product_id"));
                        item.setQuantity(rs.getInt("quantity"));

                        Product product = new Product();
                        product.setProductId(rs.getInt("product_id"));
                        product.setProductName(rs.getString("product_name"));
                        product.setPrice(rs.getBigDecimal("price"));
                        product.setStockQuantity(rs.getInt("stock_quantity"));
                        product.setImageUrl(rs.getString("image_url"));
                        product.setCategoryName(rs.getString("category_name"));
                        product.setBrandName(rs.getString("brand_name"));
                        item.setProduct(product);

                        items.add(item);
                    }
                }
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
        return items;
    }

    @Override
    public int getCartCount(int cartId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(quantity), 0) AS total FROM cart_items WHERE cart_id = ?";
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, cartId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt("total");
                    }
                }
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
        return 0;
    }
}
