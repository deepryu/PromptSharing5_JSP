<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.model.Notification" %>
<%@ page import="com.example.model.ActivityHistory" %>
<%
    String username = (String)session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 서블릿에서 전달된 데이터 받기
    List<Notification> userNotifications = (List<Notification>) request.getAttribute("userNotifications");
    List<ActivityHistory> recentActivities = (List<ActivityHistory>) request.getAttribute("recentActivities");
    Integer unreadCount = (Integer) request.getAttribute("unreadCount");
    String errorMessage = (String) request.getAttribute("error");
    
    if (unreadCount == null) unreadCount = 0;
%>
<!DOCTYPE html>
<html>
<head>
    <title>알림 및 히스토리 - 채용 관리 시스템</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            background: #f0f0f0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
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
        
        .top-bar .nav-links a {
            margin-left: 15px;
            color: #0969da;
            text-decoration: none;
            font-size: 0.9rem;
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
        
        .success-box {
            background: #dcfce7;
            border: 1px solid #86efac;
            border-radius: 6px;
            padding: 15px;
            margin-bottom: 20px;
        }
        
        .success-box h4 {
            margin: 0 0 8px 0;
            color: #16a34a;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .stat-card {
            background: white;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            padding: 15px;
            text-align: center;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        
        .stat-number {
            font-size: 1.8rem;
            font-weight: 700;
            color: #0969da;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: #656d76;
            font-size: 0.9rem;
        }
        
        .info-box {
            background: #f6f8fa;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            padding: 20px;
            margin-bottom: 20px;
            text-align: center;
        }
        
        .btn {
            padding: 8px 16px;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            background: #1f883d;
            color: white;
            text-decoration: none;
            font-size: 0.9rem;
            display: inline-block;
        }
        
        .notification-item {
            border: 1px solid #d0d7de;
            border-radius: 6px;
            padding: 15px;
            margin-bottom: 10px;
            background: white;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h2>🔔 알림 및 히스토리</h2>
            <div class="nav-links">
                <a href="main.jsp">🏠 메인</a>
                <a href="candidates">👥 인터뷰 대상자 관리</a>
                <a href="interview/list">📅 인터뷰 일정 관리</a>
                <a href="questions">💡 질문/평가 항목 관리</a>
                <a href="results">📝 인터뷰 결과 기록/관리</a>
                <a href="statistics">📊 통계 및 리포트</a>
                <a href="logout">🚪 로그아웃</a>
            </div>
        </div>

        <div class="main-dashboard">
            <div class="dashboard-header">
                <h1>알림 및 히스토리 관리</h1>
            </div>
            
            <div class="dashboard-content">
                <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                    <div style="background: #fee2e2; border: 1px solid #fca5a5; border-radius: 6px; padding: 15px; margin-bottom: 20px;">
                        <h4 style="margin: 0 0 8px 0; color: #dc2626;">❌ 오류</h4>
                        <p style="margin: 0; color: #991b1b;"><%= errorMessage %></p>
                    </div>
                <% } else { %>
                    <div class="success-box">
                        <h4>✅ 알림 및 히스토리 시스템이 정상 작동 중입니다!</h4>
                        <p style="margin: 0; color: #15803d;">시스템이 성공적으로 로드되었습니다.</p>
                    </div>
                <% } %>
                
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-number"><%= unreadCount %></div>
                        <div class="stat-label">읽지 않은 알림</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= userNotifications != null ? userNotifications.size() : 0 %></div>
                        <div class="stat-label">전체 알림</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">0</div>
                        <div class="stat-label">오늘 활동</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">1</div>
                        <div class="stat-label">로그인 세션</div>
                    </div>
                </div>
                
                <% if (userNotifications == null || userNotifications.isEmpty()) { %>
                    <div class="info-box">
                        <h3>🚀 알림 및 히스토리 시스템 준비 완료!</h3>
                        <p>아직 알림이나 활동 기록이 없습니다. 시스템을 사용하시면 자동으로 기록됩니다.</p>
                        <div style="margin-top: 20px;">
                            <a href="main.jsp" class="btn">메인 대시보드로 이동</a>
                        </div>
                    </div>
                <% } else { %>
                    <h3>📬 알림 목록</h3>
                    <% for (Notification notification : userNotifications) { %>
                        <div class="notification-item">
                            <h4><%= notification.getTitle() %></h4>
                            <p><%= notification.getContent() != null ? notification.getContent() : "" %></p>
                            <small><%= notification.getCreatedAt() %></small>
                        </div>
                    <% } %>
                <% } %>
                
                <% if (recentActivities != null && !recentActivities.isEmpty()) { %>
                    <h3>📈 최근 활동</h3>
                    <% for (ActivityHistory activity : recentActivities) { %>
                        <div class="notification-item">
                            <p><%= activity.getDescription() %></p>
                            <small>사용자: <%= activity.getUsername() %> • <%= activity.getCreatedAt() %></small>
                        </div>
                    <% } %>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>
