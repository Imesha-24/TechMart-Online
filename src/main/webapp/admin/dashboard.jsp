<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.math.BigDecimal, java.util.List, java.util.Map, java.text.SimpleDateFormat, java.text.NumberFormat, java.util.Locale" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="context-path" content="${pageContext.request.contextPath}">
    <title>Admin Dashboard - TechMart Online</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/dashboard.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/responsive.css" rel="stylesheet">
    <style>
        /* ── Avatar initials ─────────────────────────────────────── */
        .order-avatar {
            width: 36px; height: 36px; border-radius: 50%;
            display: inline-flex; align-items: center; justify-content: center;
            font-size: .73rem; font-weight: 700; color: #fff;
            flex-shrink: 0; text-transform: uppercase;
        }
        /* ── Trend badge ─────────────────────────────────────────── */
        .trend-chip {
            display: inline-flex; align-items: center; gap: .3rem;
            font-size: .72rem; font-weight: 600; padding: .25rem .6rem;
            border-radius: 2rem;
        }
        .trend-chip.up   { background: #d1fae5; color: #065f46; }
        .trend-chip.down { background: #fee2e2; color: #991b1b; }
        /* ── Dashboard error alert ───────────────────────────────── */
        .dash-error { border-left: 4px solid var(--bs-danger); }
    </style>
</head>
<body>
<%
    /* ── Data from servlet ───────────────────────────────────────── */
    Integer totalProducts     = (Integer) request.getAttribute("totalProducts");
    Integer productsThisMonth = (Integer) request.getAttribute("productsThisMonth");
    Integer totalOrders       = (Integer) request.getAttribute("totalOrders");
    Integer ordersThisMonth   = (Integer) request.getAttribute("ordersThisMonth");
    BigDecimal totalRevenue   = (BigDecimal) request.getAttribute("totalRevenue");
    BigDecimal revenueMonth   = (BigDecimal) request.getAttribute("revenueThisMonth");
    Integer totalUsers        = (Integer) request.getAttribute("totalUsers");
    Integer usersThisMonth    = (Integer) request.getAttribute("usersThisMonth");
    Integer currentYear       = (Integer) request.getAttribute("currentYear");
    String dashboardError     = (String)  request.getAttribute("dashboardError");

    // Null-safe defaults
    if (totalProducts     == null) totalProducts     = 0;
    if (productsThisMonth == null) productsThisMonth = 0;
    if (totalOrders       == null) totalOrders       = 0;
    if (ordersThisMonth   == null) ordersThisMonth   = 0;
    if (totalRevenue      == null) totalRevenue      = BigDecimal.ZERO;
    if (revenueMonth      == null) revenueMonth      = BigDecimal.ZERO;
    if (totalUsers        == null) totalUsers        = 0;
    if (usersThisMonth    == null) usersThisMonth    = 0;
    if (currentYear       == null) currentYear       = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);

    // JSON for Chart.js (serialised in servlet)
    String monthlyRevenueJson = (String) request.getAttribute("monthlyRevenueJson");
    String monthlySalesJson   = (String) request.getAttribute("monthlySalesJson");
    String inventoryJson      = (String) request.getAttribute("inventoryStatusJson");
    if (monthlyRevenueJson == null) monthlyRevenueJson = "[0,0,0,0,0,0,0,0,0,0,0,0]";
    if (monthlySalesJson   == null) monthlySalesJson   = "[]";
    if (inventoryJson      == null) inventoryJson      = "{\"in_stock\":0,\"low_stock\":0,\"out_of_stock\":0}";

    @SuppressWarnings("unchecked")
    Map<String, Integer> inventoryStatus = (Map<String, Integer>) request.getAttribute("inventoryStatus");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> recentOrders = (List<Map<String, Object>>) request.getAttribute("recentOrders");

    // Formatters
    NumberFormat currencyFmt = NumberFormat.getCurrencyInstance(Locale.US);
    SimpleDateFormat sdf = new SimpleDateFormat("MMM d, yyyy");

    // Avatar colours
    String[] avatarColors = {
        "#0d6efd","#198754","#dc3545","#fd7e14",
        "#6f42c1","#0dcaf0","#20c997","#ffc107"
    };
%>

<jsp:include page="../components/sidebar.jsp" />
<jsp:include page="../components/notification.jsp" />

<div class="admin-layout">
    <div class="admin-main" id="adminMain">

        <!-- ── Topbar ──────────────────────────────────────────────── -->
        <div class="admin-topbar">
            <div class="d-flex align-items-center gap-3">
                <button class="btn btn-icon" id="sidebarToggle"><i class="fas fa-bars"></i></button>
                <div class="admin-search d-none d-md-block">
                    <i class="fas fa-search"></i>
                    <input type="text" class="form-control" placeholder="Search dashboard...">
                </div>
            </div>
            <div class="d-flex align-items-center gap-2">
                <button class="btn btn-icon" id="darkModeToggle" title="Toggle Dark Mode">
                    <i class="fas fa-moon" id="darkModeIcon"></i>
                </button>
                <div class="dropdown">
                    <button class="btn btn-icon position-relative" data-bs-toggle="dropdown">
                        <i class="fas fa-bell"></i>
                        <% if (inventoryStatus != null && inventoryStatus.getOrDefault("low_stock", 0) > 0) { %>
                        <span class="notification-badge"><%= inventoryStatus.get("low_stock") %></span>
                        <% } %>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end glass-dropdown">
                        <li class="dropdown-header">Notifications</li>
                        <% if (inventoryStatus != null && inventoryStatus.getOrDefault("low_stock", 0) > 0) { %>
                        <li>
                            <a class="dropdown-item notification-item unread" href="${pageContext.request.contextPath}/admin/inventory">
                                <div class="notification-icon bg-warning-subtle"><i class="fas fa-exclamation text-warning"></i></div>
                                <div class="notification-content">
                                    <p class="mb-0 fw-semibold">Low Stock Alert</p>
                                    <small><%= inventoryStatus.get("low_stock") %> product(s) below threshold</small>
                                </div>
                            </a>
                        </li>
                        <% } %>
                        <% if (inventoryStatus != null && inventoryStatus.getOrDefault("out_of_stock", 0) > 0) { %>
                        <li>
                            <a class="dropdown-item notification-item unread" href="${pageContext.request.contextPath}/admin/inventory">
                                <div class="notification-icon bg-danger-subtle"><i class="fas fa-times text-danger"></i></div>
                                <div class="notification-content">
                                    <p class="mb-0 fw-semibold">Out of Stock</p>
                                    <small><%= inventoryStatus.get("out_of_stock") %> product(s) out of stock</small>
                                </div>
                            </a>
                        </li>
                        <% } %>
                        <li>
                            <a class="dropdown-item notification-item" href="${pageContext.request.contextPath}/admin/orders">
                                <div class="notification-icon bg-primary-subtle"><i class="fas fa-shopping-bag text-primary"></i></div>
                                <div class="notification-content">
                                    <p class="mb-0 fw-semibold">Orders This Month</p>
                                    <small><%= ordersThisMonth %> new order(s) placed</small>
                                </div>
                            </a>
                        </li>
                    </ul>
                </div>
                <div class="dropdown">
                    <button class="btn btn-profile d-flex align-items-center gap-2" data-bs-toggle="dropdown">
                        <div class="avatar-circle">
                            <img src="https://ui-avatars.com/api/?name=${sessionScope.userName != null ? sessionScope.userName : 'Admin'}&background=0d6efd&color=fff&size=36" alt="Admin">
                        </div>
                        <span class="d-none d-md-inline fw-semibold">${sessionScope.userName != null ? sessionScope.userName : 'Admin'}</span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end glass-dropdown">
                        <li><a class="dropdown-item" href="#"><i class="fas fa-user me-2"></i> Profile</a></li>
                        <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt me-2"></i> Logout</a></li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- ── Page body ────────────────────────────────────────────── -->
        <div class="admin-content">

            <!-- Page heading -->
            <div class="mb-4">
                <h1 class="h3 fw-bold mb-1">Dashboard</h1>
                <p class="text-muted mb-0">Welcome back! Here's what's happening with your store.</p>
            </div>

            <!-- Dashboard error -->
            <% if (dashboardError != null) { %>
            <div class="alert alert-danger dash-error alert-dismissible fade show" role="alert">
                <i class="fas fa-database me-2"></i><strong>Database error:</strong> <%= dashboardError %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <!-- ── Stat Cards ──────────────────────────────────────── -->
            <div class="row g-4 mb-4">
                <!-- Total Products -->
                <div class="col-sm-6 col-xl-3">
                    <div class="dashboard-card card-primary">
                        <div class="dashboard-card-icon icon-primary"><i class="fas fa-box"></i></div>
                        <div class="dashboard-card-value" data-counter="<%= totalProducts %>">0</div>
                        <div class="dashboard-card-label">Total Products</div>
                        <% if (productsThisMonth > 0) { %>
                        <span class="dashboard-card-trend trend-up">
                            <i class="fas fa-arrow-up"></i> <%= productsThisMonth %> new this month
                        </span>
                        <% } else { %>
                        <span class="dashboard-card-trend" style="color:var(--bs-secondary);">No new products this month</span>
                        <% } %>
                    </div>
                </div>
                <!-- Total Orders -->
                <div class="col-sm-6 col-xl-3">
                    <div class="dashboard-card card-success">
                        <div class="dashboard-card-icon icon-success"><i class="fas fa-shopping-bag"></i></div>
                        <div class="dashboard-card-value" data-counter="<%= totalOrders %>">0</div>
                        <div class="dashboard-card-label">Total Orders</div>
                        <% if (ordersThisMonth > 0) { %>
                        <span class="dashboard-card-trend trend-up">
                            <i class="fas fa-arrow-up"></i> <%= ordersThisMonth %> this month
                        </span>
                        <% } else { %>
                        <span class="dashboard-card-trend" style="color:var(--bs-secondary);">No orders this month</span>
                        <% } %>
                    </div>
                </div>
                <!-- Revenue -->
                <div class="col-sm-6 col-xl-3">
                    <div class="dashboard-card card-warning">
                        <div class="dashboard-card-icon icon-warning"><i class="fas fa-dollar-sign"></i></div>
                        <div class="dashboard-card-value" data-counter="<%= totalRevenue.longValue() %>" data-format="currency">Rs. 0</div>
                        <div class="dashboard-card-label">Revenue</div>
                        <% if (revenueMonth != null && revenueMonth.compareTo(BigDecimal.ZERO) > 0) { %>
                        <span class="dashboard-card-trend trend-up">
                            <i class="fas fa-arrow-up"></i> <%= currencyFmt.format(revenueMonth) %> this month
                        </span>
                        <% } else { %>
                        <span class="dashboard-card-trend" style="color:var(--bs-secondary);">No revenue this month</span>
                        <% } %>
                    </div>
                </div>
                <!-- Active Users -->
                <div class="col-sm-6 col-xl-3">
                    <div class="dashboard-card card-info">
                        <div class="dashboard-card-icon icon-info"><i class="fas fa-users"></i></div>
                        <div class="dashboard-card-value" data-counter="<%= totalUsers %>">0</div>
                        <div class="dashboard-card-label">Active Users</div>
                        <% if (usersThisMonth > 0) { %>
                        <span class="dashboard-card-trend trend-up">
                            <i class="fas fa-arrow-up"></i> <%= usersThisMonth %> new this month
                        </span>
                        <% } else { %>
                        <span class="dashboard-card-trend" style="color:var(--bs-secondary);">No new users this month</span>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- ── Charts Row 1: Revenue + Inventory ───────────────── -->
            <div class="row g-4 mb-4">
                <!-- Revenue Line Chart -->
                <div class="col-lg-8">
                    <div class="chart-card">
                        <div class="chart-card-header">
                            <h5 class="chart-card-title">Revenue Overview</h5>
                            <select class="form-select form-select-sm" style="width:auto;"
                                    id="revenueYearSelect" onchange="loadRevenueYear(this.value)">
                                <option value="<%= currentYear %>" selected><%= currentYear %></option>
                                <option value="<%= currentYear - 1 %>"><%= currentYear - 1 %></option>
                                <option value="<%= currentYear - 2 %>"><%= currentYear - 2 %></option>
                            </select>
                        </div>
                        <div class="chart-container"><canvas id="revenueChart"></canvas></div>
                    </div>
                </div>
                <!-- Inventory Donut -->
                <div class="col-lg-4">
                    <div class="chart-card h-100">
                        <div class="chart-card-header">
                            <h5 class="chart-card-title">Inventory Status</h5>
                        </div>
                        <div class="chart-container chart-container-sm"><canvas id="inventoryChart"></canvas></div>
                        <!-- Inventory legend with real numbers -->
                        <% if (inventoryStatus != null) { %>
                        <div class="d-flex justify-content-center gap-3 mt-3 pb-2" style="font-size:.8rem;">
                            <span><span class="me-1" style="color:#198754;">●</span>In Stock: <strong><%= inventoryStatus.getOrDefault("in_stock", 0) %></strong></span>
                            <span><span class="me-1" style="color:#ffc107;">●</span>Low: <strong><%= inventoryStatus.getOrDefault("low_stock", 0) %></strong></span>
                            <span><span class="me-1" style="color:#dc3545;">●</span>Out: <strong><%= inventoryStatus.getOrDefault("out_of_stock", 0) %></strong></span>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- ── Charts Row 2: Monthly Sales + Recent Activity ─────── -->
            <div class="row g-4 mb-4">
                <!-- Monthly Sales Bar Chart -->
                <div class="col-lg-6">
                    <div class="chart-card">
                        <div class="chart-card-header">
                            <h5 class="chart-card-title">Monthly Sales</h5>
                        </div>
                        <div class="chart-container"><canvas id="salesChart"></canvas></div>
                    </div>
                </div>
                <!-- Recent Activity -->
                <div class="col-lg-6">
                    <div class="chart-card">
                        <div class="chart-card-header">
                            <h5 class="chart-card-title">Quick Stats</h5>
                        </div>
                        <div class="row g-3 p-3">
                            <!-- Mini stat tiles -->
                            <div class="col-6">
                                <div class="p-3 rounded-3 text-center" style="background:var(--bs-success-bg-subtle);">
                                    <div class="fw-bold fs-5 text-success"><%= inventoryStatus != null ? inventoryStatus.getOrDefault("in_stock",0) : 0 %></div>
                                    <div style="font-size:.75rem;color:var(--bs-secondary);">In Stock</div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="p-3 rounded-3 text-center" style="background:var(--bs-warning-bg-subtle);">
                                    <div class="fw-bold fs-5 text-warning"><%= inventoryStatus != null ? inventoryStatus.getOrDefault("low_stock",0) : 0 %></div>
                                    <div style="font-size:.75rem;color:var(--bs-secondary);">Low Stock</div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="p-3 rounded-3 text-center" style="background:var(--bs-danger-bg-subtle);">
                                    <div class="fw-bold fs-5 text-danger"><%= inventoryStatus != null ? inventoryStatus.getOrDefault("out_of_stock",0) : 0 %></div>
                                    <div style="font-size:.75rem;color:var(--bs-secondary);">Out of Stock</div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="p-3 rounded-3 text-center" style="background:var(--bs-primary-bg-subtle);">
                                    <div class="fw-bold fs-5 text-primary"><%= usersThisMonth %></div>
                                    <div style="font-size:.75rem;color:var(--bs-secondary);">New Users / Month</div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="p-3 rounded-3 text-center" style="background:var(--bs-info-bg-subtle);">
                                    <div class="fw-bold fs-5 text-info"><%= ordersThisMonth %></div>
                                    <div style="font-size:.75rem;color:var(--bs-secondary);">Orders / Month</div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="p-3 rounded-3 text-center" style="background:var(--bs-success-bg-subtle);">
                                    <div class="fw-bold" style="font-size:1.1rem;color:#198754;">
                                        <%= revenueMonth != null ? "Rs. " + String.format("%,.0f", revenueMonth.doubleValue()) : "Rs. 0" %>
                                    </div>
                                    <div style="font-size:.75rem;color:var(--bs-secondary);">Revenue / Month</div>
                                </div>
                            </div>
                        </div>
                        <div class="px-3 pb-3 d-flex gap-2 flex-wrap">
                            <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-sm btn-outline-primary">
                                <i class="fas fa-shopping-bag me-1"></i>View Orders
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-sm btn-outline-info">
                                <i class="fas fa-users me-1"></i>View Users
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/inventory" class="btn btn-sm btn-outline-warning">
                                <i class="fas fa-warehouse me-1"></i>Inventory
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ── Recent Orders Table ─────────────────────────────────── -->
            <div class="table-card">
                <div class="table-card-header">
                    <h5 class="table-card-title">Recent Orders</h5>
                    <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-sm btn-primary">View All</a>
                </div>
                <div class="table-responsive">
                    <table class="table data-table">
                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>Customer</th>
                                <th>Products</th>
                                <th>Total</th>
                                <th>Status</th>
                                <th>Date</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                        if (recentOrders == null || recentOrders.isEmpty()) {
                        %>
                        <tr>
                            <td colspan="6" class="text-center text-muted py-4">
                                <i class="fas fa-inbox me-2"></i>No orders yet.
                            </td>
                        </tr>
                        <%
                        } else {
                            int rowIdx = 0;
                            for (Map<String, Object> ord : recentOrders) {
                                int orderId       = ord.get("orderId") != null    ? (int) ord.get("orderId")    : 0;
                                String custName   = ord.get("customerName") != null ? (String) ord.get("customerName") : "Unknown";
                                int itemCount     = ord.get("itemCount") != null   ? (int) ord.get("itemCount")   : 0;
                                BigDecimal total  = ord.get("totalAmount") != null ? (BigDecimal) ord.get("totalAmount") : BigDecimal.ZERO;
                                String status     = ord.get("statusName") != null  ? (String) ord.get("statusName")  : "—";
                                java.sql.Timestamp oDate = (java.sql.Timestamp) ord.get("orderDate");

                                // Avatar initials
                                String initials = "";
                                String[] parts = custName.trim().split("\\s+");
                                if (parts.length > 0) initials += parts[0].substring(0, 1);
                                if (parts.length > 1) initials += parts[parts.length - 1].substring(0, 1);
                                String avatarColor = avatarColors[Math.abs(orderId) % avatarColors.length];

                                // Status badge class
                                String statusLower = status.toLowerCase();
                                String badgeClass = "status-pending";
                                if (statusLower.contains("deliver")) badgeClass = "status-delivered";
                                else if (statusLower.contains("ship"))    badgeClass = "status-shipped";
                                else if (statusLower.contains("cancel"))  badgeClass = "status-cancelled";
                                else if (statusLower.contains("process")) badgeClass = "status-processing";
                        %>
                        <tr>
                            <td class="fw-semibold">#TM-<%= currentYear %>-<%= orderId %></td>
                            <td>
                                <div class="table-user">
                                    <div class="order-avatar" style="background:<%= avatarColor %>"><%= initials %></div>
                                    <span class="ms-2"><%= custName %></span>
                                </div>
                            </td>
                            <td><%= itemCount %> <%= itemCount == 1 ? "item" : "items" %></td>
                            <td class="fw-semibold"><%= currencyFmt.format(total) %></td>
                            <td><span class="status-badge <%= badgeClass %>"><%= status %></span></td>
                            <td><%= oDate != null ? sdf.format(oDate) : "—" %></td>
                        </tr>
                        <%
                                rowIdx++;
                            }
                        }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div><!-- /admin-content -->
    </div><!-- /admin-main -->
</div><!-- /admin-layout -->

<!-- ── Scripts ──────────────────────────────────────────────────── -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
<script>
/* ════════════════════════════════════════════════════════════
   Dashboard Charts — driven by JSON from AdminDashboardServlet
═════════════════════════════════════════════════════════════ */
const CONTEXT_PATH = document.querySelector('meta[name="context-path"]').content;

// ── Shared Chart.js defaults ─────────────────────────────────
Chart.defaults.font.family = "'Inter', 'Segoe UI', sans-serif";
Chart.defaults.color = '#6c757d';

// ── Data from server ─────────────────────────────────────────
const monthlyRevenue = <%= monthlyRevenueJson %>;        // 12 values
const monthlySalesData = <%= monthlySalesJson %>;         // [{month,orderCount,salesTotal},…]
const inventoryData  = <%= inventoryJson %>;              // {in_stock,low_stock,out_of_stock}

const MONTHS = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

/* ── 1. Revenue Line Chart ───────────────────────────────────── */
const revenueCtx = document.getElementById('revenueChart').getContext('2d');
const revenueGrad = revenueCtx.createLinearGradient(0, 0, 0, 300);
revenueGrad.addColorStop(0,   'rgba(13,110,253,.25)');
revenueGrad.addColorStop(1,   'rgba(13,110,253,.0)');

let revenueChart = new Chart(revenueCtx, {
    type: 'line',
    data: {
        labels: MONTHS,
        datasets: [{
            label: 'Revenue (Rs.)',
            data: monthlyRevenue.map(v => parseFloat(v) || 0),
            borderColor: '#0d6efd',
            backgroundColor: revenueGrad,
            borderWidth: 2.5,
            pointRadius: 4,
            pointBackgroundColor: '#0d6efd',
            pointHoverRadius: 6,
            fill: true,
            tension: 0.4
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
            legend: { display: false },
            tooltip: {
                callbacks: {
                    label: ctx => ' Rs. ' + ctx.parsed.y.toLocaleString('en-US', {minimumFractionDigits: 2})
                }
            }
        },
        scales: {
            y: {
                beginAtZero: true,
                grid: { color: 'rgba(0,0,0,.05)' },
                ticks: {
                    callback: v => 'Rs. ' + (v >= 1000 ? (v/1000).toFixed(0) + 'k' : v)
                }
            },
            x: { grid: { display: false } }
        }
    }
});

/* ── 2. Inventory Donut ──────────────────────────────────────── */
new Chart(document.getElementById('inventoryChart'), {
    type: 'doughnut',
    data: {
        labels: ['In Stock', 'Low Stock', 'Out of Stock'],
        datasets: [{
            data: [
                inventoryData.in_stock    || 0,
                inventoryData.low_stock   || 0,
                inventoryData.out_of_stock|| 0
            ],
            backgroundColor: ['#198754','#ffc107','#dc3545'],
            hoverOffset: 8,
            borderWidth: 3,
            borderColor: '#fff'
        }]
    },
    options: {
        responsive: true,
        cutout: '68%',
        plugins: {
            legend: {
                position: 'bottom',
                labels: { boxWidth: 12, padding: 16 }
            }
        }
    }
});

/* ── 3. Monthly Sales Bar Chart ──────────────────────────────── */
(function buildSalesChart() {
    const labels      = monthlySalesData.map(d => d.month);
    const orderCounts = monthlySalesData.map(d => d.orderCount);
    const salesTotals = monthlySalesData.map(d => parseFloat(d.salesTotal) || 0);

    new Chart(document.getElementById('salesChart'), {
        type: 'bar',
        data: {
            labels,
            datasets: [
                {
                    label: 'Sales (Rs.)',
                    data: salesTotals,
                    backgroundColor: 'rgba(13,110,253,.75)',
                    borderRadius: 6,
                    yAxisID: 'y'
                },
                {
                    label: 'Orders',
                    data: orderCounts,
                    backgroundColor: 'rgba(13,202,240,.65)',
                    borderRadius: 6,
                    yAxisID: 'y1'
                }
            ]
        },
        options: {
            responsive: true,
            interaction: { mode: 'index', intersect: false },
            plugins: {
                legend: { position: 'top', labels: { boxWidth: 12, padding: 16 } },
                tooltip: {
                    callbacks: {
                        label: ctx => ctx.dataset.yAxisID === 'y'
                            ? ' Rs. ' + ctx.parsed.y.toLocaleString()
                            : ' ' + ctx.parsed.y + ' orders'
                    }
                }
            },
            scales: {
                y:  { position:'left',  beginAtZero:true, grid:{ color:'rgba(0,0,0,.05)' },
                      ticks:{ callback: v => 'Rs. '+(v>=1000?(v/1000).toFixed(0)+'k':v) } },
                y1: { position:'right', beginAtZero:true, grid:{ drawOnChartArea:false },
                      ticks:{ stepSize:1 } },
                x:  { grid:{ display:false } }
            }
        }
    });
})();

/* ── Revenue year switcher (AJAX) ───────────────────────────── */
function loadRevenueYear(year) {
    fetch(CONTEXT_PATH + '/admin/dashboard?api=chartData&year=' + year)
        .then(r => r.json())
        .then(data => {
            revenueChart.data.datasets[0].data = data.revenue.map(v => parseFloat(v) || 0);
            revenueChart.update();
        })
        .catch(err => console.error('[Dashboard] Revenue chart update failed:', err));
}
</script>
</body>
</html>
