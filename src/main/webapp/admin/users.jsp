<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="lk.iu.model.User, java.util.List, java.text.SimpleDateFormat" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="context-path" content="${pageContext.request.contextPath}">
    <title>User Management - TechMart Online</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/dashboard.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/responsive.css" rel="stylesheet">
    <style>
        /* ── Avatar initials ───────────────────────────────────────── */
        .user-avatar-initials {
            width: 36px; height: 36px; border-radius: 50%;
            display: inline-flex; align-items: center; justify-content: center;
            font-size: .75rem; font-weight: 700; color: #fff;
            flex-shrink: 0; text-transform: uppercase;
        }
        /* ── Role colour palette ────────────────────────────────────── */
        .role-badge-ADMIN    { background: var(--bs-danger-bg-subtle); color: var(--bs-danger); }
        .role-badge-MANAGER  { background: var(--bs-warning-bg-subtle); color: #b45309; }
        .role-badge-CUSTOMER { background: var(--bs-primary-bg-subtle); color: var(--bs-primary); }

        /* ── Empty state ────────────────────────────────────────────── */
        .empty-state { padding: 4rem 1rem; text-align: center; color: var(--bs-secondary); }
        .empty-state i { font-size: 3rem; margin-bottom: 1rem; opacity: .4; }

        /* ── Modal helpers ──────────────────────────────────────────── */
        .modal-section-title {
            font-size: .7rem; font-weight: 700; text-transform: uppercase;
            letter-spacing: .06em; color: var(--bs-secondary); margin-bottom: .75rem;
        }
        /* keep delete modal overlay on top */
        #deleteConfirmModal { z-index: 1100; }
    </style>
</head>
<body>
<%
    /* ── Flash messages (Post-Redirect-Get pattern) ─────────────────── */
    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg   = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg");
    session.removeAttribute("errorMsg");

    /* ── Data from servlet ─────────────────────────────────────────── */
    @SuppressWarnings("unchecked")
    List<User> users    = (List<User>) request.getAttribute("users");
    int totalCount      = request.getAttribute("totalCount")  != null ? (int) request.getAttribute("totalCount")  : 0;
    int activeCount     = request.getAttribute("activeCount") != null ? (int) request.getAttribute("activeCount") : 0;
    int newThisMonth    = request.getAttribute("newThisMonth")!= null ? (int) request.getAttribute("newThisMonth"): 0;
    String selectedRole = request.getAttribute("selectedRole") != null ? (String) request.getAttribute("selectedRole") : "";
    String search       = request.getAttribute("search")        != null ? (String) request.getAttribute("search")        : "";

    SimpleDateFormat sdf = new SimpleDateFormat("MMM d, yyyy");

    /* ── Avatar background colours (cycle by userId mod 8) ─────────── */
    String[] avatarColors = {
        "#0d6efd","#198754","#dc3545","#fd7e14",
        "#6f42c1","#0dcaf0","#20c997","#ffc107"
    };
%>

<jsp:include page="../components/sidebar.jsp" />
<jsp:include page="../components/notification.jsp" />

<div class="admin-layout">
    <div class="admin-main" id="adminMain">

        <!-- ── Topbar ─────────────────────────────────────────────────── -->
        <div class="admin-topbar">
            <div class="d-flex align-items-center gap-3">
                <button class="btn btn-icon" id="sidebarToggle"><i class="fas fa-bars"></i></button>
                <h5 class="mb-0 fw-bold d-none d-md-block">User Management</h5>
            </div>
            <div class="d-flex align-items-center gap-2">
                <button class="btn btn-icon" id="darkModeToggle">
                    <i class="fas fa-moon" id="darkModeIcon"></i>
                </button>
                <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addUserModal"
                        id="addUserBtn">
                    <i class="fas fa-user-plus me-1"></i> Add User
                </button>
            </div>
        </div>

        <!-- ── Page body ──────────────────────────────────────────────── -->
        <div class="admin-content">

            <!-- Page heading -->
            <div class="mb-4">
                <h1 class="h3 fw-bold mb-1">Users</h1>
                <p class="text-muted mb-0">Manage <span class="text-primary fw-semibold">customer</span>
                    and <span class="text-danger fw-semibold">admin</span> accounts</p>
            </div>

            <!-- Flash alerts -->
            <% if (successMsg != null) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert" id="flashSuccess">
                <i class="fas fa-check-circle me-2"></i><%= successMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>
            <% if (errorMsg != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert" id="flashError">
                <i class="fas fa-exclamation-circle me-2"></i><%= errorMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i><%= request.getAttribute("error") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <!-- ── Stat cards ──────────────────────────────────────────── -->
            <div class="row g-4 mb-4">
                <div class="col-sm-4">
                    <div class="dashboard-card card-primary text-center">
                        <div class="dashboard-card-value" data-counter="<%= totalCount %>">0</div>
                        <div class="dashboard-card-label">Total Users</div>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="dashboard-card card-success text-center">
                        <div class="dashboard-card-value" data-counter="<%= activeCount %>">0</div>
                        <div class="dashboard-card-label">Active Users</div>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="dashboard-card card-warning text-center">
                        <div class="dashboard-card-value" data-counter="<%= newThisMonth %>">0</div>
                        <div class="dashboard-card-label">New This Month</div>
                    </div>
                </div>
            </div>

            <!-- ── User table ──────────────────────────────────────────── -->
            <div class="table-card">
                <div class="table-card-header">
                    <h5 class="table-card-title">All Users
                        <% if (!"".equals(selectedRole) || !"".equals(search)) { %>
                        <span class="badge bg-info-subtle text-info ms-2" style="font-size:.7rem;">Filtered</span>
                        <% } %>
                    </h5>
                    <form method="get" action="${pageContext.request.contextPath}/admin/users"
                          class="d-flex gap-2 flex-wrap" id="filterForm">
                        <select class="form-select form-select-sm" style="width:auto;" name="role"
                                id="roleFilter" onchange="this.form.submit()">
                            <option value="" <%= "".equals(selectedRole) ? "selected" : "" %>>All Roles</option>
                            <option value="CUSTOMER" <%= "CUSTOMER".equalsIgnoreCase(selectedRole) ? "selected":"" %>>Customer</option>
                            <option value="ADMIN"    <%= "ADMIN".equalsIgnoreCase(selectedRole)    ? "selected":"" %>>Admin</option>
                            <option value="MANAGER"  <%= "MANAGER".equalsIgnoreCase(selectedRole)  ? "selected":"" %>>Manager</option>
                        </select>
                        <div class="admin-search">
                            <i class="fas fa-search"></i>
                            <input type="text" class="form-control" id="tableSearch" name="search"
                                   placeholder="Search users..." value="<%= search %>">
                        </div>
                    </form>
                </div>

                <div class="table-responsive">
                    <table class="table data-table" id="usersTable">
                        <thead>
                            <tr>
                                <th>User</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Role</th>
                                <th>Joined</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                        if (users == null || users.isEmpty()) {
                        %>
                        <tr>
                            <td colspan="6">
                                <div class="empty-state">
                                    <i class="fas fa-users-slash d-block"></i>
                                    <p class="mb-0">No users found<% if(!"".equals(search)||!"".equals(selectedRole)){%> matching your filters<%}%>.</p>
                                    <% if(!"".equals(search)||!"".equals(selectedRole)){%>
                                    <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-sm btn-outline-secondary mt-3">
                                        <i class="fas fa-times me-1"></i>Clear Filters
                                    </a>
                                    <%}%>
                                </div>
                            </td>
                        </tr>
                        <%
                        } else {
                            for (User u : users) {
                                String initials = "";
                                if (u.getFullName() != null && !u.getFullName().isBlank()) {
                                    String[] parts = u.getFullName().trim().split("\\s+");
                                    initials = parts[0].substring(0,1);
                                    if (parts.length > 1) initials += parts[parts.length-1].substring(0,1);
                                }
                                String avatarColor = avatarColors[Math.abs(u.getUserId()) % avatarColors.length];
                                String role = u.getRole() != null ? u.getRole().toUpperCase() : "CUSTOMER";
                                String joinedDate = u.getCreatedAt() != null ? sdf.format(u.getCreatedAt()) : "—";
                                String roleBadgeClass = "role-badge-" + role;
                                String roleLabel = role.charAt(0) + role.substring(1).toLowerCase();
                        %>
                        <tr data-user-id="<%= u.getUserId() %>">
                            <td>
                                <div class="table-user">
                                    <div class="user-avatar-initials" style="background:<%= avatarColor %>">
                                        <%= initials %>
                                    </div>
                                    <span class="fw-semibold ms-2"><%= u.getFullName() != null ? u.getFullName() : "—" %></span>
                                </div>
                            </td>
                            <td class="text-muted"><%= u.getEmail() != null ? u.getEmail() : "—" %></td>
                            <td class="text-muted"><%= u.getPhone() != null && !u.getPhone().isBlank() ? u.getPhone() : "—" %></td>
                            <td>
                                <span class="badge <%= roleBadgeClass %>"><%= roleLabel %></span>
                            </td>
                            <td class="text-muted"><%= joinedDate %></td>
                            <td>
                                <div class="table-actions">
                                    <!-- Edit -->
                                    <button class="btn-table-action" title="Edit User"
                                            onclick="openEditModal(<%= u.getUserId() %>,
                                                '<%= escapeJs(u.getFullName()) %>',
                                                '<%= escapeJs(u.getEmail()) %>',
                                                '<%= escapeJs(u.getPhone() != null ? u.getPhone() : "") %>',
                                                '<%= role %>')">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <!-- Reset Password -->
                                    <button class="btn-table-action" title="Reset Password"
                                            onclick="openPasswordModal(<%= u.getUserId() %>, '<%= escapeJs(u.getFullName()) %>')">
                                        <i class="fas fa-key"></i>
                                    </button>
                                    <!-- Delete -->
                                    <button class="btn-table-action danger" title="Delete User"
                                            onclick="openDeleteModal(<%= u.getUserId() %>, '<%= escapeJs(u.getFullName()) %>')">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <%
                            } // end for
                        } // end else
                        %>
                        </tbody>
                    </table>
                </div>

                <!-- Table footer / count -->
                <% if (users != null && !users.isEmpty()) { %>
                <div class="d-flex justify-content-between align-items-center px-3 py-2 border-top"
                     style="font-size:.8rem; color:var(--bs-secondary);">
                    <span>Showing <strong><%= users.size() %></strong> of <strong><%= totalCount %></strong> users</span>
                    <% if (!"".equals(search) || !"".equals(selectedRole)) { %>
                    <a href="${pageContext.request.contextPath}/admin/users"
                       class="btn btn-sm btn-outline-secondary">
                        <i class="fas fa-times me-1"></i>Clear Filters
                    </a>
                    <% } %>
                </div>
                <% } %>
            </div><!-- /table-card -->

        </div><!-- /admin-content -->
    </div><!-- /admin-main -->
</div><!-- /admin-layout -->

<!-- ══════════════════════════════════════════════════════════════
     MODAL: Add User
═══════════════════════════════════════════════════════════════════ -->
<div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="addUserModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold" id="addUserModalLabel">
                    <i class="fas fa-user-plus text-primary me-2"></i>Add New User
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/users"
                  id="addUserForm" novalidate>
                <input type="hidden" name="action" value="add">
                <div class="modal-body pt-3">
                    <p class="modal-section-title">Account Details</p>

                    <div class="mb-3">
                        <label for="addFullName" class="form-label">Full Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="addFullName" name="fullName"
                               placeholder="e.g. Jane Smith" required>
                        <div class="invalid-feedback">Full name is required.</div>
                    </div>
                    <div class="mb-3">
                        <label for="addEmail" class="form-label">Email Address <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" id="addEmail" name="email"
                               placeholder="jane@example.com" required>
                        <div class="invalid-feedback">A valid email is required.</div>
                    </div>
                    <div class="mb-3">
                        <label for="addPhone" class="form-label">Phone</label>
                        <input type="tel" class="form-control" id="addPhone" name="phone"
                               placeholder="+1 555 000 0000">
                    </div>
                    <div class="mb-3">
                        <label for="addRole" class="form-label">Role <span class="text-danger">*</span></label>
                        <select class="form-select" id="addRole" name="role" required>
                            <option value="CUSTOMER" selected>Customer</option>
                            <option value="MANAGER">Manager</option>
                            <option value="ADMIN">Admin</option>
                        </select>
                    </div>
                    <hr class="my-3">
                    <p class="modal-section-title">Set Password</p>
                    <div class="mb-3">
                        <label for="addPassword" class="form-label">Password <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="password" class="form-control" id="addPassword" name="password"
                                   minlength="8" placeholder="Min 8 characters" required>
                            <button class="btn btn-outline-secondary" type="button"
                                    onclick="togglePwd('addPassword', this)" tabindex="-1">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                        <div class="invalid-feedback">Password must be at least 8 characters.</div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary" id="addUserSubmit">
                        <i class="fas fa-plus me-1"></i>Create User
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════════════════════════
     MODAL: Edit User
═══════════════════════════════════════════════════════════════════ -->
<div class="modal fade" id="editUserModal" tabindex="-1" aria-labelledby="editUserModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold" id="editUserModalLabel">
                    <i class="fas fa-user-edit text-warning me-2"></i>Edit User
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/users"
                  id="editUserForm" novalidate>
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="userId" id="editUserId">
                <div class="modal-body pt-3">
                    <p class="modal-section-title">Profile Information</p>
                    <div class="mb-3">
                        <label for="editFullName" class="form-label">Full Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="editFullName" name="fullName" required>
                        <div class="invalid-feedback">Full name is required.</div>
                    </div>
                    <div class="mb-3">
                        <label for="editEmail" class="form-label">Email Address <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" id="editEmail" name="email" required>
                        <div class="invalid-feedback">A valid email is required.</div>
                    </div>
                    <div class="mb-3">
                        <label for="editPhone" class="form-label">Phone</label>
                        <input type="tel" class="form-control" id="editPhone" name="phone">
                    </div>
                    <div class="mb-3">
                        <label for="editRole" class="form-label">Role <span class="text-danger">*</span></label>
                        <select class="form-select" id="editRole" name="role" required>
                            <option value="CUSTOMER">Customer</option>
                            <option value="MANAGER">Manager</option>
                            <option value="ADMIN">Admin</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-warning text-white">
                        <i class="fas fa-save me-1"></i>Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════════════════════════
     MODAL: Reset Password
═══════════════════════════════════════════════════════════════════ -->
<div class="modal fade" id="passwordModal" tabindex="-1" aria-labelledby="passwordModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold" id="passwordModalLabel">
                    <i class="fas fa-key text-info me-2"></i>Reset Password
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/users"
                  id="passwordForm" novalidate>
                <input type="hidden" name="action" value="resetPassword">
                <input type="hidden" name="userId" id="pwdUserId">
                <div class="modal-body pt-3">
                    <p class="text-muted mb-3" id="pwdUserLabel" style="font-size:.87rem;"></p>
                    <div class="mb-3">
                        <label for="newPassword" class="form-label">New Password <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <input type="password" class="form-control" id="newPassword" name="newPassword"
                                   minlength="8" placeholder="Min 8 characters" required>
                            <button class="btn btn-outline-secondary" type="button"
                                    onclick="togglePwd('newPassword', this)" tabindex="-1">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                        <div class="invalid-feedback">Password must be at least 8 characters.</div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-info text-white">
                        <i class="fas fa-key me-1"></i>Reset
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════════════════════════
     MODAL: Delete Confirm
═══════════════════════════════════════════════════════════════════ -->
<div class="modal fade" id="deleteConfirmModal" tabindex="-1" aria-labelledby="deleteConfirmModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content border-danger">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold text-danger" id="deleteConfirmModalLabel">
                    <i class="fas fa-trash me-2"></i>Delete User
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/users" id="deleteForm">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="userId" id="deleteUserId">
                <div class="modal-body pt-2">
                    <p class="mb-1">Are you sure you want to permanently delete</p>
                    <p class="fw-bold mb-3" id="deleteUserName"></p>
                    <div class="alert alert-danger py-2 mb-0" style="font-size:.82rem;">
                        <i class="fas fa-exclamation-triangle me-1"></i>
                        This action cannot be undone. All associated data may be affected.
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger">
                        <i class="fas fa-trash me-1"></i>Delete
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
<script>
/* ─── Modal helpers ────────────────────────────────────────────────── */
function openEditModal(userId, fullName, email, phone, role) {
    document.getElementById('editUserId').value   = userId;
    document.getElementById('editFullName').value = fullName;
    document.getElementById('editEmail').value    = email;
    document.getElementById('editPhone').value    = phone;
    document.getElementById('editRole').value     = role;
    // reset validation state
    document.getElementById('editUserForm').classList.remove('was-validated');
    new bootstrap.Modal(document.getElementById('editUserModal')).show();
}

function openPasswordModal(userId, fullName) {
    document.getElementById('pwdUserId').value  = userId;
    document.getElementById('pwdUserLabel').textContent = 'Resetting password for: ' + fullName;
    document.getElementById('newPassword').value = '';
    document.getElementById('passwordForm').classList.remove('was-validated');
    new bootstrap.Modal(document.getElementById('passwordModal')).show();
}

function openDeleteModal(userId, fullName) {
    document.getElementById('deleteUserId').value         = userId;
    document.getElementById('deleteUserName').textContent = fullName;
    new bootstrap.Modal(document.getElementById('deleteConfirmModal')).show();
}

/* ─── Show/hide password toggle ─────────────────────────────────────── */
function togglePwd(inputId, btn) {
    const inp = document.getElementById(inputId);
    const icon = btn.querySelector('i');
    if (inp.type === 'password') {
        inp.type = 'text';
        icon.className = 'fas fa-eye-slash';
    } else {
        inp.type = 'password';
        icon.className = 'fas fa-eye';
    }
}

/* ─── Bootstrap form validation ─────────────────────────────────────── */
(function () {
    'use strict';
    document.querySelectorAll('form[novalidate]').forEach(form => {
        form.addEventListener('submit', e => {
            if (!form.checkValidity()) {
                e.preventDefault();
                e.stopPropagation();
            }
            form.classList.add('was-validated');
        });
    });
})();

/* ─── Live search (client-side quick filter while typing) ──────────── */
const searchInput = document.getElementById('tableSearch');
if (searchInput) {
    let debounceTimer;
    searchInput.addEventListener('input', () => {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => {
            document.getElementById('filterForm').submit();
        }, 450);
    });
}

/* ─── Auto-dismiss flash alerts ─────────────────────────────────────── */
['flashSuccess', 'flashError'].forEach(id => {
    const el = document.getElementById(id);
    if (el) setTimeout(() => {
        const bsAlert = bootstrap.Alert.getOrCreateInstance(el);
        bsAlert.close();
    }, 5000);
});
</script>
</body>
</html>
<%!
    /* Helper: escape single-quotes for inline JS string literals */
    private String escapeJs(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n").replace("\r", "");
    }
%>
