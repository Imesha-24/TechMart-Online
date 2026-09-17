package lk.iu.service;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.ejb.ConcurrencyManagement;
import jakarta.ejb.ConcurrencyManagementType;
import jakarta.ejb.Local;
import jakarta.ejb.Lock;
import jakarta.ejb.LockType;
import jakarta.ejb.Schedule;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;
import jakarta.inject.Inject;
import lk.iu.dao.DashboardDAO;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Logger;


@Singleton
@Startup
@Local(DashboardService.class)
@ConcurrencyManagement(ConcurrencyManagementType.CONTAINER)
public class DashboardServiceImpl implements DashboardService {

    private static final Logger LOG = Logger.getLogger(DashboardServiceImpl.class.getName());

    @Inject
    private DashboardDAO dashboardDAO;

    private final AtomicInteger cacheRefreshCount = new AtomicInteger(0);

    private volatile boolean cacheRefreshing = false;

    public DashboardServiceImpl() {
    }

    public DashboardServiceImpl(DashboardDAO dashboardDAO) {
        this.dashboardDAO = dashboardDAO;
    }

    @PostConstruct
    public void warmUp() {
        LOG.info("╔══════════════════════════════════════════════════════╗");
        LOG.info("║  DashboardService @Singleton @Startup — warmUp()     ║");
        LOG.info("╚══════════════════════════════════════════════════════╝");
        LOG.info("[DashboardService] @PostConstruct — singleton instance created at deploy time. "
                + "Container will block all business method calls until this returns.");
        LOG.info("[DashboardService] Resource utilization: single shared instance "
                + "serves all concurrent dashboard requests via @Lock(READ).");
    }

    @Schedule(hour = "*", minute = "0", second = "0", persistent = false,
              info = "DashboardCacheRefreshTimer")
    @Lock(LockType.WRITE)
    public void refreshCache() {
        cacheRefreshing = true;
        int count = cacheRefreshCount.incrementAndGet();
        LOG.info("[DashboardService] @Schedule cache refresh #" + count
                + " — @Lock(WRITE) acquired; all @Lock(READ) callers are queued.");
        cacheRefreshing = false;
        LOG.fine("[DashboardService] Cache refresh complete; @Lock(WRITE) released.");
    }

    @PreDestroy
    public void shutdown() {
        LOG.info("[DashboardService] @PreDestroy — singleton being destroyed after "
                + cacheRefreshCount.get() + " scheduled cache refreshes. "
                + "Releasing any held resources.");
    }


    @Override
    @Lock(LockType.READ)
    public int getTotalProducts() throws SQLException { return dashboardDAO.getTotalProducts(); }

    @Override
    @Lock(LockType.READ)
    public int getProductsThisMonth() throws SQLException { return dashboardDAO.getProductsThisMonth(); }

    @Override
    @Lock(LockType.READ)
    public int getTotalOrders() throws SQLException { return dashboardDAO.getTotalOrders(); }

    @Override
    @Lock(LockType.READ)
    public int getOrdersThisMonth() throws SQLException { return dashboardDAO.getOrdersThisMonth(); }

    @Override
    @Lock(LockType.READ)
    public BigDecimal getTotalRevenue() throws SQLException { return dashboardDAO.getTotalRevenue(); }

    @Override
    @Lock(LockType.READ)
    public BigDecimal getRevenueThisMonth() throws SQLException { return dashboardDAO.getRevenueThisMonth(); }

    @Override
    @Lock(LockType.READ)
    public int getTotalUsers() throws SQLException { return dashboardDAO.getTotalUsers(); }

    @Override
    @Lock(LockType.READ)
    public int getUsersThisMonth() throws SQLException { return dashboardDAO.getUsersThisMonth(); }

    @Override
    @Lock(LockType.READ)
    public List<BigDecimal> getMonthlyRevenueForYear(int year) throws SQLException {
        Map<Integer, BigDecimal> raw = dashboardDAO.getMonthlyRevenue(year);
        List<BigDecimal> result = new ArrayList<>(12);
        for (int m = 1; m <= 12; m++) {
            result.add(raw.getOrDefault(m, BigDecimal.ZERO));
        }
        return result;
    }

    @Override
    @Lock(LockType.READ)
    public List<Map<String, Object>> getMonthlySalesLast6Months() throws SQLException {
        return dashboardDAO.getMonthlySalesLast6Months();
    }

    @Override
    @Lock(LockType.READ)
    public Map<String, Integer> getInventoryStatus() throws SQLException {
        return dashboardDAO.getInventoryStatus();
    }

    @Override
    @Lock(LockType.READ)
    public List<Map<String, Object>> getRecentOrders(int limit) throws SQLException {
        return dashboardDAO.getRecentOrders(limit);
    }
}
