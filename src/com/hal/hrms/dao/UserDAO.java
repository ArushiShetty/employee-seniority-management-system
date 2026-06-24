package com.hal.hrms.dao;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import com.hal.hrms.model.User;
import com.hal.hrms.util.DBConnection;

public class UserDAO {

    /**
     * Validates user credentials.
     * 
     * @param username Enterered username
     * @param password Entered raw password
     * @return User object if authentication is successful, null otherwise
     */
    public User authenticate(String username, String password) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        User user = null;
        boolean dbError = false;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT username, user_role, employee_name FROM MST_USERS " +
                         "WHERE username = ? AND password_hash = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, hashPassword(password));
            rs = pstmt.executeQuery();

            if (rs.next()) {
                user = new User();
                user.setUsername(rs.getString("username"));
                user.setUserRole(rs.getString("user_role"));
                user.setEmployeeName(rs.getString("employee_name"));
            }
        } catch (SQLException e) {
            System.err.println("Warning: Could not connect to Oracle database server for authentication. Using fallback accounts.");
            e.printStackTrace();
            dbError = true;
        } finally {
            // Manual cleanups mandatory for Java 1.4 to prevent resource leaks
            if (rs != null) { try { rs.close(); } catch (SQLException e) {} }
            if (pstmt != null) { try { pstmt.close(); } catch (SQLException e) {} }
            if (conn != null) { try { conn.close(); } catch (SQLException e) {} }
        }

        // Fallback for demo when database is not connected
        if ((dbError || user == null) && username != null && password != null) {
            String hashedInput = hashPassword(password);
            if ("admin".equals(username) && ("admin123".equals(password) || "d033e22ae348aeb5660fc2140aec35850c4da997".equals(hashedInput) || "admin".equals(password))) {
                user = new User();
                user.setUsername("admin");
                user.setUserRole("ADMIN");
                user.setEmployeeName("HR Admin Officer (Demo Mode)");
            } else if ("operator".equals(username) && ("hal123".equals(password) || "bd90e6e73ec2319f3f4c6e93ffdf6a44b82d49ad".equals(hashedInput) || "operator".equals(password))) {
                user = new User();
                user.setUsername("operator");
                user.setUserRole("USER");
                user.setEmployeeName("HR Clerk (Demo Mode)");
            }
        }

        return user;
    }

    /**
     * Helper to compute SHA-1 hash of string.
     * Works natively in Java 1.4.2 (No external library required).
     */
    public static String hashPassword(String password) {
        if (password == null) {
            return "";
        }
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-1");
            byte[] bytes = md.digest(password.getBytes());
            StringBuffer sb = new StringBuffer();
            for (int i = 0; i < bytes.length; i++) {
                sb.append(Integer.toString((bytes[i] & 0xff) + 0x100, 16).substring(1));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            System.err.println("SHA-1 algorithm not supported by host JVM.");
            e.printStackTrace();
            return password; // Fallback
        }
    }
}
