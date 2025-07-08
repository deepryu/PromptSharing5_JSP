package com.example.model;

import com.example.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

/**
 * 평가 기준 데이터 액세스 객체
 * 데이터베이스와의 모든 평가 기준 관련 작업을 처리
 */
public class EvaluationCriteriaDAO {
    
    /**
     * 모든 평가 기준 조회
     */
    public List<EvaluationCriteria> getAllCriteria() {
        List<EvaluationCriteria> criteria = new ArrayList<>();
        String sql = "SELECT * FROM evaluation_criteria ORDER BY weight DESC, criteria_name";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                criteria.add(mapResultSetToCriteria(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return criteria;
    }
    
    /**
     * 활성화된 평가 기준만 조회
     */
    public List<EvaluationCriteria> getActiveCriteria() {
        List<EvaluationCriteria> criteria = new ArrayList<>();
        String sql = "SELECT * FROM evaluation_criteria WHERE is_active = true ORDER BY weight DESC, criteria_name";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                criteria.add(mapResultSetToCriteria(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return criteria;
    }
    
    /**
     * ID로 특정 평가 기준 조회
     */
    public EvaluationCriteria getCriteriaById(int id) {
        String sql = "SELECT * FROM evaluation_criteria WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCriteria(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * 새 평가 기준 추가
     */
    public boolean addCriteria(EvaluationCriteria criteria) {
        String sql = "INSERT INTO evaluation_criteria (criteria_name, description, max_score, weight, is_active) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, criteria.getCriteriaName());
            pstmt.setString(2, criteria.getDescription());
            pstmt.setInt(3, criteria.getMaxScore());
            pstmt.setBigDecimal(4, criteria.getWeight());
            pstmt.setBoolean(5, criteria.isActive());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 평가 기준 정보 수정
     */
    public boolean updateCriteria(EvaluationCriteria criteria) {
        String sql = "UPDATE evaluation_criteria SET criteria_name = ?, description = ?, max_score = ?, weight = ?, is_active = ? WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, criteria.getCriteriaName());
            pstmt.setString(2, criteria.getDescription());
            pstmt.setInt(3, criteria.getMaxScore());
            pstmt.setBigDecimal(4, criteria.getWeight());
            pstmt.setBoolean(5, criteria.isActive());
            pstmt.setInt(6, criteria.getId());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 평가 기준 삭제 (실제로는 비활성화)
     */
    public boolean deleteCriteria(int id) {
        String sql = "UPDATE evaluation_criteria SET is_active = false WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 평가 기준 완전 삭제 (물리적 삭제)
     */
    public boolean permanentDeleteCriteria(int id) {
        String sql = "DELETE FROM evaluation_criteria WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 평가 기준 활성화/비활성화 토글
     */
    public boolean toggleCriteriaStatus(int id) {
        String sql = "UPDATE evaluation_criteria SET is_active = NOT is_active WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 키워드로 평가 기준 검색
     */
    public List<EvaluationCriteria> searchCriteria(String keyword) {
        List<EvaluationCriteria> criteria = new ArrayList<>();
        String sql = "SELECT * FROM evaluation_criteria WHERE " +
                    "(criteria_name ILIKE ? OR description ILIKE ?) AND is_active = true " +
                    "ORDER BY weight DESC, criteria_name";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            pstmt.setString(1, searchPattern);
            pstmt.setString(2, searchPattern);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    criteria.add(mapResultSetToCriteria(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return criteria;
    }
    
    /**
     * 가중치 범위로 평가 기준 조회
     */
    public List<EvaluationCriteria> getCriteriaByWeightRange(BigDecimal minWeight, BigDecimal maxWeight) {
        List<EvaluationCriteria> criteria = new ArrayList<>();
        String sql = "SELECT * FROM evaluation_criteria WHERE weight >= ? AND weight <= ? AND is_active = true ORDER BY weight DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setBigDecimal(1, minWeight);
            pstmt.setBigDecimal(2, maxWeight);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    criteria.add(mapResultSetToCriteria(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return criteria;
    }
    
    /**
     * 전체 활성 평가 기준 수
     */
    public int getTotalActiveCriteriaCount() {
        String sql = "SELECT COUNT(*) FROM evaluation_criteria WHERE is_active = true";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * 평가 기준명 중복 체크
     */
    public boolean isCriteriaNameDuplicate(String criteriaName, int excludeId) {
        String sql = "SELECT COUNT(*) FROM evaluation_criteria WHERE criteria_name = ? AND id != ? AND is_active = true";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, criteriaName);
            pstmt.setInt(2, excludeId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * 총 가중치 합계 계산
     */
    public BigDecimal getTotalWeight() {
        String sql = "SELECT SUM(weight) FROM evaluation_criteria WHERE is_active = true";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            if (rs.next()) {
                BigDecimal total = rs.getBigDecimal(1);
                return total != null ? total : BigDecimal.ZERO;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return BigDecimal.ZERO;
    }
    
    /**
     * 가중치별 평가 기준 통계
     */
    public List<Object[]> getWeightStatistics() {
        List<Object[]> stats = new ArrayList<>();
        String sql = "SELECT " +
                    "CASE " +
                    "  WHEN weight >= 1.4 THEN '매우 중요' " +
                    "  WHEN weight >= 1.2 THEN '중요' " +
                    "  WHEN weight >= 1.0 THEN '보통' " +
                    "  WHEN weight >= 0.8 THEN '낮음' " +
                    "  ELSE '매우 낮음' " +
                    "END as importance_level, " +
                    "COUNT(*) as count " +
                    "FROM evaluation_criteria " +
                    "WHERE is_active = true " +
                    "GROUP BY importance_level " +
                    "ORDER BY MIN(weight) DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                Object[] stat = new Object[2];
                stat[0] = rs.getString("importance_level");
                stat[1] = rs.getInt("count");
                stats.add(stat);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return stats;
    }
    
    /**
     * 최대 점수별 평가 기준 조회
     */
    public List<EvaluationCriteria> getCriteriaByMaxScore(int maxScore) {
        List<EvaluationCriteria> criteria = new ArrayList<>();
        String sql = "SELECT * FROM evaluation_criteria WHERE max_score = ? AND is_active = true ORDER BY weight DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, maxScore);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    criteria.add(mapResultSetToCriteria(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return criteria;
    }
    
    /**
     * ResultSet을 EvaluationCriteria 객체로 매핑하는 헬퍼 메서드
     */
    private EvaluationCriteria mapResultSetToCriteria(ResultSet rs) throws SQLException {
        EvaluationCriteria criteria = new EvaluationCriteria();
        criteria.setId(rs.getInt("id"));
        criteria.setCriteriaName(rs.getString("criteria_name"));
        criteria.setDescription(rs.getString("description"));
        criteria.setMaxScore(rs.getInt("max_score"));
        criteria.setWeight(rs.getBigDecimal("weight"));
        criteria.setActive(rs.getBoolean("is_active"));
        criteria.setCreatedAt(rs.getTimestamp("created_at"));
        criteria.setUpdatedAt(rs.getTimestamp("updated_at"));
        return criteria;
    }
}