package lk.iu.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lk.iu.model.Product;
import lk.iu.service.ProductService;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

@WebServlet("/api/products")
public class ProductApiServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @EJB
    private ProductService productService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String productId = request.getParameter("id");
        String category  = request.getParameter("category");
        String search    = request.getParameter("search");
        String sort      = request.getParameter("sort");

        try {
            if (productId != null && !productId.isBlank()) {
                // ── Single product by ID (synchronous) ─────────────────────
                int id = Integer.parseInt(productId.trim());
                Product product = productService.getProductById(id);

                if (product != null) {
                    out.print(gson.toJson(toJson(product)));
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print(errorJson("Product not found"));
                }

            } else {
                // ── Product list — uses @Asynchronous-style Future ─────────
                // This demonstrates the EJB @Asynchronous pattern:
                //   The service submits work to the managed thread pool and
                //   returns a Future immediately. We await with timeout to
                //   avoid blocking the servlet thread indefinitely.
                Future<List<Product>> futureProducts =
                        productService.getFilteredProductsAsync(category, search, sort);

                // Wait up to 5 seconds — mirrors @AccessTimeout in EJB
                List<Product> products = futureProducts.get(5, TimeUnit.SECONDS);

                JsonArray jsonArray = new JsonArray();
                for (Product p : products) {
                    jsonArray.add(toJson(p));
                }
                out.print(gson.toJson(jsonArray));
            }

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print(errorJson("Invalid product ID format"));

        } catch (java.util.concurrent.TimeoutException e) {
            // Mirrors EJB @AccessTimeout exceeded
            log("[ProductApiServlet] Async operation timed out");
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            out.print(errorJson("Request timed out — please retry"));

        } catch (java.util.concurrent.ExecutionException e) {
            // Unwrap exception from Future — mirrors EJB EJBException unwrap
            Throwable cause = e.getCause();
            log("[ProductApiServlet] Async execution failed: " +
                    (cause != null ? cause.getMessage() : e.getMessage()));
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(errorJson("Failed to load products"));

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(errorJson("Request interrupted"));

        } catch (SQLException e) {
            log("[ProductApiServlet] SQL error: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(errorJson("Database error"));
        }

        out.flush();
    }

    /**
     * Maps a Product domain object to a JSON representation.
     * In JAX-RS this would be handled automatically by a MessageBodyWriter
     * (e.g., Jackson or JSON-B provider).
     */
    private JsonObject toJson(Product p) {
        JsonObject json = new JsonObject();
        json.addProperty("id",          p.getProductId());
        json.addProperty("name",        p.getProductName());
        json.addProperty("description", p.getDescription());
        json.addProperty("category",    p.getCategoryName());
        json.addProperty("brand",       p.getBrandName());
        json.addProperty("color",       p.getColorName());
        json.addProperty("price",       p.getPrice());
        json.addProperty("stock",       p.getStockQuantity());
        json.addProperty("image",       p.getImageUrl());
        json.addProperty("productUrl",  p.getProductUrl());
        // Legacy UI fields (kept for frontend compatibility)
        json.addProperty("oldPrice",    p.getOldPrice());
        json.addProperty("rating",      p.getRating());
        json.addProperty("reviews",     p.getReviews());
        return json;
    }

    private String errorJson(String message) {
        JsonObject err = new JsonObject();
        err.addProperty("error", message);
        return gson.toJson(err);
    }
}
