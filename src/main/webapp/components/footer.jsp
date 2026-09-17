<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<footer class="footer-section" id="siteFooter">
    <div class="container">
        <div class="row g-4">
            <div class="col-lg-4 col-md-6">
                <div class="footer-brand mb-3">
                    <span class="brand-icon"><i class="fas fa-microchip"></i></span>
                    <span class="brand-text">TechMart <span class="text-primary">Online</span></span>
                </div>
                <p class="footer-desc">Your trusted enterprise technology partner. Premium electronics, professional service, and corporate-grade solutions for businesses worldwide.</p>
                <div class="footer-contact mb-3">
                    <p class="mb-1 small"><i class="fas fa-map-marker-alt text-primary me-2"></i>123 Enterprise Blvd, San Francisco, CA 94105</p>
                    <p class="mb-1 small"><i class="fas fa-phone text-primary me-2"></i>1-800-TECH-MART</p>
                    <p class="mb-0 small"><i class="fas fa-envelope text-primary me-2"></i>support@techmart.com</p>
                </div>
                <div class="social-links d-flex gap-2">
                    <a href="#" class="social-link" aria-label="Facebook"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" class="social-link" aria-label="Twitter"><i class="fab fa-twitter"></i></a>
                    <a href="#" class="social-link" aria-label="LinkedIn"><i class="fab fa-linkedin-in"></i></a>
                    <a href="#" class="social-link" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
                </div>
            </div>
            <div class="col-lg-2 col-md-6">
                <h6 class="footer-heading">Shop</h6>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/products">All Products</a></li>
                    <li><a href="${pageContext.request.contextPath}/products?category=laptops">Laptops</a></li>
                    <li><a href="${pageContext.request.contextPath}/products?category=smartphones">Smartphones</a></li>
                    <li><a href="${pageContext.request.contextPath}/products?category=accessories">Accessories</a></li>
                    <li><a href="${pageContext.request.contextPath}/products">Deals</a></li>
                </ul>
            </div>
            <div class="col-lg-2 col-md-6">
                <h6 class="footer-heading">Account</h6>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/login.jsp">Sign In</a></li>
                    <li><a href="${pageContext.request.contextPath}/register.jsp">Register</a></li>
                    <li><a href="${pageContext.request.contextPath}/orders.jsp">My Orders</a></li>
                    <li><a href="${pageContext.request.contextPath}/cart.jsp">Shopping Cart</a></li>
                    <li><a href="#">Wishlist</a></li>
                </ul>
            </div>
            <div class="col-lg-2 col-md-6">
                <h6 class="footer-heading">Support</h6>
                <ul class="footer-links">
                    <li><a href="#">Help Center</a></li>
                    <li><a href="#">Shipping Info</a></li>
                    <li><a href="#">Returns &amp; Refunds</a></li>
                    <li><a href="#">Warranty</a></li>
                    <li><a href="#">Contact Us</a></li>
                </ul>
            </div>
            <div class="col-lg-2 col-md-6">
                <h6 class="footer-heading">Company</h6>
                <ul class="footer-links">
                    <li><a href="#">About Us</a></li>
                    <li><a href="#">Careers</a></li>
                    <li><a href="#">Enterprise Solutions</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/dashboard">Admin Portal</a></li>
                    <li><a href="#">Partners</a></li>
                </ul>
            </div>
        </div>

        <!-- Newsletter -->
        <div class="footer-newsletter glass-card mt-4 p-4">
            <div class="row align-items-center g-3">
                <div class="col-md-6">
                    <h6 class="fw-bold mb-1">Subscribe to Our Newsletter</h6>
                    <p class="small text-muted mb-0">Get exclusive deals, product launches, and enterprise updates.</p>
                </div>
                <div class="col-md-6">
                    <form class="newsletter-form d-flex gap-2" onsubmit="return false;">
                        <input type="email" class="form-control" placeholder="Enter your email address" required>
                        <button type="submit" class="btn btn-primary px-4" onclick="TechMart.showToast('Subscribed successfully!', 'success')">
                            Subscribe
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <hr class="footer-divider">

        <div class="row align-items-center">
            <div class="col-md-4">
                <p class="copyright mb-0">&copy; 2026 TechMart Online. All rights reserved.</p>
            </div>
            <div class="col-md-4 text-md-center mt-2 mt-md-0">
                <div class="footer-legal d-flex justify-content-md-center gap-3 flex-wrap">
                    <a href="#">Privacy Policy</a>
                    <a href="#">Terms of Service</a>
                    <a href="#">Cookie Policy</a>
                </div>
            </div>
            <div class="col-md-4 text-md-end mt-2 mt-md-0">
                <div class="payment-icons">
                    <i class="fab fa-cc-visa" title="Visa"></i>
                    <i class="fab fa-cc-mastercard" title="Mastercard"></i>
                    <i class="fab fa-cc-amex" title="American Express"></i>
                    <i class="fab fa-cc-paypal" title="PayPal"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Back to Top -->
    <button class="back-to-top" id="backToTop" title="Back to top" aria-label="Back to top">
        <i class="fas fa-chevron-up"></i>
    </button>
</footer>
