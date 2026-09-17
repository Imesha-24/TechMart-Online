package lk.iu.service;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.ejb.Local;
import jakarta.ejb.Remove;
import jakarta.ejb.Stateful;
import jakarta.inject.Inject;
import lk.iu.dao.CartDAO;
import lk.iu.model.CartItem;

import java.io.Serializable;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Logger;

@Stateful
@Local(CartService.class)
public class CartServiceImpl implements CartService, Serializable {

    private static final long serialVersionUID = 1L;
    private static final Logger LOG = Logger.getLogger(CartServiceImpl.class.getName());

    @Inject
    private CartDAO cartDAO;

    public CartServiceImpl() {
    }

    public CartServiceImpl(CartDAO cartDAO) {
        this.cartDAO = cartDAO;
    }

    @PostConstruct
    public void onCreate() {
        LOG.info("[CartService] @PostConstruct — @Stateful session bean created for this client session. "
                + "One dedicated instance allocated from the container's stateful bean store.");
    }

    @jakarta.ejb.PrePassivate
    public void beforePassivate() {
        LOG.fine("[CartService] @PrePassivate — bean being passivated to secondary storage. "
                + "Non-serializable resources would be released here to prevent NotSerializableException. "
                + "CDI proxy cartDAO is serialization-safe; no manual action required.");
    }

    @jakarta.ejb.PostActivate
    public void afterActivate() {
        LOG.fine("[CartService] @PostActivate — bean restored from passivation. "
                + "CDI proxy cartDAO automatically re-wired by container after activation.");
    }

    @PreDestroy
    public void onDestroy() {
        LOG.info("[CartService] @PreDestroy — @Stateful session bean destroyed. "
                + "If @Remove was called explicitly (checkout path), this is resource-efficient. "
                + "If triggered by session timeout, consider reducing passivation timeout for better "
                + "resource utilization under high load.");
    }

    @Remove
    public void checkout() {
        LOG.info("[CartService] @Remove checkout() invoked — stateful bean will be destroyed "
                + "after this method returns, releasing server-side session resources.");
    }

    @Override
    public void addProductToCart(int userId, int productId, int quantity) throws SQLException {
        LOG.fine("[CartService] addProductToCart(user=" + userId + ", product=" + productId + ", qty=" + quantity + ")");
        int cartId = cartDAO.getOrCreateCartId(userId);
        cartDAO.addItem(cartId, productId, quantity);
    }

    @Override
    public void updateProductQuantity(int userId, int productId, int quantity) throws SQLException {
        LOG.fine("[CartService] updateProductQuantity(user=" + userId + ", product=" + productId + ", qty=" + quantity + ")");
        int cartId = cartDAO.getOrCreateCartId(userId);
        if (quantity <= 0) {
            cartDAO.removeItem(cartId, productId);
        } else {
            cartDAO.updateItemQuantity(cartId, productId, Math.min(99, quantity));
        }
    }

    @Override
    public void removeProductFromCart(int userId, int productId) throws SQLException {
        LOG.fine("[CartService] removeProductFromCart(user=" + userId + ", product=" + productId + ")");
        int cartId = cartDAO.getOrCreateCartId(userId);
        cartDAO.removeItem(cartId, productId);
    }

    @Override
    public void clearUserCart(int userId) throws SQLException {
        LOG.fine("[CartService] clearUserCart(user=" + userId + ")");
        int cartId = cartDAO.getOrCreateCartId(userId);
        cartDAO.clearCart(cartId);
    }

    @Override
    public List<CartItem> getCartItemsForUser(int userId) throws SQLException {
        LOG.fine("[CartService] getCartItemsForUser(user=" + userId + ")");
        int cartId = cartDAO.getOrCreateCartId(userId);
        return cartDAO.getCartItems(cartId);
    }

    @Override
    public int getCartItemCount(int userId) throws SQLException {
        LOG.fine("[CartService] getCartItemCount(user=" + userId + ")");
        int cartId = cartDAO.getOrCreateCartId(userId);
        return cartDAO.getCartCount(cartId);
    }
}
