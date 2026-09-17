<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Sign In - TechMart</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --bg-color: #0f172a;
            --glass-bg: rgba(30, 41, 59, 0.7);
            --glass-border: rgba(255, 255, 255, 0.1);
            --primary-color: #3b82f6;
            --primary-hover: #2563eb;
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --input-bg: rgba(15, 23, 42, 0.6);
            --error-color: #ef4444;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            background-color: var(--bg-color);
            background-image: 
                radial-gradient(circle at 15% 50%, rgba(59, 130, 246, 0.15) 0%, transparent 50%),
                radial-gradient(circle at 85% 30%, rgba(139, 92, 246, 0.15) 0%, transparent 50%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-main);
            position: relative;
            overflow: hidden;
        }

        /* Abstract shapes for background */
        .shape {
            position: absolute;
            filter: blur(60px);
            z-index: -1;
            opacity: 0.6;
        }
        .shape-1 {
            width: 300px;
            height: 300px;
            background: #3b82f6;
            border-radius: 50%;
            top: -100px;
            left: -100px;
        }
        .shape-2 {
            width: 400px;
            height: 400px;
            background: #8b5cf6;
            border-radius: 50%;
            bottom: -150px;
            right: -100px;
        }

        .login-container {
            width: 100%;
            max-width: 420px;
            padding: 40px;
            background: var(--glass-bg);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid var(--glass-border);
            border-radius: 24px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1);
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .logo-area {
            text-align: center;
            margin-bottom: 32px;
        }

        .logo-icon {
            font-size: 36px;
            color: var(--primary-color);
            margin-bottom: 16px;
            display: inline-block;
            background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .title {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 8px;
            letter-spacing: -0.5px;
        }

        .subtitle {
            font-size: 14px;
            color: var(--text-muted);
        }

        .form-group {
            margin-bottom: 20px;
            position: relative;
        }

        .form-label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 8px;
            color: var(--text-muted);
        }

        .form-control {
            width: 100%;
            padding: 14px 16px;
            padding-left: 44px;
            background: var(--input-bg);
            border: 1px solid var(--glass-border);
            border-radius: 12px;
            color: var(--text-main);
            font-size: 15px;
            transition: all 0.3s ease;
            outline: none;
        }

        .form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
            background: rgba(15, 23, 42, 0.8);
        }

        .input-icon {
            position: absolute;
            left: 16px;
            top: 40px;
            color: var(--text-muted);
            font-size: 16px;
            transition: color 0.3s ease;
        }

        .form-control:focus + .input-icon {
            color: var(--primary-color);
        }

        .btn-submit {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, var(--primary-color) 0%, #60a5fa 100%);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 10px;
            box-shadow: 0 4px 14px rgba(59, 130, 246, 0.4);
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(59, 130, 246, 0.6);
        }

        .btn-submit:active {
            transform: translateY(0);
        }

        .error-message {
            background: rgba(239, 68, 68, 0.1);
            border-left: 4px solid var(--error-color);
            color: #fca5a5;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .back-link {
            display: block;
            text-align: center;
            margin-top: 24px;
            color: var(--text-muted);
            text-decoration: none;
            font-size: 14px;
            transition: color 0.3s ease;
        }

        .back-link:hover {
            color: var(--primary-color);
        }
    </style>
</head>
<body>

    <div class="shape shape-1"></div>
    <div class="shape shape-2"></div>

    <div class="login-container">
        <div class="logo-area">
            <div class="logo-icon">
                <i class="fa-solid fa-shield-halved"></i>
            </div>
            <h1 class="title">Admin Portal</h1>
            <p class="subtitle">Sign in to manage TechMart operations</p>
        </div>

        <% 
            String errorMsg = (String) request.getAttribute("error"); 
            if (errorMsg != null && !errorMsg.isEmpty()) { 
        %>
            <div class="error-message">
                <i class="fa-solid fa-circle-exclamation"></i>
                <span><%= errorMsg %></span>
            </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/admin/login" method="POST">
            <div class="form-group">
                <label class="form-label" for="email">Admin Email</label>
                <input type="email" id="email" name="email" class="form-control" 
                       placeholder="admin@techmart.com" required 
                       value="${email != null ? email : ''}">
                <i class="fa-solid fa-envelope input-icon"></i>
            </div>

            <div class="form-group">
                <label class="form-label" for="password">Password</label>
                <input type="password" id="password" name="password" class="form-control" 
                       placeholder="••••••••" required>
                <i class="fa-solid fa-lock input-icon"></i>
            </div>

            <button type="submit" class="btn-submit">Authenticate</button>
        </form>

        <a href="${pageContext.request.contextPath}/index.jsp" class="back-link">
            <i class="fa-solid fa-arrow-left"></i> Return to Storefront
        </a>
    </div>

</body>
</html>
