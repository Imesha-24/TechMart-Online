package lk.iu.integration;

import lk.iu.dao.CartDAO;
import lk.iu.dao.CartDAOImpl;
import lk.iu.model.CartItem;
import lk.iu.model.Product;
import lk.iu.service.CartService;
import lk.iu.service.CartServiceImpl;
import lk.iu.util.DBConnectionUtil;
import org.jboss.arquillian.container.test.api.Deployment;
import org.jboss.arquillian.junit5.ArquillianExtension;
import org.jboss.shrinkwrap.api.ShrinkWrap;
import org.jboss.shrinkwrap.api.asset.EmptyAsset;
import org.jboss.shrinkwrap.api.spec.WebArchive;
import org.jboss.shrinkwrap.resolver.api.maven.Maven;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import java.io.File;
import java.sql.SQLException;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(ArquillianExtension.class)
public class CartIntegrationTest {

    @Deployment
    public static WebArchive createDeployment() {
        File[] files = Maven.resolver()
                .resolve("org.postgresql:postgresql:42.7.11")
                .withoutTransitivity()
                .asFile();

        return ShrinkWrap.create(WebArchive.class, "techmart-integration-test.war")
                .addPackage("lk.iu.model")
                .addClasses(
                        CartDAO.class,
                        CartDAOImpl.class,
                        CartService.class,
                        CartServiceImpl.class,
                        DBConnectionUtil.class
                )
                .addAsLibraries(files)
                .addAsWebInfResource(EmptyAsset.INSTANCE, "beans.xml");
    }

    @Test
    public void testCartOperations() throws SQLException {
        System.out.println("--- Starting Arquillian Cart Integration Test (User ID 7) ---");
        CartDAO dao = new CartDAOImpl();
        CartService service = new CartServiceImpl(dao);

        int testUserId = 7;
        int testProductId = 1; // Dell XPS 15 from seeds

        // 1. Clear cart first to start fresh
        service.clearUserCart(testUserId);
        assertEquals(0, service.getCartItemCount(testUserId));

        // 2. Add product
        service.addProductToCart(testUserId, testProductId, 3);
        assertEquals(3, service.getCartItemCount(testUserId));

        // 3. Verify item in list
        List<CartItem> items = service.getCartItemsForUser(testUserId);
        assertNotNull(items);
        assertFalse(items.isEmpty(), "Cart should not be empty after adding an item");
        
        CartItem item = items.stream()
                .filter(i -> i.getProductId() == testProductId)
                .findFirst()
                .orElse(null);
                
        assertNotNull(item, "Added item should be in the cart");
        assertEquals(3, item.getQuantity());
        assertNotNull(item.getProduct(), "Product details should be populated by the DAO");
        assertEquals("Dell XPS 15", item.getProduct().getProductName());

        // 4. Update quantity
        service.updateProductQuantity(testUserId, testProductId, 5);
        assertEquals(5, service.getCartItemCount(testUserId));

        // 5. Remove item
        service.removeProductFromCart(testUserId, testProductId);
        assertEquals(0, service.getCartItemCount(testUserId));
        
        System.out.println("--- Arquillian Cart Integration Test Completed Successfully ---");
    }
}
