/**
 * TechMart Online - Admin Dashboard JavaScript
 */

const TechMartDashboard = {
    charts: {},

    init() {
        this.initSidebar();
        this.initActivePage();
        this.initCharts();
        this.initStockProgress();
        this.initTableSearch();
    },

    /* ---- Sidebar Toggle ---- */
    initSidebar() {
        const sidebar = document.getElementById('adminSidebar');
        const overlay = document.getElementById('sidebarOverlay');
        const toggleBtn = document.getElementById('sidebarToggle');
        const closeBtn = document.getElementById('sidebarClose');

        toggleBtn?.addEventListener('click', () => {
            sidebar?.classList.toggle('open');
            overlay?.classList.toggle('active');
        });

        closeBtn?.addEventListener('click', () => {
            sidebar?.classList.remove('open');
            overlay?.classList.remove('active');
        });

        overlay?.addEventListener('click', () => {
            sidebar?.classList.remove('open');
            overlay?.classList.remove('active');
        });
    },

    /* ---- Active Sidebar Link ---- */
    initActivePage() {
        const currentPage = window.location.pathname.split('/').pop().replace('.jsp', '');
        document.querySelectorAll('.sidebar-link').forEach(link => {
            if (link.dataset.page === currentPage) {
                link.classList.add('active');
            }
        });
    },

    /* ---- Charts ---- */
    initCharts() {
        const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
        const gridColor = isDark ? 'rgba(148, 163, 184, 0.1)' : 'rgba(13, 110, 253, 0.08)';
        const textColor = isDark ? '#94a3b8' : '#6c7a8d';

        Chart.defaults.color = textColor;
        Chart.defaults.borderColor = gridColor;
        Chart.defaults.font.family = "'Segoe UI', system-ui, sans-serif";

        this.initRevenueChart(gridColor);
        this.initSalesChart(gridColor);
        this.initInventoryChart();
        this.initAnalyticsCharts(gridColor);
    },

    initRevenueChart(gridColor) {
        const canvas = document.getElementById('revenueChart');
        if (!canvas) return;

        this.charts.revenue = new Chart(canvas, {
            type: 'line',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                datasets: [{
                    label: 'Revenue',
                    data: [42000, 48000, 45000, 52000, 58000, 62000, 55000, 67000, 72000, 68000, 75000, 82000],
                    borderColor: '#0d6efd',
                    backgroundColor: 'rgba(13, 110, 253, 0.1)',
                    fill: true,
                    tension: 0.4,
                    pointRadius: 4,
                    pointHoverRadius: 6,
                    pointBackgroundColor: '#0d6efd'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: (ctx) => 'Rs. ' + ctx.parsed.y.toLocaleString()
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: gridColor },
                        ticks: {
                            callback: (val) => 'Rs. ' + (val / 1000) + 'k'
                        }
                    },
                    x: { grid: { display: false } }
                }
            }
        });
    },

    initSalesChart(gridColor) {
        const canvas = document.getElementById('salesChart');
        if (!canvas) return;

        this.charts.sales = new Chart(canvas, {
            type: 'bar',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                datasets: [{
                    label: 'Sales',
                    data: [320, 380, 350, 420, 480, 510],
                    backgroundColor: 'rgba(13, 110, 253, 0.7)',
                    borderRadius: 6,
                    borderSkipped: false
                }, {
                    label: 'Orders',
                    data: [280, 340, 310, 390, 420, 460],
                    backgroundColor: 'rgba(13, 202, 240, 0.5)',
                    borderRadius: 6,
                    borderSkipped: false
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { position: 'top', align: 'end' } },
                scales: {
                    y: { beginAtZero: true, grid: { color: gridColor } },
                    x: { grid: { display: false } }
                }
            }
        });
    },

    initInventoryChart() {
        const canvas = document.getElementById('inventoryChart');
        if (!canvas) return;

        this.charts.inventory = new Chart(canvas, {
            type: 'doughnut',
            data: {
                labels: ['In Stock', 'Low Stock', 'Out of Stock'],
                datasets: [{
                    data: [156, 28, 12],
                    backgroundColor: ['#198754', '#ffc107', '#dc3545'],
                    borderWidth: 0,
                    hoverOffset: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '65%',
                plugins: {
                    legend: { position: 'bottom', labels: { padding: 16, usePointStyle: true } }
                }
            }
        });
    },

    initAnalyticsCharts(gridColor) {
        const trafficCanvas = document.getElementById('trafficChart');
        if (trafficCanvas) {
            this.charts.traffic = new Chart(trafficCanvas, {
                type: 'line',
                data: {
                    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                    datasets: [{
                        label: 'Visitors',
                        data: [2400, 3200, 2800, 4100, 3800, 5200, 4800],
                        borderColor: '#0d6efd',
                        backgroundColor: 'rgba(13, 110, 253, 0.08)',
                        fill: true,
                        tension: 0.4
                    }, {
                        label: 'Page Views',
                        data: [4800, 6400, 5600, 8200, 7600, 10400, 9600],
                        borderColor: '#0dcaf0',
                        backgroundColor: 'rgba(13, 202, 240, 0.05)',
                        fill: true,
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { position: 'top', align: 'end' } },
                    scales: {
                        y: { beginAtZero: true, grid: { color: gridColor } },
                        x: { grid: { display: false } }
                    }
                }
            });
        }

        const categoryCanvas = document.getElementById('categoryChart');
        if (categoryCanvas) {
            this.charts.category = new Chart(categoryCanvas, {
                type: 'polarArea',
                data: {
                    labels: ['Laptops', 'Smartphones', 'Audio', 'Accessories', 'Monitors', 'Tablets'],
                    datasets: [{
                        data: [35, 28, 15, 12, 6, 4],
                        backgroundColor: [
                            'rgba(13, 110, 253, 0.7)',
                            'rgba(13, 202, 240, 0.6)',
                            'rgba(25, 135, 84, 0.6)',
                            'rgba(255, 193, 7, 0.6)',
                            'rgba(220, 53, 69, 0.5)',
                            'rgba(108, 117, 125, 0.5)'
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { position: 'right' } }
                }
            });
        }

        const conversionCanvas = document.getElementById('conversionChart');
        if (conversionCanvas) {
            this.charts.conversion = new Chart(conversionCanvas, {
                type: 'bar',
                data: {
                    labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
                    datasets: [{
                        label: 'Conversion Rate (%)',
                        data: [3.2, 3.8, 4.1, 4.5],
                        backgroundColor: 'rgba(25, 135, 84, 0.7)',
                        borderRadius: 6
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    indexAxis: 'y',
                    plugins: { legend: { display: false } },
                    scales: {
                        x: { beginAtZero: true, max: 6, grid: { color: gridColor } },
                        y: { grid: { display: false } }
                    }
                }
            });
        }
    },

    /* ---- Stock Progress Bars ---- */
    initStockProgress() {
        document.querySelectorAll('.stock-progress-bar').forEach(bar => {
            const width = bar.dataset.width;
            setTimeout(() => { bar.style.width = width + '%'; }, 300);
        });
    },

    /* ---- Table Search ---- */
    initTableSearch() {
        const searchInput = document.getElementById('tableSearch');
        if (!searchInput) return;

        searchInput.addEventListener('input', (e) => {
            const query = e.target.value.toLowerCase();
            const table = document.querySelector('.data-table tbody');
            if (!table) return;

            table.querySelectorAll('tr').forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(query) ? '' : 'none';
            });
        });
    }
};

document.addEventListener('DOMContentLoaded', () => TechMartDashboard.init());
