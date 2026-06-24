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
            transition: transform 0.3s cubic-bezier(0.25, 0.8, 0.25, 1), box-shadow 0.3s ease, border-color 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 16px rgba(0, 75, 135, 0.12);
            border-color: var(--hal-blue);
        }

        .stat-label {
            font-size: 0.875rem;
            font-weight: bold;
            color: var(--text-light);
            text-transform: uppercase;
        }

        /* --- HAL JET ANIMATIONS --- */
        @keyframes jetFloat {
            0% { transform: translateY(0) rotate(-35deg) scale(1); }
            50% { transform: translateY(-8px) rotate(-33deg) scale(1.03); }
            100% { transform: translateY(0) rotate(-35deg) scale(1); }
        }
        .jet-animated {
            animation: jetFloat 6s ease-in-out infinite;
        }

        @keyframes jetGlide {
            0% { transform: translate(-100px, 10px) rotate(45deg) scale(0.6); opacity: 0; }
            30% { opacity: 0.25; }
            100% { transform: translate(120px, -10px) rotate(45deg) scale(0.8); opacity: 0; }
        }
        .jet-glide {
            animation: jetGlide 3.5s cubic-bezier(0.25, 0.8, 0.25, 1) forwards;
            animation-delay: 0.5s;
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
            <svg class="jet-animated" style="position: absolute; bottom: -20px; right: -20px; width: 120px; height: 120px; opacity: 0.05; transform-origin: center; color: #ffffff; pointer-events: none;" viewBox="0 0 100 100" fill="currentColor">
                <path d="M50 5 L53 25 L85 55 L85 62 L54 50 L53 85 L65 92 L65 95 L50 90 L35 95 L35 92 L47 85 L46 50 L15 62 L15 55 L47 25 Z" />
            </svg>

            <div class="sidebar-brand" style="display: flex; align-items: center; justify-content: center; padding: 0.5rem; background: #ffffff; border-radius: 6px; margin: 0 0.5rem 1.5rem 0.5rem; z-index: 10; box-shadow: 0 2px 8px rgba(0,0,0,0.2);">
                <img src="images/hal-logo.png" alt="HAL Logo" style="max-width: 100%; height: auto; max-height: 38px;">
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
                <div class="top-bar-title">HR Seniority Management System - Overhaul Division</div>
                <div class="user-profile">
                    <span class="user-badge"><%= currentUser.getUserRole() %></span>
                    <span>Welcome, <strong><%= currentUser.getEmployeeName() %></strong></span>
                    <a href="logout" class="btn-logout">Logout</a>
                </div>
            </div>

            <!-- Page Container -->
            <div class="page-container">
                <div style="margin-bottom: 2rem; position: relative; overflow: hidden;">
                    <h2 style="color: var(--hal-navy); font-weight: 700;">HR Management Portal</h2>
                    <p style="color: var(--text-light);">Hindustan Aeronautics Limited - Overhaul Division, Bangalore</p>
                    <!-- Jet silhouette that glides across title when page loads -->
                    <div style="position: absolute; right: 0; top: 0; width: 100px; height: 40px; overflow: hidden; pointer-events: none;">
                        <svg class="jet-glide" viewBox="0 0 100 100" fill="currentColor" style="width: 24px; height: 24px; color: var(--hal-blue); opacity: 0.15; transform: rotate(90deg);">
                            <path d="M50 5 L53 25 L85 55 L85 62 L54 50 L53 85 L65 92 L65 95 L50 90 L35 95 L35 92 L47 85 L46 50 L15 62 L15 55 L47 25 Z" />
                        </svg>
                    </div>
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
