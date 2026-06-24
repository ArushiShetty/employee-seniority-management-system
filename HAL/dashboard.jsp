<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hal.hrms.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login");
        return;
    }
    Integer totalEmployees = (Integer) request.getAttribute("totalEmployees");
    Integer adminCount = (Integer) request.getAttribute("adminCount");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dashboard - HAL HR Seniority System</title>
    <style>
        :root {
            --hal-navy: #0A2540;
            --hal-blue: #004b87;
            --hal-accent: #007bc4;
            --text-dark: #2d3748;
            --text-light: #718096;
            --bg-light: #f7fafc;
            --bg-card: #ffffff;
            --border-color: #cbd5e0;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: Arial, sans-serif;
            color: var(--text-dark);
            background-color: var(--bg-light);
            line-height: 1.5;
        }

        /* App Layout Grid */
        .app-container {
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar Navigation */
        .sidebar {
            width: 260px;
            background-color: var(--hal-navy);
            color: #ffffff;
            display: flex;
            flex-direction: column;
            padding: 1.5rem 1rem;
        }

        .sidebar-brand {
            font-size: 1.25rem;
            font-weight: bold;
            padding-bottom: 2rem;
            border-bottom: 1px solid rgba(255,255,255,0.15);
            margin-bottom: 1.5rem;
        }

        .sidebar-menu {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .sidebar-item a {
            display: block;
            color: rgba(255,255,255,0.8);
            text-decoration: none;
            padding: 0.75rem 1rem;
            border-radius: 6px;
            font-weight: 500;
            transition: all 0.2s ease;
        }

        .sidebar-item a:hover,
        .sidebar-item.active a {
            background-color: var(--hal-blue);
            color: #ffffff;
            padding-left: 1.25rem;
        }

        /* Main Section */
        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .top-bar {
            background-color: #ffffff;
            height: 70px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 2rem;
            border-bottom: 1px solid var(--border-color);
        }

        .top-bar-title {
            font-size: 1.25rem;
            font-weight: bold;
            color: var(--hal-navy);
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .user-badge {
            background-color: #e2e8f0;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: bold;
            color: var(--hal-navy);
        }

        .btn-logout {
            color: #e53e3e;
            text-decoration: none;
            font-weight: bold;
            font-size: 0.9rem;
        }

        .page-container {
            padding: 2rem;
            max-width: 1200px;
            width: 100%;
            margin: 0 auto;
        }

        /* Card Component */
        .card {
            background-color: var(--bg-card);
            border-radius: 8px;
            border: 1px solid var(--border-color);
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        }

        .card-title {
            font-size: 1.1rem;
            font-weight: bold;
            color: var(--hal-navy);
            margin-bottom: 1.25rem;
            border-bottom: 2px solid var(--bg-light);
            padding-bottom: 0.5rem;
        }

        /* Stats Blocks */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background-color: var(--bg-card);
            padding: 1.5rem;
            border-radius: 8px;
            border: 1px solid var(--border-color);
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .stat-label {
            font-size: 0.875rem;
            font-weight: bold;
            color: var(--text-light);
            text-transform: uppercase;
        }

        .stat-value {
            font-size: 2rem;
            font-weight: bold;
            color: var(--hal-navy);
        }

        /* Buttons styling */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0.625rem 1.25rem;
            font-size: 0.95rem;
            font-weight: bold;
            border-radius: 4px;
            text-decoration: none;
            cursor: pointer;
            border: 1px solid transparent;
            transition: background-color 0.2s;
        }

        .btn-primary {
            background-color: var(--hal-blue);
            color: #ffffff;
        }

        .btn-primary:hover {
            background-color: var(--hal-navy);
        }

        .btn-secondary {
            background-color: #e2e8f0;
            color: var(--text-dark);
            border-color: var(--border-color);
        }

        .btn-secondary:hover {
            background-color: #cbd5e0;
        }
    </style>
</head>
<body>

    <div class="app-container" style="position: relative; padding-top: 4px;">
        <!-- Tricolor Top Accent -->
        <div style="height: 4px; width: 100%; position: absolute; top: 0; left: 0; background: linear-gradient(to right, #FF9933 33.33%, #FFFFFF 33.33%, #FFFFFF 66.66%, #138808 66.66%); z-index: 100;"></div>

        <!-- Sidebar Navigation -->
        <div class="sidebar" style="position: relative; overflow: hidden; padding-top: 2rem;">
            <!-- Jet watermark inside sidebar -->
            <svg style="position: absolute; bottom: -20px; right: -20px; width: 120px; height: 120px; opacity: 0.05; transform: rotate(-35deg); color: #ffffff; pointer-events: none;" viewBox="0 0 100 100" fill="currentColor">
                <path d="M50 5 L53 25 L85 55 L85 62 L54 50 L53 85 L65 92 L65 95 L50 90 L35 95 L35 92 L47 85 L46 50 L15 62 L15 55 L47 25 Z" />
            </svg>

            <div style="display: flex; align-items: center; gap: 0.5rem; padding-bottom: 1.5rem; border-bottom: 1px solid rgba(255,255,255,0.15); margin-bottom: 1.5rem;">
                <svg viewBox="0 0 100 100" style="width: 45px; height: 45px;">
                    <circle cx="50" cy="50" r="40" fill="#007bc4" opacity="0.25" stroke="#007bc4" stroke-width="2"/>
                    <ellipse cx="50" cy="50" rx="40" ry="12" fill="none" stroke="#007bc4" stroke-width="1" opacity="0.5"/>
                    <ellipse cx="50" cy="50" rx="12" ry="40" fill="none" stroke="#007bc4" stroke-width="1" opacity="0.5"/>
                    <!-- Jet trajectory streak -->
                    <path d="M15,80 Q50,45 80,25" fill="none" stroke="#FF9933" stroke-width="3.5" stroke-linecap="round"/>
                    <!-- Jet icon -->
                    <path d="M80,25 L76,32 L69,27 Z" fill="#FF9933"/>
                </svg>
                <div style="display: flex; flex-direction: column; text-align: left; line-height: 1.1;">
                    <span style="font-size: 0.9rem; font-weight: bold; color: #ffffff; letter-spacing: 1px;">हिएलि</span>
                    <span style="font-size: 1.25rem; font-weight: 900; color: #007bc4; letter-spacing: 2px; font-style: italic;">HAL</span>
                </div>
            </div>
            <ul class="sidebar-menu">
                <li class="sidebar-item active"><a href="dashboard">Dashboard</a></li>
                <li class="sidebar-item"><a href="seniority">Seniority Engine</a></li>
                <li class="sidebar-item"><a href="employees?action=list">Employee Roster</a></li>
                <% if ("ADMIN".equals(currentUser.getUserRole())) { %>
                    <li class="sidebar-item"><a href="employees?action=new">Add Employee</a></li>
                <% } %>
                <li class="sidebar-item" style="margin-top: auto;"><a href="logout" class="btn-logout" style="color: #ff8888;">Logout</a></li>
            </ul>
        </div>

        <!-- Main Content Area -->
        <div class="main-content">
            <!-- Header Top Bar -->
            <div class="top-bar">
                <div class="top-bar-title">HR Seniority Management System</div>
                <div class="user-profile">
                    <span class="user-badge"><%= currentUser.getUserRole() %></span>
                    <span>Welcome, <strong><%= currentUser.getEmployeeName() %></strong></span>
                    <a href="logout" class="btn-logout">Logout</a>
                </div>
            </div>

            <!-- Page Container -->
            <div class="page-container">
                <div style="margin-bottom: 2rem;">
                    <h2 style="color: var(--hal-navy); font-weight: 700;">HR Management Portal</h2>
                    <p style="color: var(--text-light);">Hindustan Aeronautics Limited - Overhaul Division, Bangalore</p>
                </div>

                <!-- Statistics Grid -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <span class="stat-label">Total Employee Files</span>
                        <span class="stat-value"><%= totalEmployees != null ? totalEmployees.toString() : "0" %></span>
                    </div>
                    <div class="stat-card">
                        <span class="stat-label">Authorized HR Operators</span>
                        <span class="stat-value"><%= adminCount != null ? adminCount.toString() : "0" %></span>
                    </div>
                    <div class="stat-card">
                        <span class="stat-label">Active Grades</span>
                        <span class="stat-value">10</span>
                    </div>
                </div>

                <!-- Quick Action Panels -->
                <div class="card">
                    <h3 class="card-title">Quick HR Operations</h3>
                    <div style="display: flex; gap: 1rem; flex-wrap: wrap;">
                        <a href="seniority" class="btn btn-primary">Open Seniority Engine</a>
                        <a href="employees?action=list" class="btn btn-secondary">Search & View Roster</a>
                        <% if ("ADMIN".equals(currentUser.getUserRole())) { %>
                            <a href="employees?action=new" class="btn btn-secondary">Register New Employee</a>
                        <% } %>
                    </div>
                </div>

                <!-- PSU Compliance Notice -->
                <div class="card" style="border-left: 4px solid var(--hal-accent);">
                    <h4 style="color: var(--hal-navy); margin-bottom: 0.5rem; font-weight: 600;">System Notification & Guidelines</h4>
                    <p style="font-size: 0.9rem; color: var(--text-dark);">
                        Seniority calculation is generated dynamically based on official grade-promotion timelines. 
                        To preserve audit trails, all operations performed (updates, modifications, and deletions) 
                        are automatically captured in the database audit log.
                    </p>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
