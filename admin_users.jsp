<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.example.model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // 세션 검증
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 관리자 권한 확인
    String role = (String) session.getAttribute("role");
    if (!"ADMIN".equals(role)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "관리자 권한이 필요합니다.");
        return;
    }
    
    @SuppressWarnings("unchecked")
    List<User> users = (List<User>) request.getAttribute("users");
    if (users == null) {
        users = new ArrayList<>();
    }
    
    String roleFilter = (String) request.getAttribute("roleFilter");
    String search = (String) request.getAttribute("search");
    
    // 세션에서 메시지 읽기 및 제거
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    if (successMessage != null) {
        session.removeAttribute("successMessage");
    }
    if (errorMessage != null) {
        session.removeAttribute("errorMessage");
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>사용자 관리 - 관리자 대시보드</title>
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
        

        
        .nav-buttons {
            background-color: #f6f8fa;
            padding: 15px 20px;
            border-bottom: 1px solid #d0d7de;
        }
        
        .nav-buttons .btn {
            background-color: white;
            color: #24292f;
            padding: 8px 16px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 500;
            font-size: 14px;
            border: 1px solid #d0d7de;
            transition: all 0.2s;
            margin-right: 10px;
        }
        
        .nav-buttons .btn:hover {
            background-color: #f3f4f6;
            border-color: #0078d4;
            color: #0078d4;
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
        
        .actions-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 15px;
        }
        
        .search-controls {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .search-input {
            padding: 8px 12px;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            font-size: 14px;
            width: 250px;
        }
        
        .select-input {
            padding: 8px 12px;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            font-size: 14px;
            background-color: white;
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
        
        .btn-danger {
            background-color: #dc2626;
            color: white;
            border-color: #dc2626;
        }
        
        .btn-danger:hover {
            background-color: #b91c1c;
            border-color: #b91c1c;
        }
        
        .btn-warning {
            background-color: #fb8500;
            color: white;
            border-color: #fb8500;
        }
        
        .btn-warning:hover {
            background-color: #e07400;
            border-color: #e07400;
        }
        
        .btn-small {
            padding: 4px 8px;
            font-size: 12px;
        }
        
        .users-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        .users-table th,
        .users-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #d0d7de;
        }
        
        .users-table th {
            background-color: #f6f8fa;
            font-weight: 600;
            color: #24292f;
        }
        
        .users-table tr:hover {
            background-color: #f6f8fa;
        }
        
        .user-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background-color: #0078d4;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            margin-right: 10px;
            font-size: 12px;
        }
        
        .user-info-cell {
            display: flex;
            align-items: center;
        }
        
        .user-details {
            display: flex;
            flex-direction: column;
        }
        
        .user-name {
            font-weight: 600;
            color: #24292f;
        }
        
        .user-username {
            font-size: 12px;
            color: #656d76;
        }
        
        .role-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
            text-transform: uppercase;
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
        
        .status-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
        }
        
        .status-active {
            background-color: #22c55e;
            color: white;
        }
        
        .status-inactive {
            background-color: #ef4444;
            color: white;
        }
        
        .status-locked {
            background-color: #f59e0b;
            color: white;
        }
        
        .actions-cell {
            display: flex;
            gap: 5px;
        }
        
        .alert {
            padding: 12px 16px;
            border-radius: 6px;
            margin-bottom: 20px;
        }
        
        .alert-success {
            background-color: #d1fae5;
            color: #166534;
            border: 1px solid #a7f3d0;
        }
        
        .alert-error {
            background-color: #fee2e2;
            color: #dc2626;
            border: 1px solid #fecaca;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #656d76;
        }
        
        .empty-state-icon {
            font-size: 48px;
            margin-bottom: 16px;
        }
        
        .stats-summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .stat-card {
            background-color: #f6f8fa;
            border: 1px solid #d0d7de;
            border-radius: 8px;
            padding: 15px;
            text-align: center;
        }
        
        .stat-number {
            font-size: 24px;
            font-weight: 700;
            color: #0078d4;
            margin-bottom: 5px;
        }
        
        .stat-label {
            font-size: 12px;
            color: #656d76;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h1>👥 사용자 관리</h1>
            <div class="user-info">
                <span>관리자: <%= session.getAttribute("userFullName") != null ? session.getAttribute("userFullName") : session.getAttribute("username") %>님</span>
                <a href="admin/dashboard" class="btn btn-secondary">대시보드</a>
                <a href="logout" class="btn btn-secondary">로그아웃</a>
            </div>
        </div>
        
        <div class="main-dashboard">
            <div class="dashboard-header">
                <h2>사용자 목록 및 관리</h2>
            </div>
            
            <!-- 관리자 네비게이션 메뉴 -->
            <div class="nav-buttons">
                <a href="admin/dashboard" class="btn">📊 대시보드</a>
                <a href="admin/users" class="btn">👥 사용자 관리</a>
                <a href="admin/settings" class="btn">⚙️ 시스템 설정</a>
                <a href="admin/logs" class="btn">📋 로그 관리</a>
                <a href="main.jsp" class="btn">🏠 메인</a>
            </div>
            
            <div class="dashboard-content">
                <!-- 성공/오류 메시지 -->
                <% if (successMessage != null) { %>
                <div class="alert alert-success">
                    ✅ <%= successMessage %>
                </div>
                <% } %>
                
                <% if (errorMessage != null) { %>
                <div class="alert alert-error">
                    ❌ <%= errorMessage %>
                </div>
                <% } %>
                
                <!-- 통계 요약 -->
                <div class="stats-summary">
                    <div class="stat-card">
                        <div class="stat-number"><%= users.size() %></div>
                        <div class="stat-label">전체 사용자</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">
                            <%= users.stream().mapToInt(user -> user.isActive() ? 1 : 0).sum() %>
                        </div>
                        <div class="stat-label">활성 사용자</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">
                            <%= users.stream().mapToInt(user -> user.isAccountLocked() ? 1 : 0).sum() %>
                        </div>
                        <div class="stat-label">잠긴 계정</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">
                            <%= users.stream().mapToInt(user -> user.isAdmin() ? 1 : 0).sum() %>
                        </div>
                        <div class="stat-label">관리자</div>
                    </div>
                </div>
                
                <!-- 작업 바 -->
                <div class="actions-bar">
                    <div>
                        <a href="admin/user/add" class="btn btn-primary">➕ 새 사용자 추가</a>
                    </div>
                    
                    <div class="search-controls">
                        <form method="GET" action="admin/users" style="display: flex; gap: 10px;">
                            <select name="role" class="select-input" onchange="this.form.submit()">
                                <option value="">모든 역할</option>
                                <option value="INTERVIEWER" <%= "INTERVIEWER".equals(roleFilter) ? "selected" : "" %>>인터뷰어</option>
                                <option value="ADMIN" <%= "ADMIN".equals(roleFilter) ? "selected" : "" %>>관리자</option>
                            </select>
                            <input type="text" name="search" class="search-input" placeholder="사용자명, 이메일, 이름 검색..." 
                                   value="<%= search != null ? search : "" %>">
                            <button type="submit" class="btn btn-secondary">🔍 검색</button>
                        </form>
                    </div>
                </div>
                
                <!-- 사용자 테이블 -->
                <% if (users.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">👥</div>
                    <h3>사용자가 없습니다</h3>
                    <p>아직 등록된 사용자가 없거나 검색 조건에 맞는 사용자가 없습니다.</p>
                    <a href="admin/user/add" class="btn btn-primary" style="margin-top: 15px;">첫 사용자 추가하기</a>
                </div>
                <% } else { %>
                <table class="users-table">
                    <thead>
                        <tr>
                            <th>사용자</th>
                            <th>이메일</th>
                            <th>역할</th>
                            <th>상태</th>
                            <th>마지막 로그인</th>
                            <th>작업</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (User user : users) { 
                            String initials = user.getFullName() != null && !user.getFullName().trim().isEmpty() 
                                ? user.getFullName().substring(0, 1).toUpperCase()
                                : user.getUsername().substring(0, 1).toUpperCase();
                        %>
                        <tr>
                            <td>
                                <div class="user-info-cell">
                                    <div class="user-avatar"><%= initials %></div>
                                    <div class="user-details">
                                        <div class="user-name"><%= user.getFullName() != null ? user.getFullName() : user.getUsername() %></div>
                                        <div class="user-username">@<%= user.getUsername() %></div>
                                    </div>
                                </div>
                            </td>
                            <td><%= user.getEmail() != null ? user.getEmail() : "-" %></td>
                            <td>
                                <span class="role-badge role-<%= user.getRole().toLowerCase().replace("_", "-") %>">
                                    <%= user.getRole() %>
                                </span>
                            </td>
                            <td>
                                <% if (user.isAccountLocked()) { %>
                                <span class="status-badge status-locked">잠김</span>
                                <% } else if (user.isActive()) { %>
                                <span class="status-badge status-active">활성</span>
                                <% } else { %>
                                <span class="status-badge status-inactive">비활성</span>
                                <% } %>
                            </td>
                            <td>
                                <%= user.getLastLogin() != null ? sdf.format(user.getLastLogin()) : "로그인 없음" %>
                            </td>
                            <td>
                                <div class="actions-cell">
                                    <a href="admin/user/detail?id=<%= user.getId() %>" class="btn btn-secondary btn-small">상세</a>
                                    <a href="admin/user/edit?id=<%= user.getId() %>" class="btn btn-secondary btn-small">수정</a>
                                    
                                    <% if (user.isAccountLocked()) { %>
                                    <form method="POST" action="admin/user/unlock" style="display: inline;">
                                        <input type="hidden" name="id" value="<%= user.getId() %>">
                                        <button type="submit" class="btn btn-warning btn-small">잠금해제</button>
                                    </form>
                                    <% } %>
                                    
                                    <% if (user.isActive()) { %>
                                    <form method="POST" action="admin/user/deactivate" style="display: inline;">
                                        <input type="hidden" name="id" value="<%= user.getId() %>">
                                        <button type="submit" class="btn btn-warning btn-small" 
                                                onclick="return confirm('정말 이 사용자를 비활성화하시겠습니까?')">비활성화</button>
                                    </form>
                                    <% } else { %>
                                    <form method="POST" action="admin/user/activate" style="display: inline;">
                                        <input type="hidden" name="id" value="<%= user.getId() %>">
                                        <button type="submit" class="btn btn-primary btn-small">활성화</button>
                                    </form>
                                    <% } %>
                                    
                                    <% if (!user.isSuperAdmin() || session.getAttribute("isSuperAdmin").equals(true)) { %>
                                    <form method="POST" action="admin/user/delete" style="display: inline;">
                                        <input type="hidden" name="id" value="<%= user.getId() %>">
                                        <button type="submit" class="btn btn-danger btn-small" 
                                                onclick="return confirm('정말 이 사용자를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.')">삭제</button>
                                    </form>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html> 