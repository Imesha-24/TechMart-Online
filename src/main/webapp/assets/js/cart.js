/**
 * TechMart Online - Shopping Cart JavaScript (Server-side)
 */

const TechMartCart = {
    cartData: { items: [], itemCount: 0, subtotal: 0, shipping: 0, tax: 0, total: 0 },

    async fetchCart() {
        try {
            const res = await fetch(TechMart.contextPath + '/api/cart');
            if (res.status === 401) {
                this.cartData = { items: [], itemCount: 0, subtotal: 0, shipping: 0, tax: 0, total: 0 };
                return;
            }
            if (res.ok) {
                this.cartData = await res.json();
                this.updateBadge(this.cartData.itemCount);
                this.renderCart();
            }
        } catch (e) {
            console.error('Failed to fetch cart', e);
        }
    },

    async addItem(productId, quantity = 1) {
        try {
            const params = new URLSearchParams();
            params.append('productId', productId);
            params.append('quantity', quantity);

            const res = await fetch(TechMart.contextPath + '/api/cart/add', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            });

            if (res.status === 401) {
                TechMart.showToast('Please sign in to add items to your cart.', 'warning');
                setTimeout(() => window.location.href = TechMart.contextPath + '/login', 1500);
                throw new Error('Unauthorized');
            }

            const data = await res.json();
            if (res.ok && data.success) {
                this.updateBadge(data.cartCount);
                TechMart.showToast('Item added to cart!', 'success');
                this.fetchCart(); // refresh full cart if we're on the cart page
            } else {
                TechMart.showToast(data.error || 'Failed to add item', 'error');
                throw new Error(data.error || 'Failed to add item');
            }
        } catch (e) {
            if (!e.message || (e.message !== 'Unauthorized' && !e.message.includes('Failed'))) {
                console.error('Error adding item', e);
                TechMart.showToast('An error occurred.', 'error');
            }
            throw e; // Re-throw so progress animation catch block fires
        }
    },

    async removeItem(productId) {
        try {
            const params = new URLSearchParams();
            params.append('productId', productId);

            const res = await fetch(TechMart.contextPath + '/api/cart/remove', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            });

            if (res.ok) {
                const data = await res.json();
                this.updateBadge(data.cartCount);
                TechMart.showToast('Item removed from cart', 'info');
                this.fetchCart();
            }
        } catch (e) {
            console.error('Error removing item', e);
        }
    },

    async updateQuantity(productId, quantity) {
        if (quantity < 1) {
            this.removeItem(productId);
            return;
        }
        try {
            const params = new URLSearchParams();
            params.append('productId', productId);
            params.append('quantity', Math.min(99, quantity));

            const res = await fetch(TechMart.contextPath + '/api/cart/update', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            });

            if (res.ok) {
                const data = await res.json();
                this.updateBadge(data.cartCount);
                this.fetchCart();
            }
        } catch (e) {
            console.error('Error updating quantity', e);
        }
    },

    async clearCart() {
        try {
            const res = await fetch(TechMart.contextPath + '/api/cart/clear', {
                method: 'POST'
            });
            if (res.ok) {
                this.updateBadge(0);
                this.fetchCart();
            }
        } catch (e) {
            console.error('Error clearing cart', e);
        }
    },

    updateBadge(count) {
        const badge = document.getElementById('cartBadge');
        if (!badge) return;
        badge.textContent = count;
        badge.style.display = count > 0 ? 'flex' : 'none';
    },

    renderCart() {
        const container = document.getElementById('cartItems');
        const emptyState = document.getElementById('cartEmpty');
        const summarySection = document.getElementById('cartSummary');

        const cart = this.cartData.items || [];

        if (container) {
            if (cart.length === 0) {
                container.innerHTML = '';
                if (emptyState) emptyState.style.display = 'block';
                if (summarySection) summarySection.style.display = 'none';
            } else {
                if (emptyState) emptyState.style.display = 'none';
                if (summarySection) summarySection.style.display = 'block';
                container.innerHTML = cart.map(item => `
                    <div class="cart-item d-flex align-items-center gap-3" data-id="${item.productId}">
                        <img src="${item.image}" alt="${item.name}" class="cart-item-image">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 fw-semibold">${item.name}</h6>
                            <small class="text-muted">${item.category}</small>
                            <div class="product-price mt-1">Rs. ${item.price.toFixed(2)}</div>
                        </div>
                        <div class="quantity-selector">
                            <button class="btn btn-qty" onclick="TechMartCart.updateQuantity(${item.productId}, ${item.quantity - 1})">
                                <i class="fas fa-minus"></i>
                            </button>
                            <input type="number" class="form-control qty-input" value="${item.quantity}" min="1" max="99"
                                   onchange="TechMartCart.updateQuantity(${item.productId}, parseInt(this.value))">
                            <button class="btn btn-qty" onclick="TechMartCart.updateQuantity(${item.productId}, ${item.quantity + 1})">
                                <i class="fas fa-plus"></i>
                            </button>
                        </div>
                        <div class="text-end" style="min-width: 80px;">
                            <div class="fw-bold text-primary">Rs. ${item.itemTotal.toFixed(2)}</div>
                        </div>
                        <button class="btn btn-table-action danger" onclick="TechMartCart.removeItem(${item.productId})" title="Remove">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                `).join('');
            }
            this.updateSummary();
        }

        const checkoutContainer = document.getElementById('checkoutItems');
        if (checkoutContainer) {
            if (cart.length === 0) {
                checkoutContainer.innerHTML = '<p class="text-muted text-center">No items in cart</p>';
            } else {
                checkoutContainer.innerHTML = cart.map(item => `
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <img src="${item.image}" alt="${item.name}" style="width:48px;height:48px;border-radius:8px;object-fit:cover;">
                        <div class="flex-grow-1">
                            <small class="fw-semibold d-block">${item.name}</small>
                            <small class="text-muted">Qty: ${item.quantity}</small>
                        </div>
                        <small class="fw-semibold">Rs. ${(item.price * item.quantity).toFixed(2)}</small>
                    </div>
                `).join('');
            }
            this.updateCheckoutSummary();
        }
    },

    updateSummary() {
        const subtotalEl = document.getElementById('cartSubtotal');
        const shippingEl = document.getElementById('cartShipping');
        const taxEl = document.getElementById('cartTax');
        const totalEl = document.getElementById('cartTotal');

        if (subtotalEl) subtotalEl.textContent = 'Rs. ' + this.cartData.subtotal.toFixed(2);
        if (shippingEl) shippingEl.textContent = this.cartData.shipping === 0 ? 'FREE' : 'Rs. ' + this.cartData.shipping.toFixed(2);
        if (taxEl) taxEl.textContent = 'Rs. ' + this.cartData.tax.toFixed(2);
        if (totalEl) totalEl.textContent = 'Rs. ' + this.cartData.total.toFixed(2);
    },

    updateCheckoutSummary() {
        const subtotalEl = document.getElementById('checkoutSubtotal');
        const shippingEl = document.getElementById('checkoutShipping');
        const taxEl = document.getElementById('checkoutTax');
        const totalEl = document.getElementById('checkoutTotal');

        if (subtotalEl) subtotalEl.textContent = 'Rs. ' + this.cartData.subtotal.toFixed(2);
        if (shippingEl) shippingEl.textContent = this.cartData.shipping === 0 ? 'FREE' : 'Rs. ' + this.cartData.shipping.toFixed(2);
        if (taxEl) taxEl.textContent = 'Rs. ' + this.cartData.tax.toFixed(2);
        if (totalEl) totalEl.textContent = 'Rs. ' + this.cartData.total.toFixed(2);
    },

    initAddToCartButtons() {
        document.querySelectorAll('[data-add-cart]').forEach(btn => {
            // Remove old listeners to prevent duplicates if re-rendered
            const newBtn = btn.cloneNode(true);
            btn.parentNode.replaceChild(newBtn, btn);

            newBtn.addEventListener('click', async (e) => {
                e.preventDefault();
                if (newBtn.disabled || newBtn.dataset.loading === 'true') return;

                const productId = parseInt(newBtn.dataset.addCart, 10);
                const qtyInput = document.getElementById('productQty');
                const qty = qtyInput ? parseInt(qtyInput.value, 10) : 1;

                // ── Progress animation ──────────────────────────────────────
                const originalHtml = newBtn.innerHTML;
                const isIconBtn = newBtn.classList.contains('product-action-btn');

                newBtn.dataset.loading = 'true';
                newBtn.disabled = true;

                if (isIconBtn) {
                    // Small circular action button (product card overlay)
                    newBtn.innerHTML = '<span class="cart-btn-spinner"></span>';
                } else {
                    // Full-width "Add to Cart" button
                    newBtn.innerHTML = '<span class="cart-btn-spinner me-2"></span>Adding…';
                    newBtn.classList.add('btn-loading');
                }

                try {
                    await this.addItem(productId, qty);

                    // Show success tick
                    if (isIconBtn) {
                        newBtn.innerHTML = '<i class="fas fa-check"></i>';
                        newBtn.style.background = 'var(--success)';
                        newBtn.style.color = '#fff';
                        newBtn.style.borderColor = 'var(--success)';
                    } else {
                        newBtn.innerHTML = '<i class="fas fa-check me-2"></i>Added!';
                        newBtn.classList.remove('btn-loading');
                        newBtn.classList.add('btn-success-flash');
                    }
                } catch {
                    // Show error state briefly
                    if (!isIconBtn) {
                        newBtn.innerHTML = '<i class="fas fa-times me-2"></i>Error';
                        newBtn.classList.remove('btn-loading');
                    }
                }

                // Reset after 1.8 s
                setTimeout(() => {
                    newBtn.innerHTML = originalHtml;
                    newBtn.disabled = false;
                    newBtn.dataset.loading = 'false';
                    newBtn.classList.remove('btn-loading', 'btn-success-flash');
                    newBtn.style.background = '';
                    newBtn.style.color = '';
                    newBtn.style.borderColor = '';
                }, 1800);
            });
        });
    },

    init() {
        this.fetchCart();
        this.initAddToCartButtons();

        const checkoutBtn = document.getElementById('checkoutBtn');
        checkoutBtn?.addEventListener('click', () => {
            if (!this.cartData.items || this.cartData.items.length === 0) {
                TechMart.showToast('Your cart is empty!', 'warning');
                return;
            }
            window.location.href = TechMart.contextPath + '/checkout.jsp';
        });
    }
};

document.addEventListener('DOMContentLoaded', () => TechMartCart.init());
