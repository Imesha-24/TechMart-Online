package lk.iu.service;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.ejb.Local;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import lk.iu.dao.InventoryDAO;
import lk.iu.dao.ProductDAO;
import lk.iu.model.InventoryLog;
import lk.iu.model.Product;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

@Stateless
@Local(InventoryService.class)
public class InventoryServiceImpl implements InventoryService {

    private static final Logger LOG = Logger.getLogger(InventoryServiceImpl.class.getName());

    @Inject
    private InventoryDAO inventoryDAO;

    @Inject
    private ProductDAO productDAO;

    public InventoryServiceImpl() {
    }

    public InventoryServiceImpl(InventoryDAO inventoryDAO, ProductDAO productDAO) {
        this.inventoryDAO = inventoryDAO;
        this.productDAO = productDAO;
    }

    @PostConstruct
    public void onCreate() {
        LOG.info("[InventoryService] @PostConstruct — @Stateless bean ready. "
                + "Dual-DAO injection: inventoryDAO and productDAO wired. "
                + "Container-managed transactions will wrap restock operations atomically.");
    }

    @PreDestroy
    public void onDestroy() {
        LOG.fine("[InventoryService] @PreDestroy — @Stateless bean instance retiring from pool.");
    }

    @Override
    public Map<String, Integer> getInventoryStats() throws SQLException {
        return inventoryDAO.getInventoryStats();
    }

    @Override
    public void restockProduct(int productId, int addedStock, String adminUsername) throws SQLException {
        LOG.fine("[InventoryService] restockProduct(id=" + productId + ", add=" + addedStock + ")");

        Product product = productDAO.findById(productId);
        if (product == null) {
            throw new IllegalArgumentException("Product not found with ID: " + productId);
        }
        int previousStock = product.getStockQuantity();

        int newStock = inventoryDAO.updateStock(productId, addedStock);

        if (newStock != -1) {
            InventoryLog log = new InventoryLog();
            log.setProductId(productId);
            log.setPreviousStock(previousStock);
            log.setNewStock(newStock);
            log.setUpdatedBy(adminUsername);
            inventoryDAO.addInventoryLog(log);
            LOG.info("[InventoryService] Restock logged: product=" + productId
                    + ", prev=" + previousStock + ", new=" + newStock + ", by=" + adminUsername);
        }
    }

    @Override
    public List<InventoryLog> getInventoryHistory(int productId) throws SQLException {
        return inventoryDAO.getInventoryHistory(productId);
    }
}
