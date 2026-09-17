package lk.iu.messaging;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.annotation.Resource;
import jakarta.ejb.Local;
import jakarta.ejb.Stateless;
import jakarta.jms.ConnectionFactory;
import jakarta.jms.JMSConnectionFactoryDefinition;
import jakarta.jms.JMSContext;
import jakarta.jms.JMSDestinationDefinition;
import jakarta.jms.JMSDestinationDefinitions;
import jakarta.jms.JMSException;
import jakarta.jms.ObjectMessage;
import jakarta.jms.Queue;
import jakarta.jms.Topic;
import lk.iu.model.Order;
import lk.iu.model.Product;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * JmsProducerService — JMS Messaging Architecture for TechMart Online
 *
 * <h2>JMS Architecture Overview</h2>
 * <p>This {@code @Stateless} session bean encapsulates all JMS message production for
 * the TechMart application. It demonstrates both JMS messaging patterns:
 *
 * <h3>Pattern 1: Point-to-Point (P2P) — Order Queue</h3>
 * <p>Used for order placement events. Characteristics:
 * <ul>
 *   <li><b>One producer → One consumer</b>: Each {@link OrderEventMessage} sent to
 *       {@code OrderQueue} is consumed by exactly one {@code OrderProcessingMDB} instance.</li>
 *   <li><b>Guaranteed delivery</b>: The JMS broker (OpenMQ in Payara) persists the message
 *       until the consumer acknowledges it. If the MDB crashes mid-processing, the message
 *       is redelivered (up to the configured redelivery limit).</li>
 *   <li><b>Load balancing</b>: If multiple {@code OrderProcessingMDB} instances are active
 *       (controlled by {@code maxSession} in {@code @ActivationConfigProperty}), messages
 *       are distributed across instances for parallel processing.</li>
 *   <li><b>Business implication</b>: Ensures every order is processed exactly once, even
 *       under server failure scenarios.</li>
 * </ul>
 *
 * <h3>Pattern 2: Publish-Subscribe (Pub/Sub) — Inventory Alert Topic</h3>
 * <p>Used for low-stock alerts. Characteristics:
 * <ul>
 *   <li><b>One producer → Many consumers</b>: Each {@link InventoryAlertMessage} published
 *       to {@code InventoryAlertTopic} is delivered to ALL active subscribers independently.</li>
 *   <li><b>Durable subscriptions</b>: Subscribers registered as durable receive messages even
 *       if they were offline when the message was published (configurable in Payara).</li>
 *   <li><b>Business implication</b>: Multiple systems (admin panel, email service, analytics)
 *       can all react to the same inventory alert without coupling to each other.</li>
 * </ul>
 *
 * <h2>Scalability Limitations &amp; Optimization Strategies</h2>
 * <ul>
 *   <li><b>Broker bottleneck</b>: OpenMQ (embedded in Payara) is single-node by default.
 *       For high-throughput production, replace with a clustered broker (ActiveMQ Artemis,
 *       IBM MQ, or Amazon SQS via JMS adapter).</li>
 *   <li><b>Connection pooling</b>: JMSContext wraps the connection; using {@code @Inject}
 *       with {@code @JMSConnectionFactory} uses the container-managed JMS connection pool
 *       (preferred over manual ConnectionFactory.createConnection()).</li>
 *   <li><b>Message size</b>: ObjectMessage serialization adds overhead. For large payloads,
 *       use TextMessage with JSON and a message ID for payload retrieval from DB.</li>
 * </ul>
 *
 * <h2>Monitoring &amp; Reliability</h2>
 * <ul>
 *   <li><b>Dead Letter Queue (DLQ)</b>: Configure Payara to move undeliverable messages
 *       to a DLQ after N redelivery attempts. Monitor DLQ size for operational alerts.</li>
 *   <li><b>Message persistence</b>: {@code DeliveryMode.PERSISTENT} (used here) ensures
 *       messages survive broker restarts. {@code NON_PERSISTENT} is faster but volatile.</li>
 *   <li><b>Transaction integration</b>: JMSContext used within a CMT {@code @Stateless} bean
 *       automatically participates in the EJB transaction. If the business method rolls back,
 *       the JMS send is also rolled back — no phantom messages.</li>
 * </ul>
 */
@JMSConnectionFactoryDefinition(
    name = "java:app/jms/TechMartConnectionFactory",
    interfaceName = "jakarta.jms.ConnectionFactory"
)
@JMSDestinationDefinitions({
    @JMSDestinationDefinition(
        name = "java:app/jms/OrderQueue",
        interfaceName = "jakarta.jms.Queue",
        destinationName = "OrderQueue"
    ),
    @JMSDestinationDefinition(
        name = "java:app/jms/InventoryAlertTopic",
        interfaceName = "jakarta.jms.Topic",
        destinationName = "InventoryAlertTopic"
    )
})
@Stateless
@Local(JmsProducerService.class)
public class JmsProducerServiceImpl implements JmsProducerService {

    private static final Logger LOG = Logger.getLogger(JmsProducerServiceImpl.class.getName());

    /**
     * Container-managed JMS ConnectionFactory, injected via JNDI @Resource.
     * Maps to the physical JMS resource declared in web.xml {@code <resource-ref>}
     * and configured in the Payara admin console.
     *
     * <p><b>@Resource vs @Inject for JMS</b>: @Resource is the correct annotation for
     * J2EE/Jakarta EE resource references (JMS, DataSource, env-entries). @Inject is
     * for CDI-managed beans. JMS resources are not CDI beans, so @Resource is mandatory.
     */
    @Resource(lookup = "java:app/jms/TechMartConnectionFactory")
    private ConnectionFactory connectionFactory;

    /**
     * JMS Queue destination for point-to-point order event messaging.
     * Bound in JNDI as declared by {@code <resource-env-ref>} in web.xml.
     */
    @Resource(lookup = "java:app/jms/OrderQueue")
    private Queue orderQueue;

    /**
     * JMS Topic destination for publish-subscribe inventory alert messaging.
     * Bound in JNDI as declared by {@code <resource-env-ref>} in web.xml.
     */
    @Resource(lookup = "java:app/jms/InventoryAlertTopic")
    private Topic inventoryAlertTopic;

    /**
     * @PostConstruct — verifies that all three JMS resources were successfully injected
     * by the container before any business method is called.
     */
    @PostConstruct
    public void onCreate() {
        boolean factoryOk = connectionFactory != null;
        boolean queueOk   = orderQueue != null;
        boolean topicOk   = inventoryAlertTopic != null;
        LOG.info("[JmsProducerService] @PostConstruct — JMS resources injected: "
                + "connectionFactory=" + factoryOk
                + ", orderQueue=" + queueOk
                + ", inventoryAlertTopic=" + topicOk);
        if (!factoryOk || !queueOk || !topicOk) {
            LOG.warning("[JmsProducerService] One or more JMS resources are null. "
                    + "Ensure JMS resources are configured in Payara admin console and "
                    + "declared in WEB-INF/web.xml. JMS operations will fail until resolved.");
        }
    }

    /**
     * @PreDestroy — logs bean retirement. JMSContext resources are auto-closed
     * (try-with-resources in business methods), so no explicit cleanup needed here.
     */
    @PreDestroy
    public void onDestroy() {
        LOG.fine("[JmsProducerService] @PreDestroy — @Stateless JMS producer bean retiring.");
    }

    /**
     * Sends an order placement event to the JMS Queue (Point-to-Point pattern).
     *
     * <p>Participant roles:
     * <ul>
     *   <li><b>Producer (this method)</b>: Creates and sends the message. Returns immediately
     *       after the broker acknowledges receipt. Does not wait for consumer processing.</li>
     *   <li><b>Broker (OpenMQ)</b>: Persists the message and delivers it to the next available
     *       {@code OrderProcessingMDB} consumer instance.</li>
     *   <li><b>Consumer (OrderProcessingMDB)</b>: Processes the message and sends ACK to broker.</li>
     * </ul>
     *
     * <p>Message delivery guarantee: {@code PERSISTENT} delivery mode ensures the message
     * survives a broker restart between production and consumption.
     *
     * @param order     the placed order entity
     * @param eventType the event type (e.g., "ORDER_PLACED", "ORDER_CANCELLED")
     */
    @Override
    public void sendOrderEvent(Order order, String eventType) {
        if (connectionFactory == null || orderQueue == null) {
            LOG.warning("[JmsProducerService] Cannot send order event — JMS resources not available. "
                    + "Order ID: " + order.getOrderId());
            return;
        }

        OrderEventMessage payload = new OrderEventMessage(
                order.getOrderId(),
                order.getUserId(),
                "",  // email resolved by consumer from userId
                "",  // name resolved by consumer from userId
                order.getTotalAmount() != null ? order.getTotalAmount().doubleValue() : 0.0,
                eventType,
                0   // item count resolved by consumer
        );

        try (JMSContext context = connectionFactory.createContext()) {
            ObjectMessage message = context.createObjectMessage(payload);
            message.setStringProperty("eventType", eventType);
            message.setIntProperty("orderId", order.getOrderId());
            message.setIntProperty("userId", order.getUserId());

            context.createProducer()
                    .setDeliveryMode(jakarta.jms.DeliveryMode.PERSISTENT)
                    .setPriority(jakarta.jms.Message.DEFAULT_PRIORITY)
                    .send(orderQueue, message);

            LOG.info("[JmsProducerService] P2P order event sent to OrderQueue: " + payload);
        } catch (JMSException e) {
            LOG.log(Level.SEVERE, "[JmsProducerService] Failed to send order event for orderId="
                    + order.getOrderId() + ". Message lost — consider retry or DLQ monitoring.", e);
        }
    }

    /**
     * Publishes a low-inventory alert to the JMS Topic (Publish-Subscribe pattern).
     *
     * <p>Participant roles:
     * <ul>
     *   <li><b>Publisher (this method)</b>: Publishes the alert once. Does not know or care
     *       how many subscribers are listening.</li>
     *   <li><b>Broker (OpenMQ Topic)</b>: Replicates the message and delivers it to each
     *       registered subscriber independently.</li>
     *   <li><b>Subscribers</b>: {@code InventoryAlertMDB} + any additional subscribers
     *       (email service, monitoring agent, etc.) each receive their own copy.</li>
     * </ul>
     *
     * <p>Durable subscription note: Subscribers registered as durable (via
     * {@code @ActivationConfigProperty(propertyName="subscriptionDurability", propertyValue="Durable")})
     * will receive messages sent while they were offline. Non-durable subscribers miss
     * messages published during their downtime.
     *
     * @param product         the product with low stock
     * @param currentStock    current stock level
     * @param threshold       low-stock threshold value
     */
    @Override
    public void publishInventoryAlert(Product product, int currentStock, int threshold) {
        if (connectionFactory == null || inventoryAlertTopic == null) {
            LOG.warning("[JmsProducerService] Cannot publish inventory alert — JMS resources not available. "
                    + "Product: " + product.getProductName());
            return;
        }

        InventoryAlertMessage.AlertSeverity severity = currentStock == 0
                ? InventoryAlertMessage.AlertSeverity.OUT_OF_STOCK
                : InventoryAlertMessage.AlertSeverity.LOW_STOCK;

        InventoryAlertMessage payload = new InventoryAlertMessage(
                product.getProductId(),
                product.getProductName(),
                currentStock,
                threshold,
                severity
        );

        try (JMSContext context = connectionFactory.createContext()) {
            ObjectMessage message = context.createObjectMessage(payload);
            message.setStringProperty("severity", severity.name());
            message.setIntProperty("productId", product.getProductId());
            message.setIntProperty("currentStock", currentStock);

            context.createProducer()
                    .setDeliveryMode(jakarta.jms.DeliveryMode.PERSISTENT)
                    .send(inventoryAlertTopic, message);

            LOG.info("[JmsProducerService] Pub/Sub inventory alert published to InventoryAlertTopic: "
                    + payload);
        } catch (JMSException e) {
            LOG.log(Level.SEVERE, "[JmsProducerService] Failed to publish inventory alert for productId="
                    + product.getProductId(), e);
        }
    }
}
