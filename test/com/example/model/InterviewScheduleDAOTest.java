package com.example.model;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Date;
import java.sql.Time;
import com.example.util.DatabaseUtil;
import java.util.List;

public class InterviewScheduleDAOTest {
    private InterviewScheduleDAO scheduleDAO;
    private CandidateDAO candidateDAO;
    private int testCandidateId;
    private final String testCandidateEmail = "test_schedule_candidate_junit@example.com";

    @Before
    public void setUp() throws Exception {
        scheduleDAO = new InterviewScheduleDAO();
        candidateDAO = new CandidateDAO();
        
        // Clean up test data
        cleanupTestData();
        
        // Create test candidate
        Candidate testCandidate = new Candidate();
        testCandidate.setName("테스트 지원자 for 일정");
        testCandidate.setEmail(testCandidateEmail);
        testCandidate.setPhone("01012345678");
        testCandidate.setResume("인터뷰 일정 테스트용 지원자");
        testCandidate.setTeam("개발팀");
        
        assertTrue("테스트 지원자 생성 실패", candidateDAO.addCandidate(testCandidate));
        
        // Get created candidate ID
        List<Candidate> candidates = candidateDAO.getAllCandidates();
        for (Candidate c : candidates) {
            if (testCandidateEmail.equals(c.getEmail())) {
                testCandidateId = c.getId();
                break;
            }
        }
        assertTrue("테스트 지원자 ID 찾기 실패", testCandidateId > 0);
    }

    @After
    public void tearDown() throws Exception {
        cleanupTestData();
    }

    private void cleanupTestData() {
        try (Connection conn = DatabaseUtil.getConnection()) {
            // Delete test interview schedules
            try (PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM interview_schedules WHERE candidate_id IN (SELECT id FROM candidates WHERE email = ?)")) {
                ps.setString(1, testCandidateEmail);
                ps.executeUpdate();
            }
            
            // Delete test candidate
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM candidates WHERE email = ?")) {
                ps.setString(1, testCandidateEmail);
                ps.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Test
    public void testAddSchedule_Success() {
        InterviewSchedule schedule = createTestSchedule();
        assertTrue("일정 추가 실패", scheduleDAO.addSchedule(schedule));
    }

    @Test
    public void testGetScheduleById_Exists() {
        InterviewSchedule schedule = createTestSchedule();
        scheduleDAO.addSchedule(schedule);
        
        List<InterviewSchedule> schedules = scheduleDAO.getSchedulesByCandidateId(testCandidateId);
        assertFalse("추가된 일정이 조회되지 않음", schedules.isEmpty());
        
        InterviewSchedule found = scheduleDAO.getScheduleById(schedules.get(0).getId());
        assertNotNull("ID로 일정 조회 실패", found);
        assertEquals("면접관 이름 불일치", "김면접관", found.getInterviewerName());
        assertEquals("면접 유형 불일치", "기술면접", found.getInterviewType());
    }

    @Test
    public void testGetScheduleById_NotExists() {
        InterviewSchedule schedule = scheduleDAO.getScheduleById(99999);
        assertNull("존재하지 않는 일정이 조회됨", schedule);
    }

    @Test
    public void testUpdateSchedule() {
        InterviewSchedule schedule = createTestSchedule();
        scheduleDAO.addSchedule(schedule);
        
        List<InterviewSchedule> schedules = scheduleDAO.getSchedulesByCandidateId(testCandidateId);
        InterviewSchedule created = schedules.get(0);
        
        // Update schedule
        created.setInterviewerName("박면접관");
        created.setLocation("회의실 B");
        created.setStatus("진행중");
        created.setNotes("수정된 메모");
        
        assertTrue("일정 수정 실패", scheduleDAO.updateSchedule(created));
        
        InterviewSchedule updated = scheduleDAO.getScheduleById(created.getId());
        assertEquals("면접관 이름 수정 실패", "박면접관", updated.getInterviewerName());
        assertEquals("장소 수정 실패", "회의실 B", updated.getLocation());
        assertEquals("상태 수정 실패", "진행중", updated.getStatus());
        assertEquals("메모 수정 실패", "수정된 메모", updated.getNotes());
    }

    @Test
    public void testDeleteSchedule() {
        InterviewSchedule schedule = createTestSchedule();
        scheduleDAO.addSchedule(schedule);
        
        List<InterviewSchedule> schedules = scheduleDAO.getSchedulesByCandidateId(testCandidateId);
        int scheduleId = schedules.get(0).getId();
        
        assertTrue("일정 삭제 실패", scheduleDAO.deleteSchedule(scheduleId));
        
        InterviewSchedule deleted = scheduleDAO.getScheduleById(scheduleId);
        assertNull("삭제된 일정이 여전히 조회됨", deleted);
    }

    @Test
    public void testGetSchedulesByCandidateId() {
        InterviewSchedule schedule1 = createTestSchedule();
        InterviewSchedule schedule2 = createTestSchedule();
        schedule2.setInterviewerName("이면접관");
        schedule2.setInterviewTime(Time.valueOf("15:00:00"));
        
        scheduleDAO.addSchedule(schedule1);
        scheduleDAO.addSchedule(schedule2);
        
        List<InterviewSchedule> schedules = scheduleDAO.getSchedulesByCandidateId(testCandidateId);
        assertEquals("지원자별 일정 조회 실패", 2, schedules.size());
    }

    @Test
    public void testGetSchedulesByDate() {
        Date testDate = Date.valueOf("2024-12-31");
        
        InterviewSchedule schedule = createTestSchedule();
        schedule.setInterviewDate(testDate);
        scheduleDAO.addSchedule(schedule);
        
        List<InterviewSchedule> schedules = scheduleDAO.getSchedulesByDate(testDate);
        assertFalse("날짜별 일정 조회 실패", schedules.isEmpty());
        
        boolean found = false;
        for (InterviewSchedule s : schedules) {
            if (s.getCandidateId() == testCandidateId) {
                found = true;
                break;
            }
        }
        assertTrue("추가한 일정이 날짜별 조회에서 발견되지 않음", found);
    }

    @Test
    public void testGetSchedulesByStatus() {
        String testStatus = "예정";
        
        InterviewSchedule schedule = createTestSchedule();
        schedule.setStatus(testStatus);
        scheduleDAO.addSchedule(schedule);
        
        List<InterviewSchedule> schedules = scheduleDAO.getSchedulesByStatus(testStatus);
        assertFalse("상태별 일정 조회 실패", schedules.isEmpty());
        
        boolean found = false;
        for (InterviewSchedule s : schedules) {
            if (s.getCandidateId() == testCandidateId) {
                found = true;
                assertEquals("상태 불일치", testStatus, s.getStatus());
                break;
            }
        }
        assertTrue("추가한 일정이 상태별 조회에서 발견되지 않음", found);
    }

    @Test
    public void testHasTimeConflict_NoConflict() {
        Date testDate = Date.valueOf("2024-12-31");
        Time testTime = Time.valueOf("10:00:00");
        int duration = 60;
        
        boolean hasConflict = scheduleDAO.hasTimeConflict(testDate, testTime, duration, 0);
        assertFalse("시간 충돌이 없어야 함", hasConflict);
    }

    @Test
    public void testHasTimeConflict_WithConflict() {
        Date testDate = Date.valueOf("2024-12-31");
        Time testTime = Time.valueOf("14:00:00");
        
        // 첫 번째 일정 추가
        InterviewSchedule schedule1 = createTestSchedule();
        schedule1.setInterviewDate(testDate);
        schedule1.setInterviewTime(testTime);
        schedule1.setDuration(60);
        scheduleDAO.addSchedule(schedule1);
        
        // 같은 시간에 충돌하는 일정 체크
        Time conflictTime = Time.valueOf("14:30:00"); // 30분 후 시작 (충돌)
        boolean hasConflict = scheduleDAO.hasTimeConflict(testDate, conflictTime, 60, 0);
        assertTrue("시간 충돌이 감지되어야 함", hasConflict);
    }

    @Test
    public void testGetAllSchedules() {
        InterviewSchedule schedule = createTestSchedule();
        scheduleDAO.addSchedule(schedule);
        
        List<InterviewSchedule> allSchedules = scheduleDAO.getAllSchedules();
        assertFalse("전체 일정 조회 실패", allSchedules.isEmpty());
        
        boolean found = false;
        for (InterviewSchedule s : allSchedules) {
            if (s.getCandidateId() == testCandidateId) {
                found = true;
                assertNotNull("지원자 이름이 조인되지 않음", s.getCandidateName());
                break;
            }
        }
        assertTrue("추가한 일정이 전체 조회에서 발견되지 않음", found);
    }

    private InterviewSchedule createTestSchedule() {
        InterviewSchedule schedule = new InterviewSchedule();
        schedule.setCandidateId(testCandidateId);
        schedule.setInterviewerName("김면접관");
        schedule.setInterviewDate(Date.valueOf("2024-12-30"));
        schedule.setInterviewTime(Time.valueOf("14:00:00"));
        schedule.setDuration(60);
        schedule.setLocation("회의실 A");
        schedule.setInterviewType("기술면접");
        schedule.setStatus("예정");
        schedule.setNotes("JUnit 테스트용 일정");
        return schedule;
    }
} 