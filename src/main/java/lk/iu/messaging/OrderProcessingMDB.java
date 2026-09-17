package lk.iu.messaging;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.annotation.Resource;
import jakarta.ejb.ActivationConfigProperty;
import jakarta.ejb.EJB;
import jakarta.ejb.MessageDriven;
import jakarta.ejb.MessageDrivenContext;
import jakarta.jms.JMSException;
import jakarta.jms.Message;
import jakarta.jms.MessageListener;
import jakarta.jms.ObjectMessage;
import lk.iu.model.Notification;
import lk.iu.service.NotificationService;

import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * OrderProcessingMDB — Message-Driven Bean for Point-to-Point Order Event Processing
 *
 * <h2>MDB Component Lifecycle — Critical Analysis</h2>
 * <p>Message-Driven Beans (MDBs) are a specialized form of Stateless Session Bean that
 * respond to JMS messages rather than direct method calls. Their lifecycle is:
 *
 * <ol>
 *   <li><b>Pool instantiation</b>: The container creates a pool of MDB instances at deploy
 *       time (controlled by {@code minSession}/{@code maxSession} activation properties).
 *       Pool size determines message throughput — more instances = more concurrent processing.</li>
 *   <li><b>{@code @PostConstruct}</b>: Called once per instance after CDI/EJB injection.
 *       Used to initialize stateless resources (logging, metrics counters).</li>
 *   <li><b>{@code onMessage(Message)}</b>: The container calls this method for each message
 *       dequeued from the {@code OrderQueue}. The container manages the JMS session,
 *       transaction, and message acknowledgement — the MDB never calls {@code acknowledge()}
 *       manually.</li>
 *   <li><b>{@code @PreDestroy}</b>: Called before the instance is removed from the pool
 *       (undeploy or pool shrinkage). Resources are released here.</li>
 * </ol>
 *
 * <h2>MDB Properties Impact on System Performance</h2>
 * <ul>
 *   <li><b>maxSession</b>: Controls maximum concurrent MDB instances. Higher values increase
 *       throughput but consume more DB connections and memory.</li>
 *   <li><b>acknowledgeMode</b>: Auto-acknowledge means the container ACKs the message after
 *       {@code onMessage()} returns normally. If an exception is thrown, the container
 *       rolls back and the message is redelivered (up to {@code maxRedeliveries} times).</li>
 *   <li><b>subscriptionDurability</b>: N/A for queues (P2P guarantees delivery by design).</li>
 *   <li><b>Transaction</b>: Container-managed transaction wraps {@code onMessage()}.
 *       An unchecked exception causes rollback and message redelivery.</li>
 * </ul>
 *
 * <h2>Limitations in High-Throughput Contexts</h2>
 * <ul>
 *   <li><b>Serial DB writes</b>: Each message triggers a notification DB write via
 *       {@code NotificationService}. Under very high order volume, the DB becomes the
 *       bottleneck. Mitigation: batch inserts or async notification pipeline.</li>
 *   <li><b>Redelivery storms</b>: If the DB is down, failed messages are redelivered
 *       repeatedly. Mitigation: configure a Dead Letter Queue (DLQ) and set a low
 *       {@code maxRedeliveries} value in the Payara activation config.</li>
 *   <li><b>Message ordering</b>: P2P queues with {@code maxSession > 1} do not guarantee
 *       message ordering. If order events must be processed sequentially (e.g., PLACED then
 *       SHIPPED for the same order), use {@code maxSession=1} or add sequence numbers.</li>
 * </ul>
 *
 * <h2>Object-Oriented Principles Applied</h2>
 * <ul>
 *   <li><b>Single Responsibility</b>: This MDB is responsible ONLY for consuming order events
 *       and delegating to {@code NotificationService}. It does not contain business logic.</li>
 *   <li><b>Dependency Inversion</b>: Depends on {@code NotificationService} interface, not
 *       the concrete implementation, enabling substitution in tests.</li>
 *   <li><b>Open/Closed</b>: New event types can be handled by adding cases to the switch
 *       statement without modifying the consume pipeline.</li>
 * </ul>
 */
@MessageDriven(
        name = "OrderProcessingMDB",
        activationConfig = {
                @ActivationConfigProperty(
                        propertyName  = "destinationType",
                        propertyValue = "jakarta.jms.Queue"),
                @ActivationConfigProperty(
                        propertyName  = "destinationLookup",
                        propertyValue = "java:app/jms/OrderQueue"),
                @ActivationConfigProperty(
                        propertyName  = "acknowledgeMode",
                        propertyValue = "Auto-acknowledge"),
                @ActivationConfigProperty(
                        propertyName  = "maxSession",
                        propertyValue = "5")
        }
)
public class OrderProcessingMDB implements MessageListener {

    private static final Logger LOG = Logger.getLogger(OrderProcessingMDB.class.getName());

    /** Container-injected message-driven context for transaction control. */
    @Resource
    private MessageDrivenContext mdContext;

    /** Notification service injected via EJB — used to confirm order processing. */
    @EJB
    private NotificationService notificationService;

    /** Per-instance message counter — useful for pool utilization monitoring. */
    private final AtomicInteger messagesProcessed = new AtomicInteger(0);

    /** Timestamp when this MDB instance was created — for lifecycle analysis. */
    private long instanceCreatedAt;

    /**
     * @PostConstruct — invoked once by the container after all resources are injected.
     * <p>Performance consideration: keep this method fast. The container will not deliver
     * messages to this instance until @PostConstruct returns.
     */
    @PostConstruct
    public void onCreate() {
        this.instanceCreatedAt = System.currentTimeMillis();
        LOG.info("[OrderProcessingMDB] @PostConstruct — MDB instance ready in pool. "
                + "Container will deliver messages from OrderQueue (P2P) to this instance. "
                + "Transaction mode: Container-Managed (CMT). "
                + "ACK mode: Auto-acknowledge (container ACKs after onMessage() returns normally).");
    }

    /**
     * @PreDestroy — invoked before the container removes this instance from the pool.
     * Reports per-instance metrics to help tune {@code maxSession} pool sizing.
     */
    @PreDestroy
    public void onDestroy() {
        long lifetimeMs = System.currentTimeMillis() - instanceCreatedAt;
        LOG.info("[OrderProcessingMDB] @PreDestroy — MDB instance retiring. "
                + "Processed " + messagesProcessed.get() + " order events "
                + "over " + lifetimeMs + "ms of lifetime. "
                + "Pool shrinkage or undeploy triggered this destruction.");
    }

    /**
     * Processes an incoming JMS message from the {@code OrderQueue}.
     *
     * <p><b>Lifecycle contract with the container</b>:
     * <ul>
     *   <li>The container provides the {@link Message} object from the queue.</li>
     *   <li>If this method returns normally, the container commits the JMS transaction
     *       and ACKs the message (removed from queue).</li>
     *   <li>If this method throws an unchecked exception (or calls
     *       {@code mdContext.setRollbackOnly()}), the container rolls back and the message
     *       is redelivered to another pool instance.</li>
     * </ul>
     *
     * <p><b>Error handling</b>: JMSException during message parsing causes rollback
     * (message redelivery). Business processing failures (notification errors) are caught
     * and logged without rolling back — to avoid infinite redelivery loops.
     *
     * @param message the JMS message received from OrderQueue
     */
    @Override
    public void onMessage(Message message) {
        int count = messagesProcessed.incrementAndGet();
        LOG.info("[OrderProcessingMDB] Received order event #" + count
                + " (msgId=" + safeGetMessageId(message) + ")");

        if (!(message instanceof ObjectMessage)) {
            LOG.warning("[OrderProcessingMDB] Unexpected message type: "
                    + message.getClass().getSimpleName() + ". Expected ObjectMessage. Ignoring.");
            return;
        }

        OrderEventMessage event;
        try {
            event = (OrderEventMessage) ((ObjectMessage) message).getObject();
        } catch (JMSException e) {
            LOG.log(Level.SEVERE, "[OrderProcessingMDB] Failed to deserialize OrderEventMessage. "
                    + "Rolling back — message will be redelivered.", e);
            mdContext.setRollbackOnly();
            return;
        }

        LOG.info("[OrderProcessingMDB] Processing order event: " + event);
        processOrderEvent(event);
    }

    /**
     * Business logic for order event processing.
     * Separated from {@code onMessage()} for clarity and testability (OOP — SRP).
     */
    private void processOrderEvent(OrderEventMessage event) {
        switch (event.getEventType()) {
            case "ORDER_PLACED" -> handleOrderPlaced(event);
            case "ORDER_CANCELLED" -> handleOrderCancelled(event);
            case "ORDER_SHIPPED" -> handleOrderShipped(event);
            default -> LOG.warning("[OrderProcessingMDB] Unknown event type: "
                    + event.getEventType() + " for orderId=" + event.getOrderId());
        }
    }

    private void handleOrderPlaced(OrderEventMessage event) {
        LOG.info("[OrderProcessingMDB] Handling ORDER_PLACED for orderId=" + event.getOrderId()
                + ", userId=" + event.getUserId());
        try {
            Notification notification = new Notification();
            notification.setUserId(event.getUserId());
            notification.setTitle("Order Confirmed!");
            notification.setMessage("Your order #" + event.getOrderId()
                    + " has been placed successfully. Total: $"
                    + String.format("%.2f", event.getTotalAmount()));
            notification.setNotificationType("ORDER");
            notificationService.addNotification(notification);
            LOG.info("[OrderProcessingMDB] Order confirmation notification sent for order #"
                    + event.getOrderId());
        } catch (Exception e) {
            // Catch but don't rethrow — avoid MDB rollback loop from notification failures.
            LOG.log(Level.WARNING, "[OrderProcessingMDB] Notification failed for ORDER_PLACED orderId="
                    + event.getOrderId() + " — event consumed, notification lost.", e);
        }
    }

    private void handleOrderCancelled(OrderEventMessage event) {
        LOG.info("[OrderProcessingMDB] Handling ORDER_CANCELLED for orderId=" + event.getOrderId());
        try {
            Notification notification = new Notification();
            notification.setUserId(event.getUserId());
            notification.setTitle("Order Cancelled");
            notification.setMessage("Your order #" + event.getOrderId() + " has been cancelled.");
            notification.setNotificationType("ORDER");
            notificationService.addNotification(notification);
        } catch (Exception e) {
            LOG.log(Level.WARNING, "[OrderProcessingMDB] Notification failed for ORDER_CANCELLED orderId="
                    + event.getOrderId(), e);
        }
    }

    private void handleOrderShipped(OrderEventMessage event) {
        LOG.info("[OrderProcessingMDB] Handling ORDER_SHIPPED for orderId=" + event.getOrderId());
        try {
            Notification notification = new Notification();
            notification.setUserId(event.getUserId());
            notification.setTitle("Order Shipped!");
            notification.setMessage("Your order #" + event.getOrderId()
                    + " has been shipped and is on its way!");
            notification.setNotificationType("ORDER");
            notificationService.addNotification(notification);
        } catch (Exception e) {
            LOG.log(Level.WARNING, "[OrderProcessingMDB] Notification failed for ORDER_SHIPPED orderId="
                    + event.getOrderId(), e);
        }
    }

    private String safeGetMessageId(Message message) {
        try {
            return message.getJMSMessageID();
        } catch (JMSException e) {
            return "unknown";
        }
    }
}
