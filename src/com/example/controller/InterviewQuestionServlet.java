package com.example.controller;

import com.example.model.InterviewQuestion;
import com.example.model.InterviewQuestionDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * 인터뷰 질문 관리 서블릿
 * 질문의 CRUD 작업과 검색 인터뷰 기능을 처리
 */
@WebServlet("/questions")
public class InterviewQuestionServlet extends HttpServlet {
    private InterviewQuestionDAO questionDAO;
    
    @Override
    public void init() throws ServletException {
        try {
            questionDAO = new InterviewQuestionDAO();
        } catch (Exception e) {
            System.err.println("[ERROR] InterviewQuestionServlet 초기화 실패: " + e.getMessage());
            e.printStackTrace();
            questionDAO = null;
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 세션 검증
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "list":
                    showQuestionList(request, response);
                    break;
                case "new":
                    showQuestionForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "detail":
                    showQuestionDetail(request, response);
                    break;
                case "delete":
                    deleteQuestion(request, response);
                    break;
                case "toggle":
                    toggleQuestionStatus(request, response);
                    break;
                case "search":
                    searchQuestions(request, response);
                    break;
                case "filter":
                    filterQuestions(request, response);
                    break;
                case "random":
                    getRandomQuestions(request, response);
                    break;
                default:
                    showQuestionList(request, response);
                    break;
            }
        } catch (Exception e) {
            System.err.println("[ERROR] GET 요청 처리 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "요청 처리 중 오류가 발생했습니다: " + e.getMessage());
            request.getRequestDispatcher("/interview_questions.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 인코딩 설정
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        // 세션 검증
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("create".equals(action)) {
                createQuestion(request, response);
            } else if ("update".equals(action)) {
                updateQuestion(request, response);
            } else {
                response.sendRedirect("questions");
            }
        } catch (Exception e) {
            System.err.println("[ERROR] POST 요청 처리 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "요청 처리 중 오류가 발생했습니다: " + e.getMessage());
            request.getRequestDispatcher("/interview_question_form.jsp").forward(request, response);
        }
    }
    
    /**
     * 질문 목록 표시
     */
    private void showQuestionList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        if (questionDAO == null) {
            request.setAttribute("questions", new java.util.ArrayList<InterviewQuestion>());
            request.setAttribute("categories", new java.util.ArrayList<String>());
            request.setAttribute("totalQuestions", 0);
            request.setAttribute("errorMessage", "데이터베이스 연결에 실패했습니다.");
            request.getRequestDispatcher("/interview_questions.jsp").forward(request, response);
            return;
        }
        
        try {
            List<InterviewQuestion> questions = questionDAO.getAllQuestions();
            List<String> categories = questionDAO.getAllCategories();
            
            // 통계 정보 계산
            int totalQuestions = questionDAO.getTotalActiveQuestionCount();
            java.util.Map<String, Integer> categoryStats = questionDAO.getCategoryStatistics();
            java.util.Map<Integer, Integer> difficultyStats = questionDAO.getDifficultyStatistics();
            
            request.setAttribute("questions", questions);
            request.setAttribute("categories", categories);
            request.setAttribute("totalQuestions", totalQuestions);
            request.setAttribute("categoryStatistics", categoryStats);
            request.setAttribute("difficultyStatistics", difficultyStats);
            
            request.getRequestDispatcher("/interview_questions.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("[ERROR] 질문 목록 조회 중 오류: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "질문 목록 조회 중 오류가 발생했습니다: " + e.getMessage());
            request.getRequestDispatcher("/interview_questions.jsp").forward(request, response);
        }
    }
    
    /**
     * 새 질문 등록 폼 표시
     */
    private void showQuestionForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        if (questionDAO == null) {
            request.setAttribute("errorMessage", "데이터베이스 연결에 실패했습니다.");
            request.getRequestDispatcher("/interview_question_form.jsp").forward(request, response);
            return;
        }
        
        try {
            List<String> categories = questionDAO.getAllCategories();
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/interview_question_form.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("[ERROR] 질문 폼 표시 중 오류: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "질문 폼을 불러오는 중 오류가 발생했습니다: " + e.getMessage());
            request.getRequestDispatcher("/interview_question_form.jsp").forward(request, response);
        }
    }
    
    /**
     * 질문 수정 폼 표시
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || questionDAO == null) {
            response.sendRedirect("questions");
            return;
        }
        
        try {
            int id = Integer.parseInt(idParam);
            InterviewQuestion question = questionDAO.getQuestionById(id);
            List<String> categories = questionDAO.getAllCategories();
            
            request.setAttribute("question", question);
            request.setAttribute("categories", categories);
            request.setAttribute("isEdit", true);
            request.getRequestDispatcher("/interview_question_form.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("[ERROR] 질문 수정 폼 표시 중 오류: " + e.getMessage());
            response.sendRedirect("questions");
        }
    }
    
    /**
     * 질문 상세 보기
     */
    private void showQuestionDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || questionDAO == null) {
            response.sendRedirect("questions");
            return;
        }
        
        try {
            int id = Integer.parseInt(idParam);
            InterviewQuestion question = questionDAO.getQuestionById(id);
            request.setAttribute("question", question);
            request.getRequestDispatcher("/interview_question_detail.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("[ERROR] 질문 상세 보기 중 오류: " + e.getMessage());
            response.sendRedirect("questions");
        }
    }
    
    /**
     * 새 질문 생성
     */
    private void createQuestion(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        if (questionDAO == null) {
            request.setAttribute("errorMessage", "데이터베이스 연결에 실패했습니다.");
            request.getRequestDispatcher("/interview_question_form.jsp").forward(request, response);
            return;
        }
        
        try {
            String questionText = request.getParameter("questionText");
            String category = request.getParameter("category");
            String difficultyParam = request.getParameter("difficulty");
            String isActiveParam = request.getParameter("isActive");
            
            if (questionText == null || questionText.trim().isEmpty() || 
                category == null || category.trim().isEmpty()) {
                request.setAttribute("errorMessage", "필수 필드를 모두 입력해주세요.");
                showQuestionForm(request, response);
                return;
            }
            
            InterviewQuestion question = new InterviewQuestion();
            question.setQuestionText(questionText);
            question.setCategory(category);
            question.setDifficultyLevel(difficultyParam != null ? Integer.parseInt(difficultyParam) : 1);
            question.setActive("true".equals(isActiveParam));
            
            boolean success = questionDAO.addQuestion(question);
            
            if (success) {
                response.sendRedirect("questions?success=create");
            } else {
                request.setAttribute("errorMessage", "질문 등록에 실패했습니다.");
                showQuestionForm(request, response);
            }
        } catch (Exception e) {
            System.err.println("[ERROR] 질문 생성 중 오류: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "질문 등록 중 오류가 발생했습니다: " + e.getMessage());
            showQuestionForm(request, response);
        }
    }
    
    /**
     * 질문 수정
     */
    private void updateQuestion(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        if (questionDAO == null) {
            response.sendRedirect("questions");
            return;
        }
        
        try {
            String idParam = request.getParameter("id");
            String questionText = request.getParameter("questionText");
            String category = request.getParameter("category");
            String difficultyParam = request.getParameter("difficulty");
            String isActiveParam = request.getParameter("isActive");
            
            if (idParam == null || questionText == null || questionText.trim().isEmpty() || 
                category == null || category.trim().isEmpty()) {
                response.sendRedirect("questions");
                return;
            }
            
            int id = Integer.parseInt(idParam);
            InterviewQuestion question = questionDAO.getQuestionById(id);
            
            if (question != null) {
                question.setQuestionText(questionText);
                question.setCategory(category);
                question.setDifficultyLevel(difficultyParam != null ? Integer.parseInt(difficultyParam) : 1);
                question.setActive("true".equals(isActiveParam));
                
                boolean success = questionDAO.updateQuestion(question);
                
                if (success) {
                    response.sendRedirect("questions?success=update");
                } else {
                    response.sendRedirect("questions?error=update");
                }
            } else {
                response.sendRedirect("questions");
            }
        } catch (Exception e) {
            System.err.println("[ERROR] 질문 수정 중 오류: " + e.getMessage());
            response.sendRedirect("questions");
        }
    }
    
    /**
     * 질문 삭제
     */
    private void deleteQuestion(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || questionDAO == null) {
            response.sendRedirect("questions");
            return;
        }
        
        try {
            int id = Integer.parseInt(idParam);
            boolean success = questionDAO.deleteQuestion(id);
            
            if (success) {
                response.sendRedirect("questions?success=delete");
            } else {
                response.sendRedirect("questions?error=delete");
            }
        } catch (Exception e) {
            System.err.println("[ERROR] 질문 삭제 중 오류: " + e.getMessage());
            response.sendRedirect("questions");
        }
    }
    
    /**
     * 질문 활성화/비활성화 토글
     */
    private void toggleQuestionStatus(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || questionDAO == null) {
            response.sendRedirect("questions");
            return;
        }
        
        try {
            int id = Integer.parseInt(idParam);
            boolean success = questionDAO.toggleQuestionStatus(id);
            
            if (success) {
                response.sendRedirect("questions?success=toggle");
            } else {
                response.sendRedirect("questions?error=toggle");
            }
        } catch (Exception e) {
            System.err.println("[ERROR] 질문 상태 토글 중 오류: " + e.getMessage());
            response.sendRedirect("questions");
        }
    }
    
    /**
     * 질문 검색
     */
    private void searchQuestions(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        if (keyword == null || keyword.trim().isEmpty() || questionDAO == null) {
            showQuestionList(request, response);
            return;
        }
        
        try {
            // 검색된 질문 목록
            List<InterviewQuestion> questions = questionDAO.searchQuestions(keyword);
            List<String> categories = questionDAO.getAllCategories();
            
            // 전체 통계 정보 (카테고리 버튼들을 유지하기 위해)
            int totalQuestions = questionDAO.getTotalActiveQuestionCount();
            java.util.Map<String, Integer> categoryStats = questionDAO.getCategoryStatistics();
            java.util.Map<Integer, Integer> difficultyStats = questionDAO.getDifficultyStatistics();
            
            // 검색 결과 설정
            request.setAttribute("questions", questions);
            request.setAttribute("categories", categories);
            request.setAttribute("searchKeyword", keyword);
            request.setAttribute("searchResultCount", questions.size());
            
            // 전체 통계 정보 설정 (버튼 유지를 위해)
            request.setAttribute("totalQuestions", totalQuestions);
            request.setAttribute("categoryStatistics", categoryStats);
            request.setAttribute("difficultyStatistics", difficultyStats);
            
            request.getRequestDispatcher("/interview_questions.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("[ERROR] 질문 검색 중 오류: " + e.getMessage());
            showQuestionList(request, response);
        }
    }
    
    /**
     * 질문 필터링 (카테고리 + 난이도 복합 필터링 지원)
     */
    private void filterQuestions(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        if (questionDAO == null) {
            showQuestionList(request, response);
            return;
        }
        
        // 필터 파라미터 가져오기
        String category = request.getParameter("category");
        String difficultyParam = request.getParameter("difficulty");
        
        // 빈 값들을 null로 처리
        if (category != null && (category.trim().isEmpty() || "all".equals(category))) {
            category = null;
        }
        
        Integer difficulty = null;
        if (difficultyParam != null && !difficultyParam.trim().isEmpty() && !"all".equals(difficultyParam)) {
            try {
                difficulty = Integer.parseInt(difficultyParam);
            } catch (NumberFormatException e) {
                difficulty = null;
            }
        }
        
        // 두 필터 모두 null이면 전체 목록 표시
        if (category == null && difficulty == null) {
            showQuestionList(request, response);
            return;
        }
        
        try {
            // 복합 필터링된 질문 목록
            List<InterviewQuestion> questions = questionDAO.getQuestionsByCategoryAndDifficulty(category, difficulty);
            List<String> categories = questionDAO.getAllCategories();
            
            // 전체 통계 정보 (카테고리 버튼들을 유지하기 위해)
            int totalQuestions = questionDAO.getTotalActiveQuestionCount();
            java.util.Map<String, Integer> categoryStats = questionDAO.getCategoryStatistics();
            java.util.Map<Integer, Integer> difficultyStats = questionDAO.getDifficultyStatistics();
            
            // 필터링 결과 설정
            request.setAttribute("questions", questions);
            request.setAttribute("categories", categories);
            request.setAttribute("filterCategory", category);
            request.setAttribute("filterDifficulty", difficulty);
            request.setAttribute("filterResultCount", questions.size());
            
            // 전체 통계 정보 설정 (버튼 유지를 위해)
            request.setAttribute("totalQuestions", totalQuestions);
            request.setAttribute("categoryStatistics", categoryStats);
            request.setAttribute("difficultyStatistics", difficultyStats);
            
            request.getRequestDispatcher("/interview_questions.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("[ERROR] 질문 필터링 중 오류: " + e.getMessage());
            showQuestionList(request, response);
        }
    }
    
    /**
     * 랜덤 질문 조회
     */
    private void getRandomQuestions(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String countParam = request.getParameter("count");
        int count = 5; // 기본값
        
        if (countParam != null) {
            try {
                count = Integer.parseInt(countParam);
                if (count <= 0 || count > 20) {
                    count = 5;
                }
            } catch (NumberFormatException e) {
                count = 5;
            }
        }
        
        if (questionDAO == null) {
            showQuestionList(request, response);
            return;
        }
        
        try {
            // 랜덤 질문 목록
            List<InterviewQuestion> questions = questionDAO.getRandomQuestions(count, null, null);
            List<String> categories = questionDAO.getAllCategories();
            
            // 전체 통계 정보 (카테고리 버튼들을 유지하기 위해)
            int totalQuestions = questionDAO.getTotalActiveQuestionCount();
            java.util.Map<String, Integer> categoryStats = questionDAO.getCategoryStatistics();
            java.util.Map<Integer, Integer> difficultyStats = questionDAO.getDifficultyStatistics();
            
            // 랜덤 결과 설정
            request.setAttribute("questions", questions);
            request.setAttribute("categories", categories);
            request.setAttribute("randomQuestions", true);
            request.setAttribute("randomLimit", count);
            
            // 전체 통계 정보 설정 (버튼 유지를 위해)
            request.setAttribute("totalQuestions", totalQuestions);
            request.setAttribute("categoryStatistics", categoryStats);
            request.setAttribute("difficultyStatistics", difficultyStats);
            
            request.getRequestDispatcher("/interview_questions.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("[ERROR] 랜덤 질문 조회 중 오류: " + e.getMessage());
            showQuestionList(request, response);
        }
    }
} 