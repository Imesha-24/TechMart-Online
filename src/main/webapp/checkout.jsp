<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="context-path" content="${pageContext.request.contextPath}">
    <title>Checkout - TechMart Online</title>
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
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/cart.jsp">Cart</a></li>
                        <li class="breadcrumb-item active">Checkout</li>
                    </ol>
                </nav>
                <h1><i class="fas fa-credit-card text-primary me-2"></i>Checkout</h1>
            </div>

            <div class="row g-4">
                <div class="col-lg-8">
                    <!-- Shipping Form -->
                    <div class="checkout-step">
                        <div class="checkout-step-header">
                            <div class="step-number">1</div>
                            <div>
                                <h5 class="mb-0 fw-bold">Shipping Information</h5>
                                <small class="text-muted">Enter your delivery details</small>
                            </div>
                        </div>
                        <form id="shippingForm">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">First Name</label>
                                    <input type="text" class="form-control" value="John" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Last Name</label>
                                    <input type="text" class="form-control" value="Doe" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Company</label>
                                    <input type="text" class="form-control" value="TechCorp Inc.">
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Street Address</label>
                                    <input type="text" class="form-control" value="123 Enterprise Blvd, Suite 400" required>
                                </div>
                                <div class="col-md-5">
                                    <label class="form-label fw-semibold">City</label>
                                    <input type="text" class="form-control" value="San Francisco" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold">State</label>
                                    <select class="form-select" required>
                                        <option value="CA" selected>California</option>
                                        <option value="NY">New York</option>
                                        <option value="TX">Texas</option>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-semibold">ZIP Code</label>
                                    <input type="text" class="form-control" value="94105" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Phone</label>
                                    <input type="tel" class="form-control" value="+1 (555) 123-4567" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Email</label>
                                    <input type="email" class="form-control" value="john.doe@techmart.com" required>
                                </div>
                            </div>
                        </form>
                    </div>

                    <!-- Payment Form -->
                    <div class="checkout-step">
                        <div class="checkout-step-header">
                            <div class="step-number">2</div>
                            <div>
                                <h5 class="mb-0 fw-bold">Payment Method</h5>
                                <small class="text-muted">Secure payment processing</small>
                            </div>
                        </div>
                        <div class="mb-3">
                            <div class="form-check form-check-inline">
                                <input class="form-check-input" type="radio" name="paymentMethod" id="payCard" checked>
                                <label class="form-check-label" for="payCard"><i class="fas fa-credit-card me-1"></i> Credit Card</label>
                            </div>
                            <div class="form-check form-check-inline">
                                <input class="form-check-input" type="radio" name="paymentMethod" id="payPaypal">
                                <label class="form-check-label" for="payPaypal"><i class="fab fa-paypal me-1"></i> PayPal</label>
                            </div>
                            <div class="form-check form-check-inline">
                                <input class="form-check-input" type="radio" name="paymentMethod" id="payBank">
                                <label class="form-check-label" for="payBank"><i class="fas fa-university me-1"></i> Bank Transfer</label>
                            </div>
                        </div>
                        <div class="row g-3">
                            <div class="col-12">
                                <label class="form-label fw-semibold">Card Number</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-credit-card"></i></span>
                                    <input type="text" class="form-control" placeholder="1234 5678 9012 3456" value="4532 1234 5678 9012">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Expiry Date</label>
                                <input type="text" class="form-control" placeholder="MM/YY" value="12/28">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">CVV</label>
                                <input type="text" class="form-control" placeholder="123" value="456">
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-semibold">Name on Card</label>
                                <input type="text" class="form-control" value="John Doe">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Order Summary -->
                <div class="col-lg-4">
                    <div class="cart-summary">
                        <h5 class="fw-bold mb-4">Order Summary</h5>
                        <div id="checkoutItems" class="mb-3"></div>
                        <hr>
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">Subtotal</span>
                            <span class="fw-semibold" id="checkoutSubtotal">Rs. 0.00</span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">Shipping</span>
                            <span class="fw-semibold" id="checkoutShipping">Rs. 0.00</span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">Tax (8%)</span>
                            <span class="fw-semibold" id="checkoutTax">Rs. 0.00</span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between mb-4">
                            <span class="fw-bold fs-5">Total</span>
                            <span class="fw-bold fs-5 text-primary" id="checkoutTotal">Rs. 0.00</span>
                        </div>
                        <button class="btn btn-primary w-100 btn-lg" id="placeOrderBtn">
                            <i class="fas fa-check-circle me-2"></i>Place Order
                        </button>
                        <div class="text-center mt-3">
                            <small class="text-muted"><i class="fas fa-lock me-1"></i> Your payment information is secure and encrypted</small>
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
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const placeOrderBtn = document.getElementById('placeOrderBtn');
            if (placeOrderBtn) {
                placeOrderBtn.addEventListener('click', async (e) => {
                    e.preventDefault();
                    
                    const cartItemsList = TechMartCart.cartData.items || [];
                    const cartTotalValue = TechMartCart.cartData.total || 0;
                    
                    if (cartItemsList.length === 0) {
                        alert('Your cart is empty!');
                        return;
                    }
                    
                    // Simple validation for shipping form
                    const shippingForm = document.getElementById('shippingForm');
                    if (!shippingForm.checkValidity()) {
                        shippingForm.reportValidity();
                        return;
                    }
                    
                    const orderData = {
                        totalAmount: cartTotalValue,
                        cartItems: cartItemsList.map(item => ({
                            id: item.productId,
                            price: item.price,
                            quantity: item.quantity
                        }))
                    };
                    
                    placeOrderBtn.disabled = true;
                    placeOrderBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Processing...';
                    
                    try {
                        const response = await fetch('${pageContext.request.contextPath}/api/checkout', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json'
                            },
                            body: JSON.stringify(orderData)
                        });
                        
                        const result = await response.json();
                        if (response.ok && result.success) {
                            await TechMartCart.clearCart();
                            window.location.href = '${pageContext.request.contextPath}/orders';
                        } else {
                            alert(result.message || 'Error processing order');
                            placeOrderBtn.disabled = false;
                            placeOrderBtn.innerHTML = '<i class="fas fa-check-circle me-2"></i>Place Order';
                        }
                    } catch (err) {
                        console.error('Checkout error:', err);
                        alert('An unexpected error occurred. Please try again.');
                        placeOrderBtn.disabled = false;
                        placeOrderBtn.innerHTML = '<i class="fas fa-check-circle me-2"></i>Place Order';
                    }
                });
            }
        });
    </script>
</body>
</html>
