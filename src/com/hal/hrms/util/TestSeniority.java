package com.hal.hrms.util;

import java.text.SimpleDateFormat;
import java.util.List;
import com.hal.hrms.dao.EmployeeDAO;
import com.hal.hrms.model.Employee;

public class TestSeniority {

    public static void main(String[] args) {
        System.out.println("==================================================");
        System.out.println("HAL HR Seniority System - Console Testing Utility");
        System.out.println("==================================================");

        EmployeeDAO dao = new EmployeeDAO();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        try {
            // 1. Fetch initially loaded seniority list (from Oracle if connected)
            System.out.println("\n--- Initial Seniority List (Fetched from Oracle DB) ---");
            printSeniorityList(dao.getSeniorityList(null));

            // 2. Simulate HR Admin adding a new employee in Java memory
            System.out.println("\n--- Adding New Employee (Vikram Sarabhai) ---");
            Employee newEmp = new Employee();
            newEmp.setEmployeeId("120229");
            newEmp.setEmployeeName("Vikram Sarabhai");
            newEmp.setGrade("Grade 4");
            newEmp.setEmpLevel("Level 1");
            newEmp.setPromotionDate(sdf.parse("2024-01-01"));
            newEmp.setDateOfJoining(sdf.parse("2014-10-03"));
            newEmp.setDateOfBirth(sdf.parse("1988-08-12"));
            newEmp.setDepartment("LCA Assembly");
            newEmp.setDesignation("HST(F)-M");

            boolean added = dao.addEmployee(newEmp);
            System.out.println("Employee registration status: " + (added ? "SUCCESS (Stored in Java Memory)" : "FAILED (Duplicate ID)"));

            // 3. Print the updated seniority list (shows combined list sorted)
            System.out.println("\n--- Updated Seniority List (DB + Memory Combined) ---");
            printSeniorityList(dao.getSeniorityList(null));

            // 4. Test Grade 4 specific filter ranking
            System.out.println("\n--- Grade 4 Seniority Rankings ---");
            printSeniorityList(dao.getSeniorityList("Grade 4"));

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Prints the employees in a formatted console table grid.
     */
    private static void printSeniorityList(List list) {
        if (list == null || list.isEmpty()) {
            System.out.println("No records found.");
            return;
        }
        
        SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy");
        System.out.println("Rank | Emp ID  | Employee Name        | Grade    | Level   | Prom Date   | DOJ         | DOB");
        System.out.println("-----+---------+----------------------+----------+---------+-------------+-------------+------------");
        for (int i = 0; i < list.size(); i++) {
            Employee emp = (Employee) list.get(i);
            if (emp.getEmployeeId().startsWith("9000")) {
                System.out.println(
                    padRight(String.valueOf(emp.getRank()), 4) + " | " +
                    padRight(emp.getEmployeeId(), 7) + " | " +
                    padRight(emp.getEmployeeName(), 20) + " | " +
                    padRight(emp.getGrade(), 8) + " | " +
                    padRight(emp.getEmpLevel(), 7) + " | " +
                    padRight(sdf.format(emp.getPromotionDate()), 11) + " | " +
                    padRight(sdf.format(emp.getDateOfJoining()), 11) + " | " +
                    sdf.format(emp.getDateOfBirth())
                );
            }
        }
    }

    /**
     * Formats alignment for console print columns.
     */
    private static String padRight(String s, int n) {
        if (s == null) s = "";
        if (s.length() >= n) return s;
        StringBuffer sb = new StringBuffer(s);
        while (sb.length() < n) {
            sb.append(" ");
        }
        return sb.toString();
    }
}
