package lk.iu.servlet;

import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lk.iu.model.Order;
import lk.iu.model.User;
import lk.iu.service.OrderService;

import java.io.IOException;
import java.util.List;

@WebServlet("/orders")
public class OrderServlet extends HttpServlet {

    @EJB
    private OrderService orderService;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        List<Order> orders = null;
        try {
            orders = orderService.getOrdersByUserId(user.getUserId());
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load orders.");
        }

        req.setAttribute("orders", orders);
        req.getRequestDispatcher("/orders.jsp").forward(req, resp);
    }
}
