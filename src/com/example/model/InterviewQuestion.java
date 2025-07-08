package com.example.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

/**
 * 인터뷰 질문 모델 클래스
 * 면접에서 사용할 질문과 관련 정보를 관리
 */
public class InterviewQuestion {
    private int id;
    private String questionText;
    private String category;
    private int difficultyLevel;
    private String expectedAnswer;
    private boolean isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // 기본 생성자
    public InterviewQuestion() {}
    
    // 매개변수 생성자
    public InterviewQuestion(String questionText, String category, int difficultyLevel, String expectedAnswer) {
        this.questionText = questionText;
        this.category = category;
        this.difficultyLevel = difficultyLevel;
        this.expectedAnswer = expectedAnswer;
        this.isActive = true;
    }
    
    // Getter and Setter methods
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
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
    
    public String getExpectedAnswer() {
        return expectedAnswer;
    }
    
    public void setExpectedAnswer(String expectedAnswer) {
        this.expectedAnswer = expectedAnswer;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
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
    
    // 편의 메서드들
    
    /**
     * 난이도를 별 표시로 반환 (★☆☆☆☆)
     */
    public String getDifficultyStars() {
        StringBuilder stars = new StringBuilder();
        for (int i = 1; i <= 5; i++) {
            if (i <= difficultyLevel) {
                stars.append("★");
            } else {
                stars.append("☆");
            }
        }
        return stars.toString();
    }
    
    /**
     * 난이도를 텍스트로 반환
     */
    public String getDifficultyText() {
        switch (difficultyLevel) {
            case 1: return "매우 쉬움";
            case 2: return "쉬움";
            case 3: return "보통";
            case 4: return "어려움";
            case 5: return "매우 어려움";
            default: return "알 수 없음";
        }
    }
    
    /**
     * 카테고리를 색상 클래스로 반환 (CSS 스타일링용)
     */
    public String getCategoryColorClass() {
        switch (category) {
            case "기술": return "category-tech";
            case "기술-Java-초급": return "category-java-beginner";
            case "기술-Java-중급": return "category-java-intermediate";
            case "기술-Java-고급": return "category-java-advanced";
            case "기술-Python-초급": return "category-python-beginner";
            case "기술-Python-중급": return "category-python-intermediate";
            case "기술-Python-고급": return "category-python-advanced";
            case "인성": return "category-personality";
            case "경험": return "category-experience";
            case "상황": return "category-situation";
            default: return "category-default";
        }
    }
    
    /**
     * 카테고리를 아이콘과 함께 텍스트로 반환
     */
    public String getCategoryText() {
        switch (category) {
            case "기술": return "💻 기술";
            case "기술-Java-초급": return "☕ Java 초급";
            case "기술-Java-중급": return "☕ Java 중급";
            case "기술-Java-고급": return "☕ Java 고급";
            case "기술-Python-초급": return "🐍 Python 초급";
            case "기술-Python-중급": return "🐍 Python 중급";
            case "기술-Python-고급": return "🐍 Python 고급";
            case "인성": return "👤 인성";
            case "경험": return "📚 경험";
            case "상황": return "🎯 상황";
            default: return "📝 " + category;
        }
    }
    
    /**
     * 활성 상태를 한글로 반환
     */
    public String getActiveStatusText() {
        return isActive ? "활성" : "비활성";
    }
    
    /**
     * 활성 상태를 CSS 클래스로 반환
     */
    public String getActiveStatusClass() {
        return isActive ? "status-active" : "status-inactive";
    }
    
    /**
     * 생성일을 포맷된 문자열로 반환
     */
    public String getFormattedCreatedAt() {
        if (createdAt == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        return sdf.format(createdAt);
    }
    
    /**
     * 수정일을 포맷된 문자열로 반환
     */
    public String getFormattedUpdatedAt() {
        if (updatedAt == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        return sdf.format(updatedAt);
    }
    
    /**
     * 질문 텍스트를 요약 형태로 반환 (리스트 표시용)
     */
    public String getQuestionSummary() {
        if (questionText == null) return "";
        if (questionText.length() <= 50) {
            return questionText;
        }
        return questionText.substring(0, 50) + "...";
    }
    
    /**
     * 예상 답변을 요약 형태로 반환
     */
    public String getExpectedAnswerSummary() {
        if (expectedAnswer == null || expectedAnswer.trim().isEmpty()) return "답변 없음";
        if (expectedAnswer.length() <= 30) {
            return expectedAnswer;
        }
        return expectedAnswer.substring(0, 30) + "...";
    }
    
    @Override
    public String toString() {
        return "InterviewQuestion{" +
                "id=" + id +
                ", questionText='" + questionText + '\'' +
                ", category='" + category + '\'' +
                ", difficultyLevel=" + difficultyLevel +
                ", isActive=" + isActive +
                '}';
    }
    
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        InterviewQuestion that = (InterviewQuestion) obj;
        return id == that.id;
    }
    
    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }
} 