<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // 현재 세션 상태 확인
    HttpSession currentSession = request.getSession(false);
    
    if (currentSession != null) {
        String username = (String) currentSession.getAttribute("username");
        
        if (username != null) {
            // 에러 메시지가 있는 경우 (권한 없는 접근 등) 리다이렉트하지 않음
            String sessionError = (String) currentSession.getAttribute("errorMessage");
            if (sessionError == null) {
                response.sendRedirect("main.jsp");
                return;
            }
        }
    }
    
    String error = (String) request.getAttribute("error");
    String sessionError = null;
    
    // 세션에서 에러 메시지 확인 (권한 없는 접근 시)
    if (currentSession != null) {
        sessionError = (String) currentSession.getAttribute("errorMessage");
        if (sessionError != null) {
            currentSession.removeAttribute("errorMessage"); // 한 번 표시 후 제거
        }
    }
    
    // 최종 에러 메시지 결정
    if (error == null && sessionError != null) {
        error = sessionError;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 - 채용 관리 시스템</title>
    
    <!-- 파비콘 설정 -->
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/favicon.ico">
    <link rel="icon" type="image/png" sizes="32x32" href="${pageContext.request.contextPath}/images/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="${pageContext.request.contextPath}/images/favicon-16x16.png">
    <link rel="apple-touch-icon" sizes="180x180" href="${pageContext.request.contextPath}/images/apple-touch-icon.png">
    
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .login-container {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 400px;
        }
        
        .login-header {
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .login-header h1 {
            color: #333;
            margin-bottom: 0.5rem;
            font-size: 1.8rem;
        }
        
        .login-header p {
            color: #666;
            margin: 0;
        }
        
        .form-group {
            margin-bottom: 1rem;
        }
        
        label {
            display: block;
            margin-bottom: 0.5rem;
            color: #333;
            font-weight: 500;
        }
        
        input[type="text"], input[type="password"] {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 1rem;
            transition: border-color 0.3s;
            box-sizing: border-box;
        }
        
        input[type="text"]:focus, input[type="password"]:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .btn-login {
            width: 100%;
            padding: 0.75rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 1rem;
            cursor: pointer;
            transition: transform 0.2s;
        }
        
        .btn-login:hover {
            transform: translateY(-2px);
        }
        
        .error {
            background: #ffebee;
            color: #c62828;
            padding: 0.75rem;
            border-radius: 5px;
            margin-bottom: 1rem;
            border-left: 4px solid #c62828;
        }
        
        .register-link {
            text-align: center;
            margin-top: 1rem;
            color: #666;
        }
        
        .register-link a {
            color: #667eea;
            text-decoration: none;
        }
        
        .register-link a:hover {
            text-decoration: underline;
        }
    </style>
    <script>
        console.log('🔍 [login.jsp-JS] 페이지 로드됨');
        console.log('🔍 [login.jsp-JS] 현재 URL:', window.location.href);
        console.log('🔍 [login.jsp-JS] Document ready 상태:', document.readyState);
        
        // 페이지 로드 완료시 추가 로그
        window.addEventListener('load', function() {
            console.log('✅ [login.jsp-JS] 페이지 완전 로드 완료');
        });
        
        // 폼 제출시 로그
        function logFormSubmit() {
            console.log('📤 [login.jsp-JS] 로그인 폼 제출');
            const username = document.getElementById('username').value;
            console.log('📤 [login.jsp-JS] 입력된 username:', username);
        }
    </script>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <h1>🏢 채용 관리 시스템</h1>
            <p>시스템에 로그인하세요</p>
        </div>
        
        <% if (error != null) { %>
            <div class="error">
                <strong>오류:</strong> <%= error %>
            </div>
        <% } %>
        
        <form action="login" method="post" onsubmit="logFormSubmit()">
            <div class="form-group">
                <label for="username">사용자명:</label>
                <input type="text" id="username" name="username" required>
            </div>
            
            <div class="form-group">
                <label for="password">비밀번호:</label>
                <input type="password" id="password" name="password" required>
            </div>
            
            <button type="submit" class="btn-login">로그인</button>
        </form>
        
        <div class="register-link">
            계정이 없으신가요? <a href="register.jsp">회원가입</a>
        </div>
    </div>
</body>
</html> 