<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="lk.iu.model.User" %>
<%@ page import="lk.iu.service.NotificationService" %>
<%@ page import="lk.iu.service.NotificationServiceImpl" %>
<%
    int notificationCount = 0;
    if (session.getAttribute("user") != null) {
        User currentUser = (User) session.getAttribute("user");
        NotificationService notifService = new NotificationServiceImpl();
        try {
            notificationCount = notifService.getNotificationCountByUserId(currentUser.getUserId());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    request.setAttribute("notificationCount", notificationCount);
%>
<nav class="navbar navbar-expand-lg navbar-glass" id="mainNavbar">
    <div class="container-fluid px-4">
        <a class="navbar-brand d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/index.jsp">
            <span class="brand-icon"><i class="fas fa-microchip"></i></span>
            <span class="brand-text">TechMart <span class="text-primary">Online</span></span>
        </a>

        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
            <i class="fas fa-bars text-primary"></i>
        </button>

        <div class="collapse navbar-collapse" id="navbarContent">
            <ul class="navbar-nav mx-auto gap-1">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/index.jsp"><i class="fas fa-home me-1"></i> Home</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/products"><i class="fas fa-th-large me-1"></i> Products</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/orders.jsp"><i class="fas fa-box me-1"></i> Orders</a>
                </li>
            </ul>

            <div class="d-flex align-items-center gap-2 navbar-actions">
                <!-- Dark Mode Toggle -->
                <button class="btn btn-icon" id="darkModeToggle" title="Toggle Dark Mode" aria-label="Toggle Dark Mode">
                    <i class="fas fa-moon" id="darkModeIcon"></i>
                </button>

                <!-- Notifications -->
                <a href="${pageContext.request.contextPath}/notifications" class="btn btn-icon position-relative" title="Notifications">
                    <i class="fas fa-bell"></i>
                    <c:if test="${notificationCount > 0}">
                        <span class="notification-badge">${notificationCount}</span>
                    </c:if>
                </a>

                <!-- Cart -->
                <a href="${pageContext.request.contextPath}/cart.jsp" class="btn btn-icon position-relative" title="Shopping Cart">
                    <i class="fas fa-shopping-cart"></i>
                    <span class="cart-badge" id="cartBadge">0</span>
                </a>

                <!-- User Profile / Login -->
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <div class="dropdown">
                            <button class="btn btn-profile d-flex align-items-center gap-2" data-bs-toggle="dropdown">
                                <div class="avatar-circle">
                                    <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName}&background=0d6efd&color=fff&size=36" alt="User" class="avatar-img">
                                </div>
                                <span class="d-none d-md-inline fw-semibold">${sessionScope.user.fullName}</span>
                                <i class="fas fa-chevron-down small"></i>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end glass-dropdown">
                                <li class="dropdown-header">
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="avatar-circle">
                                            <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName}&background=0d6efd&color=fff&size=40" alt="User">
                                        </div>
                                        <div>
                                            <p class="mb-0 fw-semibold">${sessionScope.user.fullName}</p>
                                            <small class="text-muted">${sessionScope.user.email}</small>
                                        </div>
                                    </div>
                                </li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/orders.jsp"><i class="fas fa-box me-2"></i> My Orders</a></li>
                                <li><a class="dropdown-item" href="#"><i class="fas fa-user me-2"></i> Profile</a></li>
                                <li><a class="dropdown-item" href="#"><i class="fas fa-cog me-2"></i> Settings</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt me-2"></i> Logout</a></li>
                            </ul>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-primary ms-2">Sign In</a>
                        <a href="${pageContext.request.contextPath}/register" class="btn btn-primary">Sign Up</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>
