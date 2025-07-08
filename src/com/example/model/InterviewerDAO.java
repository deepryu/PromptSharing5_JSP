package com.example.model;

import com.example.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 면접관 데이터베이스 접근 클래스
 */
public class InterviewerDAO {
    
    /**
     * 새로운 면접관 추가
     */
    public boolean addInterviewer(Interviewer interviewer) {
        String sql = "INSERT INTO interviewers (name, email, department, position, phone_number, " +
                    "expertise, role, is_active, notes) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, interviewer.getName());
            pstmt.setString(2, interviewer.getEmail());
            pstmt.setString(3, interviewer.getDepartment());
            pstmt.setString(4, interviewer.getPosition());
            pstmt.setString(5, interviewer.getPhoneNumber());
            pstmt.setString(6, interviewer.getExpertise());
            pstmt.setString(7, interviewer.getRole());
            pstmt.setBoolean(8, interviewer.isActive());
            pstmt.setString(9, interviewer.getNotes());
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 모든 면접관 조회
     */
    public List<Interviewer> getAllInterviewers() {
        List<Interviewer> interviewers = new ArrayList<>();
        String sql = "SELECT * FROM interviewers ORDER BY name ASC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                interviewers.add(mapResultSetToInterviewer(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return interviewers;
    }
    
    /**
     * 활성 면접관만 조회
     */
    public List<Interviewer> getActiveInterviewers() {
        List<Interviewer> interviewers = new ArrayList<>();
        String sql = "SELECT * FROM interviewers WHERE is_active = true ORDER BY name ASC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                interviewers.add(mapResultSetToInterviewer(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return interviewers;
    }
    
    /**
     * ID로 면접관 조회
     */
    public Interviewer getInterviewerById(int id) {
        String sql = "SELECT * FROM interviewers WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToInterviewer(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * 이메일로 면접관 조회
     */
    public Interviewer getInterviewerByEmail(String email) {
        String sql = "SELECT * FROM interviewers WHERE email = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToInterviewer(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * 부서별 면접관 조회
     */
    public List<Interviewer> getInterviewersByDepartment(String department) {
        List<Interviewer> interviewers = new ArrayList<>();
        String sql = "SELECT * FROM interviewers WHERE department = ? AND is_active = true ORDER BY name ASC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, department);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                interviewers.add(mapResultSetToInterviewer(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return interviewers;
    }
    
    /**
     * 전문분야별 면접관 조회
     */
    public List<Interviewer> getInterviewersByExpertise(String expertise) {
        List<Interviewer> interviewers = new ArrayList<>();
        String sql = "SELECT * FROM interviewers WHERE expertise = ? AND is_active = true ORDER BY name ASC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, expertise);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                interviewers.add(mapResultSetToInterviewer(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return interviewers;
    }
    
    /**
     * 면접관 정보 수정
     */
    public boolean updateInterviewer(Interviewer interviewer) {
        String sql = "UPDATE interviewers SET name = ?, email = ?, department = ?, position = ?, " +
                    "phone_number = ?, expertise = ?, role = ?, is_active = ?, notes = ?, updated_at = CURRENT_TIMESTAMP " +
                    "WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, interviewer.getName());
            pstmt.setString(2, interviewer.getEmail());
            pstmt.setString(3, interviewer.getDepartment());
            pstmt.setString(4, interviewer.getPosition());
            pstmt.setString(5, interviewer.getPhoneNumber());
            pstmt.setString(6, interviewer.getExpertise());
            pstmt.setString(7, interviewer.getRole());
            pstmt.setBoolean(8, interviewer.isActive());
            pstmt.setString(9, interviewer.getNotes());
            pstmt.setInt(10, interviewer.getId());
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 면접관 삭제 (실제로는 비활성화)
     */
    public boolean deleteInterviewer(int id) {
        String sql = "UPDATE interviewers SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 면접관 검색 (이름, 이메일, 부서로 검색)
     */
    public List<Interviewer> searchInterviewers(String keyword) {
        List<Interviewer> interviewers = new ArrayList<>();
        String sql = "SELECT * FROM interviewers WHERE " +
                    "(name ILIKE ? OR email ILIKE ? OR department ILIKE ?) " +
                    "ORDER BY name ASC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            pstmt.setString(1, searchPattern);
            pstmt.setString(2, searchPattern);
            pstmt.setString(3, searchPattern);
            
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                interviewers.add(mapResultSetToInterviewer(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return interviewers;
    }
    
    /**
     * 면접관 통계 정보 조회
     */
    public Map<String, Integer> getInterviewerStats() {
        Map<String, Integer> stats = new HashMap<>();
        
        // 전체 면접관 수
        String totalSql = "SELECT COUNT(*) as total FROM interviewers";
        // 활성 면접관 수
        String activeSql = "SELECT COUNT(*) as active FROM interviewers WHERE is_active = true";
        // 부서별 통계
        String deptSql = "SELECT department, COUNT(*) as count FROM interviewers WHERE is_active = true GROUP BY department";
        // 전문분야별 통계
        String expertiseSql = "SELECT expertise, COUNT(*) as count FROM interviewers WHERE is_active = true GROUP BY expertise";
        
        try (Connection conn = DatabaseUtil.getConnection()) {
            // 전체 수
            try (PreparedStatement pstmt = conn.prepareStatement(totalSql);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("total", rs.getInt("total"));
                }
            }
            
            // 활성 수
            try (PreparedStatement pstmt = conn.prepareStatement(activeSql);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("active", rs.getInt("active"));
                }
            }
            
            // 부서별 통계
            try (PreparedStatement pstmt = conn.prepareStatement(deptSql);
                 ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    stats.put("dept_" + rs.getString("department"), rs.getInt("count"));
                }
            }
            
            // 전문분야별 통계
            try (PreparedStatement pstmt = conn.prepareStatement(expertiseSql);
                 ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    stats.put("exp_" + rs.getString("expertise"), rs.getInt("count"));
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return stats;
    }
    
    /**
     * ResultSet을 Interviewer 객체로 매핑
     */
    private Interviewer mapResultSetToInterviewer(ResultSet rs) throws SQLException {
        Interviewer interviewer = new Interviewer();
        interviewer.setId(rs.getInt("id"));
        interviewer.setName(rs.getString("name"));
        interviewer.setEmail(rs.getString("email"));
        interviewer.setDepartment(rs.getString("department"));
        interviewer.setPosition(rs.getString("position"));
        interviewer.setPhoneNumber(rs.getString("phone_number"));
        interviewer.setExpertise(rs.getString("expertise"));
        interviewer.setRole(rs.getString("role"));
        interviewer.setActive(rs.getBoolean("is_active"));
        interviewer.setNotes(rs.getString("notes"));
        interviewer.setCreatedAt(rs.getTimestamp("created_at"));
        interviewer.setUpdatedAt(rs.getTimestamp("updated_at"));
        return interviewer;
    }
} 