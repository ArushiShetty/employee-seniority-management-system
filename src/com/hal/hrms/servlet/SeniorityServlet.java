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
            writer.println("Rank,Employee ID,Employee Name,Grade,Grade 1 (Trainee/AE),Grade 2 (Engineer/Officer),Grade 3 (Asst Manager AM),Grade 4 (Dy Manager DM),Grade 5 (Manager),Grade 6 (Sr Manager SM),Grade 7 (Chief Manager CM),Grade 8 (Dy Gen Manager DGM),Grade 9 (Addl GM AGM),Grade 10 (Gen Manager GM),Date of Joining,Date of Birth,Retirement Date,Department,Designation");

            if (seniorityList != null) {
                for (int i = 0; i < seniorityList.size(); i++) {
                    Employee emp = (Employee) seniorityList.get(i);
                    StringBuffer sb = new StringBuffer();
                    sb.append(emp.getRank()).append(",");
                    sb.append("\"").append(emp.getEmployeeId()).append("\",");
                    sb.append("\"").append(emp.getEmployeeName()).append("\",");
                    sb.append("\"").append(emp.getGrade()).append("\",");
                    
                    for (int g = 1; g <= 10; g++) {
                        java.util.Date pDate = emp.getPromotionDateForGrade("Grade " + g);
                        if (pDate != null) {
                            sb.append("\"").append(dateFormat.format(pDate)).append("\",");
                        } else {
                            sb.append("\"-\",");
                        }
                    }
                    
                    sb.append("\"").append(dateFormat.format(emp.getDateOfJoining())).append("\",");
                    sb.append("\"").append(dateFormat.format(emp.getDateOfBirth())).append("\",");
                    sb.append("\"").append(emp.getDateOfRetirement() != null ? dateFormat.format(emp.getDateOfRetirement()) : "N/A").append("\",");
                    sb.append("\"").append(emp.getDepartment()).append("\",");
                    sb.append("\"").append(emp.getDesignation()).append("\"");
                    
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
