package com.hal.hrms.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DBConnection {

    private static Properties properties = new Properties();

    static {
        InputStream is = null;
        try {
            is = DBConnection.class.getClassLoader().getResourceAsStream("db.properties");
            if (is != null) {
                properties.load(is);
                System.out.println("DBConnection: db.properties loaded successfully.");
            } else {
                System.err.println("DBConnection WARNING: db.properties not found in classpath. Using fallback values.");
                // Fallback default values
                properties.setProperty("db.driver", "oracle.jdbc.driver.OracleDriver");
                properties.setProperty("db.url", "jdbc:oracle:thin:@localhost:1521:XE");
                properties.setProperty("db.username", "system");
                properties.setProperty("db.password", "admin");
                
                properties.setProperty("table.employees", "MST_EMPLOYEES");
                properties.setProperty("table.promotions", "TRN_PROMOTIONS");
                
                properties.setProperty("col.emp.id", "employee_id");
                properties.setProperty("col.emp.name", "employee_name");
                properties.setProperty("col.emp.grade", "grade");
                properties.setProperty("col.emp.level", "emp_level");
                properties.setProperty("col.emp.promo_date", "promotion_date");
                properties.setProperty("col.emp.doj", "date_of_joining");
                properties.setProperty("col.emp.dob", "date_of_birth");
                properties.setProperty("col.emp.dept", "department");
                properties.setProperty("col.emp.desig", "designation");
                
                properties.setProperty("col.promo.id", "promotion_id");
                properties.setProperty("col.promo.emp_id", "employee_id");
                properties.setProperty("col.promo.grade", "grade");
                properties.setProperty("col.promo.date", "promotion_date");
                properties.setProperty("col.promo.order_num", "order_number");
                properties.setProperty("col.promo.pos_code", "pos_code");
                properties.setProperty("col.promo.valid_from", "valid_from");
                properties.setProperty("col.promo.valid_to", "valid_to");
                properties.setProperty("col.promo.is_primary", "is_primary");
                properties.setProperty("col.promo.assignment_type", "assignment_type");
            }
        } catch (Exception e) {
            System.err.println("DBConnection ERROR: Failed to load db.properties.");
            e.printStackTrace();
        } finally {
            if (is != null) {
                try { is.close(); } catch (Exception e) {}
            }
        }
    }

    /**
     * Retrieves a database configuration property.
     */
    public static String getProperty(String key) {
        return properties.getProperty(key);
    }

    /**
     * Obtains a standard SQL connection to the Oracle Database.
     * Compatible with Java 1.4.2 runtime.
     * 
     * @return Connection object
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        String driver = getProperty("db.driver");
        String url = getProperty("db.url");
        String user = getProperty("db.username");
        String pass = getProperty("db.password");
        
        try {
            Class.forName(driver);
        } catch (ClassNotFoundException e) {
            System.err.println("Oracle JDBC Driver not found in classpath: " + driver);
            e.printStackTrace();
            throw new SQLException("JDBC Driver ClassNotFound: " + e.getMessage());
        }
        return DriverManager.getConnection(url, user, pass);
    }
}
