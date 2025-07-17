package com.example.controller;

import com.example.model.User;
import com.example.model.UserDAO;
import com.example.model.CandidateDAO;
import com.example.model.InterviewScheduleDAO;
import com.example.model.InterviewResultDAO;
import com.example.model.ActivityHistory;
import com.example.model.ActivityHistoryDAO;

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
import java.util.ArrayList;

@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private UserDAO userDAO;
    private CandidateDAO candidateDAO;
    private InterviewScheduleDAO scheduleDAO;
    private InterviewResultDAO resultDAO;
    private ActivityHistoryDAO activityDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        candidateDAO = new CandidateDAO();
        scheduleDAO = new InterviewScheduleDAO();
        resultDAO = new InterviewResultDAO();
        activityDAO = new ActivityHistoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = getAction(request);
        
        // 세션 정보 확인
        HttpSession session = request.getSession(false);
        
        // 관리자 권한 확인
        boolean adminCheck = isAdmin(request);
        
        if (!adminCheck) {
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
            request.setAttribute("error", "관리자 기능 처리 중 오류가 발생했습니다: " + e.getMessage());
            request.getRequestDispatcher("/admin_error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = getAction(request);
        
        // 관리자 권한 확인
        boolean adminCheck = isAdmin(request);
        
        // 세션 정보 확인
        HttpSession session = request.getSession(false);
        
        if (!adminCheck) {
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
            request.setAttribute("error", "관리자 기능 처리 중 오류가 발생했습니다: " + e.getMessage());
            request.getRequestDispatcher("/admin_error.jsp").forward(request, response);
        }
    }

    /**
     * 관리자 대시보드 표시
     */
    private void showDashboard(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 시스템 통계 수집
            Map<String, Object> stats = new HashMap<>();
            
            int totalUsers = userDAO.getTotalUsersCount();
            stats.put("totalUsers", totalUsers);
            
            int activeUsers = userDAO.getActiveUsersCount();
            stats.put("activeUsers", activeUsers);
            
            int totalCandidates = candidateDAO.getAllCandidates().size();
            stats.put("totalCandidates", totalCandidates);
            
            int totalSchedules = scheduleDAO.getAllSchedules().size();
            stats.put("totalSchedules", totalSchedules);
            
            int totalResults = resultDAO.getAllResults().size();
            stats.put("totalResults", totalResults);
            
            // 역할별 사용자 수 (2단계 시스템: USER, ADMIN)
            int userCount = userDAO.getUsersCountByRole("USER");
            stats.put("userCount", userCount);
            
            int adminCount = userDAO.getUsersCountByRole("ADMIN");
            stats.put("adminCount", adminCount);
            
            // 2단계 권한 시스템에서 더 이상 사용하지 않는 역할들은 0으로 설정
            int interviewerCount = 0;
            stats.put("interviewerCount", interviewerCount);
            
            int superAdminCount = 0;
            stats.put("superAdminCount", superAdminCount);
            
            // 최근 사용자 목록 (최대 5명)
            List<User> recentUsers = userDAO.getAllUsers();
            if (recentUsers.size() > 5) {
                recentUsers = recentUsers.subList(0, 5);
            }
            stats.put("recentUsers", recentUsers);
            
            request.setAttribute("stats", stats);
            request.getRequestDispatcher("/admin_dashboard.jsp").forward(request, response);
            
        } catch (Exception e) {
            throw e;
        }
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
        
        // 기존 사용자 정보가 있다면 제거 (브라우저 캐시 방지)
        request.removeAttribute("user");
        request.removeAttribute("error");
        request.removeAttribute("success");
        
        // 새 사용자 폼임을 명시적으로 표시
        request.setAttribute("isNewUser", true);
        request.setAttribute("formTitle", "새 사용자 추가");
        
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
        
        request.getRequestDispatcher("/system_settings.jsp").forward(request, response);
    }

    /**
     * 로그 표시
     */
    private void showLogs(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 파라미터 처리
            String searchType = request.getParameter("searchType");
            String searchValue = request.getParameter("searchValue");
            String limitParam = request.getParameter("limit");
            
            int limit = 50; // 기본값
            if (limitParam != null && !limitParam.isEmpty()) {
                try {
                    limit = Integer.parseInt(limitParam);
                    if (limit > 1000) limit = 1000; // 최대 1000개
                    if (limit < 10) limit = 10;     // 최소 10개
                } catch (NumberFormatException e) {
                    limit = 50;
                }
            }
            
            List<ActivityHistory> activities = new ArrayList<>();
            
            // 검색 조건에 따른 로그 조회
            if (searchType != null && searchValue != null && !searchValue.trim().isEmpty()) {
                switch (searchType) {
                    case "username":
                        activities = activityDAO.getActivitiesByUser(searchValue.trim(), limit);
                        break;
                    case "today":
                        activities = activityDAO.getTodayActivities();
                        break;
                    case "login":
                        activities = activityDAO.getRecentLogins(limit);
                        break;
                    default:
                        activities = activityDAO.getAllActivities(limit);
                        break;
                }
            } else {
                activities = activityDAO.getAllActivities(limit);
            }
            
            // 로그 통계 정보
            Map<String, Object> logStats = new HashMap<>();
            logStats.put("totalLogs", activities.size());
            logStats.put("todayLogs", activityDAO.getTodayActivities().size());
            logStats.put("recentLogins", activityDAO.getRecentLogins(10).size());
            
            // 액션별 통계 (최근 로그에서)
            Map<String, Integer> actionCounts = new HashMap<>();
            for (ActivityHistory activity : activities) {
                String action = activity.getAction();
                actionCounts.put(action, actionCounts.getOrDefault(action, 0) + 1);
            }
            
            request.setAttribute("activities", activities);
            request.setAttribute("logStats", logStats);
            request.setAttribute("actionCounts", actionCounts);
            request.setAttribute("searchType", searchType);
            request.setAttribute("searchValue", searchValue);
            request.setAttribute("limit", limit);
            
        } catch (Exception e) {
            request.setAttribute("error", "로그 조회 중 오류가 발생했습니다: " + e.getMessage());
        }
        
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
        User user = new User(username, password, role != null ? role : "INTERVIEWER");
        user.setEmail(email);
        user.setFullName(fullName);
        user.setActive(true);
        
        // 사용자 추가
        if (userDAO.addUser(user)) {
            // 활동 로그 기록
            String adminUsername = (String) request.getSession().getAttribute("username");
            activityDAO.logCreate(adminUsername, "user", null, username, "새 사용자 생성 (역할: " + user.getRole() + ")");
            
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
        String password = request.getParameter("password");
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
            
            // 비밀번호가 입력된 경우에만 업데이트
            if (password != null && !password.trim().isEmpty()) {
                user.setPassword(password);
            }
            
            if (userDAO.updateUser(user)) {
                // 활동 로그 기록
                String adminUsername = (String) request.getSession().getAttribute("username");
                activityDAO.logUpdate(adminUsername, "user", userId, username, "사용자 정보 수정");
                
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
                // 활동 로그 기록
                String adminUsername = (String) request.getSession().getAttribute("username");
                activityDAO.logCreate(adminUsername, "user", userId, "사용자 #" + userId, "사용자 삭제");
                
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
                // 활동 로그 기록
                String adminUsername = (String) request.getSession().getAttribute("username");
                activityDAO.logUpdate(adminUsername, "user", userId, user.getUsername(), "사용자 " + action);
                
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
            String action = path.substring(7); // "/admin/" 제거
            return action;
        } else {
            return "";
        }
    }

    /**
     * 관리자 권한 확인
     */
    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            String role = (String) session.getAttribute("role");
            return "ADMIN".equals(role);
        }
        return false;
    }
} 