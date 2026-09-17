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
import jakarta.servlet.http.HttpSession;
import lk.iu.model.CartItem;
import lk.iu.model.Product;
import lk.iu.service.CartService;
import lk.iu.util.EjbLookupUtil;

import javax.naming.NamingException;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

@WebServlet(urlPatterns = {"/api/cart", "/api/cart/*"})
public class CartServlet extends HttpServlet {

    private static final String CART_SERVICE_SESSION_KEY = "cartServiceEjb";
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            JsonObject error = new JsonObject();
            error.addProperty("error", "Not authenticated");
            out.print(gson.toJson(error));
            out.flush();
            return;
        }

        int userId = (int) session.getAttribute("userId");

        try {
            CartService cartService = getCartService(session);
            List<CartItem> cartItems = cartService.getCartItemsForUser(userId);

            JsonObject result = new JsonObject();
            JsonArray items = new JsonArray();
            BigDecimal subtotal = BigDecimal.ZERO;

            for (CartItem item : cartItems) {
                JsonObject itemJson = new JsonObject();
                itemJson.addProperty("cartItemId", item.getCartItemId());
                itemJson.addProperty("productId",  item.getProductId());
                itemJson.addProperty("quantity",   item.getQuantity());

                Product p = item.getProduct();
                if (p != null) {
                    itemJson.addProperty("name",      p.getProductName());
                    itemJson.addProperty("price",     p.getPrice());
                    itemJson.addProperty("image",     p.getImageUrl());
                    itemJson.addProperty("category",  p.getCategoryName());
                    itemJson.addProperty("stock",     p.getStockQuantity());
                    itemJson.addProperty("itemTotal", item.getItemTotal());
                    subtotal = subtotal.add(item.getItemTotal());
                }
                items.add(itemJson);
            }

            double subtotalDouble = subtotal.doubleValue();
            double shipping = subtotalDouble > 100 ? 0 : 9.99;
            double tax = subtotalDouble * 0.08;
            double total = subtotalDouble + shipping + tax;

            result.add("items", items);
            result.addProperty("itemCount", cartItems.stream().mapToInt(CartItem::getQuantity).sum());
            result.addProperty("subtotal",  Math.round(subtotalDouble * 100.0) / 100.0);
            result.addProperty("shipping",  Math.round(shipping * 100.0) / 100.0);
            result.addProperty("tax",       Math.round(tax * 100.0) / 100.0);
            result.addProperty("total",     Math.round(total * 100.0) / 100.0);

            out.print(gson.toJson(result));
        } catch (SQLException e) {
            log("[CartServlet] DB error loading cart items", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject error = new JsonObject();
            error.addProperty("error", "Failed to load cart");
            out.print(gson.toJson(error));
        } catch (NamingException e) {
            throw new ServletException("[CartServlet] CartService EJB lookup failed", e);
        } finally {
            out.flush();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            JsonObject error = new JsonObject();
            error.addProperty("error", "Not authenticated");
            out.print(gson.toJson(error));
            out.flush();
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String pathInfo = request.getPathInfo();
        if (pathInfo == null) {
            pathInfo = "/add";
        }

        try {
            CartService cartService = getCartService(session);
            JsonObject result = new JsonObject();

            switch (pathInfo) {
                case "/add":
                    handleAdd(request, userId, cartService, result);
                    break;
                case "/update":
                    handleUpdate(request, userId, cartService, result);
                    break;
                case "/remove":
                    handleRemove(request, userId, cartService, result);
                    break;
                case "/clear":
                    handleClear(userId, cartService, result);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    result.addProperty("error", "Unknown action");
            }

            int cartCount = cartService.getCartItemCount(userId);
            result.addProperty("cartCount", cartCount);
            out.print(gson.toJson(result));

        } catch (SQLException e) {
            log("[CartServlet] Cart operation failed", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject error = new JsonObject();
            error.addProperty("error", "Cart operation failed");
            out.print(gson.toJson(error));
        } catch (NamingException e) {
            throw new ServletException("[CartServlet] CartService EJB lookup failed", e);
        } finally {
            out.flush();
        }
    }

    private CartService getCartService(HttpSession session) throws NamingException {
        CartService cartService = (CartService) session.getAttribute(CART_SERVICE_SESSION_KEY);
        if (cartService == null) {
            cartService = EjbLookupUtil.lookup(CartService.class, "CartServiceImpl");
            session.setAttribute(CART_SERVICE_SESSION_KEY, cartService);
        }
        return cartService;
    }

    private void handleAdd(HttpServletRequest request, int userId, CartService cartService, JsonObject result)
            throws SQLException {
        int productId = Integer.parseInt(request.getParameter("productId"));
        int quantity = 1;
        String qtyParam = request.getParameter("quantity");
        if (qtyParam != null && !qtyParam.isEmpty()) {
            quantity = Math.max(1, Integer.parseInt(qtyParam));
        }

        cartService.addProductToCart(userId, productId, quantity);
        result.addProperty("success", true);
        result.addProperty("message", "Item added to cart");
    }

    private void handleUpdate(HttpServletRequest request, int userId, CartService cartService, JsonObject result)
            throws SQLException {
        int productId = Integer.parseInt(request.getParameter("productId"));
        int quantity  = Integer.parseInt(request.getParameter("quantity"));

        if (quantity <= 0) {
            cartService.removeProductFromCart(userId, productId);
            result.addProperty("success", true);
            result.addProperty("message", "Item removed from cart");
        } else {
            cartService.updateProductQuantity(userId, productId, quantity);
            result.addProperty("success", true);
            result.addProperty("message", "Cart updated");
        }
    }

    private void handleRemove(HttpServletRequest request, int userId, CartService cartService, JsonObject result)
            throws SQLException {
        int productId = Integer.parseInt(request.getParameter("productId"));
        cartService.removeProductFromCart(userId, productId);
        result.addProperty("success", true);
        result.addProperty("message", "Item removed from cart");
    }

    private void handleClear(int userId, CartService cartService, JsonObject result) throws SQLException {
        cartService.clearUserCart(userId);
        result.addProperty("success", true);
        result.addProperty("message", "Cart cleared");
    }
}
