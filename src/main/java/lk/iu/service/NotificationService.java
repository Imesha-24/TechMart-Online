package lk.iu.service;

import jakarta.ejb.Local;
import lk.iu.model.Notification;

import java.sql.SQLException;
import java.util.List;
import java.util.concurrent.Future;

@Local
public interface NotificationService {

    boolean addNotification(Notification notification) throws SQLException;

    Future<Boolean> addNotificationAsync(Notification notification);

    Future<Boolean> addNotificationAsyncWithRetry(Notification notification);

    List<Notification> getNotificationsByUserId(int userId) throws SQLException;

    int getNotificationCountByUserId(int userId) throws SQLException;
}
