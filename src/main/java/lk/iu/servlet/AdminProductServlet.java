package lk.iu.servlet;

import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lk.iu.model.Brand;
import lk.iu.model.Category;
import lk.iu.model.Product;
import lk.iu.service.ProductService;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


@WebServlet("/admin/products")
public class AdminProductServlet extends HttpServlet {

    @EJB
    private ProductService productService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search   = request.getParameter("search");
        String category = request.getParameter("category");

        List<Product> products = new ArrayList<>();
        List<Category> categories = new ArrayList<>();
        List<Brand> brands = new ArrayList<>();
        int totalCount = 0;

        try {
            products   = productService.getFilteredProducts(category, search, null);
            categories = productService.getAllCategories();
            brands     = productService.getAllBrands();
            totalCount = productService.getTotalProductCount();
        } catch (SQLException e) {
            log("[AdminProductServlet] Failed to load products: " + e.getMessage());
            request.setAttribute("error", "Failed to load products: " + e.getMessage());
        }

        request.setAttribute("products",   products);
        request.setAttribute("categories", categories);
        request.setAttribute("brands",     brands);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("search",     search   != null ? search   : "");
        request.setAttribute("selectedCategory", category != null ? category : "");

        request.getRequestDispatcher("/admin/products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) action = "";

        String redirectUrl = request.getContextPath() + "/admin/products";

        try {
            switch (action) {
                case "add"        -> handleAdd(request);
                case "update"     -> handleUpdate(request);
                case "delete"     -> handleDelete(request);
                case "visibility" -> handleVisibility(request);
                default -> log("[AdminProductServlet] Unknown action: " + action);
            }
            request.getSession().setAttribute("successMsg", getSuccessMessage(action));
        } catch (Exception e) {
            log("[AdminProductServlet] Action '" + action + "' failed: " + e.getMessage());
            request.getSession().setAttribute("errorMsg", "Operation failed: " + e.getMessage());
        }

        response.sendRedirect(redirectUrl);
    }

    private void handleAdd(HttpServletRequest req) throws SQLException {
        Product p = buildProductFromRequest(req);
        p.setVisible(!"false".equals(req.getParameter("visible")));
        productService.addProduct(p);
    }

    private void handleUpdate(HttpServletRequest req) throws SQLException {
        Product p = buildProductFromRequest(req);
        p.setProductId(parseIntSafe(req.getParameter("productId"), 0));
        p.setVisible(!"false".equals(req.getParameter("visible")));
        productService.updateProduct(p);
    }

    private void handleDelete(HttpServletRequest req) throws SQLException {
        int id = parseIntSafe(req.getParameter("productId"), 0);
        if (id > 0) productService.deleteProduct(id);
    }

    private void handleVisibility(HttpServletRequest req) throws SQLException {
        int id      = parseIntSafe(req.getParameter("productId"), 0);
        boolean vis = "true".equals(req.getParameter("visible"));
        if (id > 0) productService.toggleProductVisibility(id, vis);
    }

    private Product buildProductFromRequest(HttpServletRequest req) {
        Product p = new Product();
        p.setProductName(req.getParameter("productName"));
        p.setDescription(req.getParameter("description"));
        p.setPrice(parseBigDecimalSafe(req.getParameter("price")));
        p.setStockQuantity(parseIntSafe(req.getParameter("stockQuantity"), 0));
        p.setImageUrl(req.getParameter("imageUrl"));
        p.setProductUrl(req.getParameter("productUrl"));
        p.setCategoryId(parseIntSafe(req.getParameter("categoryId"), 0));
        p.setBrandId(parseIntSafe(req.getParameter("brandId"), 0));
        p.setColorId(parseIntSafe(req.getParameter("colorId"), 0));
        return p;
    }

    private int parseIntSafe(String value, int defaultVal) {
        try { return (value != null && !value.isBlank()) ? Integer.parseInt(value.trim()) : defaultVal; }
        catch (NumberFormatException e) { return defaultVal; }
    }

    private BigDecimal parseBigDecimalSafe(String value) {
        try { return (value != null && !value.isBlank()) ? new BigDecimal(value.trim()) : BigDecimal.ZERO; }
        catch (NumberFormatException e) { return BigDecimal.ZERO; }
    }

    private String getSuccessMessage(String action) {
        return switch (action) {
            case "add"        -> "Product added successfully!";
            case "update"     -> "Product updated successfully!";
            case "delete"     -> "Product deleted successfully!";
            case "visibility" -> "Product visibility updated!";
            default           -> "Operation completed.";
        };
    }
}
