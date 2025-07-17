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
        
        // 면접관 권한 (기본 권한 - 모든 일반 기능 + 인터뷰 관련 쓰기 권한)
        ROLE_PERMISSIONS.put("INTERVIEWER", Arrays.asList(
            "/main.jsp", "/logout",
            // 지원자 관리 (읽기 + 쓰기)
            "/candidates", "/candidates/detail", "/candidates/view", "/candidates/add", "/candidates/edit",
            // 인터뷰 일정 관리 (읽기 + 쓰기)
            "/interview/list", "/interview/detail", "/interview/view", "/interview/add", "/interview/edit", "/interview/delete",
            // 질문 관리 (읽기 + 쓰기)
            "/questions", "/questions/detail", "/questions/view", "/questions/add", "/questions/edit",
            // 결과 관리 (읽기 + 쓰기)
            "/results", "/results/detail", "/results/view", "/results/add", "/results/edit", "/results/delete",
            // 통계 조회
            "/statistics", "/statistics/view"
        ));
        
        // 관리자 권한 (모든 기능 + 관리 기능 + 삭제 권한)
        ROLE_PERMISSIONS.put("ADMIN", Arrays.asList(
            // 관리자 전용 기능
            "/admin/users", "/admin/dashboard", "/admin/settings", "/admin/logs", "/admin/reports", 
            "/admin/notifications", "/admin/system", "/admin/backup", "/admin/security",
            "/admin/roles", "/admin/maintenance",
            // 사용자 관리 세부 기능
            "/admin/user/add", "/admin/user/edit", "/admin/user/detail", "/admin/user/delete", "/admin/user/activate", "/admin/user/deactivate",
            // 관리자 전용 메인 메뉴 기능
            "/notifications", "/settings",
            // 삭제 권한
            "/candidates/delete", "/questions/delete", "/results/delete"
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
        
        if (!hasPermission(requestURI, userRole)) {
            handleUnauthorizedAccess(httpRequest, httpResponse, "접근 권한이 없습니다.");
            return;
        }
        
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
        // role이 null인 경우 기본적으로 INTERVIEWER 권한으로 처리
        if (userRole == null) {
            userRole = "INTERVIEWER";
        }
        
        // 2단계 권한 계층 구조 확인
        switch (userRole) {
            case "ADMIN":
                // 관리자는 ADMIN + INTERVIEWER 권한 보유 (모든 권한)
                return hasRolePermission(requestURI, "ADMIN") ||
                       hasRolePermission(requestURI, "INTERVIEWER");
                
            case "INTERVIEWER":
                // 면접관은 INTERVIEWER 권한만 보유 (기본 권한)
                return hasRolePermission(requestURI, "INTERVIEWER");
                
            default:
                // 알 수 없는 권한은 접근 거부
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
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"error\": \"실행 권한이 없습니다\", \"message\": \"" + message + "\"}");
            return;
        }
        
        // 로그인이 필요한 경우 로그인 페이지로 리다이렉트
        if ("로그인이 필요합니다.".equals(message)) {
            response.setContentType("text/html; charset=UTF-8");
            response.setCharacterEncoding("UTF-8");
            
            String html = "<!DOCTYPE html>\n" +
                         "<html>\n" +
                         "<head>\n" +
                         "    <meta charset='UTF-8'>\n" +
                         "    <title>로그인 필요</title>\n" +
                         "</head>\n" +
                         "<body>\n" +
                         "    <script>\n" +
                         "        alert('🔐 " + message + "\\n\\n로그인 페이지로 이동합니다.');\n" +
                         "        window.location.href = '" + request.getContextPath() + "/login.jsp';\n" +
                         "    </script>\n" +
                         "</body>\n" +
                         "</html>";
            
            response.getWriter().write(html);
            return;
        }
        
        // 일반 권한 에러인 경우 경고창을 띄우고 이전 페이지로 돌아가는 HTML 반환
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        response.setContentType("text/html; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        String html = "<!DOCTYPE html>\n" +
                     "<html>\n" +
                     "<head>\n" +
                     "    <meta charset='UTF-8'>\n" +
                     "    <title>접근 권한 없음</title>\n" +
                     "</head>\n" +
                     "<body>\n" +
                     "    <script>\n" +
                     "        alert('❌ 실행 권한이 없습니다\\n\\n" + message + "');\n" +
                     "        history.back();\n" +
                     "    </script>\n" +
                     "</body>\n" +
                     "</html>";
        
        response.getWriter().write(html);
    }
} 