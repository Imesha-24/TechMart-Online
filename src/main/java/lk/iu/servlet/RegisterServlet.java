package lk.iu.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lk.iu.util.DBConnectionUtil;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validation
        if (fullName == null || fullName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {

            request.setAttribute("error", "All required fields must be filled.");
            preserveFormData(request, fullName, phone, email);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        fullName = fullName.trim();
        phone = phone != null ? phone.trim() : "";
        email = email.trim().toLowerCase();

        if (password.length() < 8) {
            request.setAttribute("error", "Password must be at least 8 characters long.");
            preserveFormData(request, fullName, phone, email);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            preserveFormData(request, fullName, phone, email);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();

            String checkSql = "SELECT user_id FROM users WHERE email = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, email);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                request.setAttribute("error", "An account with this email already exists.");
                preserveFormData(request, fullName, phone, email);
                rs.close();
                checkStmt.close();
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }
            rs.close();
            checkStmt.close();

            String hashedPassword = hashPassword(password);

            String insertSql = "INSERT INTO users (full_name, email, password, phone, role) " +
                               "VALUES (?, ?, ?, ?, 'CUSTOMER')";
            PreparedStatement insertStmt = conn.prepareStatement(insertSql);
            insertStmt.setString(1, fullName);
            insertStmt.setString(2, email);
            insertStmt.setString(3, hashedPassword);
            insertStmt.setString(4, phone);

            int result = insertStmt.executeUpdate();
            insertStmt.close();

            if (result > 0) {
                System.out.println("[RegisterServlet] New user registered: " + email);
                // Redirect to login with success message
                response.sendRedirect(request.getContextPath() + "/login?registered=true");
            } else {
                request.setAttribute("error", "Registration failed. Please try again.");
                preserveFormData(request, fullName, phone, email);
                request.getRequestDispatcher("/register.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            System.err.println("[RegisterServlet] Database error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "A system error occurred. Please try again later.");
            preserveFormData(request, fullName, phone, email);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        } finally {
            DBConnectionUtil.closeConnection(conn);
        }
    }

    private void preserveFormData(HttpServletRequest request, String fullName, String phone, String email) {
        request.setAttribute("fullName", fullName);
        request.setAttribute("phone", phone);
        request.setAttribute("email", email);
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
