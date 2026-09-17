package lk.iu.servlet;

import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lk.iu.model.Product;
import lk.iu.service.ProductService;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/product-details")
public class ProductDetailServlet extends HttpServlet {

    @EJB
    private ProductService productService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        }

        try {
            int productId = Integer.parseInt(idParam.trim());
            Product product = productService.getProductById(productId);

            if (product != null) {
                request.setAttribute("product", product);

                // Fetch related products (same category, excluding current product, up to 4 items)
                List<Product> allCategoryProducts = productService.getProductsByCategory(product.getCategoryName());
                List<Product> relatedProducts = allCategoryProducts.stream()
                        .filter(p -> p.getProductId() != productId)
                        .limit(4)
                        .collect(Collectors.toList());

                request.setAttribute("relatedProducts", relatedProducts);
            } else {
                request.setAttribute("error", "Product not found.");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        } catch (SQLException e) {
            log("[ProductDetailServlet] Service layer call failed", e);
            request.setAttribute("error", "Failed to retrieve product details due to server error.");
        }

        request.getRequestDispatcher("/product-details.jsp").forward(request, response);
    }
}
