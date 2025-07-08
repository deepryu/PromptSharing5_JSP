package com.example.model;

import com.example.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 알림 데이터 액세스 객체
 */
public class NotificationDAO {
    
    /**
     * 새로운 알림 추가
     */
    public boolean addNotification(Notification notification) {
        String sql = "INSERT INTO notifications (title, content, type, target_user, related_type, related_id) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, notification.getTitle());
            ps.setString(2, notification.getContent());
            ps.setString(3, notification.getType());
            ps.setString(4, notification.getTargetUser());
            ps.setString(5, notification.getRelatedType());
            setIntegerOrNull(ps, 6, notification.getRelatedId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * 사용자별 알림 목록 조회 (읽지 않은 것 우선)
     */
    public List<Notification> getNotificationsByUser(String username, int limit) {
        List<Notification> notifications = new ArrayList<>();
        String sql = "SELECT * FROM notifications " +
                    "WHERE target_user IS NULL OR target_user = ? " +
                    "ORDER BY is_read ASC, created_at DESC " +
                    "LIMIT ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    notifications.add(mapResultSetToNotification(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return notifications;
    }
    
    /**
     * 전체 알림 목록 조회 (관리자용)
     */
    public List<Notification> getAllNotifications(int limit) {
        List<Notification> notifications = new ArrayList<>();
        String sql = "SELECT * FROM notifications ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    notifications.add(mapResultSetToNotification(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return notifications;
    }
    
    /**
     * 읽지 않은 알림 수 조회
     */
    public int getUnreadCount(String username) {
        String sql = "SELECT COUNT(*) FROM notifications " +
                    "WHERE (target_user IS NULL OR target_user = ?) AND is_read = false";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    /**
     * 알림을 읽음 상태로 변경
     */
    public boolean markAsRead(int notificationId) {
        String sql = "UPDATE notifications SET is_read = true, read_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * 사용자의 모든 알림을 읽음 상태로 변경
     */
    public boolean markAllAsRead(String username) {
        String sql = "UPDATE notifications SET is_read = true, read_at = CURRENT_TIMESTAMP " +
                    "WHERE (target_user IS NULL OR target_user = ?) AND is_read = false";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * 알림 삭제
     */
    public boolean deleteNotification(int id) {
        String sql = "DELETE FROM notifications WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * 오래된 알림 정리 (30일 이상)
     */
    public int cleanupOldNotifications() {
        String sql = "DELETE FROM notifications WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '30 days'";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    /**
     * 시스템 알림 생성 (관리자 전용)
     */
    public boolean createSystemNotification(String title, String content, String type) {
        Notification notification = new Notification(title, content, type, null, "system", null);
        return addNotification(notification);
    }
    
    /**
     * 특정 사용자 대상 알림 생성
     */
    public boolean createUserNotification(String username, String title, String content, 
                                         String type, String relatedType, Integer relatedId) {
        Notification notification = new Notification(title, content, type, username, relatedType, relatedId);
        return addNotification(notification);
    }
    
    /**
     * 면접 일정 관련 알림 생성
     */
    public boolean createScheduleNotification(String title, String content, int scheduleId) {
        Notification notification = new Notification(title, content, "info", null, "schedule", scheduleId);
        return addNotification(notification);
    }
    
    private void setIntegerOrNull(PreparedStatement pstmt, int index, Integer value) throws SQLException {
        if (value != null) {
            pstmt.setInt(index, value);
        } else {
            pstmt.setNull(index, Types.INTEGER);
        }
    }
    
    private Notification mapResultSetToNotification(ResultSet rs) throws SQLException {
        Notification notification = new Notification();
        notification.setId(rs.getInt("id"));
        notification.setTitle(rs.getString("title"));
        notification.setContent(rs.getString("content"));
        notification.setType(rs.getString("type"));
        notification.setTargetUser(rs.getString("target_user"));
        notification.setRead(rs.getBoolean("is_read"));
        notification.setRelatedType(rs.getString("related_type"));
        
        int relatedId = rs.getInt("related_id");
        if (!rs.wasNull()) {
            notification.setRelatedId(relatedId);
        }
        
        notification.setCreatedAt(rs.getTimestamp("created_at"));
        notification.setReadAt(rs.getTimestamp("read_at"));
        
        return notification;
    }
} 