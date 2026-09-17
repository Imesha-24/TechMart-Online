package lk.iu.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lk.iu.model.User;
import lk.iu.util.DBConnectionUtil;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/admin/login")
public class AdminLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null && "ADMIN".equalsIgnoreCase((String) session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
            return;
        }
        request.getRequestDispatcher("/admin/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Email and password are required.");
            request.getRequestDispatcher("/admin/login.jsp").forward(request, response);
            return;
        }

        email = email.trim().toLowerCase();
        String hashedPassword = hashPassword(password);

        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            String sql = "SELECT user_id, full_name, phone, email, role, created_at " +
                         "FROM users WHERE email = ? AND password = ? AND role = 'ADMIN'";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            stmt.setString(2, hashedPassword);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setFullName(rs.getString("full_name"));
                user.setPhone(rs.getString("phone"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                user.setCreatedAt(rs.getTimestamp("created_at"));

                HttpSession session = request.getSession(true);
                session.setAttribute("user", user);
                session.setAttribute("userId", user.getUserId());
                session.setAttribute("userName", user.getFullName());
                session.setAttribute("userEmail", user.getEmail());
                session.setAttribute("userRole", user.getRole());

                session.setMaxInactiveInterval(30 * 60);

                System.out.println("[AdminLoginServlet] Admin logged in: " + user.getEmail());

                rs.close();
                stmt.close();

                response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
            } else {
                rs.close();
                stmt.close();

                request.setAttribute("error", "Invalid admin email or password.");
                request.setAttribute("email", email);
                request.getRequestDispatcher("/admin/login.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            System.err.println("[AdminLoginServlet] Database error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "A system error occurred. Please try again later.");
            request.getRequestDispatcher("/admin/login.jsp").forward(request, response);
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }

    private String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }
}
