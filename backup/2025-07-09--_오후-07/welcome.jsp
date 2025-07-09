<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
    // XSS 방어를 위해 HTML 특수 문자를 이스케이프하는 함수
    public String escapeHtml(String text) {
        if (text == null) {
            return "";
        }
        return text.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#x27;")
                   .replace("/", "&#x2F;");
    }
%>
<%
    String username = (String)session.getAttribute("username");
    // Although a filter should handle this, it's good practice to have a fallback check.
    if (username == null) {
        response.sendRedirect("login");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>환영합니다</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <h2 class="welcome-message"><%= escapeHtml(username) %>님, 환영합니다!</h2>
        <a href="logout">로그아웃</a>
    </div>
</body>
</html> 