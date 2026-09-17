package lk.iu.dao;

import lk.iu.model.InventoryLog;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public interface InventoryDAO {
    

    Map<String, Integer> getInventoryStats() throws SQLException;

    int updateStock(int productId, int addedStock) throws SQLException;

    void addInventoryLog(InventoryLog log) throws SQLException;

    List<InventoryLog> getInventoryHistory(int productId) throws SQLException;
}
