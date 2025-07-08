<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.model.Candidate" %>
<%
    String username = (String)session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<%
    List<Candidate> candidates = (List<Candidate>) request.getAttribute("candidates");
    if (candidates == null) {
        candidates = new java.util.ArrayList<>();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>지원자 목록</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #0078d4; color: white; padding: 20px; }
        .content { padding: 20px; }
        .btn { padding: 8px 16px; background: #2da44e; color: white; text-decoration: none; margin: 5px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>지원자 목록</h1>
    </div>
    <div class="content">
        <a href="candidates?action=new" class="btn">새 지원자 추가</a>
        <a href="main.jsp" class="btn">메인으로</a>
        
        <h3>총 <%= candidates.size() %>명의 지원자</h3>
        
        <% if (candidates.isEmpty()) { %>
            <p>등록된 지원자가 없습니다.</p>
        <% } else { %>
            <% for (Candidate candidate : candidates) { %>
                <div style="border: 1px solid #ccc; margin: 10px; padding: 10px;">
                    <strong><%= candidate.getName() %></strong> - <%= candidate.getEmail() %>
                    <br>팀: <%= candidate.getTeam() %>
                    <br>
                    <a href="candidates?action=detail&id=<%= candidate.getId() %>">상세</a>
                    <a href="candidates?action=edit&id=<%= candidate.getId() %>">수정</a>
                </div>
            <% } %>
        <% } %>
    </div>
</body>
</html>
