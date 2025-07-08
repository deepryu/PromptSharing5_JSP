package com.example.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import com.example.util.FileUploadUtil;

public class Candidate {
    private int id;
    private String name;
    private String email;
    private String phone;
    private String resume;
    private String team;
    private String status;
    private String interviewDateTime;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Integer interviewScheduleId;
    private String interviewResultStatus;
    private String interviewType;
    
    // 이력서 파일 관련 필드
    private String resumeFileName;      // 원본 파일명
    private String resumeFilePath;      // 서버 저장 경로
    private Long resumeFileSize;        // 파일 크기 (바이트)
    private String resumeFileType;      // 파일 형식 (pdf, hwp, doc, docx)
    private Timestamp resumeUploadedAt; // 업로드 일시

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
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getInterviewDateTime() { return interviewDateTime; }
    public void setInterviewDateTime(String interviewDateTime) { this.interviewDateTime = interviewDateTime; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    public Integer getInterviewScheduleId() { return interviewScheduleId; }
    public void setInterviewScheduleId(Integer interviewScheduleId) { this.interviewScheduleId = interviewScheduleId; }
    public String getInterviewResultStatus() { return interviewResultStatus; }
    public void setInterviewResultStatus(String interviewResultStatus) { this.interviewResultStatus = interviewResultStatus; }
    public String getInterviewType() { return interviewType; }
    public void setInterviewType(String interviewType) { this.interviewType = interviewType; }
    
    // 이력서 파일 관련 Getters and Setters
    public String getResumeFileName() { return resumeFileName; }
    public void setResumeFileName(String resumeFileName) { this.resumeFileName = resumeFileName; }
    
    public String getResumeFilePath() { return resumeFilePath; }
    public void setResumeFilePath(String resumeFilePath) { this.resumeFilePath = resumeFilePath; }
    
    public Long getResumeFileSize() { return resumeFileSize; }
    public void setResumeFileSize(Long resumeFileSize) { this.resumeFileSize = resumeFileSize; }
    
    public String getResumeFileType() { return resumeFileType; }
    public void setResumeFileType(String resumeFileType) { this.resumeFileType = resumeFileType; }
    
    public Timestamp getResumeUploadedAt() { return resumeUploadedAt; }
    public void setResumeUploadedAt(Timestamp resumeUploadedAt) { this.resumeUploadedAt = resumeUploadedAt; }
    
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
    
    // 이력서 파일 크기를 사람이 읽기 쉬운 형태로 표시
    public String getResumeFileSizeFormatted() {
        if (resumeFileSize == null || resumeFileSize <= 0) {
            return "";
        }
        return FileUploadUtil.formatFileSize(resumeFileSize);
    }
    
    // 이력서 파일이 첨부되어 있는지 확인
    public boolean hasResumeFile() {
        return resumeFileName != null && !resumeFileName.trim().isEmpty() 
               && resumeFilePath != null && !resumeFilePath.trim().isEmpty();
    }
    
    // 이력서 파일 업로드 일시를 형식화하여 표시
    public String getResumeUploadedAtFormatted() {
        if (resumeUploadedAt == null) return "";
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        return formatter.format(resumeUploadedAt);
    }
    
    // 파일 형식에 따른 아이콘 반환
    public String getResumeFileIcon() {
        if (resumeFileType == null) return "📄";
        
        switch (resumeFileType.toLowerCase()) {
            case "pdf": return "📕";
            case "hwp": return "📘";
            case "doc":
            case "docx": return "📄";
            default: return "📄";
        }
    }
    
    // 파일 형식 표시명 반환
    public String getResumeFileTypeDisplay() {
        if (resumeFileType == null) return "";
        
        switch (resumeFileType.toLowerCase()) {
            case "pdf": return "PDF";
            case "hwp": return "HWP";
            case "doc": return "DOC";
            case "docx": return "DOCX";
            default: return resumeFileType.toUpperCase();
        }
    }
} 