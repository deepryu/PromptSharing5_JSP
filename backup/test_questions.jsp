<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String username = (String)session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%><!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>吏덈Ц 愿由??뚯뒪??- PromptSharing</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            margin: 0;
            padding: 20px;
            color: white;
            text-align: center;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.1);
            padding: 40px;
            border-radius: 15px;
            backdrop-filter: blur(10px);
        }
        h1 { font-size: 2.5rem; margin-bottom: 20px; }
        .status { background: rgba(255, 255, 255, 0.2); padding: 20px; border-radius: 10px; margin: 20px 0; }
        .btn {
            display: inline-block;
            padding: 12px 30px;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            text-decoration: none;
            border-radius: 25px;
            margin: 10px;
            transition: all 0.3s ease;
        }
        .btn:hover { background: rgba(255, 255, 255, 0.3); transform: translateY(-2px); }
    </style>
</head>
<body>
    <div class="container">
        <h1>?㎦ 吏덈Ц 愿由??쒖뒪???뚯뒪??/h1>
        
        <div class="status">
            <h3>???쒕툝由??곌껐 ?뚯뒪???깃났!</h3>
            <p>InterviewQuestionServlet???뺤긽?곸쑝濡?留ㅽ븨?섏뿀?듬땲??</p>
            <p>?꾩옱 ?쒓컙: <%= new java.util.Date() %></p>
        </div>
        
        <div class="status">
            <h3>?뵩 ?ㅼ쓬 ?④퀎</h3>
            <p>1. ?곗씠?곕쿋?댁뒪 ?뚯씠釉??앹꽦</p>
            <p>2. 湲곕낯 ?곗씠???쎌엯</p>
            <p>3. ?ㅼ젣 吏덈Ц 愿由?湲곕뒫 ?뚯뒪??/p>
        </div>
        
        <a href="questions" class="btn">?뱥 吏덈Ц 愿由щ줈 ?대룞</a>
        <a href="criteria" class="btn">?뽳툘 ?됯?湲곗? 愿由щ줈 ?대룞</a>
        <a href="main.jsp" class="btn">?룧 硫붿씤?쇰줈 ?뚯븘媛湲?/a>
    </div>
</body>
</html> 
