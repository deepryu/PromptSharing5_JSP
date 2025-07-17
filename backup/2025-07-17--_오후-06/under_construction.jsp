<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String username = (String)session.getAttribute("username");
    String userRole = (String)session.getAttribute("userRole");
    String featureName = request.getParameter("feature");
    String returnUrl = request.getParameter("returnUrl");
    
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 기본값 설정
    if (featureName == null) featureName = "해당 기능";
    if (returnUrl == null) returnUrl = "main.jsp";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>준비중 - 채용 관리 시스템</title>
    
    <!-- 파비콘 설정 -->
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/favicon.ico">
    <link rel="apple-touch-icon" sizes="180x180" href="${pageContext.request.contextPath}/images/apple-touch-icon.png">
    <link rel="icon" type="image/png" sizes="32x32" href="${pageContext.request.contextPath}/images/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="${pageContext.request.contextPath}/images/favicon-16x16.png">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Noto Sans", Helvetica, Arial, sans-serif;
            background-color: #f0f0f0;
            color: #24292f;
            line-height: 1.5;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .top-bar {
            background: white;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            padding: 16px 20px;
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .main-dashboard {
            background: white;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            overflow: hidden;
        }
        
        .dashboard-header {
            background: #0078d4;
            color: white;
            padding: 20px;
            text-align: center;
        }
        
        .dashboard-content {
            padding: 40px 20px;
            text-align: center;
            min-height: 400px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }
        
        .construction-icon {
            font-size: 80px;
            margin-bottom: 30px;
            color: #fb8500;
        }
        
        .construction-title {
            font-size: 32px;
            font-weight: 600;
            margin-bottom: 16px;
            color: #24292f;
        }
        
        .construction-message {
            font-size: 16px;
            color: #656d76;
            margin-bottom: 30px;
            max-width: 600px;
            line-height: 1.6;
        }
        
        .feature-info {
            background: #f6f8fa;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            padding: 20px;
            margin: 30px 0;
            max-width: 500px;
        }
        
        .feature-info h3 {
            color: #0078d4;
            margin-bottom: 10px;
        }
        
        .btn {
            display: inline-block;
            padding: 8px 16px;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            text-decoration: none;
            background: white;
            color: #24292f;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            margin: 5px;
        }
        
        .btn:hover {
            background: #f3f4f6;
            border-color: #8c959f;
        }
        
        .btn-primary {
            background: #1f883d;
            color: white;
            border-color: #1f883d;
        }
        
        .btn-primary:hover {
            background: #1a7f37;
            border-color: #1a7f37;
        }
        
        .btn-secondary {
            background: #0078d4;
            color: white;
            border-color: #0078d4;
        }
        
        .btn-secondary:hover {
            background: #106ebe;
            border-color: #106ebe;
        }
        
        .progress-info {
            background: #dbeafe;
            border: 1px solid #3b82f6;
            border-radius: 6px;
            padding: 15px;
            margin: 20px 0;
            max-width: 400px;
        }
        
        .progress-info h4 {
            color: #1e40af;
            margin-bottom: 8px;
        }
        
        .progress-info p {
            color: #1e40af;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- 상단 네비게이션 -->
        <div class="top-bar">
            <div>
                <strong>🚀 관리자 대시보드</strong>
            </div>
            <div>
                <span style="margin-right: 15px;">
                    안녕하세요, <%= username %>님
                    <% if (userRole != null) { %>
                        (<%= userRole %>)
                    <% } %>
                </span>
                
                <a href="<%= returnUrl %>" class="btn btn-secondary">🔙 돌아가기</a>
                <a href="logout" class="btn">🚪 로그아웃</a>
            </div>
        </div>

        <!-- 메인 대시보드 -->
        <div class="main-dashboard">
            <div class="dashboard-header">
                <h1>⚠️ 기능 준비중</h1>
            </div>
            
            <div class="dashboard-content">
                <div class="construction-icon">🚧</div>
                
                <h2 class="construction-title"><%= featureName %> 개발 중</h2>
                
                <p class="construction-message">
                    죄송합니다. 현재 <strong><%= featureName %></strong> 기능을 개발 중입니다.<br>
                    빠른 시일 내에 제공할 수 있도록 최선을 다하고 있습니다.
                </p>
                
                <div class="feature-info">
                    <h3>📋 개발 상태 안내</h3>
                    <p>• 현재 기능: 설계 및 개발 진행 중</p>
                    <p>• 예상 완료: 순차적 개발 예정</p>
                    <p>• 알림: 완료 시 공지사항을 통해 안내</p>
                </div>
                
                <div class="progress-info">
                    <h4>🔄 진행 중인 작업</h4>
                    <p>관리자 기능들을 단계적으로 구현하고 있습니다.</p>
                </div>
                
                <div style="margin-top: 30px;">
                    <a href="<%= returnUrl %>" class="btn btn-primary">🏠 메인으로 돌아가기</a>
                    <a href="main.jsp" class="btn">📊 대시보드로</a>
                    <% if ("ADMIN".equals(userRole)) { %>
                        <a href="admin/dashboard" class="btn btn-secondary">🛠️ 관리자 메뉴</a>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <script>
        // 3초 후 자동으로 알림 표시 (선택사항)
        setTimeout(function() {
            console.log('기능 개발 상태: <%= featureName %> 준비중');
        }, 3000);
        
        // 뒤로가기 버튼 클릭 이벤트
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                window.location.href = '<%= returnUrl %>';
            }
        });
    </script>
</body>
</html> 