<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.model.SystemSettings" %>
<%@ page import="java.util.Map" %>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    @SuppressWarnings("unchecked")
    Map<String, SystemSettings> settings = (Map<String, SystemSettings>) request.getAttribute("settings");
    @SuppressWarnings("unchecked")
    Map<String, Object> systemStats = (Map<String, Object>) request.getAttribute("systemStats");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) session.getAttribute("successMessage");
    if (successMessage != null) session.removeAttribute("successMessage");
    if (settings == null) settings = new java.util.HashMap<>();
    if (systemStats == null) systemStats = new java.util.HashMap<>();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>시스템 설정</title>
    <style>
        body {
            background: #f0f0f0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
        }
        
        .container {
            max-width: 1000px;
            margin: 0 auto;
        }
        
        .top-bar {
            background: white;
            border: 1px solid #d0d7de;
            padding: 10px 20px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .top-bar h2 {
            margin: 0;
            color: #24292f;
            font-size: 1.2rem;
            font-weight: 600;
        }
        
        .top-bar button, .top-bar a {
            padding: 6px 12px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            background: white;
            color: #24292f;
            cursor: pointer;
            font-size: 0.85rem;
            text-decoration: none;
            transition: all 0.2s;
            margin-left: 8px;
        }
        
        .top-bar button:hover, .top-bar a:hover {
            background: #f6f8fa;
            border-color: #8c959f;
        }
        
        .main-dashboard {
            background: white;
            border: 1px solid #d0d7de;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .dashboard-header {
            background: #0078d4;
            color: white;
            padding: 15px 25px;
            border-bottom: 1px solid #106ebe;
        }
        
        .dashboard-header h1 {
            margin: 0;
            font-size: 1.3rem;
            font-weight: 600;
        }
        
        .dashboard-content {
            padding: 20px;
        }
        
        .alert {
            padding: 12px 16px;
            border-radius: 3px;
            margin-bottom: 20px;
            border: 1px solid transparent;
        }
        
        .alert-success {
            background: #d1ecf1;
            color: #0c5460;
            border-color: #bee5eb;
        }
        
        .alert-danger {
            background: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1px;
            background: #d0d7de;
            border: 1px solid #d0d7de;
            margin-bottom: 20px;
        }
        
        .stat-item {
            background: white;
            padding: 15px 20px;
            text-align: center;
            font-size: 0.9rem;
        }
        
        .stat-number {
            font-size: 1.5rem;
            font-weight: 600;
            color: #0969da;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: #656d76;
            font-size: 0.85rem;
        }
        
        .menu-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1px;
            background: #d0d7de;
            border: 1px solid #d0d7de;
            margin-bottom: 20px;
        }
        
        .menu-item {
            background: white;
            display: block;
            padding: 15px 20px;
            text-decoration: none;
            color: #24292f;
            transition: background-color 0.2s;
            border: none;
            font-size: 0.9rem;
            cursor: pointer;
        }
        
        .menu-item:hover {
            background: #f6f8fa;
        }
        
        .menu-item.primary {
            background: #dbeafe;
            border-left: 4px solid #3b82f6;
        }
        
        .menu-item.danger {
            background: #fef2f2;
            border-left: 4px solid #ef4444;
        }
        
        .setting-section {
            background: white;
            border: 1px solid #d0d7de;
            margin-bottom: 20px;
        }
        
        .setting-header {
            background: #f6f8fa;
            padding: 12px 16px;
            border-bottom: 1px solid #d0d7de;
            font-weight: 600;
            color: #24292f;
        }
        
        .setting-content {
            padding: 16px;
        }
        
        .setting-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #f6f8fa;
        }
        
        .setting-item:last-child {
            border-bottom: none;
        }
        
        .setting-info {
            flex: 1;
        }
        
        .setting-key {
            font-weight: 500;
            color: #24292f;
            margin-bottom: 4px;
        }
        
        .setting-description {
            color: #656d76;
            font-size: 0.85rem;
        }
        
        .setting-value {
            color: #0969da;
            font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
            padding: 4px 8px;
            background: #f6f8fa;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            margin-right: 10px;
            font-size: 0.85rem;
        }
        
        .btn {
            padding: 6px 12px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            background: white;
            color: #24292f;
            cursor: pointer;
            font-size: 0.85rem;
            text-decoration: none;
            transition: all 0.2s;
            display: inline-block;
        }
        
        .btn:hover {
            background: #f6f8fa;
            border-color: #8c959f;
        }
        
        .btn-primary {
            background: #0969da;
            color: white;
            border-color: #0969da;
        }
        
        .btn-primary:hover {
            background: #0550ae;
            border-color: #0550ae;
        }
        
        .btn-danger {
            background: #cf222e;
            color: white;
            border-color: #cf222e;
        }
        
        .btn-danger:hover {
            background: #a40e26;
            border-color: #a40e26;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #656d76;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h2>⚙️ 시스템 설정</h2>
            <div>
                <a href="main.jsp">🏠 메인</a>
                <a href="candidates">👥 인터뷰 대상자 관리</a>
                <a href="interview/list">📅 인터뷰 일정 관리</a>
                <a href="questions">💡 질문/평가 항목 관리</a>
                <a href="results">📝 인터뷰 결과 기록/관리</a>
                <a href="statistics">📊 통계 및 리포트</a>
                <a href="logout" class="btn-danger">🚪 로그아웃</a>
            </div>
        </div>
        
        <div class="main-dashboard">
            <div class="dashboard-header">
                <h1 style="text-align: center;">⚙️ 시스템 설정 관리</h1>
            </div>
            <div class="dashboard-content">
                <% if (successMessage != null) { %>
                    <div class="alert alert-success">✅ <%= successMessage %></div>
                <% } %>
                <% if (errorMessage != null) { %>
                    <div class="alert alert-danger">⚠️ <%= errorMessage %></div>
                <% } %>
                
                <div class="stats-grid">
                    <div class="stat-item">
                        <div class="stat-number"><%= systemStats.getOrDefault("totalSettings", 0) %></div>
                        <div class="stat-label">총 설정 항목</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number"><%= systemStats.getOrDefault("javaVersion", "N/A") %></div>
                        <div class="stat-label">Java 버전</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number"><%= systemStats.getOrDefault("maxMemory", 0) %>MB</div>
                        <div class="stat-label">최대 메모리</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number"><%= systemStats.getOrDefault("freeMemory", 0) %>MB</div>
                        <div class="stat-label">사용 가능 메모리</div>
                    </div>
                </div>
                
                <div class="menu-grid">
                    <a href="settings?action=backup" class="menu-item primary">
                        💾 백업 관리
                    </a>
                    <a href="settings?action=logs" class="menu-item">
                        📋 시스템 로그
                    </a>
                    <form action="settings" method="post" style="display: contents;">
                        <input type="hidden" name="action" value="reset">
                        <button type="submit" class="menu-item danger" onclick="return confirm('모든 설정을 기본값으로 초기화하시겠습니까?');">
                            🔄 설정 초기화
                        </button>
                    </form>
                </div>
                
                <% if (settings.isEmpty()) { %>
                    <div class="empty-state">
                        <h3>⚙️ 설정 항목을 불러오는 중...</h3>
                        <p>시스템 설정을 초기화하고 있습니다.</p>
                    </div>
                <% } else { %>
                    <div class="setting-section">
                        <div class="setting-header">🖥️ 시스템 설정</div>
                        <div class="setting-content">
                            <% 
                            boolean hasSystemSettings = false;
                            for (Map.Entry<String, SystemSettings> entry : settings.entrySet()) { 
                                SystemSettings setting = entry.getValue();
                                if ("SYSTEM".equals(setting.getCategory())) {
                                    hasSystemSettings = true;
                            %>
                                <div class="setting-item">
                                    <div class="setting-info">
                                        <div class="setting-key"><%= setting.getSettingKey() %></div>
                                        <div class="setting-description"><%= setting.getDescription() %></div>
                                    </div>
                                    <div class="setting-value"><%= setting.getSettingValue() %></div>
                                    <div>
                                        <a href="settings?action=edit&key=<%= setting.getSettingKey() %>" class="btn btn-primary">수정</a>
                                    </div>
                                </div>
                            <% } } %>
                            <% if (!hasSystemSettings) { %>
                                <div class="empty-state">시스템 설정이 없습니다.</div>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>