package com.example.controller;

import com.example.model.User;
import com.example.model.UserDAO;
import com.example.model.ActivityHistoryDAO;
import org.mindrot.jbcrypt.BCrypt;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;
    private ActivityHistoryDAO activityDAO;
    
    // 계정 잠금 설정
    private static final int MAX_FAILED_ATTEMPTS = 5;
    private static final int LOCK_DURATION_MINUTES = 30;

    public void init() {
        userDAO = new UserDAO();
        activityDAO = new ActivityHistoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String requestURI = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = requestURI.substring(contextPath.length());
        
        // 세션 상태 확인
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            String username = (String) session.getAttribute("username");
            
            if (username != null) {
                response.sendRedirect("main.jsp");
                return;
            }
        }
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        try {
            // 사용자 조회
            User user = userDAO.findByUsername(username);
            
            // 사용자가 존재하지 않는 경우
            if (user == null) {
                System.out.println("❌ [LoginServlet-POST] 존재하지 않는 사용자명");
                handleLoginFailure(request, response, "사용자명 또는 비밀번호가 올바르지 않습니다.");
                return;
            }
            
            // 비활성 계정 확인
            if (!user.isActive()) {
                handleLoginFailure(request, response, "비활성화된 계정입니다. 관리자에게 문의하세요.");
                return;
            }
            
            // 계정 잠금 확인
            if (user.isAccountLocked()) {
                handleLoginFailure(request, response, "계정이 잠겨있습니다. 잠시 후 다시 시도해주세요.");
                return;
            }
            
            // 비밀번호 검증 (호환 모드: plain text와 BCrypt 모두 지원)
            if (!isPasswordValid(password, user.getPassword())) {
                // 로그인 실패 횟수 증가
                userDAO.incrementFailedLoginAttempts(username);
                
                // 실패 횟수가 최대치에 도달한 경우 계정 잠금
                if (user.getFailedLoginAttempts() + 1 >= MAX_FAILED_ATTEMPTS) {
                    userDAO.lockAccount(username, LOCK_DURATION_MINUTES);
                    handleLoginFailure(request, response, 
                        "로그인 실패 횟수가 초과되어 계정이 " + LOCK_DURATION_MINUTES + "분간 잠겼습니다.");
                } else {
                    int remainingAttempts = MAX_FAILED_ATTEMPTS - (user.getFailedLoginAttempts() + 1);
                    handleLoginFailure(request, response, 
                        "사용자명 또는 비밀번호가 올바르지 않습니다. (" + remainingAttempts + "회 시도 가능)");
                }
                return;
            }
            
            // 로그인 성공
            
            // 로그인 성공 시 실패 횟수 초기화 및 마지막 로그인 시간 업데이트
            userDAO.resetFailedLoginAttempts(username);
            userDAO.updateLastLogin(user.getId());
            
            // 활동 로그 기록
            String ipAddress = request.getRemoteAddr();
            String userAgent = request.getHeader("User-Agent");
            boolean logResult = activityDAO.logLogin(username, ipAddress, userAgent);
            
            // 기존 세션이 있다면 무효화
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
            
            // 새 세션 생성
            HttpSession session = request.getSession(true);
            
            // 세션에 사용자 정보 저장
            session.setAttribute("username", user.getUsername());
            session.setAttribute("userId", user.getId());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("role", user.getRole()); // AdminServlet 호환성을 위해 추가
            session.setAttribute("userFullName", user.getFullName());
            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("isAdmin", user.isAdmin());
            session.setAttribute("isSuperAdmin", user.isSuperAdmin());
            session.setAttribute("isInterviewer", user.isInterviewer());
            
            // 리다이렉트 URL 확인 (로그인 전 접근하려던 페이지가 있는 경우)
            String redirectUrl = (String) session.getAttribute("redirectUrl");
            if (redirectUrl != null) {
                session.removeAttribute("redirectUrl");
                response.sendRedirect(redirectUrl);
            } else {
                response.sendRedirect("main.jsp");
            }
            
        } catch (Exception e) {
            handleLoginFailure(request, response, "로그인 중 오류가 발생했습니다: " + e.getMessage());
        }
    }
    
    /**
     * 비밀번호 검증 (호환 모드: plain text와 BCrypt 해시 모두 지원)
     */
    private boolean isPasswordValid(String inputPassword, String storedPassword) {
        if (inputPassword == null || storedPassword == null) {
            return false;
        }
        
        // BCrypt 해시인지 확인 (일반적으로 $2a$, $2b$, $2y$로 시작)
        if (storedPassword.startsWith("$2a$") || storedPassword.startsWith("$2b$") || storedPassword.startsWith("$2y$")) {
            try {
                // BCrypt 해시 비밀번호 검증
                return BCrypt.checkpw(inputPassword, storedPassword);
            } catch (Exception e) {
                return false;
            }
        } else {
            // Plain text 비밀번호 검증 (임시 호환 모드)
            return inputPassword.equals(storedPassword);
        }
    }

    /**
     * 로그인 실패 처리
     */
    private void handleLoginFailure(HttpServletRequest request, HttpServletResponse response, String errorMessage) 
            throws ServletException, IOException {
        
        request.setAttribute("error", errorMessage);
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
} 