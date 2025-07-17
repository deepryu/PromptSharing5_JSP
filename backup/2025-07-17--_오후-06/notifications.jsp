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
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/common.css">
    <style>
        /* 알림 및 히스토리 페이지 전용 스타일 - 컴팩트 버전 */
        .success-box {
            background: #dcfce7;
            border: 1px solid #86efac;
            border-radius: 4px;
            padding: 8px 12px;
            margin-bottom: 12px;
            font-size: 0.9rem;
        }
        
        .success-box h4 {
            margin: 0 0 4px 0;
            color: #16a34a;
            font-size: 1rem;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
            gap: 8px;
            margin-bottom: 12px;
        }
        
        .stat-card {
            background: white;
            border: 1px solid #d0d7de;
            border-radius: 4px;
            padding: 8px;
            text-align: center;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        
        .stat-number {
            font-size: 1.4rem;
            font-weight: 700;
            color: #0969da;
            margin-bottom: 2px;
        }
        
        .stat-label {
            color: #656d76;
            font-size: 0.8rem;
        }
        
        .info-box {
            background: #f6f8fa;
            border: 1px solid #d0d7de;
            border-radius: 4px;
            padding: 10px;
            margin-bottom: 12px;
            text-align: center;
        }
        
        .info-box h3 {
            margin: 0 0 8px 0;
            font-size: 1.1rem;
        }
        
        .info-box h4 {
            margin: 0 0 6px 0;
            font-size: 1rem;
        }
        
        .info-box p {
            margin: 4px 0;
            font-size: 0.9rem;
        }
        
        .notification-item {
            border: 1px solid #d0d7de;
            border-radius: 4px;
            padding: 8px;
            margin-bottom: 6px;
            background: white;
            font-size: 0.9rem;
        }
        
        .notification-item strong {
            font-size: 0.95rem;
        }
        
        .notification-item p {
            margin: 4px 0;
        }
        
        .notification-item small {
            font-size: 0.8rem;
        }
        
        .section {
            margin-bottom: 12px;
        }
        
        .section h3 {
            margin: 0 0 8px 0;
            font-size: 1.1rem;
        }
        
        .dashboard-header h1 {
            margin: 0 0 12px 0;
            font-size: 1.3rem;
        }
        
        .btn {
            padding: 6px 12px;
            font-size: 0.85rem;
        }
        
        .status-badge {
            display: inline-block;
            padding: 2px 6px;
            border-radius: 3px;
            font-size: 0.75rem;
            margin-left: 8px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h2>🔔 알림 및 히스토리</h2>
            <div class="nav-buttons">
                <a href="main.jsp" class="btn">🏠 메인</a>
                <a href="candidates" class="btn">👥 인터뷰 대상자 관리</a>
                <a href="interview/list" class="btn">📅 인터뷰 일정 관리</a>
                <a href="questions" class="btn">💡 질문/평가 항목 관리</a>
                <a href="results" class="btn">📝 인터뷰 결과 기록/관리</a>
                <a href="statistics" class="btn">📊 통계 및 리포트</a>
                <a href="logout" class="btn btn-danger">🚪 로그아웃</a>
            </div>
        </div>

        <div class="main-dashboard">
            <div class="dashboard-header">
                <h1 style="text-align: center;">🔔 알림 및 히스토리 관리</h1>
            </div>
            
            <div class="dashboard-content">
                <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                    <div style="background: #fee2e2; border: 1px solid #fca5a5; border-radius: 4px; padding: 8px 12px; margin-bottom: 12px;">
                        <h4 style="margin: 0 0 4px 0; color: #dc2626; font-size: 1rem;">❌ 오류</h4>
                        <p style="margin: 0; color: #991b1b; font-size: 0.9rem;"><%= errorMessage %></p>
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
                </div>
                
                <div class="info-box">
                    <h3>📢 알림 및 히스토리 시스템</h3>
                    <p>시스템에서 발생하는 모든 알림과 활동 기록을 관리합니다.</p>
                    
                    <div style="margin-top: 10px;">
                        <div style="display: flex; justify-content: center; gap: 8px; flex-wrap: wrap;">
                            <a href="notifications?action=markAllRead" class="btn btn-primary">🔄 모든 알림 읽음 처리</a>
                            <a href="notifications?action=clearHistory" class="btn btn-secondary">🗑️ 히스토리 정리</a>
                        </div>
                    </div>
                </div>
                
                <% if (userNotifications != null && !userNotifications.isEmpty()) { %>
                    <div class="section">
                        <h3>📬 내 알림</h3>
                        <% for (Notification notification : userNotifications) { %>
                            <div class="notification-item">
                                <strong><%= notification.getTitle() %></strong>
                                <p><%= notification.getContent() %></p>
                                <small>📅 <%= notification.getCreatedAt() %></small>
                                <% if (!notification.isRead()) { %>
                                    <span class="status-badge" style="background: #fef3c7; color: #d97706;">읽지 않음</span>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="info-box">
                        <h4>📭 알림이 없습니다</h4>
                        <p>새로운 알림이 있으면 여기에 표시됩니다.</p>
                    </div>
                <% } %>
                
                <% if (recentActivities != null && !recentActivities.isEmpty()) { %>
                    <div class="section">
                        <h3>📜 최근 활동</h3>
                        <% for (ActivityHistory activity : recentActivities) { %>
                            <div class="notification-item">
                                <strong><%= activity.getAction() %></strong>
                                <p><%= activity.getDescription() %></p>
                                <small>📅 <%= activity.getCreatedAt() %> | 👤 <%= activity.getUsername() %></small>
                            </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="info-box">
                        <h4>📝 활동 기록이 없습니다</h4>
                        <p>사용자 활동이 기록되면 여기에 표시됩니다.</p>
                    </div>
                <% } %>
                
                <div class="info-box">
                    <h4>💡 시스템 정보</h4>
                    <p>• 알림은 실시간으로 업데이트됩니다.</p>
                    <p>• 활동 기록은 최근 30일간 보관됩니다.</p>
                    <p>• 읽지 않은 알림은 상단에 표시됩니다.</p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
