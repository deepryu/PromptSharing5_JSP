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
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

// Apache POI imports for Excel export
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

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
        
        // 세션 상태 확인 (AuthenticationFilter에서 이미 검증했지만 재확인)
        HttpSession session = request.getSession(false);
        
        // RESTful URL 라우팅
        if (path.equals("/candidates")) {
            // 지원자 목록 (기본)
            List<Candidate> candidates = candidateDAO.getAllCandidatesWithInterviewSchedule();
            request.setAttribute("candidates", candidates);
            request.getRequestDispatcher("candidates.jsp").forward(request, response);
        } else if (path.equals("/candidates/add")) {
            // 새 지원자 추가 폼
            request.getRequestDispatcher("/candidate_form.jsp").forward(request, response);
        } else if (path.equals("/candidates/edit")) {
            // 지원자 편집 폼
            String idParam = request.getParameter("id");
            if (idParam != null && !idParam.isEmpty()) {
                int id = Integer.parseInt(idParam);
                Candidate candidate = candidateDAO.getCandidateById(id);
                request.setAttribute("candidate", candidate);
                request.getRequestDispatcher("/candidate_form.jsp").forward(request, response);
            } else {
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
            // Excel 내보내기
            handleExcelExport(request, response);
        } else {
            // 기존 action 파라미터 방식도 지원 (하위 호환성)
            String action = request.getParameter("action");
            
            if ("new".equals(action)) {
                request.getRequestDispatcher("/candidate_form.jsp").forward(request, response);
            } else if ("edit".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Candidate candidate = candidateDAO.getCandidateById(id);
                request.setAttribute("candidate", candidate);
                request.getRequestDispatcher("/candidate_form.jsp").forward(request, response);
            } else if ("detail".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Candidate candidate = candidateDAO.getCandidateById(id);
                request.setAttribute("candidate", candidate);
                request.getRequestDispatcher("/candidate_detail.jsp").forward(request, response);
            } else if ("delete-resume".equals(action)) {
                handleResumeDelete(request, response);
            } else {
                // 지원자 목록으로 리다이렉트 (절대경로로 수정)
                String redirectURL = request.getContextPath() + "/candidates";
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
    
    /**
     * Excel 내보내기를 처리합니다.
     */
    private void handleExcelExport(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // try-with-resources로 워크북 자원 관리
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            
            // 모든 지원자 데이터 가져오기
            List<Candidate> candidates = candidateDAO.getAllCandidatesWithInterviewSchedule();
            
            // Excel 시트 생성 (영문 시트명으로 안전하게)
            Sheet sheet = workbook.createSheet("Candidates_List");
            
            // 스타일 생성
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setFontHeightInPoints((short) 12);
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.LIGHT_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setBorderTop(BorderStyle.THIN);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setBorderLeft(BorderStyle.THIN);
            headerStyle.setBorderRight(BorderStyle.THIN);
            
            CellStyle dataStyle = workbook.createCellStyle();
            dataStyle.setBorderTop(BorderStyle.THIN);
            dataStyle.setBorderBottom(BorderStyle.THIN);
            dataStyle.setBorderLeft(BorderStyle.THIN);
            dataStyle.setBorderRight(BorderStyle.THIN);
            
            // 헤더 행 생성
            Row headerRow = sheet.createRow(0);
            String[] headers = {
                "ID", "Name", "Email", "Phone", "Team", 
                "Interview_Date", "Interview_Time", "Interview_Type", "Result_Status", "Created_At"
            };
            
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }
            
            // 데이터 행 생성
            SimpleDateFormat dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            
            for (int i = 0; i < candidates.size(); i++) {
                Candidate candidate = candidates.get(i);
                Row row = sheet.createRow(i + 1);
                
                // ID
                Cell cell0 = row.createCell(0);
                cell0.setCellValue(candidate.getId());
                cell0.setCellStyle(dataStyle);
                
                // 이름
                Cell cell1 = row.createCell(1);
                cell1.setCellValue(candidate.getName() != null ? candidate.getName() : "");
                cell1.setCellStyle(dataStyle);
                
                // 이메일
                Cell cell2 = row.createCell(2);
                cell2.setCellValue(candidate.getEmail() != null ? candidate.getEmail() : "");
                cell2.setCellStyle(dataStyle);
                
                // 전화번호
                Cell cell3 = row.createCell(3);
                cell3.setCellValue(candidate.getPhone() != null ? candidate.getPhone() : "");
                cell3.setCellStyle(dataStyle);
                
                // 지원분야
                Cell cell4 = row.createCell(4);
                cell4.setCellValue(candidate.getTeam() != null ? candidate.getTeam() : "TBD");
                cell4.setCellStyle(dataStyle);
                
                // 인터뷰날짜
                Cell cell5 = row.createCell(5);
                String interviewDate = "TBD";
                if (candidate.getInterviewDateTime() != null && !candidate.getInterviewDateTime().trim().isEmpty()) {
                    try {
                        String[] dateTimeParts = candidate.getInterviewDateTime().split(" ");
                        if (dateTimeParts.length >= 1) {
                            interviewDate = dateTimeParts[0];
                        }
                    } catch (Exception e) {
                        interviewDate = "TBD";
                    }
                }
                cell5.setCellValue(interviewDate);
                cell5.setCellStyle(dataStyle);
                
                // 인터뷰시간
                Cell cell6 = row.createCell(6);
                String interviewTime = "TBD";
                if (candidate.getInterviewDateTime() != null && !candidate.getInterviewDateTime().trim().isEmpty()) {
                    try {
                        String[] dateTimeParts = candidate.getInterviewDateTime().split(" ");
                        if (dateTimeParts.length >= 2) {
                            interviewTime = dateTimeParts[1];
                        }
                    } catch (Exception e) {
                        interviewTime = "TBD";
                    }
                }
                cell6.setCellValue(interviewTime);
                cell6.setCellStyle(dataStyle);
                
                // 면접유형
                Cell cell7 = row.createCell(7);
                cell7.setCellValue(candidate.getInterviewType() != null ? candidate.getInterviewType() : "TBD");
                cell7.setCellStyle(dataStyle);
                
                // 결과상태
                Cell cell8 = row.createCell(8);
                String resultStatus = candidate.getInterviewResultStatus();
                if (resultStatus != null && !resultStatus.trim().isEmpty() && !"미등록".equals(resultStatus)) {
                    if ("pass".equals(resultStatus)) {
                        resultStatus = "PASS";
                    } else if ("fail".equals(resultStatus)) {
                        resultStatus = "FAIL";
                    } else if ("hold".equals(resultStatus)) {
                        resultStatus = "HOLD";
                    } else if ("pending".equals(resultStatus)) {
                        resultStatus = "PENDING";
                    }
                } else {
                    resultStatus = "NOT_REGISTERED";
                }
                cell8.setCellValue(resultStatus);
                cell8.setCellStyle(dataStyle);
                
                // 등록일시
                Cell cell9 = row.createCell(9);
                if (candidate.getCreatedAt() != null) {
                    cell9.setCellValue(dateTimeFormat.format(candidate.getCreatedAt()));
                } else {
                    cell9.setCellValue("");
                }
                cell9.setCellStyle(dataStyle);
            }
            
            // 컬럼 너비 자동 조정
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                // 최소 너비 설정
                int currentWidth = sheet.getColumnWidth(i);
                if (currentWidth < 3000) {
                    sheet.setColumnWidth(i, 3000);
                }
            }
            
            // 파일명 생성 (영문으로 안전하게)
            String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String fileName = "candidates_list_" + timestamp + ".xlsx";
            
            // 응답 헤더 설정 (더 안전한 방식)
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setCharacterEncoding("UTF-8");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            response.setHeader("Pragma", "no-cache");
            response.setDateHeader("Expires", 0);
            
            // Excel 파일을 응답으로 전송
            try (OutputStream out = response.getOutputStream()) {
                workbook.write(out);
                out.flush();
            }
            
            System.out.println("[CandidateServlet] Excel 파일 전송 완료: " + fileName);
            
        } catch (Exception e) {
            System.err.println("[CandidateServlet] Excel 내보내기 실패: " + e.getMessage());
            e.printStackTrace();
            
            // 에러 발생 시 JSON 응답으로 변경 (더 안전함)
            response.setContentType("application/json; charset=UTF-8");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Excel export failed: " + e.getMessage() + "\"}");
        }
    }
}
