package lk.iu.service;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.ejb.AsyncResult;
import jakarta.ejb.Asynchronous;
import jakarta.ejb.Local;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import lk.iu.dao.ProductDAO;
import lk.iu.model.Brand;
import lk.iu.model.Category;
import lk.iu.model.Product;

import java.sql.SQLException;
import java.util.List;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.logging.Level;
import java.util.logging.Logger;


@Stateless
@Local(ProductService.class)
public class ProductServiceImpl implements ProductService {

    private static final Logger LOG = Logger.getLogger(ProductServiceImpl.class.getName());

    private static final long ASYNC_TIMEOUT_SECONDS = 5L;

    @Inject
    private ProductDAO productDAO;

    public ProductServiceImpl() {
    }

    public ProductServiceImpl(ProductDAO productDAO) {
        this.productDAO = productDAO;
    }

    @PostConstruct
    public void onCreate() {
        LOG.info("[ProductService] @PostConstruct — @Stateless bean instance ready in pool. "
                + "CDI-injected productDAO is wired. Container-managed transactions active.");
    }

    @PreDestroy
    public void onDestroy() {
        LOG.fine("[ProductService] @PreDestroy — @Stateless bean instance being removed from pool. "
                + "Container adjusting pool size based on load metrics.");
    }

    @Override
    public List<Product> getAllProducts() throws SQLException {
        LOG.fine("[ProductService] getAllProducts()");
        return productDAO.findAll();
    }

    @Override
    public List<Product> getProductsByCategory(String categoryName) throws SQLException {
        LOG.fine("[ProductService] getProductsByCategory(" + categoryName + ")");
        return productDAO.findByCategory(categoryName);
    }

    @Override
    public List<Product> searchProducts(String keyword) throws SQLException {
        LOG.fine("[ProductService] searchProducts(" + keyword + ")");
        return productDAO.findByKeyword(keyword);
    }

    @Override
    public List<Product> getFilteredProducts(String categoryName, String keyword, String sort)
            throws SQLException {
        LOG.fine("[ProductService] getFilteredProducts(cat=" + categoryName
                + ", kw=" + keyword + ", sort=" + sort + ")");
        return productDAO.findByCriteria(categoryName, keyword, sort);
    }

    @Override
    public Product getProductById(int productId) throws SQLException {
        LOG.fine("[ProductService] getProductById(" + productId + ")");
        return productDAO.findById(productId);
    }

    @Override
    @Asynchronous
    public Future<List<Product>> getAllProductsAsync() {
        LOG.fine("[ProductService] @Asynchronous getAllProductsAsync() — dispatching to container thread pool.");
        try {
            List<Product> products = productDAO.findAll();
            return new AsyncResult<>(products);
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "[ProductService] Async getAllProducts failed", e);
            throw new RuntimeException("Failed to load products asynchronously", e);
        }
    }

    @Override
    @Asynchronous
    public Future<List<Product>> getFilteredProductsAsync(String categoryName,
                                                          String keyword,
                                                          String sort) {
        LOG.fine("[ProductService] @Asynchronous getFilteredProductsAsync() — dispatching to container thread pool.");
        try {
            return new AsyncResult<>(productDAO.findByCriteria(categoryName, keyword, sort));
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "[ProductService] Async getFilteredProducts failed", e);
            throw new RuntimeException("Failed to load filtered products asynchronously", e);
        }
    }


    public List<Product> getAllProductsWithTimeout(long timeoutSeconds) {
        Future<List<Product>> future = getAllProductsAsync();
        try {
            return future.get(timeoutSeconds, TimeUnit.SECONDS);
        } catch (TimeoutException e) {
            future.cancel(true); // interrupt the container thread
            LOG.warning("[ProductService] getAllProducts timed out after " + timeoutSeconds
                    + "s — returning empty list for graceful degradation.");
            return List.of();
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "[ProductService] getAllProductsWithTimeout failed", e);
            return List.of();
        }
    }

    @Override
    public int getTotalProductCount() throws SQLException {
        return productDAO.countAll();
    }

    @Override
    public List<Category> getAllCategories() throws SQLException {
        return productDAO.findAllCategories();
    }

    @Override
    public List<Brand> getAllBrands() throws SQLException {
        return productDAO.findAllBrands();
    }

    @Override
    public int addProduct(Product product) throws SQLException {
        LOG.fine("[ProductService] addProduct(" + product.getProductName() + ")");
        return productDAO.insert(product);
    }

    @Override
    public void updateProduct(Product product) throws SQLException {
        LOG.fine("[ProductService] updateProduct(id=" + product.getProductId() + ")");
        productDAO.update(product);
    }

    @Override
    public void deleteProduct(int productId) throws SQLException {
        LOG.fine("[ProductService] deleteProduct(id=" + productId + ")");
        productDAO.delete(productId);
    }

    @Override
    public void toggleProductVisibility(int productId, boolean visible) throws SQLException {
        LOG.fine("[ProductService] toggleVisibility(id=" + productId + ", visible=" + visible + ")");
        productDAO.toggleVisibility(productId, visible);
    }
}
