package lk.iu.model;

import java.sql.Timestamp;

public class InventoryLog {
    private int logId;
    private int productId;
    private int previousStock;
    private int newStock;
    private String updatedBy;
    private Timestamp updatedAt;

    public InventoryLog() {}

    public int getLogId() { return logId; }
    public void setLogId(int logId) { this.logId = logId; }
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public int getPreviousStock() { return previousStock; }
    public void setPreviousStock(int previousStock) { this.previousStock = previousStock; }
    public int getNewStock() { return newStock; }
    public void setNewStock(int newStock) { this.newStock = newStock; }
    public String getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(String updatedBy) { this.updatedBy = updatedBy; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
