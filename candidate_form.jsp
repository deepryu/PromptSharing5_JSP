<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.model.Candidate" %>
<%
    Candidate candidate = (Candidate) request.getAttribute("candidate");
    boolean isEdit = (candidate != null && candidate.getId() > 0);
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= isEdit ? "지원자 수정" : "신규 지원자 등록" %></title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="container">
    <h2><%= isEdit ? "지원자 수정" : "신규 지원자 등록" %></h2>
    <% if (error != null && !error.isEmpty()) { %>
        <div class="message error"><%= error %></div>
    <% } %>
    <form method="post" action="candidates">
        <% if (isEdit) { %>
            <input type="hidden" name="id" value="<%= candidate.getId() %>">
        <% } %>
        <input type="text" name="name" placeholder="이름" value="<%= candidate != null ? candidate.getName() : "" %>" required><br>
        <input type="email" name="email" placeholder="이메일" value="<%= candidate != null ? candidate.getEmail() : "" %>" required><br>
        <input type="text" name="phone" placeholder="연락처" value="<%= candidate != null ? candidate.getPhone() : "" %>"><br>
        <textarea name="resume" placeholder="이력서(요약)"><%= candidate != null ? candidate.getResume() : "" %></textarea><br>
        <button type="submit"><%= isEdit ? "수정" : "등록" %></button>
        <a href="candidates"><button type="button">목록으로</button></a>
    </form>
</div>
</body>
</html> 