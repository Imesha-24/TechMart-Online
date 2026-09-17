<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="context-path" content="${pageContext.request.contextPath}">
    <title>Notifications - TechMart Online</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/responsive.css" rel="stylesheet">
    <style>
        .notification-card {
            border-left: 4px solid var(--primary-color);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .notification-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 .5rem 1rem rgba(0,0,0,.15)!important;
        }
        .notification-icon-large {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }
        .type-order { background-color: var(--bs-primary-bg-subtle); color: var(--bs-primary); border-left-color: var(--bs-primary); }
        .type-payment { background-color: var(--bs-warning-bg-subtle); color: var(--bs-warning); border-left-color: var(--bs-warning); }
        .type-system { background-color: var(--bs-info-bg-subtle); color: var(--bs-info); border-left-color: var(--bs-info); }
        .type-promotion { background-color: var(--bs-success-bg-subtle); color: var(--bs-success); border-left-color: var(--bs-success); }
    </style>
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
                        <li class="breadcrumb-item active">Notifications</li>
                    </ol>
                </nav>
                <h1><i class="fas fa-bell text-primary me-2"></i>Notifications</h1>
                <p class="text-muted">Stay updated with your latest alerts and offers</p>
            </div>

            <c:choose>
                <c:when test="${empty notifications}">
                    <div class="glass-card text-center p-5 mt-4">
                        <i class="fas fa-bell-slash fa-3x text-muted mb-3"></i>
                        <h4>No Notifications Found</h4>
                        <p class="text-muted mb-4">You're all caught up! Check back later for updates.</p>
                        <a href="${pageContext.request.contextPath}/products" class="btn btn-primary">
                            <i class="fas fa-shopping-bag me-2"></i>Continue Shopping
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="row g-4 mt-2">
                        <c:forEach var="notif" items="${notifications}">
                            <div class="col-12">
                                <c:set var="typeClass" value="type-system" />
                                <c:set var="iconClass" value="fa-info-circle" />
                                
                                <c:choose>
                                    <c:when test="${notif.notificationType == 'ORDER'}">
                                        <c:set var="typeClass" value="type-order" />
                                        <c:set var="iconClass" value="fa-box" />
                                    </c:when>
                                    <c:when test="${notif.notificationType == 'PAYMENT'}">
                                        <c:set var="typeClass" value="type-payment" />
                                        <c:set var="iconClass" value="fa-money-bill-wave" />
                                    </c:when>
                                    <c:when test="${notif.notificationType == 'PROMOTION'}">
                                        <c:set var="typeClass" value="type-promotion" />
                                        <c:set var="iconClass" value="fa-tags" />
                                    </c:when>
                                </c:choose>

                                <div class="glass-card notification-card p-3 p-md-4 ${typeClass}">
                                    <div class="d-flex align-items-start gap-3">
                                        <div class="notification-icon-large flex-shrink-0 bg-white">
                                            <i class="fas ${iconClass}"></i>
                                        </div>
                                        <div class="flex-grow-1">
                                            <div class="d-flex justify-content-between align-items-center mb-1">
                                                <h5 class="mb-0 fw-bold text-dark">${notif.title}</h5>
                                                <small class="text-muted"><fmt:formatDate value="${notif.createdAt}" pattern="MMM dd, yyyy h:mm a" /></small>
                                            </div>
                                            <p class="mb-0 text-muted">${notif.message}</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

    <jsp:include page="components/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>
