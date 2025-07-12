package com.example.controller;

import com.example.model.User;
import com.example.model.UserDAO;
import com.example.model.CandidateDAO;
import com.example.model.InterviewScheduleDAO;
import com.example.model.InterviewResultDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private UserDAO userDAO;
    private CandidateDAO candidateDAO;
    private InterviewScheduleDAO scheduleDAO;
    private InterviewResultDAO resultDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        candidateDAO = new CandidateDAO();
        scheduleDAO = new InterviewScheduleDAO();
        resultDAO = new InterviewResultDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = getAction(request);
        System.out.println("🔍 [AdminServlet-GET] 액션: " + action);
        
        // 관리자 권한 확인
        if (!isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "관리자 권한이 필요합니다.");
            return;
        }
        
        try {
            switch (action) {
                case "dashboard":
                    showDashboard(request, response);
                    break;
                case "users":
                    showUsers(request, response);
                    break;
                case "user/add":
                    showUserForm(request, response);
                    break;
                case "user/edit":
                    showUserEditForm(request, response);
                    break;
                case "user/detail":
                    showUserDetail(request, response);
                    break;
                case "settings":
                    showSettings(request, response);
                    break;
                case "logs":
                    showLogs(request, response);
                    break;
                default:
                    showDashboard(request, response);
                    break;
            }
        } catch (Exception e) {
            System.out.println("💥 [AdminServlet-GET] 오류 발생: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "관리자 기능 처리 중 오류가 발생했습니다: " + e.getMessage());
            request.getRequestDispatcher("/admin_error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = getAction(request);
        System.out.println("🔍 [AdminServlet-POST] 액션: " + action);
        
        // 관리자 권한 확인
        if (!isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "관리자 권한이 필요합니다.");
            return;
        }
        
        request.setCharacterEncoding("UTF-8");
        
        try {
            switch (action) {
                case "user/add":
                    addUser(request, response);
                    break;
                case "user/edit":
                    editUser(request, response);
                    break;
                case "user/delete":
                    deleteUser(request, response);
                    break;
                case "user/activate":
                    activateUser(request, response);
                    break;
                case "user/deactivate":
                    deactivateUser(request, response);
                    break;
                case "user/unlock":
                    unlockUser(request, response);
                    break;
                case "user/reset-password":
                    resetPassword(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "지원하지 않는 액션입니다.");
                    break;
            }
        } catch (Exception e) {
            System.out.println("💥 [AdminServlet-POST] 오류 발생: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "관리자 기능 처리 중 오류가 발생했습니다: " + e.getMessage());
            request.getRequestDispatcher("/admin_error.jsp").forward(request, response);
        }
    }

    /**
     * 관리자 대시보드 표시
     */
    private void showDashboard(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 시스템 통계 수집
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsers", userDAO.getTotalUsersCount());
        stats.put("activeUsers", userDAO.getActiveUsersCount());
        stats.put("totalCandidates", candidateDAO.getAllCandidates().size());
        stats.put("totalSchedules", scheduleDAO.getAllSchedules().size());
        stats.put("totalResults", resultDAO.getAllResults().size());
        
        // 역할별 사용자 수
        stats.put("userCount", userDAO.getUsersCountByRole("USER"));
        stats.put("interviewerCount", userDAO.getUsersCountByRole("INTERVIEWER"));
        stats.put("adminCount", userDAO.getUsersCountByRole("ADMIN"));
        stats.put("superAdminCount", userDAO.getUsersCountByRole("SUPER_ADMIN"));
        
        // 최근 사용자 목록 (최대 5명)
        List<User> recentUsers = userDAO.getAllUsers();
        if (recentUsers.size() > 5) {
            recentUsers = recentUsers.subList(0, 5);
        }
        stats.put("recentUsers", recentUsers);
        
        request.setAttribute("stats", stats);
        request.getRequestDispatcher("/admin_dashboard.jsp").forward(request, response);
    }

    /**
     * 사용자 목록 표시
     */
    private void showUsers(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String roleFilter = request.getParameter("role");
        String search = request.getParameter("search");
        
        List<User> users;
        
        if (search != null && !search.trim().isEmpty()) {
            users = userDAO.searchUsers(search);
        } else if (roleFilter != null && !roleFilter.trim().isEmpty()) {
            users = userDAO.getUsersByRole(roleFilter);
        } else {
            users = userDAO.getAllUsers();
        }
        
        request.setAttribute("users", users);
        request.setAttribute("roleFilter", roleFilter);
        request.setAttribute("search", search);
        request.getRequestDispatcher("/admin_users.jsp").forward(request, response);
    }

    /**
     * 사용자 등록 폼 표시
     */
    private void showUserForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.getRequestDispatcher("/admin_user_form.jsp").forward(request, response);
    }

    /**
     * 사용자 수정 폼 표시
     */
    private void showUserEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String userIdStr = request.getParameter("id");
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "사용자 ID가 필요합니다.");
            return;
        }
        
        try {
            int userId = Integer.parseInt(userIdStr);
            User user = userDAO.findById(userId);
            
            if (user == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "사용자를 찾을 수 없습니다.");
                return;
            }
            
            request.setAttribute("user", user);
            request.getRequestDispatcher("/admin_user_form.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 사용자 ID입니다.");
        }
    }

    /**
     * 사용자 상세 정보 표시
     */
    private void showUserDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String userIdStr = request.getParameter("id");
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "사용자 ID가 필요합니다.");
            return;
        }
        
        try {
            int userId = Integer.parseInt(userIdStr);
            User user = userDAO.findById(userId);
            
            if (user == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "사용자를 찾을 수 없습니다.");
                return;
            }
            
            request.setAttribute("user", user);
            request.getRequestDispatcher("/admin_user_detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 사용자 ID입니다.");
        }
    }

    /**
     * 시스템 설정 표시
     */
    private void showSettings(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.getRequestDispatcher("/admin_settings.jsp").forward(request, response);
    }

    /**
     * 로그 표시
     */
    private void showLogs(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.getRequestDispatcher("/admin_logs.jsp").forward(request, response);
    }

    /**
     * 사용자 추가
     */
    private void addUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");
        String fullName = request.getParameter("fullName");
        String role = request.getParameter("role");
        
        // 입력 유효성 검사
        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "사용자명과 비밀번호는 필수입니다.");
            request.getRequestDispatcher("/admin_user_form.jsp").forward(request, response);
            return;
        }
        
        // 사용자 객체 생성
        User user = new User(username, password, role != null ? role : "USER");
        user.setEmail(email);
        user.setFullName(fullName);
        user.setActive(true);
        
        // 사용자 추가
        if (userDAO.addUser(user)) {
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "사용자가 성공적으로 추가되었습니다.");
            response.sendRedirect(request.getContextPath() + "/admin/users");
        } else {
            request.setAttribute("error", "사용자 추가에 실패했습니다. 중복된 사용자명이나 이메일일 수 있습니다.");
            request.getRequestDispatcher("/admin_user_form.jsp").forward(request, response);
        }
    }

    /**
     * 사용자 수정
     */
    private void editUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String userIdStr = request.getParameter("id");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String fullName = request.getParameter("fullName");
        String role = request.getParameter("role");
        
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "사용자 ID가 필요합니다.");
            return;
        }
        
        try {
            int userId = Integer.parseInt(userIdStr);
            User user = userDAO.findById(userId);
            
            if (user == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "사용자를 찾을 수 없습니다.");
                return;
            }
            
            // 사용자 정보 업데이트
            user.setUsername(username);
            user.setEmail(email);
            user.setFullName(fullName);
            user.setRole(role);
            
            if (userDAO.updateUser(user)) {
                HttpSession session = request.getSession();
                session.setAttribute("successMessage", "사용자가 성공적으로 수정되었습니다.");
                response.sendRedirect(request.getContextPath() + "/admin/users");
            } else {
                request.setAttribute("error", "사용자 수정에 실패했습니다.");
                request.setAttribute("user", user);
                request.getRequestDispatcher("/admin_user_form.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 사용자 ID입니다.");
        }
    }

    /**
     * 사용자 삭제
     */
    private void deleteUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String userIdStr = request.getParameter("id");
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "사용자 ID가 필요합니다.");
            return;
        }
        
        try {
            int userId = Integer.parseInt(userIdStr);
            
            if (userDAO.deleteUser(userId)) {
                HttpSession session = request.getSession();
                session.setAttribute("successMessage", "사용자가 성공적으로 삭제되었습니다.");
                response.sendRedirect(request.getContextPath() + "/admin/users");
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "사용자 삭제에 실패했습니다.");
                response.sendRedirect(request.getContextPath() + "/admin/users");
            }
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 사용자 ID입니다.");
        }
    }

    /**
     * 사용자 활성화
     */
    private void activateUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        updateUserStatus(request, response, true, "활성화");
    }

    /**
     * 사용자 비활성화
     */
    private void deactivateUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        updateUserStatus(request, response, false, "비활성화");
    }

    /**
     * 사용자 계정 잠금 해제
     */
    private void unlockUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String userIdStr = request.getParameter("id");
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "사용자 ID가 필요합니다.");
            return;
        }
        
        try {
            int userId = Integer.parseInt(userIdStr);
            User user = userDAO.findById(userId);
            
            if (user == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "사용자를 찾을 수 없습니다.");
                return;
            }
            
            if (userDAO.resetFailedLoginAttempts(user.getUsername())) {
                HttpSession session = request.getSession();
                session.setAttribute("successMessage", "계정 잠금이 해제되었습니다.");
                response.sendRedirect(request.getContextPath() + "/admin/users");
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "계정 잠금 해제에 실패했습니다.");
                response.sendRedirect(request.getContextPath() + "/admin/users");
            }
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 사용자 ID입니다.");
        }
    }

    /**
     * 비밀번호 재설정
     */
    private void resetPassword(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String userIdStr = request.getParameter("id");
        String newPassword = request.getParameter("newPassword");
        
        if (userIdStr == null || userIdStr.trim().isEmpty() || 
            newPassword == null || newPassword.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "사용자 ID와 새 비밀번호가 필요합니다.");
            return;
        }
        
        try {
            int userId = Integer.parseInt(userIdStr);
            
            if (userDAO.updatePassword(userId, newPassword)) {
                HttpSession session = request.getSession();
                session.setAttribute("successMessage", "비밀번호가 성공적으로 재설정되었습니다.");
                response.sendRedirect(request.getContextPath() + "/admin/users");
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "비밀번호 재설정에 실패했습니다.");
                response.sendRedirect(request.getContextPath() + "/admin/users");
            }
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 사용자 ID입니다.");
        }
    }

    /**
     * 사용자 활성화/비활성화 상태 업데이트
     */
    private void updateUserStatus(HttpServletRequest request, HttpServletResponse response, 
                                 boolean isActive, String action) 
            throws ServletException, IOException {
        
        String userIdStr = request.getParameter("id");
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "사용자 ID가 필요합니다.");
            return;
        }
        
        try {
            int userId = Integer.parseInt(userIdStr);
            User user = userDAO.findById(userId);
            
            if (user == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "사용자를 찾을 수 없습니다.");
                return;
            }
            
            user.setActive(isActive);
            
            if (userDAO.updateUser(user)) {
                HttpSession session = request.getSession();
                session.setAttribute("successMessage", "사용자가 성공적으로 " + action + "되었습니다.");
                response.sendRedirect(request.getContextPath() + "/admin/users");
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "사용자 " + action + "에 실패했습니다.");
                response.sendRedirect(request.getContextPath() + "/admin/users");
            }
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 사용자 ID입니다.");
        }
    }

    /**
     * 요청 경로에서 액션 추출
     */
    private String getAction(HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = requestURI.substring(contextPath.length());
        
        if (path.startsWith("/admin/")) {
            return path.substring(7); // "/admin/" 제거
        }
        return "";
    }

    /**
     * 관리자 권한 확인
     */
    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
            return isAdmin != null && isAdmin;
        }
        return false;
    }
} 