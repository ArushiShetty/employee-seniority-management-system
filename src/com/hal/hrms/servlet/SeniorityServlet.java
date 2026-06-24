package com.hal.hrms.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.hal.hrms.dao.EmployeeDAO;
import com.hal.hrms.model.Employee;

public class SeniorityServlet extends HttpServlet {

    private EmployeeDAO employeeDAO;
    private SimpleDateFormat dateFormat;

    public void init() throws ServletException {
        employeeDAO = new EmployeeDAO();
        dateFormat = new SimpleDateFormat("dd-MMM-yyyy");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login");
            return;
        }

        String gradeFilter = request.getParameter("gradeFilter");
        if (gradeFilter != null && gradeFilter.equals("ALL")) {
            gradeFilter = null;
        }

        List seniorityList = employeeDAO.getSeniorityList(gradeFilter);

        // Server-Side Export Logic
        String exportType = request.getParameter("export");
        if ("csv".equalsIgnoreCase(exportType)) {
            response.setContentType("text/csv");
            String filename = "seniority_list_" + (gradeFilter != null ? gradeFilter.replace(" ", "_") : "organization") + ".csv";
            response.setHeader("Content-Disposition", "attachment; filename=" + filename);

            PrintWriter writer = response.getWriter();
            
            // Output the exact 30 CSV columns matching the 21 logical columns with 10 sub-grades
            writer.println("Sl No,Div/Office,Complex,PB No,Name (S/Shri),Discipline,Present Designation,Present Grade,Gender,Ex DT/MT,Ex Servicemen,PHP,SC/ST/OBC/Gen,DOB,Super Annuation,Date of Joining,Date of Absorption,Date of seniority in present grade,Grade I,Grade II,Grade III,Grade IV,Grade V,Grade VI,Grade VII,Grade VIII,Grade IX,Grade X,Educational Qualification,Remarks");

            if (seniorityList != null) {
                for (int i = 0; i < seniorityList.size(); i++) {
                    Employee emp = (Employee) seniorityList.get(i);
                    StringBuffer sb = new StringBuffer();
                    sb.append(i + 1).append(","); // Sl No
                    sb.append("\"").append(emp.getDivision() != null ? emp.getDivision() : "").append("\","); // Div/Office
                    sb.append("\"").append(emp.getComplex() != null ? emp.getComplex() : "").append("\","); // Complex
                    sb.append("\"").append(emp.getEmployeeId() != null ? emp.getEmployeeId() : "").append("\","); // PB No
                    sb.append("\"S/Shri ").append(emp.getEmployeeName() != null ? emp.getEmployeeName() : "").append("\","); // Name (S/Shri)
                    sb.append("\"").append(emp.getDiscipline() != null ? emp.getDiscipline() : "").append("\","); // Discipline
                    sb.append("\"").append(emp.getDesignation() != null ? emp.getDesignation() : "").append("\","); // Present Designation
                    sb.append("\"").append(emp.getGrade() != null ? emp.getGrade() : "").append("\","); // Present Grade
                    sb.append("\"").append(emp.getGender() != null ? emp.getGender() : "").append("\","); // Gender
                    sb.append("\"").append(emp.getExDtMt() != null ? emp.getExDtMt() : "").append("\","); // Ex DT/MT
                    sb.append("\"").append(emp.getExServicemen() != null ? emp.getExServicemen() : "").append("\","); // Ex Servicemen
                    sb.append("\"").append(emp.getPhp() != null ? emp.getPhp() : "").append("\","); // PHP
                    sb.append("\"").append(emp.getCategory() != null ? emp.getCategory() : "").append("\","); // SC/ST/OBC/Gen
                    sb.append("\"").append(emp.getDateOfBirth() != null ? dateFormat.format(emp.getDateOfBirth()) : "").append("\","); // DOB
                    sb.append("\"").append(emp.getDateOfRetirement() != null ? dateFormat.format(emp.getDateOfRetirement()) : "N/A").append("\","); // Super Annuation
                    sb.append("\"").append(emp.getDateOfJoining() != null ? dateFormat.format(emp.getDateOfJoining()) : "").append("\","); // Date of Joining
                    sb.append("\"").append(emp.getDateOfAbsorption() != null ? dateFormat.format(emp.getDateOfAbsorption()) : "-").append("\","); // Date of Absorption
                    sb.append("\"").append(emp.getPromotionDate() != null ? dateFormat.format(emp.getPromotionDate()) : "-").append("\","); // Date of seniority in present grade
                    
                    // Seniority in all grades (Grade I to X)
                    for (int g = 1; g <= 10; g++) {
                        java.util.Date pDate = emp.getPromotionDateForGrade("Grade " + g);
                        if (pDate != null) {
                            sb.append("\"").append(dateFormat.format(pDate)).append("\",");
                        } else {
                            sb.append("\"-\",");
                        }
                    }
                    
                    sb.append("\"").append(emp.getEducationalQualification() != null ? emp.getEducationalQualification() : "").append("\","); // Educational Qualification
                    sb.append("\"").append(emp.getRemarks() != null ? emp.getRemarks() : "").append("\""); // Remarks
                    
                    writer.println(sb.toString());
                }
            }
            writer.flush();
            writer.close();
            return;
        }

        // Standard Forward Page logic
        request.setAttribute("seniorityList", seniorityList);
        request.setAttribute("selectedGrade", gradeFilter != null ? gradeFilter : "ALL");

        RequestDispatcher dispatcher = request.getRequestDispatcher("seniority.jsp");
        dispatcher.forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
