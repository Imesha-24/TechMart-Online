<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="context-path" content="${pageContext.request.contextPath}">
    <title>Analytics - TechMart Online</title>
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
                    <h5 class="mb-0 fw-bold d-none d-md-block">Analytics</h5>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <button class="btn btn-icon" id="darkModeToggle"><i class="fas fa-moon" id="darkModeIcon"></i></button>
                    <select class="form-select form-select-sm" style="width:auto;">
                        <option>Last 30 Days</option>
                        <option>Last 90 Days</option>
                        <option>This Year</option>
                        <option>All Time</option>
                    </select>
                    <button class="btn btn-outline-primary btn-sm"><i class="fas fa-download me-1"></i> Report</button>
                </div>
            </div>

            <div class="admin-content">
                <div class="mb-4">
                    <h1 class="h3 fw-bold mb-1">Analytics Dashboard</h1>
                    <p class="text-muted mb-0">Deep insights into your store performance</p>
                </div>

                <!-- Key Metrics -->
                <div class="row g-4 mb-4">
                    <div class="col-6 col-lg-3">
                        <div class="chart-card analytics-metric">
                            <div class="analytics-metric-value" data-counter="28450" data-format="number">0</div>
                            <div class="analytics-metric-label">Total Visitors</div>
                            <div class="metric-change trend-up"><i class="fas fa-arrow-up"></i> 12.5%</div>
                        </div>
                    </div>
                    <div class="col-6 col-lg-3">
                        <div class="chart-card analytics-metric">
                            <div class="analytics-metric-value" data-counter="4" data-format="percent">0</div>
                            <div class="analytics-metric-label">Conversion Rate</div>
                            <div class="metric-change trend-up"><i class="fas fa-arrow-up"></i> 0.8%</div>
                        </div>
                    </div>
                    <div class="col-6 col-lg-3">
                        <div class="chart-card analytics-metric">
                            <div class="analytics-metric-value" data-counter="369" data-format="currency">Rs. 0</div>
                            <div class="analytics-metric-label">Avg. Order Value</div>
                            <div class="metric-change trend-up"><i class="fas fa-arrow-up"></i> 5.2%</div>
                        </div>
                    </div>
                    <div class="col-6 col-lg-3">
                        <div class="chart-card analytics-metric">
                            <div class="analytics-metric-value" data-counter="32" data-format="percent">0</div>
                            <div class="analytics-metric-label">Bounce Rate</div>
                            <div class="metric-change trend-down"><i class="fas fa-arrow-down"></i> 3.1%</div>
                        </div>
                    </div>
                </div>

                <!-- Traffic Chart -->
                <div class="row g-4 mb-4">
                    <div class="col-lg-8">
                        <div class="chart-card">
                            <div class="chart-card-header">
                                <h5 class="chart-card-title">Website Traffic</h5>
                                <div class="d-flex gap-3 small">
                                    <span><i class="fas fa-circle text-primary" style="font-size:0.5rem;"></i> Visitors</span>
                                    <span><i class="fas fa-circle text-info" style="font-size:0.5rem;"></i> Page Views</span>
                                </div>
                            </div>
                            <div class="chart-container"><canvas id="trafficChart"></canvas></div>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="chart-card">
                            <div class="chart-card-header">
                                <h5 class="chart-card-title">Sales by Category</h5>
                            </div>
                            <div class="chart-container"><canvas id="categoryChart"></canvas></div>
                        </div>
                    </div>
                </div>

                <div class="row g-4 mb-4">
                    <div class="col-lg-6">
                        <div class="chart-card">
                            <div class="chart-card-header">
                                <h5 class="chart-card-title">Conversion Rate Trend</h5>
                            </div>
                            <div class="chart-container chart-container-sm"><canvas id="conversionChart"></canvas></div>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="chart-card">
                            <div class="chart-card-header">
                                <h5 class="chart-card-title">Top Performing Products</h5>
                            </div>
                            <div class="table-responsive">
                                <table class="table data-table mb-0">
                                    <thead>
                                        <tr>
                                            <th>Product</th>
                                            <th>Sales</th>
                                            <th>Revenue</th>
                                            <th>Trend</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td><div class="d-flex align-items-center gap-2"><img src="https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=60&h=60&fit=crop" class="table-product-img" style="width:36px;height:36px;" alt=""><span class="fw-semibold">MacBook Pro 16"</span></div></td>
                                            <td>142</td><td class="fw-semibold">Rs. 354,998</td>
                                            <td><span class="trend-up small"><i class="fas fa-arrow-up"></i> 18%</span></td>
                                        </tr>
                                        <tr>
                                            <td><div class="d-flex align-items-center gap-2"><img src="https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=60&h=60&fit=crop" class="table-product-img" style="width:36px;height:36px;" alt=""><span class="fw-semibold">iPhone 15 Pro Max</span></div></td>
                                            <td>198</td><td class="fw-semibold">Rs. 237,598</td>
                                            <td><span class="trend-up small"><i class="fas fa-arrow-up"></i> 12%</span></td>
                                        </tr>
                                        <tr>
                                            <td><div class="d-flex align-items-center gap-2"><img src="https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=60&h=60&fit=crop" class="table-product-img" style="width:36px;height:36px;" alt=""><span class="fw-semibold">Sony WH-1000XM5</span></div></td>
                                            <td>312</td><td class="fw-semibold">Rs. 109,197</td>
                                            <td><span class="trend-up small"><i class="fas fa-arrow-up"></i> 24%</span></td>
                                        </tr>
                                        <tr>
                                            <td><div class="d-flex align-items-center gap-2"><img src="https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=60&h=60&fit=crop" class="table-product-img" style="width:36px;height:36px;" alt=""><span class="fw-semibold">Logitech MX Master 3S</span></div></td>
                                            <td>456</td><td class="fw-semibold">Rs. 45,595</td>
                                            <td><span class="trend-up small"><i class="fas fa-arrow-up"></i> 8%</span></td>
                                        </tr>
                                        <tr>
                                            <td><div class="d-flex align-items-center gap-2"><img src="https://images.unsplash.com/photo-1593642632823-8f785ba67dcc?w=60&h=60&fit=crop" class="table-product-img" style="width:36px;height:36px;" alt=""><span class="fw-semibold">Dell XPS 15 OLED</span></div></td>
                                            <td>89</td><td class="fw-semibold">Rs. 169,099</td>
                                            <td><span class="trend-down small"><i class="fas fa-arrow-down"></i> 3%</span></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
</body>
</html>
