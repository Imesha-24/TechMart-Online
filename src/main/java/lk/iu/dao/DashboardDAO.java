package lk.iu.dao;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;


public interface DashboardDAO {


    int getTotalProducts() throws SQLException;

    int getProductsThisMonth() throws SQLException;

    int getTotalOrders() throws SQLException;

    int getOrdersThisMonth() throws SQLException;

    BigDecimal getTotalRevenue() throws SQLException;

    BigDecimal getRevenueThisMonth() throws SQLException;

    int getTotalUsers() throws SQLException;

    int getUsersThisMonth() throws SQLException;

    Map<Integer, BigDecimal> getMonthlyRevenue(int year) throws SQLException;

    List<Map<String, Object>> getMonthlySalesLast6Months() throws SQLException;

    Map<String, Integer> getInventoryStatus() throws SQLException;

    List<Map<String, Object>> getRecentOrders(int limit) throws SQLException;
}
