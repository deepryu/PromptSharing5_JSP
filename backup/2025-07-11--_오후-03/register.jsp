<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <h2>회원가입</h2>
        <form method="post" action="register">
            <input type="text" name="username" placeholder="아이디" required>
            <input type="password" name="password" placeholder="비밀번호" required>
            <button type="submit">회원가입</button>
        </form>
        <% if (error != null && !error.isEmpty()) { %>
            <div class="message error"><%= error %></div>
        <% } %>
        <% if (success != null && !success.isEmpty()) { %>
            <div class="message success"><%= success %></div>
        <% } %>
        <div class="form-footer">
            <a href="login">로그인으로 돌아가기</a>
        </div>
    </div>
</body>
</html> 