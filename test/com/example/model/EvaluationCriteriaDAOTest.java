package com.example.model;

import org.junit.Before;
import org.junit.Test;
import org.junit.After;
import static org.junit.Assert.*;

import java.math.BigDecimal;
import java.util.List;

/**
 * 평가 기준 DAO JUnit 테스트 클래스
 * 
 * 주요 기능 테스트:
 * - CRUD 기능 (생성, 조회, 수정, 삭제)
 * - 가중치 관리 기능
 * - 상태 관리 기능
 */
public class EvaluationCriteriaDAOTest {
    
    private EvaluationCriteriaDAO criteriaDAO;
    private int testCriteriaId1 = 0;
    private int testCriteriaId2 = 0;
    
    @Before
    public void setUp() throws Exception {
        criteriaDAO = new EvaluationCriteriaDAO();
        System.out.println("데이터베이스 연결 성공");
        
        // 테스트 데이터 생성
        createTestData();
    }
    
    private void createTestData() {
        // 기술 역량 평가 기준 생성
        EvaluationCriteria techCriteria = new EvaluationCriteria();
        techCriteria.setCriteriaName("기술 역량");
        techCriteria.setDescription("프로그래밍 언어, 프레임워크, 도구 사용 능력");
        techCriteria.setMaxScore(100);
        techCriteria.setWeight(new BigDecimal("1.3"));
        techCriteria.setActive(true);
        
        criteriaDAO.addCriteria(techCriteria);
        
        // 소프트 스킬 평가 기준 생성
        EvaluationCriteria softSkillCriteria = new EvaluationCriteria();
        softSkillCriteria.setCriteriaName("소프트 스킬");
        softSkillCriteria.setDescription("의사소통, 팀워크, 문제해결 능력");
        softSkillCriteria.setMaxScore(100);
        softSkillCriteria.setWeight(new BigDecimal("1.1"));
        softSkillCriteria.setActive(true);
        
        criteriaDAO.addCriteria(softSkillCriteria);
        
        // 테스트용 ID 가져오기
        List<EvaluationCriteria> allCriteria = criteriaDAO.getAllCriteria();
        if (allCriteria != null && allCriteria.size() >= 2) {
            int size = allCriteria.size();
            testCriteriaId1 = allCriteria.get(size - 2).getId();
            testCriteriaId2 = allCriteria.get(size - 1).getId();
        }
    }
    
    @Test
    public void test01_createCriteria() {
        System.out.println("[TEST 1] 평가 기준 생성 테스트");
        
        // 새로운 평가 기준 생성
        EvaluationCriteria newCriteria = new EvaluationCriteria();
        newCriteria.setCriteriaName("업무 경험");
        newCriteria.setDescription("관련 업무 경험 및 프로젝트 수행 능력");
        newCriteria.setMaxScore(100);
        newCriteria.setWeight(new BigDecimal("0.9"));
        newCriteria.setActive(true);
        
        boolean result = criteriaDAO.addCriteria(newCriteria);
        assertTrue("평가 기준 생성이 성공해야 합니다", result);
        System.out.println("✅ 평가 기준 생성 테스트 통과");
    }
    
    @Test
    public void test02_getAllCriteria() {
        System.out.println("[TEST 2] 전체 평가 기준 조회 테스트");
        
        List<EvaluationCriteria> allCriteria = criteriaDAO.getAllCriteria();
        assertNotNull("전체 평가 기준 목록이 null이 아니어야 합니다", allCriteria);
        assertTrue("평가 기준이 최소 2개 이상 있어야 합니다", allCriteria.size() >= 2);
        
        // 활성화된 평가 기준만 조회
        List<EvaluationCriteria> activeCriteria = criteriaDAO.getActiveCriteria();
        assertNotNull("활성화된 평가 기준 목록이 null이 아니어야 합니다", activeCriteria);
        
        System.out.println("✅ 전체 평가 기준 조회 테스트 통과 (총 " + allCriteria.size() + "개)");
    }
    
    @Test
    public void test03_getCriteriaById() {
        System.out.println("[TEST 3] ID로 평가 기준 조회 테스트");
        
        if (testCriteriaId1 > 0) {
            EvaluationCriteria criteria = criteriaDAO.getCriteriaById(testCriteriaId1);
            assertNotNull("평가 기준이 조회되어야 합니다", criteria);
            assertEquals("ID가 일치해야 합니다", testCriteriaId1, criteria.getId());
            
            System.out.println("✅ ID로 평가 기준 조회 테스트 통과");
        } else {
            System.out.println("⚠️ 테스트용 평가 기준 ID가 없어 조회 테스트 생략");
        }
    }
    
    @Test
    public void test04_updateCriteria() {
        System.out.println("[TEST 4] 평가 기준 수정 테스트");
        
        if (testCriteriaId1 > 0) {
            // 평가 기준 조회
            EvaluationCriteria criteria = criteriaDAO.getCriteriaById(testCriteriaId1);
            assertNotNull("수정할 평가 기준이 존재해야 합니다", criteria);
            
            // 평가 기준 수정
            criteria.setCriteriaName("수정된 기술 역량");
            criteria.setDescription("수정된 설명");
            criteria.setWeight(new BigDecimal("1.5"));
            
            boolean result = criteriaDAO.updateCriteria(criteria);
            assertTrue("평가 기준 수정이 성공해야 합니다", result);
            
            // 수정 확인
            EvaluationCriteria updatedCriteria = criteriaDAO.getCriteriaById(testCriteriaId1);
            assertEquals("이름이 수정되어야 합니다", "수정된 기술 역량", updatedCriteria.getCriteriaName());
            assertTrue("가중치가 수정되어야 합니다", new BigDecimal("1.5").compareTo(updatedCriteria.getWeight()) == 0);
            
            System.out.println("✅ 평가 기준 수정 테스트 통과");
        } else {
            System.out.println("⚠️ 테스트용 평가 기준 ID가 없어 수정 테스트 생략");
        }
    }
    
    @Test
    public void test05_toggleStatus() {
        System.out.println("[TEST 5] 상태 변경 테스트");
        
        if (testCriteriaId2 > 0) {
            // 현재 상태 확인
            EvaluationCriteria criteria = criteriaDAO.getCriteriaById(testCriteriaId2);
            assertNotNull("상태를 변경할 평가 기준이 존재해야 합니다", criteria);
            
            boolean originalStatus = criteria.isActive();
            
            // 상태 변경
            boolean result = criteriaDAO.toggleCriteriaStatus(testCriteriaId2);
            assertTrue("상태 변경이 성공해야 합니다", result);
            
            // 변경 확인
            EvaluationCriteria updatedCriteria = criteriaDAO.getCriteriaById(testCriteriaId2);
            assertEquals("상태가 변경되어야 합니다", !originalStatus, updatedCriteria.isActive());
            
            System.out.println("✅ 상태 변경 테스트 통과 (상태: " + originalStatus + " → " + updatedCriteria.isActive() + ")");
        } else {
            System.out.println("⚠️ 테스트용 평가 기준 ID가 없어 상태 변경 테스트 생략");
        }
    }
    
    @Test
    public void test06_getWeightValidation() {
        System.out.println("[TEST 6] 가중치 유효성 검증 테스트");
        
        // 전체 평가 기준 조회
        List<EvaluationCriteria> allCriteria = criteriaDAO.getAllCriteria();
        assertNotNull("평가 기준 목록이 null이 아니어야 합니다", allCriteria);
        
        // 가중치가 설정되어 있는지 확인
        for (EvaluationCriteria criteria : allCriteria) {
            if (criteria.isActive()) {
                assertNotNull("가중치가 null이 아니어야 합니다", criteria.getWeight());
                assertTrue("가중치가 0보다 커야 합니다", criteria.getWeight().compareTo(BigDecimal.ZERO) > 0);
            }
        }
        
        System.out.println("✅ 가중치 유효성 검증 테스트 통과");
    }
    
    @Test
    public void test07_weightRangeTest() {
        System.out.println("[TEST 7] 가중치 범위 테스트");
        
        // 높은 가중치(1.2 이상) 평가 기준 조회
        List<EvaluationCriteria> highWeightCriteria = criteriaDAO.getCriteriaByWeightRange(
            new BigDecimal("1.2"), new BigDecimal("2.0"));
        assertNotNull("높은 가중치 평가 기준 목록이 null이 아니어야 합니다", highWeightCriteria);
        
        // 가중치 범위 확인
        for (EvaluationCriteria criteria : highWeightCriteria) {
            assertTrue("가중치가 1.2 이상이어야 합니다", 
                criteria.getWeight().compareTo(new BigDecimal("1.2")) >= 0);
            assertTrue("가중치가 2.0 이하여야 합니다", 
                criteria.getWeight().compareTo(new BigDecimal("2.0")) <= 0);
        }
        
        System.out.println("✅ 가중치 범위 테스트 통과 (높은 가중치: " + highWeightCriteria.size() + "개)");
    }
    
    @After
    public void tearDown() {
        // 테스트 데이터 정리 (선택사항)
        System.out.println("테스트 완료");
    }
} 