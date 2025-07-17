package com.example.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * 테스트 전용 데이터베이스 연결 유틸리티
 * 프로덕션 데이터베이스 보호를 위해 별도 테스트 DB 사용
 */
public class TestDatabaseUtil {

    // 테스트 전용 데이터베이스 설정
    private static final String TEST_DB_URL = System.getProperty("test.database.url", "jdbc:postgresql://localhost:5432/promptsharing_test");
    private static final String DB_USER = "postgres";
    private static final String DB_PASS = "1234";
    private static final String JDBC_DRIVER = "org.postgresql.Driver";

    static {
        try {
            Class.forName(JDBC_DRIVER);
        } catch (ClassNotFoundException e) {
            System.err.println("PostgreSQL JDBC Driver not found.");
            e.printStackTrace();
        }
    }

    /**
     * 테스트 전용 데이터베이스 연결
     * @return 테스트 DB 연결
     * @throws SQLException
     */
    public static Connection getTestConnection() throws SQLException {
        return DriverManager.getConnection(TEST_DB_URL, DB_USER, DB_PASS);
    }

    /**
     * 테스트 DB 사용 가능 여부 확인
     * @return 테스트 DB 연결 가능 여부
     */
    public static boolean isTestDatabaseAvailable() {
        try (Connection conn = getTestConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("테스트 데이터베이스에 연결할 수 없습니다: " + e.getMessage());
            return false;
        }
    }
} 