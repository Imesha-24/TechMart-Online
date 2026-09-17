<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- Toast Notification Container -->
<div class="toast-container position-fixed top-0 end-0 p-3" id="toastContainer" style="z-index: 11000;"></div>

<!-- Loading Spinner Overlay -->
<div class="loading-overlay" id="loadingOverlay">
    <div class="loading-spinner">
        <div class="spinner-ring"></div>
        <p class="loading-text">Loading...</p>
    </div>
</div>

<!-- Quick View Product Modal -->
<div class="modal fade" id="quickViewModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content glass-card border-0">
            <div class="modal-header border-0">
                <h5 class="modal-title fw-bold" id="quickViewTitle">Product Name</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="row g-4">
                    <div class="col-md-6">
                        <div class="quick-view-image">
                            <img src="" alt="Product" id="quickViewImage" class="img-fluid rounded-3">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="quick-view-details">
                            <span class="badge bg-primary mb-2" id="quickViewCategory">Category</span>
                            <div class="product-rating mb-2" id="quickViewRating"></div>
                            <h3 class="product-price mb-3" id="quickViewPrice">Rs. 0.00</h3>
                            <p class="text-muted" id="quickViewDescription">Product description goes here.</p>
                            <div class="stock-status mb-3" id="quickViewStock"></div>
                            <div class="d-flex gap-2 align-items-center mb-3">
                                <label class="fw-semibold">Qty:</label>
                                <div class="quantity-selector">
                                    <button class="btn btn-qty" onclick="TechMart.changeQty('quickViewQty', -1)"><i class="fas fa-minus"></i></button>
                                    <input type="number" class="form-control qty-input" id="quickViewQty" value="1" min="1" max="99">
                                    <button class="btn btn-qty" onclick="TechMart.changeQty('quickViewQty', 1)"><i class="fas fa-plus"></i></button>
                                </div>
                            </div>
                            <div class="d-flex gap-2">
                                <button class="btn btn-primary flex-grow-1" id="quickViewAddCart">
                                    <i class="fas fa-cart-plus me-2"></i>Add to Cart
                                </button>
                                <a href="#" class="btn btn-outline-primary" id="quickViewDetails" title="View Details">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <a href="#" class="btn btn-outline-info d-none" id="quickViewOfficial" target="_blank" title="Official Page">
                                    <i class="fas fa-external-link-alt"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
