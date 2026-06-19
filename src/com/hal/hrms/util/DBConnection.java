package com.hal.hrms.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // Database Connection Settings (Adjust host, port, SID, user, and pass for HAL environment)
    private static final String DB_DRIVER = "oracle.jdbc.driver.OracleDriver";
    private static final String DB_URL = "jdbc:oracle:thin:@localhost:1521:XE"; // XE is standard local SID
    private static final String DB_USER = "system";
    private static final String DB_PASSWORD = "admin";

    /**
     * Obtains a standard SQL connection to the Oracle Database.
     * Compatible with Java 1.4.2 runtime.
     * 
     * @return Connection object
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName(DB_DRIVER);
        } catch (ClassNotFoundException e) {
            System.err.println("Oracle JDBC Driver not found in classpath. Ensure ojdbc14.jar is in WEB-INF/lib.");
            e.printStackTrace();
            throw new SQLException("JDBC Driver ClassNotFound: " + e.getMessage());
        }
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }
}
