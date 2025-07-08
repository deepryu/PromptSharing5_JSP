package com.example.model;

import java.sql.Timestamp;

public class SystemSettings {
    private int id;
    private String settingKey;
    private String settingValue;
    private String description;
    private String category;
    private boolean isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // 기본 생성자
    public SystemSettings() {}
    
    // 전체 필드 생성자
    public SystemSettings(int id, String settingKey, String settingValue, String description, 
                         String category, boolean isActive, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.settingKey = settingKey;
        this.settingValue = settingValue;
        this.description = description;
        this.category = category;
        this.isActive = isActive;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Getter and Setter methods
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getSettingKey() {
        return settingKey;
    }
    
    public void setSettingKey(String settingKey) {
        this.settingKey = settingKey;
    }
    
    public String getSettingValue() {
        return settingValue;
    }
    
    public void setSettingValue(String settingValue) {
        this.settingValue = settingValue;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getCategory() {
        return category;
    }
    
    public void setCategory(String category) {
        this.category = category;
    }
    
    public boolean getIsActive() {
        return isActive;
    }
    
    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
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
    
    // 유틸리티 메소드
    public String getFormattedCreatedAt() {
        if (createdAt == null) return "";
        return new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(createdAt);
    }
    
    public String getFormattedUpdatedAt() {
        if (updatedAt == null) return "";
        return new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(updatedAt);
    }
    
    public String getCategoryDisplayName() {
        switch (category != null ? category.toUpperCase() : "") {
            case "SYSTEM":
                return "시스템";
            case "EMAIL":
                return "이메일";
            case "SECURITY":
                return "보안";
            case "DATABASE":
                return "데이터베이스";
            default:
                return category != null ? category : "기타";
        }
    }
    
    public String getStatusDisplayName() {
        return isActive ? "활성" : "비활성";
    }
    
    public String getStatusColorClass() {
        return isActive ? "status-active" : "status-inactive";
    }
    
    @Override
    public String toString() {
        return "SystemSettings{" +
                "id=" + id +
                ", settingKey='" + settingKey + '\'' +
                ", settingValue='" + settingValue + '\'' +
                ", description='" + description + '\'' +
                ", category='" + category + '\'' +
                ", isActive=" + isActive +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
} 