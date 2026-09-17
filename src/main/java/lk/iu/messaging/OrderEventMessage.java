package lk.iu.messaging;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * OrderEventMessage — Serializable JMS message payload for order placement events.
 *
 * <h2>JMS Message Design</h2>
 * <p>This POJO is transmitted as a {@link jakarta.jms.ObjectMessage} payload through
 * the JMS {@code OrderQueue}. It implements {@link Serializable} as required by the
 * JMS specification for ObjectMessage payloads.
 *
 * <h3>Design Decision: ObjectMessage vs. TextMessage</h3>
 * <table border="1">
 *   <tr><th>Message Type</th><th>Pros</th><th>Cons</th></tr>
 *   <tr><td>ObjectMessage (this class)</td><td>Type-safe; no serialization code in producer</td>
 *       <td>Receiver must have the class on classpath; Java-only</td></tr>
 *   <tr><td>TextMessage (JSON)</td><td>Language-agnostic; human-readable</td>
 *       <td>Requires serializer/deserializer; less type-safe</td></tr>
 * </table>
 * <p>ObjectMessage is appropriate here since both producer and MDB consumer are
 * co-located in the same WAR/classloader.
 */
public class OrderEventMessage implements Serializable {

    private static final long serialVersionUID = 1L;

    private int orderId;
    private int userId;
    private String customerEmail;
    private String customerName;
    private double totalAmount;
    private String eventType;        // "ORDER_PLACED", "ORDER_CANCELLED", "ORDER_SHIPPED"
    private LocalDateTime eventTime;
    private int itemCount;

    public OrderEventMessage() {
        this.eventTime = LocalDateTime.now();
    }

    public OrderEventMessage(int orderId, int userId, String customerEmail,
                             String customerName, double totalAmount,
                             String eventType, int itemCount) {
        this.orderId = orderId;
        this.userId = userId;
        this.customerEmail = customerEmail;
        this.customerName = customerName;
        this.totalAmount = totalAmount;
        this.eventType = eventType;
        this.itemCount = itemCount;
        this.eventTime = LocalDateTime.now();
    }

    public int getOrderId()           { return orderId; }
    public void setOrderId(int v)     { this.orderId = v; }

    public int getUserId()            { return userId; }
    public void setUserId(int v)      { this.userId = v; }

    public String getCustomerEmail()         { return customerEmail; }
    public void setCustomerEmail(String v)   { this.customerEmail = v; }

    public String getCustomerName()          { return customerName; }
    public void setCustomerName(String v)    { this.customerName = v; }

    public double getTotalAmount()           { return totalAmount; }
    public void setTotalAmount(double v)     { this.totalAmount = v; }

    public String getEventType()             { return eventType; }
    public void setEventType(String v)       { this.eventType = v; }

    public LocalDateTime getEventTime()      { return eventTime; }
    public void setEventTime(LocalDateTime v){ this.eventTime = v; }

    public int getItemCount()                { return itemCount; }
    public void setItemCount(int v)          { this.itemCount = v; }

    @Override
    public String toString() {
        return "OrderEventMessage{orderId=" + orderId + ", userId=" + userId
                + ", type='" + eventType + "', total=" + totalAmount
                + ", items=" + itemCount + ", time=" + eventTime + "}";
    }
}
