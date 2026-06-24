<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.hal.hrms.model.Employee" %>
<%@ page import="com.hal.hrms.model.User" %>
<%@ page import="com.hal.hrms.model.Promotion" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login");
        return;
    }
    List employeeList = (List) request.getAttribute("employeeList");
    String searchQuery = (String) request.getAttribute("searchQuery");
    if (searchQuery == null) {
        searchQuery = "";
    }
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MMM-yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Employee Roster - HAL HR Seniority System</title>
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
            background-color: var(--bg-light);
            line-height: 1.5;
        }

        .app-container {
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar Styling */
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

        /* Main Content Container */
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

        /* Tables */
        .table-responsive {
            overflow-x: auto;
            width: 100%;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
            font-size: 0.95rem;
        }

        .data-table th {
            background-color: var(--hal-navy);
            color: #ffffff;
            text-align: left;
            padding: 0.75rem 1rem;
            font-weight: bold;
            border: 1px solid var(--hal-navy);
        }

        .data-table td {
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--border-color);
            color: var(--text-dark);
        }

        .data-table tbody tr:nth-child(even) {
            background-color: var(--bg-light);
        }

        .data-table tbody tr:hover {
            background-color: #ebf8ff;
        }

        /* Forms inputs */
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

        .actions-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.5rem;
            gap: 1rem;
            flex-wrap: wrap;
        }

        @media print {
            .sidebar, .top-bar, .actions-bar, .btn, .no-print, form {
                display: none !important;
            }
            .main-content {
                padding: 0 !important;
            }
            .page-container {
                padding: 0 !important;
                max-width: 100% !important;
            }
            .card {
                border: none !important;
                box-shadow: none !important;
                padding: 0 !important;
            }
            .data-table th {
                background-color: #f2f2f2 !important;
                color: #000000 !important;
                border: 1px solid #000000 !important;
                white-space: normal !important;
            }
            .data-table td {
                border: 1px solid #000000 !important;
                white-space: normal !important;
            }
        }

        /* Modal Backdrop */
        .modal-overlay {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(10, 37, 64, 0.4);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }

        /* Modal Container */
        .modal-container {
            background-color: #ffffff;
            border-radius: 12px;
            width: 90%;
            max-width: 650px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            border: 1px solid var(--border-color);
            animation: modalSlideUp 0.3s ease-out;
            max-height: 85vh;
            display: flex;
            flex-direction: column;
        }

        @keyframes modalSlideUp {
            from {
                transform: translateY(30px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        /* Modal Header */
        .modal-header {
            padding: 1.5rem;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            justify-content: space-between;
            background-color: var(--bg-light);
            border-top-left-radius: 12px;
            border-top-right-radius: 12px;
        }

        .modal-header-title {
            color: var(--hal-navy);
            font-size: 1.25rem;
            font-weight: 700;
        }

        .modal-header-subtitle {
            font-size: 0.85rem;
            color: var(--text-light);
            margin-top: 0.25rem;
        }

        .btn-modal-close {
            background: none;
            border: none;
            color: var(--text-light);
            font-size: 1.75rem;
            cursor: pointer;
            line-height: 1;
            padding: 0.25rem;
            transition: color 0.2s;
        }

        .btn-modal-close:hover {
            color: var(--danger-red);
        }

        /* Modal Body */
        .modal-body {
            padding: 1.5rem;
            overflow-y: auto;
            flex: 1;
        }

        /* Timeline Tree/List */
        .timeline-wrapper {
            position: relative;
            padding-left: 2rem;
            margin: 1rem 0;
            border-left: 2px solid var(--border-color);
        }

        .timeline-item {
            position: relative;
            margin-bottom: 2rem;
        }

        .timeline-item:last-child {
            margin-bottom: 0.5rem;
        }

        .timeline-badge {
            position: absolute;
            left: calc(-2rem - 7px);
            top: 6px;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background-color: var(--border-color);
            border: 2px solid #ffffff;
            box-shadow: 0 0 0 2px var(--border-color);
            transition: all 0.2s ease;
        }

        .timeline-item.primary-assignment .timeline-badge {
            background-color: var(--hal-accent);
            box-shadow: 0 0 0 2px var(--hal-accent);
        }

        .timeline-card {
            background-color: var(--bg-light);
            border-radius: 8px;
            border: 1px solid var(--border-color);
            padding: 1rem;
            transition: all 0.2s ease;
        }

        .timeline-item.primary-assignment .timeline-card {
            border-left: 4px solid var(--hal-accent);
            background-color: #f0f7ff;
        }

        .timeline-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 0.75rem;
            gap: 1rem;
        }

        .timeline-designation {
            font-weight: 700;
            color: var(--hal-navy);
            font-size: 1.05rem;
        }

        /* Assignment Type Tags */
        .assignment-type-tag {
            font-size: 0.75rem;
            font-weight: bold;
            text-transform: uppercase;
            padding: 0.2rem 0.6rem;
            border-radius: 4px;
            white-space: nowrap;
        }

        .type-trainee {
            background-color: #edf2f7;
            color: #4a5568;
        }

        .type-absorption {
            background-color: #ebf8ff;
            color: #2b6cb0;
        }

        .type-cps {
            background-color: #e6fffa;
            color: #234e52;
        }

        .type-dpc {
            background-color: #faf5ff;
            color: #553c9a;
        }

        .type-transfer {
            background-color: #fffaf0;
            color: #dd6b20;
        }

        .type-job-rotation {
            background-color: #f0fff4;
            color: #22543d;
        }

        .type-revised-designation {
            background-color: #e2e8f0;
            color: #4a5568;
        }

        .type-additional-responsibilities {
            background-color: #fff5f5;
            color: #9b2c2c;
        }

        .timeline-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 0.5rem;
            font-size: 0.85rem;
            color: var(--text-dark);
        }

        .detail-item strong {
            color: var(--text-light);
        }

        .no-history {
            text-align: center;
            color: var(--text-light);
            padding: 2rem;
            font-style: italic;
        }
    </style>
    <script type="text/javascript">
        /**
         * Exports HTML Table data directly into a CSV Spreadsheet.
         * Works natively in client web browser without server load.
         */
        function exportTableToCSV(tableId, filename) {
            var csv = [];
            var table = document.getElementById(tableId);
            if (!table) return;

            var rows = table.querySelectorAll("tr");
            
            for (var i = 0; i < rows.length; i++) {
                var row = [];
                var cols = rows[i].querySelectorAll("td, th");
                
                // Skip the Actions column header and cell data if this is admin view
                var limit = cols.length;
                var isAdmin = "<%= currentUser.getUserRole() %>" === "ADMIN";
                if (isAdmin && i > 0) {
                    limit = cols.length - 1; // skip last td (actions)
                } else if (isAdmin && i == 0) {
                    limit = cols.length - 1; // skip last th (actions)
                }

                for (var j = 0; j < limit; j++) {
                    var cellText = cols[j].innerText.trim();
                    cellText = cellText.replace(/"/g, '""'); // Escape double quotes
                    row.push('"' + cellText + '"');
                }
                
                csv.push(row.join(","));
            }

            var csvFile = new Blob([csv.join("\n")], { type: "text/csv;charset=utf-8;" });
            var downloadLink = document.createElement("a");
            
            downloadLink.download = filename;
            downloadLink.href = window.URL.createObjectURL(csvFile);
            downloadLink.style.display = "none";
            document.body.appendChild(downloadLink);
            downloadLink.click();
            document.body.removeChild(downloadLink);
        }
    </script>
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

            <div class="sidebar-brand" style="display: flex; align-items: center; justify-content: center; padding: 0.5rem; background: #ffffff; border-radius: 6px; margin: 0 0.5rem 1.5rem 0.5rem; z-index: 10; box-shadow: 0 2px 8px rgba(0,0,0,0.2);">
                <img src="images/hal-logo.png" alt="HAL Logo" style="max-width: 100%; height: auto; max-height: 38px;">
            </div>
            <ul class="sidebar-menu">
                <li class="sidebar-item"><a href="dashboard">Dashboard</a></li>
                <li class="sidebar-item"><a href="seniority">Seniority Engine</a></li>
                <li class="sidebar-item active"><a href="employees?action=list">Employee Roster</a></li>
                <% if ("ADMIN".equals(currentUser.getUserRole())) { %>
                    <li class="sidebar-item"><a href="employees?action=new">Add Employee</a></li>
                <% } %>
                <li class="sidebar-item" style="margin-top: auto;"><a href="logout" class="btn-logout" style="color: #ff8888;">Logout</a></li>
            </ul>
        </div>

        <!-- Main Content Area -->
        <div class="main-content">
            <div class="top-bar">
                <div class="top-bar-title">Employee Records Directory - Overhaul Division</div>
                <div class="user-profile">
                    <span class="user-badge"><%= currentUser.getUserRole() %></span>
                    <span>Welcome, <strong><%= currentUser.getEmployeeName() %></strong></span>
                </div>
            </div>

            <!-- Page Content -->
            <div class="page-container">
                <div class="actions-bar">
                    <div>
                        <h2 style="color: var(--hal-navy); font-weight: 700;">Active Employees Roster</h2>
                        <p style="color: var(--text-light); font-size: 0.9rem;">Maintain active profiles and trace administrative parameters.</p>
                    </div>
                    <div>
                        <% if ("ADMIN".equals(currentUser.getUserRole())) { %>
                            <a href="employees?action=new" class="btn btn-primary">+ Add New Employee</a>
                        <% } %>
                    </div>
                </div>

                <!-- Search Card -->
                <div class="card" style="padding: 1rem;">
                    <form action="employees" method="get" style="display: flex; gap: 1rem; align-items: center;">
                        <input type="hidden" name="action" value="list">
                        <input type="text" name="query" class="form-control" placeholder="Search by ID, Name, Department, or Designation..." value="<%= searchQuery %>" style="flex: 1;">
                        <button type="submit" class="btn btn-primary">Search</button>
                        <% if (!"".equals(searchQuery)) { %>
                            <a href="employees?action=list" class="btn btn-secondary">Clear</a>
                        <% } %>
                    </form>
                </div>

                <!-- Roster Grid -->
                <div class="card">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                        <h3 class="card-title" style="margin-bottom: 0; border: none;">Employee Directory Listings</h3>
                        <button onclick="exportTableToCSV('rosterTable', 'hal_employee_roster.csv')" class="btn btn-secondary">Export to CSV</button>
                    </div>

                    <div class="table-responsive">
                        <%
                            boolean[] activeGrades = new boolean[11]; // index 1 to 10
                            int activeGradesCount = 0;
                            if (employeeList != null && !employeeList.isEmpty()) {
                                for (int i = 0; i < employeeList.size(); i++) {
                                    Employee emp = (Employee) employeeList.get(i);
                                    for (int g = 1; g <= 10; g++) {
                                        if (emp.getPromotionDateForGrade("Grade " + g) != null) {
                                            if (!activeGrades[g]) {
                                                activeGrades[g] = true;
                                                activeGradesCount++;
                                            }
                                        }
                                    }
                                }
                            }
                            if (activeGradesCount == 0) {
                                if (employeeList != null && !employeeList.isEmpty()) {
                                    Employee emp = (Employee) employeeList.get(0);
                                    String gName = emp.getGrade();
                                    if (gName != null && gName.startsWith("Grade ")) {
                                        try {
                                            int g = Integer.parseInt(gName.substring(6).trim());
                                            activeGrades[g] = true;
                                            activeGradesCount = 1;
                                        } catch (Exception e) {}
                                    }
                                }
                            }
                            int totalColsCount = ("ADMIN".equals(currentUser.getUserRole()) ? 9 : 8) + activeGradesCount;
                        %>
                        <table class="data-table" id="rosterTable">
                            <thead>
                                <tr>
                                    <th rowspan="2" style="vertical-align: middle;">Employee ID</th>
                                    <th rowspan="2" style="vertical-align: middle;">Full Name</th>
                                    <th rowspan="2" style="vertical-align: middle;">Grade</th>
                                    <% if (activeGradesCount > 0) { %>
                                        <th colspan="<%= activeGradesCount %>" style="text-align: center; border-bottom: 1px solid rgba(255,255,255,0.2);">Promotion Dates per Grade (Position)</th>
                                    <% } %>
                                    <th rowspan="2" style="vertical-align: middle;">Date of Joining</th>
                                    <th rowspan="2" style="vertical-align: middle;">Date of Birth</th>
                                    <th rowspan="2" style="vertical-align: middle;">Retirement Date</th>
                                    <th rowspan="2" style="vertical-align: middle;">Department</th>
                                    <th rowspan="2" style="vertical-align: middle;">Designation</th>
                                    <% if ("ADMIN".equals(currentUser.getUserRole())) { %>
                                        <th rowspan="2" class="no-print" style="width: 130px; text-align: center; vertical-align: middle;">Actions</th>
                                    <% } %>
                                </tr>
                                <tr>
                                    <% for (int g = 10; g >= 1; g--) { 
                                        if (activeGrades[g]) {
                                            String dName = Employee.getDesignationForGrade("Grade " + g);
                                            String shortD = dName.indexOf("(") > -1 ? dName.substring(dName.indexOf("(")+1, dName.indexOf(")")) : dName;
                                    %>
                                        <th style="font-size: 0.8rem; padding: 0.5rem; text-align: center; min-width: 90px;">
                                            Gr <%= g %><br><span style="font-size:0.7rem; font-weight:normal; opacity:0.85;"><%= shortD %></span>
                                        </th>
                                    <% 
                                        }
                                    } %>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (employeeList != null && !employeeList.isEmpty()) {
                                        for (int i = 0; i < employeeList.size(); i++) {
                                            Employee emp = (Employee) employeeList.get(i);
                                %>
                                    <tr>
                                        <td><strong><%= emp.getEmployeeId() %></strong></td>
                                        <td>
                                            <a href="javascript:void(0)" onclick="showTimelineModal('<%= emp.getEmployeeId() %>')" style="color: var(--hal-blue); text-decoration: underline; font-weight: 600;"><%= emp.getEmployeeName() %></a>
                                            <div id="history-data-<%= emp.getEmployeeId() %>" style="display: none;">
                                                [
                                                <%
                                                    List history = emp.getHistoryList();
                                                    if (history != null) {
                                                        for (int j = 0; j < history.size(); j++) {
                                                            Promotion promo = (Promotion) history.get(j);
                                                            String validFromStr = promo.getValidFrom() != null ? sdf.format(promo.getValidFrom()) : "N/A";
                                                            String validToStr = promo.getValidTo() != null ? sdf.format(promo.getValidTo()) : "Present";
                                                            String promoDateStr = promo.getPromotionDate() != null ? sdf.format(promo.getPromotionDate()) : "N/A";
                                                            String des = promo.getDesignation() != null ? promo.getDesignation() : "";
                                                            des = des.replace("\\", "\\\\").replace("\"", "\\\"");
                                                            String gr = promo.getGrade() != null ? promo.getGrade() : "";
                                                            gr = gr.replace("\\", "\\\\").replace("\"", "\\\"");
                                                            String type = promo.getAssignmentType() != null ? promo.getAssignmentType() : "";
                                                            type = type.replace("\\", "\\\\").replace("\"", "\\\"");
                                                            String ord = promo.getOrderNumber() != null ? promo.getOrderNumber() : "N/A";
                                                            ord = ord.replace("\\", "\\\\").replace("\"", "\\\"");
                                                %>
                                                    {
                                                        "grade": "<%= gr %>",
                                                        "promotionDate": "<%= promoDateStr %>",
                                                        "designation": "<%= des %>",
                                                        "validFrom": "<%= validFromStr %>",
                                                        "validTo": "<%= validToStr %>",
                                                        "isPrimary": <%= promo.getIsPrimary() %>,
                                                        "assignmentType": "<%= type %>",
                                                        "orderNumber": "<%= ord %>"
                                                    }<%= (j < history.size() - 1) ? "," : "" %>
                                                <%
                                                        }
                                                    }
                                                %>
                                                ]
                                            </div>
                                        </td>
                                        <td><%= emp.getGrade() %></td>
                                        
                                        <% for (int g = 10; g >= 1; g--) { 
                                            if (activeGrades[g]) {
                                                java.util.Date pDate = emp.getPromotionDateForGrade("Grade " + g);
                                        %>
                                            <td style="text-align: center; font-size: 0.85rem;">
                                                <%= pDate != null ? sdf.format(pDate) : "-" %>
                                            </td>
                                        <% 
                                            }
                                        } %>
                                        
                                        <td><%= sdf.format(emp.getDateOfJoining()) %></td>
                                        <td><%= sdf.format(emp.getDateOfBirth()) %></td>
                                        <td><%= emp.getDateOfRetirement() != null ? sdf.format(emp.getDateOfRetirement()) : "N/A" %></td>
                                        <td><%= emp.getDepartment() %></td>
                                        <td><%= emp.getDesignation() %></td>
                                        <% if ("ADMIN".equals(currentUser.getUserRole())) { %>
                                            <td class="no-print" style="text-align: center;">
                                                <a href="employees?action=edit&id=<%= emp.getEmployeeId() %>" style="color: var(--hal-blue); text-decoration: none; font-weight: bold; margin-right: 0.75rem;">Edit</a>
                                                <a href="employees?action=delete&id=<%= emp.getEmployeeId() %>" onclick="return confirm('Are you sure you want to delete this employee?');" style="color: var(--danger-red); text-decoration: none; font-weight: bold;">Delete</a>
                                            </td>
                                        <% } %>
                                    </tr>
                                <%
                                        }
                                    } else {
                                %>
                                    <tr>
                                        <td colspan="<%= totalColsCount %>" style="text-align: center; color: var(--text-light); padding: 2rem;">
                                            No employee records found.
                                        </td>
                                    </tr>
                                <%
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Timeline Modal -->
    <div id="timelineModal" class="modal-overlay">
        <div class="modal-container">
            <div class="modal-header">
                <div>
                    <h3 class="modal-header-title" id="modalEmployeeName">Employee Name</h3>
                    <div class="modal-header-subtitle">Employee ID: <span id="modalEmployeeId">N/A</span></div>
                </div>
                <button class="btn-modal-close" onclick="closeTimelineModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="timeline-wrapper" id="timelineContent">
                    <!-- Dynamic Timeline Content will be inserted here -->
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        function showTimelineModal(empId) {
            var dataElement = document.getElementById("history-data-" + empId);
            var history = [];
            if (dataElement) {
                try {
                    history = JSON.parse(dataElement.textContent || dataElement.innerText);
                } catch(e) {
                    console.error("Error parsing history JSON for employee " + empId, e);
                }
            }
            var empName = "";
            
            // Find employee name
            var rows = document.querySelectorAll("#rosterTable tbody tr");
            for (var i = 0; i < rows.length; i++) {
                var cellId = rows[i].cells[0].innerText.trim();
                if (cellId === empId) {
                    // Link is inside the second cell
                    empName = rows[i].cells[1].innerText.trim();
                    break;
                }
            }
            
            document.getElementById("modalEmployeeId").innerText = empId;
            document.getElementById("modalEmployeeName").innerText = empName;
            
            var timelineContainer = document.getElementById("timelineContent");
            timelineContainer.innerHTML = "";
            
            if (!history || history.length === 0) {
                timelineContainer.innerHTML = "<div class='no-history'>No promotion or assignment history recorded for this employee.</div>";
            } else {
                // Sort history by validFrom to make sure it's chronological
                var months = { "Jan":0, "Feb":1, "Mar":2, "Apr":3, "May":4, "Jun":5, "Jul":6, "Aug":7, "Sep":8, "Oct":9, "Nov":10, "Dec":11 };
                function parseCustomDate(dateStr) {
                    if (!dateStr || dateStr === "N/A" || dateStr === "Present") return new Date();
                    var parts = dateStr.split("-");
                    if (parts.length < 3) return new Date();
                    var day = parseInt(parts[0], 10);
                    var month = months[parts[1]];
                    var year = parseInt(parts[2], 10);
                    return new Date(year, month, day);
                }
                
                // Clone and sort
                var sortedHistory = [];
                for (var k = 0; k < history.length; k++) {
                    sortedHistory.push(history[k]);
                }
                sortedHistory.sort(function(a, b) {
                    return parseCustomDate(a.validFrom) - parseCustomDate(b.validFrom);
                });
                
                var html = "";
                for (var i = 0; i < sortedHistory.length; i++) {
                    var item = sortedHistory[i];
                    var badgeClass = item.isPrimary ? "badge-primary" : "badge-secondary";
                    var typeClass = "type-" + item.assignmentType.toLowerCase().replace(/[^a-z0-9]/g, "-");
                    
                    html += "<div class='timeline-item " + (item.isPrimary ? "primary-assignment" : "") + "'>";
                    html += "  <div class='timeline-badge " + badgeClass + "'></div>";
                    html += "  <div class='timeline-card'>";
                    html += "    <div class='timeline-header'>";
                    html += "      <span class='timeline-designation'>Pos Code: " + item.designation + "</span>";
                    html += "      <span class='assignment-type-tag " + typeClass + "'>" + item.assignmentType + "</span>";
                    html += "    </div>";
                    html += "    <div class='timeline-details'>";
                    html += "      <div class='detail-item'><strong>Grade:</strong> " + item.grade + "</div>";
                    html += "      <div class='detail-item'><strong>Promotion Date:</strong> " + item.promotionDate + "</div>";
                    html += "      <div class='detail-item'><strong>Duration:</strong> " + item.validFrom + " to " + item.validTo + "</div>";
                    html += "      <div class='detail-item'><strong>Order Number:</strong> " + item.orderNumber + "</div>";
                    html += "    </div>";
                    html += "  </div>";
                    html += "</div>";
                }
                timelineContainer.innerHTML = html;
            }
            
            document.getElementById("timelineModal").style.display = "flex";
        }
        
        function closeTimelineModal() {
            document.getElementById("timelineModal").style.display = "none";
        }
        
        // Close modal on click outside content
        window.onclick = function(event) {
            var modal = document.getElementById("timelineModal");
            if (event.target == modal) {
                modal.style.display = "none";
            }
        }
    </script>
</body>
</html>
