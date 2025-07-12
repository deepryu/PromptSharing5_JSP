package com.example.controller;

import com.example.model.User;
import com.example.model.UserDAO;
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
    
    // 계정 잠금 설정
    private static final int MAX_FAILED_ATTEMPTS = 5;
    private static final int LOCK_DURATION_MINUTES = 30;

    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String requestURI = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = requestURI.substring(contextPath.length());
        
        System.out.println("🔍 [LoginServlet-GET] ================================");
        System.out.println("🔍 [LoginServlet-GET] 요청 경로: " + path);
        System.out.println("🔍 [LoginServlet-GET] 전체 URI: " + requestURI);
        
        // 세션 상태 확인
        HttpSession session = request.getSession(false);
        System.out.println("🔍 [LoginServlet-GET] 현재 세션: " + (session != null ? "존재" : "null"));
        
        if (session != null) {
            String username = (String) session.getAttribute("username");
            System.out.println("🔍 [LoginServlet-GET] 세션의 username: " + username);
            
            if (username != null) {
                System.out.println("✅ [LoginServlet-GET] 이미 로그인된 사용자 - main.jsp로 리다이렉트");
                response.sendRedirect("main.jsp");
                return;
            }
        }
        
        System.out.println("📄 [LoginServlet-GET] 로그인 페이지 표시");
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("🔍 [LoginServlet-POST] ================================");
        System.out.println("🔍 [LoginServlet-POST] 로그인 요청 시작");
        
        request.setCharacterEncoding("UTF-8");
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        System.out.println("🔍 [LoginServlet-POST] 입력된 username: " + username);
        System.out.println("🔍 [LoginServlet-POST] password 입력됨: " + (password != null && !password.isEmpty()));
        
        try {
            // 사용자 조회
            User user = userDAO.findByUsername(username);
            System.out.println("🔍 [LoginServlet-POST] DB 조회 결과: " + (user != null ? "사용자 찾음" : "사용자 없음"));
            
            // 사용자가 존재하지 않는 경우
            if (user == null) {
                System.out.println("❌ [LoginServlet-POST] 존재하지 않는 사용자명");
                handleLoginFailure(request, response, "사용자명 또는 비밀번호가 올바르지 않습니다.");
                return;
            }
            
            // 비활성 계정 확인
            if (!user.isActive()) {
                System.out.println("❌ [LoginServlet-POST] 비활성화된 계정");
                handleLoginFailure(request, response, "비활성화된 계정입니다. 관리자에게 문의하세요.");
                return;
            }
            
            // 계정 잠금 확인
            if (user.isAccountLocked()) {
                System.out.println("❌ [LoginServlet-POST] 잠긴 계정");
                handleLoginFailure(request, response, "계정이 잠겨있습니다. 잠시 후 다시 시도해주세요.");
                return;
            }
            
            // 비밀번호 검증 (호환 모드: plain text와 BCrypt 모두 지원)
            if (!isPasswordValid(password, user.getPassword())) {
                System.out.println("❌ [LoginServlet-POST] 비밀번호 불일치");
                
                // 로그인 실패 횟수 증가
                userDAO.incrementFailedLoginAttempts(username);
                
                // 실패 횟수가 최대치에 도달한 경우 계정 잠금
                if (user.getFailedLoginAttempts() + 1 >= MAX_FAILED_ATTEMPTS) {
                    userDAO.lockAccount(username, LOCK_DURATION_MINUTES);
                    System.out.println("🔒 [LoginServlet-POST] 계정 잠금됨 - 최대 실패 횟수 초과");
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
            System.out.println("✅ [LoginServlet-POST] 로그인 성공 - 세션 생성 시작");
            
            // 로그인 성공 시 실패 횟수 초기화 및 마지막 로그인 시간 업데이트
            userDAO.resetFailedLoginAttempts(username);
            userDAO.updateLastLogin(user.getId());
            
            // 기존 세션이 있다면 무효화
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                System.out.println("🔍 [LoginServlet-POST] 기존 세션 무효화: " + oldSession.getId());
                oldSession.invalidate();
            }
            
            // 새 세션 생성
            HttpSession session = request.getSession(true);
            System.out.println("🔍 [LoginServlet-POST] 새 세션 생성: " + session.getId());
            
            // 세션에 사용자 정보 저장
            session.setAttribute("username", user.getUsername());
            session.setAttribute("userId", user.getId());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("userFullName", user.getFullName());
            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("isAdmin", user.isAdmin());
            session.setAttribute("isSuperAdmin", user.isSuperAdmin());
            session.setAttribute("isInterviewer", user.isInterviewer());
            
            System.out.println("🔍 [LoginServlet-POST] 세션에 저장된 데이터:");
            System.out.println("  - username: " + session.getAttribute("username"));
            System.out.println("  - userId: " + session.getAttribute("userId"));
            System.out.println("  - userRole: " + session.getAttribute("userRole"));
            System.out.println("  - userFullName: " + session.getAttribute("userFullName"));
            System.out.println("  - isAdmin: " + session.getAttribute("isAdmin"));
            System.out.println("  - isSuperAdmin: " + session.getAttribute("isSuperAdmin"));
            
            // 리다이렉트 URL 확인 (로그인 전 접근하려던 페이지가 있는 경우)
            String redirectUrl = (String) session.getAttribute("redirectUrl");
            if (redirectUrl != null) {
                session.removeAttribute("redirectUrl");
                System.out.println("🔄 [LoginServlet-POST] 원래 요청 페이지로 리다이렉트: " + redirectUrl);
                response.sendRedirect(redirectUrl);
            } else {
                System.out.println("🔄 [LoginServlet-POST] main.jsp로 리다이렉트");
                response.sendRedirect("main.jsp");
            }
            
        } catch (Exception e) {
            System.out.println("💥 [LoginServlet-POST] 로그인 중 예외 발생: " + e.getMessage());
            e.printStackTrace();
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
                System.out.println("🔍 [LoginServlet] BCrypt 해시 비밀번호 검증");
                return BCrypt.checkpw(inputPassword, storedPassword);
            } catch (Exception e) {
                System.out.println("❌ [LoginServlet] BCrypt 검증 실패: " + e.getMessage());
                return false;
            }
        } else {
            // Plain text 비밀번호 검증 (임시 호환 모드)
            System.out.println("🔍 [LoginServlet] Plain text 비밀번호 검증 (임시 호환 모드)");
            return inputPassword.equals(storedPassword);
        }
    }

    /**
     * 로그인 실패 처리
     */
    private void handleLoginFailure(HttpServletRequest request, HttpServletResponse response, String errorMessage) 
            throws ServletException, IOException {
        
        System.out.println("❌ [LoginServlet] 로그인 실패: " + errorMessage);
        request.setAttribute("error", errorMessage);
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
} 