package lk.iu.performance;

import com.github.noconnor.junitperf.JUnitPerfInterceptor;
import com.github.noconnor.junitperf.JUnitPerfTest;
import com.github.noconnor.junitperf.JUnitPerfTestRequirement;
import lk.iu.dao.ProductDAO;
import lk.iu.dao.ProductDAOImpl;
import lk.iu.model.Product;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import java.sql.SQLException;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * ServicePerformanceTest - Database lookup load and latency test suite
 * Uses JUnitPerf to simulate parallel threads making concurrent queries.
 * Establishes performance requirements: 95th percentile latency must be low.
 */
@ExtendWith(JUnitPerfInterceptor.class)
public class ServicePerformanceTest {

    private final ProductDAO productDAO = new ProductDAOImpl();

    @Test
    @JUnitPerfTest(threads = 5, durationMs = 2000, warmUpMs = 500)
    @JUnitPerfTestRequirement(percentiles = "95:250", allowedErrorPercentage = 0.05f)
    public void testFindAllProductsPerformance() throws SQLException {
        List<Product> products = productDAO.findAll();
        assertNotNull(products);
        assertFalse(products.isEmpty(), "Database should contain seeded products");
    }

    @Test
    @JUnitPerfTest(threads = 8, durationMs = 2000, warmUpMs = 500)
    @JUnitPerfTestRequirement(percentiles = "95:150", allowedErrorPercentage = 0.05f)
    public void testFindProductByIdPerformance() throws SQLException {
        Product p = productDAO.findById(1); // Seeded Dell XPS 15
        assertNotNull(p);
        assertEquals(1, p.getProductId());
        assertEquals("Dell XPS 15", p.getProductName());
    }
}
