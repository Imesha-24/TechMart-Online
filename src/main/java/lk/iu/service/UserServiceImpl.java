package lk.iu.service;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.ejb.Local;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import lk.iu.dao.UserDAO;
import lk.iu.model.User;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Logger;


@Stateless
@Local(UserService.class)
public class UserServiceImpl implements UserService {

    private static final Logger LOG = Logger.getLogger(UserServiceImpl.class.getName());

    @Inject
    private UserDAO userDAO;

    public UserServiceImpl() {
    }

    public UserServiceImpl(UserDAO userDAO) {
        this.userDAO = userDAO;
    }


    @PostConstruct
    public void onCreate() {
        LOG.info("[UserService] @PostConstruct — @Stateless bean ready. "
                + "CDI @Inject resolved userDAO. "
                + "Contrast with @EJB: CDI injection is type-safe and supports interceptors.");
    }

    @PreDestroy
    public void onDestroy() {
        LOG.fine("[UserService] @PreDestroy — @Stateless bean instance retiring from pool. "
                + "No state to clean up (stateless design).");
    }

    @Override
    public List<User> getAllUsers() throws SQLException {
        return userDAO.findAll();
    }

    @Override
    public List<User> getFilteredUsers(String role, String keyword) throws SQLException {
        boolean hasRole    = role    != null && !role.isBlank()    && !"ALL".equalsIgnoreCase(role);
        boolean hasKeyword = keyword != null && !keyword.isBlank();

        if (!hasRole && !hasKeyword) return userDAO.findAll();
        return userDAO.findByCriteria(hasRole ? role : null, hasKeyword ? keyword : null);
    }

    @Override
    public User getUserById(int userId) throws SQLException {
        return userDAO.findById(userId);
    }

    @Override
    public int getTotalUserCount() throws SQLException {
        return userDAO.countAll();
    }

    @Override
    public int getNewThisMonthCount() throws SQLException {
        return userDAO.countNewThisMonth();
    }

    @Override
    public int addUser(User user) throws SQLException {
        if (user.getEmail() == null || user.getEmail().isBlank())
            throw new IllegalArgumentException("Email is required.");
        if (user.getFullName() == null || user.getFullName().isBlank())
            throw new IllegalArgumentException("Full name is required.");
        if (user.getPassword() == null || user.getPassword().length() < 8)
            throw new IllegalArgumentException("Password must be at least 8 characters.");
        if (userDAO.emailExists(user.getEmail(), 0))
            throw new IllegalArgumentException("A user with email '" + user.getEmail() + "' already exists.");

        user.setPassword(hashPassword(user.getPassword()));
        return userDAO.insert(user);
    }

    @Override
    public void updateUser(User user) throws SQLException {
        if (user.getEmail() == null || user.getEmail().isBlank())
            throw new IllegalArgumentException("Email is required.");
        if (user.getFullName() == null || user.getFullName().isBlank())
            throw new IllegalArgumentException("Full name is required.");
        if (userDAO.emailExists(user.getEmail(), user.getUserId()))
            throw new IllegalArgumentException("Email '" + user.getEmail() + "' is already used by another user.");

        userDAO.update(user);
    }

    @Override
    public void resetPassword(int userId, String newPassword) throws SQLException {
        if (newPassword == null || newPassword.length() < 8)
            throw new IllegalArgumentException("Password must be at least 8 characters.");
        userDAO.updatePassword(userId, hashPassword(newPassword));
    }

    @Override
    public void deleteUser(int userId) throws SQLException {
        userDAO.delete(userId);
    }

    private String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (byte b : hash) {
                String h = Integer.toHexString(0xff & b);
                if (h.length() == 1) hex.append('0');
                hex.append(h);
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }
}
