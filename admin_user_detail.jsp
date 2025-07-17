<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    
    User user = (User) request.getAttribute("user");
    if (user == null) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND, "사용자를 찾을 수 없습니다.");
        return;
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>사용자 상세정보 - 관리자 대시보드</title>
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
        
        .top-bar h2 {
            font-size: 20px;
            font-weight: 600;
            margin: 0;
        }
        
        .back-link {
            color: white;
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 6px;
            transition: background-color 0.2s;
        }
        
        .back-link:hover {
            background-color: rgba(255, 255, 255, 0.1);
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
        }
        
        .dashboard-content {
            padding: 20px;
        }
        
        .user-profile {
            display: grid;
            grid-template-columns: auto 1fr;
            gap: 30px;
            align-items: start;
        }
        
        .user-avatar-large {
            width: 120px;
            height: 120px;
            background: linear-gradient(135deg, #0078d4, #1890ff);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            font-weight: bold;
            color: white;
            text-transform: uppercase;
        }
        
        .user-info {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }
        
        .user-header {
            display: flex;
            align-items: center;
            gap: 15px;
            flex-wrap: wrap;
        }
        
        .user-name {
            font-size: 24px;
            font-weight: 600;
            color: #24292f;
        }
        
        .user-username {
            font-size: 16px;
            color: #656d76;
        }
        
        .role-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .role-user {
            background-color: #dbeafe;
            color: #1d4ed8;
        }
        
        .role-admin {
            background-color: #dcfce7;
            color: #166534;
        }
        
        .user-details {
            background-color: #f6f8fa;
            border: 1px solid #d0d7de;
            border-radius: 8px;
            padding: 20px;
        }
        
        .detail-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #e1e5e9;
        }
        
        .detail-row:last-child {
            border-bottom: none;
        }
        
        .detail-label {
            font-weight: 600;
            color: #24292f;
            min-width: 120px;
        }
        
        .detail-value {
            color: #656d76;
            text-align: right;
        }
        
        .status-active {
            color: #1f883d;
            font-weight: 600;
        }
        
        .status-inactive {
            color: #cf222e;
            font-weight: 600;
        }
        
        .action-buttons {
            margin-top: 30px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        
        .btn-primary {
            background-color: #1f883d;
            color: white;
        }
        
        .btn-primary:hover {
            background-color: #1a7f37;
        }
        
        .btn-secondary {
            background-color: white;
            color: #24292f;
            border: 1px solid #d0d7de;
        }
        
        .btn-secondary:hover {
            background-color: #f6f8fa;
        }
        
        .btn-danger {
            background-color: #cf222e;
            color: white;
        }
        
        .btn-danger:hover {
            background-color: #a40e26;
        }
        
        @media (max-width: 768px) {
            .user-profile {
                grid-template-columns: 1fr;
                text-align: center;
            }
            
            .detail-row {
                flex-direction: column;
                align-items: flex-start;
                gap: 4px;
            }
            
            .detail-value {
                text-align: left;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h2>👤 사용자 상세정보</h2>
            <a href="admin/users" class="back-link">← 사용자 목록으로 돌아가기</a>
        </div>
        
        <div class="main-dashboard">
            <div class="dashboard-header">
                <h2><%= user.getFullName() != null ? user.getFullName() : user.getUsername() %>님의 상세정보</h2>
            </div>
            
            <div class="dashboard-content">
                <div class="user-profile">
                    <%
                        String initials = user.getFullName() != null && !user.getFullName().trim().isEmpty() 
                            ? user.getFullName().substring(0, 1).toUpperCase()
                            : user.getUsername().substring(0, 1).toUpperCase();
                    %>
                    <div class="user-avatar-large"><%= initials %></div>
                    
                    <div class="user-info">
                        <div class="user-header">
                            <div class="user-name"><%= user.getFullName() != null ? user.getFullName() : user.getUsername() %></div>
                            <div class="user-username">@<%= user.getUsername() %></div>
                            <span class="role-badge role-<%= user.getRole().toLowerCase() %>">
                                <%= user.getRole() %>
                            </span>
                        </div>
                        
                        <div class="user-details">
                            <div class="detail-row">
                                <span class="detail-label">🆔 사용자 ID</span>
                                <span class="detail-value"><%= user.getId() %></span>
                            </div>
                            
                            <div class="detail-row">
                                <span class="detail-label">👤 사용자명</span>
                                <span class="detail-value"><%= user.getUsername() %></span>
                            </div>
                            
                            <% if (user.getFullName() != null && !user.getFullName().trim().isEmpty()) { %>
                            <div class="detail-row">
                                <span class="detail-label">📝 전체 이름</span>
                                <span class="detail-value"><%= user.getFullName() %></span>
                            </div>
                            <% } %>
                            
                            <% if (user.getEmail() != null && !user.getEmail().trim().isEmpty()) { %>
                            <div class="detail-row">
                                <span class="detail-label">📧 이메일</span>
                                <span class="detail-value"><%= user.getEmail() %></span>
                            </div>
                            <% } %>
                            
                            <div class="detail-row">
                                <span class="detail-label">🔑 역할</span>
                                <span class="detail-value">
                                    <span class="role-badge role-<%= user.getRole().toLowerCase() %>">
                                        <%= user.getRole() %>
                                    </span>
                                </span>
                            </div>
                            
                            <div class="detail-row">
                                <span class="detail-label">🔄 상태</span>
                                <span class="detail-value <%= user.isActive() ? "status-active" : "status-inactive" %>">
                                    <%= user.isActive() ? "활성" : "비활성" %>
                                </span>
                            </div>
                            
                            <% if (user.getCreatedAt() != null) { %>
                            <div class="detail-row">
                                <span class="detail-label">📅 가입일</span>
                                <span class="detail-value"><%= sdf.format(user.getCreatedAt()) %></span>
                            </div>
                            <% } %>
                            
                            <!-- 수정일 정보는 현재 User 클래스에서 지원하지 않음 -->
                        </div>
                        
                        <div class="action-buttons">
                            <a href="admin/user/edit?id=<%= user.getId() %>" class="btn btn-primary">
                                ✏️ 사용자 수정
                            </a>
                            
                            <% if (user.isActive()) { %>
                            <a href="admin/user/deactivate?id=<%= user.getId() %>" class="btn btn-danger"
                               onclick="return confirm('<%= user.getUsername() %>님을 비활성화하시겠습니까?')">
                                🔒 계정 비활성화
                            </a>
                            <% } else { %>
                            <a href="admin/user/activate?id=<%= user.getId() %>" class="btn btn-primary"
                               onclick="return confirm('<%= user.getUsername() %>님을 활성화하시겠습니까?')">
                                🔓 계정 활성화
                            </a>
                            <% } %>
                            
                            <a href="admin/users" class="btn btn-secondary">
                                📋 사용자 목록
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html> 