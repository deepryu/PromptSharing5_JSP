package com.example.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

/**
 * 활동 히스토리를 관리하는 모델 클래스
 */
public class ActivityHistory {
    private int id;
    private String username;
    private String action; // login, logout, create, update, delete
    private String targetType; // candidate, schedule, result, question, etc.
    private Integer targetId;
    private String targetName; // 대상 객체의 이름이나 제목
    private String description; // 상세 설명
    private String ipAddress;
    private String userAgent;
    private Timestamp createdAt;
    
    // 기본 생성자
    public ActivityHistory() {}
    
    // 매개변수 생성자
    public ActivityHistory(String username, String action, String targetType, 
                          Integer targetId, String targetName, String description) {
        this.username = username;
        this.action = action;
        this.targetType = targetType;
        this.targetId = targetId;
        this.targetName = targetName;
        this.description = description;
    }
    
    // Getter and Setter methods
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getAction() {
        return action;
    }
    
    public void setAction(String action) {
        this.action = action;
    }
    
    public String getTargetType() {
        return targetType;
    }
    
    public void setTargetType(String targetType) {
        this.targetType = targetType;
    }
    
    public Integer getTargetId() {
        return targetId;
    }
    
    public void setTargetId(Integer targetId) {
        this.targetId = targetId;
    }
    
    public String getTargetName() {
        return targetName;
    }
    
    public void setTargetName(String targetName) {
        this.targetName = targetName;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getIpAddress() {
        return ipAddress;
    }
    
    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }
    
    public String getUserAgent() {
        return userAgent;
    }
    
    public void setUserAgent(String userAgent) {
        this.userAgent = userAgent;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    // 편의 메소드들
    public String getCreatedAtFormatted() {
        if (createdAt == null) return "";
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        return formatter.format(createdAt);
    }
    
    public String getCreatedAtDateOnly() {
        if (createdAt == null) return "";
        SimpleDateFormat dateFormat = new SimpleDateFormat("MM-dd");
        return dateFormat.format(createdAt);
    }
    
    public String getCreatedAtTimeOnly() {
        if (createdAt == null) return "";
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
        return timeFormat.format(createdAt);
    }
    
    public String getActionDisplayName() {
        switch (action) {
            case "login": return "로그인";
            case "logout": return "로그아웃";
            case "create": return "생성";
            case "update": return "수정";
            case "delete": return "삭제";
            case "view": return "조회";
            default: return action;
        }
    }
    
    public String getTargetTypeDisplayName() {
        switch (targetType) {
            case "candidate": return "지원자";
            case "schedule": return "면접 일정";
            case "result": return "평가 결과";
            case "question": return "면접 질문";
            case "criteria": return "평가 기준";
            case "interviewer": return "면접관";
            case "user": return "사용자";
            case "system": return "시스템";
            default: return targetType;
        }
    }
    
    public String getActionClass() {
        switch (action) {
            case "login": return "action-login";
            case "logout": return "action-logout";
            case "create": return "action-create";
            case "update": return "action-update";
            case "delete": return "action-delete";
            case "view": return "action-view";
            default: return "action-default";
        }
    }
    
    public String getSummary() {
        StringBuilder summary = new StringBuilder();
        summary.append(getActionDisplayName());
        
        if (targetType != null && !targetType.isEmpty()) {
            summary.append(" - ").append(getTargetTypeDisplayName());
        }
        
        if (targetName != null && !targetName.isEmpty()) {
            summary.append(": ").append(targetName);
        }
        
        return summary.toString();
    }
} 