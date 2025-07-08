package com.example.model;

import org.junit.Before;
import org.junit.Test;
import org.junit.After;
import static org.junit.Assert.*;

import java.util.List;

/**
 * 인터뷰 질문 DAO JUnit 테스트 클래스
 * 
 * 주요 기능 테스트:
 * - CRUD 기능 (생성, 조회, 수정, 삭제)
 * - 검색 기능 (키워드 검색)
 * - 필터링 기능 (카테고리, 난이도, 조합 필터)
 * - 랜덤 추출 기능
 * - 통계 기능
 */
public class InterviewQuestionDAOTest {
    
    private InterviewQuestionDAO questionDAO;
    private int testQuestionId1 = 0;
    private int testQuestionId2 = 0;
    private int testQuestionId3 = 0;
    
    @Before
    public void setUp() throws Exception {
        questionDAO = new InterviewQuestionDAO();
        System.out.println("데이터베이스 연결 성공");
        
        // 테스트 데이터 생성
        createTestData();
    }
    
    private void createTestData() {
        // 기술 질문 생성 (일반)
        InterviewQuestion techQuestion = new InterviewQuestion();
        techQuestion.setQuestionText("소프트웨어 개발 생명주기에 대해 설명해주세요.");
        techQuestion.setCategory("기술");
        techQuestion.setDifficultyLevel(3);
        techQuestion.setExpectedAnswer("요구사항 분석, 설계, 구현, 테스트, 배포, 유지보수");
        techQuestion.setActive(true);
        
        questionDAO.addQuestion(techQuestion);
        
        // Java 초급 질문 생성
        InterviewQuestion javaBeginnerQuestion = new InterviewQuestion();
        javaBeginnerQuestion.setQuestionText("Java의 기본 데이터 타입에는 어떤 것들이 있나요?");
        javaBeginnerQuestion.setCategory("기술-Java-초급");
        javaBeginnerQuestion.setDifficultyLevel(1);
        javaBeginnerQuestion.setExpectedAnswer("byte, short, int, long, float, double, boolean, char");
        javaBeginnerQuestion.setActive(true);
        
        questionDAO.addQuestion(javaBeginnerQuestion);
        
        // Java 중급 질문 생성
        InterviewQuestion javaIntermediateQuestion = new InterviewQuestion();
        javaIntermediateQuestion.setQuestionText("Java의 컬렉션 프레임워크에 대해 설명해주세요.");
        javaIntermediateQuestion.setCategory("기술-Java-중급");
        javaIntermediateQuestion.setDifficultyLevel(3);
        javaIntermediateQuestion.setExpectedAnswer("List, Set, Map 인터페이스와 구현체들의 특징");
        javaIntermediateQuestion.setActive(true);
        
        questionDAO.addQuestion(javaIntermediateQuestion);
        
        // Python 초급 질문 생성
        InterviewQuestion pythonBeginnerQuestion = new InterviewQuestion();
        pythonBeginnerQuestion.setQuestionText("Python의 기본 데이터 타입에는 어떤 것들이 있나요?");
        pythonBeginnerQuestion.setCategory("기술-Python-초급");
        pythonBeginnerQuestion.setDifficultyLevel(1);
        pythonBeginnerQuestion.setExpectedAnswer("int, float, str, bool, list, tuple, dict, set");
        pythonBeginnerQuestion.setActive(true);
        
        questionDAO.addQuestion(pythonBeginnerQuestion);
        
        // 인성 질문 생성
        InterviewQuestion personalityQuestion = new InterviewQuestion();
        personalityQuestion.setQuestionText("팀 프로젝트에서 갈등이 발생했을 때 어떻게 해결하시나요?");
        personalityQuestion.setCategory("인성");
        personalityQuestion.setDifficultyLevel(2);
        personalityQuestion.setExpectedAnswer("경청하고 상호 존중하며 해결책을 함께 찾습니다.");
        personalityQuestion.setActive(true);
        
        questionDAO.addQuestion(personalityQuestion);
        
        // 경험 질문 생성
        InterviewQuestion experienceQuestion = new InterviewQuestion();
        experienceQuestion.setQuestionText("가장 도전적이었던 프로젝트에 대해 설명해주세요.");
        experienceQuestion.setCategory("경험");
        experienceQuestion.setDifficultyLevel(4);
        experienceQuestion.setExpectedAnswer("구체적인 문제 상황과 해결 과정을 포함한 답변");
        experienceQuestion.setActive(true);
        
        questionDAO.addQuestion(experienceQuestion);
        
        // 테스트용 ID 가져오기
        List<InterviewQuestion> allQuestions = questionDAO.getAllQuestions();
        if (allQuestions != null && allQuestions.size() >= 3) {
            int size = allQuestions.size();
            testQuestionId1 = allQuestions.get(size - 3).getId();
            testQuestionId2 = allQuestions.get(size - 2).getId();
            testQuestionId3 = allQuestions.get(size - 1).getId();
        }
    }
    
    @Test
    public void test01_createQuestions() {
        System.out.println("[TEST 1] 인터뷰 질문 생성 테스트");
        
        // 새로운 질문 생성
        InterviewQuestion newQuestion = new InterviewQuestion();
        newQuestion.setQuestionText("Spring Framework의 핵심 개념을 설명해주세요.");
        newQuestion.setCategory("기술");
        newQuestion.setDifficultyLevel(3);
        newQuestion.setExpectedAnswer("IoC, DI, AOP 등");
        newQuestion.setActive(true);
        
        boolean result = questionDAO.addQuestion(newQuestion);
        assertTrue("질문 생성이 성공해야 합니다", result);
        System.out.println("✅ 질문 생성 테스트 통과");
    }
    
    @Test
    public void test02_getAllQuestions() {
        System.out.println("[TEST 2] 전체 질문 조회 테스트");
        
        List<InterviewQuestion> allQuestions = questionDAO.getAllQuestions();
        assertNotNull("전체 질문 목록이 null이 아니어야 합니다", allQuestions);
        assertTrue("질문이 최소 3개 이상 있어야 합니다", allQuestions.size() >= 3);
        
        // 활성화된 질문만 조회
        List<InterviewQuestion> activeQuestions = questionDAO.getActiveQuestions();
        assertNotNull("활성화된 질문 목록이 null이 아니어야 합니다", activeQuestions);
        
        System.out.println("✅ 전체 질문 조회 테스트 통과 (총 " + allQuestions.size() + "개)");
    }
    
    @Test
    public void test03_getQuestionsByCategory() {
        System.out.println("[TEST 3] 카테고리별 질문 조회 테스트");
        
        // 기술 카테고리 질문 조회
        List<InterviewQuestion> techQuestions = questionDAO.getQuestionsByCategory("기술");
        assertNotNull("기술 카테고리 질문 목록이 null이 아니어야 합니다", techQuestions);
        assertTrue("기술 카테고리 질문이 최소 1개 이상 있어야 합니다", techQuestions.size() >= 1);
        
        // Java 초급 카테고리 질문 조회
        List<InterviewQuestion> javaBeginnerQuestions = questionDAO.getQuestionsByCategory("기술-Java-초급");
        assertNotNull("Java 초급 카테고리 질문 목록이 null이 아니어야 합니다", javaBeginnerQuestions);
        
        // Python 초급 카테고리 질문 조회
        List<InterviewQuestion> pythonBeginnerQuestions = questionDAO.getQuestionsByCategory("기술-Python-초급");
        assertNotNull("Python 초급 카테고리 질문 목록이 null이 아니어야 합니다", pythonBeginnerQuestions);
        
        System.out.println("✅ 카테고리별 질문 조회 테스트 통과 (기술: " + techQuestions.size() + "개, Java초급: " + javaBeginnerQuestions.size() + "개, Python초급: " + pythonBeginnerQuestions.size() + "개)");
    }
    
    @Test
    public void test04_getQuestionsByDifficulty() {
        System.out.println("[TEST 4] 난이도별 질문 조회 테스트");
        
        // 중급 난이도(3) 질문 조회
        List<InterviewQuestion> mediumQuestions = questionDAO.getQuestionsByDifficulty(3);
        assertNotNull("중급 난이도 질문 목록이 null이 아니어야 합니다", mediumQuestions);
        assertTrue("중급 난이도 질문이 최소 1개 이상 있어야 합니다", mediumQuestions.size() >= 1);
        
        // 모든 질문이 난이도 3인지 확인
        for (InterviewQuestion q : mediumQuestions) {
            assertEquals("모든 질문이 중급 난이도(3)여야 합니다", 3, q.getDifficultyLevel());
        }
        
        System.out.println("✅ 난이도별 질문 조회 테스트 통과 (중급: " + mediumQuestions.size() + "개)");
    }
    
    @Test
    public void test05_getCombinedFilter() {
        System.out.println("[TEST 5] 조합 필터 테스트");
        
        // 기술 + 중급 난이도 조합 필터
        List<InterviewQuestion> filteredQuestions = questionDAO.getQuestionsByCategoryAndDifficulty("기술", 3);
        assertNotNull("조합 필터 결과가 null이 아니어야 합니다", filteredQuestions);
        
        // Java 중급 + 중급 난이도 조합 필터
        List<InterviewQuestion> javaIntermediateQuestions = questionDAO.getQuestionsByCategoryAndDifficulty("기술-Java-중급", 3);
        assertNotNull("Java 중급 조합 필터 결과가 null이 아니어야 합니다", javaIntermediateQuestions);
        
        // 결과 검증
        for (InterviewQuestion q : javaIntermediateQuestions) {
            assertEquals("모든 질문이 Java 중급 카테고리여야 합니다", "기술-Java-중급", q.getCategory());
            assertEquals("모든 질문이 중급 난이도(3)여야 합니다", 3, q.getDifficultyLevel());
        }
        
        System.out.println("✅ 조합 필터 테스트 통과 (기술+중급: " + filteredQuestions.size() + "개, Java중급+중급: " + javaIntermediateQuestions.size() + "개)");
    }
    
    @Test
    public void test06_searchQuestions() {
        System.out.println("[TEST 6] 검색 기능 테스트");
        
        // 키워드 검색
        List<InterviewQuestion> searchResults = questionDAO.searchQuestions("Java");
        assertNotNull("검색 결과가 null이 아니어야 합니다", searchResults);
        
        // 검색 결과에 키워드가 포함되어 있는지 확인
        for (InterviewQuestion q : searchResults) {
            assertTrue("검색 결과에 키워드가 포함되어야 합니다", 
                q.getQuestionText().toLowerCase().contains("java") || 
                q.getExpectedAnswer().toLowerCase().contains("java"));
        }
        
        System.out.println("✅ 검색 기능 테스트 통과 (Java 검색: " + searchResults.size() + "개)");
    }
    
    @Test
    public void test07_getRandomQuestions() {
        System.out.println("[TEST 7] 랜덤 추출 테스트");
        
        // 랜덤 질문 3개 추출 (전체에서)
        List<InterviewQuestion> randomQuestions = questionDAO.getRandomQuestions(3, null, null);
        assertNotNull("랜덤 질문 목록이 null이 아니어야 합니다", randomQuestions);
        assertTrue("랜덤 질문이 요청한 개수 이하여야 합니다", randomQuestions.size() <= 3);
        
        // 기술 카테고리에서 랜덤 추출
        List<InterviewQuestion> techRandomQuestions = questionDAO.getRandomQuestions(2, "기술", null);
        assertNotNull("기술 카테고리 랜덤 질문 목록이 null이 아니어야 합니다", techRandomQuestions);
        
        System.out.println("✅ 랜덤 추출 테스트 통과 (전체: " + randomQuestions.size() + "개, 기술: " + techRandomQuestions.size() + "개)");
    }
    
    @Test
    public void test08_getStatistics() {
        System.out.println("[TEST 8] 통계 기능 테스트");
        
        // 카테고리별 통계
        int techCount = questionDAO.getQuestionCountByCategory("기술");
        assertTrue("기술 카테고리 질문 수가 0 이상이어야 합니다", techCount >= 0);
        
        // 전체 활성 질문 수
        int totalCount = questionDAO.getTotalActiveQuestionCount();
        assertTrue("전체 활성 질문 수가 0 이상이어야 합니다", totalCount >= 0);
        
        // 카테고리 목록 조회
        List<String> categories = questionDAO.getAllCategories();
        assertNotNull("카테고리 목록이 null이 아니어야 합니다", categories);
        
        System.out.println("✅ 통계 기능 테스트 통과 (기술: " + techCount + "개, 전체: " + totalCount + "개, 카테고리: " + categories.size() + "개)");
    }
    
    @Test
    public void test09_updateQuestion() {
        System.out.println("[TEST 9] 질문 수정 테스트");
        
        if (testQuestionId1 > 0) {
            // 질문 조회
            InterviewQuestion question = questionDAO.getQuestionById(testQuestionId1);
            assertNotNull("수정할 질문이 존재해야 합니다", question);
            
            // 질문 수정
            question.setQuestionText("수정된 질문 텍스트");
            question.setExpectedAnswer("수정된 답변");
            
            boolean result = questionDAO.updateQuestion(question);
            assertTrue("질문 수정이 성공해야 합니다", result);
            
            // 수정 확인
            InterviewQuestion updatedQuestion = questionDAO.getQuestionById(testQuestionId1);
            assertEquals("질문 텍스트가 수정되어야 합니다", "수정된 질문 텍스트", updatedQuestion.getQuestionText());
            
            System.out.println("✅ 질문 수정 테스트 통과");
        } else {
            System.out.println("⚠️ 테스트용 질문 ID가 없어 수정 테스트 생략");
        }
    }
    
    @Test
    public void test10_toggleStatus() {
        System.out.println("[TEST 10] 상태 변경 테스트");
        
        if (testQuestionId2 > 0) {
            // 현재 상태 확인
            InterviewQuestion question = questionDAO.getQuestionById(testQuestionId2);
            assertNotNull("상태를 변경할 질문이 존재해야 합니다", question);
            
            boolean originalStatus = question.isActive();
            
            // 상태 변경
            boolean result = questionDAO.toggleQuestionStatus(testQuestionId2);
            assertTrue("상태 변경이 성공해야 합니다", result);
            
            // 변경 확인
            InterviewQuestion updatedQuestion = questionDAO.getQuestionById(testQuestionId2);
            assertEquals("상태가 변경되어야 합니다", !originalStatus, updatedQuestion.isActive());
            
            System.out.println("✅ 상태 변경 테스트 통과 (상태: " + originalStatus + " → " + updatedQuestion.isActive() + ")");
        } else {
            System.out.println("⚠️ 테스트용 질문 ID가 없어 상태 변경 테스트 생략");
        }
    }
    
    @After
    public void tearDown() {
        // 테스트 데이터 정리 (선택사항)
        System.out.println("테스트 완료");
    }
}