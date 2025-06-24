<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.model.Candidate" %>
<%
    Candidate candidate = (Candidate) request.getAttribute("candidate");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>지원자 상세 정보</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="container">
    <h2>지원자 상세 정보</h2>
    <% if (candidate != null) { %>
        <p><strong>이름:</strong> <%= candidate.getName() %></p>
        <p><strong>이메일:</strong> <%= candidate.getEmail() %></p>
        <p><strong>연락처:</strong> <%= candidate.getPhone() %></p>
        <p><strong>이력서(요약):</strong><br><pre><%= candidate.getResume() %></pre></p>
        <p><strong>등록일:</strong> <%= candidate.getCreatedAt() %></p>
        <p><strong>수정일:</strong> <%= candidate.getUpdatedAt() %></p>
        <a href="candidates?action=edit&id=<%=candidate.getId()%>"><button>수정</button></a>
        <a href="candidates?action=delete&id=<%=candidate.getId()%>" onclick="return confirm('정말 삭제하시겠습니까?');"><button>삭제</button></a>
        <a href="candidates"><button>목록으로</button></a>
    <% } else { %>
        <p>지원자 정보를 찾을 수 없습니다.</p>
        <a href="candidates"><button>목록으로</button></a>
    <% } %>
</div>
</body>
</html> 