package lk.iu.servlet;

import com.google.gson.Gson;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lk.iu.model.Order;
import lk.iu.service.OrderService;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/orders")
public class AdminOrderServlet extends HttpServlet {

    @EJB
    private OrderService orderService;

    private Gson gson;

    @Override
    public void init() throws ServletException {
        gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("search");
        String statusFilter = request.getParameter("status");

        try {
            Map<String, Integer> stats = orderService.getOrderStats();
            request.setAttribute("stats", stats);

            List<Order> orders = orderService.getAllOrders(statusFilter, search);
            request.setAttribute("orders", orders);
            request.setAttribute("search", search != null ? search : "");
            request.setAttribute("selectedStatus", statusFilter != null ? statusFilter : "All Status");

        } catch (SQLException e) {
            log("[AdminOrderServlet] Failed to load order data: " + e.getMessage());
            request.setAttribute("error", "Failed to load order data: " + e.getMessage());
        }

        request.getRequestDispatcher("/admin/orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "";

        try {
            if ("update_status".equals(action)) {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                int statusId = Integer.parseInt(request.getParameter("statusId"));
                orderService.updateOrderStatus(orderId, statusId);
                request.getSession().setAttribute("successMsg", "Order #" + orderId + " status updated successfully.");
                response.sendRedirect(request.getContextPath() + "/admin/orders");
                return;
            } else if ("view_order".equals(action)) {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                Order order = orderService.getOrderById(orderId);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(gson.toJson(order));
                return;
            }
        } catch (Exception e) {
            log("[AdminOrderServlet] Action '" + action + "' failed: " + e.getMessage());
            request.getSession().setAttribute("errorMsg", "Operation failed: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/orders");
    }
}
