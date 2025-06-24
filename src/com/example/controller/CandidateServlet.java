package com.example.controller;

import com.example.model.Candidate;
import com.example.model.CandidateDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/candidates")
public class CandidateServlet extends HttpServlet {
    private CandidateDAO candidateDAO;

    @Override
    public void init() {
        candidateDAO = new CandidateDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "list";
        switch (action) {
            case "new":
                request.getRequestDispatcher("candidate_form.jsp").forward(request, response);
                break;
            case "edit":
                int editId = Integer.parseInt(request.getParameter("id"));
                Candidate editCandidate = candidateDAO.getCandidateById(editId);
                request.setAttribute("candidate", editCandidate);
                request.getRequestDispatcher("candidate_form.jsp").forward(request, response);
                break;
            case "delete":
                int delId = Integer.parseInt(request.getParameter("id"));
                candidateDAO.deleteCandidate(delId);
                response.sendRedirect("candidates");
                break;
            case "detail":
                int detailId = Integer.parseInt(request.getParameter("id"));
                Candidate detailCandidate = candidateDAO.getCandidateById(detailId);
                request.setAttribute("candidate", detailCandidate);
                request.getRequestDispatcher("candidate_detail.jsp").forward(request, response);
                break;
            default:
                List<Candidate> list = candidateDAO.getAllCandidates();
                request.setAttribute("candidates", list);
                request.getRequestDispatcher("candidates.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String resume = request.getParameter("resume");
        Candidate candidate = new Candidate();
        candidate.setName(name);
        candidate.setEmail(email);
        candidate.setPhone(phone);
        candidate.setResume(resume);
        String error = null;
        boolean result = false;
        if (idStr == null || idStr.isEmpty()) {
            // 신규 등록
            try {
                result = candidateDAO.addCandidate(candidate);
                if (!result) {
                    error = "지원자 등록에 실패했습니다. (이메일 중복 등)";
                    candidate.setId(0);
                }
            } catch (Exception e) {
                error = e.getMessage();
                candidate.setId(0);
            }
        } else {
            // 수정
            candidate.setId(Integer.parseInt(idStr));
            try {
                result = candidateDAO.updateCandidate(candidate);
                if (!result) error = "지원자 정보 수정에 실패했습니다.";
            } catch (Exception e) {
                error = e.getMessage();
            }
        }
        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("candidate", candidate);
            request.getRequestDispatcher("candidate_form.jsp").forward(request, response);
        } else {
            response.sendRedirect("candidates");
        }
    }
} 