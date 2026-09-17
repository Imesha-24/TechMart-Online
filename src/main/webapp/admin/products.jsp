<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="context-path" content="${pageContext.request.contextPath}">
    <title>Product Management - TechMart Admin</title>
    <meta name="description" content="Manage your TechMart product catalog — add, edit, delete and control visibility of all products.">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/dashboard.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/responsive.css" rel="stylesheet">
    <style>
        /* ─── Product Management Extras ─── */
        .pm-hero { background: linear-gradient(135deg,#0d6efd 0%,#6610f2 100%); border-radius:16px; padding:1.5rem 2rem; color:#fff; margin-bottom:1.5rem; position:relative; overflow:hidden; }
        .pm-hero::after { content:''; position:absolute; right:-40px; top:-40px; width:200px; height:200px; border-radius:50%; background:rgba(255,255,255,.08); }
        .pm-hero::before { content:''; position:absolute; right:60px; bottom:-60px; width:140px; height:140px; border-radius:50%; background:rgba(255,255,255,.05); }
        .pm-hero h1 { font-size:1.75rem; font-weight:700; margin:0 0 .25rem; }
        .pm-hero p  { margin:0; opacity:.85; font-size:.95rem; }
        .pm-stat-pill { display:inline-flex; align-items:center; gap:.5rem; background:rgba(255,255,255,.18); border-radius:50px; padding:.35rem .9rem; font-size:.85rem; font-weight:600; margin-top:.75rem; }

        /* filter bar */
        .filter-bar { background:var(--card-bg,#fff); border-radius:12px; padding:1rem 1.25rem; box-shadow:0 1px 8px rgba(0,0,0,.06); display:flex; flex-wrap:wrap; gap:.75rem; align-items:center; margin-bottom:1.25rem; }
        .filter-bar .form-control, .filter-bar .form-select { border-radius:8px; font-size:.9rem; }

        /* table */
        .product-table-wrap { background:var(--card-bg,#fff); border-radius:16px; box-shadow:0 2px 16px rgba(0,0,0,.07); overflow:hidden; }
        .product-table-head { padding:1rem 1.5rem; border-bottom:1px solid var(--border-color,rgba(0,0,0,.08)); display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:.75rem; }
        .product-table-head h5 { margin:0; font-weight:700; font-size:1rem; }
        .product-img-thumb { width:44px; height:44px; border-radius:10px; object-fit:cover; background:#f3f4f6; }
        .product-name-cell { font-weight:600; font-size:.92rem; line-height:1.2; }
        .product-brand-cell { font-size:.78rem; color:#6c757d; }
        .price-cell { font-weight:700; color:#0d6efd; }
        .stock-pill { display:inline-block; padding:.2rem .65rem; border-radius:20px; font-size:.75rem; font-weight:600; }
        .stock-in { background:#d1fae5; color:#065f46; }
        .stock-low { background:#fef9c3; color:#92400e; }
        .stock-out { background:#fee2e2; color:#991b1b; }
        .visibility-toggle { position:relative; display:inline-block; width:42px; height:22px; }
        .visibility-toggle input { opacity:0; width:0; height:0; }
        .vt-slider { position:absolute; inset:0; background:#ccc; border-radius:22px; cursor:pointer; transition:.3s; }
        .vt-slider:before { content:''; position:absolute; width:16px; height:16px; left:3px; bottom:3px; background:#fff; border-radius:50%; transition:.3s; }
        input:checked + .vt-slider { background:#0d6efd; }
        input:checked + .vt-slider:before { transform:translateX(20px); }
        .action-btn { width:32px; height:32px; border:none; border-radius:8px; display:inline-flex; align-items:center; justify-content:center; cursor:pointer; transition:all .2s; font-size:.82rem; }
        .action-btn.edit-btn   { background:#e0f2fe; color:#0369a1; }
        .action-btn.view-btn   { background:#f0fdf4; color:#166534; }
        .action-btn.delete-btn { background:#fee2e2; color:#991b1b; }
        .action-btn:hover { transform:scale(1.12); }
        .empty-state { padding:3rem; text-align:center; color:#6c757d; }
        .empty-state i { font-size:3rem; opacity:.3; margin-bottom:1rem; }

        /* Modals */
        .modal-header-gradient { background:linear-gradient(135deg,#0d6efd,#6610f2); color:#fff; border-radius:16px 16px 0 0; }
        .modal-header-gradient .btn-close { filter:invert(1); }
        .modal-content { border:none; border-radius:16px; }
        .form-label { font-weight:600; font-size:.88rem; }
        .required-star { color:#dc3545; }

        /* toast */
        .admin-toast { position:fixed; top:1.25rem; right:1.25rem; z-index:9999; min-width:300px; border-radius:12px; box-shadow:0 8px 24px rgba(0,0,0,.15); animation:slideInRight .35s ease; }
        @keyframes slideInRight { from{transform:translateX(120%);opacity:0} to{transform:translateX(0);opacity:1} }

        /* dark mode compat */
        [data-bs-theme="dark"] .product-table-wrap,
        [data-bs-theme="dark"] .filter-bar { background:var(--card-bg,#1e2535); }
        [data-bs-theme="dark"] .stock-in  { background:#064e3b; color:#6ee7b7; }
        [data-bs-theme="dark"] .stock-low { background:#78350f; color:#fde68a; }
        [data-bs-theme="dark"] .stock-out { background:#7f1d1d; color:#fca5a5; }
        [data-bs-theme="dark"] .action-btn.edit-btn   { background:#0c4a6e; color:#7dd3fc; }
        [data-bs-theme="dark"] .action-btn.view-btn   { background:#14532d; color:#86efac; }
        [data-bs-theme="dark"] .action-btn.delete-btn { background:#7f1d1d; color:#fca5a5; }
    </style>
</head>
<body>
<jsp:include page="../components/sidebar.jsp" />
<jsp:include page="../components/notification.jsp" />

<div class="admin-layout">
    <div class="admin-main" id="adminMain">

        <!-- Top Bar -->
        <div class="admin-topbar">
            <div class="d-flex align-items-center gap-3">
                <button class="btn btn-icon" id="sidebarToggle"><i class="fas fa-bars"></i></button>
                <h5 class="mb-0 fw-bold d-none d-md-block">Product Management</h5>
            </div>
            <div class="d-flex align-items-center gap-2">
                <button class="btn btn-icon" id="darkModeToggle" title="Toggle Dark Mode">
                    <i class="fas fa-moon" id="darkModeIcon"></i>
                </button>
            </div>
        </div>

        <div class="admin-content">

            <%-- Flash messages --%>
            <c:if test="${not empty sessionScope.successMsg}">
                <div class="alert alert-success alert-dismissible fade show rounded-3 mb-3" role="alert" id="successAlert">
                    <i class="fas fa-check-circle me-2"></i>${sessionScope.successMsg}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="successMsg" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="alert alert-danger alert-dismissible fade show rounded-3 mb-3" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMsg}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="errorMsg" scope="session"/>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-warning alert-dismissible fade show rounded-3 mb-3" role="alert">
                    <i class="fas fa-exclamation-triangle me-2"></i>${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <%-- Hero Banner --%>
            <div class="pm-hero">
                <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
                    <div>
                        <h1><i class="fas fa-box-open me-2"></i>Products</h1>
                        <p>Manage your TechMart product catalog with full CRUD control.</p>
                        <span class="pm-stat-pill"><i class="fas fa-layer-group"></i> ${totalCount} total products</span>
                    </div>
                    <button class="btn btn-light fw-bold shadow-sm px-4" id="btnAddProduct"
                            data-bs-toggle="modal" data-bs-target="#productModal" onclick="openAddModal()">
                        <i class="fas fa-plus me-2"></i>Add Product
                    </button>
                </div>
            </div>

            <%-- Filter bar --%>
            <form method="get" action="${pageContext.request.contextPath}/admin/products" class="filter-bar" id="filterForm">
                <div class="flex-grow-1" style="min-width:220px;">
                    <div class="input-group">
                        <span class="input-group-text bg-transparent border-end-0"><i class="fas fa-search text-muted"></i></span>
                        <input type="text" name="search" class="form-control border-start-0" id="searchInput"
                               placeholder="Search products, brands…" value="${search}" autocomplete="off">
                    </div>
                </div>
                <select name="category" class="form-select" style="max-width:200px;" onchange="this.form.submit()" id="categoryFilter">
                    <option value="">All Categories</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.categoryName}" ${selectedCategory == cat.categoryName ? 'selected' : ''}>${cat.categoryName}</option>
                    </c:forEach>
                </select>
                <button type="submit" class="btn btn-primary px-4">
                    <i class="fas fa-filter me-1"></i>Filter
                </button>
                <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-outline-secondary">
                    <i class="fas fa-redo me-1"></i>Reset
                </a>
            </form>

            <%-- Products Table --%>
            <div class="product-table-wrap">
                <div class="product-table-head">
                    <h5>
                        <c:choose>
                            <c:when test="${not empty search or not empty selectedCategory}">
                                Search Results
                            </c:when>
                            <c:otherwise>All Products</c:otherwise>
                        </c:choose>
                        <span class="badge bg-primary ms-2">${fn:length(products)}</span>
                    </h5>
                    <small class="text-muted">Showing ${fn:length(products)} of ${totalCount} products</small>
                </div>
                <div class="table-responsive">
                    <table class="table data-table mb-0" id="productsTable">
                        <thead>
                            <tr>
                                <th style="min-width:220px;">Product</th>
                                <th>SKU</th>
                                <th>Category</th>
                                <th>Price</th>
                                <th>Stock</th>
                                <th>Status</th>
                                <th>Visibility</th>
                                <th style="min-width:120px;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty products}">
                                    <tr>
                                        <td colspan="8">
                                            <div class="empty-state">
                                                <div><i class="fas fa-box-open"></i></div>
                                                <h5 class="fw-semibold">No products found</h5>
                                                <p class="mb-0 small">Try adjusting your filters or add a new product.</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="p" items="${products}">
                                        <c:set var="stockClass" value="${p.stockQuantity == 0 ? 'stock-out' : (p.stockQuantity < 10 ? 'stock-low' : 'stock-in')}"/>
                                        <c:set var="stockLabel" value="${p.stockQuantity == 0 ? 'Out of Stock' : (p.stockQuantity < 10 ? 'Low Stock' : 'In Stock')}"/>
                                        <tr data-product-id="${p.productId}">
                                            <td>
                                                <div class="d-flex align-items-center gap-2">
                                                    <img src="${not empty p.imageUrl ? p.imageUrl : 'https://via.placeholder.com/44x44?text=?'}"
                                                         class="product-img-thumb" alt="${p.productName}"
                                                         onerror="this.src='https://via.placeholder.com/44x44?text=?'">
                                                    <div>
                                                        <div class="product-name-cell">${p.productName}</div>
                                                        <div class="product-brand-cell">${p.brandName}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="text-muted small">TM-<fmt:formatNumber value="${p.productId}" pattern="00000"/></td>
                                            <td><span class="badge bg-light text-dark border">${not empty p.categoryName ? p.categoryName : '—'}</span></td>
                                            <td class="price-cell">Rs. <fmt:formatNumber value="${p.price}" pattern="#,##0.00"/></td>
                                            <td>${p.stockQuantity}</td>
                                            <td><span class="stock-pill ${stockClass}">${stockLabel}</span></td>
                                            <td>
                                                <form method="post" action="${pageContext.request.contextPath}/admin/products" class="d-inline visibility-form">
                                                    <input type="hidden" name="action" value="visibility">
                                                    <input type="hidden" name="productId" value="${p.productId}">
                                                    <input type="hidden" name="visible" value="${p.visible ? 'false' : 'true'}" class="vis-hidden-val">
                                                    <label class="visibility-toggle" title="${p.visible ? 'Visible — click to hide' : 'Hidden — click to show'}">
                                                        <input type="checkbox" ${p.visible ? 'checked' : ''} class="vis-checkbox" onchange="submitVisibility(this)">
                                                        <span class="vt-slider"></span>
                                                    </label>
                                                </form>
                                            </td>
                                            <td>
                                                <div class="d-flex gap-1">
                                                    <button class="action-btn edit-btn" title="Edit product"
                                                            onclick="openEditModal(${p.productId},'${fn:escapeXml(p.productName)}','${fn:escapeXml(p.description)}',${p.price},${p.stockQuantity},'${fn:escapeXml(p.imageUrl)}','${fn:escapeXml(p.productUrl)}',${p.categoryId},${p.brandId},${p.colorId},${p.visible})">
                                                        <i class="fas fa-edit"></i>
                                                    </button>
                                                    <a href="${pageContext.request.contextPath}/product-details?id=${p.productId}" target="_blank"
                                                       class="action-btn view-btn" title="View in store">
                                                        <i class="fas fa-external-link-alt"></i>
                                                    </a>
                                                    <button class="action-btn delete-btn" title="Delete product"
                                                            onclick="confirmDelete(${p.productId},'${fn:escapeXml(p.productName)}')">
                                                        <i class="fas fa-trash"></i>
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div><%-- end product-table-wrap --%>

        </div><%-- end admin-content --%>
    </div><%-- end admin-main --%>
</div><%-- end admin-layout --%>

<%-- ═══════════════════════════ ADD / EDIT MODAL ═══════════════════════════ --%>
<div class="modal fade" id="productModal" tabindex="-1" aria-labelledby="productModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header modal-header-gradient">
                <h5 class="modal-title fw-bold" id="productModalLabel"><i class="fas fa-box me-2"></i>Add Product</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/products" id="productForm" novalidate>
                <input type="hidden" name="action" id="formAction" value="add">
                <input type="hidden" name="productId" id="formProductId" value="">
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-8">
                            <label class="form-label">Product Name <span class="required-star">*</span></label>
                            <input type="text" name="productName" id="formProductName" class="form-control" required placeholder="e.g. MacBook Pro 16&quot; M3">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Price (USD) <span class="required-star">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text">Rs. </span>
                                <input type="number" step="0.01" min="0" name="price" id="formPrice" class="form-control" required placeholder="0.00">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Category <span class="required-star">*</span></label>
                            <select name="categoryId" id="formCategoryId" class="form-select" required>
                                <option value="">Select category</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.categoryId}">${cat.categoryName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Brand <span class="required-star">*</span></label>
                            <select name="brandId" id="formBrandId" class="form-select" required>
                                <option value="">Select brand</option>
                                <c:forEach var="brand" items="${brands}">
                                    <option value="${brand.brandId}">${brand.brandName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Stock Quantity <span class="required-star">*</span></label>
                            <input type="number" min="0" name="stockQuantity" id="formStock" class="form-control" required placeholder="0">
                        </div>
                        <div class="col-12">
                            <label class="form-label">Description</label>
                            <textarea name="description" id="formDescription" class="form-control" rows="3" placeholder="Describe this product…"></textarea>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Image URL</label>
                            <input type="url" name="imageUrl" id="formImageUrl" class="form-control" placeholder="https://…"
                                   oninput="updateImgPreview(this.value)">
                            <div class="mt-2">
                                <img id="imgPreview" src="" alt="" style="max-height:80px; border-radius:8px; display:none;" class="img-thumbnail">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Product URL</label>
                            <input type="text" name="productUrl" id="formProductUrl" class="form-control" placeholder="/product-details?id=…">
                        </div>
                        <div class="col-12">
                            <div class="form-check form-switch">
                                <input type="hidden" name="visible" id="formVisibleHidden" value="true">
                                <input class="form-check-input" type="checkbox" role="switch" id="formVisible" checked
                                       onchange="document.getElementById('formVisibleHidden').value = this.checked ? 'true' : 'false'">
                                <label class="form-check-label fw-semibold" for="formVisible">Visible to customers</label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary px-4" id="formSubmitBtn">
                        <i class="fas fa-plus me-1"></i>Add Product
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ═══════════════════════════ DELETE CONFIRM MODAL ═══════════════════════════ --%>
<div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold text-danger" id="deleteModalLabel"><i class="fas fa-trash me-2"></i>Delete Product</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="text-center mb-3">
                    <div style="width:64px;height:64px;background:#fee2e2;border-radius:50%;margin:0 auto 1rem;display:flex;align-items:center;justify-content:center;">
                        <i class="fas fa-exclamation-triangle text-danger" style="font-size:1.5rem;"></i>
                    </div>
                    <h6 class="fw-semibold">Are you sure?</h6>
                    <p class="text-muted mb-0">You are about to permanently delete <strong id="deleteProductName"></strong>. This action cannot be undone.</p>
                </div>
            </div>
            <div class="modal-footer border-0 justify-content-center gap-3">
                <button type="button" class="btn btn-light px-4" data-bs-dismiss="modal">Cancel</button>
                <form method="post" action="${pageContext.request.contextPath}/admin/products" id="deleteForm">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="productId" id="deleteProductId" value="">
                    <button type="submit" class="btn btn-danger px-4"><i class="fas fa-trash me-1"></i>Yes, Delete</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
<script>
// ─── Add Modal ─────────────────────────────────────────────────────────────
function openAddModal() {
    document.getElementById('productModalLabel').innerHTML = '<i class="fas fa-plus me-2"></i>Add New Product';
    document.getElementById('formAction').value = 'add';
    document.getElementById('formProductId').value = '';
    document.getElementById('productForm').reset();
    document.getElementById('formVisibleHidden').value = 'true';
    document.getElementById('formVisible').checked = true;
    document.getElementById('formSubmitBtn').innerHTML = '<i class="fas fa-plus me-1"></i>Add Product';
    hideImgPreview();
}

// ─── Edit Modal ─────────────────────────────────────────────────────────────
function openEditModal(id, name, desc, price, stock, imageUrl, productUrl, catId, brandId, colorId, visible) {
    document.getElementById('productModalLabel').innerHTML = '<i class="fas fa-edit me-2"></i>Edit Product';
    document.getElementById('formAction').value = 'update';
    document.getElementById('formProductId').value = id;
    document.getElementById('formProductName').value = name;
    document.getElementById('formDescription').value = desc !== 'null' ? desc : '';
    document.getElementById('formPrice').value = price;
    document.getElementById('formStock').value = stock;
    document.getElementById('formImageUrl').value = imageUrl !== 'null' ? imageUrl : '';
    document.getElementById('formProductUrl').value = productUrl !== 'null' ? productUrl : '';
    // Set selects
    setSelectValue('formCategoryId', catId);
    setSelectValue('formBrandId', brandId);
    const isVisible = visible === true || visible === 'true';
    document.getElementById('formVisible').checked = isVisible;
    document.getElementById('formVisibleHidden').value = isVisible ? 'true' : 'false';
    document.getElementById('formSubmitBtn').innerHTML = '<i class="fas fa-save me-1"></i>Save Changes';
    updateImgPreview(imageUrl !== 'null' ? imageUrl : '');
    new bootstrap.Modal(document.getElementById('productModal')).show();
}

function setSelectValue(id, val) {
    const sel = document.getElementById(id);
    if (!sel) return;
    for (let i = 0; i < sel.options.length; i++) {
        if (sel.options[i].value == val) { sel.selectedIndex = i; break; }
    }
}

// ─── Delete Modal ────────────────────────────────────────────────────────────
function confirmDelete(id, name) {
    document.getElementById('deleteProductId').value = id;
    document.getElementById('deleteProductName').textContent = name;
    new bootstrap.Modal(document.getElementById('deleteModal')).show();
}

// ─── Visibility Toggle ───────────────────────────────────────────────────────
function submitVisibility(checkbox) {
    const form = checkbox.closest('.visibility-form');
    // Update the hidden input: if now checked → visible=true, else false
    form.querySelector('.vis-hidden-val').value = checkbox.checked ? 'true' : 'false';
    form.submit();
}

// ─── Image Preview ───────────────────────────────────────────────────────────
function updateImgPreview(url) {
    const preview = document.getElementById('imgPreview');
    if (url && url.trim()) {
        preview.src = url;
        preview.style.display = 'inline-block';
        preview.onerror = () => hideImgPreview();
    } else {
        hideImgPreview();
    }
}
function hideImgPreview() {
    const preview = document.getElementById('imgPreview');
    preview.src = '';
    preview.style.display = 'none';
}

// ─── Live table search ───────────────────────────────────────────────────────
document.getElementById('searchInput').addEventListener('keypress', function(e) {
    if (e.key === 'Enter') document.getElementById('filterForm').submit();
});

// Auto-dismiss success alert
window.addEventListener('DOMContentLoaded', () => {
    const sa = document.getElementById('successAlert');
    if (sa) setTimeout(() => { const a = bootstrap.Alert.getOrCreateInstance(sa); a && a.close(); }, 4000);
});
</script>
</body>
</html>
