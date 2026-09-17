<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="context-path" content="${pageContext.request.contextPath}">
    <title>Home - TechMart Online</title>
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
            <!-- Hero Banner -->
            <section class="hero-section">
                <div class="row align-items-center">
                    <div class="col-lg-6">
                        <div class="hero-content">
                            <span class="badge bg-light text-primary mb-3 px-3 py-2">Enterprise Technology Solutions</span>
                            <h1 class="hero-title">Power Your Business with <span class="text-warning">Premium Tech</span></h1>
                            <p class="hero-subtitle">Discover cutting-edge laptops, smartphones, and enterprise accessories. Trusted by 10,000+ corporate clients worldwide.</p>
                            <div class="hero-buttons d-flex gap-3 flex-wrap">
                                <a href="${pageContext.request.contextPath}/products" class="btn btn-light btn-lg px-4">
                                    <i class="fas fa-shopping-bag me-2"></i>Shop Now
                                </a>
                                <a href="#featured" class="btn btn-outline-light btn-lg px-4">
                                    <i class="fas fa-play-circle me-2"></i>Explore
                                </a>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="hero-image text-center">
                            <img src="https://images.unsplash.com/photo-1498049794561-7780e7231661?w=600&h=400&fit=crop" alt="Enterprise Technology" class="img-fluid rounded-4">
                        </div>
                    </div>
                </div>
            </section>

            <!-- Stats Bar -->
            <section class="row g-4 mb-5">
                <div class="col-6 col-md-3">
                    <div class="glass-card text-center p-4">
                        <div class="stat-number" data-counter="10000" data-format="number">0</div>
                        <small class="text-muted">Happy Customers</small>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="glass-card text-center p-4">
                        <div class="stat-number" data-counter="500" data-format="number">0</div>
                        <small class="text-muted">Products</small>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="glass-card text-center p-4">
                        <div class="stat-number" data-counter="50" data-format="number">0</div>
                        <small class="text-muted">Brands</small>
                    </div>
                </div>
                <div class="col-6 col-md-3">
                    <div class="glass-card text-center p-4">
                        <div class="stat-number" data-counter="99" data-format="percent">0</div>
                        <small class="text-muted">Satisfaction Rate</small>
                    </div>
                </div>
            </section>

            <!-- Categories -->
            <section class="mb-5">
                <h2 class="section-title">Shop by Category</h2>
                <p class="section-subtitle">Browse our wide range of enterprise technology categories</p>
                <div class="row g-4" id="categoriesContainer">
                    <!-- Skeleton shown until JS renders real categories -->
                    <div class="col-6 col-md-4 col-lg-2"><div class="skeleton skeleton-card" style="height: 120px;"></div></div>
                    <div class="col-6 col-md-4 col-lg-2"><div class="skeleton skeleton-card" style="height: 120px;"></div></div>
                    <div class="col-6 col-md-4 col-lg-2"><div class="skeleton skeleton-card" style="height: 120px;"></div></div>
                    <div class="col-6 col-md-4 col-lg-2"><div class="skeleton skeleton-card" style="height: 120px;"></div></div>
                    <div class="col-6 col-md-4 col-lg-2"><div class="skeleton skeleton-card" style="height: 120px;"></div></div>
                    <div class="col-6 col-md-4 col-lg-2"><div class="skeleton skeleton-card" style="height: 120px;"></div></div>
                </div>
            </section>

            <!-- Featured Products -->
            <section class="mb-5" id="featured">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h2 class="section-title mb-0">Featured Products</h2>
                        <p class="section-subtitle mb-0">Handpicked premium selections for you</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-outline-primary">View All <i class="fas fa-arrow-right ms-1"></i></a>
                </div>

                <!-- Skeleton shown until JS renders real cards -->
                <div class="row g-4" id="featuredSkeletonRow">
                    <div class="col-md-6 col-lg-3"><div class="skeleton skeleton-card"></div></div>
                    <div class="col-md-6 col-lg-3"><div class="skeleton skeleton-card"></div></div>
                    <div class="col-md-6 col-lg-3"><div class="skeleton skeleton-card"></div></div>
                    <div class="col-md-6 col-lg-3"><div class="skeleton skeleton-card"></div></div>
                </div>
                <div class="row g-4" id="featuredProductsContainer" style="display:none;"></div>
            </section>

            <!-- Top Selling Products -->
            <section class="mb-5">
                <h2 class="section-title">Top Selling Products</h2>
                <p class="section-subtitle">Most popular items among our enterprise clients</p>
                
                <!-- Skeleton shown until JS renders real cards -->
                <div class="row g-4" id="topSellingSkeletonRow">
                    <div class="col-md-6 col-lg-4"><div class="skeleton skeleton-card" style="height: 140px;"></div></div>
                    <div class="col-md-6 col-lg-4"><div class="skeleton skeleton-card" style="height: 140px;"></div></div>
                    <div class="col-md-6 col-lg-4"><div class="skeleton skeleton-card" style="height: 140px;"></div></div>
                </div>
                <div class="row g-4" id="topSellingProductsContainer" style="display:none;"></div>
            </section>

            <!-- Customer Reviews -->
            <section class="mb-5">
                <h2 class="section-title">Customer Reviews</h2>
                <p class="section-subtitle">What our enterprise clients say about us</p>
                <div class="row g-4">
                    <div class="col-md-4">
                        <div class="review-card">
                            <div class="d-flex align-items-center gap-3 mb-3">
                                <img src="https://ui-avatars.com/api/?name=Sarah+Johnson&background=0d6efd&color=fff" alt="Sarah" class="review-avatar">
                                <div>
                                    <h6 class="mb-0 fw-semibold">Sarah Johnson</h6>
                                    <small class="text-muted">CTO, TechCorp Inc.</small>
                                </div>
                            </div>
                            <div class="review-stars mb-2"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i></div>
                            <p class="mb-0 text-muted">"TechMart Online has been our go-to supplier for enterprise hardware. Fast delivery, competitive pricing, and excellent support."</p>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="review-card">
                            <div class="d-flex align-items-center gap-3 mb-3">
                                <img src="https://ui-avatars.com/api/?name=Michael+Chen&background=198754&color=fff" alt="Michael" class="review-avatar">
                                <div>
                                    <h6 class="mb-0 fw-semibold">Michael Chen</h6>
                                    <small class="text-muted">IT Director, GlobalSoft</small>
                                </div>
                            </div>
                            <div class="review-stars mb-2"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i></div>
                            <p class="mb-0 text-muted">"Bulk ordering made easy. We equipped our entire office with laptops and monitors through TechMart. Highly recommended!"</p>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="review-card">
                            <div class="d-flex align-items-center gap-3 mb-3">
                                <img src="https://ui-avatars.com/api/?name=Emily+Davis&background=dc3545&color=fff" alt="Emily" class="review-avatar">
                                <div>
                                    <h6 class="mb-0 fw-semibold">Emily Davis</h6>
                                    <small class="text-muted">Procurement Manager, InnovateCo</small>
                                </div>
                            </div>
                            <div class="review-stars mb-2"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i></div>
                            <p class="mb-0 text-muted">"The enterprise dashboard and bulk pricing options saved us thousands. Professional service from start to finish."</p>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </main>

    <jsp:include page="components/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/cart.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', async () => {
            const featuredSkeletonRow  = document.getElementById('featuredSkeletonRow');
            const featuredContainer    = document.getElementById('featuredProductsContainer');
            const topSellingSkeletonRow = document.getElementById('topSellingSkeletonRow');
            const topSellingContainer  = document.getElementById('topSellingProductsContainer');
            const categoriesContainer  = document.getElementById('categoriesContainer');

            const buildCard = (p) => {
                const badge    = p.oldPrice > 0 ? '<span class="badge bg-danger product-badge">Sale</span>' : '';
                const oldPrice = p.oldPrice > 0 ? `<span class="old-price">Rs. \${parseFloat(p.oldPrice).toFixed(2)}</span>` : '';
                const imgSrc   = p.image  || 'https://via.placeholder.com/400x400?text=No+Image';
                const stars    = TechMart.renderStars(p.rating || 0);
                const stockOut = p.stock <= 0;
                const qvJson   = JSON.stringify(p).replace(/"/g, '&quot;');

                return `
                <div class="col-md-6 col-lg-3">
                    <div class="product-card h-100">
                        <div class="product-image-wrapper">
                            \${badge}
                            <img src="\${imgSrc}" alt="\${p.name}"
                                 onerror="this.src='https://via.placeholder.com/400x400?text=No+Image'">
                            <div class="product-actions">
                                <button class="product-action-btn" data-quick-view="\${qvJson}" title="Quick View">
                                    <i class="fas fa-eye"></i>
                                </button>
                                <button class="product-action-btn" data-add-cart="\${p.id}"
                                    \${stockOut ? 'disabled title="Out of Stock"' : 'title="Add to Cart"'}>
                                    <i class="fas fa-cart-plus"></i>
                                </button>
                            </div>
                        </div>
                        <div class="product-body">
                            <span class="product-category">\${p.category || ''}</span>
                            <h5 class="product-title">\${p.name}</h5>
                            <div class="product-rating">
                                \${stars}<span class="rating-count">(\${p.reviews || 0})</span>
                            </div>
                            <div class="product-price">
                                Rs. \${parseFloat(p.price).toFixed(2)} \${oldPrice}
                            </div>
                            <span class="stock-status \${p.stock > 10 ? 'stock-in' : p.stock > 0 ? 'stock-low' : 'stock-out'}">
                                <i class="fas \${p.stock > 0 ? 'fa-check-circle' : 'fa-times-circle'}"></i>
                                \${p.stock > 10 ? 'In Stock' : p.stock > 0 ? 'Low Stock (' + p.stock + ')' : 'Out of Stock'}
                            </span>
                        </div>
                        <div class="product-footer">
                            <a href="\${TechMart.contextPath}/product-details?id=\${p.id}" class="btn btn-primary w-100">View Details</a>
                        </div>
                    </div>
                </div>`;
            };

            const buildHorizontalCard = (p) => {
                const imgSrc   = p.image  || 'https://via.placeholder.com/200x200?text=No+Image';
                const stars    = TechMart.renderStars(p.rating || 0);
                
                return `
                <div class="col-md-6 col-lg-4">
                    <a href="\${TechMart.contextPath}/product-details?id=\${p.id}" class="text-decoration-none text-dark">
                        <div class="product-card d-flex flex-row h-100">
                            <div class="product-image-wrapper" style="width:140px;aspect-ratio:auto;flex-shrink:0;">
                                <img src="\${imgSrc}" alt="\${p.name}" onerror="this.src='https://via.placeholder.com/200x200?text=No+Image'">
                            </div>
                            <div class="product-body">
                                <span class="product-category">\${p.category || ''}</span>
                                <h5 class="product-title">\${p.name}</h5>
                                <div class="product-rating">
                                    \${stars}<span class="rating-count">(\${p.reviews || 0})</span>
                                </div>
                                <div class="product-price">
                                    Rs. \${parseFloat(p.price).toFixed(2)}
                                </div>
                                <span class="stock-status \${p.stock > 10 ? 'stock-in' : p.stock > 0 ? 'stock-low' : 'stock-out'}">
                                    <i class="fas \${p.stock > 0 ? 'fa-check-circle' : 'fa-times-circle'}"></i> 
                                    \${p.stock > 10 ? 'In Stock' : p.stock > 0 ? 'Low Stock' : 'Out of Stock'}
                                </span>
                            </div>
                        </div>
                    </a>
                </div>`;
            };

            const buildCategoryCard = (c) => {
                return `
                <div class="col-6 col-md-4 col-lg-2">
                    <a href="\${TechMart.contextPath}/products?category=\${encodeURIComponent(c.name.toLowerCase())}">
                        <div class="category-card">
                            <div class="category-icon"><i class="fas \${c.icon}"></i></div>
                            <h6 class="mb-0 fw-semibold">\${c.name}</h6>
                        </div>
                    </a>
                </div>`;
            };

            // Fetch Categories
            try {
                const catRes = await fetch(TechMart.contextPath + '/api/categories');
                if (catRes.ok) {
                    const categories = await catRes.json();
                    if (categories.length > 0) {
                        categoriesContainer.innerHTML = categories.map(buildCategoryCard).join('');
                    } else {
                        categoriesContainer.innerHTML = '<div class="col-12 text-center text-muted">No categories found.</div>';
                    }
                } else {
                    categoriesContainer.innerHTML = '<div class="col-12 text-center text-muted">Failed to load categories.</div>';
                }
            } catch (e) {
                console.error('Failed to fetch categories', e);
                categoriesContainer.innerHTML = '<div class="col-12 text-center text-muted">Failed to load categories.</div>';
            }

            // Fetch Products (Featured and Top Selling)
            try {
                const res = await fetch(TechMart.contextPath + '/api/products');
                if (res.ok) {
                    const products = await res.json();
                    
                    // Featured Products (first 4)
                    const featured = products.slice(0, 4);
                    if (featured.length > 0) {
                        featuredContainer.innerHTML = featured.map(buildCard).join('');
                        if (featuredSkeletonRow) featuredSkeletonRow.style.display = 'none';
                        featuredContainer.style.display = '';
                    } else {
                        if (featuredSkeletonRow) featuredSkeletonRow.style.display = 'none';
                        featuredContainer.style.display = '';
                        featuredContainer.innerHTML = '<div class="col-12 text-center text-muted py-4">No products available yet.</div>';
                    }
                    
                    // Top Selling Products (sorted by reviews, take top 3)
                    const topSelling = [...products].sort((a, b) => (b.reviews || 0) - (a.reviews || 0)).slice(0, 3);
                    if (topSelling.length > 0) {
                        topSellingContainer.innerHTML = topSelling.map(buildHorizontalCard).join('');
                        if (topSellingSkeletonRow) topSellingSkeletonRow.style.display = 'none';
                        topSellingContainer.style.display = '';
                    } else {
                        if (topSellingSkeletonRow) topSellingSkeletonRow.style.display = 'none';
                        topSellingContainer.style.display = '';
                        topSellingContainer.innerHTML = '<div class="col-12 text-center text-muted py-4">No top selling products available.</div>';
                    }

                    TechMart.initQuickView();
                    TechMartCart.initAddToCartButtons();
                } else {
                    if (featuredSkeletonRow) featuredSkeletonRow.style.display = 'none';
                    if (topSellingSkeletonRow) topSellingSkeletonRow.style.display = 'none';
                }
            } catch (e) {
                console.error('Failed to fetch products', e);
                if (featuredSkeletonRow) featuredSkeletonRow.style.display = 'none';
                if (topSellingSkeletonRow) topSellingSkeletonRow.style.display = 'none';
            }
        });
    </script>
</body>
</html>
