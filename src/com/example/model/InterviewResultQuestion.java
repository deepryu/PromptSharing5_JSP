package com.example.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

/**
 * 인터뷰 결과와 선택된 질문들의 연결을 관리하는 모델 클래스
 */
public class InterviewResultQuestion {
    private int id;
    private int resultId;
    private int questionId;
    private boolean isAsked;
    private Timestamp askedAt;
    private String answerSummary;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // 조인을 위한 추가 필드들
    private String questionText;
    private String category;
    private int difficultyLevel;
    
    // 기본 생성자
    public InterviewResultQuestion() {}
    
    // 매개변수 생성자
    public InterviewResultQuestion(int resultId, int questionId) {
        this.resultId = resultId;
        this.questionId = questionId;
        this.isAsked = false;
    }
    
    // Getter and Setter methods
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getResultId() {
        return resultId;
    }
    
    public void setResultId(int resultId) {
        this.resultId = resultId;
    }
    
    public int getQuestionId() {
        return questionId;
    }
    
    public void setQuestionId(int questionId) {
        this.questionId = questionId;
    }
    
    public boolean isAsked() {
        return isAsked;
    }
    
    public void setAsked(boolean asked) {
        isAsked = asked;
    }
    
    public Timestamp getAskedAt() {
        return askedAt;
    }
    
    public void setAskedAt(Timestamp askedAt) {
        this.askedAt = askedAt;
    }
    
    public String getAnswerSummary() {
        return answerSummary;
    }
    
    public void setAnswerSummary(String answerSummary) {
        this.answerSummary = answerSummary;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    // 조인 필드들
    public String getQuestionText() {
        return questionText;
    }
    
    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }
    
    public String getCategory() {
        return category;
    }
    
    public void setCategory(String category) {
        this.category = category;
    }
    
    public int getDifficultyLevel() {
        return difficultyLevel;
    }
    
    public void setDifficultyLevel(int difficultyLevel) {
        this.difficultyLevel = difficultyLevel;
    }
    
    // 편의 메서드들
    
    /**
     * 질문 실시 시간을 포맷된 문자열로 반환
     */
    public String getFormattedAskedAt() {
        if (askedAt == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        return sdf.format(askedAt);
    }
    
    /**
     * 질문 상태를 텍스트로 반환
     */
    public String getStatusText() {
        return isAsked ? "완료" : "미완료";
    }
    
    /**
     * 질문 상태를 CSS 클래스로 반환
     */
    public String getStatusClass() {
        return isAsked ? "status-completed" : "status-pending";
    }
    
    @Override
    public String toString() {
        return "InterviewResultQuestion{" +
                "id=" + id +
                ", resultId=" + resultId +
                ", questionId=" + questionId +
                ", isAsked=" + isAsked +
                ", askedAt=" + askedAt +
                '}';
    }
    
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        InterviewResultQuestion that = (InterviewResultQuestion) obj;
        return resultId == that.resultId && questionId == that.questionId;
    }
    
    @Override
    public int hashCode() {
        return java.util.Objects.hash(resultId, questionId);
    }
} 