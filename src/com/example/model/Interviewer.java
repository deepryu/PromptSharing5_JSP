package com.example.model;

import java.sql.Timestamp;

/**
 * 면접관 정보를 관리하는 모델 클래스
 */
public class Interviewer {
    private Integer id;
    private String name;
    private String email;
    private String department;
    private String position;
    private String phoneNumber;
    private String expertise; // 전문분야 (예: 기술, 인사, 경영)
    private String role; // 역할 (SENIOR, JUNIOR, LEAD)
    private boolean isActive;
    private String notes; // 비고
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // 기본 생성자
    public Interviewer() {}
    
    // 전체 파라미터 생성자
    public Interviewer(String name, String email, String department, String position, 
                      String phoneNumber, String expertise, String role, boolean isActive, String notes) {
        this.name = name;
        this.email = email;
        this.department = department;
        this.position = position;
        this.phoneNumber = phoneNumber;
        this.expertise = expertise;
        this.role = role;
        this.isActive = isActive;
        this.notes = notes;
    }
    
    // Getter and Setter methods
    public Integer getId() {
        return id;
    }
    
    public void setId(Integer id) {
        this.id = id;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getDepartment() {
        return department;
    }
    
    public void setDepartment(String department) {
        this.department = department;
    }
    
    public String getPosition() {
        return position;
    }
    
    public void setPosition(String position) {
        this.position = position;
    }
    
    public String getPhoneNumber() {
        return phoneNumber;
    }
    
    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
    
    public String getExpertise() {
        return expertise;
    }
    
    public void setExpertise(String expertise) {
        this.expertise = expertise;
    }
    
    public String getRole() {
        return role;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
    }
    
    public String getNotes() {
        return notes;
    }
    
    public void setNotes(String notes) {
        this.notes = notes;
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
    
    @Override
    public String toString() {
        return "Interviewer{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", department='" + department + '\'' +
                ", position='" + position + '\'' +
                ", expertise='" + expertise + '\'' +
                ", role='" + role + '\'' +
                ", isActive=" + isActive +
                '}';
    }
} 