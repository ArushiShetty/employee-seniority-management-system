<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hal.hrms.model.Employee" %>
<%@ page import="com.hal.hrms.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"ADMIN".equals(currentUser.getUserRole())) {
        response.sendRedirect("login");
        return;
    }
    
    Boolean isEditObj = (Boolean) request.getAttribute("isEdit");
    boolean isEdit = isEditObj != null && isEditObj.booleanValue();
    Employee emp = (Employee) request.getAttribute("employee");
    if (emp == null) {
        emp = new Employee();
    }
    
    java.text.SimpleDateFormat sdfInput = new java.text.SimpleDateFormat("yyyy-MM-dd");
    String promoDateStr = emp.getPromotionDate() != null ? sdfInput.format(emp.getPromotionDate()) : "";
    String dojDateStr = emp.getDateOfJoining() != null ? sdfInput.format(emp.getDateOfJoining()) : "";
    String dobDateStr = emp.getDateOfBirth() != null ? sdfInput.format(emp.getDateOfBirth()) : "";
    
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><%= isEdit ? "Edit Profile" : "Register Employee" %> - HAL HR Seniority System</title>
    <style>
        :root {
            --hal-navy: #0A2540;
            --hal-blue: #004b87;
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

        /* Main Area */
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

        /* Card components */
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

        /* Forms Layout & Controls */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
            margin-bottom: 1.5rem;
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
            background-color: #ffffff;
        }

        .form-control:focus {
            border-color: var(--hal-blue);
        }

        /* Buttons */
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

        .error-message {
            background-color: #fff5f5;
            border-left: 4px solid var(--danger-red);
            color: var(--danger-red);
            padding: 0.75rem 1rem;
            border-radius: 4px;
            font-size: 0.9rem;
            margin-bottom: 1.5rem;
        }

        .actions-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.5rem;
            gap: 1rem;
            flex-wrap: wrap;
        }
    </style>
    <script type="text/javascript">
        /**
         * Validates Employee Creation/Edition Form
         */
        function validateEmployeeForm() {
            var empId = document.getElementById("employeeId").value.trim();
            var empName = document.getElementById("employeeName").value.trim();
            var dobStr = document.getElementById("dateOfBirth").value;
            var dojStr = document.getElementById("dateOfJoining").value;
            var promoStr = document.getElementById("promotionDate").value;

            if (empId === "" || empName === "") {
                alert("Employee ID and Name cannot be blank.");
                return false;
            }

            if (empId.length < 3) {
                alert("Please enter a valid Employee ID.");
                return false;
            }

            if (!dobStr || !dojStr || !promoStr) {
                alert("Please fill in all date fields (Date of Birth, Date of Joining, Promotion Date).");
                return false;
            }

            var dob = new Date(dobStr);
            var doj = new Date(dojStr);
            var promo = new Date(promoStr);

            // Rule: DOJ must be after DOB (at least 18 years old)
            var ageAtJoining = doj.getFullYear() - dob.getFullYear();
            if (ageAtJoining < 18) {
                alert("Validation Error: Date of Joining must represent an age of at least 18 years from Date of Birth.");
                return false;
            }

            // Rule: Promotion date must be on or after DOJ
            if (promo < doj) {
                alert("Validation Error: Current Grade Promotion Date cannot be earlier than Date of Joining.");
                return false;
            }

            return true;
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
                <li class="sidebar-item"><a href="seniority">Seniority Engine</a></li>
                <li class="sidebar-item"><a href="employees?action=list">Employee Roster</a></li>
                <li class="sidebar-item <%= !isEdit ? "active" : "" %>"><a href="employees?action=new">Add Employee</a></li>
                <li class="sidebar-item" style="margin-top: auto;"><a href="logout" class="btn-logout" style="color: #ff8888;">Logout</a></li>
            </ul>
        </div>

        <!-- Main Content Area -->
        <div class="main-content">
            <div class="top-bar">
                <div class="top-bar-title"><%= isEdit ? "Modify Employee File" : "Register Employee File" %></div>
                <div class="user-profile">
                    <span class="user-badge"><%= currentUser.getUserRole() %></span>
                    <span>Welcome, <strong><%= currentUser.getEmployeeName() %></strong></span>
                </div>
            </div>

            <!-- Page Container -->
            <div class="page-container">
                <div class="actions-bar">
                    <div>
                        <h2 style="color: var(--hal-navy); font-weight: 700;"><%= isEdit ? "Edit Employee Profile" : "Add New Employee Profile" %></h2>
                        <p style="color: var(--text-light); font-size: 0.9rem;">Fill in the master data fields. All parameters affect seniority ranking.</p>
                    </div>
                    <div>
                        <a href="employees?action=list" class="btn btn-secondary">&larr; Return to Roster</a>
                    </div>
                </div>

                <% if (error != null) { %>
                    <div class="error-message">
                        <%= error %>
                    </div>
                <% } %>

                <!-- Form Card -->
                <div class="card">
                    <h3 class="card-title">Employee Profile Parameters</h3>
                    
                    <form action="employees" method="post" onsubmit="return validateEmployeeForm();">
                        <input type="hidden" name="isEditMode" value="<%= isEdit %>">

                        <div class="form-grid">
                            <!-- Employee ID -->
                            <div class="form-group">
                                <label for="employeeId" class="form-label">Employee ID (Permanent)</label>
                                <input type="text" id="employeeId" name="employeeId" class="form-control" 
                                       placeholder="e.g. 103225" required value="<%= emp.getEmployeeId() != null ? emp.getEmployeeId() : "" %>"
                                       <%= isEdit ? "readonly style='background-color: #e2e8f0; cursor: not-allowed;'" : "" %>>
                                <% if (isEdit) { %>
                                    <span style="font-size: 0.75rem; color: var(--text-light);">Primary identifiers are non-modifiable.</span>
                                <% } %>
                            </div>

                            <!-- Employee Name -->
                            <div class="form-group">
                                <label for="employeeName" class="form-label">Full Name</label>
                                <input type="text" id="employeeName" name="employeeName" class="form-control" 
                                       placeholder="Enter Full Name" required value="<%= emp.getEmployeeName() != null ? emp.getEmployeeName() : "" %>">
                            </div>

                            <!-- Department -->
                            <div class="form-group">
                                <label for="department" class="form-label">Department</label>
                                <input type="text" id="department" name="department" class="form-control" 
                                       placeholder="e.g. OVERHAUL, LCA, SERVICES" required value="<%= emp.getDepartment() != null ? emp.getDepartment() : "" %>">
                            </div>

                            <!-- Designation -->
                            <div class="form-group">
                                <label for="designation" class="form-label">Designation</label>
                                <input type="text" id="designation" name="designation" class="form-control" 
                                       placeholder="e.g. GM(O), AGM, HST(F)-J" required value="<%= emp.getDesignation() != null ? emp.getDesignation() : "" %>">
                            </div>

                            <!-- Grade selection -->
                            <div class="form-group">
                                <label for="grade" class="form-label">Grade</label>
                                <select id="grade" name="grade" class="form-control" required>
                                    <% for (int g = 1; g <= 10; g++) { 
                                        String currentG = "Grade " + g;
                                        boolean selected = currentG.equals(emp.getGrade());
                                    %>
                                        <option value="<%= currentG %>" <%= selected ? "selected" : "" %>><%= currentG %></option>
                                    <% } %>
                                </select>
                            </div>

                            <!-- Level (Hidden for backend compatibility) -->
                            <input type="hidden" name="empLevel" value="Level 1">

                            <!-- Date of Birth -->
                            <div class="form-group">
                                <label for="dateOfBirth" class="form-label">Date of Birth</label>
                                <input type="date" id="dateOfBirth" name="dateOfBirth" class="form-control" required value="<%= dobDateStr %>">
                            </div>

                            <!-- Date of Joining -->
                            <div class="form-group">
                                <label for="dateOfJoining" class="form-label">Date of Joining (DOJ)</label>
                                <input type="date" id="dateOfJoining" name="dateOfJoining" class="form-control" required value="<%= dojDateStr %>">
                            </div>

                            <!-- Promotion Date -->
                            <div class="form-group">
                                <label for="promotionDate" class="form-label">Current Grade Promotion Date</label>
                                <input type="date" id="promotionDate" name="promotionDate" class="form-control" required value="<%= promoDateStr %>">
                            </div>
                        </div>

                        <div style="display: flex; gap: 1rem; margin-top: 2rem;">
                            <button type="submit" class="btn btn-primary"><%= isEdit ? "Update File" : "Save Record" %></button>
                            <a href="employees?action=list" class="btn btn-secondary">Cancel</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
