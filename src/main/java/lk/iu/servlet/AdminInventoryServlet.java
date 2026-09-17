package lk.iu.servlet;

import com.google.gson.Gson;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lk.iu.model.InventoryLog;
import lk.iu.model.Product;
import lk.iu.service.InventoryService;
import lk.iu.service.ProductService;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;


@WebServlet("/admin/inventory")
public class AdminInventoryServlet extends HttpServlet {

    @EJB
    private InventoryService inventoryService;

    @EJB
    private ProductService productService;

    private Gson gson;

    @Override
    public void init() throws ServletException {
        gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String search = request.getParameter("search");
        
        try {
            Map<String, Integer> stats = inventoryService.getInventoryStats();
            request.setAttribute("stats", stats);

            List<Product> products = productService.getFilteredProducts(null, search, null);
            request.setAttribute("products", products);
            request.setAttribute("search", search != null ? search : "");
            
        } catch (SQLException e) {
            log("[AdminInventoryServlet] Failed to load inventory data: " + e.getMessage());
            request.setAttribute("error", "Failed to load inventory data: " + e.getMessage());
        }

        request.getRequestDispatcher("/admin/inventory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "";

        try {
            if ("restock".equals(action)) {
                handleRestock(request, response);
                return;
            } else if ("history".equals(action)) {
                handleHistory(request, response);
                return;
            }
            log("[AdminInventoryServlet] Unknown action: " + action);
            response.sendRedirect(request.getContextPath() + "/admin/inventory");
            
        } catch (Exception e) {
            log("[AdminInventoryServlet] Action '" + action + "' failed: " + e.getMessage());
            request.getSession().setAttribute("errorMsg", "Operation failed: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/inventory");
        }
    }

    private void handleRestock(HttpServletRequest req, HttpServletResponse res) throws Exception {
        int productId = Integer.parseInt(req.getParameter("productId"));
        int addedStock = Integer.parseInt(req.getParameter("addedStock"));

        String adminUsername = "Admin";
        
        inventoryService.restockProduct(productId, addedStock, adminUsername);
        
        req.getSession().setAttribute("successMsg", "Stock updated successfully!");
        res.sendRedirect(req.getContextPath() + "/admin/inventory");
    }

    private void handleHistory(HttpServletRequest req, HttpServletResponse res) throws Exception {
        int productId = Integer.parseInt(req.getParameter("productId"));
        List<InventoryLog> history = inventoryService.getInventoryHistory(productId);
        
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        res.getWriter().write(gson.toJson(history));
    }
}
