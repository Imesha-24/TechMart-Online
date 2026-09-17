package lk.iu.dao;

import lk.iu.model.User;

import java.sql.SQLException;
import java.util.List;

public interface UserDAO {

    List<User> findAll() throws SQLException;

    List<User> findByRole(String role) throws SQLException;

    List<User> findByKeyword(String keyword) throws SQLException;

    List<User> findByCriteria(String role, String keyword) throws SQLException;

    User findById(int userId) throws SQLException;

    User findByEmail(String email) throws SQLException;

    int countAll() throws SQLException;

    int countNewThisMonth() throws SQLException;

    int insert(User user) throws SQLException;

    void update(User user) throws SQLException;

    void updatePassword(int userId, String hashedPassword) throws SQLException;

    void delete(int userId) throws SQLException;

    boolean emailExists(String email, int excludeId) throws SQLException;
}
