package com.example.model;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import com.example.util.DatabaseUtil;
import java.util.List;

public class CandidateDAOTest {
    private CandidateDAO candidateDAO;
    private final String testEmail = "test_candidate_junit@example.com";

    @Before
    public void setUp() throws Exception {
        candidateDAO = new CandidateDAO();
        // Clean up test candidate if exists
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM candidates WHERE email = ?")) {
            ps.setString(1, testEmail);
            ps.executeUpdate();
        }
    }

    @After
    public void tearDown() throws Exception {
        // Clean up test candidate
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM candidates WHERE email = ?")) {
            ps.setString(1, testEmail);
            ps.executeUpdate();
        }
    }

    @Test
    public void testAddCandidate_Success() {
        Candidate c = new Candidate();
        c.setName("테스트 지원자");
        c.setEmail(testEmail);
        c.setPhone("01012345678");
        c.setResume("JUnit 테스트용 지원자");
        assertTrue(candidateDAO.addCandidate(c));
    }

    @Test
    public void testAddCandidate_Duplicate() {
        Candidate c1 = new Candidate();
        c1.setName("테스트 지원자");
        c1.setEmail(testEmail);
        c1.setPhone("01012345678");
        c1.setResume("JUnit 테스트용 지원자");
        candidateDAO.addCandidate(c1);

        Candidate c2 = new Candidate();
        c2.setName("중복 지원자");
        c2.setEmail(testEmail); // 같은 이메일
        c2.setPhone("01099999999");
        c2.setResume("중복 테스트");
        assertFalse(candidateDAO.addCandidate(c2));
    }

    @Test
    public void testGetCandidateById_Exists() {
        Candidate c = new Candidate();
        c.setName("테스트 지원자");
        c.setEmail(testEmail);
        c.setPhone("01012345678");
        c.setResume("JUnit 테스트용 지원자");
        candidateDAO.addCandidate(c);
        List<Candidate> list = candidateDAO.getAllCandidates();
        Candidate found = null;
        for (Candidate cand : list) {
            if (testEmail.equals(cand.getEmail())) {
                found = candidateDAO.getCandidateById(cand.getId());
                break;
            }
        }
        assertNotNull(found);
        assertEquals(testEmail, found.getEmail());
    }

    @Test
    public void testUpdateCandidate() {
        Candidate c = new Candidate();
        c.setName("테스트 지원자");
        c.setEmail(testEmail);
        c.setPhone("01012345678");
        c.setResume("JUnit 테스트용 지원자");
        candidateDAO.addCandidate(c);
        List<Candidate> list = candidateDAO.getAllCandidates();
        Candidate found = null;
        for (Candidate cand : list) {
            if (testEmail.equals(cand.getEmail())) {
                found = cand;
                break;
            }
        }
        assertNotNull(found);
        found.setName("수정된 지원자");
        found.setPhone("01087654321");
        assertTrue(candidateDAO.updateCandidate(found));
        Candidate updated = candidateDAO.getCandidateById(found.getId());
        assertEquals("수정된 지원자", updated.getName());
        assertEquals("01087654321", updated.getPhone());
    }

    @Test
    public void testDeleteCandidate() {
        Candidate c = new Candidate();
        c.setName("테스트 지원자");
        c.setEmail(testEmail);
        c.setPhone("01012345678");
        c.setResume("JUnit 테스트용 지원자");
        candidateDAO.addCandidate(c);
        List<Candidate> list = candidateDAO.getAllCandidates();
        Candidate found = null;
        for (Candidate cand : list) {
            if (testEmail.equals(cand.getEmail())) {
                found = cand;
                break;
            }
        }
        assertNotNull(found);
        assertTrue(candidateDAO.deleteCandidate(found.getId()));
        Candidate deleted = candidateDAO.getCandidateById(found.getId());
        assertNull(deleted);
    }
} 