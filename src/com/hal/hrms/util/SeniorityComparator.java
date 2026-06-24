package com.hal.hrms.util;

import java.util.Comparator;
import java.util.Date;
import com.hal.hrms.model.Employee;
import com.hal.hrms.model.Promotion;

public class SeniorityComparator implements Comparator {

    public int compare(Object o1, Object o2) {
        Employee e1 = (Employee) o1;
        Employee e2 = (Employee) o2;

        // Rule 1: Compare Grade Level Weight (Higher Grade is Senior)
        int g1 = getGradeWeight(e1.getGrade());
        int g2 = getGradeWeight(e2.getGrade());
        if (g1 != g2) {
            return g2 - g1; // Senior-most first
        }

        // Rule 2 to 4: Compare promotion dates backwards grade-by-grade
        int currentGradeNum = g1;
        for (int g = currentGradeNum; g >= 1; g--) {
            String gradeKey = "Grade " + g;
            Date d1 = getPromoDateForGrade(e1, gradeKey);
            Date d2 = getPromoDateForGrade(e2, gradeKey);

            if (d1 != null || d2 != null) {
                if (d1 == null) return 1;  // null dates placed last
                if (d2 == null) return -1;
                if (!d1.equals(d2)) {
                    return d1.compareTo(d2); // Earlier promotion is senior
                }
            }
        }

        // Rule 5: Date of Joining (DOJ) (Earlier DOJ is senior)
        if (e1.getDateOfJoining() != null && e2.getDateOfJoining() != null) {
            if (!e1.getDateOfJoining().equals(e2.getDateOfJoining())) {
                return e1.getDateOfJoining().compareTo(e2.getDateOfJoining());
            }
        }

        // Rule 6: Date of Birth (DOB) (Older employee is senior)
        if (e1.getDateOfBirth() != null && e2.getDateOfBirth() != null) {
            if (!e1.getDateOfBirth().equals(e2.getDateOfBirth())) {
                return e1.getDateOfBirth().compareTo(e2.getDateOfBirth());
            }
        }

        // Rule 7: Tie-breaker (Employee ID ascending)
        if (e1.getEmployeeId() != null && e2.getEmployeeId() != null) {
            return e1.getEmployeeId().compareTo(e2.getEmployeeId());
        }

        return 0;
    }

    /**
     * Helper to convert Grade string (e.g. "Grade 5") to integer weight (5).
     */
    private int getGradeWeight(String grade) {
        if (grade == null) return 0;
        try {
            return Integer.parseInt(grade.substring(6).trim());
        } catch (Exception e) {
            return 0;
        }
    }

    /**
     * Finds promotion date for a specific grade inside employee profile.
     */
    private Date getPromoDateForGrade(Employee emp, String gradeName) {
        if (gradeName.equals(emp.getGrade())) {
            return emp.getPromotionDate();
        }
        if (emp.getHistoryList() != null) {
            for (int i = 0; i < emp.getHistoryList().size(); i++) {
                Promotion pm = (Promotion) emp.getHistoryList().get(i);
                if (gradeName.equals(pm.getGrade())) {
                    return pm.getPromotionDate();
                }
            }
        }
        return null;
    }
}
