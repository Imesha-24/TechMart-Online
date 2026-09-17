package lk.iu.service;

import jakarta.ejb.Local;
import lk.iu.model.InventoryLog;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@Local
public interface InventoryService {

    Map<String, Integer> getInventoryStats() throws SQLException;

    void restockProduct(int productId, int addedStock, String adminUsername) throws SQLException;

    List<InventoryLog> getInventoryHistory(int productId) throws SQLException;
}
