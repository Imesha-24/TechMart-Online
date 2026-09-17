package lk.iu.service;

import jakarta.ejb.Local;
import lk.iu.model.CartItem;

import java.sql.SQLException;
import java.util.List;


@Local
public interface CartService {

    void addProductToCart(int userId, int productId, int quantity) throws SQLException;

    void updateProductQuantity(int userId, int productId, int quantity) throws SQLException;

    void removeProductFromCart(int userId, int productId) throws SQLException;

    void clearUserCart(int userId) throws SQLException;

    List<CartItem> getCartItemsForUser(int userId) throws SQLException;

    int getCartItemCount(int userId) throws SQLException;


    void checkout();
}
