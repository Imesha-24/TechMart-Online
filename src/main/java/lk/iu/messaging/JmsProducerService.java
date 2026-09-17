package lk.iu.messaging;

import lk.iu.model.Order;
import lk.iu.model.Product;

/**
 * JmsProducerService — Local business interface for JMS message production.
 *
 * <h2>JMS Architecture Design</h2>
 * <p>This interface abstracts the JMS infrastructure from the business layer.
 * Services that need to dispatch order events or publish inventory alerts depend
 * on this interface (injected via CDI {@code @Inject} or {@code @EJB}), not on
 * the concrete JMS implementation, enabling easy substitution in tests.
 */
public interface JmsProducerService {

    /**
     * Sends an order event to the JMS Queue (Point-to-Point).
     * The message is consumed exactly once by {@code OrderProcessingMDB}.
     *
     * @param order     the order entity
     * @param eventType event identifier, e.g. "ORDER_PLACED", "ORDER_CANCELLED"
     */
    void sendOrderEvent(Order order, String eventType);

    /**
     * Publishes a low-inventory alert to the JMS Topic (Publish-Subscribe).
     * All active subscribers receive their own independent copy.
     *
     * @param product      the low-stock product
     * @param currentStock current stock level
     * @param threshold    configured low-stock threshold
     */
    void publishInventoryAlert(Product product, int currentStock, int threshold);
}
