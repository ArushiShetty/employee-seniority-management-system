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

        <div class="login-header">
            <div style="display: flex; justify-content: center; align-items: center; gap: 0.5rem; margin-bottom: 1.25rem;">
                <svg viewBox="0 0 100 100" style="width: 55px; height: 55px;">
                    <circle cx="50" cy="50" r="40" fill="#004b87" opacity="0.15" stroke="#004b87" stroke-width="2"/>
                    <ellipse cx="50" cy="50" rx="40" ry="12" fill="none" stroke="#004b87" stroke-width="1" opacity="0.4"/>
                    <ellipse cx="50" cy="50" rx="12" ry="40" fill="none" stroke="#004b87" stroke-width="1" opacity="0.4"/>
                    <!-- Jet trajectory streak -->
                    <path d="M15,80 Q50,45 80,25" fill="none" stroke="#FF9933" stroke-width="3.5" stroke-linecap="round"/>
                    <!-- Jet icon -->
                    <path d="M80,25 L76,32 L69,27 Z" fill="#FF9933"/>
                </svg>
                <div style="display: flex; flex-direction: column; text-align: left; line-height: 1.1;">
                    <span style="font-size: 1.1rem; font-weight: bold; color: var(--hal-navy); letter-spacing: 1px;">हिएलि</span>
                    <span style="font-size: 1.5rem; font-weight: 900; color: var(--hal-blue); letter-spacing: 2px; font-style: italic;">HAL</span>
                </div>
            </div>
            
            <h2 style="font-size: 1.25rem; font-weight: 800; color: var(--hal-navy); margin-bottom: 0.25rem; text-transform: uppercase; letter-spacing: 0.5px;">Hindustan Aeronautics Limited</h2>
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
