package com.example.model;

import com.example.util.DatabaseUtil;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 인터뷰 결과 데이터 액세스 객체
 * 데이터베이스와의 모든 인터뷰 결과 관련 작업을 처리
 */
public class InterviewResultDAO {
    
    /**
     * 인터뷰 결과 추가
     */
    public boolean addResult(InterviewResult result) {
        // 중복 체크
        boolean exists = isResultExists(result.getCandidateId(), result.getInterviewDate(), result.getInterviewerName());
        
        if (exists) {
            return false;
        }
        String sql = "INSERT INTO interview_results (candidate_id, schedule_id, interviewer_name, " +
                    "interview_date, interview_type, technical_score, communication_score, " +
                    "problem_solving_score, attitude_score, overall_score, strengths, weaknesses, " +
                    "detailed_feedback, improvement_suggestions, result_status, hire_recommendation, next_step) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setInt(1, result.getCandidateId());
            if (result.getScheduleId() != null) {
                pstmt.setInt(2, result.getScheduleId());
            } else {
                pstmt.setNull(2, Types.INTEGER);
            }
            pstmt.setString(3, result.getInterviewerName());
            pstmt.setDate(4, result.getInterviewDate());
            pstmt.setString(5, result.getInterviewType());
            setIntegerOrNull(pstmt, 6, result.getTechnicalScore());
            setIntegerOrNull(pstmt, 7, result.getCommunicationScore());
            setIntegerOrNull(pstmt, 8, result.getProblemSolvingScore());
            setIntegerOrNull(pstmt, 9, result.getAttitudeScore());
            if (result.getOverallScore() != null) {
                pstmt.setBigDecimal(10, result.getOverallScore());
            } else {
                pstmt.setNull(10, Types.DECIMAL);
            }
            pstmt.setString(11, result.getStrengths());
            pstmt.setString(12, result.getWeaknesses());
            pstmt.setString(13, result.getDetailedFeedback());
            pstmt.setString(14, result.getImprovementSuggestions());
            pstmt.setString(15, result.getResultStatus());
            pstmt.setString(16, result.getHireRecommendation());
            pstmt.setString(17, result.getNextStep());
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                // 새로 생성된 ID를 결과 객체에 설정
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int newId = generatedKeys.getInt(1);
                        result.setId(newId);
                    }
                }
                return true;
            }
            
            return false;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 모든 인터뷰 결과 조회 (지원자 이름 포함)
     */
    public List<InterviewResult> getAllResults() {
        List<InterviewResult> results = new ArrayList<>();
        String sql = "SELECT ir.*, c.name as candidate_name " +
                    "FROM interview_results ir " +
                    "JOIN candidates c ON ir.candidate_id = c.id " +
                    "ORDER BY ir.interview_date DESC, ir.created_at DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                results.add(mapResultSetToInterviewResult(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return results;
    }
    
    /**
     * ID로 인터뷰 결과 조회
     */
    public InterviewResult getResultById(int id) {
        String sql = "SELECT ir.*, c.name as candidate_name " +
                    "FROM interview_results ir " +
                    "JOIN candidates c ON ir.candidate_id = c.id " +
                    "WHERE ir.id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToInterviewResult(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * 지원자별 인터뷰 결과 조회
     */
    public List<InterviewResult> getResultsByCandidateId(int candidateId) {
        List<InterviewResult> results = new ArrayList<>();
        String sql = "SELECT ir.*, c.name as candidate_name " +
                    "FROM interview_results ir " +
                    "JOIN candidates c ON ir.candidate_id = c.id " +
                    "WHERE ir.candidate_id = ? " +
                    "ORDER BY ir.interview_date DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, candidateId);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                results.add(mapResultSetToInterviewResult(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return results;
    }
    
    /**
     * 결과 상태별 인터뷰 결과 조회
     */
    public List<InterviewResult> getResultsByStatus(String status) {
        List<InterviewResult> results = new ArrayList<>();
        String sql = "SELECT ir.*, c.name as candidate_name " +
                    "FROM interview_results ir " +
                    "JOIN candidates c ON ir.candidate_id = c.id " +
                    "WHERE ir.result_status = ? " +
                    "ORDER BY ir.interview_date DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, status);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                results.add(mapResultSetToInterviewResult(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return results;
    }
    
    /**
     * 인터뷰 결과 수정
     */
    public boolean updateResult(InterviewResult result) {
        String sql = "UPDATE interview_results SET candidate_id = ?, schedule_id = ?, " +
                    "interviewer_name = ?, interview_date = ?, interview_type = ?, " +
                    "technical_score = ?, communication_score = ?, problem_solving_score = ?, " +
                    "attitude_score = ?, overall_score = ?, strengths = ?, weaknesses = ?, " +
                    "detailed_feedback = ?, improvement_suggestions = ?, result_status = ?, " +
                    "hire_recommendation = ?, next_step = ?, updated_at = CURRENT_TIMESTAMP " +
                    "WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, result.getCandidateId());
            if (result.getScheduleId() != null) {
                pstmt.setInt(2, result.getScheduleId());
            } else {
                pstmt.setNull(2, Types.INTEGER);
            }
            pstmt.setString(3, result.getInterviewerName());
            pstmt.setDate(4, result.getInterviewDate());
            pstmt.setString(5, result.getInterviewType());
            
            // 점수들 설정 (null 가능)
            setIntegerOrNull(pstmt, 6, result.getTechnicalScore());
            setIntegerOrNull(pstmt, 7, result.getCommunicationScore());
            setIntegerOrNull(pstmt, 8, result.getProblemSolvingScore());
            setIntegerOrNull(pstmt, 9, result.getAttitudeScore());
            
            if (result.getOverallScore() != null) {
                pstmt.setBigDecimal(10, result.getOverallScore());
            } else {
                pstmt.setNull(10, Types.DECIMAL);
            }
            
            pstmt.setString(11, result.getStrengths());
            pstmt.setString(12, result.getWeaknesses());
            pstmt.setString(13, result.getDetailedFeedback());
            pstmt.setString(14, result.getImprovementSuggestions());
            pstmt.setString(15, result.getResultStatus());
            pstmt.setString(16, result.getHireRecommendation());
            pstmt.setString(17, result.getNextStep());
            pstmt.setInt(18, result.getId());
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 인터뷰 결과 삭제
     */
    public boolean deleteResult(int id) {
        String sql = "DELETE FROM interview_results WHERE id = ?";
        
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
     * 결과 상태별 통계 조회
     */
    public java.util.Map<String, Integer> getResultStatusStats() {
        java.util.Map<String, Integer> stats = new java.util.HashMap<>();
        
        // 기본 상태들을 0으로 초기화
        stats.put("pending", 0);
        stats.put("pass", 0);
        stats.put("fail", 0);
        stats.put("hold", 0);
        stats.put("total", 0);
        
        String sql = "SELECT result_status, COUNT(*) as count FROM interview_results GROUP BY result_status";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            int total = 0;
            while (rs.next()) {
                String status = rs.getString("result_status");
                int count = rs.getInt("count");
                stats.put(status, count);
                total += count;
            }
            stats.put("total", total);
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return stats;
    }
    
    /**
     * 평균 점수 조회
     */
    public BigDecimal getAverageOverallScore() {
        String sql = "SELECT AVG(overall_score) as avg_score FROM interview_results WHERE overall_score IS NOT NULL";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            if (rs.next()) {
                BigDecimal avgScore = rs.getBigDecimal("avg_score");
                // null이면 데이터가 없는 것이므로 null 반환
                if (avgScore == null) {
                    return null;
                }
                // 소수점 2자리로 반올림하여 반환 (1.0 ~ 5.0 범위 보장)
                return avgScore.setScale(2, RoundingMode.HALF_UP);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null; // 데이터가 없거나 오류 시 null 반환
    }
    
    /**
     * 검색 기능 (지원자명, 면접관명으로 검색)
     */
    public List<InterviewResult> searchResults(String keyword) {
        List<InterviewResult> results = new ArrayList<>();
        String sql = "SELECT ir.*, c.name as candidate_name " +
                    "FROM interview_results ir " +
                    "JOIN candidates c ON ir.candidate_id = c.id " +
                    "WHERE LOWER(c.name) LIKE LOWER(?) OR LOWER(ir.interviewer_name) LIKE LOWER(?) " +
                    "ORDER BY ir.interview_date DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            pstmt.setString(1, searchPattern);
            pstmt.setString(2, searchPattern);
            
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                results.add(mapResultSetToInterviewResult(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return results;
    }
    
    /**
     * scheduleId로 결과 상태(합격/불합격/보류 등)를 조회
     */
    public String getResultStatusByScheduleId(int scheduleId) {
        String sql = "SELECT result_status FROM interview_results WHERE schedule_id = ? ORDER BY interview_date DESC LIMIT 1";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("result_status");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * 중복 결과 존재 여부를 확인
     */
    public boolean isResultExists(int candidateId, Date interviewDate, String interviewerName) {
        String sql = "SELECT 1 FROM interview_results WHERE candidate_id = ? AND interview_date = ? AND interviewer_name = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, candidateId);
            ps.setDate(2, interviewDate);
            ps.setString(3, interviewerName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * scheduleId로 단일 인터뷰 결과 조회 (가장 최근 1건)
     */
    public InterviewResult getResultByScheduleId(int scheduleId) {
        String sql = "SELECT ir.*, c.name as candidate_name " +
                    "FROM interview_results ir " +
                    "JOIN candidates c ON ir.candidate_id = c.id " +
                    "WHERE ir.schedule_id = ? " +
                    "ORDER BY ir.interview_date DESC LIMIT 1";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, scheduleId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return mapResultSetToInterviewResult(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Helper 메소드들
    
    /**
     * Integer 값을 PreparedStatement에 설정 (null 처리 포함)
     */
    private void setIntegerOrNull(PreparedStatement pstmt, int index, Integer value) throws SQLException {
        if (value != null) {
            pstmt.setInt(index, value);
        } else {
            pstmt.setNull(index, Types.INTEGER);
        }
    }
    
    /**
     * ResultSet을 InterviewResult 객체로 변환
     */
    private InterviewResult mapResultSetToInterviewResult(ResultSet rs) throws SQLException {
        InterviewResult result = new InterviewResult();
        
        result.setId(rs.getInt("id"));
        result.setCandidateId(rs.getInt("candidate_id"));
        result.setCandidateName(rs.getString("candidate_name"));
        
        int scheduleId = rs.getInt("schedule_id");
        if (!rs.wasNull()) {
            result.setScheduleId(scheduleId);
        }
        
        result.setInterviewerName(rs.getString("interviewer_name"));
        result.setInterviewDate(rs.getDate("interview_date"));
        result.setInterviewType(rs.getString("interview_type"));
        
        // 점수들 설정 (null 체크)
        Integer techScore = rs.getInt("technical_score");
        if (!rs.wasNull()) result.setTechnicalScore(techScore);
        
        Integer commScore = rs.getInt("communication_score");
        if (!rs.wasNull()) result.setCommunicationScore(commScore);
        
        Integer problemScore = rs.getInt("problem_solving_score");
        if (!rs.wasNull()) result.setProblemSolvingScore(problemScore);
        
        Integer attitudeScore = rs.getInt("attitude_score");
        if (!rs.wasNull()) result.setAttitudeScore(attitudeScore);
        
        BigDecimal overallScore = rs.getBigDecimal("overall_score");
        if (overallScore != null) result.setOverallScore(overallScore);
        
        result.setStrengths(rs.getString("strengths"));
        result.setWeaknesses(rs.getString("weaknesses"));
        result.setDetailedFeedback(rs.getString("detailed_feedback"));
        result.setImprovementSuggestions(rs.getString("improvement_suggestions"));
        result.setResultStatus(rs.getString("result_status"));
        result.setHireRecommendation(rs.getString("hire_recommendation"));
        result.setNextStep(rs.getString("next_step"));
        result.setCreatedAt(rs.getTimestamp("created_at"));
        result.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        return result;
    }
}
