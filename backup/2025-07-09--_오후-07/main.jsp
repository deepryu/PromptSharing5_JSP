<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String username = (String)session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>메인 대시보드 - 채용 관리 시스템</title>
    <link rel="stylesheet" href="css/common.css">
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h2>📊 채용 관리 시스템</h2>
            <div class="nav-buttons">
                <% if (username != null) { %>
                    <span style="margin-right: 15px; color: var(--text-secondary); font-size: var(--font-sm);">안녕하세요, <%= username %>님</span>
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
                <h1>관리자 메인 대시보드 V1.0</h1>
            </div>
            <div class="dashboard-content">
                <div class="menu-grid">
                    <a href="candidates" class="menu-item completed">
                        <span class="menu-number">1.</span>
                        인터뷰 대상자 관리
                        <span class="status-badge status-completed">완료</span>
                    </a>
                    <a href="interview/list" class="menu-item completed">
                        <span class="menu-number">2.</span>
                        인터뷰 일정 관리
                        <span class="status-badge status-completed">완료</span>
                    </a>
                    <a href="questions" class="menu-item completed">
                        <span class="menu-number">3.</span>
                        질문/평가 항목 관리
                        <span class="status-badge status-completed">완료</span>
                    </a>
                    <a href="results" class="menu-item completed">
                        <span class="menu-number">4.</span>
                        인터뷰 결과 기록/관리
                        <span class="status-badge status-completed">완료</span>
                    </a>
                    <a href="statistics" class="menu-item completed">
                        <span class="menu-number">5.</span>
                        통계 및 리포트
                        <span class="status-badge status-completed">완료</span>
                    </a>
                    <a href="interviewers" class="menu-item completed">
                        <span class="menu-number">6.</span>
                        면접관(관리자) 관리
                        <span class="status-badge status-completed">완료</span>
                    </a>
                    <a href="notifications" class="menu-item completed">
                        <span class="menu-number">7.</span>
                        알림 및 히스토리
                        <span class="status-badge status-completed">완료</span>
                    </a>
                    <a href="settings" class="menu-item completed">
                        <span class="menu-number">8.</span>
                        시스템 설정
                        <span class="status-badge status-completed">완료</span>
                    </a>
                </div>
            </div>
        </div>
    </div>
</body>
</html> 