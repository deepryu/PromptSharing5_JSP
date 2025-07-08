package com.example.model;

import com.example.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 활동 히스토리 데이터 액세스 객체
 */
public class ActivityHistoryDAO {
    
    /**
     * 새로운 활동 기록 추가
     */
    public boolean addActivity(ActivityHistory activity) {
        String sql = "INSERT INTO activity_history (username, action, target_type, target_id, target_name, description, ip_address, user_agent) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, activity.getUsername());
            ps.setString(2, activity.getAction());
            ps.setString(3, activity.getTargetType());
            setIntegerOrNull(ps, 4, activity.getTargetId());
            ps.setString(5, activity.getTargetName());
            ps.setString(6, activity.getDescription());
            ps.setString(7, activity.getIpAddress());
            ps.setString(8, activity.getUserAgent());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * 전체 활동 히스토리 조회 (최신순)
     */
    public List<ActivityHistory> getAllActivities(int limit) {
        List<ActivityHistory> activities = new ArrayList<>();
        String sql = "SELECT * FROM activity_history ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    activities.add(mapResultSetToActivity(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return activities;
    }
    
    /**
     * 사용자별 활동 히스토리 조회
     */
    public List<ActivityHistory> getActivitiesByUser(String username, int limit) {
        List<ActivityHistory> activities = new ArrayList<>();
        String sql = "SELECT * FROM activity_history WHERE username = ? ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    activities.add(mapResultSetToActivity(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return activities;
    }
    
    /**
     * 오늘의 활동 통계
     */
    public List<ActivityHistory> getTodayActivities() {
        List<ActivityHistory> activities = new ArrayList<>();
        String sql = "SELECT * FROM activity_history " +
                    "WHERE DATE(created_at) = CURRENT_DATE " +
                    "ORDER BY created_at DESC LIMIT 50";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    activities.add(mapResultSetToActivity(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return activities;
    }
    
    /**
     * 최근 로그인 활동 조회
     */
    public List<ActivityHistory> getRecentLogins(int limit) {
        List<ActivityHistory> activities = new ArrayList<>();
        String sql = "SELECT * FROM activity_history WHERE action = 'login' ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    activities.add(mapResultSetToActivity(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return activities;
    }
    
    /**
     * 로그인 활동 기록
     */
    public boolean logLogin(String username, String ipAddress, String userAgent) {
        ActivityHistory activity = new ActivityHistory(username, "login", "user", null, username, "사용자 로그인");
        activity.setIpAddress(ipAddress);
        activity.setUserAgent(userAgent);
        return addActivity(activity);
    }
    
    /**
     * 로그아웃 활동 기록
     */
    public boolean logLogout(String username, String ipAddress) {
        ActivityHistory activity = new ActivityHistory(username, "logout", "user", null, username, "사용자 로그아웃");
        activity.setIpAddress(ipAddress);
        return addActivity(activity);
    }
    
    /**
     * 생성 활동 기록
     */
    public boolean logCreate(String username, String targetType, Integer targetId, String targetName, String description) {
        ActivityHistory activity = new ActivityHistory(username, "create", targetType, targetId, targetName, description);
        return addActivity(activity);
    }
    
    /**
     * 수정 활동 기록
     */
    public boolean logUpdate(String username, String targetType, Integer targetId, String targetName, String description) {
        ActivityHistory activity = new ActivityHistory(username, "update", targetType, targetId, targetName, description);
        return addActivity(activity);
    }
    
    private void setIntegerOrNull(PreparedStatement pstmt, int index, Integer value) throws SQLException {
        if (value != null) {
            pstmt.setInt(index, value);
        } else {
            pstmt.setNull(index, Types.INTEGER);
        }
    }
    
    private ActivityHistory mapResultSetToActivity(ResultSet rs) throws SQLException {
        ActivityHistory activity = new ActivityHistory();
        activity.setId(rs.getInt("id"));
        activity.setUsername(rs.getString("username"));
        activity.setAction(rs.getString("action"));
        activity.setTargetType(rs.getString("target_type"));
        
        int targetId = rs.getInt("target_id");
        if (!rs.wasNull()) {
            activity.setTargetId(targetId);
        }
        
        activity.setTargetName(rs.getString("target_name"));
        activity.setDescription(rs.getString("description"));
        activity.setIpAddress(rs.getString("ip_address"));
        activity.setUserAgent(rs.getString("user_agent"));
        activity.setCreatedAt(rs.getTimestamp("created_at"));
        
        return activity;
    }
}
