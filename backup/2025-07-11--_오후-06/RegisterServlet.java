package com.example.controller;

import com.example.model.User;
import com.example.model.UserDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    public void init() {
        userDAO = new UserDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Forward to the registration page
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        String error = "";
        String success = "";

        if (username == null || username.isEmpty() || password == null || password.isEmpty()) {
            error = "아이디와 비밀번호를 모두 입력해주세요.";
        } else {
            if (userDAO.findByUsername(username) != null) {
                error = "이미 사용 중인 아이디입니다.";
            } else {
                User newUser = new User(username, password);
                boolean result = userDAO.addUser(newUser);
                if (result) {
                    success = "회원가입이 성공적으로 완료되었습니다. 로그인 해주세요.";
                } else {
                    error = "회원가입에 실패했습니다. 다시 시도해주세요.";
                }
            }
        }
        
        if (!error.isEmpty()) {
            request.setAttribute("error", error);
        }
        if (!success.isEmpty()) {
            request.setAttribute("success", success);
        }
        
        // Forward back to the registration page to display messages
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }
} 