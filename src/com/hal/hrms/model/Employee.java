package com.hal.hrms.model;

import java.util.Date;

public class Employee {
    private String employeeId;
    private String employeeName;
    private String grade;
    private String empLevel;
    private Date promotionDate;
    private Date dateOfJoining;
    private Date dateOfBirth;
    private String department;
    private String designation;
    private int rank; // For holding computed seniority rank in display listings

    public Employee() {
    }

    public String getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(String employeeId) {
        this.employeeId = employeeId;
    }

    public String getEmployeeName() {
        return employeeName;
    }

    public void setEmployeeName(String employeeName) {
        this.employeeName = employeeName;
    }

    public String getGrade() {
        return grade;
    }

    public void setGrade(String grade) {
        this.grade = grade;
    }

    public String getEmpLevel() {
        return empLevel;
    }

    public void setEmpLevel(String empLevel) {
        this.empLevel = empLevel;
    }

    public Date getPromotionDate() {
        return promotionDate;
    }

    public void setPromotionDate(Date promotionDate) {
        this.promotionDate = promotionDate;
    }

    public Date getDateOfJoining() {
        return dateOfJoining;
    }

    public void setDateOfJoining(Date dateOfJoining) {
        this.dateOfJoining = dateOfJoining;
    }

    public Date getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(Date dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public String getDesignation() {
        return expandDesignation(designation);
    }

    public void setDesignation(String designation) {
        this.designation = designation;
    }

    public int getRank() {
        return rank;
    }

    public void setRank(int rank) {
        this.rank = rank;
    }

    private java.util.List historyList;

    public java.util.List getHistoryList() {
        return historyList;
    }

    public void setHistoryList(java.util.List historyList) {
        this.historyList = historyList;
    }

    public Date getPromotionDateForGrade(String targetGrade) {
        if (historyList == null) {
            if (targetGrade != null && targetGrade.equals(this.grade)) {
                return this.promotionDate;
            }
            return null;
        }
        for (int i = 0; i < historyList.size(); i++) {
            Promotion p = (Promotion) historyList.get(i);
            if (p != null && targetGrade != null && targetGrade.equals(p.getGrade())) {
                return p.getPromotionDate();
            }
        }
        if (targetGrade != null && targetGrade.equals(this.grade)) {
            return this.promotionDate;
        }
        return null;
    }

    public static String getDesignationForGrade(String gradeName) {
        if (gradeName == null) return "";
        if (gradeName.equals("Grade 1")) return "Trainee / Assistant Engineer";
        if (gradeName.equals("Grade 2")) return "Engineer / Officer";
        if (gradeName.equals("Grade 3")) return "Assistant Manager";
        if (gradeName.equals("Grade 4")) return "Deputy Manager";
        if (gradeName.equals("Grade 5")) return "Manager";
        if (gradeName.equals("Grade 6")) return "Senior Manager";
        if (gradeName.equals("Grade 7")) return "Chief Manager";
        if (gradeName.equals("Grade 8")) return "Deputy General Manager";
        if (gradeName.equals("Grade 9")) return "Additional General Manager";
        if (gradeName.equals("Grade 10")) return "General Manager";
        return "";
    }

    public static String expandDesignation(String desig) {
        if (desig == null) return "";
        String res = desig;
        res = res.replaceAll("\\bAGM\\b", "Additional General Manager");
        res = res.replaceAll("\\bDGM\\b", "Deputy General Manager");
        res = res.replaceAll("\\bGM\\b", "General Manager");
        res = res.replaceAll("\\bCM\\b", "Chief Manager");
        res = res.replaceAll("\\bDM\\b", "Deputy Manager");
        res = res.replaceAll("\\bSM\\b", "Senior Manager");
        return res;
    }

    /**
     * Computes the Date of Retirement according to HAL/PSU regulations
     * (the last day of the month in which the employee turns 60).
     */
    public Date getDateOfRetirement() {
        if (dateOfBirth == null) {
            return null;
        }
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.setTime(dateOfBirth);
        cal.add(java.util.Calendar.YEAR, 60);
        cal.set(java.util.Calendar.DAY_OF_MONTH, cal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH));
        return cal.getTime();
    }
}
