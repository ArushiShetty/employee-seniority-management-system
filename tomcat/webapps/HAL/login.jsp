<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login - HAL HR Seniority Management System</title>
    <style>
        :root {
            --hal-navy: #0A2540;
            --hal-blue: #004b87;
            --text-dark: #2d3748;
            --text-light: #718096;
            --bg-light: #f7fafc;
            --border-color: #cbd5e0;
            --danger-red: #e53e3e;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: Arial, sans-serif;
            color: var(--text-dark);
            background-color: var(--hal-navy);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            line-height: 1.5;
        }

        .login-card {
            background: #ffffff;
            padding: 2.5rem;
            border-radius: 12px;
            width: 100%;
            max-width: 440px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.25);
            position: relative;
            overflow: hidden;
        }

        .login-header {
            text-align: center;
            margin-bottom: 2rem;
        }

        .login-logo {
            font-size: 1.75rem;
            font-weight: bold;
            color: var(--hal-navy);
            margin-bottom: 0.5rem;
        }

        .login-subtitle {
            font-size: 0.9rem;
            color: var(--text-light);
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 0.375rem;
        }

        .form-label {
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--text-dark);
        }

        .form-control {
            padding: 0.625rem;
            border: 1px solid var(--border-color);
            border-radius: 4px;
            font-size: 0.95rem;
            width: 100%;
            outline: none;
        }

        .form-control:focus {
            border-color: var(--hal-blue);
        }

        .btn {
            display: block;
            width: 100%;
            padding: 0.75rem;
            font-size: 0.95rem;
            font-weight: bold;
            border-radius: 4px;
            border: none;
            cursor: pointer;
            background-color: var(--hal-blue);
            color: #ffffff;
            transition: background-color 0.2s;
        }

        .btn:hover {
            background-color: var(--hal-navy);
        }

        .error-message {
            background-color: #fff5f5;
            border-left: 4px solid var(--danger-red);
            color: var(--danger-red);
            padding: 0.75rem 1rem;
            border-radius: 4px;
            font-size: 0.9rem;
            margin-bottom: 1.25rem;
        }
    </style>
</head>
<body>

    <!-- Jet watermark background -->
    <svg style="position: fixed; bottom: -5%; right: -5%; width: 45%; height: 45%; opacity: 0.04; transform: rotate(-35deg); color: #ffffff; pointer-events: none;" viewBox="0 0 100 100" fill="currentColor">
        <path d="M50 5 L53 25 L85 55 L85 62 L54 50 L53 85 L65 92 L65 95 L50 90 L35 95 L35 92 L47 85 L46 50 L15 62 L15 55 L47 25 Z" />
    </svg>

    <div class="login-card">
        <!-- Tricolor Top Accent -->
        <div style="height: 5px; width: 100%; position: absolute; top: 0; left: 0; background: linear-gradient(to right, #FF9933 33.33%, #FFFFFF 33.33%, #FFFFFF 66.66%, #138808 66.66%);"></div>

        <div class="login-header" style="text-align: center;">
            <img src="images/hal-logo.png" alt="HAL Logo" style="width: 100%; max-width: 360px; height: auto; display: block; margin: 0 auto 1.5rem auto; border-radius: 8px; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);">
            <h2 style="font-size: 1.25rem; font-weight: 800; color: var(--hal-navy); margin-bottom: 0.25rem; text-transform: uppercase; letter-spacing: 0.5px;">Hindustan Aeronautics Limited</h2>
            <h3 style="font-size: 0.95rem; font-weight: bold; color: var(--hal-blue); margin-bottom: 0.25rem; text-transform: uppercase;">Overhaul Division, Bangalore</h3>
            <div style="height: 2px; width: 60px; background-color: #FF9933; margin: 0.5rem auto;"></div>
            <h3 style="font-size: 0.85rem; font-weight: 700; color: var(--text-light); text-transform: uppercase; letter-spacing: 1px;">Employee Seniority Management System</h3>
        </div>

        <%
            String error = (String) request.getAttribute("error");
            if (error != null) {
        %>
            <div class="error-message">
                <%= error %>
            </div>
        <%
            }
        %>

        <form action="login" method="post">
            <div class="form-group" style="margin-bottom: 1.25rem;">
                <label for="username" class="form-label">Employee ID / Username</label>
                <input type="text" id="username" name="username" class="form-control" placeholder="Enter Username" required autocomplete="off">
            </div>

            <div class="form-group" style="margin-bottom: 1.5rem;">
                <label for="password" class="form-label">Password</label>
                <input type="password" id="password" name="password" class="form-control" placeholder="Enter Password" required>
            </div>

            <button type="submit" class="btn">Login Securely</button>
        </form>
        
        <div style="margin-top: 1.5rem; text-align: center; font-size: 0.8rem; color: var(--text-light);">
            Hindustan Aeronautics Limited &copy; <%= new java.text.SimpleDateFormat("yyyy").format(new java.util.Date()) %>
        </div>
    </div>

</body>
</html>
