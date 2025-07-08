package com.example.controller;

import com.example.model.Candidate;
import com.example.model.CandidateDAO;
import com.example.util.FileUploadUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/candidates", "/candidates/*"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,   // 1 MB
    maxFileSize = 1024 * 1024 * 10,        // 10 MB
    maxRequestSize = 1024 * 1024 * 15      // 15 MB
)
public class CandidateServlet extends HttpServlet {
    private CandidateDAO candidateDAO;

    @Override
    public void init() {
        candidateDAO = new CandidateDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String requestURI = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = requestURI.substring(contextPath.length());
        
        System.out.println("🔍 [CandidateServlet-GET] ================================");
        System.out.println("🔍 [CandidateServlet-GET] 요청 경로: " + path);
        System.out.println("🔍 [CandidateServlet-GET] 전체 URI: " + requestURI);
        
        // 세션 상태 확인 (AuthenticationFilter에서 이미 검증했지만 재확인)
        HttpSession session = request.getSession(false);
        System.out.println("🔍 [CandidateServlet-GET] 세션 상태: " + (session != null ? "존재" : "null"));
        
        if (session != null) {
            String username = (String) session.getAttribute("username");
            System.out.println("🔍 [CandidateServlet-GET] 세션의 username: " + username);
        }
        
        // RESTful URL 라우팅
        if (path.equals("/candidates")) {
            System.out.println("📋 [CandidateServlet-GET] 지원자 목록 요청 처리");
            // 지원자 목록 (기본)
            List<Candidate> candidates = candidateDAO.getAllCandidatesWithInterviewSchedule();
            request.setAttribute("candidates", candidates);
            System.out.println("✅ [CandidateServlet-GET] candidates.jsp로 포워딩, 지원자 수: " + candidates.size());
            request.getRequestDispatcher("candidates.jsp").forward(request, response);
        } else if (path.equals("/candidates/add")) {
            System.out.println("➕ [CandidateServlet-GET] 새 지원자 추가 폼 요청 처리");
            // 새 지원자 추가 폼
            System.out.println("📄 [CandidateServlet-GET] candidate_form.jsp로 포워딩 (절대경로)");
            request.getRequestDispatcher("/candidate_form.jsp").forward(request, response);
        } else if (path.equals("/candidates/edit")) {
            System.out.println("✏️ [CandidateServlet-GET] 지원자 편집 폼 요청 처리");
            // 지원자 편집 폼
            String idParam = request.getParameter("id");
            System.out.println("🔍 [CandidateServlet-GET] 편집할 지원자 ID: " + idParam);
            if (idParam != null && !idParam.isEmpty()) {
                int id = Integer.parseInt(idParam);
                Candidate candidate = candidateDAO.getCandidateById(id);
                request.setAttribute("candidate", candidate);
                System.out.println("📄 [CandidateServlet-GET] candidate_form.jsp로 포워딩 (절대경로) - 지원자: " + (candidate != null ? candidate.getName() : "null"));
                request.getRequestDispatcher("/candidate_form.jsp").forward(request, response);
            } else {
                System.out.println("❌ [CandidateServlet-GET] ID 파라미터가 없음 - 400 에러 반환");
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID 파라미터가 필요합니다.");
            }
        } else if (path.equals("/candidates/detail")) {
            // 지원자 상세보기
            String idParam = request.getParameter("id");
            if (idParam != null && !idParam.isEmpty()) {
                int id = Integer.parseInt(idParam);
                Candidate candidate = candidateDAO.getCandidateById(id);
                request.setAttribute("candidate", candidate);
                request.getRequestDispatcher("/candidate_detail.jsp").forward(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID 파라미터가 필요합니다.");
            }
        } else if (path.equals("/candidates/download-resume")) {
            // 이력서 파일 다운로드 처리
            handleResumeDownload(request, response);
        } else if (path.equals("/candidates/export")) {
            // Excel 내보내기 (향후 구현)
            response.setContentType("text/plain; charset=UTF-8");
            response.getWriter().write("Excel 내보내기 기능은 준비 중입니다.");
        } else {
            // 기존 action 파라미터 방식도 지원 (하위 호환성)
            String action = request.getParameter("action");
            
            System.out.println("🔍 [CandidateServlet-GET] else 블록 진입");
            System.out.println("🔍 [CandidateServlet-GET] action 파라미터: " + action);
            
            if ("new".equals(action)) {
                System.out.println("📄 [CandidateServlet-GET] action=new - candidate_form.jsp로 포워딩 (절대경로)");
                request.getRequestDispatcher("/candidate_form.jsp").forward(request, response);
            } else if ("edit".equals(action)) {
                System.out.println("✏️ [CandidateServlet-GET] action=edit - 편집 폼으로 이동");
                int id = Integer.parseInt(request.getParameter("id"));
                Candidate candidate = candidateDAO.getCandidateById(id);
                request.setAttribute("candidate", candidate);
                request.getRequestDispatcher("/candidate_form.jsp").forward(request, response);
            } else if ("detail".equals(action)) {
                System.out.println("👁️ [CandidateServlet-GET] action=detail - 상세보기로 이동");
                int id = Integer.parseInt(request.getParameter("id"));
                Candidate candidate = candidateDAO.getCandidateById(id);
                request.setAttribute("candidate", candidate);
                request.getRequestDispatcher("/candidate_detail.jsp").forward(request, response);
            } else if ("delete-resume".equals(action)) {
                System.out.println("🗑️ [CandidateServlet-GET] action=delete-resume - 이력서 삭제");
                handleResumeDelete(request, response);
            } else {
                // 지원자 목록으로 리다이렉트 (절대경로로 수정)
                String redirectURL = request.getContextPath() + "/candidates";
                System.out.println("🔄 [CandidateServlet-GET] 기본 리다이렉트: " + redirectURL);
                System.out.println("⚠️ [CandidateServlet-GET] 예상치 못한 경로 또는 action: path=" + path + ", action=" + action);
                response.sendRedirect(redirectURL);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 세션 검증
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        request.setCharacterEncoding("UTF-8");
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String team = request.getParameter("team");
        String resume = request.getParameter("resume");
        String idStr = request.getParameter("id");
        
        try {
            Candidate candidate = new Candidate();
            candidate.setName(name);
            candidate.setEmail(email);
            candidate.setPhone(phone);
            candidate.setTeam(team);
            candidate.setResume(resume);
            
            // 이력서 파일 처리
            Part resumeFilePart = request.getPart("resumeFile");
            if (resumeFilePart != null && resumeFilePart.getSize() > 0) {
                try {
                    Map<String, Object> fileInfo = FileUploadUtil.uploadResumeFile(resumeFilePart, name);
                    candidate.setResumeFileName((String) fileInfo.get("originalFileName"));
                    candidate.setResumeFilePath((String) fileInfo.get("filePath"));
                    candidate.setResumeFileSize((Long) fileInfo.get("fileSize"));
                    candidate.setResumeFileType((String) fileInfo.get("fileType"));
                    candidate.setResumeUploadedAt(new Timestamp(System.currentTimeMillis()));
                } catch (Exception e) {
                    request.setAttribute("error", "이력서 파일 업로드 실패: " + e.getMessage());
                    request.setAttribute("candidate", candidate);
                    request.getRequestDispatcher("/candidate_form.jsp").forward(request, response);
                    return;
                }
            }
            
            boolean success = false;
            String errorMessage = null;
            
            if (idStr != null && !idStr.isEmpty()) {
                // 수정
                candidate.setId(Integer.parseInt(idStr));
                
                // 기존 지원자 정보 가져오기 (이력서 파일 정보 유지를 위해)
                Candidate existingCandidate = candidateDAO.getCandidateById(candidate.getId());
                if (existingCandidate != null && !candidate.hasResumeFile()) {
                    // 새로운 파일이 업로드되지 않은 경우 기존 파일 정보 유지
                    candidate.setResumeFileName(existingCandidate.getResumeFileName());
                    candidate.setResumeFilePath(existingCandidate.getResumeFilePath());
                    candidate.setResumeFileSize(existingCandidate.getResumeFileSize());
                    candidate.setResumeFileType(existingCandidate.getResumeFileType());
                    candidate.setResumeUploadedAt(existingCandidate.getResumeUploadedAt());
                } else if (candidate.hasResumeFile() && existingCandidate != null && existingCandidate.hasResumeFile()) {
                    // 새 파일이 업로드된 경우 기존 파일 삭제
                    FileUploadUtil.deleteResumeFile(existingCandidate.getResumeFilePath());
                }
                
                success = candidateDAO.updateCandidate(candidate);
                if (!success) {
                    errorMessage = "이메일 주소 '" + email + "'이(가) 이미 다른 지원자에 의해 사용되고 있습니다. 다른 이메일 주소를 입력해주세요.";
                }
            } else {
                // 새 등록
                success = candidateDAO.addCandidate(candidate);
                if (!success) {
                    errorMessage = "이메일 주소 '" + email + "'이(가) 이미 등록되어 있습니다. 다른 이메일 주소를 입력해주세요.";
                    // 실패한 경우 업로드된 파일 삭제
                    if (candidate.hasResumeFile()) {
                        FileUploadUtil.deleteResumeFile(candidate.getResumeFilePath());
                    }
                }
            }
            
            if (success) {
                response.sendRedirect("candidates");
            } else {
                // 에러 발생 시 입력된 데이터를 유지하면서 폼으로 돌아가기
                request.setAttribute("error", errorMessage);
                request.setAttribute("candidate", candidate);
                request.getRequestDispatcher("/candidate_form.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "저장 중 오류가 발생했습니다: " + e.getMessage());
            request.getRequestDispatcher("/candidate_form.jsp").forward(request, response);
        }
    }
    
    /**
     * 이력서 파일 다운로드를 처리합니다.
     */
    private void handleResumeDownload(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String candidateIdStr = request.getParameter("candidateId");
        if (candidateIdStr == null || candidateIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "지원자 ID가 필요합니다.");
            return;
        }
        
        try {
            int candidateId = Integer.parseInt(candidateIdStr);
            Candidate candidate = candidateDAO.getCandidateById(candidateId);
            
            if (candidate == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "지원자를 찾을 수 없습니다.");
                return;
            }
            
            if (!candidate.hasResumeFile()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "첨부된 이력서 파일이 없습니다.");
                return;
            }
            
            Path filePath = Paths.get(candidate.getResumeFilePath());
            if (!Files.exists(filePath)) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "이력서 파일을 찾을 수 없습니다.");
                return;
            }
            
            // 파일 다운로드 응답 설정
            String fileName = candidate.getResumeFileName();
            String encodedFileName = new String(fileName.getBytes("UTF-8"), "ISO-8859-1");
            
            response.setContentType("application/octet-stream");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + encodedFileName + "\"");
            response.setContentLengthLong(Files.size(filePath));
            
            // 파일 내용을 응답으로 전송
            try (InputStream fileStream = Files.newInputStream(filePath);
                 OutputStream responseStream = response.getOutputStream()) {
                
                byte[] buffer = new byte[8192];
                int bytesRead;
                while ((bytesRead = fileStream.read(buffer)) != -1) {
                    responseStream.write(buffer, 0, bytesRead);
                }
                responseStream.flush();
            }
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 지원자 ID입니다.");
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "파일 다운로드 중 오류가 발생했습니다.");
        }
    }
    
    /**
     * 이력서 파일 삭제를 처리합니다.
     */
    private void handleResumeDelete(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String candidateIdStr = request.getParameter("id");
        if (candidateIdStr == null || candidateIdStr.trim().isEmpty()) {
            response.sendRedirect("candidates");
            return;
        }
        
        try {
            int candidateId = Integer.parseInt(candidateIdStr);
            boolean success = candidateDAO.deleteCandidateResumeFile(candidateId);
            
            if (success) {
                request.getSession().setAttribute("message", "이력서 파일이 삭제되었습니다.");
            } else {
                request.getSession().setAttribute("error", "이력서 파일 삭제에 실패했습니다.");
            }
            
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "잘못된 지원자 ID입니다.");
        } catch (Exception e) {
            request.getSession().setAttribute("error", "파일 삭제 중 오류가 발생했습니다.");
        }
        
        response.sendRedirect("candidates");
    }
}
