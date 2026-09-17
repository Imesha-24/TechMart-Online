package lk.iu.service;

import jakarta.ejb.Local;
import lk.iu.model.User;

import java.sql.SQLException;
import java.util.List;


@Local
public interface UserService {

    List<User> getAllUsers() throws SQLException;

    List<User> getFilteredUsers(String role, String keyword) throws SQLException;

    User getUserById(int userId) throws SQLException;

    int getTotalUserCount() throws SQLException;

    int getNewThisMonthCount() throws SQLException;

    int addUser(User user) throws SQLException;

    void updateUser(User user) throws SQLException;

    void resetPassword(int userId, String newPassword) throws SQLException;

    void deleteUser(int userId) throws SQLException;
}
