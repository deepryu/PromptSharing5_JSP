package com.example.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Enumeration;

@WebServlet("/sessiontest")
public class SessionTestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>세션 테스트</title></head><body>");
        out.println("<h2>세션 상태 확인</h2>");
        
        HttpSession session = request.getSession(false);
        
        if (session == null) {
            out.println("<p><strong>세션이 존재하지 않습니다.</strong></p>");
        } else {
            out.println("<p><strong>세션 ID:</strong> " + session.getId() + "</p>");
            out.println("<p><strong>세션 생성 시간:</strong> " + new java.util.Date(session.getCreationTime()) + "</p>");
            out.println("<p><strong>마지막 접근 시간:</strong> " + new java.util.Date(session.getLastAccessedTime()) + "</p>");
            
            out.println("<h3>세션 속성들:</h3>");
            out.println("<ul>");
            
            Enumeration<String> attributeNames = session.getAttributeNames();
            boolean hasAttributes = false;
            
            while (attributeNames.hasMoreElements()) {
                hasAttributes = true;
                String attributeName = attributeNames.nextElement();
                Object attributeValue = session.getAttribute(attributeName);
                out.println("<li><strong>" + attributeName + ":</strong> " + attributeValue + "</li>");
            }
            
            if (!hasAttributes) {
                out.println("<li>세션에 저장된 속성이 없습니다.</li>");
            }
            
            out.println("</ul>");
            
            // username 속성 특별 확인
            String username = (String) session.getAttribute("username");
            out.println("<h3>username 속성 확인:</h3>");
            if (username != null) {
                out.println("<p style='color: green;'><strong>✅ username 존재:</strong> " + username + "</p>");
            } else {
                out.println("<p style='color: red;'><strong>❌ username 속성이 null입니다.</strong></p>");
            }
        }
        
        out.println("<hr>");
        out.println("<p><a href='main.jsp'>메인 페이지로 돌아가기</a></p>");
        out.println("<p><a href='results'>인터뷰 결과 관리 테스트</a></p>");
        out.println("</body></html>");
        
        out.close();
    }
} 