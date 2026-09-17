<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="context-path" content="${pageContext.request.contextPath}">
    <title>My Orders - TechMart Online</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/responsive.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="components/header.jsp" />
    <jsp:include page="components/notification.jsp" />

    <main class="main-content">
        <div class="container-page">
            <div class="page-header">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb breadcrumb-glass">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                        <li class="breadcrumb-item active">My Orders</li>
                    </ol>
                </nav>
                <h1><i class="fas fa-box text-primary me-2"></i>Order History</h1>
                <p class="text-muted">Track and manage your enterprise orders</p>
            </div>

            <c:choose>
                <c:when test="${empty orders}">
                    <div class="glass-card text-center p-5 mt-4">
                        <i class="fas fa-box-open fa-3x text-muted mb-3"></i>
                        <h4>No Orders Found</h4>
                        <p class="text-muted mb-4">You haven't placed any orders yet.</p>
                        <a href="${pageContext.request.contextPath}/products" class="btn btn-primary btn-lg">
                            <i class="fas fa-shopping-bag me-2"></i>Start Shopping
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="order" items="${orders}">
                        <div class="order-card mt-4">
                            <div class="row align-items-center mb-3">
                                <div class="col-md-3">
                                    <small class="text-muted d-block">Order ID</small>
                                    <span class="fw-bold">#TM-2026-${order.orderId}</span>
                                </div>
                                <div class="col-md-3">
                                    <small class="text-muted d-block">Date</small>
                                    <span><fmt:formatDate value="${order.orderDate}" pattern="MMM dd, yyyy" /></span>
                                </div>
                                <div class="col-md-3">
                                    <small class="text-muted d-block">Total</small>
                                    <span class="fw-bold text-primary">Rs. <fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00" /></span>
                                </div>
                                <div class="col-md-3 text-md-end">
                                    <c:choose>
                                        <c:when test="${order.statusId == 1}">
                                            <span class="status-badge status-pending">${order.statusName}</span>
                                        </c:when>
                                        <c:when test="${order.statusId == 2}">
                                            <span class="status-badge status-pending">${order.statusName}</span>
                                        </c:when>
                                        <c:when test="${order.statusId == 3}">
                                            <span class="status-badge status-shipped">${order.statusName}</span>
                                        </c:when>
                                        <c:when test="${order.statusId == 4}">
                                            <span class="status-badge status-delivered">${order.statusName}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge bg-secondary text-white">${order.statusName}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="row g-3 mb-3">
                                <c:forEach var="item" items="${order.orderItems}">
                                    <div class="col-auto">
                                        <img src="${item.product.imageUrl}" alt="${item.product.productName}" class="cart-item-image">
                                    </div>
                                    <div class="col">
                                        <h6 class="mb-1 fw-semibold">${item.product.productName}</h6>
                                        <small class="text-muted">Qty: ${item.quantity} &times; Rs. ${item.unitPrice}</small>
                                    </div>
                                </c:forEach>
                            </div>
                            <div class="row">
                                <div class="col-lg-6">
                                    <h6 class="fw-semibold mb-3">Order Status</h6>
                                    <div class="order-timeline">
                                        <div class="timeline-item ${order.statusId >= 1 ? 'completed' : ''}">
                                            <div class="timeline-dot"><i class="fas fa-check"></i></div>
                                            <strong>Order Placed</strong>
                                            <p class="text-muted small mb-0">Completed</p>
                                        </div>
                                        <div class="timeline-item ${order.statusId >= 2 ? 'completed' : (order.statusId == 1 ? 'active' : '')}">
                                            <div class="timeline-dot"><c:if test="${order.statusId >= 2}"><i class="fas fa-check"></i></c:if></div>
                                            <strong>Processing</strong>
                                            <p class="text-muted small mb-0">${order.statusId >= 2 ? 'Completed' : (order.statusId == 1 ? 'In Progress' : 'Pending')}</p>
                                        </div>
                                        <div class="timeline-item ${order.statusId >= 3 ? 'completed' : (order.statusId == 2 ? 'active' : '')}">
                                            <div class="timeline-dot"><c:if test="${order.statusId >= 3}"><i class="fas fa-check"></i></c:if></div>
                                            <strong>Shipped</strong>
                                            <p class="text-muted small mb-0">${order.statusId >= 3 ? 'Completed' : 'Pending'}</p>
                                        </div>
                                        <div class="timeline-item ${order.statusId >= 4 ? 'completed' : (order.statusId == 3 ? 'active' : '')}">
                                            <div class="timeline-dot"><c:if test="${order.statusId >= 4}"><i class="fas fa-check"></i></c:if></div>
                                            <strong>Delivered</strong>
                                            <p class="text-muted small mb-0">${order.statusId >= 4 ? 'Completed' : 'Pending'}</p>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-6 d-flex align-items-end justify-content-lg-end gap-2 mt-3 mt-lg-0">
                                    <button class="btn btn-outline-primary btn-sm"><i class="fas fa-file-invoice me-1"></i> Invoice</button>
                                    <c:if test="${order.statusId == 1 || order.statusId == 2}">
                                        <button class="btn btn-outline-danger btn-sm"><i class="fas fa-times me-1"></i> Cancel</button>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

    <jsp:include page="components/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/cart.js"></script>
</body>
</html>
