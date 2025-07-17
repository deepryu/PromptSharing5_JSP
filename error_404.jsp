<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isErrorPage="true" %>
<%
    String username = (String)session.getAttribute("username");
    String userRole = (String)session.getAttribute("userRole");
    String requestedUrl = (String)request.getAttribute("javax.servlet.error.request_uri");
    String referrer = request.getHeader("Referer");
    
    // 기본값 설정
    if (requestedUrl == null) requestedUrl = "알 수 없는 페이지";
    if (referrer == null) referrer = "main.jsp";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>페이지를 찾을 수 없습니다 - 채용 관리 시스템</title>
    
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
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            flex: 1;
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
            flex: 1;
        }
        
        .dashboard-header {
            background: #dc3545;
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
        
        .error-icon {
            font-size: 100px;
            margin-bottom: 30px;
            color: #dc3545;
        }
        
        .error-title {
            font-size: 48px;
            font-weight: 700;
            margin-bottom: 16px;
            color: #dc3545;
        }
        
        .error-subtitle {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 20px;
            color: #24292f;
        }
        
        .error-message {
            font-size: 16px;
            color: #656d76;
            margin-bottom: 30px;
            max-width: 600px;
            line-height: 1.6;
        }
        
        .error-details {
            background: #f6f8fa;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            padding: 20px;
            margin: 30px 0;
            max-width: 500px;
            text-align: left;
        }
        
        .error-details h3 {
            color: #dc3545;
            margin-bottom: 10px;
        }
        
        .error-details code {
            background: #f3f4f6;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
            font-size: 14px;
        }
        
        .btn {
            display: inline-block;
            padding: 12px 20px;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            text-decoration: none;
            background: white;
            color: #24292f;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            margin: 8px;
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
        
        .btn-danger {
            background: #dc3545;
            color: white;
            border-color: #dc3545;
        }
        
        .btn-danger:hover {
            background: #c82333;
            border-color: #bd2130;
        }
        
        .suggestions {
            background: #e7f3ff;
            border: 1px solid #0969da;
            border-radius: 6px;
            padding: 20px;
            margin: 20px 0;
            max-width: 500px;
        }
        
        .suggestions h4 {
            color: #0969da;
            margin-bottom: 10px;
        }
        
        .suggestions ul {
            list-style: none;
            padding: 0;
        }
        
        .suggestions li {
            margin: 8px 0;
            color: #0969da;
        }
        
        .suggestions a {
            color: #0969da;
            text-decoration: none;
        }
        
        .suggestions a:hover {
            text-decoration: underline;
        }
        
        .footer-note {
            margin-top: 40px;
            font-size: 12px;
            color: #656d76;
            border-top: 1px solid #d0d7de;
            padding-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- 상단 네비게이션 -->
        <div class="top-bar">
            <div>
                <strong>🚀 채용 관리 시스템</strong>
            </div>
            <div>
                <% if (username != null) { %>
                    <span style="margin-right: 15px;">
                        안녕하세요, <%= username %>님
                        <% if (userRole != null) { %>
                            (<%= userRole %>)
                        <% } %>
                    </span>
                    <a href="main.jsp" class="btn btn-secondary">🏠 메인으로</a>
                    <a href="logout" class="btn">🚪 로그아웃</a>
                <% } else { %>
                    <a href="login.jsp" class="btn btn-primary">🔑 로그인</a>
                <% } %>
            </div>
        </div>

        <!-- 에러 페이지 메인 -->
        <div class="main-dashboard">
            <div class="dashboard-header">
                <h1>❌ 페이지를 찾을 수 없습니다</h1>
            </div>
            
            <div class="dashboard-content">
                <div class="error-icon">🔍</div>
                
                <h2 class="error-title">404</h2>
                <h3 class="error-subtitle">요청하신 페이지가 존재하지 않습니다</h3>
                
                <p class="error-message">
                    죄송합니다. 요청하신 페이지를 찾을 수 없습니다.<br>
                    페이지가 이동되었거나 삭제되었을 수 있습니다.
                </p>
                
                <div class="error-details">
                    <h3>📋 요청 정보</h3>
                    <p><strong>요청된 URL:</strong> <code><%= requestedUrl %></code></p>
                    <% if (!"main.jsp".equals(referrer) && referrer != null) { %>
                        <p><strong>이전 페이지:</strong> <code><%= referrer %></code></p>
                    <% } %>
                    <p><strong>오류 시간:</strong> <%= new java.util.Date() %></p>
                </div>
                
                <div class="suggestions">
                    <h4>🎯 추천 행동</h4>
                    <ul>
                        <li>• URL 주소가 정확한지 확인해보세요</li>
                        <li>• <a href="main.jsp">메인 페이지</a>로 돌아가보세요</li>
                        <li>• <a href="javascript:history.back()">이전 페이지</a>로 돌아가보세요</li>
                        <% if ("ADMIN".equals(userRole)) { %>
                            <li>• <a href="admin/dashboard">관리자 대시보드</a>를 확인해보세요</li>
                        <% } %>
                    </ul>
                </div>
                
                <div style="margin-top: 30px;">
                    <a href="main.jsp" class="btn btn-primary">🏠 메인 페이지로</a>
                    <a href="javascript:history.back()" class="btn btn-secondary">🔙 이전 페이지로</a>
                    <% if ("ADMIN".equals(userRole)) { %>
                        <a href="admin/dashboard" class="btn">🛠️ 관리자 메뉴</a>
                    <% } %>
                    <a href="javascript:location.reload()" class="btn">🔄 새로고침</a>
                </div>
                
                <div class="footer-note">
                    <p>지속적으로 문제가 발생한다면 시스템 관리자에게 문의해주세요.</p>
                    <p>오류 코드: HTTP 404 - Page Not Found</p>
                </div>
            </div>
        </div>
    </div>

    <script>
        // 3초 후 자동으로 메인으로 이동 옵션 (주석 처리됨)
        // setTimeout(function() {
        //     if (confirm('메인 페이지로 이동하시겠습니까?')) {
        //         window.location.href = 'main.jsp';
        //     }
        // }, 10000);
        
        // ESC 키로 메인으로 이동
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                window.location.href = 'main.jsp';
            }
        });
        
        // 브라우저 뒤로가기 버튼 감지
        window.addEventListener('popstate', function(event) {
            console.log('404 페이지에서 뒤로가기 감지');
        });
    </script>
</body>
</html> 