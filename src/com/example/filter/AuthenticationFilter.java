package com.example.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

/**
 * 모든 요청에 대해 세션 인증을 검증하는 필터
 * 로그인하지 않은 사용자의 직접 URL 접근을 차단합니다.
 */
@WebFilter("/*")
public class AuthenticationFilter implements Filter {
    
    // 인증이 필요없는 페이지들
    private static final List<String> EXCLUDED_PATHS = Arrays.asList(
        "/login",
        "/login.jsp", 
        "/register",
        "/register.jsp",
        "/css/",
        "/js/",
        "/images/",
        "/favicon.ico"
    );
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("🔧 AuthenticationFilter 초기화됨");
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = requestURI.substring(contextPath.length());
        String method = httpRequest.getMethod();
        String queryString = httpRequest.getQueryString();
        String fullURL = requestURI + (queryString != null ? "?" + queryString : "");
        
        System.out.println("🔍 [AuthFilter] ================================");
        System.out.println("🔍 [AuthFilter] 요청 URL: " + fullURL);
        System.out.println("🔍 [AuthFilter] Method: " + method);
        System.out.println("🔍 [AuthFilter] RequestURI: " + requestURI);
        System.out.println("🔍 [AuthFilter] ContextPath: " + contextPath);
        System.out.println("🔍 [AuthFilter] Path: " + path);
        
        // 제외 경로 확인
        boolean isExcluded = isExcludedPath(path);
        System.out.println("🔍 [AuthFilter] 제외 경로 여부: " + isExcluded);
        
        if (isExcluded) {
            System.out.println("✅ [AuthFilter] 제외 경로이므로 인증 검사 생략");
            chain.doFilter(request, response);
            return;
        }
        
        // 세션 확인
        HttpSession session = httpRequest.getSession(false);
        String username = null;
        
        System.out.println("🔍 [AuthFilter] Session 객체: " + (session != null ? "존재" : "null"));
        
        if (session != null) {
            username = (String) session.getAttribute("username");
            System.out.println("🔍 [AuthFilter] Session ID: " + session.getId());
            System.out.println("🔍 [AuthFilter] Username: " + username);
            System.out.println("🔍 [AuthFilter] Session 생성시간: " + new java.util.Date(session.getCreationTime()));
            System.out.println("🔍 [AuthFilter] Session 마지막 접근: " + new java.util.Date(session.getLastAccessedTime()));
        }
        
        // 인증되지 않은 사용자
        if (username == null) {
            System.out.println("❌ [AuthFilter] 인증되지 않은 사용자 감지");
            
            // AJAX 요청인 경우
            String ajaxHeader = httpRequest.getHeader("X-Requested-With");
            System.out.println("🔍 [AuthFilter] X-Requested-With: " + ajaxHeader);
            
            if ("XMLHttpRequest".equals(ajaxHeader)) {
                System.out.println("📡 [AuthFilter] AJAX 요청 - 401 응답 반환");
                httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                httpResponse.getWriter().write("{\"error\":\"로그인이 필요합니다.\"}");
                return;
            }
            
            // 일반 요청인 경우 로그인 페이지로 리다이렉트
            String redirectURL = contextPath + "/login.jsp";
            System.out.println("🔄 [AuthFilter] 로그인 페이지로 리다이렉트: " + redirectURL);
            httpResponse.sendRedirect(redirectURL);
            return;
        }
        
        // 인증된 사용자는 요청 계속 처리
        System.out.println("✅ [AuthFilter] 인증된 사용자 (" + username + ") - 요청 계속 처리");
        chain.doFilter(request, response);
        System.out.println("✅ [AuthFilter] 요청 처리 완료");
    }
    
    /**
     * 제외 경로인지 확인
     */
    private boolean isExcludedPath(String path) {
        System.out.println("🔍 [AuthFilter] 제외 경로 검사 대상: " + path);
        for (String excludedPath : EXCLUDED_PATHS) {
            if (path.startsWith(excludedPath)) {
                System.out.println("✅ [AuthFilter] 제외 경로 매칭: " + excludedPath);
                return true;
            }
        }
        System.out.println("❌ [AuthFilter] 제외 경로에 해당하지 않음");
        return false;
    }
    
    @Override
    public void destroy() {
        System.out.println("🔧 AuthenticationFilter 종료됨");
    }
} 