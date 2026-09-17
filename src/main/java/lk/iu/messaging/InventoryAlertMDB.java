package lk.iu.messaging;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.annotation.Resource;
import jakarta.ejb.ActivationConfigProperty;
import jakarta.ejb.MessageDriven;
import jakarta.ejb.MessageDrivenContext;
import jakarta.jms.JMSException;
import jakarta.jms.Message;
import jakarta.jms.MessageListener;
import jakarta.jms.ObjectMessage;

import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * InventoryAlertMDB — Message-Driven Bean for Publish-Subscribe Inventory Alert Processing
 *
 * <h2>MDB Lifecycle Efficiency — Critical Analysis</h2>
 * <p>Unlike {@code @Stateless} or {@code @Stateful} session beans, MDB instances are
 * <em>never</em> directly invoked by client code. The container is the sole caller of
 * {@code onMessage()}. This creates unique lifecycle efficiency considerations:
 *
 * <ul>
 *   <li><b>Pool sizing</b>: MDB pool instances ({@code maxSession}) must be tuned to match
 *       the expected message arrival rate. Under-provisioning causes message backlog;
 *       over-provisioning wastes DB connections and memory.</li>
 *   <li><b>Idle instances</b>: If inventory alerts are infrequent, pool instances sit idle
 *       between messages. The container may passivate them (though MDBs are not formally
 *       passivatable like @Stateful beans — they are simply pooled).</li>
 *   <li><b>Startup cost</b>: @PostConstruct runs when instances are added to the pool —
 *       this is NOT per-message. This means initialization cost is amortized across
 *       many messages, not paid on every invocation.</li>
 * </ul>
 *
 * <h2>Topic Subscription vs. Queue — Lifecycle Implications</h2>
 * <p>This MDB subscribes to a {@code Topic} (Pub/Sub), which has different lifecycle
 * semantics from a Queue (P2P) subscriber:
 * <ul>
 *   <li>If this MDB is offline (undeployed) and no durable subscription is configured,
 *       messages published during the downtime are LOST (non-durable default).</li>
 *   <li>With {@code subscriptionDurability=Durable}, the broker retains messages for this
 *       subscriber's {@code clientId} even when the MDB is offline, ensuring no alerts
 *       are missed. This is enabled by the activation config property below.</li>
 * </ul>
 *
 * <h2>Performance Metrics Integration</h2>
 * <p>This MDB tracks per-instance processing statistics (message count, total processing
 * time, average latency) which are logged at @PreDestroy. These metrics enable capacity
 * planning for {@code maxSession} tuning.
 *
 * <h2>Deployment Scenario: Lifecycle Management Optimization</h2>
 * <table border="1">
 *   <tr><th>Scenario</th><th>Recommended maxSession</th><th>Rationale</th></tr>
 *   <tr><td>Low volume (< 10 alerts/min)</td><td>1–2</td><td>Minimize idle resource use</td></tr>
 *   <tr><td>Medium volume (10–100/min)</td><td>3–5</td><td>Balance concurrency vs. DB load</td></tr>
 *   <tr><td>High volume (> 100/min)</td><td>10+</td><td>Scale DB write capacity first</td></tr>
 * </table>
 */
@MessageDriven(
        name = "InventoryAlertMDB",
        activationConfig = {
                @ActivationConfigProperty(
                        propertyName  = "destinationType",
                        propertyValue = "jakarta.jms.Topic"),
                @ActivationConfigProperty(
                        propertyName  = "destinationLookup",
                        propertyValue = "java:app/jms/InventoryAlertTopic"),
                @ActivationConfigProperty(
                        propertyName  = "acknowledgeMode",
                        propertyValue = "Auto-acknowledge"),
                @ActivationConfigProperty(
                        propertyName  = "subscriptionDurability",
                        propertyValue = "Durable"),
                @ActivationConfigProperty(
                        propertyName  = "clientId",
                        propertyValue = "InventoryAlertMDBClient"),
                @ActivationConfigProperty(
                        propertyName  = "subscriptionName",
                        propertyValue = "TechMartInventoryAlertSubscription")
        }
)
public class InventoryAlertMDB implements MessageListener {

    private static final Logger LOG = Logger.getLogger(InventoryAlertMDB.class.getName());

    @Resource
    private MessageDrivenContext mdContext;

    /** Per-instance performance metrics. */
    private final AtomicInteger alertsProcessed     = new AtomicInteger(0);
    private final AtomicLong    totalProcessingNanos = new AtomicLong(0);
    private long instanceCreatedAt;

    /**
     * @PostConstruct — pool instance initialization.
     * <p>Runs once per instance creation, not per message. Cost is amortized
     * across all messages handled by this instance.
     */
    @PostConstruct
    public void onCreate() {
        this.instanceCreatedAt = System.currentTimeMillis();
        LOG.info("[InventoryAlertMDB] @PostConstruct — Durable Topic subscriber ready. "
                + "Subscription: TechMartInventoryAlertSubscription. "
                + "Durable mode: messages retained by broker even when this MDB is offline. "
                + "Container will deliver InventoryAlertTopic messages to this pool instance.");
    }

    /**
     * @PreDestroy — pool instance retirement.
     * <p>Logs per-instance performance statistics to support pool sizing decisions.
     * Average processing time per alert informs whether {@code maxSession} should be adjusted.
     */
    @PreDestroy
    public void onDestroy() {
        int total = alertsProcessed.get();
        long totalNanos = totalProcessingNanos.get();
        long avgNs = total > 0 ? totalNanos / total : 0;
        long lifetimeMs = System.currentTimeMillis() - instanceCreatedAt;

        LOG.info("[InventoryAlertMDB] @PreDestroy — MDB instance retiring. "
                + "Performance metrics: alerts processed=" + total
                + ", avg processing time=" + (avgNs / 1_000_000) + "ms"
                + ", total lifetime=" + lifetimeMs + "ms. "
                + "Use these metrics to tune maxSession activation property.");
    }

    /**
     * Processes an incoming inventory alert from the {@code InventoryAlertTopic}.
     *
     * <p><b>Pub/Sub contract</b>: This method is called for EACH message published to the topic,
     * even if another MDB instance already processed it. Each subscriber gets an independent copy.
     *
     * <p><b>Durable subscription behaviour</b>: Because {@code subscriptionDurability=Durable},
     * if this MDB is temporarily undeployed and a message is published during that period,
     * the broker retains the message and delivers it on reconnection.
     *
     * @param message the JMS message received from InventoryAlertTopic
     */
    @Override
    public void onMessage(Message message) {
        long startNanos = System.nanoTime();
        int count = alertsProcessed.incrementAndGet();

        LOG.info("[InventoryAlertMDB] Received inventory alert #" + count
                + " (msgId=" + safeGetMessageId(message) + ")");

        if (!(message instanceof ObjectMessage)) {
            LOG.warning("[InventoryAlertMDB] Unexpected message type: "
                    + message.getClass().getSimpleName() + ". Expected ObjectMessage. Skipping.");
            return;
        }

        InventoryAlertMessage alert;
        try {
            alert = (InventoryAlertMessage) ((ObjectMessage) message).getObject();
        } catch (JMSException e) {
            LOG.log(Level.SEVERE, "[InventoryAlertMDB] Failed to deserialize InventoryAlertMessage. "
                    + "Rolling back — message will be redelivered.", e);
            mdContext.setRollbackOnly();
            return;
        }

        LOG.info("[InventoryAlertMDB] Processing inventory alert: " + alert);
        processInventoryAlert(alert);

        long elapsedNanos = System.nanoTime() - startNanos;
        totalProcessingNanos.addAndGet(elapsedNanos);
        LOG.fine("[InventoryAlertMDB] Alert #" + count + " processed in "
                + (elapsedNanos / 1_000_000) + "ms.");
    }

    /**
     * Business logic for inventory alert processing.
     * Applies OOP Single Responsibility — only concerns itself with alert handling logic.
     */
    private void processInventoryAlert(InventoryAlertMessage alert) {
        switch (alert.getSeverity()) {
            case OUT_OF_STOCK -> {
                LOG.warning("[InventoryAlertMDB] OUT_OF_STOCK alert: product='"
                        + alert.getProductName() + "' (id=" + alert.getProductId() + ") "
                        + "has 0 units remaining. Immediate restock action required.");
                triggerRestockWorkflow(alert);
            }
            case LOW_STOCK -> {
                LOG.warning("[InventoryAlertMDB] LOW_STOCK alert: product='"
                        + alert.getProductName() + "' (id=" + alert.getProductId() + ") "
                        + "has only " + alert.getCurrentStock() + " units "
                        + "(threshold: " + alert.getLowStockThreshold() + "). "
                        + "Consider restocking soon.");
                logLowStockForReview(alert);
            }
            default ->
                LOG.info("[InventoryAlertMDB] Received alert with unknown severity: "
                        + alert.getSeverity() + " for product=" + alert.getProductName());
        }
    }

    /**
     * Simulates triggering a restock workflow for out-of-stock products.
     * In a full implementation this would: create a purchase order, notify procurement,
     * or integrate with an ERP system via outbound JMS or REST.
     */
    private void triggerRestockWorkflow(InventoryAlertMessage alert) {
        LOG.info("[InventoryAlertMDB] Restock workflow triggered for product="
                + alert.getProductName() + " (id=" + alert.getProductId() + "). "
                + "Action: procurement team notified. "
                + "[Extension point: integrate with ERP via outbound JMS or REST API]");
    }

    /**
     * Logs low-stock products for review by the inventory management team.
     */
    private void logLowStockForReview(InventoryAlertMessage alert) {
        LOG.info("[InventoryAlertMDB] Low-stock review entry: product="
                + alert.getProductName() + ", current=" + alert.getCurrentStock()
                + ", threshold=" + alert.getLowStockThreshold()
                + ", alertTime=" + alert.getAlertTime()
                + ". [Extension point: persist to audit log table]");
    }

    private String safeGetMessageId(Message message) {
        try {
            return message.getJMSMessageID();
        } catch (JMSException e) {
            return "unknown";
        }
    }
}
