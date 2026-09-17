package lk.iu.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lk.iu.model.Order;
import lk.iu.model.OrderItem;
import lk.iu.model.User;
import lk.iu.service.OrderService;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/api/checkout")
public class CheckoutServlet extends HttpServlet {

    @EJB
    private OrderService orderService;

    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\": false, \"message\": \"User not logged in.\"}");
            out.flush();
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = req.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }

            JsonObject requestData = gson.fromJson(sb.toString(), JsonObject.class);

            if (requestData == null || !requestData.has("cartItems") || !requestData.has("totalAmount")) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\": false, \"message\": \"Invalid request data.\"}");
                out.flush();
                return;
            }

            BigDecimal totalAmount = requestData.get("totalAmount").getAsBigDecimal();
            JsonArray cartItems = requestData.getAsJsonArray("cartItems");

            if (cartItems.isEmpty()) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\": false, \"message\": \"Cart is empty.\"}");
                out.flush();
                return;
            }

            Order order = new Order();
            order.setUserId(user.getUserId());
            order.setTotalAmount(totalAmount);
            order.setStatusId(1);

            List<OrderItem> items = new ArrayList<>();
            for (JsonElement element : cartItems) {
                JsonObject itemObj = element.getAsJsonObject();
                OrderItem item = new OrderItem();
                item.setProductId(itemObj.get("id").getAsInt());
                item.setQuantity(itemObj.get("quantity").getAsInt());
                item.setUnitPrice(itemObj.get("price").getAsBigDecimal());
                items.add(item);
            }

            boolean success = orderService.createOrder(order, items);

            if (success) {
                out.print("{\"success\": true, \"message\": \"Order placed successfully!\"}");
            } else {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\": false, \"message\": \"Failed to place order. Please try again.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"An error occurred while processing the order.\"}");
        } finally {
            out.flush();
        }
    }
}
