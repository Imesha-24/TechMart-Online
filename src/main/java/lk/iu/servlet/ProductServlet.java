package lk.iu.servlet;

import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lk.iu.model.Product;
import lk.iu.service.ProductService;
import lk.iu.util.DBConnectionUtil;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


@WebServlet("/products")
public class ProductServlet extends HttpServlet {

    @EJB
    private ProductService productService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String category = request.getParameter("category");
        String search   = request.getParameter("search");
        String sort     = request.getParameter("sort");

        List<Product> productList = new ArrayList<>();

        try {

            productList = productService.getFilteredProducts(category, search, sort);

            log("[ProductServlet] Loaded " + productList.size() + " products" +
                    (category != null && !category.equals("all") ? " | cat=" + category : "") +
                    (search   != null && !search.isBlank()       ? " | search=" + search  : "") +
                    (sort     != null && !sort.isBlank()          ? " | sort=" + sort      : ""));

        } catch (SQLException e) {
            log("[ProductServlet] Service call failed: " + e.getMessage());
            request.setAttribute("error", "Unable to load products. Please try again.");
        }

        request.setAttribute("productList",      productList);
        request.setAttribute("selectedCategory", category != null ? category : "all");
        request.setAttribute("searchQuery",      search   != null ? search   : "");
        request.setAttribute("selectedSort",     sort     != null ? sort     : "featured");
        request.getRequestDispatcher("/products.jsp").forward(request, response);
    }


    @Deprecated
    static Product mapResultSetToProduct(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setProductId(rs.getInt("product_id"));
        product.setProductName(rs.getString("product_name"));
        product.setDescription(rs.getString("description"));
        product.setPrice(rs.getBigDecimal("price"));
        product.setStockQuantity(rs.getInt("stock_quantity"));
        product.setImageUrl(rs.getString("image_url"));
        product.setCategoryId(rs.getInt("category_id"));
        product.setCreatedAt(rs.getTimestamp("created_at"));
        product.setBrandId(rs.getInt("brand_id"));
        product.setColorId(rs.getInt("color_id"));
        product.setCategoryName(rs.getString("category_name"));
        product.setBrandName(rs.getString("brand_name"));
        product.setColorName(rs.getString("color_name"));
        return product;
    }
}
