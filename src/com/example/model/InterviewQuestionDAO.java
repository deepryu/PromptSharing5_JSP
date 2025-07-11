package com.example.model;

import com.example.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 인터뷰 질문 데이터 액세스 객체
 * 데이터베이스와의 모든 인터뷰 질문 관련 작업을 처리
 */
public class InterviewQuestionDAO {
    
    /**
     * 모든 인터뷰 질문 조회
     */
    public List<InterviewQuestion> getAllQuestions() {
        List<InterviewQuestion> questions = new ArrayList<>();
        String sql = "SELECT * FROM interview_questions ORDER BY created_at DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                questions.add(mapResultSetToQuestion(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return questions;
    }
    
    /**
     * 활성화된 인터뷰 질문만 조회
     */
    public List<InterviewQuestion> getActiveQuestions() {
        List<InterviewQuestion> questions = new ArrayList<>();
        String sql = "SELECT * FROM interview_questions WHERE is_active = true ORDER BY category, difficulty_level";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                questions.add(mapResultSetToQuestion(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return questions;
    }
    
    /**
     * 카테고리별 질문 조회
     */
    public List<InterviewQuestion> getQuestionsByCategory(String category) {
        List<InterviewQuestion> questions = new ArrayList<>();
        String sql = "SELECT * FROM interview_questions WHERE category = ? AND is_active = true ORDER BY difficulty_level";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, category);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    questions.add(mapResultSetToQuestion(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return questions;
    }
    
    /**
     * 난이도별 질문 조회
     */
    public List<InterviewQuestion> getQuestionsByDifficulty(int difficultyLevel) {
        List<InterviewQuestion> questions = new ArrayList<>();
        String sql = "SELECT * FROM interview_questions WHERE difficulty_level = ? AND is_active = true ORDER BY category";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, difficultyLevel);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    questions.add(mapResultSetToQuestion(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return questions;
    }
    
    /**
     * 카테고리와 난이도를 동시에 적용하여 질문 조회
     */
    public List<InterviewQuestion> getQuestionsByCategoryAndDifficulty(String category, Integer difficultyLevel) {
        List<InterviewQuestion> questions = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM interview_questions WHERE is_active = true");
        List<Object> params = new ArrayList<>();
        
        // 카테고리 조건 추가
        if (category != null && !category.trim().isEmpty()) {
            sql.append(" AND category = ?");
            params.add(category);
        }
        
        // 난이도 조건 추가
        if (difficultyLevel != null) {
            sql.append(" AND difficulty_level = ?");
            params.add(difficultyLevel);
        }
        
        sql.append(" ORDER BY category, difficulty_level");
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            
            // 파라미터 설정
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    pstmt.setString(i + 1, (String) param);
                } else if (param instanceof Integer) {
                    pstmt.setInt(i + 1, (Integer) param);
                }
            }
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    questions.add(mapResultSetToQuestion(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return questions;
    }
    
    /**
     * ID로 특정 질문 조회
     */
    public InterviewQuestion getQuestionById(int id) {
        String sql = "SELECT * FROM interview_questions WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToQuestion(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * 새 질문 추가
     */
    public boolean addQuestion(InterviewQuestion question) {
        System.out.println("[DEBUG] === InterviewQuestionDAO.addQuestion 시작 ===");
        System.out.println("[DEBUG] 질문 등록 요청 - " + question.getQuestionText().substring(0, Math.min(50, question.getQuestionText().length())) + "...");
        
        String sql = "INSERT INTO interview_questions (question_text, category, difficulty_level, expected_answer, is_active) VALUES (?, ?, ?, ?, ?)";
        System.out.println("[DEBUG] 실행할 SQL: " + sql);
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            System.out.println("[DEBUG] 데이터베이스 연결 시도...");
            conn = DatabaseUtil.getConnection();
            System.out.println("[DEBUG] ✅ 데이터베이스 연결 성공");
            
            System.out.println("[DEBUG] PreparedStatement 생성...");
            pstmt = conn.prepareStatement(sql);
            
            // 파라미터 설정
            System.out.println("[DEBUG] SQL 파라미터 설정 시작...");
            pstmt.setString(1, question.getQuestionText());
            System.out.println("[DEBUG] 파라미터 1 (question_text): " + question.getQuestionText().substring(0, Math.min(100, question.getQuestionText().length())) + "...");
            
            pstmt.setString(2, question.getCategory());
            System.out.println("[DEBUG] 파라미터 2 (category): " + question.getCategory());
            
            pstmt.setInt(3, question.getDifficultyLevel());
            System.out.println("[DEBUG] 파라미터 3 (difficulty_level): " + question.getDifficultyLevel());
            
            pstmt.setString(4, question.getExpectedAnswer());
            System.out.println("[DEBUG] 파라미터 4 (expected_answer): " + (question.getExpectedAnswer() != null ? question.getExpectedAnswer().substring(0, Math.min(50, question.getExpectedAnswer().length())) + "..." : "null"));
            
            pstmt.setBoolean(5, question.isActive());
            System.out.println("[DEBUG] 파라미터 5 (is_active): " + question.isActive());
            System.out.println("[DEBUG] ✅ SQL 파라미터 설정 완료");
            
            System.out.println("[DEBUG] SQL 실행 시작...");
            int rowsAffected = pstmt.executeUpdate();
            System.out.println("[DEBUG] SQL 실행 완료 - 영향받은 행 수: " + rowsAffected);
            
            boolean success = rowsAffected > 0;
            System.out.println("[DEBUG] 최종 결과: " + (success ? "성공" : "실패"));
            
            if (success) {
                System.out.println("[DEBUG] ✅ 질문이 성공적으로 데이터베이스에 저장되었습니다");
            } else {
                System.out.println("[DEBUG] ❌ 질문 저장 실패 - 영향받은 행이 없음");
            }
            
            return success;
            
        } catch (SQLException e) {
            System.err.println("[ERROR] ❌ SQL 오류 발생:");
            System.err.println("[ERROR] SQL State: " + e.getSQLState());
            System.err.println("[ERROR] Error Code: " + e.getErrorCode());
            System.err.println("[ERROR] Message: " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            System.err.println("[ERROR] ❌ 예상치 못한 오류 발생: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            // 리소스 정리
            System.out.println("[DEBUG] 리소스 정리 시작...");
            try {
                if (pstmt != null) {
                    pstmt.close();
                    System.out.println("[DEBUG] PreparedStatement 닫기 완료");
                }
                if (conn != null) {
                    conn.close();
                    System.out.println("[DEBUG] Connection 닫기 완료");
                }
            } catch (SQLException e) {
                System.err.println("[ERROR] 리소스 정리 중 오류: " + e.getMessage());
            }
            System.out.println("[DEBUG] === InterviewQuestionDAO.addQuestion 완료 ===\n");
        }
    }
    
    /**
     * 질문 정보 수정
     */
    public boolean updateQuestion(InterviewQuestion question) {
        String sql = "UPDATE interview_questions SET question_text = ?, category = ?, difficulty_level = ?, expected_answer = ?, is_active = ? WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, question.getQuestionText());
            pstmt.setString(2, question.getCategory());
            pstmt.setInt(3, question.getDifficultyLevel());
            pstmt.setString(4, question.getExpectedAnswer());
            pstmt.setBoolean(5, question.isActive());
            pstmt.setInt(6, question.getId());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 질문 삭제 (실제로는 비활성화)
     */
    public boolean deleteQuestion(int id) {
        String sql = "UPDATE interview_questions SET is_active = false WHERE id = ?";
        
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
     * 질문 완전 삭제 (물리적 삭제)
     */
    public boolean permanentDeleteQuestion(int id) {
        String sql = "DELETE FROM interview_questions WHERE id = ?";
        
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
     * 질문 활성화/비활성화 토글
     */
    public boolean toggleQuestionStatus(int id) {
        String sql = "UPDATE interview_questions SET is_active = NOT is_active WHERE id = ?";
        
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
     * 키워드로 질문 검색
     */
    public List<InterviewQuestion> searchQuestions(String keyword) {
        List<InterviewQuestion> questions = new ArrayList<>();
        String sql = "SELECT * FROM interview_questions WHERE " +
                    "(question_text ILIKE ? OR expected_answer ILIKE ?) AND is_active = true " +
                    "ORDER BY category, difficulty_level";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            pstmt.setString(1, searchPattern);
            pstmt.setString(2, searchPattern);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    questions.add(mapResultSetToQuestion(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return questions;
    }
    
    /**
     * 카테고리별 질문 수 통계
     */
    public int getQuestionCountByCategory(String category) {
        String sql = "SELECT COUNT(*) FROM interview_questions WHERE category = ? AND is_active = true";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, category);
            try (ResultSet rs = pstmt.executeQuery()) {
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
     * 전체 활성 질문 수
     */
    public int getTotalActiveQuestionCount() {
        String sql = "SELECT COUNT(*) FROM interview_questions WHERE is_active = true";
        
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
     * 모든 카테고리 목록 조회
     */
    public List<String> getAllCategories() {
        List<String> categories = new ArrayList<>();
        String sql = "SELECT DISTINCT category FROM interview_questions WHERE is_active = true ORDER BY category";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                categories.add(rs.getString("category"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return categories;
    }
    
    /**
     * 랜덤 질문 조회 (난이도와 카테고리 제한 가능)
     */
    public List<InterviewQuestion> getRandomQuestions(int limit, String category, Integer difficultyLevel) {
        List<InterviewQuestion> questions = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM interview_questions WHERE is_active = true");
        
        if (category != null && !category.trim().isEmpty()) {
            sql.append(" AND category = ?");
        }
        if (difficultyLevel != null) {
            sql.append(" AND difficulty_level = ?");
        }
        sql.append(" ORDER BY RANDOM() LIMIT ?");
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (category != null && !category.trim().isEmpty()) {
                pstmt.setString(paramIndex++, category);
            }
            if (difficultyLevel != null) {
                pstmt.setInt(paramIndex++, difficultyLevel);
            }
            pstmt.setInt(paramIndex, limit);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    questions.add(mapResultSetToQuestion(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return questions;
    }
    
    /**
     * 카테고리별 질문 통계 조회
     */
    public java.util.Map<String, Integer> getCategoryStatistics() {
        java.util.Map<String, Integer> statistics = new java.util.LinkedHashMap<>();
        String sql = "SELECT category, COUNT(*) as count FROM interview_questions WHERE is_active = true GROUP BY category ORDER BY count DESC, category";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                statistics.put(rs.getString("category"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return statistics;
    }
    
    /**
     * 난이도별 질문 통계 조회
     */
    public java.util.Map<Integer, Integer> getDifficultyStatistics() {
        java.util.Map<Integer, Integer> statistics = new java.util.LinkedHashMap<>();
        String sql = "SELECT difficulty_level, COUNT(*) as count FROM interview_questions WHERE is_active = true GROUP BY difficulty_level ORDER BY difficulty_level";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                statistics.put(rs.getInt("difficulty_level"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return statistics;
    }
    
    /**
     * ResultSet을 InterviewQuestion 객체로 매핑하는 헬퍼 메서드
     */
    private InterviewQuestion mapResultSetToQuestion(ResultSet rs) throws SQLException {
        InterviewQuestion question = new InterviewQuestion();
        question.setId(rs.getInt("id"));
        question.setQuestionText(rs.getString("question_text"));
        question.setCategory(rs.getString("category"));
        question.setDifficultyLevel(rs.getInt("difficulty_level"));
        question.setExpectedAnswer(rs.getString("expected_answer"));
        question.setActive(rs.getBoolean("is_active"));
        question.setCreatedAt(rs.getTimestamp("created_at"));
        question.setUpdatedAt(rs.getTimestamp("updated_at"));
        return question;
    }
}