package com.hal.hrms.servlet;

import java.io.IOException;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.hal.hrms.dao.UserDAO;
import com.hal.hrms.model.User;

public class LoginServlet extends HttpServlet {

    private UserDAO userDAO;

    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Direct GET request to login servlet redirects to the login view page
        RequestDispatcher dispatcher = request.getRequestDispatcher("login.jsp");
        dispatcher.forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        User user = userDAO.authenticate(username, password);

        if (user != null) {
            // Setup session
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);
            
            // Redirect to dashboard
            response.sendRedirect("dashboard");
        } else {
            // Return failure state
            request.setAttribute("error", "Authentication failed. Invalid Employee ID or Password.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("login.jsp");
            dispatcher.forward(request, response);
        }
    }
}
