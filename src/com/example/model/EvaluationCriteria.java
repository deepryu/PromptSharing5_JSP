package com.example.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * 평가 기준 모델 클래스
 * 인터뷰 평가에 사용할 기준과 관련 정보를 관리
 */
public class EvaluationCriteria {
    private int id;
    private String criteriaName;
    private String description;
    private int maxScore;
    private BigDecimal weight;
    private boolean isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // 기본 생성자
    public EvaluationCriteria() {}
    
    // 매개변수 생성자
    public EvaluationCriteria(String criteriaName, String description, int maxScore, BigDecimal weight) {
        this.criteriaName = criteriaName;
        this.description = description;
        this.maxScore = maxScore;
        this.weight = weight;
        this.isActive = true;
    }
    
    // Getter and Setter methods
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getCriteriaName() {
        return criteriaName;
    }
    
    public void setCriteriaName(String criteriaName) {
        this.criteriaName = criteriaName;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public int getMaxScore() {
        return maxScore;
    }
    
    public void setMaxScore(int maxScore) {
        this.maxScore = maxScore;
    }
    
    public BigDecimal getWeight() {
        return weight;
    }
    
    public void setWeight(BigDecimal weight) {
        this.weight = weight;
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
     * 가중치를 백분율로 반환 (ex: 1.5 -> 150%)
     */
    public String getWeightPercentage() {
        if (weight == null) return "100%";
        return weight.multiply(new BigDecimal("100")).setScale(0, RoundingMode.HALF_UP) + "%";
    }
    
    /**
     * 가중치 적용된 최대 점수 계산
     */
    public BigDecimal getWeightedMaxScore() {
        if (weight == null) return new BigDecimal(maxScore);
        return new BigDecimal(maxScore).multiply(weight).setScale(1, RoundingMode.HALF_UP);
    }
    
    /**
     * 가중치 중요도를 텍스트로 반환
     */
    public String getWeightImportanceText() {
        if (weight == null) return "보통";
        
        double weightValue = weight.doubleValue();
        if (weightValue >= 1.4) return "매우 중요";
        else if (weightValue >= 1.2) return "중요";
        else if (weightValue >= 1.0) return "보통";
        else if (weightValue >= 0.8) return "낮음";
        else return "매우 낮음";
    }
    
    /**
     * 가중치를 색상 클래스로 반환 (CSS 스타일링용)
     */
    public String getWeightColorClass() {
        if (weight == null) return "weight-normal";
        
        double weightValue = weight.doubleValue();
        if (weightValue >= 1.4) return "weight-very-high";
        else if (weightValue >= 1.2) return "weight-high";
        else if (weightValue >= 1.0) return "weight-normal";
        else if (weightValue >= 0.8) return "weight-low";
        else return "weight-very-low";
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
     * 설명을 요약 형태로 반환 (리스트 표시용)
     */
    public String getDescriptionSummary() {
        if (description == null || description.trim().isEmpty()) return "설명 없음";
        if (description.length() <= 40) {
            return description;
        }
        return description.substring(0, 40) + "...";
    }
    
    /**
     * 점수 범위를 문자열로 반환 (ex: 0~10점)
     */
    public String getScoreRange() {
        return "0~" + maxScore + "점";
    }
    
    /**
     * 가중치가 적용된 점수 범위 반환
     */
    public String getWeightedScoreRange() {
        BigDecimal weightedMax = getWeightedMaxScore();
        return "0~" + weightedMax + "점";
    }
    
    /**
     * 평가 기준의 중요도 순서를 위한 정렬 키 반환
     */
    public double getSortKey() {
        return weight != null ? weight.doubleValue() : 1.0;
    }
    
    @Override
    public String toString() {
        return "EvaluationCriteria{" +
                "id=" + id +
                ", criteriaName='" + criteriaName + '\'' +
                ", maxScore=" + maxScore +
                ", weight=" + weight +
                ", isActive=" + isActive +
                '}';
    }
    
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        EvaluationCriteria that = (EvaluationCriteria) obj;
        return id == that.id;
    }
    
    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }
} 