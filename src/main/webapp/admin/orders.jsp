<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="context-path" content="${pageContext.request.contextPath}">
    <title>Order Management - TechMart Online</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/dashboard.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/responsive.css" rel="stylesheet">
    <style>
        .order-status-pill { display: inline-block; padding: 0.25rem 0.75rem; border-radius: 50px; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; }
        .status-pending { background-color: #e0f2fe; color: #0284c7; }
        .status-processing { background-color: #fef08a; color: #ca8a04; }
        .status-paid { background-color: #d1fae5; color: #059669; }
        .status-shipped { background-color: #bfdbfe; color: #1d4ed8; }
        .status-delivered { background-color: #bbf7d0; color: #15803d; }
        .status-cancelled { background-color: #fecaca; color: #b91c1c; }

        .payment-method-icon { width: 24px; height: 16px; object-fit: contain; vertical-align: middle; }
        
        .avatar-initials { width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 600; color: white; }
    </style>
</head>
<body>
    <jsp:include page="../components/sidebar.jsp" />
    <jsp:include page="../components/notification.jsp" />

    <div class="admin-layout">
        <div class="admin-main" id="adminMain">
            <div class="admin-topbar">
                <div class="d-flex align-items-center gap-3">
                    <button class="btn btn-icon" id="sidebarToggle"><i class="fas fa-bars"></i></button>
                    <h5 class="mb-0 fw-bold d-none d-md-block">Order Management</h5>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <button class="btn btn-icon" id="darkModeToggle"><i class="fas fa-moon" id="darkModeIcon"></i></button>
                    <button class="btn btn-outline-primary btn-sm"><i class="fas fa-download me-1"></i> Export</button>
                </div>
            </div>

            <div class="admin-content">
                
                <%-- Flash messages --%>
                <c:if test="${not empty sessionScope.successMsg}">
                    <div class="alert alert-success alert-dismissible fade show rounded-3 mb-3" role="alert" id="successAlert">
                        <i class="fas fa-check-circle me-2"></i>${sessionScope.successMsg}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="successMsg" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.errorMsg}">
                    <div class="alert alert-danger alert-dismissible fade show rounded-3 mb-3" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMsg}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="errorMsg" scope="session"/>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-warning alert-dismissible fade show rounded-3 mb-3" role="alert">
                        <i class="fas fa-exclamation-triangle me-2"></i>${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <div class="mb-4">
                    <h1 class="h3 fw-bold mb-1">Manage Orders</h1>
                    <p class="text-muted mb-0">Manage and track all customer orders</p>
                </div>

                <!-- Order Summary Cards -->
                <div class="row g-4 mb-4">
                    <div class="col-sm-3">
                        <div class="dashboard-card text-center" style="border-top: 4px solid #0284c7;">
                            <div class="dashboard-card-value text-primary" data-counter="${stats.pending}">0</div>
                            <div class="dashboard-card-label">Pending</div>
                        </div>
                    </div>
                    <div class="col-sm-3">
                        <div class="dashboard-card text-center" style="border-top: 4px solid #ca8a04;">
                            <div class="dashboard-card-value text-warning" data-counter="${stats.processing}">0</div>
                            <div class="dashboard-card-label">Processing</div>
                        </div>
                    </div>
                    <div class="col-sm-3">
                        <div class="dashboard-card text-center" style="border-top: 4px solid #1d4ed8;">
                            <div class="dashboard-card-value text-info" data-counter="${stats.shipped}">0</div>
                            <div class="dashboard-card-label">Shipped</div>
                        </div>
                    </div>
                    <div class="col-sm-3">
                        <div class="dashboard-card text-center" style="border-top: 4px solid #15803d;">
                            <div class="dashboard-card-value text-success" data-counter="${stats.delivered}">0</div>
                            <div class="dashboard-card-label">Delivered</div>
                        </div>
                    </div>
                </div>

                <div class="table-card">
                    <div class="table-card-header d-flex justify-content-between align-items-center flex-wrap gap-3">
                        <h5 class="table-card-title mb-0">All Orders</h5>
                        <form action="${pageContext.request.contextPath}/admin/orders" method="GET" class="d-flex gap-2 mb-0">
                            <select name="status" class="form-select" onchange="this.form.submit()" style="max-width: 150px;">
                                <option value="All Status" ${selectedStatus == 'All Status' ? 'selected' : ''}>All Status</option>
                                <option value="1" ${selectedStatus == '1' ? 'selected' : ''}>Pending</option>
                                <option value="2" ${selectedStatus == '2' ? 'selected' : ''}>Processing</option>
                                <option value="3" ${selectedStatus == '3' ? 'selected' : ''}>Paid</option>
                                <option value="4" ${selectedStatus == '4' ? 'selected' : ''}>Shipped</option>
                                <option value="5" ${selectedStatus == '5' ? 'selected' : ''}>Delivered</option>
                                <option value="6" ${selectedStatus == '6' ? 'selected' : ''}>Cancelled</option>
                            </select>
                            <div class="admin-search mb-0 position-relative">
                                <i class="fas fa-search position-absolute top-50 start-0 translate-middle-y ms-3 text-muted"></i>
                                <input type="text" name="search" class="form-control ps-5" value="${search}" placeholder="Search orders...">
                            </div>
                        </form>
                    </div>
                    <div class="table-responsive">
                        <table class="table data-table">
                            <thead>
                                <tr>
                                    <th>Order ID</th>
                                    <th>Customer</th>
                                    <th>Items</th>
                                    <th>Total</th>
                                    <th>Payment</th>
                                    <th>Status</th>
                                    <th>Date</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty orders}">
                                        <tr>
                                            <td colspan="8" class="text-center py-4 text-muted">No orders found.</td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="o" items="${orders}">
                                            <c:set var="statusClass" value="" />
                                            <c:choose>
                                                <c:when test="${o.statusId == 1}"><c:set var="statusClass" value="status-pending" /></c:when>
                                                <c:when test="${o.statusId == 2}"><c:set var="statusClass" value="status-processing" /></c:when>
                                                <c:when test="${o.statusId == 3}"><c:set var="statusClass" value="status-paid" /></c:when>
                                                <c:when test="${o.statusId == 4}"><c:set var="statusClass" value="status-shipped" /></c:when>
                                                <c:when test="${o.statusId == 5}"><c:set var="statusClass" value="status-delivered" /></c:when>
                                                <c:when test="${o.statusId == 6}"><c:set var="statusClass" value="status-cancelled" /></c:when>
                                            </c:choose>

                                            <!-- Get Initials -->
                                            <c:set var="initials" value="${fn:substring(o.customerName, 0, 1)}" />
                                            <c:set var="nameParts" value="${fn:split(o.customerName, ' ')}" />
                                            <c:if test="${fn:length(nameParts) > 1}">
                                                <c:set var="initials" value="${initials}${fn:substring(nameParts[1], 0, 1)}" />
                                            </c:if>

                                            <!-- Calculate items count -->
                                            <c:set var="itemsCount" value="0" />
                                            <c:forEach var="item" items="${o.orderItems}">
                                                <c:set var="itemsCount" value="${itemsCount + item.quantity}" />
                                            </c:forEach>

                                            <tr>
                                                <td class="fw-semibold text-dark">#TM-<fmt:formatDate value="${o.orderDate}" pattern="yyyy"/>-<fmt:formatNumber value="${o.orderId}" pattern="0000"/></td>
                                                <td>
                                                    <div class="d-flex align-items-center gap-2">
                                                        <div class="avatar-initials bg-primary">${initials}</div>
                                                        <div>
                                                            <div class="fw-semibold text-dark" style="font-size: 0.9rem;">${o.customerName}</div>
                                                            <div class="text-muted" style="font-size: 0.8rem;">${o.customerEmail}</div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>${itemsCount}</td>
                                                <td class="fw-bold text-dark">Rs. <fmt:formatNumber value="${o.totalAmount}" pattern="#,##0.00"/></td>
                                                <td>
                                                    <div class="d-flex align-items-center gap-1">
                                                        <c:choose>
                                                            <c:when test="${fn:containsIgnoreCase(o.paymentMethod, 'visa')}">
                                                                <i class="fab fa-cc-visa text-primary fs-5"></i> Visa
                                                            </c:when>
                                                            <c:when test="${fn:containsIgnoreCase(o.paymentMethod, 'mastercard')}">
                                                                <i class="fab fa-cc-mastercard text-danger fs-5"></i> Mastercard
                                                            </c:when>
                                                            <c:when test="${fn:containsIgnoreCase(o.paymentMethod, 'amex')}">
                                                                <i class="fab fa-cc-amex text-info fs-5"></i> Amex
                                                            </c:when>
                                                            <c:when test="${fn:containsIgnoreCase(o.paymentMethod, 'paypal')}">
                                                                <i class="fab fa-cc-paypal text-primary fs-5"></i> PayPal
                                                            </c:when>
                                                            <c:otherwise>
                                                                <i class="fas fa-credit-card text-muted fs-5"></i> ${not empty o.paymentMethod ? o.paymentMethod : 'N/A'}
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </td>
                                                <td><span class="order-status-pill ${statusClass}">${o.statusName}</span></td>
                                                <td class="text-muted"><fmt:formatDate value="${o.orderDate}" pattern="MMM d, yyyy" /></td>
                                                <td>
                                                    <div class="table-actions">
                                                        <button class="btn-table-action text-secondary" title="View Order" onclick="viewOrder(${o.orderId})">
                                                            <i class="fas fa-eye"></i>
                                                        </button>
                                                        <button class="btn-table-action text-primary dropdown-toggle dropdown-toggle-split" data-bs-toggle="dropdown" aria-expanded="false" title="Update Status">
                                                            <i class="fas fa-truck"></i>
                                                        </button>
                                                        <ul class="dropdown-menu shadow border-0">
                                                            <li><h6 class="dropdown-header">Update Status</h6></li>
                                                            <li><form method="post" action="${pageContext.request.contextPath}/admin/orders"><input type="hidden" name="action" value="update_status"><input type="hidden" name="orderId" value="${o.orderId}"><input type="hidden" name="statusId" value="1"><button class="dropdown-item" type="submit"><i class="fas fa-clock text-info me-2"></i>Pending</button></form></li>
                                                            <li><form method="post" action="${pageContext.request.contextPath}/admin/orders"><input type="hidden" name="action" value="update_status"><input type="hidden" name="orderId" value="${o.orderId}"><input type="hidden" name="statusId" value="2"><button class="dropdown-item" type="submit"><i class="fas fa-cog text-warning me-2"></i>Processing</button></form></li>
                                                            <li><form method="post" action="${pageContext.request.contextPath}/admin/orders"><input type="hidden" name="action" value="update_status"><input type="hidden" name="orderId" value="${o.orderId}"><input type="hidden" name="statusId" value="3"><button class="dropdown-item" type="submit"><i class="fas fa-money-bill text-success me-2"></i>Paid</button></form></li>
                                                            <li><form method="post" action="${pageContext.request.contextPath}/admin/orders"><input type="hidden" name="action" value="update_status"><input type="hidden" name="orderId" value="${o.orderId}"><input type="hidden" name="statusId" value="4"><button class="dropdown-item" type="submit"><i class="fas fa-shipping-fast text-primary me-2"></i>Shipped</button></form></li>
                                                            <li><form method="post" action="${pageContext.request.contextPath}/admin/orders"><input type="hidden" name="action" value="update_status"><input type="hidden" name="orderId" value="${o.orderId}"><input type="hidden" name="statusId" value="5"><button class="dropdown-item" type="submit"><i class="fas fa-box-open text-success me-2"></i>Delivered</button></form></li>
                                                            <li><hr class="dropdown-divider"></li>
                                                            <li><form method="post" action="${pageContext.request.contextPath}/admin/orders"><input type="hidden" name="action" value="update_status"><input type="hidden" name="orderId" value="${o.orderId}"><input type="hidden" name="statusId" value="6"><button class="dropdown-item text-danger" type="submit"><i class="fas fa-times-circle me-2"></i>Cancel Order</button></form></li>
                                                        </ul>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Order Details Modal -->
    <div class="modal fade" id="orderDetailsModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content border-0 rounded-4 shadow">
                <div class="modal-header border-0 pb-2">
                    <h5 class="modal-title fw-bold" id="modalOrderTitle">Order Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body pt-0">
                    <div id="modalOrderLoading" class="text-center py-5">
                        <div class="spinner-border text-primary" role="status"></div>
                        <p class="text-muted mt-2">Loading order details...</p>
                    </div>
                    <div id="modalOrderContent" style="display: none;">
                        <div class="row g-4 mb-4">
                            <div class="col-md-6">
                                <div class="bg-light p-3 rounded-3 h-100">
                                    <h6 class="fw-bold mb-3 text-uppercase small text-muted">Customer Information</h6>
                                    <p class="mb-1 fw-semibold text-dark" id="modalCustomerName"></p>
                                    <p class="mb-0 text-muted" id="modalCustomerEmail"></p>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="bg-light p-3 rounded-3 h-100">
                                    <h6 class="fw-bold mb-3 text-uppercase small text-muted">Order Information</h6>
                                    <p class="mb-1"><strong>Date:</strong> <span id="modalOrderDate"></span></p>
                                    <p class="mb-1"><strong>Status:</strong> <span id="modalOrderStatus" class="order-status-pill"></span></p>
                                    <p class="mb-0"><strong>Payment:</strong> <span id="modalOrderPayment"></span></p>
                                </div>
                            </div>
                        </div>
                        <h6 class="fw-bold mb-3 text-uppercase small text-muted">Order Items</h6>
                        <div class="table-responsive">
                            <table class="table">
                                <thead class="table-light">
                                    <tr>
                                        <th>Product</th>
                                        <th>Price</th>
                                        <th>Qty</th>
                                        <th class="text-end">Subtotal</th>
                                    </tr>
                                </thead>
                                <tbody id="modalOrderItemsBody">
                                    <!-- Items injected here -->
                                </tbody>
                                <tfoot>
                                    <tr>
                                        <td colspan="3" class="text-end fw-bold">Total Amount:</td>
                                        <td class="text-end fw-bold text-primary" id="modalOrderTotal"></td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pb-4 px-4">
                    <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
    
    <script>
        function viewOrder(orderId) {
            const modal = new bootstrap.Modal(document.getElementById('orderDetailsModal'));
            modal.show();
            
            document.getElementById('modalOrderLoading').style.display = 'block';
            document.getElementById('modalOrderContent').style.display = 'none';
            
            const url = '${pageContext.request.contextPath}/admin/orders';
            const formData = new URLSearchParams();
            formData.append('action', 'view_order');
            formData.append('orderId', orderId);
            
            fetch(url, {
                method: 'POST',
                body: formData,
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            })
            .then(response => response.json())
            .then(order => {
                document.getElementById('modalOrderLoading').style.display = 'none';
                document.getElementById('modalOrderContent').style.display = 'block';
                
                document.getElementById('modalOrderTitle').textContent = `Order #TM-\${new Date(order.orderDate).getFullYear()}-\${order.orderId.toString().padStart(4, '0')}`;
                document.getElementById('modalCustomerName').textContent = order.customerName;
                document.getElementById('modalCustomerEmail').textContent = order.customerEmail;
                
                let dateStr;
                try {
                    dateStr = new Intl.DateTimeFormat('en-US', {
                        year: 'numeric', month: 'short', day: '2-digit',
                        hour: '2-digit', minute: '2-digit'
                    }).format(new Date(order.orderDate));
                } catch(e) {
                    dateStr = new Date(order.orderDate).toLocaleString();
                }
                document.getElementById('modalOrderDate').textContent = dateStr;
                
                const statusSpan = document.getElementById('modalOrderStatus');
                statusSpan.textContent = order.statusName;
                statusSpan.className = 'order-status-pill';
                if(order.statusId === 1) statusSpan.classList.add('status-pending');
                else if(order.statusId === 2) statusSpan.classList.add('status-processing');
                else if(order.statusId === 3) statusSpan.classList.add('status-paid');
                else if(order.statusId === 4) statusSpan.classList.add('status-shipped');
                else if(order.statusId === 5) statusSpan.classList.add('status-delivered');
                else if(order.statusId === 6) statusSpan.classList.add('status-cancelled');
                
                document.getElementById('modalOrderPayment').textContent = `\${order.paymentMethod || 'N/A'} (\${order.paymentStatus || 'Pending'})`;
                
                document.getElementById('modalOrderTotal').textContent = `Rs. \${order.totalAmount.toFixed(2)}`;
                
                const itemsBody = document.getElementById('modalOrderItemsBody');
                itemsBody.innerHTML = '';
                
                if (order.orderItems && order.orderItems.length > 0) {
                    order.orderItems.forEach(item => {
                        const productUrl = `\${item.product && item.product.imageUrl ? item.product.imageUrl : 'https://via.placeholder.com/44x44?text=?'}`;
                        const productName = item.product ? item.product.productName : 'Unknown Product';
                        const subtotal = item.quantity * item.unitPrice;
                        
                        itemsBody.innerHTML += `
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <img src="\${productUrl}" alt="" style="width: 32px; height: 32px; border-radius: 6px; object-fit: cover;">
                                        <span>\${productName}</span>
                                    </div>
                                </td>
                                <td>Rs. \${item.unitPrice.toFixed(2)}</td>
                                <td>\${item.quantity}</td>
                                <td class="text-end fw-semibold">Rs. \${subtotal.toFixed(2)}</td>
                            </tr>
                        `;
                    });
                }
            })
            .catch(error => {
                console.error('Error fetching order details:', error);
                document.getElementById('modalOrderLoading').innerHTML = '<p class="text-danger">Failed to load order details.</p>';
            });
        }
        
        // Auto-dismiss success alert
        window.addEventListener('DOMContentLoaded', () => {
            const sa = document.getElementById('successAlert');
            if (sa) setTimeout(() => { const a = bootstrap.Alert.getOrCreateInstance(sa); a && a.close(); }, 4000);
        });
    </script>
</body>
</html>
