<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="context-path" content="${pageContext.request.contextPath}">
    <title>
        <c:choose>
            <c:when test="${not empty product}">
                ${product.productName} - TechMart Online
            </c:when>
            <c:otherwise>
                Product Details - TechMart Online
            </c:otherwise>
        </c:choose>
    </title>
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
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/products">Products</a></li>
                        <li class="breadcrumb-item active" id="breadcrumbName">
                            <c:choose>
                                <c:when test="${not empty product}">${product.productName}</c:when>
                                <c:otherwise>Product Details</c:otherwise>
                            </c:choose>
                        </li>
                    </ol>
                </nav>
            </div>

            <div class="row g-4 mb-5" id="productDetail">
                <c:choose>
                    <c:when test="${not empty product}">
                        <div class="col-lg-6">
                            <div class="product-detail-image">
                                <img src="${product.imageUrl}" alt="${product.productName}" id="mainProductImage"
                                     onerror="this.onerror=null;this.src='https://via.placeholder.com/400x400?text=No+Image'">
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="product-detail-info">
                                <span class="badge bg-primary mb-2">${product.categoryName}</span>
                                <h1 class="h2 fw-bold mb-2">${product.productName}</h1>
                                
                                <div class="product-rating mb-3 fs-5">
                                    <c:forEach var="i" begin="1" end="5">
                                        <c:choose>
                                            <c:when test="${i <= product.rating}">
                                                <i class="fas fa-star text-warning"></i>
                                            </c:when>
                                            <c:when test="${i - 0.5 <= product.rating}">
                                                <i class="fas fa-star-half-alt text-warning"></i>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="far fa-star text-warning"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                    <span class="rating-count fs-6">(${product.reviews} reviews)</span>
                                </div>

                                <div class="product-price mb-3" style="font-size:2rem;">
                                    Rs. <fmt:formatNumber value="${product.price}" type="number" minFractionDigits="2" maxFractionDigits="2" />
                                    <c:if test="${product.oldPrice > 0}">
                                        <span class="old-price fs-5">Rs. <fmt:formatNumber value="${product.oldPrice}" type="number" minFractionDigits="2" maxFractionDigits="2" /></span>
                                    </c:if>
                                </div>
                                <p class="text-muted mb-4">${product.description}</p>
                                
                                <c:choose>
                                    <c:when test="${product.stockQuantity > 10}">
                                        <span class="stock-status stock-in fs-6"><i class="fas fa-check-circle"></i> In Stock (${product.stockQuantity} available)</span>
                                    </c:when>
                                    <c:when test="${product.stockQuantity > 0}">
                                        <span class="stock-status stock-low fs-6"><i class="fas fa-exclamation-circle"></i> Low Stock (${product.stockQuantity} left)</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="stock-status stock-out fs-6"><i class="fas fa-times-circle"></i> Out of Stock</span>
                                    </c:otherwise>
                                </c:choose>

                                <div class="d-flex align-items-center gap-3 my-4">
                                    <label class="fw-semibold">Quantity:</label>
                                    <div class="quantity-selector">
                                        <button class="btn btn-qty" onclick="TechMart.changeQty('productQty', -1)"><i class="fas fa-minus"></i></button>
                                        <input type="number" class="form-control qty-input" id="productQty" value="1" min="1" max="99">
                                        <button class="btn btn-qty" onclick="TechMart.changeQty('productQty', 1)"><i class="fas fa-plus"></i></button>
                                    </div>
                                </div>

                                <div class="d-flex gap-3 flex-wrap mb-4">
                                    <button class="btn btn-primary btn-lg flex-grow-1" data-add-cart="${product.productId}" <c:if test="${product.stockQuantity == 0}">disabled</c:if>>
                                        <i class="fas fa-cart-plus me-2"></i>Add to Cart
                                    </button>
                                    <button class="btn btn-outline-primary btn-lg"><i class="fas fa-heart"></i></button>
                                    <button class="btn btn-outline-primary btn-lg"><i class="fas fa-share-alt"></i></button>
                                    <c:if test="${not empty product.productUrl}">
                                        <a href="${product.productUrl}" target="_blank" class="btn btn-outline-info btn-lg flex-grow-1"><i class="fas fa-external-link-alt me-2"></i>Official Page</a>
                                    </c:if>
                                </div>

                                <ul class="spec-list mt-4">
                                    <li><span class="text-muted">SKU</span><span>TM-<fmt:formatNumber value="${product.productId}" pattern="00000" /></span></li>
                                    <li><span class="text-muted">Category</span><span>${product.categoryName}</span></li>
                                    <li><span class="text-muted">Brand</span><span>${product.brandName}</span></li>
                                    <li><span class="text-muted">Color</span><span>${product.colorName}</span></li>
                                    <li><span class="text-muted">Rating</span><span>${product.rating} / 5.0</span></li>
                                    <li><span class="text-muted">Warranty</span><span>1 Year Manufacturer</span></li>
                                    <li><span class="text-muted">Shipping</span><span>Free on orders over Rs. 100</span></li>
                                </ul>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="col-12 text-center py-5">
                            <i class="fas fa-box-open fa-4x text-muted mb-3"></i>
                            <h3>Product not found</h3>
                            <p class="text-muted">${error != null ? error : "The product you are looking for does not exist or has been removed."}</p>
                            <a href="${pageContext.request.contextPath}/products" class="btn btn-primary mt-3">Browse Products</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Related Products -->
            <c:if test="${not empty relatedProducts}">
                <section>
                    <h2 class="section-title">Related Products</h2>
                    <p class="section-subtitle">You might also be interested in</p>
                    <div class="row g-4" id="relatedProducts">
                        <c:forEach var="relProduct" items="${relatedProducts}">
                            <div class="col-md-6 col-lg-3">
                                <div class="product-card">
                                    <div class="product-image-wrapper">
                                        <img src="${relProduct.imageUrl}" alt="${relProduct.productName}">
                                    </div>
                                    <div class="product-body">
                                        <span class="product-category">${relProduct.categoryName}</span>
                                        <h5 class="product-title">${relProduct.productName}</h5>
                                        <div class="product-price">Rs. <fmt:formatNumber value="${relProduct.price}" type="number" minFractionDigits="2" maxFractionDigits="2" /></div>
                                    </div>
                                    <div class="product-footer">
                                        <a href="${pageContext.request.contextPath}/product-details?id=${relProduct.productId}" class="btn btn-outline-primary w-100">View Details</a>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </section>
            </c:if>
        </div>
    </main>

    <jsp:include page="components/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/cart.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            TechMartCart.initAddToCartButtons();
        });
    </script>
</body>
</html>
