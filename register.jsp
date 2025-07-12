<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입 - 채용 관리 시스템</title>
    
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
        
        .register-container {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 400px;
        }
        
        .register-header {
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .register-header h1 {
            color: #333;
            margin-bottom: 0.5rem;
            font-size: 1.8rem;
        }
        
        .register-header p {
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
        
        .btn-register {
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
        
        .btn-register:hover {
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
        
        .success {
            background: #e8f5e8;
            color: #2e7d32;
            padding: 0.75rem;
            border-radius: 5px;
            margin-bottom: 1rem;
            border-left: 4px solid #2e7d32;
        }
        
        .login-link {
            text-align: center;
            margin-top: 1rem;
            color: #666;
        }
        
        .login-link a {
            color: #667eea;
            text-decoration: none;
        }
        
        .login-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="register-container">
        <div class="register-header">
            <h1>👤 채용 관리 시스템</h1>
            <p>새 계정을 만드세요</p>
        </div>
        
        <% if (error != null && !error.isEmpty()) { %>
            <div class="error">
                <strong>오류:</strong> <%= error %>
            </div>
        <% } %>
        
        <% if (success != null && !success.isEmpty()) { %>
            <div class="success">
                <strong>성공:</strong> <%= success %>
            </div>
        <% } %>
        
        <form action="register" method="post">
            <div class="form-group">
                <label for="username">사용자명:</label>
                <input type="text" id="username" name="username" required>
            </div>
            
            <div class="form-group">
                <label for="password">비밀번호:</label>
                <input type="password" id="password" name="password" required>
            </div>
            
            <button type="submit" class="btn-register">회원가입</button>
        </form>
        
        <div class="login-link">
            이미 계정이 있으신가요? <a href="login.jsp">로그인</a>
        </div>
    </div>
</body>
</html> 