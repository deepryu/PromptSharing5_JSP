package com.example.util;

import java.io.*;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.Date;

/**
 * 백업 관리 유틸리티 클래스
 */
public class BackupManagerUtil {
    
    private static final String BACKUP_DIR = "backup/database/";
    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss");
    
    /**
     * 데이터베이스 백업 생성
     */
    public static String createDatabaseBackup() {
        try {
            // 백업 디렉토리 생성
            File backupDirectory = new File(BACKUP_DIR);
            if (!backupDirectory.exists()) {
                backupDirectory.mkdirs();
            }
            
            String timestamp = DATE_FORMAT.format(new Date());
            String backupFileName = "promptsharing_backup_" + timestamp + ".sql";
            String backupFilePath = BACKUP_DIR + backupFileName;
            
            try (Connection conn = DatabaseUtil.getConnection();
                 FileWriter writer = new FileWriter(backupFilePath)) {
                
                // 백업 헤더 작성
                writer.write("-- PromptSharing Database Backup\n");
                writer.write("-- Created: " + new Date() + "\n");
                writer.write("-- Database: promptsharing\n\n");
                
                // 테이블 목록 조회
                DatabaseMetaData metaData = conn.getMetaData();
                ResultSet tables = metaData.getTables(null, null, "%", new String[]{"TABLE"});
                
                List<String> tableNames = new ArrayList<>();
                while (tables.next()) {
                    String tableName = tables.getString("TABLE_NAME");
                    if (!tableName.startsWith("pg_") && !tableName.startsWith("information_schema")) {
                        tableNames.add(tableName);
                    }
                }
                
                // 각 테이블 백업
                for (String tableName : tableNames) {
                    backupTable(conn, writer, tableName);
                }
                
                return backupFileName;
                
            } catch (Exception e) {
                return null;
            }
            
        } catch (Exception e) {
            return null;
        }
    }
    
    /**
     * 개별 테이블 백업
     */
    private static void backupTable(Connection conn, FileWriter writer, String tableName) throws Exception {
        writer.write("\n-- Table: " + tableName + "\n");
        
        // 테이블 구조 백업 (간단한 형태)
        writer.write("-- Structure for table " + tableName + "\n");
        
        // 데이터 백업
        String sql = "SELECT * FROM " + tableName;
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            ResultSetMetaData rsmd = rs.getMetaData();
            int columnCount = rsmd.getColumnCount();
            
            while (rs.next()) {
                writer.write("INSERT INTO " + tableName + " VALUES (");
                for (int i = 1; i <= columnCount; i++) {
                    Object value = rs.getObject(i);
                    if (value == null) {
                        writer.write("NULL");
                    } else if (value instanceof String || value instanceof Date) {
                        writer.write("'" + value.toString().replace("'", "''") + "'");
                    } else {
                        writer.write(value.toString());
                    }
                    if (i < columnCount) writer.write(", ");
                }
                writer.write(");\n");
            }
        }
    }
    
    /**
     * 백업 파일 목록 조회
     */
    public static List<Map<String, Object>> getBackupFiles() {
        List<Map<String, Object>> backupFiles = new ArrayList<>();
        
        File backupDirectory = new File(BACKUP_DIR);
        if (!backupDirectory.exists()) {
            return backupFiles;
        }
        
        File[] files = backupDirectory.listFiles((dir, name) -> name.endsWith(".sql"));
        if (files != null) {
            for (File file : files) {
                Map<String, Object> fileInfo = new HashMap<>();
                fileInfo.put("name", file.getName());
                fileInfo.put("size", formatFileSize(file.length()));
                fileInfo.put("lastModified", new Date(file.lastModified()));
                fileInfo.put("path", file.getAbsolutePath());
                backupFiles.add(fileInfo);
            }
            
            // 날짜순 정렬 (최신순)
            backupFiles.sort((a, b) -> ((Date)b.get("lastModified")).compareTo((Date)a.get("lastModified")));
        }
        
        return backupFiles;
    }
    
    /**
     * 백업 파일 삭제
     */
    public static boolean deleteBackupFile(String fileName) {
        try {
            File file = new File(BACKUP_DIR + fileName);
            return file.delete();
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * 파일 크기 포맷팅
     */
    private static String formatFileSize(long bytes) {
        if (bytes < 1024) return bytes + " B";
        int exp = (int) (Math.log(bytes) / Math.log(1024));
        String pre = "KMGTPE".charAt(exp-1) + "";
        return String.format("%.1f %sB", bytes / Math.pow(1024, exp), pre);
    }
    
    /**
     * 시스템 정보 조회
     */
    public static Map<String, Object> getSystemInfo() {
        Map<String, Object> systemInfo = new HashMap<>();
        
        // JVM 정보
        Runtime runtime = Runtime.getRuntime();
        systemInfo.put("totalMemory", runtime.totalMemory() / 1024 / 1024);
        systemInfo.put("freeMemory", runtime.freeMemory() / 1024 / 1024);
        systemInfo.put("maxMemory", runtime.maxMemory() / 1024 / 1024);
        systemInfo.put("usedMemory", (runtime.totalMemory() - runtime.freeMemory()) / 1024 / 1024);
        
        // 시스템 속성
        systemInfo.put("javaVersion", System.getProperty("java.version"));
        systemInfo.put("osName", System.getProperty("os.name"));
        systemInfo.put("osVersion", System.getProperty("os.version"));
        systemInfo.put("userDir", System.getProperty("user.dir"));
        
        // 데이터베이스 정보
        try (Connection conn = DatabaseUtil.getConnection()) {
            DatabaseMetaData metaData = conn.getMetaData();
            systemInfo.put("dbName", metaData.getDatabaseProductName());
            systemInfo.put("dbVersion", metaData.getDatabaseProductVersion());
            systemInfo.put("driverName", metaData.getDriverName());
            systemInfo.put("driverVersion", metaData.getDriverVersion());
        } catch (Exception e) {
            systemInfo.put("dbError", e.getMessage());
        }
        
        return systemInfo;
    }
} 