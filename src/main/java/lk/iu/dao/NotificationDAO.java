package lk.iu.dao;

import lk.iu.model.Notification;

import java.sql.SQLException;
import java.util.List;

public interface NotificationDAO {
    boolean addNotification(Notification notification) throws SQLException;
    List<Notification> getNotificationsByUserId(int userId) throws SQLException;
    int getNotificationCountByUserId(int userId) throws SQLException;
}
