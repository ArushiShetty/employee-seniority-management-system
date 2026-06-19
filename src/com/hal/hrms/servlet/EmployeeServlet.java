package com.hal.hrms.servlet;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.hal.hrms.dao.EmployeeDAO;
import com.hal.hrms.model.Employee;
import com.hal.hrms.model.User;

public class EmployeeServlet extends HttpServlet {

    private EmployeeDAO employeeDAO;
    private SimpleDateFormat dateFormat;

    public void init() throws ServletException {
        employeeDAO = new EmployeeDAO();
        dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            if ("new".equals(action)) {
                // Only admins can add employees
                if (!"ADMIN".equals(currentUser.getUserRole())) {
                    response.sendRedirect("dashboard");
                    return;
                }
                request.setAttribute("isEdit", Boolean.FALSE);
                RequestDispatcher dispatcher = request.getRequestDispatcher("employee-form.jsp");
                dispatcher.forward(request, response);
                
            } else if ("edit".equals(action)) {
                if (!"ADMIN".equals(currentUser.getUserRole())) {
                    response.sendRedirect("dashboard");
                    return;
                }
                String id = request.getParameter("id");
                Employee emp = employeeDAO.getEmployeeById(id);
                request.setAttribute("employee", emp);
                request.setAttribute("isEdit", Boolean.TRUE);
                RequestDispatcher dispatcher = request.getRequestDispatcher("employee-form.jsp");
                dispatcher.forward(request, response);
                
            } else if ("delete".equals(action)) {
                if (!"ADMIN".equals(currentUser.getUserRole())) {
                    response.sendRedirect("dashboard");
                    return;
                }
                String id = request.getParameter("id");
                employeeDAO.deleteEmployee(id);
                response.sendRedirect("employees?action=list");
                
            } else { // "list"
                String query = request.getParameter("query");
                List employees;
                if (query != null && !query.trim().equals("")) {
                    employees = employeeDAO.searchEmployees(query);
                    request.setAttribute("searchQuery", query);
                } else {
                    employees = employeeDAO.getSeniorityList(null); // All, un-filtered grade
                }
                request.setAttribute("employeeList", employees);
                RequestDispatcher dispatcher = request.getRequestDispatcher("employee-list.jsp");
                dispatcher.forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (!"ADMIN".equals(currentUser.getUserRole())) {
            response.sendRedirect("dashboard");
            return;
        }

        boolean isEdit = "true".equals(request.getParameter("isEditMode"));
        
        Employee emp = new Employee();
        emp.setEmployeeId(request.getParameter("employeeId"));
        emp.setEmployeeName(request.getParameter("employeeName"));
        emp.setGrade(request.getParameter("grade"));
        emp.setEmpLevel(request.getParameter("empLevel"));
        emp.setDepartment(request.getParameter("department"));
        emp.setDesignation(request.getParameter("designation"));

        try {
            emp.setPromotionDate(dateFormat.parse(request.getParameter("promotionDate")));
            emp.setDateOfJoining(dateFormat.parse(request.getParameter("dateOfJoining")));
            emp.setDateOfBirth(dateFormat.parse(request.getParameter("dateOfBirth")));
        } catch (ParseException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error parsing input dates. Ensure format is YYYY-MM-DD.");
            request.setAttribute("employee", emp);
            request.setAttribute("isEdit", new Boolean(isEdit));
            RequestDispatcher dispatcher = request.getRequestDispatcher("employee-form.jsp");
            dispatcher.forward(request, response);
            return;
        }

        boolean success;
        if (isEdit) {
            success = employeeDAO.editEmployee(emp);
        } else {
            success = employeeDAO.addEmployee(emp);
        }

        if (success) {
            response.sendRedirect("employees?action=list");
        } else {
            request.setAttribute("error", "Database error occurred while saving employee record. ID might already exist.");
            request.setAttribute("employee", emp);
            request.setAttribute("isEdit", new Boolean(isEdit));
            RequestDispatcher dispatcher = request.getRequestDispatcher("employee-form.jsp");
            dispatcher.forward(request, response);
        }
    }
}
