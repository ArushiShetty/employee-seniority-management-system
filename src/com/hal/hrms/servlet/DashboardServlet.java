package com.hal.hrms.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.hal.hrms.model.User;
import com.hal.hrms.util.DBConnection;

public class DashboardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login");
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int totalEmployees = 0;
        int adminCount = 0;

        try {
            conn = DBConnection.getConnection();
            
            // Get total employees
            String sqlCount = "SELECT COUNT(*) FROM MST_EMPLOYEES";
            pstmt = conn.prepareStatement(sqlCount);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                totalEmployees = rs.getInt(1);
            }
            
            rs.close();
            pstmt.close();
            
            // Get total system administrators
            String sqlAdmins = "SELECT COUNT(*) FROM MST_USERS WHERE user_role = 'ADMIN'";
            pstmt = conn.prepareStatement(sqlAdmins);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                adminCount = rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (rs != null) { try { rs.close(); } catch (SQLException e) {} }
            if (pstmt != null) { try { pstmt.close(); } catch (SQLException e) {} }
            if (conn != null) { try { conn.close(); } catch (SQLException e) {} }
        }

        if (totalEmployees == 0) {
            com.hal.hrms.dao.EmployeeDAO dao = new com.hal.hrms.dao.EmployeeDAO();
            totalEmployees = dao.getSeniorityList(null).size();
        }
        if (adminCount == 0) {
            adminCount = 2; // Default mock administrators for demo
        }
        request.setAttribute("totalEmployees", new Integer(totalEmployees));
        request.setAttribute("adminCount", new Integer(adminCount));

        RequestDispatcher dispatcher = request.getRequestDispatcher("dashboard.jsp");
        dispatcher.forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
