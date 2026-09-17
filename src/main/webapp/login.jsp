<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="context-path" content="${pageContext.request.contextPath}">
    <title>Login - TechMart Online</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/responsive.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="components/header.jsp">
        <jsp:param name="mode" value="minimal"/>
    </jsp:include>
    <jsp:include page="components/notification.jsp" />

    <div class="auth-page">
        <div class="auth-card fade-in">
            <div class="auth-logo">
                <div class="brand-icon mx-auto mb-2" style="width:56px;height:56px;font-size:1.5rem;">
                    <i class="fas fa-microchip"></i>
                </div>
                <span class="brand-text fs-4">TechMart <span class="text-primary">Online</span></span>
            </div>
            <h1 class="auth-title">Welcome Back</h1>
            <p class="auth-subtitle">Sign in to your enterprise account</p>

            <form action="${pageContext.request.contextPath}/login" method="POST">
                <c:if test="${not empty error}">
                    <div class="alert alert-danger" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i>${error}
                    </div>
                </c:if>
                <c:if test="${param.registered == 'true'}">
                    <div class="alert alert-success" role="alert">
                        <i class="fas fa-check-circle me-2"></i>Account created successfully! Please sign in.
                    </div>
                </c:if>
                <c:if test="${param.redirect == 'true'}">
                    <div class="alert alert-warning" role="alert">
                        <i class="fas fa-info-circle me-2"></i>Please sign in to access that page.
                    </div>
                </c:if>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Email Address</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                        <input type="email" name="email" class="form-control" placeholder="john.doe@company.com" value="${email}" required>
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Password</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-lock"></i></span>
                        <input type="password" name="password" class="form-control" id="loginPassword" placeholder="Enter your password" required>
                        <button class="btn btn-outline-secondary" type="button" onclick="togglePassword('loginPassword', this)">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                </div>
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="rememberMe" checked>
                        <label class="form-check-label" for="rememberMe">Remember me</label>
                    </div>
                    <a href="#" class="text-primary small">Forgot password?</a>
                </div>
                <button type="submit" class="btn btn-primary w-100 btn-lg mb-3">
                    <i class="fas fa-sign-in-alt me-2"></i>Sign In
                </button>
                <div class="text-center">
                    <span class="text-muted">Don't have an account?</span>
                    <a href="${pageContext.request.contextPath}/register.jsp" class="text-primary fw-semibold">Create Account</a>
                </div>
            </form>

            <div class="mt-4 pt-3 border-top text-center">
                <p class="small text-muted mb-2">Or sign in as</p>
                <div class="d-flex gap-2 justify-content-center">
                    <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-outline-primary btn-sm">
                        <i class="fas fa-user me-1"></i> Customer
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-secondary btn-sm">
                        <i class="fas fa-user-shield me-1"></i> Admin
                    </a>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="components/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
    <script>
        function togglePassword(id, btn) {
            const input = document.getElementById(id);
            const icon = btn.querySelector('i');
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.replace('fa-eye', 'fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.replace('fa-eye-slash', 'fa-eye');
            }
        }
    </script>
</body>
</html>
