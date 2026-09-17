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
import lk.iu.model.Category;
import lk.iu.service.ProductService;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/api/categories")
public class CategoryApiServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @EJB
    private ProductService productService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            List<Category> categories = productService.getAllCategories();
            JsonArray jsonArray = new JsonArray();
            for (Category c : categories) {
                JsonObject json = new JsonObject();
                json.addProperty("id", c.getCategoryId());
                json.addProperty("name", c.getCategoryName());
                // Add a default icon for the frontend
                json.addProperty("icon", getIconForCategory(c.getCategoryName()));
                jsonArray.add(json);
            }
            out.print(gson.toJson(jsonArray));
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject err = new JsonObject();
            err.addProperty("error", "Database error");
            out.print(gson.toJson(err));
        }
        out.flush();
    }

    private String getIconForCategory(String categoryName) {
        if (categoryName == null) return "fa-tag";
        String lower = categoryName.toLowerCase();
        if (lower.contains("laptop")) return "fa-laptop";
        if (lower.contains("phone") || lower.contains("mobile")) return "fa-mobile-alt";
        if (lower.contains("audio") || lower.contains("headphone")) return "fa-headphones";
        if (lower.contains("tablet")) return "fa-tablet-alt";
        if (lower.contains("monitor") || lower.contains("display")) return "fa-desktop";
        if (lower.contains("access") || lower.contains("keyboard")) return "fa-keyboard";
        return "fa-tag";
    }
}
