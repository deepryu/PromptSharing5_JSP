package com.example.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseUtil {

    // TODO: Move these details to a properties file for better security and flexibility.
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/promptsharing";
    private static final String DB_USER = "postgres";
    private static final String DB_PASS = "1234"; // IMPORTANT: Replace with your actual password
    private static final String JDBC_DRIVER = "org.postgresql.Driver";

    static {
        try {
            Class.forName(JDBC_DRIVER);
        } catch (ClassNotFoundException e) {
            System.err.println("PostgreSQL JDBC Driver not found.");
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }
} 