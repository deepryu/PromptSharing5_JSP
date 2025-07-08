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
            // UserDAO의 실제 메소드 사용: findByUsername
            User user = userDAO.findByUsername(username);
            System.out.println("🔍 [LoginServlet-POST] DB 조회 결과: " + (user != null ? "사용자 찾음" : "사용자 없음"));
            
            // 사용자가 존재하고 비밀번호가 일치하는지 확인
            if (user != null && BCrypt.checkpw(password, user.getPassword())) {
                // 로그인 성공
                System.out.println("✅ [LoginServlet-POST] 로그인 성공 - 세션 생성 시작");
                
                // 기존 세션이 있다면 무효화
                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) {
                    System.out.println("🔍 [LoginServlet-POST] 기존 세션 무효화: " + oldSession.getId());
                    oldSession.invalidate();
                }
                
                // 새 세션 생성
                HttpSession session = request.getSession(true);
                System.out.println("🔍 [LoginServlet-POST] 새 세션 생성: " + session.getId());
                
                // User 클래스의 실제 메소드 사용
                session.setAttribute("username", user.getUsername());
                session.setAttribute("userId", user.getId());
                
                System.out.println("🔍 [LoginServlet-POST] 세션에 저장된 데이터:");
                System.out.println("  - username: " + session.getAttribute("username"));
                System.out.println("  - userId: " + session.getAttribute("userId"));
                
                System.out.println("🔄 [LoginServlet-POST] main.jsp로 리다이렉트");
                response.sendRedirect("main.jsp");
            } else {
                // 로그인 실패
                System.out.println("❌ [LoginServlet-POST] 로그인 실패 - 잘못된 인증정보");
                request.setAttribute("error", "사용자명 또는 비밀번호가 올바르지 않습니다.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            System.out.println("💥 [LoginServlet-POST] 로그인 중 예외 발생: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "로그인 중 오류가 발생했습니다: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
} 