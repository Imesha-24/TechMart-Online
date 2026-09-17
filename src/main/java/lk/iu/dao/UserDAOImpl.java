package lk.iu.dao;

import jakarta.enterprise.context.ApplicationScoped;
import lk.iu.model.User;
import lk.iu.util.DBConnectionUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;


@ApplicationScoped
public class UserDAOImpl implements UserDAO {


    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setRole(rs.getString("role"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        return u;
    }

    @Override
    public List<User> findAll() throws SQLException {
        String sql = "SELECT user_id, full_name, email, phone, role, created_at " +
                     "FROM users ORDER BY created_at DESC";
        List<User> list = new ArrayList<>();
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    @Override
    public List<User> findByRole(String role) throws SQLException {
        String sql = "SELECT user_id, full_name, email, phone, role, created_at " +
                     "FROM users WHERE UPPER(role) = UPPER(?) ORDER BY created_at DESC";
        List<User> list = new ArrayList<>();
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, role);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    @Override
    public List<User> findByKeyword(String keyword) throws SQLException {
        String sql = "SELECT user_id, full_name, email, phone, role, created_at " +
                     "FROM users " +
                     "WHERE LOWER(full_name) LIKE LOWER(?) OR LOWER(email) LIKE LOWER(?) " +
                     "ORDER BY created_at DESC";
        List<User> list = new ArrayList<>();
        String pattern = "%" + keyword + "%";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, pattern);
            stmt.setString(2, pattern);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    @Override
    public List<User> findByCriteria(String role, String keyword) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT user_id, full_name, email, phone, role, created_at FROM users WHERE 1=1");

        boolean hasRole    = role    != null && !role.isBlank();
        boolean hasKeyword = keyword != null && !keyword.isBlank();

        if (hasRole)    sql.append(" AND UPPER(role) = UPPER(?)");
        if (hasKeyword) sql.append(" AND (LOWER(full_name) LIKE LOWER(?) OR LOWER(email) LIKE LOWER(?))");
        sql.append(" ORDER BY created_at DESC");

        List<User> list = new ArrayList<>();
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (hasRole)    stmt.setString(idx++, role);
            if (hasKeyword) {
                String p = "%" + keyword + "%";
                stmt.setString(idx++, p);
                stmt.setString(idx,   p);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    @Override
    public User findById(int userId) throws SQLException {
        String sql = "SELECT user_id, full_name, email, phone, role, created_at " +
                     "FROM users WHERE user_id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    @Override
    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT user_id, full_name, email, phone, role, created_at " +
                     "FROM users WHERE LOWER(email) = LOWER(?)";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }


    @Override
    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    @Override
    public int countNewThisMonth() throws SQLException {
        String sql = "SELECT COUNT(*) FROM users " +
                     "WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE)";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }


    @Override
    public int insert(User user) throws SQLException {
        String sql = "INSERT INTO users (full_name, email, password, phone, role) " +
                     "VALUES (?, ?, ?, ?, ?) RETURNING user_id";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, user.getFullName());
            stmt.setString(2, user.getEmail().toLowerCase());
            stmt.setString(3, user.getPassword());
            stmt.setString(4, user.getPhone());
            stmt.setString(5, user.getRole() != null ? user.getRole().toUpperCase() : "CUSTOMER");
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    @Override
    public void update(User user) throws SQLException {
        String sql = "UPDATE users SET full_name = ?, email = ?, phone = ?, role = ? " +
                     "WHERE user_id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, user.getFullName());
            stmt.setString(2, user.getEmail().toLowerCase());
            stmt.setString(3, user.getPhone());
            stmt.setString(4, user.getRole().toUpperCase());
            stmt.setInt(5, user.getUserId());
            stmt.executeUpdate();
        }
    }

    @Override
    public void updatePassword(int userId, String hashedPassword) throws SQLException {
        String sql = "UPDATE users SET password = ? WHERE user_id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, hashedPassword);
            stmt.setInt(2, userId);
            stmt.executeUpdate();
        }
    }

    @Override
    public void delete(int userId) throws SQLException {
        String sql = "DELETE FROM users WHERE user_id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        }
    }

    @Override
    public boolean emailExists(String email, int excludeId) throws SQLException {
        String sql = excludeId > 0
                ? "SELECT 1 FROM users WHERE LOWER(email) = LOWER(?) AND user_id <> ?"
                : "SELECT 1 FROM users WHERE LOWER(email) = LOWER(?)";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            if (excludeId > 0) stmt.setInt(2, excludeId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }
}
