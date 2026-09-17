package lk.iu.dao;

import lk.iu.model.CartItem;

import java.sql.SQLException;
import java.util.List;


public interface CartDAO {


    int getOrCreateCartId(int userId) throws SQLException;


    void addItem(int cartId, int productId, int quantity) throws SQLException;


    void updateItemQuantity(int cartId, int productId, int quantity) throws SQLException;


    void removeItem(int cartId, int productId) throws SQLException;


    void clearCart(int cartId) throws SQLException;


    List<CartItem> getCartItems(int cartId) throws SQLException;


    int getCartCount(int cartId) throws SQLException;
}
