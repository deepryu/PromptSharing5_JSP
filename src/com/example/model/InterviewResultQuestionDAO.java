package com.example.model;

import com.example.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 인터뷰 결과와 질문 연결 데이터를 관리하는 DAO 클래스
 */
public class InterviewResultQuestionDAO {
    
    /**
     * 인터뷰 결과에 선택된 질문들을 저장
     */
    public boolean saveSelectedQuestions(int resultId, List<Integer> questionIds) {
        String deleteSql = "DELETE FROM interview_result_questions WHERE result_id = ?";
        String insertSql = "INSERT INTO interview_result_questions (result_id, question_id) VALUES (?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);
            
            try {
                // 기존 질문들 삭제
                try (PreparedStatement deleteStmt = conn.prepareStatement(deleteSql)) {
                    deleteStmt.setInt(1, resultId);
                    deleteStmt.executeUpdate();
                }
                
                // 새 질문들 삽입
                if (questionIds != null && !questionIds.isEmpty()) {
                    try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                        for (int questionId : questionIds) {
                            insertStmt.setInt(1, resultId);
                            insertStmt.setInt(2, questionId);
                            insertStmt.addBatch();
                        }
                        insertStmt.executeBatch();
                    }
                }
                
                conn.commit();
                return true;
                
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 인터뷰 결과의 선택된 질문들을 조회
     */
    public List<InterviewResultQuestion> getQuestionsByResultId(int resultId) {
        String sql = "SELECT irq.*, iq.question_text, iq.category, iq.difficulty_level " +
                    "FROM interview_result_questions irq " +
                    "JOIN interview_questions iq ON irq.question_id = iq.id " +
                    "WHERE irq.result_id = ? " +
                    "ORDER BY iq.category, iq.difficulty_level, iq.id";
        
        List<InterviewResultQuestion> questions = new ArrayList<>();
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, resultId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    InterviewResultQuestion question = new InterviewResultQuestion();
                    question.setId(rs.getInt("id"));
                    question.setResultId(rs.getInt("result_id"));
                    question.setQuestionId(rs.getInt("question_id"));
                    question.setAsked(rs.getBoolean("is_asked"));
                    question.setAskedAt(rs.getTimestamp("asked_at"));
                    question.setAnswerSummary(rs.getString("answer_summary"));
                    question.setCreatedAt(rs.getTimestamp("created_at"));
                    question.setUpdatedAt(rs.getTimestamp("updated_at"));
                    
                    // 조인된 질문 정보
                    question.setQuestionText(rs.getString("question_text"));
                    question.setCategory(rs.getString("category"));
                    question.setDifficultyLevel(rs.getInt("difficulty_level"));
                    
                    questions.add(question);
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return questions;
    }
    
    /**
     * 인터뷰 결과의 선택된 질문 ID 목록을 조회
     */
    public List<Integer> getSelectedQuestionIds(int resultId) {
        String sql = "SELECT question_id FROM interview_result_questions WHERE result_id = ?";
        List<Integer> questionIds = new ArrayList<>();
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, resultId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    questionIds.add(rs.getInt("question_id"));
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return questionIds;
    }
    
    /**
     * 카테고리별 선택된 질문이 있는 카테고리 목록을 조회
     */
    public List<String> getCategoriesWithSelectedQuestions(int resultId) {
        String sql = "SELECT DISTINCT iq.category " +
                    "FROM interview_result_questions irq " +
                    "JOIN interview_questions iq ON irq.question_id = iq.id " +
                    "WHERE irq.result_id = ?";
        
        List<String> categories = new ArrayList<>();
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, resultId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    categories.add(rs.getString("category"));
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return categories;
    }
    
    /**
     * 질문을 실시 완료로 업데이트
     */
    public boolean markQuestionAsAsked(int resultId, int questionId, String answerSummary) {
        String sql = "UPDATE interview_result_questions " +
                    "SET is_asked = true, asked_at = CURRENT_TIMESTAMP, answer_summary = ?, " +
                    "updated_at = CURRENT_TIMESTAMP " +
                    "WHERE result_id = ? AND question_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, answerSummary);
            stmt.setInt(2, resultId);
            stmt.setInt(3, questionId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 질문을 미완료로 업데이트
     */
    public boolean markQuestionAsNotAsked(int resultId, int questionId) {
        String sql = "UPDATE interview_result_questions " +
                    "SET is_asked = false, asked_at = null, answer_summary = null, " +
                    "updated_at = CURRENT_TIMESTAMP " +
                    "WHERE result_id = ? AND question_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, resultId);
            stmt.setInt(2, questionId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 특정 인터뷰 결과의 모든 연결된 질문 삭제
     */
    public boolean deleteQuestionsByResultId(int resultId) {
        String sql = "DELETE FROM interview_result_questions WHERE result_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, resultId);
            return stmt.executeUpdate() >= 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
} 