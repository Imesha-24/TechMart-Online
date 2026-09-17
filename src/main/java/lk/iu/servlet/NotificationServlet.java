package lk.iu.servlet;

import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lk.iu.model.Notification;
import lk.iu.model.User;
import lk.iu.service.NotificationService;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {

    @EJB
    private NotificationService notificationService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        try {
            List<Notification> notifications = notificationService.getNotificationsByUserId(user.getUserId());
            request.setAttribute("notifications", notifications);
            request.getRequestDispatcher("/notifications.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred while retrieving notifications.");
        }
    }
}
