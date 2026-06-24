package com.hal.hrms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import com.hal.hrms.model.Employee;
import com.hal.hrms.model.Promotion;
import com.hal.hrms.util.DBConnection;

public class EmployeeDAO {

    // Thread-safe in-memory cache to hold records (DB entries + new insertions)
    private static List inMemoryEmployees = null;

    /**
     * Initializes the static list by loading official employee records 
     * from the read-only Oracle database.
     */
    private synchronized void initMemoryStore() {
        if (inMemoryEmployees != null) {
            return; // Already loaded
        }
        
        inMemoryEmployees = new ArrayList();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            
            // Load Table and Column Names from configurations
            String tEmp = DBConnection.getProperty("table.employees");
            String colEmpId = DBConnection.getProperty("col.emp.id");
            String colEmpName = DBConnection.getProperty("col.emp.name");
            String colEmpGrade = DBConnection.getProperty("col.emp.grade");
            String colEmpLevel = DBConnection.getProperty("col.emp.level");
            String colEmpPromoDate = DBConnection.getProperty("col.emp.promo_date");
            String colEmpDoj = DBConnection.getProperty("col.emp.doj");
            String colEmpDob = DBConnection.getProperty("col.emp.dob");
            String colEmpDept = DBConnection.getProperty("col.emp.dept");
            String colEmpDesig = DBConnection.getProperty("col.emp.desig");
            
            // 1. Fetch active Employee files
            String sql = "SELECT " + colEmpId + ", " + colEmpName + ", " + colEmpGrade + ", " +
                         colEmpLevel + ", " + colEmpPromoDate + ", " + colEmpDoj + ", " +
                         colEmpDob + ", " + colEmpDept + ", " + colEmpDesig + " FROM " + tEmp;
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Employee emp = new Employee();
                emp.setEmployeeId(rs.getString(colEmpId) != null ? rs.getString(colEmpId).trim() : "");
                emp.setEmployeeName(rs.getString(colEmpName) != null ? rs.getString(colEmpName).trim() : "");
                emp.setGrade(rs.getString(colEmpGrade) != null ? rs.getString(colEmpGrade).trim() : "");
                emp.setEmpLevel(rs.getString(colEmpLevel) != null ? rs.getString(colEmpLevel).trim() : "");
                emp.setPromotionDate(rs.getDate(colEmpPromoDate));
                emp.setDateOfJoining(rs.getDate(colEmpDoj));
                emp.setDateOfBirth(rs.getDate(colEmpDob));
                emp.setDepartment(rs.getString(colEmpDept) != null ? rs.getString(colEmpDept).trim() : "");
                emp.setDesignation(rs.getString(colEmpDesig) != null ? rs.getString(colEmpDesig).trim() : "");
                emp.setHistoryList(new ArrayList());
                inMemoryEmployees.add(emp);
            }
            
            rs.close();
            pstmt.close();
            
            // Load Table and Column Names for Promotions
            String tPromo = DBConnection.getProperty("table.promotions");
            String colPromoEmpId = DBConnection.getProperty("col.promo.emp_id");
            String colPromoGrade = DBConnection.getProperty("col.promo.grade");
            String colPromoDate = DBConnection.getProperty("col.promo.date");
            String colPromoPosCode = DBConnection.getProperty("col.promo.pos_code");
            String colPromoValidFrom = DBConnection.getProperty("col.promo.valid_from");
            String colPromoValidTo = DBConnection.getProperty("col.promo.valid_to");
            String colPromoIsPrimary = DBConnection.getProperty("col.promo.is_primary");
            String colPromoAssignmentType = DBConnection.getProperty("col.promo.assignment_type");
            String colPromoOrderNum = DBConnection.getProperty("col.promo.order_num");
            
            // 2. Fetch all historical promotion milestones and link them to employees
            String sqlPromo = "SELECT " + colPromoEmpId + ", " + colPromoGrade + ", " + colPromoDate + ", " +
                              colPromoPosCode + ", " + colPromoValidFrom + ", " + colPromoValidTo + ", " +
                              colPromoIsPrimary + ", " + colPromoAssignmentType + ", " + colPromoOrderNum + " FROM " + tPromo;
            pstmt = conn.prepareStatement(sqlPromo);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                String empId = rs.getString(colPromoEmpId) != null ? rs.getString(colPromoEmpId).trim() : "";
                Promotion pm = new Promotion();
                pm.setEmployeeId(empId);
                pm.setGrade(rs.getString(colPromoGrade) != null ? rs.getString(colPromoGrade).trim() : "");
                pm.setPromotionDate(rs.getDate(colPromoDate));
                pm.setDesignation(rs.getString(colPromoPosCode) != null ? rs.getString(colPromoPosCode).trim() : "");
                pm.setValidFrom(rs.getDate(colPromoValidFrom));
                pm.setValidTo(rs.getDate(colPromoValidTo));
                pm.setIsPrimary(rs.getInt(colPromoIsPrimary));
                pm.setAssignmentType(rs.getString(colPromoAssignmentType) != null ? rs.getString(colPromoAssignmentType).trim() : "");
                pm.setOrderNumber(rs.getString(colPromoOrderNum) != null ? rs.getString(colPromoOrderNum).trim() : "");
                
                // Attach promotion record to matching employee object
                for (int i = 0; i < inMemoryEmployees.size(); i++) {
                    Employee e = (Employee) inMemoryEmployees.get(i);
                    if (e.getEmployeeId().trim().equals(empId)) {
                        e.getHistoryList().add(pm);
                        break;
                    }
                }
            }
            System.out.println("Java In-Memory Cache initialized with database records.");
            
        } catch (SQLException e) {
            System.err.println("Warning: Could not connect to Oracle database server. Initializing with demo fallback records.");
            e.printStackTrace();
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) {} }
            if (pstmt != null) { try { pstmt.close(); } catch (SQLException e) {} }
            if (conn != null) { try { conn.close(); } catch (SQLException e) {} }
        }

        // Fallback for demo when database is not connected
        if (inMemoryEmployees.isEmpty()) {
            loadDemoData();
        }
    }

    /**
     * Loads standard demo data matching schema.sql so the app is immediately usable.
     */
    private void loadDemoData() {
        inMemoryEmployees = new ArrayList();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        try {
            // Employee 1: M. Visvesvaraya (Grade 10)
            Employee e1 = new Employee();
            e1.setEmployeeId("103499");
            e1.setEmployeeName("M. Visvesvaraya");
            e1.setGrade("Grade 10");
            e1.setEmpLevel("Level 3");
            e1.setPromotionDate(sdf.parse("2025-07-01"));
            e1.setDateOfJoining(sdf.parse("1992-06-01"));
            e1.setDateOfBirth(sdf.parse("1967-11-20"));
            e1.setDepartment("Overhaul Division");
            e1.setDesignation("General Manager");
            List h1 = new ArrayList();
            
            Promotion p1_1 = new Promotion();
            p1_1.setEmployeeId("103499");
            p1_1.setGrade("Grade 9");
            p1_1.setPromotionDate(sdf.parse("2020-07-01"));
            p1_1.setDesignation("Additional General Manager (Overhaul)");
            p1_1.setValidFrom(sdf.parse("2021-05-21"));
            p1_1.setValidTo(sdf.parse("2024-06-30"));
            p1_1.setAssignmentType("TRANSFER");
            p1_1.setIsPrimary(0);
            h1.add(p1_1);
            
            Promotion p1_2 = new Promotion();
            p1_2.setEmployeeId("103499");
            p1_2.setGrade("Grade 10");
            p1_2.setPromotionDate(sdf.parse("2025-07-01"));
            p1_2.setDesignation("General Manager (Overhaul)");
            p1_2.setValidFrom(sdf.parse("2025-11-01"));
            p1_2.setValidTo(sdf.parse("2030-12-31"));
            p1_2.setAssignmentType("JOB ROTATION");
            p1_2.setIsPrimary(1);
            h1.add(p1_2);
            
            e1.setHistoryList(h1);
            inMemoryEmployees.add(e1);

            // Employee 2: Rajesh Kumar Sharma (Grade 9)
            Employee e2 = new Employee();
            e2.setEmployeeId("103225");
            e2.setEmployeeName("Rajesh Kumar Sharma");
            e2.setGrade("Grade 9");
            e2.setEmpLevel("Level 2");
            e2.setPromotionDate(sdf.parse("2025-07-01"));
            e2.setDateOfJoining(sdf.parse("1995-07-01"));
            e2.setDateOfBirth(sdf.parse("1970-04-12"));
            e2.setDepartment("LCA Division");
            e2.setDesignation("Additional General Manager");
            List h2 = new ArrayList();
            
            Promotion p2_1 = new Promotion();
            p2_1.setEmployeeId("103225");
            p2_1.setGrade("Grade 8");
            p2_1.setPromotionDate(sdf.parse("2015-07-01"));
            p2_1.setDesignation("Deputy General Manager - Section Head (LCA)");
            p2_1.setValidFrom(sdf.parse("2022-09-01"));
            p2_1.setValidTo(sdf.parse("2022-12-30"));
            p2_1.setAssignmentType("TRANSFER");
            p2_1.setIsPrimary(0);
            h2.add(p2_1);

            Promotion p2_1_b = new Promotion();
            p2_1_b.setEmployeeId("103225");
            p2_1_b.setGrade("Grade 8");
            p2_1_b.setPromotionDate(sdf.parse("2015-07-01"));
            p2_1_b.setDesignation("Deputy General Manager (Management Services - Information Technology)");
            p2_1_b.setValidFrom(sdf.parse("2024-05-24"));
            p2_1_b.setValidTo(sdf.parse("2025-06-30"));
            p2_1_b.setAssignmentType("JOB ROTATION");
            p2_1_b.setIsPrimary(0);
            h2.add(p2_1_b);

            Promotion p2_2 = new Promotion();
            p2_2.setEmployeeId("103225");
            p2_2.setGrade("Grade 9");
            p2_2.setPromotionDate(sdf.parse("2025-07-01"));
            p2_2.setDesignation("Additional General Manager (Management Services & IT Project Management)");
            p2_2.setValidFrom(sdf.parse("2025-07-22"));
            p2_2.setValidTo(sdf.parse("2026-08-31"));
            p2_2.setAssignmentType("ADDITIONAL RESPONSIBILITIES");
            p2_2.setIsPrimary(1);
            h2.add(p2_2);
            
            e2.setHistoryList(h2);
            inMemoryEmployees.add(e2);

            // Employee 3: Sunil Dev (Grade 7)
            Employee e3 = new Employee();
            e3.setEmployeeId("104725");
            e3.setEmployeeName("Sunil Dev");
            e3.setGrade("Grade 7");
            e3.setEmpLevel("Level 1");
            e3.setPromotionDate(sdf.parse("2024-07-01"));
            e3.setDateOfJoining(sdf.parse("2005-01-01"));
            e3.setDateOfBirth(sdf.parse("1980-08-15"));
            e3.setDepartment("Services Dept");
            e3.setDesignation("Chief Manager");
            List h3 = new ArrayList();
            
            Promotion p3_1 = new Promotion();
            p3_1.setEmployeeId("104725");
            p3_1.setGrade("Grade 5");
            p3_1.setPromotionDate(sdf.parse("2013-07-01"));
            p3_1.setDesignation("Manager (Services - Housekeeping)");
            p3_1.setValidFrom(sdf.parse("2013-05-03"));
            p3_1.setValidTo(sdf.parse("2019-06-30"));
            p3_1.setAssignmentType("TRANSFER");
            p3_1.setIsPrimary(0);
            h3.add(p3_1);
            
            Promotion p3_2 = new Promotion();
            p3_2.setEmployeeId("104725");
            p3_2.setGrade("Grade 6");
            p3_2.setPromotionDate(sdf.parse("2019-07-01"));
            p3_2.setDesignation("Senior Manager (Services - Housekeeping)");
            p3_2.setValidFrom(sdf.parse("2019-07-01"));
            p3_2.setValidTo(sdf.parse("2024-06-30"));
            p3_2.setAssignmentType("DPC");
            p3_2.setIsPrimary(0);
            h3.add(p3_2);
            
            Promotion p3_3 = new Promotion();
            p3_3.setEmployeeId("104725");
            p3_3.setGrade("Grade 7");
            p3_3.setPromotionDate(sdf.parse("2024-07-01"));
            p3_3.setDesignation("Chief Manager (Services - Housekeeping)");
            p3_3.setValidFrom(sdf.parse("2024-07-01"));
            p3_3.setValidTo(sdf.parse("2039-02-28"));
            p3_3.setAssignmentType("DPC");
            p3_3.setIsPrimary(1);
            h3.add(p3_3);
            
            e3.setHistoryList(h3);
            inMemoryEmployees.add(e3);

            // Employee 4: Anil K. V. (Grade 4)
            Employee e4 = new Employee();
            e4.setEmployeeId("120016");
            e4.setEmployeeName("Anil K. V.");
            e4.setGrade("Grade 4");
            e4.setEmpLevel("Level 1");
            e4.setPromotionDate(sdf.parse("2023-01-01"));
            e4.setDateOfJoining(sdf.parse("2012-12-14"));
            e4.setDateOfBirth(sdf.parse("1992-05-05"));
            e4.setDepartment("Jet Engine Overhaul");
            e4.setDesignation("Highly Skilled Technician");
            List h4 = new ArrayList();
            
            Promotion p4_1 = new Promotion();
            p4_1.setEmployeeId("120016");
            p4_1.setGrade("Grade 1");
            p4_1.setPromotionDate(sdf.parse("2012-12-14"));
            p4_1.setDesignation("Trainee Technician (Fitter)");
            p4_1.setValidFrom(sdf.parse("2012-12-14"));
            p4_1.setValidTo(sdf.parse("2013-12-13"));
            p4_1.setAssignmentType("TRAINEE");
            p4_1.setIsPrimary(0);
            h4.add(p4_1);
            
            Promotion p4_2 = new Promotion();
            p4_2.setEmployeeId("120016");
            p4_2.setGrade("Grade 2");
            p4_2.setPromotionDate(sdf.parse("2012-12-14"));
            p4_2.setDesignation("Technician (Fitter)");
            p4_2.setValidFrom(sdf.parse("2013-12-14"));
            p4_2.setValidTo(sdf.parse("2015-03-05"));
            p4_2.setAssignmentType("ABSORPTION");
            p4_2.setIsPrimary(0);
            h4.add(p4_2);
            
            Promotion p4_3 = new Promotion();
            p4_3.setEmployeeId("120016");
            p4_3.setGrade("Grade 3");
            p4_3.setPromotionDate(sdf.parse("2017-01-01"));
            p4_3.setDesignation("Senior Technician (Fitter)");
            p4_3.setValidFrom(sdf.parse("2017-01-01"));
            p4_3.setValidTo(sdf.parse("2020-01-13"));
            p4_3.setAssignmentType("CPS");
            p4_3.setIsPrimary(0);
            h4.add(p4_3);
            
            Promotion p4_4 = new Promotion();
            p4_4.setEmployeeId("120016");
            p4_4.setGrade("Grade 4");
            p4_4.setPromotionDate(sdf.parse("2023-01-01"));
            p4_4.setDesignation("Highly Skilled Technician (Fitter)");
            p4_4.setValidFrom(sdf.parse("2023-01-01"));
            p4_4.setValidTo(sdf.parse("2045-02-28"));
            p4_4.setAssignmentType("CPS");
            p4_4.setIsPrimary(1);
            h4.add(p4_4);
            
            e4.setHistoryList(h4);
            inMemoryEmployees.add(e4);

            // Employee 5: Balaji Prasad (Grade 4)
            Employee e5 = new Employee();
            e5.setEmployeeId("120018");
            e5.setEmployeeName("Balaji Prasad");
            e5.setGrade("Grade 4");
            e5.setEmpLevel("Level 1");
            e5.setPromotionDate(sdf.parse("2023-01-01"));
            e5.setDateOfJoining(sdf.parse("2012-12-17"));
            e5.setDateOfBirth(sdf.parse("1991-03-14"));
            e5.setDepartment("Jet Engine Overhaul");
            e5.setDesignation("Highly Skilled Technician");
            List h5 = new ArrayList();
            
            Promotion p5_1 = new Promotion();
            p5_1.setEmployeeId("120018");
            p5_1.setGrade("Grade 1");
            p5_1.setPromotionDate(sdf.parse("2012-12-17"));
            p5_1.setDesignation("Trainee Technician (Fitter)");
            p5_1.setValidFrom(sdf.parse("2012-12-17"));
            p5_1.setValidTo(sdf.parse("2013-12-16"));
            p5_1.setAssignmentType("TRAINEE");
            p5_1.setIsPrimary(0);
            h5.add(p5_1);
            
            Promotion p5_2 = new Promotion();
            p5_2.setEmployeeId("120018");
            p5_2.setGrade("Grade 2");
            p5_2.setPromotionDate(sdf.parse("2012-12-17"));
            p5_2.setDesignation("Technician (Fitter)");
            p5_2.setValidFrom(sdf.parse("2013-12-17"));
            p5_2.setValidTo(sdf.parse("2015-03-05"));
            p5_2.setAssignmentType("ABSORPTION");
            p5_2.setIsPrimary(0);
            h5.add(p5_2);
            
            Promotion p5_3 = new Promotion();
            p5_3.setEmployeeId("120018");
            p5_3.setGrade("Grade 3");
            p5_3.setPromotionDate(sdf.parse("2017-01-01"));
            p5_3.setDesignation("Senior Technician (Fitter)");
            p5_3.setValidFrom(sdf.parse("2017-01-01"));
            p5_3.setValidTo(sdf.parse("2020-01-13"));
            p5_3.setAssignmentType("CPS");
            p5_3.setIsPrimary(0);
            h5.add(p5_3);
            
            Promotion p5_4 = new Promotion();
            p5_4.setEmployeeId("120018");
            p5_4.setGrade("Grade 4");
            p5_4.setPromotionDate(sdf.parse("2023-01-01"));
            p5_4.setDesignation("Highly Skilled Technician (Fitter)");
            p5_4.setValidFrom(sdf.parse("2023-01-01"));
            p5_4.setValidTo(sdf.parse("2048-08-31"));
            p5_4.setAssignmentType("CPS");
            p5_4.setIsPrimary(1);
            h5.add(p5_4);
            
            e5.setHistoryList(h5);
            inMemoryEmployees.add(e5);

            // Employee 6: Chinnaswamy M. (Grade 4)
            Employee e6 = new Employee();
            e6.setEmployeeId("120020");
            e6.setEmployeeName("Chinnaswamy M.");
            e6.setGrade("Grade 4");
            e6.setEmpLevel("Level 1");
            e6.setPromotionDate(sdf.parse("2023-01-01"));
            e6.setDateOfJoining(sdf.parse("2012-12-26"));
            e6.setDateOfBirth(sdf.parse("1990-10-10"));
            e6.setDepartment("Jet Engine Overhaul");
            e6.setDesignation("Highly Skilled Technician");
            List h6 = new ArrayList();
            
            Promotion p6_1 = new Promotion();
            p6_1.setEmployeeId("120020");
            p6_1.setGrade("Grade 1");
            p6_1.setPromotionDate(sdf.parse("2012-12-26"));
            p6_1.setDesignation("Trainee Technician (Fitter)");
            p6_1.setValidFrom(sdf.parse("2012-12-26"));
            p6_1.setValidTo(sdf.parse("2013-12-25"));
            p6_1.setAssignmentType("TRAINEE");
            p6_1.setIsPrimary(0);
            h6.add(p6_1);
            
            Promotion p6_2 = new Promotion();
            p6_2.setEmployeeId("120020");
            p6_2.setGrade("Grade 2");
            p6_2.setPromotionDate(sdf.parse("2012-12-26"));
            p6_2.setDesignation("Technician (Fitter)");
            p6_2.setValidFrom(sdf.parse("2013-12-26"));
            p6_2.setValidTo(sdf.parse("2015-03-05"));
            p6_2.setAssignmentType("ABSORPTION");
            p6_2.setIsPrimary(0);
            h6.add(p6_2);
            
            Promotion p6_3 = new Promotion();
            p6_3.setEmployeeId("120020");
            p6_3.setGrade("Grade 3");
            p6_3.setPromotionDate(sdf.parse("2017-01-01"));
            p6_3.setDesignation("Senior Technician (Fitter)");
            p6_3.setValidFrom(sdf.parse("2017-01-01"));
            p6_3.setValidTo(sdf.parse("2020-01-13"));
            p6_3.setAssignmentType("CPS");
            p6_3.setIsPrimary(0);
            h6.add(p6_3);
            
            Promotion p6_4 = new Promotion();
            p6_4.setEmployeeId("120020");
            p6_4.setGrade("Grade 4");
            p6_4.setPromotionDate(sdf.parse("2023-01-01"));
            p6_4.setDesignation("Highly Skilled Technician (Fitter)");
            p6_4.setValidFrom(sdf.parse("2023-01-01"));
            p6_4.setValidTo(sdf.parse("2044-06-30"));
            p6_4.setAssignmentType("CPS");
            p6_4.setIsPrimary(1);
            h6.add(p6_4);
            
            e6.setHistoryList(h6);
            inMemoryEmployees.add(e6);

            // Programmatically generate at least 10 employees for every grade (Grade 1 to 10)
            String[] firstNames = {"Amit", "Rohan", "Sanjay", "Karan", "Vijay", "Anand", "Deepak", "Vikram", "Sunil", "Rajesh", "Manoj", "Pradeep", "Ashok", "Suresh", "Ramesh", "Ajay", "Dinesh", "Harish", "Arvind", "Sandeep"};
            String[] lastNames = {"Patil", "Nair", "Joshi", "Iyer", "Rao", "Reddy", "Mehta", "Gowda", "Mishra", "Gupta", "Sen", "Bose", "Das", "Roy", "Nair", "Kumar", "Sharma", "Singh", "Prasad", "Verma"};
            String[] depts = {"LCA Assembly", "Overhaul Engine", "Jet Avionics", "Services Maintenance", "Purchase Logistics", "Information Systems", "Finance Accounting", "Human Resources"};
            
            String[] olderNames = {
                "",
                "Aarav Patil",
                "Rohan Nair",
                "Sanjay Joshi",
                "Karan Iyer",
                "Vijay Rao",
                "Anand Reddy",
                "Deepak Mehta",
                "Vikram Gowda",
                "Sunil Mishra",
                "Rajesh Gupta"
            };
            String[] youngerNames = {
                "",
                "Alok Deshmukh",
                "Rahul Pillai",
                "Sandeep Kulkarni",
                "Kunal Menon",
                "Varun Hegde",
                "Arjun Naidu",
                "Dinesh Shah",
                "Vinay Shettigar",
                "Suresh Pandey",
                "Ramesh Bansal"
            };

            for (int g = 1; g <= 10; g++) {
                for (int k = 0; k < 12; k++) {
                    int empIdInt = 120000 + (g * 100) + k;
                    String empIdStr = String.valueOf(empIdInt);
                    
                    String firstName, lastName, fullName, dept;
                    int careerDurationYears = (g - 1) * 3;
                    int currentPromoYear, joinYear;
                    Date doj, dob;
                    
                    if (k >= 10) {
                        dept = "Overhaul Engine";
                        currentPromoYear = 2022;
                        joinYear = currentPromoYear - careerDurationYears;
                        doj = sdf.parse(joinYear + "-05-15");
                        
                        if (k == 10) {
                            fullName = olderNames[g];
                            dob = sdf.parse((joinYear - 28) + "-04-12");
                        } else {
                            fullName = youngerNames[g];
                            dob = sdf.parse((joinYear - 24) + "-08-25");
                        }
                    } else {
                        firstName = firstNames[(g * k + k) % firstNames.length];
                        lastName = lastNames[(g * k + g) % lastNames.length];
                        fullName = firstName + " " + lastName;
                        dept = depts[(g + k) % depts.length];
                        
                        currentPromoYear = 2020 + (k % 6);
                        joinYear = currentPromoYear - careerDurationYears;
                        
                        int joinMonth = 1 + (k % 12);
                        int joinDay = 1 + (k * 7) % 28;
                        String joinMonthStr = joinMonth < 10 ? "0" + joinMonth : "" + joinMonth;
                        String joinDayStr = joinDay < 10 ? "0" + joinDay : "" + joinDay;
                        doj = sdf.parse(joinYear + "-" + joinMonthStr + "-" + joinDayStr);
                        
                        int birthYear = joinYear - 22 - (k % 5);
                        int birthMonth = 1 + ((k + 3) % 12);
                        int birthDay = 1 + ((k * 3) % 28);
                        String birthMonthStr = birthMonth < 10 ? "0" + birthMonth : "" + birthMonth;
                        String birthDayStr = birthDay < 10 ? "0" + birthDay : "" + birthDay;
                        dob = sdf.parse(birthYear + "-" + birthMonthStr + "-" + birthDayStr);
                    }
                    
                    Employee emp = new Employee();
                    emp.setEmployeeId(empIdStr);
                    emp.setEmployeeName(fullName);
                    emp.setDepartment(dept);
                    emp.setDateOfJoining(doj);
                    emp.setDateOfBirth(dob);
                    
                    List history = new ArrayList();
                    Date currentPromoDate = doj;
                    
                    for (int pg = 1; pg <= g; pg++) {
                        Promotion p = new Promotion();
                        p.setEmployeeId(empIdStr);
                        p.setGrade("Grade " + pg);
                        
                        int promoYear = joinYear + (pg - 1) * 3;
                        Date pDate = sdf.parse(promoYear + "-07-01");
                        p.setPromotionDate(pDate);
                        currentPromoDate = pDate;
                        
                        String des = "Associate Grade " + pg;
                        if (pg == 1) des = "Trainee (" + dept + ")";
                        else if (pg == 2) des = "Technician (" + dept + ")";
                        else if (pg == 3) des = "Senior Technician";
                        else if (pg == 4) des = "Highly Skilled Technician";
                        else if (pg == 5) des = "Deputy Manager";
                        else if (pg == 6) des = "Manager";
                        else if (pg == 7) des = "Senior Manager";
                        else if (pg == 8) des = "Chief Manager";
                        else if (pg == 9) des = "Deputy General Manager";
                        else if (pg == 10) des = "General Manager";
                        
                        p.setDesignation(des);
                        p.setValidFrom(pDate);
                        p.setOrderNumber("ORD-" + promoYear + "-GR" + pg + "-" + k);
                        
                        if (pg == g) {
                            p.setValidTo(sdf.parse("2045-12-31"));
                            p.setIsPrimary(1);
                            p.setAssignmentType("CPS");
                            
                            emp.setGrade("Grade " + g);
                            emp.setEmpLevel("Level " + (1 + (k % 3)));
                            emp.setPromotionDate(pDate);
                            emp.setDesignation(des);
                        } else {
                            int nextPromoYear = promoYear + 3;
                            p.setValidTo(sdf.parse(nextPromoYear + "-06-30"));
                            p.setIsPrimary(0);
                            p.setAssignmentType(pg == 1 ? "TRAINEE" : "CPS");
                        }
                        
                        history.add(p);
                    }
                    
                    emp.setHistoryList(history);
                    inMemoryEmployees.add(emp);
                }
            }
            System.out.println("Java In-Memory Cache initialized with demo fallback records.");
        } catch (java.text.ParseException e) {
            System.err.println("Error parsing demo dates:");
            e.printStackTrace();
        }
    }

    /**
     * Retrieves the seniority list. Filters by Grade category if provided.
     * Computes rankings using the Java-level SeniorityComparator.
     */
    public List getSeniorityList(String gradeFilter) {
        initMemoryStore();
        
        // Clone the list to prevent thread-safety conflicts during page requests
        List list = new ArrayList();
        for (int i = 0; i < inMemoryEmployees.size(); i++) {
            list.add(inMemoryEmployees.get(i));
        }
        
        // Sort the entire employee list using the Java Comparator
        Collections.sort(list, new com.hal.hrms.util.SeniorityComparator());
        
        // Dynamically compute global seniority ranks
        for (int i = 0; i < list.size(); i++) {
            Employee e = (Employee) list.get(i);
            e.setRank(i + 1);
        }
        
        // If filtering by a specific grade:
        if (gradeFilter != null && !gradeFilter.trim().equals("")) {
            List filteredList = new ArrayList();
            int subRank = 1;
            for (int i = 0; i < list.size(); i++) {
                Employee e = (Employee) list.get(i);
                if (gradeFilter.equals(e.getGrade())) {
                    // Create copy for display scope
                    Employee copy = new Employee();
                    copy.setEmployeeId(e.getEmployeeId());
                    copy.setEmployeeName(e.getEmployeeName());
                    copy.setGrade(e.getGrade());
                    copy.setEmpLevel(e.getEmpLevel());
                    copy.setPromotionDate(e.getPromotionDate());
                    copy.setDateOfJoining(e.getDateOfJoining());
                    copy.setDateOfBirth(e.getDateOfBirth());
                    copy.setDepartment(e.getDepartment());
                    copy.setDesignation(e.getDesignation());
                    copy.setRank(subRank++); // Rank within this specific grade category
                    copy.setHistoryList(e.getHistoryList());
                    filteredList.add(copy);
                }
            }
            return filteredList;
        }
        
        return list;
    }

    /**
     * Registers a new employee profile in Java memory (Read-only DB workaround).
     */
    public boolean addEmployee(Employee emp) {
        initMemoryStore();
        
        // Check duplicate Employee ID
        for (int i = 0; i < inMemoryEmployees.size(); i++) {
            Employee e = (Employee) inMemoryEmployees.get(i);
            if (e.getEmployeeId().equals(emp.getEmployeeId())) {
                return false; 
            }
        }
        
        emp.setHistoryList(new ArrayList());
        
        // Add current promotion date into history
        Promotion pm = new Promotion();
        pm.setEmployeeId(emp.getEmployeeId());
        pm.setGrade(emp.getGrade());
        pm.setPromotionDate(emp.getPromotionDate());
        pm.setDesignation(emp.getDesignation());
        emp.getHistoryList().add(pm);
        
        inMemoryEmployees.add(emp);
        return true;
    }

    /**
     * Modifies employee attributes inside Java memory.
     */
    public boolean editEmployee(Employee emp) {
        initMemoryStore();
        
        for (int i = 0; i < inMemoryEmployees.size(); i++) {
            Employee e = (Employee) inMemoryEmployees.get(i);
            if (e.getEmployeeId().equals(emp.getEmployeeId())) {
                e.setEmployeeName(emp.getEmployeeName());
                
                // If the employee's current grade has changed, capture it in history
                if (!e.getGrade().equals(emp.getGrade())) {
                    boolean found = false;
                    for (int h = 0; h < e.getHistoryList().size(); h++) {
                        Promotion p = (Promotion) e.getHistoryList().get(h);
                        if (p.getGrade().equals(emp.getGrade())) {
                            p.setPromotionDate(emp.getPromotionDate());
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        Promotion p = new Promotion();
                        p.setEmployeeId(emp.getEmployeeId());
                        p.setGrade(emp.getGrade());
                        p.setPromotionDate(emp.getPromotionDate());
                        p.setDesignation(emp.getDesignation());
                        e.getHistoryList().add(p);
                    }
                }
                
                e.setGrade(emp.getGrade());
                e.setEmpLevel(emp.getEmpLevel());
                e.setPromotionDate(emp.getPromotionDate());
                e.setDateOfJoining(emp.getDateOfJoining());
                e.setDateOfBirth(emp.getDateOfBirth());
                e.setDepartment(emp.getDepartment());
                e.setDesignation(emp.getDesignation());
                return true;
            }
        }
        return false;
    }

    /**
     * Removes employee record from memory.
     */
    public boolean deleteEmployee(String employeeId) {
        initMemoryStore();
        
        for (int i = 0; i < inMemoryEmployees.size(); i++) {
            Employee e = (Employee) inMemoryEmployees.get(i);
            if (e.getEmployeeId().equals(employeeId)) {
                inMemoryEmployees.remove(i);
                return true;
            }
        }
        return false;
    }

    /**
     * Fetches a single employee by ID from local cache.
     */
    public Employee getEmployeeById(String employeeId) {
        initMemoryStore();
        
        for (int i = 0; i < inMemoryEmployees.size(); i++) {
            Employee e = (Employee) inMemoryEmployees.get(i);
            if (e.getEmployeeId().equals(employeeId)) {
                return e;
            }
        }
        return null;
    }

    /**
     * Performs employee search using local memory fields.
     */
    public List searchEmployees(String query) {
        initMemoryStore();
        
        List results = new ArrayList();
        if (query == null || query.trim().equals("")) {
            return results;
        }
        
        String q = query.toLowerCase();
        for (int i = 0; i < inMemoryEmployees.size(); i++) {
            Employee e = (Employee) inMemoryEmployees.get(i);
            if (e.getEmployeeId().toLowerCase().indexOf(q) > -1 ||
                e.getEmployeeName().toLowerCase().indexOf(q) > -1 ||
                e.getDepartment().toLowerCase().indexOf(q) > -1 ||
                e.getDesignation().toLowerCase().indexOf(q) > -1) {
                results.add(e);
            }
        }
        return results;
    }
}
