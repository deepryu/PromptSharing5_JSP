package com.example.filter;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Arrays;
import java.util.List;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.example.model.User;
import com.example.model.UserDAO;

/**
 * 권한 기반 접근 제어 필터
 * 사용자의 권한에 따라 페이지 접근을 제어합니다.
 */
@WebFilter("/*")
public class RoleBasedFilter implements Filter {
    
    private UserDAO userDAO;
    
    // 권한별 접근 가능한 경로 정의
    private static final Map<String, List<String>> ROLE_PERMISSIONS = new HashMap<>();
    
    static {
        // 모든 사용자 접근 가능
        ROLE_PERMISSIONS.put("PUBLIC", Arrays.asList(
            "/login.jsp", "/register.jsp", "/welcome.jsp", 
            "/css/", "/js/", "/images/", "/favicon.ico"
        ));
        
        // 일반 사용자 접근 가능
        ROLE_PERMISSIONS.put("USER", Arrays.asList(
            "/main.jsp", "/candidate/list", "/candidate/detail", 
            "/interview/list", "/interview/detail", "/statistics/view"
        ));
        
        // 면접관 접근 가능
        ROLE_PERMISSIONS.put("INTERVIEWER", Arrays.asList(
            "/interview/add", "/interview/edit", "/interview/delete",
            "/result/add", "/result/edit", "/result/list",
            "/candidate/add", "/candidate/edit"
        ));
        
        // 관리자 접근 가능
        ROLE_PERMISSIONS.put("ADMIN", Arrays.asList(
            "/admin/users", "/admin/dashboard", "/admin/settings",
            "/admin/logs", "/admin/reports", "/admin/notifications"
        ));
        
        // 최고 관리자 접근 가능
        ROLE_PERMISSIONS.put("SUPER_ADMIN", Arrays.asList(
            "/admin/system", "/admin/backup", "/admin/security",
            "/admin/roles", "/admin/maintenance"
        ));
    }
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        userDAO = new UserDAO();
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        
        // 컨텍스트 경로 제거
        if (requestURI.startsWith(contextPath)) {
            requestURI = requestURI.substring(contextPath.length());
        }
        
        // 정적 리소스 및 공개 페이지는 통과
        if (isPublicResource(requestURI)) {
            chain.doFilter(request, response);
            return;
        }
        
        // 세션에서 사용자 정보 가져오기
        HttpSession session = httpRequest.getSession(false);
        String username = null;
        User user = null;
        
        if (session != null) {
            username = (String) session.getAttribute("username");
            if (username != null) {
                user = userDAO.findByUsername(username);
            }
        }
        
        // 로그인하지 않은 사용자 처리
        if (user == null) {
            handleUnauthorizedAccess(httpRequest, httpResponse, "로그인이 필요합니다.");
            return;
        }
        
        // 비활성 계정 처리
        if (!user.isActive()) {
            handleUnauthorizedAccess(httpRequest, httpResponse, "비활성화된 계정입니다.");
            return;
        }
        
        // 계정 잠금 처리
        if (user.isAccountLocked()) {
            handleUnauthorizedAccess(httpRequest, httpResponse, "계정이 잠겨있습니다.");
            return;
        }
        
        // 권한 확인 (admin 계정은 특별 처리)
        String userRole = user.getRole();
        String originalRole = userRole;
        
        if ("admin".equals(user.getUsername()) && (userRole == null || "USER".equals(userRole))) {
            userRole = "SUPER_ADMIN";  // admin 계정은 최고 관리자 권한 부여
        }
        
        // 디버깅 로그
        System.out.println("🔍 [RoleBasedFilter] ================================");
        System.out.println("🔍 [RoleBasedFilter] 요청 URI: " + requestURI);
        System.out.println("🔍 [RoleBasedFilter] 사용자: " + user.getUsername());
        System.out.println("🔍 [RoleBasedFilter] 원래 역할: " + originalRole);
        System.out.println("🔍 [RoleBasedFilter] 적용 역할: " + userRole);
        System.out.println("🔍 [RoleBasedFilter] 권한 검사 시작...");
        
        if (!hasPermission(requestURI, userRole)) {
            System.out.println("❌ [RoleBasedFilter] 권한 없음 - 로그인 페이지로 리다이렉트");
            handleUnauthorizedAccess(httpRequest, httpResponse, "접근 권한이 없습니다.");
            return;
        }
        
        System.out.println("✅ [RoleBasedFilter] 권한 확인 완료 - 접근 허용");
        
        // 사용자 정보를 request에 저장 (서블릿에서 사용)
        httpRequest.setAttribute("currentUser", user);
        
        // 권한 통과
        chain.doFilter(request, response);
    }
    
    @Override
    public void destroy() {
        // 리소스 정리
    }
    
    /**
     * 공개 리소스 확인
     */
    private boolean isPublicResource(String requestURI) {
        List<String> publicPaths = ROLE_PERMISSIONS.get("PUBLIC");
        
        for (String path : publicPaths) {
            if (requestURI.startsWith(path)) {
                return true;
            }
        }
        
        // 서블릿 경로 확인
        return requestURI.equals("/login") || requestURI.equals("/register") || 
               requestURI.equals("/logout") || requestURI.equals("/");
    }
    
    /**
     * 권한 확인
     */
    private boolean hasPermission(String requestURI, String userRole) {
        // role이 null인 경우 기본적으로 USER 권한으로 처리
        if (userRole == null) {
            userRole = "USER";
        }
        
        // 권한 계층 구조 확인
        switch (userRole) {
            case "SUPER_ADMIN":
                // 최고 관리자는 모든 권한 보유
                return true;
                
            case "ADMIN":
                // 관리자는 ADMIN + INTERVIEWER + USER 권한 보유
                return hasRolePermission(requestURI, "ADMIN") ||
                       hasRolePermission(requestURI, "INTERVIEWER") ||
                       hasRolePermission(requestURI, "USER");
                
            case "INTERVIEWER":
                // 면접관은 INTERVIEWER + USER 권한 보유
                return hasRolePermission(requestURI, "INTERVIEWER") ||
                       hasRolePermission(requestURI, "USER");
                
            case "USER":
                // 일반 사용자는 USER 권한만 보유
                return hasRolePermission(requestURI, "USER");
                
            default:
                return false;
        }
    }
    
    /**
     * 특정 역할의 권한 확인
     */
    private boolean hasRolePermission(String requestURI, String role) {
        List<String> permissions = ROLE_PERMISSIONS.get(role);
        if (permissions == null) {
            return false;
        }
        
        for (String path : permissions) {
            if (requestURI.startsWith(path)) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * 권한 없음 처리
     */
    private void handleUnauthorizedAccess(HttpServletRequest request, HttpServletResponse response, 
                                        String message) throws IOException {
        
        // AJAX 요청인 경우 JSON 응답
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"error\": \"" + message + "\"}");
            return;
        }
        
        // 일반 요청인 경우 로그인 페이지로 리다이렉트
        HttpSession session = request.getSession();
        session.setAttribute("errorMessage", message);
        session.setAttribute("redirectUrl", request.getRequestURI());
        
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }
} 