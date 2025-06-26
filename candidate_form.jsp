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
        <select name="team" required>
            <option value="">지원팀 선택</option>
            <option value="개발팀" <%= candidate != null && "개발팀".equals(candidate.getTeam()) ? "selected" : "" %>>개발팀</option>
            <option value="기획팀" <%= candidate != null && "기획팀".equals(candidate.getTeam()) ? "selected" : "" %>>기획팀</option>
            <option value="디자인팀" <%= candidate != null && "디자인팀".equals(candidate.getTeam()) ? "selected" : "" %>>디자인팀</option>
            <option value="마케팅팀" <%= candidate != null && "마케팅팀".equals(candidate.getTeam()) ? "selected" : "" %>>마케팅팀</option>
            <option value="영업팀" <%= candidate != null && "영업팀".equals(candidate.getTeam()) ? "selected" : "" %>>영업팀</option>
            <option value="인사팀" <%= candidate != null && "인사팀".equals(candidate.getTeam()) ? "selected" : "" %>>인사팀</option>
            <option value="재무팀" <%= candidate != null && "재무팀".equals(candidate.getTeam()) ? "selected" : "" %>>재무팀</option>
        </select><br>
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