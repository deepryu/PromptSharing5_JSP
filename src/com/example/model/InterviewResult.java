package com.example.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

/**
 * 인터뷰 결과 모델 클래스
 * 면접 결과와 평가 정보를 관리
 */
public class InterviewResult {
    private int id;
    private int candidateId;
    private String candidateName; // 조인을 위한 필드
    private Integer scheduleId;
    private String interviewerName;
    private Date interviewDate;
    private String interviewType;
    
    // 평가 점수 (1-5점 척도)
    private Integer technicalScore;
    private Integer communicationScore;
    private Integer problemSolvingScore;
    private Integer attitudeScore;
    private BigDecimal overallScore;
    
    // 평가 내용
    private String strengths;
    private String weaknesses;
    private String detailedFeedback;
    private String improvementSuggestions;
    
    // 최종 결과
    private String resultStatus; // pending, pass, fail, hold
    private String hireRecommendation; // yes, no
    private String nextStep;
    
    // 메타데이터
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // 기본 생성자
    public InterviewResult() {}
    
    // 매개변수 생성자
    public InterviewResult(int candidateId, String interviewerName, Date interviewDate, String interviewType) {
        this.candidateId = candidateId;
        this.interviewerName = interviewerName;
        this.interviewDate = interviewDate;
        this.interviewType = interviewType;
        this.resultStatus = "pending";
        this.hireRecommendation = "no";
    }
    
    // Getter and Setter methods
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getCandidateId() {
        return candidateId;
    }
    
    public void setCandidateId(int candidateId) {
        this.candidateId = candidateId;
    }
    
    public String getCandidateName() {
        return candidateName;
    }
    
    public void setCandidateName(String candidateName) {
        this.candidateName = candidateName;
    }
    
    public Integer getScheduleId() {
        return scheduleId;
    }
    
    public void setScheduleId(Integer scheduleId) {
        this.scheduleId = scheduleId;
    }
    
    public String getInterviewerName() {
        return interviewerName;
    }
    
    public void setInterviewerName(String interviewerName) {
        this.interviewerName = interviewerName;
    }
    
    public Date getInterviewDate() {
        return interviewDate;
    }
    
    public void setInterviewDate(Date interviewDate) {
        this.interviewDate = interviewDate;
    }
    
    public String getInterviewType() {
        return interviewType;
    }
    
    public void setInterviewType(String interviewType) {
        this.interviewType = interviewType;
    }
    
    public Integer getTechnicalScore() {
        return technicalScore;
    }
    
    public void setTechnicalScore(Integer technicalScore) {
        this.technicalScore = technicalScore;
    }
    
    public Integer getCommunicationScore() {
        return communicationScore;
    }
    
    public void setCommunicationScore(Integer communicationScore) {
        this.communicationScore = communicationScore;
    }
    
    public Integer getProblemSolvingScore() {
        return problemSolvingScore;
    }
    
    public void setProblemSolvingScore(Integer problemSolvingScore) {
        this.problemSolvingScore = problemSolvingScore;
    }
    
    public Integer getAttitudeScore() {
        return attitudeScore;
    }
    
    public void setAttitudeScore(Integer attitudeScore) {
        this.attitudeScore = attitudeScore;
    }
    
    public BigDecimal getOverallScore() {
        return overallScore;
    }
    
    public void setOverallScore(BigDecimal overallScore) {
        this.overallScore = overallScore;
    }
    
    public String getStrengths() {
        return strengths;
    }
    
    public void setStrengths(String strengths) {
        this.strengths = strengths;
    }
    
    public String getWeaknesses() {
        return weaknesses;
    }
    
    public void setWeaknesses(String weaknesses) {
        this.weaknesses = weaknesses;
    }
    
    public String getDetailedFeedback() {
        return detailedFeedback;
    }
    
    public void setDetailedFeedback(String detailedFeedback) {
        this.detailedFeedback = detailedFeedback;
    }
    
    public String getImprovementSuggestions() {
        return improvementSuggestions;
    }
    
    public void setImprovementSuggestions(String improvementSuggestions) {
        this.improvementSuggestions = improvementSuggestions;
    }
    
    public String getResultStatus() {
        return resultStatus;
    }
    
    public void setResultStatus(String resultStatus) {
        this.resultStatus = resultStatus;
    }
    
    public String getHireRecommendation() {
        return hireRecommendation;
    }
    
    public void setHireRecommendation(String hireRecommendation) {
        this.hireRecommendation = hireRecommendation;
    }
    
    public String getNextStep() {
        return nextStep;
    }
    
    public void setNextStep(String nextStep) {
        this.nextStep = nextStep;
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
    
    // 편의 메소드들
    
    /**
     * 면접 날짜를 포맷된 문자열로 반환
     */
    public String getInterviewDateFormatted() {
        if (interviewDate == null) return "";
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        return dateFormat.format(interviewDate);
    }
    
    /**
     * HTML5 datetime-local 입력을 위한 날짜 포맷 반환
     */
    public String getInterviewDateForInput() {
        if (interviewDate == null) return "";
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
        return dateFormat.format(interviewDate);
    }
    
    /**
     * 결과 상태의 표시명 반환
     */
    public String getResultStatusDisplayName() {
        switch (resultStatus) {
            case "pending": return "검토중";
            case "pass": return "합격";
            case "fail": return "불합격";
            case "hold": return "보류";
            default: return resultStatus;
        }
    }
    
    /**
     * 결과 상태의 CSS 클래스 반환
     */
    public String getResultStatusClass() {
        switch (resultStatus) {
            case "pass": return "status-pass";
            case "fail": return "status-fail";
            case "hold": return "status-hold";
            case "pending": return "status-pending";
            default: return "status-default";
        }
    }
    
    /**
     * 추천 여부의 표시명 반환
     */
    public String getHireRecommendationDisplayName() {
        if ("yes".equals(hireRecommendation)) return "추천";
        if ("no".equals(hireRecommendation)) return "비추천";
        return hireRecommendation != null ? hireRecommendation : "미정";
    }
    
    /**
     * 추천 여부의 CSS 클래스 반환
     */
    public String getHireRecommendationClass() {
        if ("yes".equals(hireRecommendation)) return "recommendation-yes";
        if ("no".equals(hireRecommendation)) return "recommendation-no";
        return "recommendation-default";
    }
    
    /**
     * 전체 점수를 문자열로 반환 (null 체크 포함)
     */
    public String getOverallScoreFormatted() {
        if (overallScore == null) return "미평가";
        return String.format("%.2f", overallScore);
    }
    
    /**
     * 점수별 별점 표시 반환
     */
    public String getScoreStars(Integer score) {
        if (score == null) return "☆☆☆☆☆";
        StringBuilder stars = new StringBuilder();
        for (int i = 1; i <= 5; i++) {
            stars.append(i <= score ? "★" : "☆");
        }
        return stars.toString();
    }
    
    /**
     * 전체 점수의 별점 표시 반환
     */
    public String getOverallScoreStars() {
        if (overallScore == null) return "☆☆☆☆☆";
        int score = overallScore.intValue();
        StringBuilder stars = new StringBuilder();
        for (int i = 1; i <= 5; i++) {
            stars.append(i <= score ? "★" : "☆");
        }
        return stars.toString();
    }
    
    /**
     * 평가 완료 여부 확인
     */
    public boolean isEvaluationComplete() {
        return technicalScore != null && communicationScore != null && 
               problemSolvingScore != null && attitudeScore != null && 
               overallScore != null;
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
    
    @Override
    public String toString() {
        return "InterviewResult{" +
                "id=" + id +
                ", candidateId=" + candidateId +
                ", candidateName='" + candidateName + '\'' +
                ", interviewerName='" + interviewerName + '\'' +
                ", interviewDate=" + interviewDate +
                ", resultStatus='" + resultStatus + '\'' +
                ", overallScore=" + overallScore +
                '}';
    }
}
