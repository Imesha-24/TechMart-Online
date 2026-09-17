<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<aside class="admin-sidebar" id="adminSidebar">
    <div class="sidebar-header">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="sidebar-brand">
            <span class="brand-icon"><i class="fas fa-microchip"></i></span>
            <span class="brand-text">TechMart <span class="text-primary">Admin</span></span>
        </a>
        <button class="btn btn-icon sidebar-close d-lg-none" id="sidebarClose">
            <i class="fas fa-times"></i>
        </button>
    </div>

    <div class="sidebar-user">
        <div class="avatar-circle">
            <img src="https://ui-avatars.com/api/?name=Admin+User&background=0d6efd&color=fff&size=44" alt="Admin">
        </div>
        <div class="sidebar-user-info">
            <p class="mb-0 fw-semibold">Admin User</p>
            <small class="text-muted">Super Administrator</small>
        </div>
    </div>

    <nav class="sidebar-nav">
        <p class="sidebar-section-title">Main</p>
        <ul class="nav flex-column">
            <li class="nav-item">
                <a class="nav-link sidebar-link" href="${pageContext.request.contextPath}/admin/dashboard" data-page="dashboard">
                    <i class="fas fa-tachometer-alt"></i>
                    <span>Dashboard</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link sidebar-link" href="${pageContext.request.contextPath}/admin/products" data-page="products">
                    <i class="fas fa-box"></i>
                    <span>Products</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link sidebar-link" href="${pageContext.request.contextPath}/admin/inventory" data-page="inventory">
                    <i class="fas fa-warehouse"></i>
                    <span>Inventory</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link sidebar-link" href="${pageContext.request.contextPath}/admin/orders" data-page="orders">
                    <i class="fas fa-shopping-bag"></i>
                    <span>Orders</span>
                    <span class="sidebar-badge">12</span>
                </a>
            </li>
        </ul>

        <p class="sidebar-section-title">Management</p>
        <ul class="nav flex-column">
            <li class="nav-item">
                <a class="nav-link sidebar-link" href="${pageContext.request.contextPath}/admin/users" data-page="users">
                    <i class="fas fa-users"></i>
                    <span>Users</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link sidebar-link" href="${pageContext.request.contextPath}/admin/analytics.jsp" data-page="analytics">
                    <i class="fas fa-chart-line"></i>
                    <span>Analytics</span>
                </a>
            </li>
        </ul>

        <p class="sidebar-section-title">System</p>
        <ul class="nav flex-column">
            <li class="nav-item">
                <a class="nav-link sidebar-link" href="${pageContext.request.contextPath}/index.jsp">
                    <i class="fas fa-store"></i>
                    <span>View Store</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link sidebar-link" href="#">
                    <i class="fas fa-cog"></i>
                    <span>Settings</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link sidebar-link text-danger" href="${pageContext.request.contextPath}/login.jsp">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Logout</span>
                </a>
            </li>
        </ul>
    </nav>
</aside>
<div class="sidebar-overlay" id="sidebarOverlay"></div>
