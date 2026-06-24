<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
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
            max-width: 1400px;
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
            border: 1px solid var(--border-color);
            border-radius: 6px;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.85rem;
        }

        .data-table th {
            background-color: var(--hal-navy);
            color: #ffffff;
            text-align: left;
            padding: 0.6rem 0.8rem;
            font-weight: bold;
            border: 1px solid rgba(255,255,255,0.15);
            white-space: nowrap;
        }

        .data-table td {
            padding: 0.6rem 0.8rem;
            border-bottom: 1px solid var(--border-color);
            border-right: 1px solid var(--border-color);
            color: var(--text-dark);
            white-space: nowrap;
        }

        .data-table tbody tr:nth-child(even) {
            background-color: var(--bg-light);
        }

        .data-table tbody tr:hover {
            background-color: #ebf8ff;
        }

        /* Dropdown and search filters in headers */
        .header-filter-select, .header-filter-input {
            width: 100%;
            margin-top: 4px;
            padding: 3px 5px;
            font-size: 0.75rem;
            color: var(--text-dark);
            background-color: rgba(255, 255, 255, 0.95);
            border: 1px solid var(--border-color);
            border-radius: 4px;
            outline: none;
            font-weight: normal;
        }
        .header-filter-select:focus, .header-filter-input:focus {
            border-color: var(--hal-blue);
            background-color: #ffffff;
            box-shadow: 0 0 0 2px rgba(0, 75, 135, 0.15);
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

        /* Pagination Styling */
        .pagination-container {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-top: 1rem;
            flex-wrap: wrap;
            gap: 1rem;
            font-size: 0.9rem;
            color: var(--text-light);
        }
        .pagination-controls {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .page-btn {
            padding: 0.4rem 0.8rem;
            background-color: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: 4px;
            cursor: pointer;
            font-weight: bold;
            color: var(--text-dark);
            transition: all 0.2s;
        }
        .page-btn:hover:not(:disabled) {
            background-color: var(--hal-blue);
            color: #ffffff;
            border-color: var(--hal-blue);
        }
        .page-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        /* CSS Print Template for PDF Generation */
        @media print {
            .sidebar, .top-bar, .actions-bar, .btn, .no-print, .filter-row {
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

            <div style="display: flex; align-items: center; gap: 0.5rem; padding-bottom: 1.5rem; border-bottom: 1px solid rgba(255,255,255,0.15); margin-bottom: 1.5rem; padding-left: 0.5rem;">
                <svg viewBox="0 0 100 100" style="width: 40px; height: 40px;">
                    <circle cx="50" cy="50" r="40" fill="#007bc4" opacity="0.25" stroke="#007bc4" stroke-width="2"/>
                    <path d="M15,80 Q50,45 80,25" fill="none" stroke="#FF9933" stroke-width="3.5" stroke-linecap="round"/>
                    <path d="M80,25 L76,32 L69,27 Z" fill="#FF9933"/>
                </svg>
                <div style="display: flex; flex-direction: column; text-align: left; line-height: 1.1;">
                    <span style="font-size: 0.8rem; font-weight: bold; color: #ffffff; letter-spacing: 1px;">हिएलि</span>
                    <span style="font-size: 1.1rem; font-weight: 900; color: #007bc4; letter-spacing: 2px; font-style: italic;">HAL</span>
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
                        <a href="seniority?export=csv" class="btn btn-primary">Download CSV</a>
                    </div>
                </div>

                <!-- Grade Selection Filter (Synced to dynamic filter row) -->
                <div class="card no-print">
                    <div style="display: flex; align-items: center; gap: 1rem; flex-wrap: wrap;">
                        <label for="gradeFilter" class="form-label" style="margin-bottom: 0; white-space: nowrap;">Filter Seniority List by Grade:</label>
                        <select id="gradeFilter" class="form-control" style="max-width: 320px;" onchange="syncTopGradeFilter()">
                            <option value="">All Grades (Global Ranks)</option>
                            <option value="Grade 1">Grade I (Assistant Engineer)</option>
                            <option value="Grade 2">Grade II (Engineer)</option>
                            <option value="Grade 3">Grade III (Deputy Manager)</option>
                            <option value="Grade 4">Grade IV (Manager)</option>
                            <option value="Grade 5">Grade V (Senior Manager)</option>
                            <option value="Grade 6">Grade VI (Chief Manager)</option>
                            <option value="Grade 7">Grade VII (Deputy General Manager)</option>
                            <option value="Grade 8">Grade VIII (Additional General Manager)</option>
                            <option value="Grade 9">Grade IX (General Manager)</option>
                            <option value="Grade 10">Grade X (Executive Director)</option>
                        </select>
                        <span style="font-size: 0.85rem; color: var(--text-light);">
                            Selecting a single grade shows the internal seniority ranks of employees in that grade.
                        </span>
                    </div>
                </div>

                <!-- Seniority Table -->
                <div class="card">
                    <h3 class="card-title" id="seniorityTableTitle">
                        Organization-Wide Seniority Listings
                    </h3>

                    <div class="table-responsive">
                        <table class="data-table" id="seniorityTable">
                            <thead>
                                <tr>
                                    <th rowspan="2" style="width: 60px; text-align: center; vertical-align: middle;">Sl No.</th>
                                    <th rowspan="2" style="vertical-align: middle;">Div/Office</th>
                                    <th rowspan="2" style="vertical-align: middle;">Complex</th>
                                    <th rowspan="2" style="vertical-align: middle;">PB No</th>
                                    <th rowspan="2" style="vertical-align: middle;">Name (S/Shri)</th>
                                    <th rowspan="2" style="vertical-align: middle;">Discipline</th>
                                    <th rowspan="2" style="vertical-align: middle;">Present Designation</th>
                                    <th rowspan="2" style="vertical-align: middle;">Present Grade</th>
                                    <th rowspan="2" style="vertical-align: middle;">Gender</th>
                                    <th rowspan="2" style="vertical-align: middle;">Ex DT/MT</th>
                                    <th rowspan="2" style="vertical-align: middle;">Ex Servicemen</th>
                                    <th rowspan="2" style="vertical-align: middle;">PHP</th>
                                    <th rowspan="2" style="vertical-align: middle;">SC/ST/OBC/Gen</th>
                                    <th rowspan="2" style="vertical-align: middle;">DOB</th>
                                    <th rowspan="2" style="vertical-align: middle;">Super Annuation</th>
                                    <th rowspan="2" style="vertical-align: middle;">Date of Joining</th>
                                    <th rowspan="2" style="vertical-align: middle;">Date of Absorption</th>
                                    <th rowspan="2" style="vertical-align: middle;">Date of seniority in present grade</th>
                                    <th id="seniorityInGradesHeader" colspan="10" style="text-align: center; border-bottom: 1px solid rgba(255,255,255,0.2);">Seniority in Grades</th>
                                    <th rowspan="2" style="vertical-align: middle;">Educational Qualification</th>
                                    <th rowspan="2" style="vertical-align: middle;">Remarks</th>
                                </tr>
                                <tr>
                                    <th id="th-grade-1" style="text-align: center; min-width: 85px;">I</th>
                                    <th id="th-grade-2" style="text-align: center; min-width: 85px;">II</th>
                                    <th id="th-grade-3" style="text-align: center; min-width: 85px;">III</th>
                                    <th id="th-grade-4" style="text-align: center; min-width: 85px;">IV</th>
                                    <th id="th-grade-5" style="text-align: center; min-width: 85px;">V</th>
                                    <th id="th-grade-6" style="text-align: center; min-width: 85px;">VI</th>
                                    <th id="th-grade-7" style="text-align: center; min-width: 85px;">VII</th>
                                    <th id="th-grade-8" style="text-align: center; min-width: 85px;">VIII</th>
                                    <th id="th-grade-9" style="text-align: center; min-width: 85px;">IX</th>
                                    <th id="th-grade-10" style="text-align: center; min-width: 85px;">X</th>
                                </tr>
                                <!-- Clean filter dropdowns row -->
                                <tr class="filter-row no-print">
                                    <th></th>
                                    <th><select id="filter-division" class="header-filter-select" onchange="applyFilters()"><option value="">All</option></select></th>
                                    <th><select id="filter-complex" class="header-filter-select" onchange="applyFilters()"><option value="">All</option></select></th>
                                    <th><input type="text" id="filter-employeeId" class="header-filter-input" placeholder="Search ID..." onkeyup="applyFilters()"></th>
                                    <th><input type="text" id="filter-employeeName" class="header-filter-input" placeholder="Search name..." onkeyup="applyFilters()"></th>
                                    <th><select id="filter-discipline" class="header-filter-select" onchange="applyFilters()"><option value="">All</option></select></th>
                                    <th><select id="filter-designation" class="header-filter-select" onchange="applyFilters()"><option value="">All</option></select></th>
                                    <th><select id="filter-grade" class="header-filter-select" onchange="applyFilters()"><option value="">All</option></select></th>
                                    <th><select id="filter-gender" class="header-filter-select" onchange="applyFilters()"><option value="">All</option></select></th>
                                    <th><select id="filter-exDtMt" class="header-filter-select" onchange="applyFilters()"><option value="">All</option></select></th>
                                    <th><select id="filter-exServicemen" class="header-filter-select" onchange="applyFilters()"><option value="">All</option></select></th>
                                    <th><select id="filter-php" class="header-filter-select" onchange="applyFilters()"><option value="">All</option></select></th>
                                    <th><select id="filter-category" class="header-filter-select" onchange="applyFilters()"><option value="">All</option></select></th>
                                    <th><input type="text" id="filter-dob" class="header-filter-input" placeholder="Year..." onkeyup="applyFilters()"></th>
                                    <th><input type="text" id="filter-retDate" class="header-filter-input" placeholder="Year..." onkeyup="applyFilters()"></th>
                                    <th><input type="text" id="filter-doj" class="header-filter-input" placeholder="Year..." onkeyup="applyFilters()"></th>
                                    <th><input type="text" id="filter-doa" class="header-filter-input" placeholder="Year..." onkeyup="applyFilters()"></th>
                                    <th><input type="text" id="filter-promoDate" class="header-filter-input" placeholder="Year..." onkeyup="applyFilters()"></th>
                                    <th id="th-filter-grade-1"></th>
                                    <th id="th-filter-grade-2"></th>
                                    <th id="th-filter-grade-3"></th>
                                    <th id="th-filter-grade-4"></th>
                                    <th id="th-filter-grade-5"></th>
                                    <th id="th-filter-grade-6"></th>
                                    <th id="th-filter-grade-7"></th>
                                    <th id="th-filter-grade-8"></th>
                                    <th id="th-filter-grade-9"></th>
                                    <th id="th-filter-grade-10"></th>
                                    <th><select id="filter-qualification" class="header-filter-select" onchange="applyFilters()"><option value="">All</option></select></th>
                                    <th><input type="text" id="filter-remarks" class="header-filter-input" placeholder="Search..." onkeyup="applyFilters()"></th>
                                </tr>
                            </thead>
                            <tbody id="seniorityTableBody">
                                <!-- Populated dynamically by client JS -->
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination and display count summary -->
                    <div class="pagination-container no-print">
                        <div id="displayCountLabel">Showing 0 to 0 of 0 records</div>
                        <div class="pagination-controls">
                            <label for="pageSizeSelect" style="margin-right: 0.5rem;">Page Size:</label>
                            <select id="pageSizeSelect" onchange="changePageSize()" style="padding: 0.3rem; border-radius: 4px; border: 1px solid var(--border-color); margin-right: 1rem;">
                                <option value="50">50</option>
                                <option value="100" selected>100</option>
                                <option value="200">200</option>
                                <option value="ALL">All</option>
                            </select>
                            <button id="prevPageBtn" class="page-btn" onclick="prevPage()">&larr; Prev</button>
                            <span id="currentPageLabel">Page 1 of 1</span>
                            <button id="nextPageBtn" class="page-btn" onclick="nextPage()">Next &rarr;</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- JSON DATA EMBEDDING FROM JAVA BACKEND -->
    <script type="text/javascript">
        var allEmployees = [
            <%
                java.text.SimpleDateFormat outSdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
                java.text.SimpleDateFormat displaySdf = new java.text.SimpleDateFormat("dd-MMM-yyyy");
                if (seniorityList != null) {
                    for (int i = 0; i < seniorityList.size(); i++) {
                        Employee emp = (Employee) seniorityList.get(i);
                        String dobStr = emp.getDateOfBirth() != null ? outSdf.format(emp.getDateOfBirth()) : "";
                        String dojStr = emp.getDateOfJoining() != null ? outSdf.format(emp.getDateOfJoining()) : "";
                        String doaStr = emp.getDateOfAbsorption() != null ? outSdf.format(emp.getDateOfAbsorption()) : "";
                        String promoStr = emp.getPromotionDate() != null ? outSdf.format(emp.getPromotionDate()) : "";
                        String retStr = emp.getDateOfRetirement() != null ? displaySdf.format(emp.getDateOfRetirement()) : "N/A";
                        
                        String empNameEsc = emp.getEmployeeName() != null ? emp.getEmployeeName().replace("'", "\\'").replace("\"", "\\\"") : "";
                        String deptEsc = emp.getDepartment() != null ? emp.getDepartment().replace("'", "\\'").replace("\"", "\\\"") : "";
                        String desigEsc = emp.getDesignation() != null ? emp.getDesignation().replace("'", "\\'").replace("\"", "\\\"") : "";
                        String divEsc = emp.getDivision() != null ? emp.getDivision().replace("'", "\\'").replace("\"", "\\\"") : "";
                        String compEsc = emp.getComplex() != null ? emp.getComplex().replace("'", "\\'").replace("\"", "\\\"") : "";
                        String discEsc = emp.getDiscipline() != null ? emp.getDiscipline().replace("'", "\\'").replace("\"", "\\\"") : "";
                        String qualEsc = emp.getEducationalQualification() != null ? emp.getEducationalQualification().replace("'", "\\'").replace("\"", "\\\"") : "";
                        String remEsc = emp.getRemarks() != null ? emp.getRemarks().replace("'", "\\'").replace("\"", "\\\"") : "";
            %>
                {
                    employeeId: '<%= emp.getEmployeeId() %>',
                    employeeName: '<%= empNameEsc %>',
                    grade: '<%= emp.getGrade() %>',
                    empLevel: '<%= emp.getEmpLevel() %>',
                    doj: '<%= dojStr %>',
                    dob: '<%= dobStr %>',
                    doa: '<%= doaStr %>',
                    division: '<%= divEsc %>',
                    complex: '<%= compEsc %>',
                    discipline: '<%= discEsc %>',
                    gender: '<%= emp.getGender() %>',
                    exDtMt: '<%= emp.getExDtMt() %>',
                    exServicemen: '<%= emp.getExServicemen() %>',
                    php: '<%= emp.getPhp() %>',
                    category: '<%= emp.getCategory() %>',
                    qualification: '<%= qualEsc %>',
                    remarks: '<%= remEsc %>',
                    designation: '<%= desigEsc %>',
                    retDate: '<%= retStr %>',
                    promoDate: '<%= promoStr %>',
                    history: {
                        <% for (int g = 1; g <= 10; g++) { 
                            Date pd = emp.getPromotionDateForGrade("Grade " + g);
                            String pdStr = pd != null ? outSdf.format(pd) : "";
                        %>
                            'Grade <%= g %>': '<%= pdStr %>'<%= (g < 10) ? "," : "" %>
                        <% } %>
                    }
                }<%= (i < seniorityList.size() - 1) ? "," : "" %>
            <%
                    }
                }
            %>
        ];

        // PAGINATION & FILTERING CONFIGURATION
        var currentPage = 1;
        var pageSize = 100;
        var filteredEmployees = [];

        // Dynamic Formatter helper
        function formatDate(dateString) {
            if (!dateString || dateString === "-") return "";
            var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
            var parts = dateString.split("-");
            if (parts.length !== 3) return dateString;
            var year = parts[0];
            var month = months[parseInt(parts[1]) - 1];
            var day = parts[2];
            return day + "-" + month + "-" + year;
        }

        // Initialize lists and choices on page load
        window.onload = function() {
            populateFilterOptions();
            applyFilters();
        };

        // Populate header dropdowns dynamically from existing unique options
        function populateFilterOptions() {
            var categoricalCols = {
                'division': 'filter-division',
                'complex': 'filter-complex',
                'discipline': 'filter-discipline',
                'grade': 'filter-grade',
                'gender': 'filter-gender',
                'exDtMt': 'filter-exDtMt',
                'exServicemen': 'filter-exServicemen',
                'php': 'filter-php',
                'category': 'filter-category',
                'qualification': 'filter-qualification',
                'designation': 'filter-designation'
            };
            
            for (var key in categoricalCols) {
                var selectId = categoricalCols[key];
                var selectEl = document.getElementById(selectId);
                if (!selectEl) continue;
                
                var uniqueVals = {};
                allEmployees.forEach(function(emp) {
                    var val = emp[key];
                    if (val && val.trim() !== '') {
                        uniqueVals[val] = true;
                    }
                });
                
                var sortedVals = Object.keys(uniqueVals).sort();
                
                selectEl.innerHTML = '<option value="">All</option>';
                sortedVals.forEach(function(val) {
                    var opt = document.createElement('option');
                    opt.value = val;
                    opt.innerText = val;
                    selectEl.appendChild(opt);
                });
            }
        }

        // Top Filter synchronization
        function syncTopGradeFilter() {
            var val = document.getElementById('gradeFilter').value;
            document.getElementById('filter-grade').value = val;
            applyFilters();
        }

        // Filter calculation engine
        function applyFilters() {
            var textFilters = {
                'employeeId': document.getElementById('filter-employeeId').value.toLowerCase(),
                'employeeName': document.getElementById('filter-employeeName').value.toLowerCase(),
                'dob': document.getElementById('filter-dob').value.toLowerCase(),
                'retDate': document.getElementById('filter-retDate').value.toLowerCase(),
                'doj': document.getElementById('filter-doj').value.toLowerCase(),
                'doa': document.getElementById('filter-doa').value.toLowerCase(),
                'promoDate': document.getElementById('filter-promoDate').value.toLowerCase(),
                'remarks': document.getElementById('filter-remarks').value.toLowerCase()
            };
            
            var selectFilters = {
                'division': document.getElementById('filter-division').value,
                'complex': document.getElementById('filter-complex').value,
                'discipline': document.getElementById('filter-discipline').value,
                'grade': document.getElementById('filter-grade').value,
                'gender': document.getElementById('filter-gender').value,
                'exDtMt': document.getElementById('filter-exDtMt').value,
                'exServicemen': document.getElementById('filter-exServicemen').value,
                'php': document.getElementById('filter-php').value,
                'category': document.getElementById('filter-category').value,
                'qualification': document.getElementById('filter-qualification').value,
                'designation': document.getElementById('filter-designation').value
            };

            filteredEmployees = allEmployees.filter(function(emp) {
                // Apply text filters
                for (var key in textFilters) {
                    var q = textFilters[key];
                    if (q !== '') {
                        var val = emp[key] ? emp[key].toLowerCase() : '';
                        // Also check formatted dates for text search inputs
                        if (key === 'dob' || key === 'doj' || key === 'doa' || key === 'promoDate') {
                            val = formatDate(emp[key]).toLowerCase();
                        }
                        if (val.indexOf(q) === -1) return false;
                    }
                }
                
                // Apply select filters
                for (var key in selectFilters) {
                    var q = selectFilters[key];
                    if (q !== '') {
                        var val = emp[key] ? emp[key] : '';
                        if (val !== q) return false;
                    }
                }
                return true;
            });
            
            // Sync top select dropdown in case filter-grade was modified manually
            var gradeVal = document.getElementById('filter-grade').value;
            var topSelect = document.getElementById('gradeFilter');
            if (topSelect) {
                topSelect.value = gradeVal;
            }
            
            // Update title
            var titleEl = document.getElementById('seniorityTableTitle');
            if (titleEl) {
                titleEl.innerText = gradeVal === "" 
                    ? "Organization-Wide Seniority Listings" 
                    : gradeVal + " Seniority Rankings";
            }

            // Dynamic display of Seniority in Grades columns
            var maxGradeVisible = 10;
            if (gradeVal && gradeVal.indexOf("Grade ") === 0) {
                var num = parseInt(gradeVal.substring(6));
                if (!isNaN(num) && num >= 1 && num <= 10) {
                    maxGradeVisible = num;
                }
            }

            var headerEl = document.getElementById('seniorityInGradesHeader');
            if (headerEl) {
                headerEl.colSpan = maxGradeVisible;
                headerEl.style.display = maxGradeVisible > 0 ? '' : 'none';
            }

            for (var g = 1; g <= 10; g++) {
                var thEl = document.getElementById('th-grade-' + g);
                if (thEl) {
                    thEl.style.display = (g <= maxGradeVisible) ? '' : 'none';
                }
                var filterThEl = document.getElementById('th-filter-grade-' + g);
                if (filterThEl) {
                    filterThEl.style.display = (g <= maxGradeVisible) ? '' : 'none';
                }
            }

            currentPage = 1;
            renderTable();
        }

        // Render current paginated view
        function renderTable() {
            var tbody = document.getElementById('seniorityTableBody');
            if (!tbody) return;
            
            tbody.innerHTML = '';
            
            var totalRecords = filteredEmployees.length;
            var startIdx = (currentPage - 1) * pageSize;
            var endIdx = startIdx + pageSize;
            if (endIdx > totalRecords) endIdx = totalRecords;
            
            document.getElementById('displayCountLabel').innerText = 'Showing ' + (totalRecords > 0 ? (startIdx + 1) : 0) + ' to ' + endIdx + ' of ' + totalRecords + ' records';
            
            // Dynamic display of Seniority in Grades columns count
            var maxGradeVisible = 10;
            var gradeVal = document.getElementById('filter-grade').value; // e.g. "Grade 5"
            if (gradeVal && gradeVal.indexOf("Grade ") === 0) {
                var num = parseInt(gradeVal.substring(6));
                if (!isNaN(num) && num >= 1 && num <= 10) {
                    maxGradeVisible = num;
                }
            }
            
            if (totalRecords === 0) {
                tbody.innerHTML = '<tr><td colspan="' + (20 + maxGradeVisible) + '" style="text-align: center; color: var(--text-light); padding: 2rem;">No employee records match the filters.</td></tr>';
                updatePaginationControls(0);
                return;
            }
            
            var pageList = filteredEmployees.slice(startIdx, endIdx);
            
            pageList.forEach(function(emp, index) {
                var tr = document.createElement('tr');
                
                // Build the promotion history columns (I to maxGradeVisible)
                var gradeCols = '';
                for (var g = 1; g <= maxGradeVisible; g++) {
                    var pd = emp.history['Grade ' + g];
                    gradeCols += '<td style="text-align: center; font-size: 0.85rem;">' + (pd ? formatDate(pd) : '-') + '</td>';
                }
                
                // Determine salutation based on gender
                var salutation = "S/Shri";
                if (emp.gender) {
                    var gLower = emp.gender.trim().toLowerCase();
                    if (gLower === 'male' || gLower === 'm') {
                        salutation = "Shri";
                    } else if (gLower === 'female' || gLower === 'f') {
                        salutation = "Smt.";
                    }
                }
                
                tr.innerHTML = 
                    '<td style="text-align: center;"><strong>' + (startIdx + index + 1) + '</strong></td>' +
                    '<td>' + emp.division + '</td>' +
                    '<td>' + emp.complex + '</td>' +
                    '<td><strong>' + emp.employeeId + '</strong></td>' +
                    '<td>' + salutation + ' ' + emp.employeeName + '</td>' +
                    '<td>' + emp.discipline + '</td>' +
                    '<td>' + emp.designation + '</td>' +
                    '<td>' + emp.grade + '</td>' +
                    '<td>' + emp.gender + '</td>' +
                    '<td>' + emp.exDtMt + '</td>' +
                    '<td>' + emp.exServicemen + '</td>' +
                    '<td>' + emp.php + '</td>' +
                    '<td>' + emp.category + '</td>' +
                    '<td>' + formatDate(emp.dob) + '</td>' +
                    '<td>' + emp.retDate + '</td>' +
                    '<td>' + formatDate(emp.doj) + '</td>' +
                    '<td>' + (emp.doa ? formatDate(emp.doa) : '-') + '</td>' +
                    '<td>' + (emp.promoDate ? formatDate(emp.promoDate) : '-') + '</td>' +
                    gradeCols +
                    '<td>' + emp.qualification + '</td>' +
                    '<td>' + emp.remarks + '</td>';
                    
                tbody.appendChild(tr);
            });
            
            updatePaginationControls(totalRecords);
        }

        // Handle Pagination State
        function updatePaginationControls(totalRecords) {
            var totalPages = Math.ceil(totalRecords / pageSize);
            var prevBtn = document.getElementById('prevPageBtn');
            var nextBtn = document.getElementById('nextPageBtn');
            var pageLabel = document.getElementById('currentPageLabel');
            
            pageLabel.innerText = 'Page ' + currentPage + ' of ' + (totalPages > 0 ? totalPages : 1);
            
            prevBtn.disabled = (currentPage === 1);
            nextBtn.disabled = (currentPage === totalPages || totalPages === 0);
        }

        function prevPage() {
            if (currentPage > 1) {
                currentPage--;
                renderTable();
            }
        }

        function nextPage() {
            var totalPages = Math.ceil(filteredEmployees.length / pageSize);
            if (currentPage < totalPages) {
                currentPage++;
                renderTable();
            }
        }

        function changePageSize() {
            var selectSize = document.getElementById('pageSizeSelect').value;
            if (selectSize === 'ALL') {
                pageSize = filteredEmployees.length > 0 ? filteredEmployees.length : 100;
            } else {
                pageSize = parseInt(selectSize);
            }
            currentPage = 1;
            renderTable();
        }
    </script>
</body>
</html>
