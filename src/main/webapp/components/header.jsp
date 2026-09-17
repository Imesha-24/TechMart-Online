<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String headerMode = request.getParameter("mode");
    if (headerMode == null) headerMode = "full";
    pageContext.setAttribute("headerMode", headerMode);
%>
<header class="site-header" id="siteHeader">
    <% if ("full".equals(headerMode)) { %>
    <!-- Top Bar -->
    <div class="header-topbar">
        <div class="container-fluid px-4">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                <div class="header-topbar-left d-flex align-items-center gap-3 flex-wrap">
                    <a href="tel:+18008382786" class="header-topbar-link">
                        <i class="fas fa-phone-alt me-1"></i> 1-800-TECH-MART
                    </a>
                    <a href="mailto:support@techmart.com" class="header-topbar-link d-none d-sm-inline">
                        <i class="fas fa-envelope me-1"></i> support@techmart.com
                    </a>
                    <span class="header-topbar-promo d-none d-md-inline">
                        <i class="fas fa-truck me-1"></i> Free shipping on orders over Rs. 100
                    </span>
                </div>
                <div class="header-topbar-right d-flex align-items-center gap-3">
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="header-topbar-link">
                        <i class="fas fa-user-shield me-1"></i> Admin
                    </a>
                    <a href="${pageContext.request.contextPath}/login.jsp" class="header-topbar-link">
                        <i class="fas fa-sign-in-alt me-1"></i> Login
                    </a>
                    <a href="${pageContext.request.contextPath}/register.jsp" class="header-topbar-link fw-semibold">
                        <i class="fas fa-user-plus me-1"></i> Register
                    </a>
                </div>
            </div>
        </div>
    </div>
    <% } %>

    <% if ("minimal".equals(headerMode)) { %>
    <!-- Minimal Header (auth pages) -->
    <div class="header-minimal navbar-glass">
        <div class="container-fluid px-4 py-3 d-flex justify-content-between align-items-center">
            <a class="navbar-brand d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/index.jsp">
                <span class="brand-icon"><i class="fas fa-microchip"></i></span>
                <span class="brand-text">TechMart <span class="text-primary">Online</span></span>
            </a>
            <div class="d-flex align-items-center gap-2">
                <button class="btn btn-icon" id="darkModeToggle" title="Toggle Dark Mode" aria-label="Toggle Dark Mode">
                    <i class="fas fa-moon" id="darkModeIcon"></i>
                </button>
                <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-outline-primary btn-sm">
                    <i class="fas fa-home me-1"></i> Back to Store
                </a>
            </div>
        </div>
    </div>
    <% } else { %>
    <!-- Main Navigation -->
    <jsp:include page="navbar.jsp" />
    <% } %>
</header>
