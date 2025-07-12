package com.example.model;

import com.example.util.DatabaseUtil;
import com.example.util.FileUploadUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CandidateDAO {
    public boolean isEmailExists(String email) {
        String sql = "SELECT COUNT(*) FROM candidates WHERE email = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isEmailExistsForUpdate(String email, int candidateId) {
        String sql = "SELECT COUNT(*) FROM candidates WHERE email = ? AND id != ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, candidateId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addCandidate(Candidate candidate) {
        if (isEmailExists(candidate.getEmail())) {
            return false;
        }
        
        String sql = "INSERT INTO candidates (name, email, phone, resume, team, resume_file_name, resume_file_path, resume_file_size, resume_file_type, resume_uploaded_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, candidate.getName());
            ps.setString(2, candidate.getEmail());
            ps.setString(3, candidate.getPhone());
            ps.setString(4, candidate.getResume());
            ps.setString(5, candidate.getTeam());
            ps.setString(6, candidate.getResumeFileName());
            ps.setString(7, candidate.getResumeFilePath());
            if (candidate.getResumeFileSize() != null) {
                ps.setLong(8, candidate.getResumeFileSize());
            } else {
                ps.setNull(8, Types.BIGINT);
            }
            ps.setString(9, candidate.getResumeFileType());
            ps.setTimestamp(10, candidate.getResumeUploadedAt());
            
            int result = ps.executeUpdate();
            if (result > 0) {
                // 생성된 ID를 Candidate 객체에 설정
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        candidate.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Candidate> getAllCandidates() {
        List<Candidate> list = new ArrayList<>();
        String sql = "SELECT * FROM candidates ORDER BY created_at DESC";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Candidate c = mapResultSetToCandidate(rs);
                list.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 지원자 목록과 최신 인터뷰 일정을 함께 가져오는 메서드
    public List<Candidate> getAllCandidatesWithInterviewSchedule() {
        List<Candidate> list = new ArrayList<>();
        InterviewResultDAO resultDAO = new InterviewResultDAO();
        InterviewScheduleDAO scheduleDAO = new InterviewScheduleDAO();
        String sql =
            "SELECT c.*, s.id AS interview_schedule_id, s.interview_date, s.interview_time " +
            "FROM candidates c " +
            "LEFT JOIN ( " +
            "    SELECT DISTINCT ON (candidate_id) id, candidate_id, interview_date, interview_time " +
            "    FROM interview_schedules " +
            "    ORDER BY candidate_id, interview_date DESC, interview_time DESC " +
            ") s ON c.id = s.candidate_id " +
            "ORDER BY c.created_at DESC";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Candidate c = mapResultSetToCandidate(rs);
                
                java.sql.Date interviewDate = rs.getDate("interview_date");
                java.sql.Time interviewTime = rs.getTime("interview_time");
                int scheduleId = rs.getInt("interview_schedule_id");
                if (!rs.wasNull()) {
                    c.setInterviewScheduleId(scheduleId);
                    // 상태값: 결과 있으면 결과, 없으면 예정
                    String status = resultDAO.getResultStatusByScheduleId(scheduleId);
                    if (status != null && !status.isEmpty()) {
                        c.setInterviewResultStatus(status);
                    } else {
                        c.setInterviewResultStatus("예정");
                    }
                    // 면접유형 세팅
                    InterviewResult result = resultDAO.getResultByScheduleId(scheduleId);
                    if (result != null && result.getInterviewType() != null) {
                        c.setInterviewType(result.getInterviewType());
                    } else {
                        c.setInterviewType("-");
                    }
                } else {
                    c.setInterviewResultStatus("미등록");
                    c.setInterviewType("-");
                }
                if (interviewDate != null && interviewTime != null) {
                    c.setInterviewDateTime(interviewDate.toString() + " " + interviewTime.toString().substring(0, 5));
                }
                
                // 버튼 상태 제어를 위한 데이터 설정
                // 1. 인터뷰 일정 존재 여부 확인
                List<InterviewSchedule> candidateSchedules = scheduleDAO.getSchedulesByCandidateId(c.getId());
                boolean hasSchedule = candidateSchedules != null && !candidateSchedules.isEmpty();
                c.setHasInterviewSchedule(hasSchedule);
                
                // 2. 인터뷰 결과 존재 여부 확인
                List<InterviewResult> candidateResults = resultDAO.getResultsByCandidateId(c.getId());
                boolean hasResult = candidateResults != null && !candidateResults.isEmpty();
                c.setHasInterviewResult(hasResult);
                
                list.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Candidate> getCandidatesByStatus(String status) {
        // 현재 DB에 status 컬럼이 없으므로 모든 지원자를 반환
        // 실제로는 status 필드가 있어야 함
        return getAllCandidatesWithInterviewSchedule();
    }

    public List<Candidate> searchCandidates(String search) {
        List<Candidate> list = new ArrayList<>();
        String sql = "SELECT * FROM candidates WHERE name ILIKE ? OR email ILIKE ? ORDER BY created_at DESC";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String searchPattern = "%" + search + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Candidate c = mapResultSetToCandidate(rs);
                    list.add(c);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Candidate getCandidateById(int id) {
        String sql = "SELECT * FROM candidates WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCandidate(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateCandidate(Candidate candidate) {
        if (isEmailExistsForUpdate(candidate.getEmail(), candidate.getId())) {
            return false;
        }
        
        String sql = "UPDATE candidates SET name=?, email=?, phone=?, resume=?, team=?, resume_file_name=?, resume_file_path=?, resume_file_size=?, resume_file_type=?, resume_uploaded_at=?, updated_at=now() WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, candidate.getName());
            ps.setString(2, candidate.getEmail());
            ps.setString(3, candidate.getPhone());
            ps.setString(4, candidate.getResume());
            ps.setString(5, candidate.getTeam());
            ps.setString(6, candidate.getResumeFileName());
            ps.setString(7, candidate.getResumeFilePath());
            if (candidate.getResumeFileSize() != null) {
                ps.setLong(8, candidate.getResumeFileSize());
            } else {
                ps.setNull(8, Types.BIGINT);
            }
            ps.setString(9, candidate.getResumeFileType());
            ps.setTimestamp(10, candidate.getResumeUploadedAt());
            ps.setInt(11, candidate.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteCandidate(int id) {
        // 먼저 기존 이력서 파일 삭제
        Candidate candidate = getCandidateById(id);
        if (candidate != null && candidate.getResumeFilePath() != null) {
            FileUploadUtil.deleteResumeFile(candidate.getResumeFilePath());
        }
        
        String sql = "DELETE FROM candidates WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // ========== 이력서 파일 관련 메소드들 ==========
    
    /**
     * 지원자의 이력서 파일 정보만 업데이트합니다.
     */
    public boolean updateCandidateResumeFile(int candidateId, String fileName, String filePath, 
                                           Long fileSize, String fileType, Timestamp uploadedAt) {
        // 기존 파일이 있다면 삭제
        Candidate existingCandidate = getCandidateById(candidateId);
        if (existingCandidate != null && existingCandidate.getResumeFilePath() != null) {
            FileUploadUtil.deleteResumeFile(existingCandidate.getResumeFilePath());
        }
        
        String sql = "UPDATE candidates SET resume_file_name=?, resume_file_path=?, resume_file_size=?, resume_file_type=?, resume_uploaded_at=?, updated_at=now() WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fileName);
            ps.setString(2, filePath);
            if (fileSize != null) {
                ps.setLong(3, fileSize);
            } else {
                ps.setNull(3, Types.BIGINT);
            }
            ps.setString(4, fileType);
            ps.setTimestamp(5, uploadedAt);
            ps.setInt(6, candidateId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * 지원자의 이력서 파일을 삭제합니다.
     */
    public boolean deleteCandidateResumeFile(int candidateId) {
        // 먼저 파일 정보 조회
        Candidate candidate = getCandidateById(candidateId);
        if (candidate == null || candidate.getResumeFilePath() == null) {
            return false;
        }
        
        // 실제 파일 삭제
        boolean fileDeleted = FileUploadUtil.deleteResumeFile(candidate.getResumeFilePath());
        
        // DB에서 파일 정보 삭제
        String sql = "UPDATE candidates SET resume_file_name=NULL, resume_file_path=NULL, resume_file_size=NULL, resume_file_type=NULL, resume_uploaded_at=NULL, updated_at=now() WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, candidateId);
            boolean dbUpdated = ps.executeUpdate() > 0;
            return fileDeleted && dbUpdated;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * 이력서 파일이 첨부된 지원자 목록을 가져옵니다.
     */
    public List<Candidate> getCandidatesWithResumeFiles() {
        List<Candidate> list = new ArrayList<>();
        String sql = "SELECT * FROM candidates WHERE resume_file_name IS NOT NULL AND resume_file_path IS NOT NULL ORDER BY resume_uploaded_at DESC";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Candidate c = mapResultSetToCandidate(rs);
                list.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    /**
     * 특정 파일 형식의 이력서를 가진 지원자 목록을 가져옵니다.
     */
    public List<Candidate> getCandidatesByResumeFileType(String fileType) {
        List<Candidate> list = new ArrayList<>();
        String sql = "SELECT * FROM candidates WHERE resume_file_type = ? ORDER BY resume_uploaded_at DESC";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fileType.toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Candidate c = mapResultSetToCandidate(rs);
                    list.add(c);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    /**
     * ResultSet을 Candidate 객체로 변환하는 헬퍼 메소드
     */
    private Candidate mapResultSetToCandidate(ResultSet rs) throws SQLException {
        Candidate c = new Candidate();
        c.setId(rs.getInt("id"));
        c.setName(rs.getString("name"));
        c.setEmail(rs.getString("email"));
        c.setPhone(rs.getString("phone"));
        c.setResume(rs.getString("resume"));
        c.setTeam(rs.getString("team"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        // 이력서 파일 관련 필드
        c.setResumeFileName(rs.getString("resume_file_name"));
        c.setResumeFilePath(rs.getString("resume_file_path"));
        Long fileSize = rs.getLong("resume_file_size");
        if (!rs.wasNull()) {
            c.setResumeFileSize(fileSize);
        }
        c.setResumeFileType(rs.getString("resume_file_type"));
        c.setResumeUploadedAt(rs.getTimestamp("resume_uploaded_at"));
        
        // 데이터베이스에서 상태 값 읽기 (기본값: "활성")
        String status = rs.getString("status");
        c.setStatus(status != null ? status : "활성");
        
        return c;
    }
    
    /**
     * 지원자의 상태를 업데이트합니다.
     * @param candidateId 지원자 ID
     * @param status 새로운 상태 (예: "면접완료", "활성", "비활성" 등)
     * @return 업데이트 성공 여부
     */
    public boolean updateCandidateStatus(int candidateId, String status) {
        String sql = "UPDATE candidates SET status = ?, updated_at = now() WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, candidateId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
} 