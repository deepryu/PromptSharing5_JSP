package com.example.model;

import com.example.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InterviewScheduleDAO {

    public boolean addSchedule(InterviewSchedule schedule) {
        String sql = "INSERT INTO interview_schedules (candidate_id, interviewer_name, interview_date, interview_time, duration, location, interview_type, status, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, schedule.getCandidateId());
            ps.setString(2, schedule.getInterviewerName());
            ps.setDate(3, schedule.getInterviewDate());
            ps.setTime(4, schedule.getInterviewTime());
            ps.setInt(5, schedule.getDuration());
            ps.setString(6, schedule.getLocation());
            ps.setString(7, schedule.getInterviewType());
            ps.setString(8, schedule.getStatus());
            ps.setString(9, schedule.getNotes());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<InterviewSchedule> getAllSchedules() {
        List<InterviewSchedule> list = new ArrayList<>();
        String sql = "SELECT s.*, c.name as candidate_name FROM interview_schedules s LEFT JOIN candidates c ON s.candidate_id = c.id ORDER BY s.interview_date, s.interview_time";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                InterviewSchedule schedule = mapResultSetToSchedule(rs);
                list.add(schedule);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<InterviewSchedule> getSchedulesByCandidateId(int candidateId) {
        List<InterviewSchedule> list = new ArrayList<>();
        String sql = "SELECT s.*, c.name as candidate_name FROM interview_schedules s LEFT JOIN candidates c ON s.candidate_id = c.id WHERE s.candidate_id = ? ORDER BY s.interview_date, s.interview_time";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, candidateId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InterviewSchedule schedule = mapResultSetToSchedule(rs);
                    list.add(schedule);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<InterviewSchedule> getSchedulesByDate(Date date) {
        List<InterviewSchedule> list = new ArrayList<>();
        String sql = "SELECT s.*, c.name as candidate_name FROM interview_schedules s LEFT JOIN candidates c ON s.candidate_id = c.id WHERE s.interview_date = ? ORDER BY s.interview_time";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, date);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InterviewSchedule schedule = mapResultSetToSchedule(rs);
                    list.add(schedule);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<InterviewSchedule> getSchedulesByStatus(String status) {
        List<InterviewSchedule> list = new ArrayList<>();
        String sql = "SELECT s.*, c.name as candidate_name FROM interview_schedules s LEFT JOIN candidates c ON s.candidate_id = c.id WHERE s.status = ? ORDER BY s.interview_date, s.interview_time";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InterviewSchedule schedule = mapResultSetToSchedule(rs);
                    list.add(schedule);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public InterviewSchedule getScheduleById(int id) {
        String sql = "SELECT s.*, c.name as candidate_name FROM interview_schedules s LEFT JOIN candidates c ON s.candidate_id = c.id WHERE s.id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSchedule(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateSchedule(InterviewSchedule schedule) {
        String sql = "UPDATE interview_schedules SET candidate_id=?, interviewer_name=?, interview_date=?, interview_time=?, duration=?, location=?, interview_type=?, status=?, notes=?, updated_at=now() WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, schedule.getCandidateId());
            ps.setString(2, schedule.getInterviewerName());
            ps.setDate(3, schedule.getInterviewDate());
            ps.setTime(4, schedule.getInterviewTime());
            ps.setInt(5, schedule.getDuration());
            ps.setString(6, schedule.getLocation());
            ps.setString(7, schedule.getInterviewType());
            ps.setString(8, schedule.getStatus());
            ps.setString(9, schedule.getNotes());
            ps.setInt(10, schedule.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteSchedule(int id) {
        String sql = "DELETE FROM interview_schedules WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 시간 충돌 체크
    public boolean hasTimeConflict(Date date, Time time, int duration, int excludeId) {
        String sql = "SELECT interview_time, duration FROM interview_schedules WHERE interview_date = ? AND id != ? AND status NOT IN ('취소', '연기')";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, date);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Time existingTime = rs.getTime("interview_time");
                    int existingDuration = rs.getInt("duration");
                    
                    // Java에서 시간 충돌 체크
                    if (isTimeOverlap(time, duration, existingTime, existingDuration)) {
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // 시간 중복 체크 헬퍼 메소드
    private boolean isTimeOverlap(Time time1, int duration1, Time time2, int duration2) {
        long start1 = time1.getTime();
        long end1 = start1 + (duration1 * 60 * 1000); // 분을 밀리초로 변환
        
        long start2 = time2.getTime();
        long end2 = start2 + (duration2 * 60 * 1000);
        
        // 겹치는 경우: (start1 < end2) && (start2 < end1)
        return (start1 < end2) && (start2 < end1);
    }

    private InterviewSchedule mapResultSetToSchedule(ResultSet rs) throws SQLException {
        InterviewSchedule schedule = new InterviewSchedule();
        schedule.setId(rs.getInt("id"));
        schedule.setCandidateId(rs.getInt("candidate_id"));
        schedule.setCandidateName(rs.getString("candidate_name"));
        schedule.setInterviewerName(rs.getString("interviewer_name"));
        schedule.setInterviewDate(rs.getDate("interview_date"));
        schedule.setInterviewTime(rs.getTime("interview_time"));
        schedule.setDuration(rs.getInt("duration"));
        schedule.setLocation(rs.getString("location"));
        schedule.setInterviewType(rs.getString("interview_type"));
        schedule.setStatus(rs.getString("status"));
        schedule.setNotes(rs.getString("notes"));
        schedule.setCreatedAt(rs.getTimestamp("created_at"));
        schedule.setUpdatedAt(rs.getTimestamp("updated_at"));
        return schedule;
    }
} 