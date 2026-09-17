<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="context-path" content="${pageContext.request.contextPath}">
    <title>Shopping Cart - TechMart Online</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/responsive.css" rel="stylesheet">
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
                        <li class="breadcrumb-item active">Shopping Cart</li>
                    </ol>
                </nav>
                <h1><i class="fas fa-shopping-cart text-primary me-2"></i>Shopping Cart</h1>
            </div>

            <div class="row g-4">
                <div class="col-lg-8">
                    <div id="cartItems"></div>

                    <div id="cartEmpty" class="glass-card text-center p-5" style="display:none;">
                        <i class="fas fa-shopping-cart fa-3x text-muted mb-3"></i>
                        <h4>Your cart is empty</h4>
                        <p class="text-muted mb-4">Looks like you haven't added any products yet.</p>
                        <a href="${pageContext.request.contextPath}/products" class="btn btn-primary btn-lg">
                            <i class="fas fa-shopping-bag me-2"></i>Continue Shopping
                        </a>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="cart-summary" id="cartSummary" style="display:none;">
                        <h5 class="fw-bold mb-4">Order Summary</h5>
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">Subtotal</span>
                            <span class="fw-semibold" id="cartSubtotal">Rs. 0.00</span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">Shipping</span>
                            <span class="fw-semibold" id="cartShipping">Rs. 0.00</span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">Tax (8%)</span>
                            <span class="fw-semibold" id="cartTax">Rs. 0.00</span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between mb-4">
                            <span class="fw-bold fs-5">Total</span>
                            <span class="fw-bold fs-5 text-primary" id="cartTotal">Rs. 0.00</span>
                        </div>
                        <button class="btn btn-primary w-100 btn-lg mb-3" id="checkoutBtn">
                            <i class="fas fa-lock me-2"></i>Proceed to Checkout
                        </button>
                        <a href="${pageContext.request.contextPath}/products" class="btn btn-outline-primary w-100">
                            <i class="fas fa-arrow-left me-2"></i>Continue Shopping
                        </a>
                        <div class="mt-3 p-3 rounded-3" style="background:rgba(13,110,253,0.05);">
                            <small class="text-muted"><i class="fas fa-truck text-primary me-1"></i> Free shipping on orders over Rs. 100</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="components/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/cart.js"></script>
</body>
</html>
