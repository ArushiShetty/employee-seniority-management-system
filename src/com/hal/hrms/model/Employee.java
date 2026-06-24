package com.hal.hrms.model;

import java.util.Date;
import java.util.List;

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
    
    // New parameters for 21-column layout
    private String division;
    private String complex;
    private String discipline;
    private String gender;
    private String exDtMt;
    private String exServicemen;
    private String php;
    private String category;
    private Date dateOfAbsorption;
    private String educationalQualification;
    private String remarks;
    
    private int rank; // For holding computed seniority rank in display listings
    private List historyList; // List of Promotion objects

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
        return designation;
    }

    public void setDesignation(String designation) {
        this.designation = designation;
    }

    // Getters and Setters for New Fields
    public String getDivision() {
        return division;
    }

    public void setDivision(String division) {
        this.division = division;
    }

    public String getComplex() {
        return complex;
    }

    public void setComplex(String complex) {
        this.complex = complex;
    }

    public String getDiscipline() {
        return discipline;
    }

    public void setDiscipline(String discipline) {
        this.discipline = discipline;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getExDtMt() {
        return exDtMt;
    }

    public void setExDtMt(String exDtMt) {
        this.exDtMt = exDtMt;
    }

    public String getExServicemen() {
        return exServicemen;
    }

    public void setExServicemen(String exServicemen) {
        this.exServicemen = exServicemen;
    }

    public String getPhp() {
        return php;
    }

    public void setPhp(String php) {
        this.php = php;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public Date getDateOfAbsorption() {
        return dateOfAbsorption;
    }

    public void setDateOfAbsorption(Date dateOfAbsorption) {
        this.dateOfAbsorption = dateOfAbsorption;
    }

    public String getEducationalQualification() {
        return educationalQualification;
    }

    public void setEducationalQualification(String educationalQualification) {
        this.educationalQualification = educationalQualification;
    }

    public String getRemarks() {
        return remarks;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }

    public int getRank() {
        return rank;
    }

    public void setRank(int rank) {
        this.rank = rank;
    }

    public List getHistoryList() {
        return historyList;
    }

    public void setHistoryList(List historyList) {
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

    /**
     * Map Grade string (e.g. "Grade 5") to its corresponding designation.
     */
    public static String getDesignationForGrade(String gradeName) {
        if (gradeName == null) return "";
        if (gradeName.equals("Grade 1")) return "Assistant Engineer";
        if (gradeName.equals("Grade 2")) return "Engineer";
        if (gradeName.equals("Grade 3")) return "Deputy Manager";
        if (gradeName.equals("Grade 4")) return "Manager";
        if (gradeName.equals("Grade 5")) return "Senior Manager";
        if (gradeName.equals("Grade 6")) return "Chief Manager";
        if (gradeName.equals("Grade 7")) return "Deputy General Manager";
        if (gradeName.equals("Grade 8")) return "Additional General Manager";
        if (gradeName.equals("Grade 9")) return "General Manager";
        if (gradeName.equals("Grade 10")) return "Executive Director";
        return "";
    }

    /**
     * Computes the Date of Retirement according to HAL/PSU regulations.
     * Irrespective of whatever day you are born, your retirement is at age 60 on:
     * - Last day of the previous month if born on the 1st.
     * - Last day of the birth month if born on any other day (2nd to 31st).
     */
    public Date getDateOfRetirement() {
        if (dateOfBirth == null) {
            return null;
        }
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.setTime(dateOfBirth);
        cal.add(java.util.Calendar.YEAR, 60);
        int day = cal.get(java.util.Calendar.DAY_OF_MONTH);
        if (day == 1) {
            cal.add(java.util.Calendar.MONTH, -1);
        }
        cal.set(java.util.Calendar.DAY_OF_MONTH, cal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH));
        return cal.getTime();
    }

    /**
     * Helper function to expand designation abbreviations (CM, DM, GM, AGM, DGM, SM) to full forms.
     */
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
}
