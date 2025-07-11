package com.example.controller;

import com.example.model.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * 인터뷰 결과 관리를 위한 서블릿 컨트롤러
 */
@WebServlet("/results/*")
public class InterviewResultServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private InterviewResultDAO resultDAO;
    private CandidateDAO candidateDAO;
    private InterviewScheduleDAO scheduleDAO = new InterviewScheduleDAO();
    private InterviewQuestionDAO questionDAO;
    private InterviewResultQuestionDAO resultQuestionDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        try {
            resultDAO = new InterviewResultDAO();
            candidateDAO = new CandidateDAO();
            questionDAO = new InterviewQuestionDAO();
            resultQuestionDAO = new InterviewResultQuestionDAO();
        } catch (Exception e) {
            e.printStackTrace();
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
        
        String requestURI = request.getRequestURI();
        String contextPath = request.getContextPath();
        String pathInfo = request.getPathInfo();
        String action = request.getParameter("action");
        
        System.out.println("🔍 [InterviewResultServlet-GET] ================================");
        System.out.println("🔍 [InterviewResultServlet-GET] 요청 URI: " + requestURI);
        System.out.println("🔍 [InterviewResultServlet-GET] 컨텍스트 경로: " + contextPath);
        System.out.println("🔍 [InterviewResultServlet-GET] PathInfo: " + pathInfo);
        System.out.println("🔍 [InterviewResultServlet-GET] Action 파라미터: " + action);
        
        // action 파라미터가 있으면 우선 사용, 없으면 pathInfo 사용
        String targetAction = null;
        if (action != null && !action.trim().isEmpty()) {
            targetAction = "/" + action;
        } else if (pathInfo != null && !pathInfo.equals("/")) {
            targetAction = pathInfo;
        } else {
            targetAction = "/list";
        }
        
        try {
            switch (targetAction) {
                case "/list":
                    System.out.println("📋 [InterviewResultServlet-GET] /list 경로 처리");
                    showResultList(request, response);
                    break;
                case "/detail":
                    System.out.println("👁️ [InterviewResultServlet-GET] /detail 경로 처리");
                    showResultDetail(request, response);
                    break;
                case "/add":
                case "/new":
                    System.out.println("➕ [InterviewResultServlet-GET] /add 경로 처리 - 결과등록 폼");
                    showResultForm(request, response);
                    break;
                case "/edit":
                    System.out.println("✏️ [InterviewResultServlet-GET] /edit 경로 처리");
                    editResult(request, response);
                    break;
                case "/delete":
                    System.out.println("🗑️ [InterviewResultServlet-GET] /delete 경로 처리");
                    deleteResult(request, response);
                    break;
                case "/search":
                    System.out.println("🔍 [InterviewResultServlet-GET] /search 경로 처리");
                    searchResults(request, response);
                    break;
                case "/filter":
                    System.out.println("🔽 [InterviewResultServlet-GET] /filter 경로 처리");
                    filterResults(request, response);
                    break;
                default:
                    System.out.println("❓ [InterviewResultServlet-GET] 기본 경로 처리: " + targetAction);
                    showResultList(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "오류가 발생했습니다: " + e.getMessage());
            System.out.println("📄 [InterviewResultServlet] doGet catch - interview_results.jsp로 포워딩 (절대경로)");
            request.getRequestDispatcher("/interview_results.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 세션 검증
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String pathInfo = request.getPathInfo();
        String action = request.getParameter("action");
        
        // action 파라미터가 있으면 우선 사용, 없으면 pathInfo 사용
        String targetAction = null;
        if (action != null && !action.trim().isEmpty()) {
            targetAction = "/" + action;
        } else if (pathInfo != null && !pathInfo.equals("/")) {
            targetAction = pathInfo;
        } else {
            targetAction = "/list";
        }
        
        try {
            switch (targetAction) {
                case "/add":
                case "/new":
                    createResult(request, response);
                    break;
                case "/edit":
                    updateResult(request, response);
                    break;
                default:
                    showResultList(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "오류가 발생했습니다: " + e.getMessage());
            System.out.println("📄 [InterviewResultServlet] doPost catch - interview_results.jsp로 포워딩 (절대경로)");
            request.getRequestDispatcher("/interview_results.jsp").forward(request, response);
        }
    }
    
    /**
     * 인터뷰 결과 목록 표시
     */
    private void showResultList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        if (resultDAO == null) {
            request.setAttribute("results", new java.util.ArrayList<InterviewResult>());
            request.setAttribute("errorMessage", "데이터베이스 연결에 실패했습니다.");
            request.getRequestDispatcher("/interview_results.jsp").forward(request, response);
            return;
        }
        
        try {
            List<InterviewResult> results = resultDAO.getAllResults();
            
            Map<String, Integer> statusStats = resultDAO.getResultStatusStats();
            
            BigDecimal averageScore = resultDAO.getAverageOverallScore();
            
            // 통계 정보 설정
            request.setAttribute("results", results);
            request.setAttribute("statusStats", statusStats);
            request.setAttribute("averageScore", averageScore);
            request.setAttribute("totalResults", results.size());
            
            // 상태별 개수 설정
            request.setAttribute("pendingCount", statusStats.getOrDefault("pending", 0));
            request.setAttribute("passCount", statusStats.getOrDefault("pass", 0));
            request.setAttribute("failCount", statusStats.getOrDefault("fail", 0));
            request.setAttribute("holdCount", statusStats.getOrDefault("hold", 0));
            
            System.out.println("📄 [InterviewResultServlet] interview_results.jsp로 포워딩 (절대경로)");
            request.getRequestDispatcher("/interview_results.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "데이터 조회 중 오류가 발생했습니다: " + e.getMessage());
            System.out.println("📄 [InterviewResultServlet] 에러 후 interview_results.jsp로 포워딩 (절대경로)");
            request.getRequestDispatcher("/interview_results.jsp").forward(request, response);
        }
    }
    
    /**
     * 인터뷰 결과 상세 표시
     */
    private void showResultDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect("results");
            return;
        }
        
        try {
            int id = Integer.parseInt(idParam);
            InterviewResult result = resultDAO.getResultById(id);
            
            if (result == null) {
                request.setAttribute("errorMessage", "해당 인터뷰 결과를 찾을 수 없습니다.");
                showResultList(request, response);
                return;
            }
            
            request.setAttribute("result", result);
            System.out.println("📄 [InterviewResultServlet] interview_result_detail.jsp로 포워딩 (절대경로)");
            request.getRequestDispatcher("/interview_result_detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "잘못된 결과 ID입니다.");
            showResultList(request, response);
        }
    }
    
    /**
     * 인터뷰 결과 등록 폼 표시
     */
    private void showResultForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("📄 [InterviewResultServlet] showResultForm 호출");
        
        // 지원자 목록 가져오기
        List<Candidate> candidates = candidateDAO.getAllCandidates();
        request.setAttribute("candidates", candidates);
        
        // 인터뷰 질문 목록 가져오기
        List<InterviewQuestion> questions = questionDAO.getAllQuestions();
        request.setAttribute("questions", questions);
        
        // 선택된 지원자 ID가 있는 경우
        String candidateIdParam = request.getParameter("candidateId");
        if (candidateIdParam != null && !candidateIdParam.trim().isEmpty()) {
            request.setAttribute("selectedCandidateId", candidateIdParam);
            System.out.println("🔍 [InterviewResultServlet] 선택된 지원자 ID: " + candidateIdParam);
        }
        
        // 스케줄 ID가 있는 경우
        String scheduleIdParam = request.getParameter("scheduleId");
        if (scheduleIdParam != null && !scheduleIdParam.trim().isEmpty()) {
            try {
                int scheduleId = Integer.parseInt(scheduleIdParam);
                InterviewSchedule schedule = scheduleDAO.getScheduleById(scheduleId);
                if (schedule != null) {
                    request.setAttribute("schedule", schedule);
                    request.setAttribute("selectedCandidateId", String.valueOf(schedule.getCandidateId()));
                    System.out.println("🔍 [InterviewResultServlet] 스케줄 ID: " + scheduleId + ", 지원자: " + schedule.getCandidateName());
                }
            } catch (Exception e) { 
                System.out.println("❌ [InterviewResultServlet] 스케줄 조회 오류: " + e.getMessage());
            }
        }
        
        System.out.println("📄 [InterviewResultServlet] interview_result_form.jsp로 포워딩 (절대경로)");
        request.getRequestDispatcher("/interview_result_form.jsp").forward(request, response);
    }
    
    /**
     * 인터뷰 결과 수정 폼 표시
     */
    private void editResult(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        String scheduleIdParam = request.getParameter("scheduleId");
        InterviewResult result = null;
        try {
            if (idParam != null && !idParam.trim().isEmpty()) {
                int id = Integer.parseInt(idParam);
                result = resultDAO.getResultById(id);
            } else if (scheduleIdParam != null && !scheduleIdParam.trim().isEmpty()) {
                int scheduleId = Integer.parseInt(scheduleIdParam);
                result = resultDAO.getResultByScheduleId(scheduleId);
            }
            if (result == null) {
                request.setAttribute("errorMessage", "해당 인터뷰 결과를 찾을 수 없습니다.");
                showResultList(request, response);
                return;
            }
            // 지원자 목록 가져오기
            List<Candidate> candidates = candidateDAO.getAllCandidates();
            request.setAttribute("result", result);
            request.setAttribute("candidates", candidates);
            request.setAttribute("id", result.getId());
            
            // 인터뷰 질문 목록 가져오기
            List<InterviewQuestion> questions = questionDAO.getAllQuestions();
            request.setAttribute("questions", questions);
            
            // 기존 선택된 질문들 가져오기
            List<Integer> selectedQuestionIds = resultQuestionDAO.getSelectedQuestionIds(result.getId());
            request.setAttribute("selectedQuestionIds", selectedQuestionIds);
            
            // 선택된 질문이 있는 카테고리 목록 가져오기
            List<String> selectedCategories = resultQuestionDAO.getCategoriesWithSelectedQuestions(result.getId());
            request.setAttribute("selectedCategories", selectedCategories);
            
            System.out.println("📄 [InterviewResultServlet] interview_result_form.jsp로 포워딩 (절대경로)");
            request.getRequestDispatcher("/interview_result_form.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "잘못된 결과 ID 또는 일정 ID입니다.");
            showResultList(request, response);
        }
    }
    
    /**
     * 인터뷰 결과 생성
     */
    private void createResult(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        System.out.println("🚀 [DEBUG] createResult 메소드 시작");
        try {
            System.out.println("📝 [DEBUG] 폼 데이터 추출 중...");
            InterviewResult result = extractResultFromRequest(request);
            System.out.println("✅ [DEBUG] 추출된 데이터: 지원자ID=" + result.getCandidateId() + ", 면접관=" + result.getInterviewerName() + ", 결과상태=" + result.getResultStatus());
            
            System.out.println("💾 [DEBUG] DB 저장 시도 중...");
            boolean success = resultDAO.addResult(result);
            System.out.println("📊 [DEBUG] DB 저장 결과: " + (success ? "성공" : "실패"));
            
            // 선택된 질문들 저장
            if (success && result.getId() > 0) {
                List<Integer> selectedQuestionIds = extractSelectedQuestionIds(request);
                if (!selectedQuestionIds.isEmpty()) {
                    resultQuestionDAO.saveSelectedQuestions(result.getId(), selectedQuestionIds);
                }
                
                // 2차면접 결과 저장 시 면접완료 처리 (기존 "2차 면접"과 새로운 "2차면접" 모두 지원)
                if ("2차면접".equals(result.getInterviewType()) || "2차 면접".equals(result.getInterviewType())) {
                    try {
                        boolean statusUpdated = candidateDAO.updateCandidateStatus(result.getCandidateId(), "면접완료");
                        System.out.println("✅ [DEBUG] 2차면접 완료 - 지원자 상태 업데이트: " + 
                                          (statusUpdated ? "성공" : "실패") + 
                                          " (지원자 ID: " + result.getCandidateId() + ")");
                    } catch (Exception e) {
                        System.out.println("❌ [DEBUG] 2차면접 완료 처리 중 오류: " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            }
            
            String from = request.getParameter("from");
            String contextPath = request.getContextPath();
            
            if (success) {
                request.setAttribute("successMessage", "인터뷰 결과가 성공적으로 등록되었습니다.");
                if (from != null && from.equals("candidates")) {
                    response.sendRedirect(contextPath + "/candidates");
                    return;
                } else {
                    response.sendRedirect(contextPath + "/results");
                    return;
                }
            } else {
                if (from != null && from.equals("candidates")) {
                    response.sendRedirect(contextPath + "/candidates?error=duplicate");
                    return;
                } else {
                    request.setAttribute("errorMessage", "이미 동일한 지원자, 면접일, 면접관 조합의 결과가 등록되어 있습니다.");
                    showResultForm(request, response);
                    return;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "데이터 처리 중 오류가 발생했습니다: " + e.getMessage());
            showResultForm(request, response);
        }
    }
    
    /**
     * 인터뷰 결과 수정
     */
    private void updateResult(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            InterviewResult result = extractResultFromRequest(request);
            boolean success = resultDAO.updateResult(result);
            
            // 선택된 질문들 업데이트
            if (success) {
                List<Integer> selectedQuestionIds = extractSelectedQuestionIds(request);
                resultQuestionDAO.saveSelectedQuestions(result.getId(), selectedQuestionIds);
                
                // 2차면접 결과 수정 시 면접완료 처리 (기존 "2차 면접"과 새로운 "2차면접" 모두 지원)
                if ("2차면접".equals(result.getInterviewType()) || "2차 면접".equals(result.getInterviewType())) {
                    try {
                        boolean statusUpdated = candidateDAO.updateCandidateStatus(result.getCandidateId(), "면접완료");
                        System.out.println("✅ [DEBUG] 2차면접 수정 완료 - 지원자 상태 업데이트: " + 
                                          (statusUpdated ? "성공" : "실패") + 
                                          " (지원자 ID: " + result.getCandidateId() + ")");
                    } catch (Exception e) {
                        System.out.println("❌ [DEBUG] 2차면접 수정 완료 처리 중 오류: " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            }
            
            String from = request.getParameter("from");
            String contextPath = request.getContextPath();
            
            if (success) {
                request.setAttribute("successMessage", "면접 결과가 성공적으로 수정되었습니다.");
                if (from != null && from.equals("candidates")) {
                    response.sendRedirect(contextPath + "/candidates");
                    return;
                } else {
                    response.sendRedirect(contextPath + "/results");
                    return;
                }
            } else {
                request.setAttribute("errorMessage", "면접 결과 수정에 실패했습니다.");
                showResultForm(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "면접 결과 수정 중 오류가 발생했습니다.");
            showResultForm(request, response);
        }
    }
    
    /**
     * 인터뷰 결과 삭제
     */
    private void deleteResult(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect("results");
            return;
        }
        
        try {
            int id = Integer.parseInt(idParam);
            
            if (resultDAO.deleteResult(id)) {
                request.setAttribute("successMessage", "인터뷰 결과가 성공적으로 삭제되었습니다.");
            } else {
                request.setAttribute("errorMessage", "인터뷰 결과 삭제에 실패했습니다.");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "잘못된 결과 ID입니다.");
        }
        
        showResultList(request, response);
    }
    
    /**
     * 인터뷰 결과 검색
     */
    private void searchResults(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        if (keyword == null || keyword.trim().isEmpty()) {
            showResultList(request, response);
            return;
        }
        
        List<InterviewResult> results = resultDAO.searchResults(keyword.trim());
        Map<String, Integer> statusStats = resultDAO.getResultStatusStats();
        BigDecimal averageScore = resultDAO.getAverageOverallScore();
        
        request.setAttribute("results", results);
        request.setAttribute("statusStats", statusStats);
        request.setAttribute("averageScore", averageScore);
        request.setAttribute("searchKeyword", keyword);
        request.setAttribute("searchResultCount", results.size());
        request.setAttribute("totalResults", results.size());
        
        System.out.println("📄 [InterviewResultServlet] searchResults - interview_results.jsp로 포워딩 (절대경로)");
        request.getRequestDispatcher("/interview_results.jsp").forward(request, response);
    }
    
    /**
     * 인터뷰 결과 필터링
     */
    private void filterResults(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String status = request.getParameter("status");
        String scoreRange = request.getParameter("scoreRange");
        
        List<InterviewResult> results;
        
        if ((status == null || status.equals("all")) && (scoreRange == null || scoreRange.equals("all"))) {
            results = resultDAO.getAllResults();
        } else {
            results = resultDAO.getAllResults(); // 임시로 전체 조회
        }
        
        Map<String, Integer> statusStats = resultDAO.getResultStatusStats();
        BigDecimal averageScore = resultDAO.getAverageOverallScore();
        
        request.setAttribute("results", results);
        request.setAttribute("statusStats", statusStats);
        request.setAttribute("averageScore", averageScore);
        request.setAttribute("filterStatus", status);
        request.setAttribute("filterScoreRange", scoreRange);
        request.setAttribute("filterResultCount", results.size());
        request.setAttribute("totalResults", results.size());
        
        System.out.println("📄 [InterviewResultServlet] filterResults - interview_results.jsp로 포워딩 (절대경로)");
        request.getRequestDispatcher("/interview_results.jsp").forward(request, response);
    }
    
    /**
     * 요청에서 InterviewResult 객체 추출
     */
    private InterviewResult extractResultFromRequest(HttpServletRequest request) throws Exception {
        InterviewResult result = new InterviewResult();
        
        // 기본 정보
        String candidateIdStr = request.getParameter("candidateId");
        if (candidateIdStr == null || candidateIdStr.trim().isEmpty()) {
            throw new IllegalArgumentException("지원자를 선택해주세요.");
        }
        result.setCandidateId(Integer.parseInt(candidateIdStr));
        
        String interviewerName = request.getParameter("interviewerName");
        if (interviewerName == null || interviewerName.trim().isEmpty()) {
            throw new IllegalArgumentException("면접관 이름을 입력해주세요.");
        }
        result.setInterviewerName(interviewerName.trim());
        
        String interviewDateStr = request.getParameter("interviewDate");
        if (interviewDateStr == null || interviewDateStr.trim().isEmpty()) {
            throw new IllegalArgumentException("면접 날짜를 선택해주세요.");
        }
        
        // HTML5 datetime-local 형식에서 날짜 부분만 추출 (yyyy-MM-ddTHH:mm → yyyy-MM-dd)
        try {
            String dateOnly = interviewDateStr.split("T")[0]; // T 기준으로 분할하여 날짜 부분만 사용
            Date sqlDate = Date.valueOf(dateOnly); // yyyy-MM-dd 형식으로 변환
            result.setInterviewDate(sqlDate);
        } catch (Exception e) {
            throw new IllegalArgumentException("잘못된 날짜 형식입니다: " + interviewDateStr);
        }
        
        String interviewType = request.getParameter("interviewType");
        result.setInterviewType(interviewType != null ? interviewType : "기술면접");
        
        // 점수들 (선택사항)
        String techScoreStr = request.getParameter("technicalScore");
        if (techScoreStr != null && !techScoreStr.trim().isEmpty()) {
            result.setTechnicalScore(Integer.parseInt(techScoreStr));
        }
        
        String commScoreStr = request.getParameter("communicationScore");
        if (commScoreStr != null && !commScoreStr.trim().isEmpty()) {
            result.setCommunicationScore(Integer.parseInt(commScoreStr));
        }
        
        String problemScoreStr = request.getParameter("problemSolvingScore");
        if (problemScoreStr != null && !problemScoreStr.trim().isEmpty()) {
            result.setProblemSolvingScore(Integer.parseInt(problemScoreStr));
        }
        
        String attitudeScoreStr = request.getParameter("attitudeScore");
        if (attitudeScoreStr != null && !attitudeScoreStr.trim().isEmpty()) {
            result.setAttitudeScore(Integer.parseInt(attitudeScoreStr));
        }
        
        String overallScoreStr = request.getParameter("overallScore");
        if (overallScoreStr != null && !overallScoreStr.trim().isEmpty()) {
            result.setOverallScore(new BigDecimal(overallScoreStr));
        }
        
        // 평가 내용
        result.setStrengths(request.getParameter("strengths"));
        result.setWeaknesses(request.getParameter("weaknesses"));
        result.setDetailedFeedback(request.getParameter("detailedFeedback"));
        result.setImprovementSuggestions(request.getParameter("improvementSuggestions"));
        
        // 최종 결과
        String resultStatus = request.getParameter("resultStatus");
        result.setResultStatus(resultStatus != null && !resultStatus.trim().isEmpty() ? resultStatus : "pending");
        
        String hireRecommendationStr = request.getParameter("hireRecommendation");
        // 빈 문자열이나 null인 경우 "no"로 설정
        if (hireRecommendationStr == null || hireRecommendationStr.trim().isEmpty()) {
            result.setHireRecommendation("no");
        } else {
            // "yes" 또는 "no"만 허용, 그 외는 "no"로 설정
            String cleanValue = hireRecommendationStr.trim().toLowerCase();
            result.setHireRecommendation("yes".equals(cleanValue) ? "yes" : "no");
        }
        
        result.setNextStep(request.getParameter("nextStep"));
        
        // 스케줄 ID (선택사항)
        String scheduleIdStr = request.getParameter("scheduleId");
        if (scheduleIdStr != null && !scheduleIdStr.trim().isEmpty()) {
            result.setScheduleId(Integer.parseInt(scheduleIdStr));
        }
        
        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.trim().isEmpty() && !idParam.equals("0")) {
            result.setId(Integer.parseInt(idParam));
            
            // 수정 모드인 경우 기존 schedule_id를 유지 (scheduleId 파라미터가 없으면)
            if (scheduleIdStr == null || scheduleIdStr.trim().isEmpty()) {
                try {
                    InterviewResultDAO dao = new InterviewResultDAO();
                    InterviewResult existingResult = dao.getResultById(Integer.parseInt(idParam));
                    if (existingResult != null && existingResult.getScheduleId() > 0) {
                        result.setScheduleId(existingResult.getScheduleId());
                        System.out.println("🔗 [InterviewResultServlet] 기존 schedule_id 유지: " + existingResult.getScheduleId());
                    }
                } catch (Exception e) {
                    System.err.println("⚠️ [InterviewResultServlet] 기존 schedule_id 조회 중 오류: " + e.getMessage());
                }
            }
        } else {
            // scheduleId로 InterviewResult를 찾아서 id 세팅
            String scheduleIdParam = request.getParameter("scheduleId");
            if (scheduleIdParam != null && !scheduleIdParam.trim().isEmpty()) {
                InterviewResultDAO dao = new InterviewResultDAO();
                InterviewResult dbResult = dao.getResultByScheduleId(Integer.parseInt(scheduleIdParam));
                if (dbResult != null) result.setId(dbResult.getId());
            }
        }
        
        return result;
    }
    
    /**
     * 요청에서 선택된 질문 ID 목록 추출
     */
    private List<Integer> extractSelectedQuestionIds(HttpServletRequest request) {
        List<Integer> selectedIds = new ArrayList<>();
        String[] questionIds = request.getParameterValues("selectedQuestions");
        
        if (questionIds != null) {
            for (String questionId : questionIds) {
                try {
                    selectedIds.add(Integer.parseInt(questionId));
                } catch (NumberFormatException e) {
                    // 잘못된 형식의 ID는 무시
                    System.err.println("Invalid question ID: " + questionId);
                }
            }
        }
        
        return selectedIds;
    }
}
