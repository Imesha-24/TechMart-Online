<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="context-path" content="${pageContext.request.contextPath}">
    <title>Products - TechMart Online</title>
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
                        <li class="breadcrumb-item active">Products</li>
                    </ol>
                </nav>
                <h1>All Products</h1>
                <p class="text-muted">Browse our complete catalog of enterprise technology</p>
            </div>

            <!-- Search & Filter Bar -->
            <div class="filter-bar">
                <form action="${pageContext.request.contextPath}/products" method="GET">
                    <div class="row g-3 align-items-end">
                        <div class="col-md-5">
                            <label class="form-label fw-semibold small">Search Products</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-search"></i></span>
                                <input type="text" name="search" class="form-control" id="productSearch" placeholder="Search by name, brand, or SKU..." value="${searchQuery}">
                            </div>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold small">Category</label>
                            <select class="form-select" name="category" id="categoryFilter">
                                <option value="all" <c:if test="${selectedCategory == 'all'}">selected</c:if>>All Categories</option>
                                <option value="laptops" <c:if test="${selectedCategory == 'laptops'}">selected</c:if>>Laptops</option>
                                <option value="smartphones" <c:if test="${selectedCategory == 'smartphones'}">selected</c:if>>Smartphones</option>
                                <option value="gaming" <c:if test="${selectedCategory == 'gaming'}">selected</c:if>>Gaming</option>
                                <option value="accessories" <c:if test="${selectedCategory == 'accessories'}">selected</c:if>>Accessories</option>
                                <option value="smart home" <c:if test="${selectedCategory == 'smart home'}">selected</c:if>>Smart Home</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label fw-semibold small">Sort By</label>
                            <select class="form-select" name="sort" id="sortFilter">
                                <option value="featured" <c:if test="${selectedSort == 'featured'}">selected</c:if>>Featured</option>
                                <option value="price-low" <c:if test="${selectedSort == 'price-low'}">selected</c:if>>Price: Low to High</option>
                                <option value="price-high" <c:if test="${selectedSort == 'price-high'}">selected</c:if>>Price: High to Low</option>
                                <option value="name" <c:if test="${selectedSort == 'name'}">selected</c:if>>Name A-Z</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary w-100">
                                <i class="fas fa-filter me-1"></i> Apply
                            </button>
                        </div>
                    </div>
                </form>
            </div>

            <!-- Product Grid -->
            <div class="row g-4" id="productGrid">
                <c:if test="${empty productList}">
                    <div class="col-12 text-center py-5">
                        <h4>No products found</h4>
                        <p class="text-muted">Try adjusting your filters</p>
                    </div>
                </c:if>
                <c:forEach var="product" items="${productList}">
                    <div class="col-md-6 col-lg-3 product-item" data-category="${product.categoryName.toLowerCase()}" data-name="${product.productName.toLowerCase()}">
                        <div class="product-card">
                            <div class="product-image-wrapper">
                                <c:if test="${product.oldPrice > 0}">
                                    <span class="badge bg-danger product-badge">Sale</span>
                                </c:if>
                                <img src="${product.imageUrl}" alt="${product.productName}"
                                     onerror="this.onerror=null;this.src='https://via.placeholder.com/400x400?text=No+Image'">
                                <div class="product-actions">
                                    <button class="product-action-btn" data-quick-view='{"id":${product.productId},"name":"${product.productName}","category":"${product.categoryName}","price":${product.price},"rating":${product.rating},"reviews":${product.reviews},"stock":${product.stockQuantity},"image":"${product.imageUrl}","description":"${product.description}","productUrl":"${product.productUrl}"}'><i class="fas fa-eye"></i></button>
                                    <button class="product-action-btn" data-add-cart="${product.productId}" <c:if test="${product.stockQuantity == 0}">disabled</c:if>><i class="fas fa-cart-plus"></i></button>
                                </div>
                            </div>
                            <div class="product-body">
                                <span class="product-category">${product.categoryName}</span>
                                <h5 class="product-title">${product.productName}</h5>
                                <div class="product-rating">
                                    <!-- Simplified star rendering for JSP, actual logic could be more complex -->
                                    <i class="fas fa-star text-warning"></i> ${product.rating} <span class="rating-count">(${product.reviews})</span>
                                </div>
                                <div class="product-price">
                                    Rs.<fmt:formatNumber value="${product.price}" type="number" minFractionDigits="2" maxFractionDigits="2" />
                                    <c:if test="${product.oldPrice > 0}">
                                        <span class="old-price">$<fmt:formatNumber value="${product.oldPrice}" type="number" minFractionDigits="2" maxFractionDigits="2" /></span>
                                    </c:if>
                                </div>
                                <c:choose>
                                    <c:when test="${product.stockQuantity > 10}">
                                        <span class="stock-status stock-in"><i class="fas fa-check-circle"></i> In Stock</span>
                                    </c:when>
                                    <c:when test="${product.stockQuantity > 0}">
                                        <span class="stock-status stock-low"><i class="fas fa-exclamation-circle"></i> Low Stock (${product.stockQuantity})</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="stock-status stock-out"><i class="fas fa-times-circle"></i> Out of Stock</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="product-footer d-flex gap-2">
                                <a href="${pageContext.request.contextPath}/product-details?id=${product.productId}" class="btn btn-primary flex-grow-1">View Details</a>
                                <button class="btn btn-outline-primary" data-add-cart="${product.productId}"
                                        <c:if test="${product.stockQuantity == 0}">disabled title="Out of Stock"</c:if>>
                                    <i class="fas fa-cart-plus"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- Pagination -->
            <nav class="mt-5 d-flex justify-content-center" aria-label="Product pagination">
                <ul class="pagination pagination-glass" id="pagination">
                    <li class="page-item disabled"><a class="page-link" href="#"><i class="fas fa-chevron-left"></i></a></li>
                    <li class="page-item active"><a class="page-link" href="#">1</a></li>
                    <li class="page-item"><a class="page-link" href="#">2</a></li>
                    <li class="page-item"><a class="page-link" href="#">3</a></li>
                    <li class="page-item"><a class="page-link" href="#"><i class="fas fa-chevron-right"></i></a></li>
                </ul>
            </nav>
        </div>
    </main>

    <jsp:include page="components/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/cart.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            TechMart.initQuickView();
            TechMartCart.initAddToCartButtons();
        });
    </script>
</body>
</html>
