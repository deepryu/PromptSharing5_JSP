package com.example.controller;

import com.example.model.Interviewer;
import com.example.model.InterviewerDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/interviewers")
public class InterviewerServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private InterviewerDAO interviewerDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        try {
            interviewerDAO = new InterviewerDAO();
        } catch (Exception e) {
            System.err.println("InterviewerServlet 초기화 실패: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 세션 검증 [[memory:5133392728938285816]]
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        try {
            switch (action) {
                case "list":
                    showInterviewerList(request, response);
                    break;
                case "detail":
                    showInterviewerDetail(request, response);
                    break;
                case "new":
                    showInterviewerForm(request, response);
                    break;
                case "edit":
                    editInterviewer(request, response);
                    break;
                case "delete":
                    deleteInterviewer(request, response);
                    break;
                case "search":
                    searchInterviewers(request, response);
                    break;
                case "filter":
                    filterInterviewers(request, response);
                    break;
                default:
                    showInterviewerList(request, response);
                    break;
            }
        } catch (Exception e) {
            System.err.println("InterviewerServlet GET 오류: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "시스템 오류가 발생했습니다: " + e.getMessage());
            showInterviewerList(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        // 세션 검증
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            switch (action) {
                case "create":
                    createInterviewer(request, response);
                    break;
                case "update":
                    updateInterviewer(request, response);
                    break;
                default:
                    showInterviewerList(request, response);
                    break;
            }
        } catch (Exception e) {
            System.err.println("InterviewerServlet POST 오류: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "오류가 발생했습니다: " + e.getMessage());
            showInterviewerList(request, response);
        }
    }
    
    /**
     * 면접관 목록 표시
     */
    private void showInterviewerList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 세션에서 성공 메시지 처리
        HttpSession session = request.getSession(false);
        if (session != null) {
            String successMessage = (String) session.getAttribute("successMessage");
            if (successMessage != null) {
                request.setAttribute("successMessage", successMessage);
                session.removeAttribute("successMessage");
            }
        }
        
        if (interviewerDAO == null) {
            request.setAttribute("interviewers", new java.util.ArrayList<Interviewer>());
            request.setAttribute("errorMessage", "데이터베이스 연결에 실패했습니다.");
            request.getRequestDispatcher("interviewer_list.jsp").forward(request, response);
            return;
        }
        
        try {
            List<Interviewer> interviewers = interviewerDAO.getAllInterviewers();
            Map<String, Integer> stats = interviewerDAO.getInterviewerStats();
            
            // 통계 정보 설정
            request.setAttribute("interviewers", interviewers);
            request.setAttribute("stats", stats);
            request.setAttribute("totalInterviewers", interviewers.size());
            
            // 상태별 개수 설정
            request.setAttribute("activeCount", stats.getOrDefault("active", 0));
            request.setAttribute("inactiveCount", stats.getOrDefault("total", 0) - stats.getOrDefault("active", 0));
            
            request.getRequestDispatcher("interviewer_list.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "데이터 조회 중 오류가 발생했습니다: " + e.getMessage());
            request.getRequestDispatcher("interviewer_list.jsp").forward(request, response);
        }
    }
    
    /**
     * 면접관 상세 표시
     */
    private void showInterviewerDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect("interviewers");
            return;
        }
        
        try {
            int id = Integer.parseInt(idParam);
            Interviewer interviewer = interviewerDAO.getInterviewerById(id);
            
            if (interviewer == null) {
                request.setAttribute("errorMessage", "해당 면접관을 찾을 수 없습니다.");
                showInterviewerList(request, response);
                return;
            }
            
            request.setAttribute("interviewer", interviewer);
            request.getRequestDispatcher("interviewer_detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "잘못된 면접관 ID입니다.");
            showInterviewerList(request, response);
        }
    }
    
    /**
     * 면접관 등록 폼 표시
     */
    private void showInterviewerForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.getRequestDispatcher("interviewer_form.jsp").forward(request, response);
    }
    
    /**
     * 면접관 편집 폼 표시
     */
    private void editInterviewer(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect("interviewers");
            return;
        }
        
        try {
            int id = Integer.parseInt(idParam);
            Interviewer interviewer = interviewerDAO.getInterviewerById(id);
            
            if (interviewer == null) {
                request.setAttribute("errorMessage", "해당 면접관을 찾을 수 없습니다.");
                showInterviewerList(request, response);
                return;
            }
            
            request.setAttribute("interviewer", interviewer);
            request.getRequestDispatcher("interviewer_form.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "잘못된 면접관 ID입니다.");
            showInterviewerList(request, response);
        }
    }
    
    /**
     * 면접관 생성
     */
    private void createInterviewer(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            Interviewer interviewer = extractInterviewerFromRequest(request);
            
            // 이메일 중복 검사
            if (interviewerDAO.getInterviewerByEmail(interviewer.getEmail()) != null) {
                request.setAttribute("errorMessage", "이미 등록된 이메일입니다.");
                request.setAttribute("interviewer", interviewer);
                showInterviewerForm(request, response);
                return;
            }
            
            boolean success = interviewerDAO.addInterviewer(interviewer);
            
            if (success) {
                HttpSession session = request.getSession();
                session.setAttribute("successMessage", "면접관이 성공적으로 등록되었습니다.");
                response.sendRedirect("interviewers");
            } else {
                request.setAttribute("errorMessage", "면접관 등록에 실패했습니다.");
                request.setAttribute("interviewer", interviewer);
                showInterviewerForm(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "데이터 처리 중 오류가 발생했습니다: " + e.getMessage());
            showInterviewerForm(request, response);
        }
    }
    
    /**
     * 면접관 수정
     */
    private void updateInterviewer(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.trim().isEmpty()) {
                request.setAttribute("errorMessage", "면접관 ID가 필요합니다.");
                showInterviewerList(request, response);
                return;
            }
            
            int id = Integer.parseInt(idParam);
            Interviewer interviewer = extractInterviewerFromRequest(request);
            interviewer.setId(id);
            
            // 이메일 중복 검사 (자신 제외)
            Interviewer existingInterviewer = interviewerDAO.getInterviewerByEmail(interviewer.getEmail());
            if (existingInterviewer != null && !existingInterviewer.getId().equals(id)) {
                request.setAttribute("errorMessage", "이미 사용 중인 이메일입니다.");
                request.setAttribute("interviewer", interviewer);
                editInterviewer(request, response);
                return;
            }
            
            if (interviewerDAO.updateInterviewer(interviewer)) {
                HttpSession session = request.getSession();
                session.setAttribute("successMessage", "면접관 정보가 성공적으로 수정되었습니다.");
                response.sendRedirect("interviewers");
            } else {
                request.setAttribute("errorMessage", "면접관 정보 수정에 실패했습니다.");
                request.setAttribute("interviewer", interviewer);
                editInterviewer(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "데이터 처리 중 오류가 발생했습니다: " + e.getMessage());
            showInterviewerList(request, response);
        }
    }
    
    /**
     * 면접관 삭제 (비활성화)
     */
    private void deleteInterviewer(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect("interviewers");
            return;
        }
        
        try {
            int id = Integer.parseInt(idParam);
            
            if (interviewerDAO.deleteInterviewer(id)) {
                HttpSession session = request.getSession();
                session.setAttribute("successMessage", "면접관이 성공적으로 비활성화되었습니다.");
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "면접관 비활성화에 실패했습니다.");
            }
            
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "잘못된 면접관 ID입니다.");
        }
        
        response.sendRedirect("interviewers");
    }
    
    /**
     * 면접관 검색
     */
    private void searchInterviewers(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        if (keyword == null || keyword.trim().isEmpty()) {
            showInterviewerList(request, response);
            return;
        }
        
        try {
            List<Interviewer> interviewers = interviewerDAO.searchInterviewers(keyword.trim());
            Map<String, Integer> stats = interviewerDAO.getInterviewerStats();
            
            request.setAttribute("interviewers", interviewers);
            request.setAttribute("stats", stats);
            request.setAttribute("searchKeyword", keyword);
            request.setAttribute("searchResultCount", interviewers.size());
            
            request.getRequestDispatcher("interviewer_list.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "검색 중 오류가 발생했습니다: " + e.getMessage());
            showInterviewerList(request, response);
        }
    }
    
    /**
     * 면접관 필터링 (부서별, 전문분야별)
     */
    private void filterInterviewers(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String filterType = request.getParameter("filterType");
        String filterValue = request.getParameter("filterValue");
        
        if (filterType == null || filterValue == null || filterValue.trim().isEmpty()) {
            showInterviewerList(request, response);
            return;
        }
        
        try {
            List<Interviewer> interviewers;
            
            if ("department".equals(filterType)) {
                interviewers = interviewerDAO.getInterviewersByDepartment(filterValue);
            } else if ("expertise".equals(filterType)) {
                interviewers = interviewerDAO.getInterviewersByExpertise(filterValue);
            } else {
                showInterviewerList(request, response);
                return;
            }
            
            Map<String, Integer> stats = interviewerDAO.getInterviewerStats();
            
            request.setAttribute("interviewers", interviewers);
            request.setAttribute("stats", stats);
            request.setAttribute("filterType", filterType);
            request.setAttribute("filterValue", filterValue);
            request.setAttribute("filterResultCount", interviewers.size());
            
            request.getRequestDispatcher("interviewer_list.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "필터링 중 오류가 발생했습니다: " + e.getMessage());
            showInterviewerList(request, response);
        }
    }
    
    /**
     * 요청에서 Interviewer 객체 추출
     */
    private Interviewer extractInterviewerFromRequest(HttpServletRequest request) throws Exception {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String department = request.getParameter("department");
        String position = request.getParameter("position");
        String phoneNumber = request.getParameter("phoneNumber");
        String expertise = request.getParameter("expertise");
        String role = request.getParameter("role");
        String isActiveParam = request.getParameter("isActive");
        String notes = request.getParameter("notes");
        
        // 필수 필드 검증
        if (name == null || name.trim().isEmpty()) {
            throw new Exception("이름은 필수 입력 항목입니다.");
        }
        if (email == null || email.trim().isEmpty()) {
            throw new Exception("이메일은 필수 입력 항목입니다.");
        }
        if (department == null || department.trim().isEmpty()) {
            throw new Exception("부서는 필수 입력 항목입니다.");
        }
        
        Interviewer interviewer = new Interviewer();
        interviewer.setName(name.trim());
        interviewer.setEmail(email.trim());
        interviewer.setDepartment(department.trim());
        interviewer.setPosition(position != null ? position.trim() : "");
        interviewer.setPhoneNumber(phoneNumber != null ? phoneNumber.trim() : "");
        interviewer.setExpertise(expertise != null ? expertise.trim() : "기술");
        interviewer.setRole(role != null ? role.trim() : "JUNIOR");
        interviewer.setActive(isActiveParam != null && "true".equals(isActiveParam));
        interviewer.setNotes(notes != null ? notes.trim() : "");
        
        return interviewer;
    }
} 