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

    // Thread-safe in-memory cache to hold records (DB entries + fallback insertions)
    private static List inMemoryEmployees = null;

    /**
     * Initializes the static list by loading official employee records 
     * from the Oracle database, or falling back to in-memory seed data.
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
            
            // New column configurations
            String colEmpDiv = DBConnection.getProperty("col.emp.division");
            String colEmpComplex = DBConnection.getProperty("col.emp.complex");
            String colEmpDiscipline = DBConnection.getProperty("col.emp.discipline");
            String colEmpGender = DBConnection.getProperty("col.emp.gender");
            String colEmpExDtMt = DBConnection.getProperty("col.emp.ex_dt_mt");
            String colEmpExServicemen = DBConnection.getProperty("col.emp.ex_servicemen");
            String colEmpPhp = DBConnection.getProperty("col.emp.php");
            String colEmpCategory = DBConnection.getProperty("col.emp.category");
            String colEmpAbsDate = DBConnection.getProperty("col.emp.date_of_absorption");
            String colEmpEdu = DBConnection.getProperty("col.emp.educational_qualification");
            String colEmpRemarks = DBConnection.getProperty("col.emp.remarks");

            // Defaults in case configuration properties are not present
            if (tEmp == null) tEmp = "MST_EMPLOYEES";
            if (colEmpId == null) colEmpId = "employee_id";
            if (colEmpName == null) colEmpName = "employee_name";
            if (colEmpGrade == null) colEmpGrade = "grade";
            if (colEmpLevel == null) colEmpLevel = "emp_level";
            if (colEmpPromoDate == null) colEmpPromoDate = "promotion_date";
            if (colEmpDoj == null) colEmpDoj = "date_of_joining";
            if (colEmpDob == null) colEmpDob = "date_of_birth";
            if (colEmpDept == null) colEmpDept = "department";
            if (colEmpDesig == null) colEmpDesig = "designation";
            
            if (colEmpDiv == null) colEmpDiv = "division";
            if (colEmpComplex == null) colEmpComplex = "complex";
            if (colEmpDiscipline == null) colEmpDiscipline = "discipline";
            if (colEmpGender == null) colEmpGender = "gender";
            if (colEmpExDtMt == null) colEmpExDtMt = "ex_dt_mt";
            if (colEmpExServicemen == null) colEmpExServicemen = "ex_servicemen";
            if (colEmpPhp == null) colEmpPhp = "php";
            if (colEmpCategory == null) colEmpCategory = "category";
            if (colEmpAbsDate == null) colEmpAbsDate = "date_of_absorption";
            if (colEmpEdu == null) colEmpEdu = "educational_qualification";
            if (colEmpRemarks == null) colEmpRemarks = "remarks";

            // 1. Fetch active Employee files
            String sql = "SELECT " + colEmpId + ", " + colEmpName + ", " + colEmpGrade + ", " +
                         colEmpLevel + ", " + colEmpPromoDate + ", " + colEmpDoj + ", " +
                         colEmpDob + ", " + colEmpDept + ", " + colEmpDesig + ", " +
                         colEmpDiv + ", " + colEmpComplex + ", " + colEmpDiscipline + ", " +
                         colEmpGender + ", " + colEmpExDtMt + ", " + colEmpExServicemen + ", " +
                         colEmpPhp + ", " + colEmpCategory + ", " + colEmpAbsDate + ", " +
                         colEmpEdu + ", " + colEmpRemarks + " FROM " + tEmp;
                         
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
                
                // Set new fields
                emp.setDivision(rs.getString(colEmpDiv) != null ? rs.getString(colEmpDiv).trim() : "");
                emp.setComplex(rs.getString(colEmpComplex) != null ? rs.getString(colEmpComplex).trim() : "");
                emp.setDiscipline(rs.getString(colEmpDiscipline) != null ? rs.getString(colEmpDiscipline).trim() : "");
                emp.setGender(rs.getString(colEmpGender) != null ? rs.getString(colEmpGender).trim() : "");
                emp.setExDtMt(rs.getString(colEmpExDtMt) != null ? rs.getString(colEmpExDtMt).trim() : "");
                emp.setExServicemen(rs.getString(colEmpExServicemen) != null ? rs.getString(colEmpExServicemen).trim() : "");
                emp.setPhp(rs.getString(colEmpPhp) != null ? rs.getString(colEmpPhp).trim() : "");
                emp.setCategory(rs.getString(colEmpCategory) != null ? rs.getString(colEmpCategory).trim() : "");
                emp.setDateOfAbsorption(rs.getDate(colEmpAbsDate));
                emp.setEducationalQualification(rs.getString(colEmpEdu) != null ? rs.getString(colEmpEdu).trim() : "");
                emp.setRemarks(rs.getString(colEmpRemarks) != null ? rs.getString(colEmpRemarks).trim() : "");
                
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
            
            if (tPromo == null) tPromo = "TRN_PROMOTIONS";
            if (colPromoEmpId == null) colPromoEmpId = "employee_id";
            if (colPromoGrade == null) colPromoGrade = "grade";
            if (colPromoDate == null) colPromoDate = "promotion_date";
            if (colPromoPosCode == null) colPromoPosCode = "pos_code";
            if (colPromoValidFrom == null) colPromoValidFrom = "valid_from";
            if (colPromoValidTo == null) colPromoValidTo = "valid_to";
            if (colPromoIsPrimary == null) colPromoIsPrimary = "is_primary";
            if (colPromoAssignmentType == null) colPromoAssignmentType = "assignment_type";
            if (colPromoOrderNum == null) colPromoOrderNum = "order_number";

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
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) {} }
            if (pstmt != null) { try { pstmt.close(); } catch (SQLException e) {} }
            if (conn != null) { try { conn.close(); } catch (SQLException e) {} }
        }

        // Fallback for demo/offline operations when database is not connected
        if (inMemoryEmployees.isEmpty()) {
            loadDemoData();
        }
    }

    /**
     * Seeds 1,000 detailed employee records (100 per grade) for high-performance offline demonstration.
     */
    private void loadDemoData() {
        inMemoryEmployees = new ArrayList();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        
        String[] maleFirstNames = {"Amit", "Rohan", "Sanjay", "Karan", "Vijay", "Anand", "Deepak", "Vikram", "Sunil", "Rajesh", "Manoj", "Pradeep", "Ashok", "Suresh", "Ramesh", "Ajay", "Dinesh", "Harish", "Arvind", "Sandeep", "Kunal", "Varun", "Arjun", "Vinay", "Alok", "Rahul", "Pankaj", "Abhishek", "Gaurav", "Siddharth"};
        String[] femaleFirstNames = {"Arushi", "Priya", "Neha", "Anjali", "Ritu", "Deepa", "Suman", "Sunita", "Geeta", "Kiran", "Meera", "Aarti", "Pooja", "Jyoti", "Shalini", "Rashmi", "Divya", "Swati", "Kavita", "Aditi", "Anita", "Preeti", "Mamta", "Radha", "Rekha", "Uma", "Shanti", "Lata", "Asha", "Sita"};
        String[] lastNames = {"Patil", "Nair", "Joshi", "Iyer", "Rao", "Reddy", "Mehta", "Gowda", "Mishra", "Gupta", "Sen", "Bose", "Das", "Roy", "Sharma", "Singh", "Prasad", "Verma", "Pillai", "Kulkarni", "Choudhury", "Banerjee", "Chatterjee", "Dubey", "Dwivedi", "Tripathi", "Pandey"};
        
        String[] divisions = {
            "Aircraft Division - Bengaluru",
            "Engine Division - Bengaluru",
            "Overhaul Division - Bengaluru",
            "Foundry & Forge Division - Bengaluru",
            "Aerospace Division - Bengaluru",
            "IMGT Division (Industrial, Marine and Gas Turbine) - Bengaluru",
            "LCA-Tejas Division - Bengaluru",
            "Helicopter Division - Bengaluru",
            "Helicopter MRO Division - Bengaluru",
            "Aerospace Composites Division - Bengaluru",
            "Helicopter Division - Tumakuru",
            "Barrackpore Division - Barrackpore",
            "Aircraft Manufacturing Division - Nashik",
            "Aircraft Overhaul Division - Nashik",
            "Engine Division - Koraput",
            "Sukhoi Engine Division - Koraput",
            "TAD-Kanpur Division (Transport Aircraft) - Kanpur",
            "Accessories Division - Lucknow",
            "Avionics Division - Hyderabad",
            "Avionics Division - Korwa",
            "Kasaragod Division - Kasaragod"
        };
        String[] disciplines = {"Technical", "HR", "Finance", "IT", "Materials Management", "Legal", "Security", "PR"};
        String[] qualifications = {"BE (Aero)", "B.Tech (Mech)", "BE (ECE)", "B.Tech (CS)", "MBA (HR)", "CA", "ICWA", "LLB", "M.Tech", "PhD"};
        
        try {
            // Seed exactly 100 employees per grade (Grade 1 to 10) -> Total 1,000 records
            for (int g = 1; g <= 10; g++) {
                String gradeKey = "Grade " + g;
                
                for (int k = 0; k < 100; k++) {
                    int empIdInt = 100000 + (g * 1000) + k;
                    String empIdStr = String.valueOf(empIdInt);
                    
                    // Gender selection first, then gender-appropriate name
                    String gender = (k % 4 == 0) ? "Female" : "Male";
                    String firstName = "Female".equals(gender)
                        ? femaleFirstNames[(g * k + k) % femaleFirstNames.length]
                        : maleFirstNames[(g * k + k) % maleFirstNames.length];
                    String lastName = lastNames[(g * k + g) % lastNames.length];
                    String fullName = firstName + " " + lastName;
                    
                    // Division & Discipline selection
                    String division = divisions[(g + k) % divisions.length];
                    // Make 70% technical and 30% non-technical
                    String discipline = ((g + k) % 10 < 7) ? "Technical" : disciplines[(g * k) % (disciplines.length - 1) + 1];
                    
                    // Designation mapping based on Grade and Discipline
                    String designation = Employee.getDesignationForGrade(gradeKey);
                    if (!"Technical".equals(discipline)) {
                        // Adapt designation slightly for non-technical fields
                        if ("Grade 1".equals(gradeKey)) designation = "Assistant Officer (" + discipline + ")";
                        else if ("Grade 2".equals(gradeKey)) designation = "Officer (" + discipline + ")";
                        else designation = designation + " (" + discipline + ")";
                    } else {
                        designation = designation + " (Technical)";
                    }
                    
                    // Determine dates logically
                    // Career duration: Grade 1 has 0-3 years, Grade 10 has 27-30 years
                    int careerDurationYears = (g - 1) * 3 + (k % 3);
                    int currentPromoYear = 2025 - (k % 4); // Promoted recently in last 0-3 years
                    int joinYear = currentPromoYear - careerDurationYears;
                    
                    int joinMonth = 1 + (k % 12);
                    int joinDay = 1 + (k * 7) % 28;
                    String joinMonthStr = joinMonth < 10 ? "0" + joinMonth : "" + joinMonth;
                    String joinDayStr = joinDay < 10 ? "0" + joinDay : "" + joinDay;
                    Date doj = sdf.parse(joinYear + "-" + joinMonthStr + "-" + joinDayStr);
                    
                    // Age at joining: 22 to 26 years
                    int birthYear = joinYear - 22 - (k % 5);
                    int birthMonth = 1 + ((k + 3) % 12);
                    int birthDay = 1 + ((k * 3) % 28);
                    // Special test case for birth on the 1st of the month
                    if (k % 15 == 0) {
                        birthDay = 1;
                    }
                    String birthMonthStr = birthMonth < 10 ? "0" + birthMonth : "" + birthMonth;
                    String birthDayStr = birthDay < 10 ? "0" + birthDay : "" + birthDay;
                    Date dob = sdf.parse(birthYear + "-" + birthMonthStr + "-" + birthDayStr);
                    
                    // DT/MT/NA selection
                    String exDtMt = "NA";
                    if (k % 3 == 0) {
                        exDtMt = "Technical".equals(discipline) ? "DT" : "MT";
                    } else if (k % 3 == 1) {
                        exDtMt = "MT";
                    }
                    
                    // Date of Absorption (1 year after DOJ for DT/MT, otherwise same as DOJ)
                    Date absDate = doj;
                    if ("DT".equals(exDtMt) || "MT".equals(exDtMt)) {
                        absDate = sdf.parse((joinYear + 1) + "-" + joinMonthStr + "-" + joinDayStr);
                    }
                    
                    // Ex-Servicemen and PHP indicators (small percentages)
                    String exServicemen = (k % 25 == 0) ? "Y" : "N";
                    String php = (k % 33 == 0) ? "Y" : "N";
                    
                    // Caste Category
                    String[] categories = {"Gen", "Gen", "OBC", "OBC", "SC", "ST"};
                    String category = categories[(g * k) % categories.length];
                    
                    // Educational Qualification
                    String qual = qualifications[(g + k) % qualifications.length];
                    
                    // Assemble Employee Object
                    Employee emp = new Employee();
                    emp.setEmployeeId(empIdStr);
                    emp.setEmployeeName(fullName);
                    emp.setGrade(gradeKey);
                    emp.setEmpLevel("Level " + (1 + (k % 4)));
                    emp.setDateOfJoining(doj);
                    emp.setDateOfBirth(dob);
                    emp.setDateOfAbsorption(absDate);
                    emp.setDepartment(discipline + " Dept");
                    emp.setDesignation(designation);
                    emp.setDivision(division);
                    emp.setComplex(""); // Kept blank for manual entries later
                    emp.setDiscipline(discipline);
                    emp.setGender(gender);
                    emp.setExDtMt(exDtMt);
                    emp.setExServicemen(exServicemen);
                    emp.setPhp(php);
                    emp.setCategory(category);
                    emp.setEducationalQualification(qual);
                    emp.setRemarks(k % 20 == 0 ? "Verified by HR Division" : "");
                    
                    // Build promotion history from Grade 1 up to current grade
                    List history = new ArrayList();
                    for (int pg = 1; pg <= g; pg++) {
                        Promotion p = new Promotion();
                        p.setEmployeeId(empIdStr);
                        p.setGrade("Grade " + pg);
                        
                        int promoYear = joinYear + (pg - 1) * 3;
                        Date pDate = sdf.parse(promoYear + "-07-01");
                        p.setPromotionDate(pDate);
                        
                        String promoDesig = Employee.getDesignationForGrade("Grade " + pg);
                        if (!"Technical".equals(discipline)) {
                            if (pg == 1) promoDesig = "Assistant Officer (" + discipline + ")";
                            else if (pg == 2) promoDesig = "Officer (" + discipline + ")";
                            else promoDesig = promoDesig + " (" + discipline + ")";
                        } else {
                            promoDesig = promoDesig + " (Technical)";
                        }
                        
                        p.setDesignation(promoDesig);
                        p.setValidFrom(pDate);
                        p.setOrderNumber("ORD-" + promoYear + "-GR" + pg + "-" + k);
                        
                        if (pg == g) {
                            p.setValidTo(sdf.parse("2045-12-31"));
                            p.setIsPrimary(1);
                            p.setAssignmentType("CPS");
                            
                            emp.setPromotionDate(pDate);
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

            // Inject 6 Specific Seniority Rule Verification Employees in Grade 5
            injectSeniorityTestCases(sdf);

            System.out.println("Java In-Memory Cache initialized with 1,006 detailed records.");
        } catch (Exception e) {
            System.err.println("Error parsing demo dates in EmployeeDAO:");
            e.printStackTrace();
        }
    }

    private void injectSeniorityTestCases(SimpleDateFormat sdf) throws Exception {
        // Expected rank order: C -> D -> E -> F -> A -> B
        
        // Baseline employee A (ID 900001)
        Employee empA = new Employee();
        empA.setEmployeeId("900001");
        empA.setEmployeeName("RuleTwo A");
        empA.setGrade("Grade 5");
        empA.setEmpLevel("Level 1");
        empA.setPromotionDate(sdf.parse("2024-07-01"));
        empA.setDateOfJoining(sdf.parse("2015-07-01"));
        empA.setDateOfBirth(sdf.parse("1985-01-01"));
        empA.setDateOfAbsorption(sdf.parse("2015-07-01"));
        empA.setDepartment("Technical Dept");
        empA.setDesignation("Senior Manager (Technical)");
        empA.setDivision("Aircraft Division - Bengaluru");
        empA.setComplex("");
        empA.setDiscipline("Technical");
        empA.setGender("Male");
        empA.setExDtMt("NA");
        empA.setExServicemen("N");
        empA.setPhp("N");
        empA.setCategory("Gen");
        empA.setEducationalQualification("BE (Aero)");
        empA.setRemarks("Seniority Test Baseline A");
        
        List historyA = new ArrayList();
        for (int pg = 1; pg <= 5; pg++) {
            Promotion p = new Promotion();
            p.setEmployeeId("900001");
            p.setGrade("Grade " + pg);
            p.setPromotionDate(sdf.parse((pg <= 2 ? 2015 : pg == 3 ? 2018 : pg == 4 ? 2021 : 2024) + "-07-01"));
            p.setDesignation(Employee.getDesignationForGrade("Grade " + pg) + " (Technical)");
            p.setIsPrimary(pg == 5 ? 1 : 0);
            historyA.add(p);
        }
        empA.setHistoryList(historyA);
        inMemoryEmployees.add(empA);

        // Employee B (Rule 2: promoted later than A)
        Employee empB = new Employee();
        empB.setEmployeeId("900002");
        empB.setEmployeeName("RuleTwo B");
        empB.setGrade("Grade 5");
        empB.setEmpLevel("Level 1");
        empB.setPromotionDate(sdf.parse("2024-08-01")); // Rule 2 junior
        empB.setDateOfJoining(sdf.parse("2015-07-01"));
        empB.setDateOfBirth(sdf.parse("1985-01-01"));
        empB.setDateOfAbsorption(sdf.parse("2015-07-01"));
        empB.setDepartment("Technical Dept");
        empB.setDesignation("Senior Manager (Technical)");
        empB.setDivision("Aircraft Division - Bengaluru");
        empB.setComplex("");
        empB.setDiscipline("Technical");
        empB.setGender("Male");
        empB.setExDtMt("NA");
        empB.setExServicemen("N");
        empB.setPhp("N");
        empB.setCategory("Gen");
        empB.setEducationalQualification("BE (Aero)");
        empB.setRemarks("Rule 2: Promoted Later (Junior to A)");
        
        List historyB = new ArrayList();
        for (int pg = 1; pg <= 5; pg++) {
            Promotion p = new Promotion();
            p.setEmployeeId("900002");
            p.setGrade("Grade " + pg);
            p.setPromotionDate(sdf.parse((pg <= 2 ? 2015 : pg == 3 ? 2018 : pg == 4 ? 2021 : 2024) + (pg == 5 ? "-08-01" : "-07-01")));
            p.setDesignation(Employee.getDesignationForGrade("Grade " + pg) + " (Technical)");
            p.setIsPrimary(pg == 5 ? 1 : 0);
            historyB.add(p);
        }
        empB.setHistoryList(historyB);
        inMemoryEmployees.add(empB);

        // Employee C (Rule 3: promoted to Grade 4 earlier than A)
        Employee empC = new Employee();
        empC.setEmployeeId("900003");
        empC.setEmployeeName("RuleThree C");
        empC.setGrade("Grade 5");
        empC.setEmpLevel("Level 1");
        empC.setPromotionDate(sdf.parse("2024-07-01"));
        empC.setDateOfJoining(sdf.parse("2015-07-01"));
        empC.setDateOfBirth(sdf.parse("1983-01-01"));
        empC.setDateOfAbsorption(sdf.parse("2015-07-01"));
        empC.setDepartment("Technical Dept");
        empC.setDesignation("Senior Manager (Technical)");
        empC.setDivision("Aircraft Division - Bengaluru");
        empC.setComplex("");
        empC.setDiscipline("Technical");
        empC.setGender("Male");
        empC.setExDtMt("NA");
        empC.setExServicemen("N");
        empC.setPhp("N");
        empC.setCategory("Gen");
        empC.setEducationalQualification("BE (Aero)");
        empC.setRemarks("Rule 3: Prev Grade Promoted Earlier (Senior to A)");
        
        List historyC = new ArrayList();
        for (int pg = 1; pg <= 5; pg++) {
            Promotion p = new Promotion();
            p.setEmployeeId("900003");
            p.setGrade("Grade " + pg);
            p.setPromotionDate(sdf.parse((pg <= 2 ? 2015 : pg == 3 ? 2018 : pg == 4 ? 2021 : 2024) + "-07-01"));
            if (pg == 4) {
                p.setPromotionDate(sdf.parse("2021-06-01")); // Rule 3 senior (June vs July)
            }
            p.setDesignation(Employee.getDesignationForGrade("Grade " + pg) + " (Technical)");
            p.setIsPrimary(pg == 5 ? 1 : 0);
            historyC.add(p);
        }
        empC.setHistoryList(historyC);
        inMemoryEmployees.add(empC);

        // Employee D (Rule 5: DOJ earlier than A)
        Employee empD = new Employee();
        empD.setEmployeeId("900004");
        empD.setEmployeeName("RuleFive D");
        empD.setGrade("Grade 5");
        empD.setEmpLevel("Level 1");
        empD.setPromotionDate(sdf.parse("2024-07-01"));
        empD.setDateOfJoining(sdf.parse("2015-06-01")); // Rule 5 senior (June vs July)
        empD.setDateOfBirth(sdf.parse("1983-06-01"));
        empD.setDateOfAbsorption(sdf.parse("2015-06-01"));
        empD.setDepartment("Technical Dept");
        empD.setDesignation("Senior Manager (Technical)");
        empD.setDivision("Aircraft Division - Bengaluru");
        empD.setComplex("");
        empD.setDiscipline("Technical");
        empD.setGender("Male");
        empD.setExDtMt("NA");
        empD.setExServicemen("N");
        empD.setPhp("N");
        empD.setCategory("Gen");
        empD.setEducationalQualification("BE (Aero)");
        empD.setRemarks("Rule 5: Joined HAL Earlier (Senior to A)");
        
        List historyD = new ArrayList();
        for (int pg = 1; pg <= 5; pg++) {
            Promotion p = new Promotion();
            p.setEmployeeId("900004");
            p.setGrade("Grade " + pg);
            p.setPromotionDate(sdf.parse((pg <= 2 ? "2015-06-01" : pg == 3 ? "2018-07-01" : pg == 4 ? "2021-07-01" : "2024-07-01")));
            p.setDesignation(Employee.getDesignationForGrade("Grade " + pg) + " (Technical)");
            p.setIsPrimary(pg == 5 ? 1 : 0);
            historyD.add(p);
        }
        empD.setHistoryList(historyD);
        inMemoryEmployees.add(empD);

        // Employee E (Rule 6: DOB earlier/older than A)
        Employee empE = new Employee();
        empE.setEmployeeId("900005");
        empE.setEmployeeName("RuleSix E");
        empE.setGrade("Grade 5");
        empE.setEmpLevel("Level 1");
        empE.setPromotionDate(sdf.parse("2024-07-01"));
        empE.setDateOfJoining(sdf.parse("2015-07-01"));
        empE.setDateOfBirth(sdf.parse("1984-12-01")); // Rule 6 senior (Older)
        empE.setDateOfAbsorption(sdf.parse("2015-07-01"));
        empE.setDepartment("Technical Dept");
        empE.setDesignation("Senior Manager (Technical)");
        empE.setDivision("Aircraft Division - Bengaluru");
        empE.setComplex("");
        empE.setDiscipline("Technical");
        empE.setGender("Male");
        empE.setExDtMt("NA");
        empE.setExServicemen("N");
        empE.setPhp("N");
        empE.setCategory("Gen");
        empE.setEducationalQualification("BE (Aero)");
        empE.setRemarks("Rule 6: Older by Birth (Senior to A)");
        
        List historyE = new ArrayList();
        for (int pg = 1; pg <= 5; pg++) {
            Promotion p = new Promotion();
            p.setEmployeeId("900005");
            p.setGrade("Grade " + pg);
            p.setPromotionDate(sdf.parse((pg <= 2 ? 2015 : pg == 3 ? 2018 : pg == 4 ? 2021 : 2024) + "-07-01"));
            p.setDesignation(Employee.getDesignationForGrade("Grade " + pg) + " (Technical)");
            p.setIsPrimary(pg == 5 ? 1 : 0);
            historyE.add(p);
        }
        empE.setHistoryList(historyE);
        inMemoryEmployees.add(empE);

        // Employee F (Rule 7: Employee ID lower than A)
        Employee empF = new Employee();
        empF.setEmployeeId("900000"); // Rule 7 senior (900000 vs 900001)
        empF.setEmployeeName("RuleSeven F");
        empF.setGrade("Grade 5");
        empF.setEmpLevel("Level 1");
        empF.setPromotionDate(sdf.parse("2024-07-01"));
        empF.setDateOfJoining(sdf.parse("2015-07-01"));
        empF.setDateOfBirth(sdf.parse("1985-01-01"));
        empF.setDateOfAbsorption(sdf.parse("2015-07-01"));
        empF.setDepartment("Technical Dept");
        empF.setDesignation("Senior Manager (Technical)");
        empF.setDivision("Aircraft Division - Bengaluru");
        empF.setComplex("");
        empF.setDiscipline("Technical");
        empF.setGender("Male");
        empF.setExDtMt("NA");
        empF.setExServicemen("N");
        empF.setPhp("N");
        empF.setCategory("Gen");
        empF.setEducationalQualification("BE (Aero)");
        empF.setRemarks("Rule 7: Lower PB No Tie-breaker (Senior to A)");
        
        List historyF = new ArrayList();
        for (int pg = 1; pg <= 5; pg++) {
            Promotion p = new Promotion();
            p.setEmployeeId("900000");
            p.setGrade("Grade " + pg);
            p.setPromotionDate(sdf.parse((pg <= 2 ? 2015 : pg == 3 ? 2018 : pg == 4 ? 2021 : 2024) + "-07-01"));
            p.setDesignation(Employee.getDesignationForGrade("Grade " + pg) + " (Technical)");
            p.setIsPrimary(pg == 5 ? 1 : 0);
            historyF.add(p);
        }
        empF.setHistoryList(historyF);
        inMemoryEmployees.add(empF);
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
                    
                    // Copy new fields
                    copy.setDivision(e.getDivision());
                    copy.setComplex(e.getComplex());
                    copy.setDiscipline(e.getDiscipline());
                    copy.setGender(e.getGender());
                    copy.setExDtMt(e.getExDtMt());
                    copy.setExServicemen(e.getExServicemen());
                    copy.setPhp(e.getPhp());
                    copy.setCategory(e.getCategory());
                    copy.setDateOfAbsorption(e.getDateOfAbsorption());
                    copy.setEducationalQualification(e.getEducationalQualification());
                    copy.setRemarks(e.getRemarks());
                    
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
     * Registers a new employee profile in Java memory.
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
                
                // Copy new fields
                e.setDivision(emp.getDivision());
                e.setComplex(emp.getComplex());
                e.setDiscipline(emp.getDiscipline());
                e.setGender(emp.getGender());
                e.setExDtMt(emp.getExDtMt());
                e.setExServicemen(emp.getExServicemen());
                e.setPhp(emp.getPhp());
                e.setCategory(emp.getCategory());
                e.setDateOfAbsorption(emp.getDateOfAbsorption());
                e.setEducationalQualification(emp.getEducationalQualification());
                e.setRemarks(emp.getRemarks());
                
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
                e.getDesignation().toLowerCase().indexOf(q) > -1 ||
                e.getDivision().toLowerCase().indexOf(q) > -1 ||
                e.getDiscipline().toLowerCase().indexOf(q) > -1) {
                results.add(e);
            }
        }
        return results;
    }
}
