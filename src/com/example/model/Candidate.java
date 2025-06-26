package com.example.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class Candidate {
    private int id;
    private String name;
    private String email;
    private String phone;
    private String resume;
    private String team;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getResume() { return resume; }
    public void setResume(String resume) { this.resume = resume; }
    public String getTeam() { return team; }
    public void setTeam(String team) { this.team = team; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    
    // 등록일을 시간만 표시하는 메소드
    public String getCreatedAtTimeOnly() {
        if (createdAt == null) return "";
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");
        return timeFormat.format(createdAt);
    }
    
    // 수정일을 시간만 표시하는 메소드
    public String getUpdatedAtTimeOnly() {
        if (updatedAt == null) return "";
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");
        return timeFormat.format(updatedAt);
    }
} 