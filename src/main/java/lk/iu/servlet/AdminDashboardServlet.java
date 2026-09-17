package lk.iu.servlet;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lk.iu.service.DashboardService;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.sql.SQLException;
import java.util.*;


@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    @EJB
    private DashboardService dashboardService;

    private Gson gson;

    @Override
    public void init() throws ServletException {
        gson = new GsonBuilder()
                .registerTypeAdapter(BigDecimal.class,
                        (com.google.gson.JsonSerializer<BigDecimal>)
                        (src, type, ctx) -> new com.google.gson.JsonPrimitive(src.stripTrailingZeros().toPlainString()))
                .registerTypeAdapter(Timestamp.class,
                        (com.google.gson.JsonSerializer<Timestamp>)
                        (src, type, ctx) -> new com.google.gson.JsonPrimitive(src.toString()))
                .create();
    }


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String api = request.getParameter("api");
        if ("chartData".equals(api)) {
            serveChartData(request, response);
            return;
        }

        int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);

        try {
            int totalProducts     = dashboardService.getTotalProducts();
            int productsThisMonth = dashboardService.getProductsThisMonth();
            int totalOrders       = dashboardService.getTotalOrders();
            int ordersThisMonth   = dashboardService.getOrdersThisMonth();
            BigDecimal revenue    = dashboardService.getTotalRevenue();
            BigDecimal revenueMonth = dashboardService.getRevenueThisMonth();
            int totalUsers        = dashboardService.getTotalUsers();
            int usersThisMonth    = dashboardService.getUsersThisMonth();

            request.setAttribute("totalProducts",     totalProducts);
            request.setAttribute("productsThisMonth", productsThisMonth);
            request.setAttribute("totalOrders",       totalOrders);
            request.setAttribute("ordersThisMonth",   ordersThisMonth);
            request.setAttribute("totalRevenue",      revenue);
            request.setAttribute("revenueThisMonth",  revenueMonth);
            request.setAttribute("totalUsers",        totalUsers);
            request.setAttribute("usersThisMonth",    usersThisMonth);

            List<BigDecimal> monthlyRevenue = dashboardService.getMonthlyRevenueForYear(currentYear);
            request.setAttribute("monthlyRevenueJson", gson.toJson(monthlyRevenue));
            request.setAttribute("revenueYear",        currentYear);

            List<Map<String, Object>> salesData = dashboardService.getMonthlySalesLast6Months();
            request.setAttribute("monthlySalesJson", gson.toJson(salesData));

            Map<String, Integer> inventoryStatus = dashboardService.getInventoryStatus();
            request.setAttribute("inventoryStatus",     inventoryStatus);
            request.setAttribute("inventoryStatusJson", gson.toJson(inventoryStatus));

            List<Map<String, Object>> recentOrders = dashboardService.getRecentOrders(8);
            request.setAttribute("recentOrders", recentOrders);

        } catch (SQLException e) {
            log("[AdminDashboardServlet] Failed to load dashboard data: " + e.getMessage());
            request.setAttribute("dashboardError", "Failed to load dashboard data: " + e.getMessage());
        }

        request.setAttribute("currentYear", currentYear);
        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }


    private void serveChartData(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int year;
        try {
            year = Integer.parseInt(request.getParameter("year"));
        } catch (NumberFormatException e) {
            year = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
        }

        Map<String, Object> data = new LinkedHashMap<>();
        try {
            data.put("revenue", dashboardService.getMonthlyRevenueForYear(year));
            data.put("year", year);
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            data.put("error", e.getMessage());
        }

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(gson.toJson(data));
    }
}
