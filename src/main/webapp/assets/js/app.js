/**
 * TechMart Online - Main Application JavaScript
 */

const TechMart = {
    contextPath: '',

    init() {
        this.contextPath = document.querySelector('meta[name="context-path"]')?.content || '';
        this.initDarkMode();
        this.initNavbar();
        this.initBackToTop();
        this.initAnimations();
        this.initSkeletonLoaders();
        this.initQuickView();
        this.updateCartBadge();
    },

    initBackToTop() {
        const btn = document.getElementById('backToTop');
        if (!btn) return;

        window.addEventListener('scroll', () => {
            btn.classList.toggle('visible', window.scrollY > 400);
        });

        btn.addEventListener('click', () => {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        });
    },

    /* ---- Dark Mode ---- */
    initDarkMode() {
        const toggle = document.getElementById('darkModeToggle');
        const icon = document.getElementById('darkModeIcon');
        const saved = localStorage.getItem('techmart-theme');

        if (saved === 'dark') {
            document.documentElement.setAttribute('data-theme', 'dark');
            if (icon) {
                icon.classList.replace('fa-moon', 'fa-sun');
            }
        }

        toggle?.addEventListener('click', () => {
            const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
            if (isDark) {
                document.documentElement.removeAttribute('data-theme');
                localStorage.setItem('techmart-theme', 'light');
                icon?.classList.replace('fa-sun', 'fa-moon');
            } else {
                document.documentElement.setAttribute('data-theme', 'dark');
                localStorage.setItem('techmart-theme', 'dark');
                icon?.classList.replace('fa-moon', 'fa-sun');
            }
        });
    },

    /* ---- Navbar Active State ---- */
    initNavbar() {
        const currentPage = window.location.pathname.split('/').pop();
        document.querySelectorAll('.navbar-glass .nav-link').forEach(link => {
            if (link.getAttribute('href')?.includes(currentPage)) {
                link.classList.add('active');
            }
        });
    },

    /* ---- Animated Statistics ---- */
    animateCounter(element, target, duration = 2000) {
        if (!element) return;
        const start = 0;
        const isCurrency = element.dataset.format === 'currency';
        const isPercent = element.dataset.format === 'percent';
        const startTime = performance.now();

        const update = (currentTime) => {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);
            const eased = 1 - Math.pow(1 - progress, 3);
            const current = Math.floor(start + (target - start) * eased);

            if (isCurrency) {
                element.textContent = 'Rs. ' + current.toLocaleString();
            } else if (isPercent) {
                element.textContent = current + '%';
            } else {
                element.textContent = current.toLocaleString();
            }

            if (progress < 1) {
                requestAnimationFrame(update);
            }
        };

        requestAnimationFrame(update);
    },

    initAnimations() {
        const counters = document.querySelectorAll('[data-counter]');
        if (counters.length === 0) return;

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const el = entry.target;
                    const target = parseInt(el.dataset.counter, 10);
                    this.animateCounter(el, target);
                    observer.unobserve(el);
                }
            });
        }, { threshold: 0.5 });

        counters.forEach(counter => observer.observe(counter));
    },

    /* ---- Toast Notifications ---- */
    showToast(message, type = 'info') {
        const container = document.getElementById('toastContainer');
        if (!container) return;

        const icons = {
            success: 'fa-check-circle text-success',
            error: 'fa-times-circle text-danger',
            warning: 'fa-exclamation-triangle text-warning',
            info: 'fa-info-circle text-primary'
        };

        const id = 'toast-' + Date.now();
        const toastHtml = `
            <div class="toast show" id="${id}" role="alert">
                <div class="toast-body d-flex align-items-center gap-2">
                    <i class="fas ${icons[type] || icons.info}"></i>
                    <span>${message}</span>
                    <button type="button" class="btn-close ms-auto" data-bs-dismiss="toast"></button>
                </div>
            </div>
        `;

        container.insertAdjacentHTML('beforeend', toastHtml);
        const toastEl = document.getElementById(id);
        const bsToast = new bootstrap.Toast(toastEl, { delay: 4000 });
        bsToast.show();

        toastEl.addEventListener('hidden.bs.toast', () => toastEl.remove());
    },

    /* ---- Loading Spinner ---- */
    showLoading() {
        document.getElementById('loadingOverlay')?.classList.add('active');
    },

    hideLoading() {
        document.getElementById('loadingOverlay')?.classList.remove('active');
    },

    /* ---- Skeleton Loaders ---- */
    initSkeletonLoaders() {
        const skeletonContainers = document.querySelectorAll('[data-skeleton]');
        skeletonContainers.forEach(container => {
            const delay = parseInt(container.dataset.skeleton, 10) || 1500;
            setTimeout(() => {
                container.querySelectorAll('.skeleton-content').forEach(el => el.style.display = 'none');
                container.querySelectorAll('.real-content').forEach(el => {
                    el.style.display = '';
                    el.classList.add('fade-in');
                });
            }, delay);
        });
    },

    /* ---- Quick View Modal ---- */
    initQuickView() {
        document.querySelectorAll('[data-quick-view]').forEach(btn => {
            btn.addEventListener('click', (e) => {
                e.preventDefault();
                const product = JSON.parse(btn.dataset.quickView);
                this.openQuickView(product);
            });
        });
    },

    openQuickView(product) {
        document.getElementById('quickViewTitle').textContent = product.name;
        document.getElementById('quickViewImage').src = product.image;
        document.getElementById('quickViewImage').alt = product.name;
        document.getElementById('quickViewCategory').textContent = product.category;
        document.getElementById('quickViewPrice').textContent = 'Rs. ' + product.price.toFixed(2);
        document.getElementById('quickViewDescription').textContent = product.description;
        document.getElementById('quickViewRating').innerHTML = this.renderStars(product.rating) +
            `<span class="rating-count">(${product.reviews})</span>`;

        const stockEl = document.getElementById('quickViewStock');
        if (product.stock > 10) {
            stockEl.innerHTML = '<i class="fas fa-check-circle"></i> In Stock';
            stockEl.className = 'stock-status stock-in';
        } else if (product.stock > 0) {
            stockEl.innerHTML = '<i class="fas fa-exclamation-circle"></i> Low Stock (' + product.stock + ' left)';
            stockEl.className = 'stock-status stock-low';
        } else {
            stockEl.innerHTML = '<i class="fas fa-times-circle"></i> Out of Stock';
            stockEl.className = 'stock-status stock-out';
        }

        document.getElementById('quickViewQty').value = 1;
        document.getElementById('quickViewDetails').href = this.contextPath + '/product-details?id=' + product.id;

        const officialBtn = document.getElementById('quickViewOfficial');
        if (officialBtn) {
            if (product.productUrl) {
                officialBtn.href = product.productUrl;
                officialBtn.classList.remove('d-none');
            } else {
                officialBtn.classList.add('d-none');
                officialBtn.href = '#';
            }
        }

        const addBtn = document.getElementById('quickViewAddCart');
        addBtn.onclick = () => {
            const qty = parseInt(document.getElementById('quickViewQty').value, 10);
            TechMartCart.addItem(product.id, qty);
            bootstrap.Modal.getInstance(document.getElementById('quickViewModal'))?.hide();
        };

        new bootstrap.Modal(document.getElementById('quickViewModal')).show();
    },

    renderStars(rating) {
        let html = '';
        for (let i = 1; i <= 5; i++) {
            if (i <= Math.floor(rating)) {
                html += '<i class="fas fa-star"></i>';
            } else if (i - 0.5 <= rating) {
                html += '<i class="fas fa-star-half-alt"></i>';
            } else {
                html += '<i class="far fa-star"></i>';
            }
        }
        return html;
    },

    /* ---- Quantity Selector ---- */
    changeQty(inputId, delta) {
        const input = document.getElementById(inputId);
        if (!input) return;
        let val = parseInt(input.value, 10) + delta;
        const min = parseInt(input.min, 10) || 1;
        const max = parseInt(input.max, 10) || 99;
        val = Math.max(min, Math.min(max, val));
        input.value = val;
    },

    /* ---- Cart Badge ---- */
    updateCartBadge() {
        // Now handled by TechMartCart fetching from API
    },

    /* ---- Product API Helper ---- */
    async fetchProducts(category = null) {
        let url = this.contextPath + '/api/products';
        if (category && category !== 'all') {
            url += '?category=' + encodeURIComponent(category);
        }
        try {
            const res = await fetch(url);
            return res.ok ? await res.json() : [];
        } catch (e) {
            console.error('Failed to fetch products', e);
            return [];
        }
    }
};

document.addEventListener('DOMContentLoaded', () => TechMart.init());
