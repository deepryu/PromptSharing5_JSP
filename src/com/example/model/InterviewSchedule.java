package com.example.model;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class InterviewSchedule {
    private int id;
    private int candidateId;
    private String candidateName; // 조인을 위한 필드
    private String interviewerName;
    private Date interviewDate;
    private Time interviewTime;
    private int duration; // 면접 시간(분)
    private String location;
    private String interviewType;
    private String status;
    private String notes;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // 기본 생성자
    public InterviewSchedule() {}

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCandidateId() { return candidateId; }
    public void setCandidateId(int candidateId) { this.candidateId = candidateId; }

    public String getCandidateName() { return candidateName; }
    public void setCandidateName(String candidateName) { this.candidateName = candidateName; }

    public String getInterviewerName() { return interviewerName; }
    public void setInterviewerName(String interviewerName) { this.interviewerName = interviewerName; }

    public Date getInterviewDate() { return interviewDate; }
    public void setInterviewDate(Date interviewDate) { this.interviewDate = interviewDate; }

    public Time getInterviewTime() { return interviewTime; }
    public void setInterviewTime(Time interviewTime) { this.interviewTime = interviewTime; }

    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getInterviewType() { return interviewType; }
    public void setInterviewType(String interviewType) { this.interviewType = interviewType; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    // 편의 메소드들
    public String getInterviewDateFormatted() {
        if (interviewDate == null) return "";
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        return dateFormat.format(interviewDate);
    }

    public String getInterviewTimeFormatted() {
        if (interviewTime == null) return "";
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
        return timeFormat.format(interviewTime);
    }

    public String getInterviewDateTimeFormatted() {
        return getInterviewDateFormatted() + " " + getInterviewTimeFormatted();
    }

    public String getDurationFormatted() {
        if (duration <= 0) return "미정";
        int hours = duration / 60;
        int minutes = duration % 60;
        if (hours > 0) {
            return hours + "시간 " + (minutes > 0 ? minutes + "분" : "");
        } else {
            return minutes + "분";
        }
    }

    public String getStatusDisplayName() {
        switch (status) {
            case "scheduled": return "예정";
            case "in_progress": return "진행중";
            case "completed": return "완료";
            case "cancelled": return "취소";
            case "postponed": return "연기";
            default: return status;
        }
    }
} 