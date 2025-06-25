<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String username = (String)session.getAttribute("username");
%>
<!DOCTYPE html>
<html>
<head>
    <title>메인 대시보드</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            min-height: 100vh;
            margin: 0;
            background: #f7fafa;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .main-dashboard {
            max-width: 800px;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
            padding: 36px 32px;
            margin: 0;
        }
        .main-dashboard h1 { font-size: 2rem; margin-bottom: 24px; text-align: center; }
        .main-dashboard ul { list-style: none; padding: 0; display: grid; grid-template-columns: repeat(4, 1fr); grid-template-rows: repeat(2, 1fr); gap: 16px; }
        .main-dashboard li { margin: 0; }
        .main-dashboard a { display: block; padding: 14px 8px; background: #f5f7fa; border-radius: 6px; text-align: center; font-size: 1rem; color: #222; text-decoration: none; transition: background 0.2s; }
        .main-dashboard a:hover { background: #e0e7ef; color: #0056b3; }
        .main-dashboard a.completed { background: #d4edda; color: #155724; }
        .main-dashboard a.completed:hover { background: #c3e6cb; color: #0a3622; }
        .main-dashboard .desc { color: #888; font-size: 0.85rem; margin-top: 8px; text-align: center; }
        .top-bar { width: 100%; max-width: 800px; margin: 0 auto 20px auto; display: flex; justify-content: flex-end; }
        .top-bar form, .top-bar a { margin-left: 8px; }
        .top-bar button { padding: 7px 18px; border-radius: 6px; border: 1px solid #ddd; background: #f5f7fa; font-size: 1rem; cursor: pointer; transition: background 0.2s; color: #333; font-weight: 500; }
        .top-bar button:hover { background: #e0e7ef; color: #0056b3; }
    </style>
</head>
<body>
    <div>
        <div class="top-bar">
            <% if (username != null) { %>
                <form action="logout" method="get" style="display:inline;">
                    <button type="submit">로그아웃</button>
                </form>
            <% } else { %>
                <a href="login"><button type="button">로그인</button></a>
            <% } %>
        </div>
        <div class="main-dashboard">
            <h1>관리자 메인 대시보드</h1>
            <ul>
                <li>
                    <a href="candidates" class="completed">1. 인터뷰 대상자(지원자) 관리</a>
                </li>
                <li>
                    <a href="#">2. 인터뷰 일정 관리 (준비중)</a>
                </li>
                <li>
                    <a href="#">3. 질문/평가 항목 관리 (준비중)</a>
                </li>
                <li>
                    <a href="#">4. 인터뷰 결과 기록/관리 (준비중)</a>
                </li>
                <li>
                    <a href="#">5. 통계 및 리포트 (준비중)</a>
                </li>
                <li>
                    <a href="#">6. 면접관(관리자) 관리 (준비중)</a>
                </li>
                <li>
                    <a href="#">7. 알림 및 히스토리 (준비중)</a>
                </li>
                <li style="visibility: hidden;"></li>
            </ul>
        </div>
    </div>
</body>
</html> 