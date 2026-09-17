package lk.iu.servlet;

import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lk.iu.model.User;
import lk.iu.service.UserService;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {

    @EJB
    private UserService userService;


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String role    = request.getParameter("role");
        String search  = request.getParameter("search");

        List<User> users   = List.of();
        int totalCount     = 0;
        int newThisMonth   = 0;

        try {
            users        = userService.getFilteredUsers(role, search);
            totalCount   = userService.getTotalUserCount();
            newThisMonth = userService.getNewThisMonthCount();
        } catch (SQLException e) {
            log("[AdminUserServlet] Failed to load users: " + e.getMessage());
            request.setAttribute("error", "Failed to load users: " + e.getMessage());
        }

        request.setAttribute("users",        users);
        request.setAttribute("totalCount",   totalCount);
        request.setAttribute("newThisMonth", newThisMonth);
        request.setAttribute("activeCount",  totalCount); // all rows = active (no status col in DB)
        request.setAttribute("selectedRole", role   != null ? role   : "");
        request.setAttribute("search",       search != null ? search : "");

        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "";

        String redirectUrl = request.getContextPath() + "/admin/users";

        try {
            switch (action) {
                case "add"           -> handleAdd(request);
                case "update"        -> handleUpdate(request);
                case "resetPassword" -> handleResetPassword(request);
                case "delete"        -> handleDelete(request);
                default              -> log("[AdminUserServlet] Unknown action: " + action);
            }
            request.getSession().setAttribute("successMsg", getSuccessMessage(action));
        } catch (IllegalArgumentException e) {
            log("[AdminUserServlet] Validation error on action '" + action + "': " + e.getMessage());
            request.getSession().setAttribute("errorMsg", e.getMessage());
        } catch (Exception e) {
            log("[AdminUserServlet] Action '" + action + "' failed: " + e.getMessage());
            request.getSession().setAttribute("errorMsg", "Operation failed: " + e.getMessage());
        }

        response.sendRedirect(redirectUrl);
    }


    private void handleAdd(HttpServletRequest req) throws SQLException {
        User u = buildUserFromRequest(req);
        u.setPassword(req.getParameter("password"));
        userService.addUser(u);
    }


    private void handleUpdate(HttpServletRequest req) throws SQLException {
        User u = buildUserFromRequest(req);
        u.setUserId(parseIntSafe(req.getParameter("userId"), 0));
        userService.updateUser(u);
    }


    private void handleResetPassword(HttpServletRequest req) throws SQLException {
        int    userId      = parseIntSafe(req.getParameter("userId"), 0);
        String newPassword = req.getParameter("newPassword");
        if (userId > 0) userService.resetPassword(userId, newPassword);
    }


    private void handleDelete(HttpServletRequest req) throws SQLException {
        int userId = parseIntSafe(req.getParameter("userId"), 0);
        if (userId > 0) userService.deleteUser(userId);
    }


    private User buildUserFromRequest(HttpServletRequest req) {
        User u = new User();
        u.setFullName(req.getParameter("fullName"));
        u.setEmail(req.getParameter("email"));
        u.setPhone(req.getParameter("phone"));
        u.setRole(req.getParameter("role") != null ? req.getParameter("role").toUpperCase() : "CUSTOMER");
        return u;
    }

    private int parseIntSafe(String value, int defaultVal) {
        try { return (value != null && !value.isBlank()) ? Integer.parseInt(value.trim()) : defaultVal; }
        catch (NumberFormatException e) { return defaultVal; }
    }

    private String getSuccessMessage(String action) {
        return switch (action) {
            case "add"           -> "User created successfully!";
            case "update"        -> "User updated successfully!";
            case "resetPassword" -> "Password reset successfully!";
            case "delete"        -> "User deleted successfully!";
            default              -> "Operation completed.";
        };
    }
}
