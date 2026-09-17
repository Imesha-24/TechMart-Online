<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="context-path" content="${pageContext.request.contextPath}">
    <title>Register - TechMart Online</title>
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
        <div class="auth-card fade-in" style="max-width:520px;">
            <div class="auth-logo">
                <div class="brand-icon mx-auto mb-2" style="width:56px;height:56px;font-size:1.5rem;">
                    <i class="fas fa-microchip"></i>
                </div>
                <span class="brand-text fs-4">TechMart <span class="text-primary">Online</span></span>
            </div>
            <h1 class="auth-title">Create Account</h1>
            <p class="auth-subtitle">Join thousands of enterprise customers</p>

            <form action="${pageContext.request.contextPath}/register" method="POST">
                <c:if test="${not empty error}">
                    <div class="alert alert-danger" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i>${error}
                    </div>
                </c:if>
                <div class="row g-3">
                    <div class="col-12">
                        <label class="form-label fw-semibold">Full Name</label>
                        <input type="text" name="fullName" class="form-control" placeholder="John Doe" value="${fullName}" required>
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Phone Number</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-phone"></i></span>
                            <input type="text" name="phone" class="form-control" placeholder="+1 (555) 000-0000" value="${phone}">
                        </div>
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Email Address</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                            <input type="email" name="email" class="form-control" placeholder="john.doe@company.com" value="${email}" required>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Password</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-lock"></i></span>
                            <input type="password" name="password" class="form-control" id="regPassword" placeholder="Min. 8 characters" required minlength="8">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Confirm Password</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-lock"></i></span>
                            <input type="password" name="confirmPassword" class="form-control" placeholder="Confirm password" required>
                        </div>
                    </div>
                    <div class="col-12">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="termsAgree" required>
                            <label class="form-check-label" for="termsAgree">
                                I agree to the <a href="#" class="text-primary">Terms of Service</a> and <a href="#" class="text-primary">Privacy Policy</a>
                            </label>
                        </div>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary w-100 btn-lg mt-4 mb-3">
                    <i class="fas fa-user-plus me-2"></i>Create Account
                </button>
                <div class="text-center">
                    <span class="text-muted">Already have an account?</span>
                    <a href="${pageContext.request.contextPath}/login.jsp" class="text-primary fw-semibold">Sign In</a>
                </div>
            </form>
        </div>
    </div>

    <jsp:include page="components/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
    <script>
        // Form validations or additional UI logic can be added here
    </script>
</body>
</html>
