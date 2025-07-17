<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String username = (String)session.getAttribute("username");
    String userRole = (String)session.getAttribute("userRole");
    String role = (String)session.getAttribute("role");
    Boolean isAdmin = (Boolean)session.getAttribute("isAdmin");
    
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 관리자 대시보드 접근 권한 확인 (ADMIN 권한만 허용)
    boolean hasAdminAccess = (isAdmin != null && isAdmin) || 
                            ("ADMIN".equals(userRole)) ||
                            ("ADMIN".equals(role));
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>메인 대시보드 - 채용 관리 시스템</title>
    
    <!-- 파비콘 설정 -->
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/favicon.ico">
    <link rel="icon" type="image/png" sizes="32x32" href="${pageContext.request.contextPath}/images/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="${pageContext.request.contextPath}/images/favicon-16x16.png">
    <link rel="apple-touch-icon" sizes="180x180" href="${pageContext.request.contextPath}/images/apple-touch-icon.png">
    
    <link rel="stylesheet" href="css/common.css">
    <style>
        /* 대시보드 테이블 스타일 - candidates.jsp와 동일한 스타일 적용 */
        
        #dashboardTable {
            width: 100%;
            border-collapse: collapse;
            margin: 0;
            background: white;
        }
        
        #dashboardTable th {
            text-align: center;
            background: #d0d7de;
            border-bottom: 2px solid #8c959f;
            border-right: 1px solid #8c959f;
            padding: 16px 8px;
            font-weight: 600;
            color: #24292f;
            font-size: 1.25rem;
            white-space: nowrap;
        }
        
        #dashboardTable th:last-child {
            border-right: none;
        }
        
        #dashboardTable td {
            vertical-align: middle;
            border-bottom: 1px solid #eaeef2;
            border-right: 1px solid #eaeef2;
            padding: 20px 8px;
            font-size: 0.9rem;
        }
        
        #dashboardTable td:last-child {
            border-right: none;
        }
        
        /* 테이블 행 스타일 - 스트라이프 패턴 */
        #dashboardTable tbody tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        
        #dashboardTable tbody tr:nth-child(odd) {
            background-color: white;
        }
        
        #dashboardTable tbody tr:hover {
            background-color: #e6f3ff !important;
            transform: scale(1.01);
            transition: all 0.2s ease;
        }
        
        /* 대시보드 메뉴 링크 스타일 */
        .dashboard-menu-link {
            display: block;
            text-decoration: none;
            color: #24292f;
            font-size: 1rem;
            font-weight: 500;
            padding: 10px 15px;
            border-radius: 3px;
            transition: all 0.2s ease;
            background: transparent;
            width: 100%;
            text-align: center;
        }
        
        .dashboard-menu-link:hover {
            background: #f6f8fa;
            text-decoration: none;
            color: #0969da;
            border: 1px solid #d0d7de;
        }
        
        .dashboard-menu-link .menu-number {
            font-weight: 600;
            color: #0969da;
            margin-right: 8px;
        }
        
        .dashboard-menu-link:hover .menu-number {
            color: #0969da;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h2>📊 채용 관리 시스템</h2>
            <div class="nav-buttons">
                <% if (username != null) { %>
                    <span style="margin-right: 15px; color: var(--text-secondary); font-size: var(--font-sm);">안녕하세요, <%= username %>님 
                        <% if (userRole != null) { %>
                            (<%= userRole %>)
                        <% } %>
                    </span>
                    
                    <%-- 관리자 권한이 있는 사용자에게만 관리자 대시보드 버튼 표시 --%>
                    <% if (hasAdminAccess) { %>
                        <form action="admin/dashboard" method="get" style="display:inline; margin-right: 10px;" 
                              onsubmit="return debugAdminDashboard();">
                            <button type="submit" class="btn btn-primary" id="adminDashboardBtn">🛠️ 관리자 대시보드</button>
                        </form>
                    <% } %>
                    
                    <form action="logout" method="get" style="display:inline;">
                        <button type="submit" class="btn">🚪 로그아웃</button>
                    </form>
                <% } else { %>
                    <form action="login" method="get" style="display:inline;">
                        <button type="submit" class="btn">🔑 로그인</button>
                    </form>
                <% } %>
            </div>
        </div>
        
        <div class="main-dashboard">
            <div class="dashboard-header">
                <h1 style="text-align: center;">관리자 메인 대시보드 V1.0</h1>
            </div>
            <div class="dashboard-content">
                <div class="table-container">
                    <table id="dashboardTable">
                        <thead>
                            <tr>
                                <th colspan="2" style="width: 100%; text-align: center;">메뉴</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td style="text-align: center; padding: 20px;">
                                    <a href="candidates" class="dashboard-menu-link">
                                        <span class="menu-number">1.</span>
                                        인터뷰 대상자 관리
                                    </a>
                                </td>
                                <td style="text-align: center; padding: 20px;">
                                    <a href="interview/list" class="dashboard-menu-link">
                                        <span class="menu-number">2.</span>
                                        인터뷰 일정 관리
                                    </a>
                                </td>
                            </tr>
                            <tr>
                                <td style="text-align: center; padding: 20px;">
                                    <a href="questions" class="dashboard-menu-link">
                                        <span class="menu-number">3.</span>
                                        질문/평가 항목 관리
                                    </a>
                                </td>
                                <td style="text-align: center; padding: 20px;">
                                    <a href="results" class="dashboard-menu-link">
                                        <span class="menu-number">4.</span>
                                        인터뷰 결과 기록/관리
                                    </a>
                                </td>
                            </tr>
                            <tr>
                                <td style="text-align: center; padding: 20px;">
                                    <a href="statistics" class="dashboard-menu-link">
                                        <span class="menu-number">5.</span>
                                        통계 및 리포트
                                    </a>
                                </td>
                                <td style="text-align: center; padding: 20px;">
                                    <a href="notifications" class="dashboard-menu-link">
                                        <span class="menu-number">6.</span>
                                        알림 및 히스토리
                                    </a>
                                </td>
                            </tr>
                            <tr>
                                <td style="text-align: center; padding: 20px;" colspan="2">
                                    <!-- 향후 확장 기능 자리 -->
                                    <div style="color: #8c959f; font-style: italic; padding: 10px;">
                                        더 많은 기능이 곧 추가될 예정입니다
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <script>
        function debugAdminDashboard() {
            console.log("=== 관리자 대시보드 디버깅 ===");
            console.log("🖱️ 관리자 대시보드 버튼 클릭됨");
            console.log("📍 현재 URL:", window.location.href);
            console.log("📍 Form action:", document.querySelector('form[action="admin/dashboard"]').action);
            console.log("🔗 이동할 URL:", window.location.origin + window.location.pathname.replace(/[^/]*$/, '') + "admin/dashboard");
            
            // 세션 정보 (서버에서 출력된 정보 참고)
            console.log("👤 세션 정보는 서버 콘솔을 확인하세요");
            console.log("=== 디버깅 완료 ===");
            
            return true; // 폼 제출 허용
        }
    </script>
</body>
</html> 