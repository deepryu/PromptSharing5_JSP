<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // The error message is now passed from the LoginServlet via a request attribute.
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>로그인</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <h2>로그인 2</h2>
        <form method="post" action="login">
            <input type="text" name="username" placeholder="아이디" required>
            <input type="password" name="password" placeholder="비밀번호" required>
            <button type="submit">로그인</button>
        </form>
        <% if (error != null && !error.isEmpty()) { %>
            <div class="message error"><%= error %></div>
        <% } %>
        <div class="form-footer">
            <a href="register">회원가입</a>
        </div>
    </div>
</body>
</html> 