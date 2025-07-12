<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.example.model.User" %>
<%
    // 세션 검증
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 관리자 권한 확인
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "관리자 권한이 필요합니다.");
        return;
    }
    
    @SuppressWarnings("unchecked")
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    if (stats == null) {
        stats = new HashMap<>();
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리자 대시보드 - 채용 관리 시스템</title>
    <base href="${pageContext.request.contextPath}/">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background-color: #f0f0f0;
            color: #24292f;
            line-height: 1.6;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .top-bar {
            background-color: #0078d4;
            color: white;
            padding: 15px 20px;
            margin-bottom: 30px;
            border-radius: 8px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .top-bar h1 {
            font-size: 24px;
            font-weight: 600;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .main-dashboard {
            background-color: white;
            border-radius: 8px;
            border: 1px solid #d0d7de;
            overflow: hidden;
        }
        
        .dashboard-header {
            background-color: #f6f8fa;
            padding: 20px;
            border-bottom: 1px solid #d0d7de;
        }
        
        .dashboard-header h2 {
            font-size: 20px;
            font-weight: 600;
            color: #24292f;
            margin-bottom: 10px;
        }
        
        .dashboard-nav {
            display: flex;
            gap: 20px;
        }
        
        .nav-link {
            color: #0078d4;
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 6px;
            transition: background-color 0.2s;
        }
        
        .nav-link:hover {
            background-color: #f3f4f6;
        }
        
        .dashboard-content {
            padding: 20px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background-color: #f6f8fa;
            border: 1px solid #d0d7de;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
        }
        
        .stat-number {
            font-size: 32px;
            font-weight: 700;
            color: #0078d4;
            margin-bottom: 8px;
        }
        
        .stat-label {
            font-size: 14px;
            color: #656d76;
            font-weight: 500;
        }
        
        .recent-activity {
            background-color: #f6f8fa;
            border: 1px solid #d0d7de;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .recent-activity h3 {
            font-size: 18px;
            font-weight: 600;
            color: #24292f;
            margin-bottom: 15px;
        }
        
        .user-list {
            list-style: none;
        }
        
        .user-item {
            display: flex;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #d0d7de;
        }
        
        .user-item:last-child {
            border-bottom: none;
        }
        
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: #0078d4;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            margin-right: 12px;
        }
        
        .user-details {
            flex: 1;
        }
        
        .user-name {
            font-weight: 600;
            color: #24292f;
        }
        
        .user-role {
            font-size: 12px;
            color: #656d76;
        }
        
        .role-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
            margin-left: 8px;
        }
        
        .role-super-admin {
            background-color: #dc2626;
            color: white;
        }
        
        .role-admin {
            background-color: #7c2d12;
            color: white;
        }
        
        .role-interviewer {
            background-color: #0078d4;
            color: white;
        }
        
        .role-user {
            background-color: #65a30d;
            color: white;
        }
        
        .btn {
            display: inline-block;
            padding: 8px 16px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 500;
            text-align: center;
            border: 1px solid transparent;
            cursor: pointer;
            transition: all 0.2s;
            font-size: 14px;
        }
        
        .btn-primary {
            background-color: #1f883d;
            color: white;
            border-color: #1f883d;
        }
        
        .btn-primary:hover {
            background-color: #1a7f37;
            border-color: #1a7f37;
        }
        
        .btn-secondary {
            background-color: white;
            color: #24292f;
            border-color: #d0d7de;
        }
        
        .btn-secondary:hover {
            background-color: #f3f4f6;
            border-color: #d0d7de;
        }
        
        .quick-actions {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        
        .system-status {
            background-color: #f6f8fa;
            border: 1px solid #d0d7de;
            border-radius: 8px;
            padding: 20px;
        }
        
        .system-status h3 {
            font-size: 18px;
            font-weight: 600;
            color: #24292f;
            margin-bottom: 15px;
        }
        
        .status-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 0;
            border-bottom: 1px solid #d0d7de;
        }
        
        .status-item:last-child {
            border-bottom: none;
        }
        
        .status-label {
            font-weight: 500;
            color: #24292f;
        }
        
        .status-value {
            font-weight: 600;
            color: #0078d4;
        }
        
        .status-good {
            color: #1f883d;
        }
        
        .status-warning {
            color: #fb8500;
        }
        
        .status-error {
            color: #dc2626;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h1>🛠️ 관리자 대시보드</h1>
            <div class="user-info">
                <span>환영합니다, <%= session.getAttribute("userFullName") != null ? session.getAttribute("userFullName") : session.getAttribute("username") %>님</span>
                <span class="role-badge role-<%= session.getAttribute("userRole").toString().toLowerCase().replace("_", "-") %>">
                    <%= session.getAttribute("userRole") %>
                </span>
                <a href="logout" class="btn btn-secondary">로그아웃</a>
            </div>
        </div>
        
        <div class="main-dashboard">
            <div class="dashboard-header">
                <h2>시스템 관리</h2>
                <div class="dashboard-nav">
                    <a href="admin/dashboard" class="nav-link">📊 대시보드</a>
                    <a href="admin/users" class="nav-link">👥 사용자 관리</a>
                    <a href="admin/settings" class="nav-link">⚙️ 시스템 설정</a>
                    <a href="admin/logs" class="nav-link">📋 로그 관리</a>
                    <a href="main.jsp" class="nav-link">🏠 메인으로</a>
                </div>
            </div>
            
            <div class="dashboard-content">
                <!-- 빠른 작업 버튼 -->
                <div class="quick-actions">
                    <a href="admin/user/add" class="btn btn-primary">➕ 새 사용자 추가</a>
                    <a href="admin/users" class="btn btn-secondary">👥 사용자 관리</a>
                    <a href="admin/settings" class="btn btn-secondary">⚙️ 시스템 설정</a>
                </div>
                
                <!-- 통계 카드 -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-number"><%= stats.get("totalUsers") %></div>
                        <div class="stat-label">전체 사용자</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= stats.get("activeUsers") %></div>
                        <div class="stat-label">활성 사용자</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= stats.get("totalCandidates") %></div>
                        <div class="stat-label">전체 지원자</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= stats.get("totalSchedules") %></div>
                        <div class="stat-label">인터뷰 일정</div>
                    </div>
                </div>
                
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    <!-- 최근 사용자 -->
                    <div class="recent-activity">
                        <h3>👥 최근 사용자</h3>
                        <ul class="user-list">
                            <%
                                @SuppressWarnings("unchecked")
                                List<User> recentUsers = (List<User>) stats.get("recentUsers");
                                if (recentUsers != null && !recentUsers.isEmpty()) {
                                    for (User user : recentUsers) {
                                        String initials = user.getFullName() != null && !user.getFullName().trim().isEmpty() 
                                            ? user.getFullName().substring(0, 1).toUpperCase()
                                            : user.getUsername().substring(0, 1).toUpperCase();
                            %>
                            <li class="user-item">
                                <div class="user-avatar"><%= initials %></div>
                                <div class="user-details">
                                    <div class="user-name"><%= user.getFullName() != null ? user.getFullName() : user.getUsername() %></div>
                                    <div class="user-role">
                                        @<%= user.getUsername() %>
                                        <span class="role-badge role-<%= user.getRole().toLowerCase().replace("_", "-") %>">
                                            <%= user.getRole() %>
                                        </span>
                                    </div>
                                </div>
                            </li>
                            <%
                                    }
                                } else {
                            %>
                            <li class="user-item">
                                <div style="color: #656d76; font-style: italic;">사용자가 없습니다.</div>
                            </li>
                            <%
                                }
                            %>
                        </ul>
                    </div>
                    
                    <!-- 시스템 상태 -->
                    <div class="system-status">
                        <h3>📊 시스템 상태</h3>
                        <div class="status-item">
                            <span class="status-label">데이터베이스 연결</span>
                            <span class="status-value status-good">정상</span>
                        </div>
                        <div class="status-item">
                            <span class="status-label">사용자 수</span>
                            <span class="status-value"><%= stats.get("totalUsers") %>명</span>
                        </div>
                        <div class="status-item">
                            <span class="status-label">관리자 수</span>
                            <span class="status-value"><%= (Integer) stats.get("adminCount") + (Integer) stats.get("superAdminCount") %>명</span>
                        </div>
                        <div class="status-item">
                            <span class="status-label">면접관 수</span>
                            <span class="status-value"><%= stats.get("interviewerCount") %>명</span>
                        </div>
                        <div class="status-item">
                            <span class="status-label">시스템 가동 시간</span>
                            <span class="status-value status-good">정상</span>
                        </div>
                    </div>
                </div>
                
                <!-- 역할별 사용자 통계 -->
                <div class="stats-grid" style="margin-top: 30px;">
                    <div class="stat-card">
                        <div class="stat-number"><%= stats.get("superAdminCount") %></div>
                        <div class="stat-label">최고 관리자</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= stats.get("adminCount") %></div>
                        <div class="stat-label">관리자</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= stats.get("interviewerCount") %></div>
                        <div class="stat-label">면접관</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= stats.get("userCount") %></div>
                        <div class="stat-label">일반 사용자</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html> 