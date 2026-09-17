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
    <title>Inventory Management - TechMart Online</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/dashboard.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/responsive.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="../components/sidebar.jsp" />
    <jsp:include page="../components/notification.jsp" />

    <div class="admin-layout">
        <div class="admin-main" id="adminMain">
            <div class="admin-topbar">
                <div class="d-flex align-items-center gap-3">
                    <button class="btn btn-icon" id="sidebarToggle"><i class="fas fa-bars"></i></button>
                    <h5 class="mb-0 fw-bold d-none d-md-block">Inventory Management</h5>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <button class="btn btn-icon" id="darkModeToggle"><i class="fas fa-moon" id="darkModeIcon"></i></button>
                    <!-- Global Restock button could open a modal with product selection -->
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
                    <h1 class="h3 fw-bold mb-1">Inventory</h1>
                    <p class="text-muted mb-0">Monitor and manage stock levels across all products</p>
                </div>

                <!-- Inventory Summary Cards -->
                <div class="row g-4 mb-4">
                    <div class="col-sm-4">
                        <div class="dashboard-card card-success text-center">
                            <div class="dashboard-card-icon icon-success mx-auto"><i class="fas fa-check-circle"></i></div>
                            <div class="dashboard-card-value" data-counter="${stats.in_stock}">0</div>
                            <div class="dashboard-card-label">In Stock</div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="dashboard-card card-warning text-center">
                            <div class="dashboard-card-icon icon-warning mx-auto"><i class="fas fa-exclamation-triangle"></i></div>
                            <div class="dashboard-card-value" data-counter="${stats.low_stock}">0</div>
                            <div class="dashboard-card-label">Low Stock</div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="dashboard-card card-primary text-center" style="--danger: #dc3545;">
                            <div class="dashboard-card-icon mx-auto" style="background:rgba(220,53,69,0.12);color:#dc3545;"><i class="fas fa-times-circle"></i></div>
                            <div class="dashboard-card-value" data-counter="${stats.out_of_stock}">0</div>
                            <div class="dashboard-card-label">Out of Stock</div>
                        </div>
                    </div>
                </div>

                <div class="table-card">
                    <div class="table-card-header d-flex justify-content-between align-items-center">
                        <h5 class="table-card-title mb-0">Stock Levels</h5>
                        <form action="${pageContext.request.contextPath}/admin/inventory" method="GET" class="admin-search mb-0 position-relative">
                            <i class="fas fa-search position-absolute top-50 start-0 translate-middle-y ms-3 text-muted"></i>
                            <input type="text" name="search" class="form-control ps-5" value="${search}" placeholder="Search inventory...">
                        </form>
                    </div>
                    <div class="table-responsive">
                        <table class="table data-table">
                            <thead>
                                <tr>
                                    <th>Product</th>
                                    <th>SKU</th>
                                    <th>Warehouse</th>
                                    <th>Current Stock</th>
                                    <th>Stock Level</th>
                                    <th>Reorder Point</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty products}">
                                        <tr>
                                            <td colspan="8" class="text-center py-4 text-muted">No products found.</td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="p" items="${products}">
                                            <!-- Using hardcoded reorder point of 10 -->
                                            <c:set var="reorderPoint" value="10" />
                                            <c:set var="maxStock" value="100" />
                                            <!-- Calculate percentage, max 100 -->
                                            <c:set var="stockPercentage" value="${(p.stockQuantity / maxStock) * 100}" />
                                            <c:if test="${stockPercentage > 100}"><c:set var="stockPercentage" value="100" /></c:if>
                                            
                                            <c:set var="stockClass" value="" />
                                            <c:set var="stockLabel" value="" />
                                            <c:set var="progressClass" value="" />
                                            
                                            <c:choose>
                                                <c:when test="${p.stockQuantity == 0}">
                                                    <c:set var="stockClass" value="status-out-stock" />
                                                    <c:set var="stockLabel" value="Out of Stock" />
                                                    <c:set var="progressClass" value="low" />
                                                </c:when>
                                                <c:when test="${p.stockQuantity < reorderPoint}">
                                                    <c:set var="stockClass" value="status-low-stock" />
                                                    <c:set var="stockLabel" value="Low Stock" />
                                                    <c:set var="progressClass" value="medium" />
                                                </c:when>
                                                <c:otherwise>
                                                    <c:set var="stockClass" value="status-in-stock" />
                                                    <c:set var="stockLabel" value="In Stock" />
                                                    <c:set var="progressClass" value="high" />
                                                </c:otherwise>
                                            </c:choose>
                                            
                                            <tr>
                                                <td>
                                                    <div class="d-flex align-items-center gap-2">
                                                        <img src="${not empty p.imageUrl ? p.imageUrl : 'https://via.placeholder.com/44x44?text=?'}" class="table-product-img" alt="">
                                                        <span class="fw-semibold">${p.productName}</span>
                                                    </div>
                                                </td>
                                                <td>TM-<fmt:formatNumber value="${p.productId}" pattern="00000"/></td>
                                                <td>Main Warehouse</td>
                                                <td>${p.stockQuantity}</td>
                                                <td style="min-width:120px;">
                                                    <div class="stock-progress">
                                                        <div class="stock-progress-bar ${progressClass}" data-width="${stockPercentage}" style="width:${stockPercentage}%;"></div>
                                                    </div>
                                                </td>
                                                <td>${reorderPoint}</td>
                                                <td><span class="status-badge ${stockClass}">${stockLabel}</span></td>
                                                <td>
                                                    <div class="table-actions">
                                                        <button class="btn-table-action text-primary" title="Restock" onclick="openRestockModal(${p.productId}, '${fn:escapeXml(p.productName)}', ${p.stockQuantity})">
                                                            <i class="fas fa-plus"></i>
                                                        </button>
                                                        <button class="btn-table-action text-info" title="History" onclick="openHistoryModal(${p.productId}, '${fn:escapeXml(p.productName)}')">
                                                            <i class="fas fa-history"></i>
                                                        </button>
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

    <!-- Restock Modal -->
    <div class="modal fade" id="restockModal" tabindex="-1" aria-labelledby="restockModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content border-0 rounded-4 shadow">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold" id="restockModalLabel"><i class="fas fa-box-open text-primary me-2"></i>Restock Product</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="${pageContext.request.contextPath}/admin/inventory" method="POST">
                    <div class="modal-body pt-3">
                        <input type="hidden" name="action" value="restock">
                        <input type="hidden" name="productId" id="restockProductId">
                        <div class="mb-3">
                            <label class="form-label text-muted small fw-semibold text-uppercase">Product Name</label>
                            <p class="fw-bold mb-0" id="restockProductName"></p>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-muted small fw-semibold text-uppercase">Current Stock</label>
                            <p class="fw-bold mb-0" id="restockCurrentStock"></p>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Quantity to Add</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="fas fa-plus text-primary"></i></span>
                                <input type="number" class="form-control border-start-0 ps-0" name="addedStock" id="addedStock" min="1" required placeholder="Enter quantity">
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-0 pt-0 pb-4 px-4">
                        <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary rounded-pill px-4 shadow-sm">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- History Modal -->
    <div class="modal fade" id="historyModal" tabindex="-1" aria-labelledby="historyModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content border-0 rounded-4 shadow">
                <div class="modal-header border-0 pb-2">
                    <h5 class="modal-title fw-bold" id="historyModalLabel"><i class="fas fa-history text-info me-2"></i>Inventory History</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body pt-0">
                    <p class="text-muted small mb-3">Viewing history for <span class="fw-bold text-dark" id="historyProductName"></span></p>
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Date & Time</th>
                                    <th>Admin</th>
                                    <th>Previous Stock</th>
                                    <th>New Stock</th>
                                    <th>Change</th>
                                </tr>
                            </thead>
                            <tbody id="historyTableBody">
                                <!-- Populated via AJAX -->
                            </tbody>
                        </table>
                    </div>
                    <div id="historyLoading" class="text-center py-4" style="display: none;">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                    </div>
                    <div id="historyEmpty" class="text-center py-4 text-muted" style="display: none;">
                        No history found for this product.
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
        function openRestockModal(productId, productName, currentStock) {
            document.getElementById('restockProductId').value = productId;
            document.getElementById('restockProductName').textContent = productName;
            document.getElementById('restockCurrentStock').textContent = currentStock;
            document.getElementById('addedStock').value = '';
            
            var modal = new bootstrap.Modal(document.getElementById('restockModal'));
            modal.show();
        }

        function openHistoryModal(productId, productName) {
            document.getElementById('historyProductName').textContent = productName;
            const tbody = document.getElementById('historyTableBody');
            const loading = document.getElementById('historyLoading');
            const empty = document.getElementById('historyEmpty');
            
            tbody.innerHTML = '';
            loading.style.display = 'block';
            empty.style.display = 'none';
            
            var modal = new bootstrap.Modal(document.getElementById('historyModal'));
            modal.show();

            // Fetch history data via AJAX
            const url = '${pageContext.request.contextPath}/admin/inventory';
            const formData = new URLSearchParams();
            formData.append('action', 'history');
            formData.append('productId', productId);
            
            fetch(url, {
                method: 'POST',
                body: formData,
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            })
            .then(response => response.json())
            .then(data => {
                loading.style.display = 'none';
                
                if (data && data.length > 0) {
                    data.forEach(log => {
                        const change = log.newStock - log.previousStock;
                        const changeHtml = change > 0 
                            ? `<span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25">+${change}</span>`
                            : `<span class="badge bg-danger bg-opacity-10 text-danger border border-danger border-opacity-25">${change}</span>`;
                            
                        const date = new Date(log.updatedAt);
                        
                        // Fallback format if options are not supported in all browsers
                        let dateString;
                        try {
                            dateString = new Intl.DateTimeFormat('en-US', {
                                year: 'numeric', month: 'short', day: '2-digit',
                                hour: '2-digit', minute: '2-digit'
                            }).format(date);
                        } catch (e) {
                            dateString = date.toLocaleString();
                        }
                        
                        const row = `
                            <tr>
                                <td class="small text-muted">${dateString}</td>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="avatar-circle" style="width:24px;height:24px;min-width:24px;">
                                            <img src="https://ui-avatars.com/api/?name=${log.updatedBy}&background=random&color=fff&size=24" alt="${log.updatedBy}">
                                        </div>
                                        <span class="fw-medium">${log.updatedBy}</span>
                                    </div>
                                </td>
                                <td>${log.previousStock}</td>
                                <td class="fw-bold">${log.newStock}</td>
                                <td>${changeHtml}</td>
                            </tr>
                        `;
                        tbody.innerHTML += row;
                    });
                } else {
                    empty.style.display = 'block';
                }
            })
            .catch(error => {
                console.error('Error fetching history:', error);
                loading.style.display = 'none';
                empty.style.display = 'block';
                empty.textContent = 'Error loading history. Please try again.';
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
