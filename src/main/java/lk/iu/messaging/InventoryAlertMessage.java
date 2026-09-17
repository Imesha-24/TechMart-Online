package lk.iu.messaging;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * InventoryAlertMessage — Serializable JMS payload for low-stock and out-of-stock alerts.
 *
 * <h2>Pub/Sub Messaging Design</h2>
 * <p>This message is published to the {@code InventoryAlertTopic} (a JMS Topic) by the
 * {@code JmsProducerService}. Multiple durable subscribers can independently receive
 * and process each alert:
 * <ul>
 *   <li><b>InventoryAlertMDB</b>: Logs the alert and triggers a restock workflow.</li>
 *   <li><b>Admin notification system</b>: Could notify administrators via email/SMS.</li>
 *   <li><b>Reporting service</b>: Could record inventory events for audit trails.</li>
 * </ul>
 *
 * <h3>Point-to-Point vs. Publish/Subscribe Selection Rationale</h3>
 * <p>Inventory alerts use Pub/Sub (Topic) rather than Point-to-Point (Queue) because:
 * <ul>
 *   <li>Multiple independent systems need to react to the same alert simultaneously.</li>
 *   <li>The alert producer does not need to know which or how many consumers exist.</li>
 *   <li>If no subscriber is active, non-durable subscriptions simply miss the message
 *       (acceptable for alerts; critical events should use durable subscriptions).</li>
 * </ul>
 */
public class InventoryAlertMessage implements Serializable {

    private static final long serialVersionUID = 1L;

    public enum AlertSeverity {
        LOW_STOCK,    // stock <= lowStockThreshold but > 0
        OUT_OF_STOCK  // stock == 0
    }

    private int productId;
    private String productName;
    private int currentStock;
    private int lowStockThreshold;
    private AlertSeverity severity;
    private LocalDateTime alertTime;

    public InventoryAlertMessage() {
        this.alertTime = LocalDateTime.now();
    }

    public InventoryAlertMessage(int productId, String productName,
                                 int currentStock, int lowStockThreshold,
                                 AlertSeverity severity) {
        this.productId = productId;
        this.productName = productName;
        this.currentStock = currentStock;
        this.lowStockThreshold = lowStockThreshold;
        this.severity = severity;
        this.alertTime = LocalDateTime.now();
    }

    public int getProductId()                   { return productId; }
    public void setProductId(int v)             { this.productId = v; }

    public String getProductName()              { return productName; }
    public void setProductName(String v)        { this.productName = v; }

    public int getCurrentStock()                { return currentStock; }
    public void setCurrentStock(int v)          { this.currentStock = v; }

    public int getLowStockThreshold()           { return lowStockThreshold; }
    public void setLowStockThreshold(int v)     { this.lowStockThreshold = v; }

    public AlertSeverity getSeverity()          { return severity; }
    public void setSeverity(AlertSeverity v)    { this.severity = v; }

    public LocalDateTime getAlertTime()         { return alertTime; }
    public void setAlertTime(LocalDateTime v)   { this.alertTime = v; }

    @Override
    public String toString() {
        return "InventoryAlertMessage{productId=" + productId
                + ", productName='" + productName + "'"
                + ", stock=" + currentStock + "/" + lowStockThreshold
                + ", severity=" + severity + ", time=" + alertTime + "}";
    }
}
