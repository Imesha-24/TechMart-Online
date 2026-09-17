package lk.iu.service;

import lk.iu.dao.UserDAO;
import lk.iu.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class UserServiceTest {

    @Mock
    private UserDAO userDAO;

    private UserService userService;

    @BeforeEach
    public void setUp() {
        userService = new UserServiceImpl(userDAO);
    }

    @Test
    public void testAddUser_Success() throws SQLException {
        User user = new User();
        user.setFullName("John Doe");
        user.setEmail("john@example.com");
        user.setPassword("password123"); // 11 chars
        user.setRole("CUSTOMER");

        when(userDAO.emailExists("john@example.com", 0)).thenReturn(false);
        when(userDAO.insert(any(User.class))).thenReturn(100);

        int generatedId = userService.addUser(user);

        assertEquals(100, generatedId);

        // Verify the DAO insert was called with hashed password
        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userDAO).insert(userCaptor.capture());
        
        User savedUser = userCaptor.getValue();
        assertEquals("John Doe", savedUser.getFullName());
        assertEquals("john@example.com", savedUser.getEmail());
        // SHA-256 hash length is 64 hex chars
        assertEquals(64, savedUser.getPassword().length());
        assertNotEquals("password123", savedUser.getPassword());
    }

    @Test
    public void testAddUser_MissingEmail() {
        User user = new User();
        user.setFullName("John Doe");
        user.setEmail("");
        user.setPassword("password123");

        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            userService.addUser(user);
        });

        assertEquals("Email is required.", exception.getMessage());
    }

    @Test
    public void testAddUser_MissingName() {
        User user = new User();
        user.setFullName("  ");
        user.setEmail("john@example.com");
        user.setPassword("password123");

        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            userService.addUser(user);
        });

        assertEquals("Full name is required.", exception.getMessage());
    }

    @Test
    public void testAddUser_ShortPassword() {
        User user = new User();
        user.setFullName("John Doe");
        user.setEmail("john@example.com");
        user.setPassword("short"); // 5 chars

        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            userService.addUser(user);
        });

        assertEquals("Password must be at least 8 characters.", exception.getMessage());
    }

    @Test
    public void testAddUser_DuplicateEmail() throws SQLException {
        User user = new User();
        user.setFullName("John Doe");
        user.setEmail("john@example.com");
        user.setPassword("password123");

        when(userDAO.emailExists("john@example.com", 0)).thenReturn(true);

        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            userService.addUser(user);
        });

        assertTrue(exception.getMessage().contains("already exists"));
    }

    @Test
    public void testUpdateUser_Success() throws SQLException {
        User user = new User();
        user.setUserId(10);
        user.setFullName("Jane Doe");
        user.setEmail("jane@example.com");

        when(userDAO.emailExists("jane@example.com", 10)).thenReturn(false);

        userService.updateUser(user);

        verify(userDAO).update(user);
    }

    @Test
    public void testResetPassword_Success() throws SQLException {
        userService.resetPassword(5, "newSecurePassword");

        verify(userDAO).updatePassword(eq(5), anyString());
    }

    @Test
    public void testResetPassword_TooShort() {
        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            userService.resetPassword(5, "short");
        });

        assertEquals("Password must be at least 8 characters.", exception.getMessage());
    }

    @Test
    public void testGetFilteredUsers_AllFilters() throws SQLException {
        List<User> list = new ArrayList<>();
        when(userDAO.findByCriteria("ADMIN", "test")).thenReturn(list);

        List<User> result = userService.getFilteredUsers("ADMIN", "test");

        assertSame(list, result);
        verify(userDAO).findByCriteria("ADMIN", "test");
    }
}
