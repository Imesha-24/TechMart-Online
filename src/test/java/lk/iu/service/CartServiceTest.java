package lk.iu.service;

import lk.iu.dao.CartDAO;
import lk.iu.model.CartItem;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class CartServiceTest {

    @Mock
    private CartDAO cartDAO;

    private CartService cartService;

    @BeforeEach
    public void setUp() {
        cartService = new CartServiceImpl(cartDAO);
    }

    @Test
    public void testAddProductToCart() throws SQLException {
        int userId = 1;
        int productId = 10;
        int quantity = 2;
        int cartId = 100;

        when(cartDAO.getOrCreateCartId(userId)).thenReturn(cartId);

        cartService.addProductToCart(userId, productId, quantity);

        verify(cartDAO).getOrCreateCartId(userId);
        verify(cartDAO).addItem(cartId, productId, quantity);
    }

    @Test
    public void testUpdateProductQuantity_Positive() throws SQLException {
        int userId = 1;
        int productId = 10;
        int quantity = 5;
        int cartId = 100;

        when(cartDAO.getOrCreateCartId(userId)).thenReturn(cartId);

        cartService.updateProductQuantity(userId, productId, quantity);

        verify(cartDAO).updateItemQuantity(cartId, productId, 5);
    }

    @Test
    public void testUpdateProductQuantity_Capped() throws SQLException {
        int userId = 1;
        int productId = 10;
        int quantity = 150; // exceeds cap of 99
        int cartId = 100;

        when(cartDAO.getOrCreateCartId(userId)).thenReturn(cartId);

        cartService.updateProductQuantity(userId, productId, quantity);

        verify(cartDAO).updateItemQuantity(cartId, productId, 99);
    }

    @Test
    public void testUpdateProductQuantity_ZeroOrNegative() throws SQLException {
        int userId = 1;
        int productId = 10;
        int quantity = 0;
        int cartId = 100;

        when(cartDAO.getOrCreateCartId(userId)).thenReturn(cartId);

        cartService.updateProductQuantity(userId, productId, quantity);

        verify(cartDAO).removeItem(cartId, productId);
        verify(cartDAO, never()).updateItemQuantity(anyInt(), anyInt(), anyInt());
    }

    @Test
    public void testRemoveProductFromCart() throws SQLException {
        int userId = 1;
        int productId = 10;
        int cartId = 100;

        when(cartDAO.getOrCreateCartId(userId)).thenReturn(cartId);

        cartService.removeProductFromCart(userId, productId);

        verify(cartDAO).removeItem(cartId, productId);
    }

    @Test
    public void testClearUserCart() throws SQLException {
        int userId = 1;
        int cartId = 100;

        when(cartDAO.getOrCreateCartId(userId)).thenReturn(cartId);

        cartService.clearUserCart(userId);

        verify(cartDAO).clearCart(cartId);
    }

    @Test
    public void testGetCartItemsForUser() throws SQLException {
        int userId = 1;
        int cartId = 100;
        List<CartItem> expectedItems = new ArrayList<>();

        when(cartDAO.getOrCreateCartId(userId)).thenReturn(cartId);
        when(cartDAO.getCartItems(cartId)).thenReturn(expectedItems);

        List<CartItem> result = cartService.getCartItemsForUser(userId);

        assertSame(expectedItems, result);
        verify(cartDAO).getCartItems(cartId);
    }

    @Test
    public void testGetCartItemCount() throws SQLException {
        int userId = 1;
        int cartId = 100;

        when(cartDAO.getOrCreateCartId(userId)).thenReturn(cartId);
        when(cartDAO.getCartCount(cartId)).thenReturn(4);

        int count = cartService.getCartItemCount(userId);

        assertEquals(4, count);
        verify(cartDAO).getCartCount(cartId);
    }
}
