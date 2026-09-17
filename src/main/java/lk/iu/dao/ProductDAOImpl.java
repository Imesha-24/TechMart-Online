package lk.iu.dao;

import jakarta.enterprise.context.ApplicationScoped;
import lk.iu.model.Brand;
import lk.iu.model.Category;
import lk.iu.model.Product;
import lk.iu.util.DBConnectionUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@ApplicationScoped
public class ProductDAOImpl implements ProductDAO {

    private static final String BASE_SQL =
            "SELECT p.product_id, p.product_name, p.description, p.price, " +
            "       p.stock_quantity, p.image_url, p.product_url, p.category_id, p.created_at, " +
            "       p.brand_id, p.color_id, " +
            "       COALESCE(p.is_visible, true) AS is_visible, " +
            "       b.brand_name, c.category_name, col.color_name " +
            "FROM products p " +
            "LEFT JOIN brands     b   ON p.brand_id    = b.brand_id " +
            "LEFT JOIN categories c   ON p.category_id = c.category_id " +
            "LEFT JOIN colors     col ON p.color_id    = col.color_id ";

    @Override
    public List<Product> findAll() throws SQLException {
        String sql = BASE_SQL + "ORDER BY p.product_id ASC";
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                return mapList(rs);
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }

    @Override
    public List<Product> findByCategory(String categoryName) throws SQLException {
        String sql = BASE_SQL + "WHERE LOWER(c.category_name) = ? ORDER BY p.product_id ASC";
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, categoryName.trim().toLowerCase());
                try (ResultSet rs = ps.executeQuery()) {
                    return mapList(rs);
                }
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }

    @Override
    public List<Product> findByKeyword(String keyword) throws SQLException {
        String sql = BASE_SQL +
                "WHERE LOWER(p.product_name) LIKE ? OR LOWER(b.brand_name) LIKE ? " +
                "ORDER BY p.product_id ASC";
        String pattern = "%" + keyword.trim().toLowerCase() + "%";
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, pattern);
                ps.setString(2, pattern);
                try (ResultSet rs = ps.executeQuery()) {
                    return mapList(rs);
                }
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }

    @Override
    public List<Product> findByCriteria(String categoryName, String keyword, String sortColumn)
            throws SQLException {

        List<String> conditions = new ArrayList<>();
        List<Object>  params    = new ArrayList<>();

        boolean hasCategory = categoryName != null && !categoryName.isBlank()
                              && !categoryName.equalsIgnoreCase("all");
        boolean hasKeyword  = keyword      != null && !keyword.isBlank();

        if (hasCategory) {
            conditions.add("LOWER(c.category_name) = ?");
            params.add(categoryName.trim().toLowerCase());
        }
        if (hasKeyword) {
            conditions.add("(LOWER(p.product_name) LIKE ? OR LOWER(b.brand_name) LIKE ?)");
            String pattern = "%" + keyword.trim().toLowerCase() + "%";
            params.add(pattern);
            params.add(pattern);
        }

        String orderBy = resolveOrderBy(sortColumn);

        StringBuilder sql = new StringBuilder(BASE_SQL);
        if (!conditions.isEmpty()) {
            sql.append("WHERE ").append(String.join(" AND ", conditions)).append(" ");
        }
        sql.append("ORDER BY ").append(orderBy);

        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    return mapList(rs);
                }
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }

    @Override
    public Product findById(int productId) throws SQLException {
        String sql = BASE_SQL + "WHERE p.product_id = ?";
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next() ? mapRow(rs) : null;
                }
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }

    private List<Product> mapList(ResultSet rs) throws SQLException {
        List<Product> list = new ArrayList<>();
        while (rs.next()) {
            list.add(mapRow(rs));
        }
        return list;
    }

    private Product mapRow(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getInt("product_id"));
        p.setProductName(rs.getString("product_name"));
        p.setDescription(rs.getString("description"));
        p.setPrice(rs.getBigDecimal("price"));
        p.setStockQuantity(rs.getInt("stock_quantity"));
        p.setImageUrl(rs.getString("image_url"));
        p.setProductUrl(rs.getString("product_url"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setBrandId(rs.getInt("brand_id"));
        p.setColorId(rs.getInt("color_id"));
        // Try to read is_visible; default true if column not present
        try { p.setVisible(rs.getBoolean("is_visible")); } catch (SQLException ignored) { p.setVisible(true); }
        // Joined display fields
        p.setCategoryName(rs.getString("category_name"));
        p.setBrandName(rs.getString("brand_name"));
        p.setColorName(rs.getString("color_name"));
        return p;
    }

    private String resolveOrderBy(String sortParam) {
        if (sortParam == null) return "p.product_id ASC";
        return switch (sortParam.toLowerCase()) {
            case "price-low"  -> "p.price ASC";
            case "price-high" -> "p.price DESC";
            case "name"       -> "p.product_name ASC";
            case "newest"     -> "p.created_at DESC";
            default           -> "p.product_id ASC"; // "featured"
        };
    }

    @Override
    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM products";
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }

    @Override
    public List<Category> findAllCategories() throws SQLException {
        String sql = "SELECT category_id, category_name FROM categories ORDER BY category_name ASC";
        List<Category> list = new ArrayList<>();
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Category(rs.getInt("category_id"), rs.getString("category_name")));
                }
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
        return list;
    }

    @Override
    public List<Brand> findAllBrands() throws SQLException {
        String sql = "SELECT brand_id, brand_name FROM brands ORDER BY brand_name ASC";
        List<Brand> list = new ArrayList<>();
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Brand(rs.getInt("brand_id"), rs.getString("brand_name")));
                }
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
        return list;
    }

    @Override
    public int insert(Product product) throws SQLException {
        String sql = "INSERT INTO products (product_name, description, price, stock_quantity, " +
                     "image_url, product_url, category_id, brand_id, color_id, is_visible) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING product_id";
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, product.getProductName());
                ps.setString(2, product.getDescription());
                ps.setBigDecimal(3, product.getPrice());
                ps.setInt(4, product.getStockQuantity());
                ps.setString(5, product.getImageUrl());
                ps.setString(6, product.getProductUrl());
                ps.setInt(7, product.getCategoryId());
                ps.setInt(8, product.getBrandId());
                if (product.getColorId() > 0) ps.setInt(9, product.getColorId()); else ps.setNull(9, java.sql.Types.INTEGER);
                ps.setBoolean(10, product.isVisible());
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next() ? rs.getInt(1) : -1;
                }
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }

    @Override
    public void update(Product product) throws SQLException {
        String sql = "UPDATE products SET product_name=?, description=?, price=?, stock_quantity=?, " +
                     "image_url=?, product_url=?, category_id=?, brand_id=?, color_id=?, is_visible=? " +
                     "WHERE product_id=?";
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, product.getProductName());
                ps.setString(2, product.getDescription());
                ps.setBigDecimal(3, product.getPrice());
                ps.setInt(4, product.getStockQuantity());
                ps.setString(5, product.getImageUrl());
                ps.setString(6, product.getProductUrl());
                ps.setInt(7, product.getCategoryId());
                ps.setInt(8, product.getBrandId());
                if (product.getColorId() > 0) ps.setInt(9, product.getColorId()); else ps.setNull(9, java.sql.Types.INTEGER);
                ps.setBoolean(10, product.isVisible());
                ps.setInt(11, product.getProductId());
                ps.executeUpdate();
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }

    @Override
    public void delete(int productId) throws SQLException {
        String sql = "DELETE FROM products WHERE product_id = ?";
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, productId);
                ps.executeUpdate();
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }

    @Override
    public void toggleVisibility(int productId, boolean visible) throws SQLException {
        // Try updating is_visible column; gracefully handle if column doesn't exist yet
        String sql = "UPDATE products SET is_visible = ? WHERE product_id = ?";
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setBoolean(1, visible);
                ps.setInt(2, productId);
                ps.executeUpdate();
            }
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }
}
