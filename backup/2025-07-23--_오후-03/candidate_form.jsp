<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.model.Candidate" %>
<%
    // AuthenticationFilter에서 이미 세션 검증을 수행하므로 여기서는 제거
    Candidate candidate = (Candidate) request.getAttribute("candidate");
    boolean isEdit = (candidate != null && candidate.getId() > 0);
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "지원자 수정" : "새 지원자 등록" %> - 채용 관리 시스템</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/common.css">
    <style>
        body {
            background: #f0f0f0;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border: 1px solid #d0d7de;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .header {
            background: #0078d4;
            color: white;
            padding: 20px;
            border-bottom: 1px solid #106ebe;
        }
        
        .header h1 {
            margin: 0;
            font-size: 1.3rem;
            font-weight: 600;
        }
        
        .content {
            padding: 20px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: 600;
            color: #24292f;
        }
        
        input, select, textarea {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            font-size: 14px;
            box-sizing: border-box;
        }
        
        input:focus, select:focus, textarea:focus {
            border-color: #0078d4;
            outline: none;
            box-shadow: 0 0 0 2px rgba(0,120,212,0.2);
        }
        
        textarea {
            min-height: 100px;
            resize: vertical;
        }
        
        .btn {
            padding: 8px 16px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            background: white;
            color: #24292f;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
            display: inline-block;
            margin-right: 10px;
        }
        
        .btn-primary {
            background: #2da44e;
            color: white;
            border-color: #2da44e;
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
            border-color: #6c757d;
        }
        
        .btn:hover {
            background: #f6f8fa;
            border-color: #8c959f;
        }
        
        .btn-primary:hover {
            background: #2c974b;
            border-color: #2c974b;
        }
        
        .btn-secondary:hover {
            background: #5a6268;
            border-color: #5a6268;
        }
        
        .error {
            background: #ffebee;
            color: #d32f2f;
            padding: 10px;
            border: 1px solid #ffcdd2;
            border-radius: 3px;
            margin-bottom: 15px;
        }
        
        .file-upload-section {
            background: #f8f9fa;
            padding: 15px;
            border: 1px solid #e9ecef;
            border-radius: 3px;
            margin-bottom: 15px;
        }
        
        .file-upload-section h3 {
            margin: 0 0 10px 0;
            font-size: 1.1rem;
            color: #495057;
        }
        
        .file-info {
            background: #e3f2fd;
            padding: 10px;
            border: 1px solid #bbdefb;
            border-radius: 3px;
            margin-bottom: 10px;
        }
        
        .file-info .file-icon {
            font-size: 1.2rem;
            margin-right: 8px;
        }
        
        .file-meta {
            font-size: 0.9rem;
            color: #666;
            margin-top: 5px;
        }
        
        .file-actions {
            margin-top: 10px;
        }
        
        .file-actions a {
            font-size: 0.9rem;
            margin-right: 10px;
        }
        
        .upload-help {
            font-size: 0.9rem;
            color: #666;
            margin-top: 5px;
        }
        
        .required-note {
            font-size: 0.9rem;
            color: #666;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #e9ecef;
        }
    </style>
    <script>
        function previewFile() {
            const fileInput = document.getElementById('resumeFile');
            const filePreview = document.getElementById('filePreview');
            const fileName = document.getElementById('fileName');
            const fileSize = document.getElementById('fileSize');
            
            if (fileInput.files && fileInput.files[0]) {
                const file = fileInput.files[0];
                const maxSize = 10 * 1024 * 1024; // 10MB
                
                if (file.size > maxSize) {
                    alert('파일 크기가 10MB를 초과할 수 없습니다.');
                    fileInput.value = '';
                    filePreview.style.display = 'none';
                    return;
                }
                
                const allowedTypes = ['application/pdf', 'application/haansofthwp', 'application/x-hwp', 
                                    'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];
                const allowedExtensions = ['.pdf', '.hwp', '.doc', '.docx'];
                
                const fileExtension = file.name.toLowerCase().substring(file.name.lastIndexOf('.'));
                
                if (!allowedExtensions.includes(fileExtension)) {
                    alert('지원하지 않는 파일 형식입니다. PDF, HWP, DOC, DOCX 파일만 업로드 가능합니다.');
                    fileInput.value = '';
                    filePreview.style.display = 'none';
                    return;
                }
                
                fileName.textContent = file.name;
                fileSize.textContent = formatFileSize(file.size);
                filePreview.style.display = 'block';
            } else {
                filePreview.style.display = 'none';
            }
        }
        
        function formatFileSize(bytes) {
            if (bytes === 0) return '0 B';
            const k = 1024;
            const sizes = ['B', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
        }
        
        function clearFileInput() {
            document.getElementById('resumeFile').value = '';
            document.getElementById('filePreview').style.display = 'none';
        }
        
        function deleteExistingFile() {
            if (confirm('기존 이력서 파일을 삭제하시겠습니까?')) {
                const candidateId = <%= isEdit ? candidate.getId() : "null" %>;
                if (candidateId) {
                    window.location.href = 'candidates?action=delete-resume&id=' + candidateId;
                }
            }
        }
    </script>
</head>
<body>
<div class="container">
    <div class="header">
        <h1>📝 <%= isEdit ? "지원자 수정" : "새 지원자 등록" %></h1>
    </div>
    
    <div class="content">
        <% if (error != null && !error.isEmpty()) { %>
            <div class="error"><%= error %></div>
        <% } %>
        
        <form method="post" action="candidates" enctype="multipart/form-data">
            <% if (isEdit) { %>
                <input type="hidden" name="id" value="<%= candidate.getId() %>">
            <% } %>
            
            <div class="form-group">
                <label for="team">지원팀 *</label>
                <select name="team" id="team" required>
                    <option value="">팀을 선택하세요</option>
                    <option value="개발팀" <%= candidate != null && "개발팀".equals(candidate.getTeam()) ? "selected" : "" %>>개발팀</option>
                    <option value="기획팀" <%= candidate != null && "기획팀".equals(candidate.getTeam()) ? "selected" : "" %>>기획팀</option>
                    <option value="디자인팀" <%= candidate != null && "디자인팀".equals(candidate.getTeam()) ? "selected" : "" %>>디자인팀</option>
                    <option value="마케팅팀" <%= candidate != null && "마케팅팀".equals(candidate.getTeam()) ? "selected" : "" %>>마케팅팀</option>
                    <option value="영업팀" <%= candidate != null && "영업팀".equals(candidate.getTeam()) ? "selected" : "" %>>영업팀</option>
                    <option value="인사팀" <%= candidate != null && "인사팀".equals(candidate.getTeam()) ? "selected" : "" %>>인사팀</option>
                    <option value="기타" <%= candidate != null && "기타".equals(candidate.getTeam()) ? "selected" : "" %>>기타</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="name">이름 *</label>
                <input type="text" name="name" id="name" placeholder="지원자 이름을 입력하세요" 
                       value="<%= candidate != null ? (candidate.getName() != null ? candidate.getName() : "") : "" %>" required>
            </div>
            
            <div class="form-group">
                <label for="email">이메일 *</label>
                <input type="email" name="email" id="email" placeholder="example@company.com" 
                       value="<%= candidate != null ? (candidate.getEmail() != null ? candidate.getEmail() : "") : "" %>" required>
            </div>
            
            <div class="form-group">
                <label for="phone">전화번호</label>
                <input type="text" name="phone" id="phone" placeholder="010-0000-0000" 
                       value="<%= candidate != null ? (candidate.getPhone() != null ? candidate.getPhone() : "") : "" %>">
            </div>
            
            <div class="form-group">
                <label for="resume">이력서 (간단 요약)</label>
                <textarea name="resume" id="resume" placeholder="경력사항, 주요 기술, 특이사항 등을 간단히 작성해주세요"><%= candidate != null ? (candidate.getResume() != null ? candidate.getResume() : "") : "" %></textarea>
            </div>
            
            <!-- 이력서 파일 업로드 섹션 -->
            <div class="file-upload-section">
                <h3>📎 이력서 파일 첨부</h3>
                
                <% if (isEdit && candidate != null && candidate.hasResumeFile()) { %>
                    <!-- 기존 파일 정보 표시 -->
                    <div class="file-info">
                        <div>
                            <span class="file-icon"><%= candidate.getResumeFileIcon() %></span>
                            <strong><%= candidate.getResumeFileName() %></strong>
                        </div>
                        <div class="file-meta">
                            파일 형식: <%= candidate.getResumeFileTypeDisplay() %> | 
                            크기: <%= candidate.getResumeFileSizeFormatted() %> | 
                            업로드: <%= candidate.getResumeUploadedAtFormatted() %>
                        </div>
                        <div class="file-actions">
                            <a href="candidates/download-resume?candidateId=<%= candidate.getId() %>" class="btn" target="_blank">💾 다운로드</a>
                            <button type="button" class="btn btn-secondary" onclick="deleteExistingFile()">🗑️ 삭제</button>
                        </div>
                    </div>
                    <p style="margin: 10px 0; color: #666;">새 파일을 선택하시면 기존 파일이 교체됩니다.</p>
                <% } %>
                
                <div class="form-group">
                    <label for="resumeFile">이력서 파일 선택</label>
                    <input type="file" name="resumeFile" id="resumeFile" accept=".pdf,.hwp,.doc,.docx" onchange="previewFile()">
                    <div class="upload-help">
                        지원 형식: PDF, HWP, DOC, DOCX | 최대 크기: 10MB
                    </div>
                </div>
                
                <!-- 새 파일 미리보기 -->
                <div id="filePreview" style="display: none;" class="file-info">
                    <div>
                        <span class="file-icon">📄</span>
                        <strong>선택된 파일: <span id="fileName"></span></strong>
                    </div>
                    <div class="file-meta">
                        크기: <span id="fileSize"></span>
                    </div>
                    <div class="file-actions">
                        <button type="button" class="btn" onclick="clearFileInput()">❌ 선택 취소</button>
                    </div>
                </div>
            </div>
            
            <div style="margin-top: 20px;">
                <button type="submit" class="btn btn-primary"><%= isEdit ? "수정" : "등록" %></button>
                <a href="candidates" class="btn">목록으로</a>
            </div>
            
            <div class="required-note">
                * 표시된 항목은 필수 입력 사항입니다.
            </div>
        </form>
    </div>
</div>
</body>
</html>
