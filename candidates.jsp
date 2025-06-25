<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.model.Candidate" %>
<%
    List<Candidate> candidates = (List<Candidate>) request.getAttribute("candidates");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>지원자 목록</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .wide-table-container {
            max-width: 900px;
            margin: 0 auto;
        }
        table.candidate-table {
            width: 100%;
            min-width: 800px;
            border-collapse: collapse;
        }
        table.candidate-table th, table.candidate-table td {
            min-width: 120px;
            padding: 10px 8px;
            text-align: center;
        }
        table.candidate-table th {
            font-size: 1.1em;
        }
    </style>
</head>
<body>
<div class="container wide-table-container">
    <h2>지원자 목록</h2>
    <a href="candidates?action=new"><button>신규 지원자 등록</button></a>
    <a href="main.jsp"><button>홈으로 이동</button></a>
    <table class="candidate-table" border="1">
        <tr>
            <th>이름</th>
            <th>이메일</th>
            <th>연락처</th>
            <th>등록일</th>
            <th>관리</th>
        </tr>
        <% if (candidates != null) for (Candidate c : candidates) { %>
        <tr>
            <td><%= c.getName() %></td>
            <td><%= c.getEmail() %></td>
            <td><%= c.getPhone() %></td>
            <td><%= c.getCreatedAt() %></td>
            <td>
                <a href="candidates?action=detail&id=<%=c.getId()%>">상세</a> |
                <a href="candidates?action=edit&id=<%=c.getId()%>">수정</a> |
                <a href="candidates?action=delete&id=<%=c.getId()%>" onclick="return confirm('정말 삭제하시겠습니까?');">삭제</a>
            </td>
        </tr>
        <% } %>
    </table>
</div>
</body>
</html> 