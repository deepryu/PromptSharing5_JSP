package com.example.model;

import java.sql.*;
import java.util.HashMap;
import java.util.Map;
import com.example.util.DatabaseUtil;

public class SystemSettingsDAO {
    
    public SystemSettingsDAO() {
        try {
            createTableIfNotExists();
            initializeDefaultSettings();
        } catch (SQLException e) {
            System.err.println("SystemSettingsDAO 초기화 실패: " + e.getMessage());
        }
    }
    
    private void createTableIfNotExists() throws SQLException {
        String sql = "CREATE TABLE IF NOT EXISTS system_settings (" +
                    "id SERIAL PRIMARY KEY," +
                    "setting_key VARCHAR(100) UNIQUE NOT NULL," +
                    "setting_value TEXT," +
                    "description TEXT," +
                    "category VARCHAR(50) DEFAULT 'SYSTEM'," +
                    "is_active BOOLEAN DEFAULT true," +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                    "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
        }
    }
    
    private void initializeDefaultSettings() throws SQLException {
        if (!settingExists("SYSTEM_NAME")) {
            SystemSettings setting = new SystemSettings();
            setting.setSettingKey("SYSTEM_NAME");
            setting.setSettingValue("채용 관리 시스템");
            setting.setDescription("시스템 이름");
            setting.setCategory("SYSTEM");
            setting.setIsActive(true);
            insertSetting(setting);
        }
    }
    
    private boolean settingExists(String key) throws SQLException {
        String sql = "SELECT COUNT(*) FROM system_settings WHERE setting_key = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, key);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }
    
    public Map<String, SystemSettings> getAllSettings() throws SQLException {
        Map<String, SystemSettings> settings = new HashMap<>();
        String sql = "SELECT * FROM system_settings ORDER BY category, setting_key";
        
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                SystemSettings setting = mapResultSetToSetting(rs);
                settings.put(setting.getSettingKey(), setting);
            }
        }
        return settings;
    }
    
    public SystemSettings getSettingByKey(String key) throws SQLException {
        String sql = "SELECT * FROM system_settings WHERE setting_key = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, key);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSetting(rs);
                }
            }
        }
        return null;
    }
    
    public boolean updateSetting(SystemSettings setting) throws SQLException {
        String sql = "INSERT INTO system_settings (setting_key, setting_value, description, category, is_active) " +
                    "VALUES (?, ?, ?, ?, ?) " +
                    "ON CONFLICT (setting_key) DO UPDATE SET " +
                    "setting_value = EXCLUDED.setting_value, " +
                    "description = EXCLUDED.description, " +
                    "category = EXCLUDED.category, " +
                    "is_active = EXCLUDED.is_active, " +
                    "updated_at = CURRENT_TIMESTAMP";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, setting.getSettingKey());
            pstmt.setString(2, setting.getSettingValue());
            pstmt.setString(3, setting.getDescription());
            pstmt.setString(4, setting.getCategory());
            pstmt.setBoolean(5, setting.getIsActive());
            return pstmt.executeUpdate() > 0;
        }
    }
    
    private boolean insertSetting(SystemSettings setting) throws SQLException {
        String sql = "INSERT INTO system_settings (setting_key, setting_value, description, category, is_active) " +
                    "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, setting.getSettingKey());
            pstmt.setString(2, setting.getSettingValue());
            pstmt.setString(3, setting.getDescription());
            pstmt.setString(4, setting.getCategory());
            pstmt.setBoolean(5, setting.getIsActive());
            return pstmt.executeUpdate() > 0;
        }
    }
    
    public boolean resetToDefaults() throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String deleteSQL = "DELETE FROM system_settings";
                try (Statement stmt = conn.createStatement()) {
                    stmt.execute(deleteSQL);
                }
                initializeDefaultSettings();
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }
    
    private SystemSettings mapResultSetToSetting(ResultSet rs) throws SQLException {
        SystemSettings setting = new SystemSettings();
        setting.setId(rs.getInt("id"));
        setting.setSettingKey(rs.getString("setting_key"));
        setting.setSettingValue(rs.getString("setting_value"));
        setting.setDescription(rs.getString("description"));
        setting.setCategory(rs.getString("category"));
        setting.setIsActive(rs.getBoolean("is_active"));
        setting.setCreatedAt(rs.getTimestamp("created_at"));
        setting.setUpdatedAt(rs.getTimestamp("updated_at"));
        return setting;
    }
} 