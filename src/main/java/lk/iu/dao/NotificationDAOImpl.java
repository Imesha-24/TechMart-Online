package lk.iu.dao;

import jakarta.enterprise.context.ApplicationScoped;
import lk.iu.model.Notification;
import lk.iu.util.DBConnectionUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

@ApplicationScoped
public class NotificationDAOImpl implements NotificationDAO {

    @Override
    public boolean addNotification(Notification notification) throws SQLException {
        String sql = "INSERT INTO notifications (user_id, title, message, notification_type, created_at) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, notification.getUserId());
            stmt.setString(2, notification.getTitle());
            stmt.setString(3, notification.getMessage());
            stmt.setString(4, notification.getNotificationType());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        notification.setNotificationId(rs.getInt(1));
                        return true;
                    }
                }
            }
            return false;
        }
    }

    @Override
    public List<Notification> getNotificationsByUserId(int userId) throws SQLException {
        List<Notification> notifications = new ArrayList<>();
        String sql = "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC";
        
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Notification notification = new Notification();
                    notification.setNotificationId(rs.getInt("notification_id"));
                    notification.setUserId(rs.getInt("user_id"));
                    notification.setTitle(rs.getString("title"));
                    notification.setMessage(rs.getString("message"));
                    notification.setNotificationType(rs.getString("notification_type"));
                    notification.setCreatedAt(rs.getTimestamp("created_at"));
                    notifications.add(notification);
                }
            }
        }
        return notifications;
    }

    @Override
    public int getNotificationCountByUserId(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }
}
