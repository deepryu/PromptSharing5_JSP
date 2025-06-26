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
            max-width: 1000px;
            margin: 0 auto;
        }
        .button-container {
            margin-bottom: 15px;
            text-align: center;
        }
        .button-container button {
            margin-right: 10px;
            margin-bottom: 10px;
        }
        table.candidate-table {
            width: 100%;
            min-width: 900px;
            border-collapse: collapse;
            margin-top: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border-radius: 8px;
            overflow: hidden;
        }
        table.candidate-table th, table.candidate-table td {
            min-width: 100px;
            padding: 12px 8px;
            text-align: center;
            border: 1px solid #ddd;
        }
        table.candidate-table th {
            font-size: 1.1em;
            font-weight: 600;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-shadow: 0 1px 2px rgba(0,0,0,0.3);
            border: none;
            position: relative;
        }
        table.candidate-table th::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(45deg, rgba(255,255,255,0.1) 0%, transparent 50%);
            pointer-events: none;
        }
        table.candidate-table tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        table.candidate-table tr:hover {
            background-color: #e3f2fd;
            transition: background-color 0.3s ease;
        }
        table.candidate-table td {
            border-bottom: 1px solid #eee;
        }
    </style>
</head>
<body>
<div class="container wide-table-container">
    <h2>지원자 목록</h2>
    <div class="button-container">
        <a href="candidates?action=new"><button>신규 지원자 등록</button></a>
        <a href="interview/list"><button>인터뷰 일정 관리</button></a>
        <a href="main.jsp"><button>홈으로 이동</button></a>
    </div>
    <table class="candidate-table">
        <tr>
            <th>지원팀</th>
            <th>이름</th>
            <th>이메일</th>
            <th>연락처</th>
            <th>등록시간</th>
            <th>관리</th>
        </tr>
        <% if (candidates != null) for (Candidate c : candidates) { %>
        <tr>
            <td><%= c.getTeam() != null ? c.getTeam() : "-" %></td>
            <td><%= c.getName() %></td>
            <td><%= c.getEmail() %></td>
            <td><%= c.getPhone() %></td>
            <td><%= c.getCreatedAtTimeOnly() %></td>
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