<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.hal.hrms.model.Employee" %>
<%@ page import="com.hal.hrms.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login");
        return;
    }
    List seniorityList = (List) request.getAttribute("seniorityList");
    String selectedGrade = (String) request.getAttribute("selectedGrade");
    if (selectedGrade == null) {
        selectedGrade = "ALL";
    }
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MMM-yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Seniority Engine - HAL HR Seniority System</title>
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

        /* Main Workspace */
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

        /* Cards styling */
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

        /* Data Tables */
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

        /* Forms Dropdown */
        .form-control {
            padding: 0.625rem;
            border: 1px solid var(--border-color);
            border-radius: 4px;
            font-size: 0.95rem;
            outline: none;
            background-color: #ffffff;
        }

        .form-control:focus {
            border-color: var(--hal-blue);
        }

        .form-label {
            font-size: 0.95rem;
            font-weight: bold;
            color: var(--text-dark);
        }

        /* Action Buttons */
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

        /* CSS Print Template for PDF Generation */
        @media print {
            .sidebar, .top-bar, .actions-bar, .btn, .no-print {
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
            }
            .data-table td {
                border: 1px solid #000000 !important;
            }
        }
    </style>
    <script type="text/javascript">
        function handleGradeChange() {
            var grade = document.getElementById("gradeFilter").value;
            window.location.href = "seniority?gradeFilter=" + encodeURIComponent(grade);
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
                <li class="sidebar-item"><a href="dashboard">Dashboard</a></li>
                <li class="sidebar-item active"><a href="seniority">Seniority Engine</a></li>
                <li class="sidebar-item"><a href="employees?action=list">Employee Roster</a></li>
                <% if ("ADMIN".equals(currentUser.getUserRole())) { %>
                    <li class="sidebar-item"><a href="employees?action=new">Add Employee</a></li>
                <% } %>
                <li class="sidebar-item" style="margin-top: auto;"><a href="logout" class="btn-logout" style="color: #ff8888;">Logout</a></li>
            </ul>
        </div>

        <!-- Main Content Area -->
        <div class="main-content">
            <div class="top-bar">
                <div class="top-bar-title">Seniority Calculations Engine</div>
                <div class="user-profile">
                    <span class="user-badge"><%= currentUser.getUserRole() %></span>
                    <span>Welcome, <strong><%= currentUser.getEmployeeName() %></strong></span>
                </div>
            </div>

            <!-- Page Container -->
            <div class="page-container">
                <div class="actions-bar">
                    <div>
                        <h2 style="color: var(--hal-navy); font-weight: 700;">Dynamic Seniority Rankings</h2>
                        <p style="color: var(--text-light); font-size: 0.9rem;">Rankings are computed dynamically using the 7-level fallback seniority algorithm.</p>
                    </div>
                    <div class="no-print" style="display: flex; gap: 0.5rem;">
                        <button onclick="window.print()" class="btn btn-secondary">Print Report / PDF</button>
                        <!-- Server-Side Export (Fully Java 1.4 Native) -->
                        <a href="seniority?gradeFilter=<%= selectedGrade %>&export=csv" class="btn btn-primary">Download CSV</a>
                    </div>
                </div>

                <!-- Grade Selection Filter -->
                <div class="card no-print">
                    <div style="display: flex; align-items: center; gap: 1rem; flex-wrap: wrap;">
                        <label for="gradeFilter" class="form-label" style="margin-bottom: 0; white-space: nowrap;">Filter Seniority List by Grade:</label>
                        <select id="gradeFilter" name="gradeFilter" class="form-control" style="max-width: 250px;" onchange="handleGradeChange()">
                            <option value="ALL" <%= "ALL".equals(selectedGrade) ? "selected" : "" %>>All Grades (Global Ranks)</option>
                            <% for (int g = 1; g <= 10; g++) { 
                                String currentG = "Grade " + g;
                                boolean selected = currentG.equals(selectedGrade);
                            %>
                                <option value="<%= currentG %>" <%= selected ? "selected" : "" %>><%= currentG %> (<%= Employee.getDesignationForGrade(currentG) %>)</option>
                            <% } %>
                        </select>
                        <span style="font-size: 0.85rem; color: var(--text-light);">
                            Selecting a single grade shows the internal seniority ranks of employees in that grade.
                        </span>
                    </div>
                </div>

                <!-- Seniority Table -->
                <div class="card">
                    <h3 class="card-title">
                        <%= "ALL".equals(selectedGrade) ? "Organization-Wide Seniority Listings" : selectedGrade + " Seniority Rankings" %>
                    </h3>

                    <div class="table-responsive">
                        <%
                            boolean[] activeGrades = new boolean[11]; // index 1 to 10
                            int activeGradesCount = 0;
                            if (seniorityList != null && !seniorityList.isEmpty()) {
                                for (int i = 0; i < seniorityList.size(); i++) {
                                    Employee emp = (Employee) seniorityList.get(i);
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
                                if (selectedGrade != null && selectedGrade.startsWith("Grade ")) {
                                    try {
                                        int g = Integer.parseInt(selectedGrade.substring(6).trim());
                                        activeGrades[g] = true;
                                        activeGradesCount = 1;
                                    } catch (Exception e) {}
                                } else if (seniorityList != null && !seniorityList.isEmpty()) {
                                    Employee emp = (Employee) seniorityList.get(0);
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
                            
                            int totalColsCount = 4 + activeGradesCount + 5;
                        %>
                        <table class="data-table" id="seniorityTable">
                            <thead>
                                <tr>
                                    <th rowspan="2" style="width: 80px; text-align: center; vertical-align: middle;">Rank</th>
                                    <th rowspan="2" style="vertical-align: middle;">Employee ID</th>
                                    <th rowspan="2" style="vertical-align: middle;">Employee Name</th>
                                    <th rowspan="2" style="vertical-align: middle;">Grade</th>
                                    <% if (activeGradesCount > 0) { %>
                                        <th colspan="<%= activeGradesCount %>" style="text-align: center; border-bottom: 1px solid rgba(255,255,255,0.2);">Promotion Dates per Grade (Position)</th>
                                    <% } %>
                                    <th rowspan="2" style="vertical-align: middle;">Date of Joining</th>
                                    <th rowspan="2" style="vertical-align: middle;">Date of Birth</th>
                                    <th rowspan="2" style="vertical-align: middle;">Retirement Date</th>
                                    <th rowspan="2" style="vertical-align: middle;">Department</th>
                                    <th rowspan="2" style="vertical-align: middle;">Designation</th>
                                </tr>
                                <tr>
                                    <% for (int g = 1; g <= 10; g++) { 
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
                                    if (seniorityList != null && !seniorityList.isEmpty()) {
                                        for (int i = 0; i < seniorityList.size(); i++) {
                                            Employee emp = (Employee) seniorityList.get(i);
                                %>
                                    <tr>
                                        <td style="text-align: center;"><strong><%= emp.getRank() %></strong></td>
                                        <td><strong><%= emp.getEmployeeId() %></strong></td>
                                        <td><%= emp.getEmployeeName() %></td>
                                        <td><%= emp.getGrade() %></td>
                                        
                                        <% for (int g = 1; g <= 10; g++) { 
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
                                    </tr>
                                <%
                                        }
                                    } else {
                                %>
                                    <tr>
                                        <td colspan="<%= totalColsCount %>" style="text-align: center; color: var(--text-light); padding: 2rem;">
                                            No employee records found in this grade category.
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

</body>
</html>
