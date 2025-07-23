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
 * 기존 AuthenticationFilter - RoleBasedFilter로 통합됨
 * 현재 비활성화 상태 (주석 처리)
 */
// @WebFilter("/*")  // 비활성화: RoleBasedFilter로 통합
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
        System.out.println("🔧 AuthenticationFilter 초기화됨 (비활성화됨)");
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
        
        // 제외 경로 확인
        boolean isExcluded = isExcludedPath(path);
        
        if (isExcluded) {
            chain.doFilter(request, response);
            return;
        }
        
        // 세션 확인
        HttpSession session = httpRequest.getSession(false);
        String username = null;
        
        if (session != null) {
            username = (String) session.getAttribute("username");
        }
        
        // 인증되지 않은 사용자
        if (username == null) {
            // AJAX 요청인 경우
            String ajaxHeader = httpRequest.getHeader("X-Requested-With");
            
            if ("XMLHttpRequest".equals(ajaxHeader)) {
                httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                httpResponse.getWriter().write("{\"error\":\"로그인이 필요합니다.\"}");
                return;
            }
            
            // 일반 요청인 경우 로그인 페이지로 리다이렉트
            String redirectURL = contextPath + "/login.jsp";
            httpResponse.sendRedirect(redirectURL);
            return;
        }
        
        // 인증된 사용자는 요청 계속 처리
        chain.doFilter(request, response);
    }
    
    /**
     * 제외 경로인지 확인
     */
    private boolean isExcludedPath(String path) {
        for (String excludedPath : EXCLUDED_PATHS) {
            if (path.startsWith(excludedPath)) {
                return true;
            }
        }
        return false;
    }
    
    @Override
    public void destroy() {
        System.out.println("🔧 AuthenticationFilter 종료됨");
    }
} 