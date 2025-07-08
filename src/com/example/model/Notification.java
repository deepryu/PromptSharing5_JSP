package com.example.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

/**
 * 알림 정보를 관리하는 모델 클래스
 */
public class Notification {
    private int id;
    private String title;
    private String content;
    private String type; // info, warning, success, error
    private String targetUser; // 특정 사용자 대상, null이면 전체
    private boolean isRead;
    private String relatedType; // schedule, result, candidate, user
    private Integer relatedId; // 관련 객체 ID
    private Timestamp createdAt;
    private Timestamp readAt;
    
    // 기본 생성자
    public Notification() {}
    
    // 매개변수 생성자
    public Notification(String title, String content, String type, String targetUser, 
                       String relatedType, Integer relatedId) {
        this.title = title;
        this.content = content;
        this.type = type;
        this.targetUser = targetUser;
        this.relatedType = relatedType;
        this.relatedId = relatedId;
        this.isRead = false;
    }
    
    // Getter and Setter methods
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }
    
    public String getTargetUser() {
        return targetUser;
    }
    
    public void setTargetUser(String targetUser) {
        this.targetUser = targetUser;
    }
    
    public boolean isRead() {
        return isRead;
    }
    
    public void setRead(boolean read) {
        isRead = read;
    }
    
    public String getRelatedType() {
        return relatedType;
    }
    
    public void setRelatedType(String relatedType) {
        this.relatedType = relatedType;
    }
    
    public Integer getRelatedId() {
        return relatedId;
    }
    
    public void setRelatedId(Integer relatedId) {
        this.relatedId = relatedId;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getReadAt() {
        return readAt;
    }
    
    public void setReadAt(Timestamp readAt) {
        this.readAt = readAt;
    }
    
    // 편의 메소드들
    public String getCreatedAtFormatted() {
        if (createdAt == null) return "";
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        return formatter.format(createdAt);
    }
    
    public String getCreatedAtTimeOnly() {
        if (createdAt == null) return "";
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
        return timeFormat.format(createdAt);
    }
    
    public String getTypeDisplayName() {
        switch (type) {
            case "info": return "정보";
            case "warning": return "경고";
            case "success": return "성공";
            case "error": return "오류";
            default: return "알림";
        }
    }
    
    public String getRelatedTypeDisplayName() {
        switch (relatedType) {
            case "schedule": return "면접 일정";
            case "result": return "평가 결과";
            case "candidate": return "지원자";
            case "user": return "사용자";
            case "system": return "시스템";
            default: return "기타";
        }
    }
    
    public String getStatusClass() {
        if (isRead) {
            return "notification-read";
        } else {
            return "notification-unread";
        }
    }
    
    public String getTypeClass() {
        return "notification-" + type;
    }
} 