package lk.iu.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Order {
    private int orderId;
    private int userId;
    private BigDecimal totalAmount;
    private Timestamp orderDate;
    private int statusId;

    public Order() {}

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public Timestamp getOrderDate() { return orderDate; }
    public void setOrderDate(Timestamp orderDate) { this.orderDate = orderDate; }
    public int getStatusId() { return statusId; }
    public void setStatusId(int statusId) { this.statusId = statusId; }
    
    // Transient fields for UI display
    private String statusName;
    private java.util.List<OrderItem> orderItems;
    private String customerName;
    private String customerEmail;
    private String paymentMethod;
    private String paymentStatus;
    
    public String getStatusName() { return statusName; }
    public void setStatusName(String statusName) { this.statusName = statusName; }
    public java.util.List<OrderItem> getOrderItems() { return orderItems; }
    public void setOrderItems(java.util.List<OrderItem> orderItems) { this.orderItems = orderItems; }
    
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public String getCustomerEmail() { return customerEmail; }
    public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
}
