package lk.iu.service;

import jakarta.ejb.Local;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;


@Local
public interface DashboardService {


    int getTotalProducts() throws SQLException;
    int getProductsThisMonth() throws SQLException;

    int getTotalOrders() throws SQLException;
    int getOrdersThisMonth() throws SQLException;

    BigDecimal getTotalRevenue() throws SQLException;
    BigDecimal getRevenueThisMonth() throws SQLException;

    int getTotalUsers() throws SQLException;
    int getUsersThisMonth() throws SQLException;


    List<BigDecimal> getMonthlyRevenueForYear(int year) throws SQLException;

    List<Map<String, Object>> getMonthlySalesLast6Months() throws SQLException;

    Map<String, Integer> getInventoryStatus() throws SQLException;

    List<Map<String, Object>> getRecentOrders(int limit) throws SQLException;
}
