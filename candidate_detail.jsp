<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.model.Candidate" %>
<%
    String username = (String)session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    Candidate candidate = (Candidate) request.getAttribute("candidate");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>지원자 상세 정보</title>
    <base href="${pageContext.request.contextPath}/">
    <style>
        body { 
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; 
            margin: 20px; 
            background: #f0f0f0; 
        }
        .container { 
            max-width: 800px; 
            margin: 0 auto; 
            background: white; 
            padding: 20px; 
            border: 1px solid #d0d7de; 
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .header { 
            background: #0078d4; 
            color: white; 
            padding: 15px; 
            margin: -20px -20px 20px -20px; 
        }
        .header h1 {
            margin: 0;
            font-size: 1.3rem;
            font-weight: 600;
        }
        .info-section { 
            margin-bottom: 20px; 
            padding: 15px; 
            background: #f6f8fa; 
            border: 1px solid #d0d7de; 
            border-radius: 3px;
        }
        .info-section h3 {
            margin: 0 0 15px 0;
            color: #24292f;
            font-size: 1.1rem;
        }
        .info-item { 
            margin-bottom: 10px; 
            display: flex;
            align-items: flex-start;
        }
        .label { 
            font-weight: 600; 
            color: #656d76; 
            display: inline-block; 
            width: 120px; 
            flex-shrink: 0;
        }
        .value {
            flex: 1;
            color: #24292f;
        }
        .btn { 
            padding: 8px 16px; 
            margin: 5px; 
            text-decoration: none; 
            color: white; 
            border-radius: 3px; 
            display: inline-block; 
            font-size: 14px;
            border: none;
            cursor: pointer;
        }
        .btn-primary { background: #2da44e; }
        .btn-secondary { background: #6c757d; }
        .btn-danger { background: #cf222e; }
        .btn-info { background: #0969da; }
        .btn:hover { opacity: 0.9; }
        
        .file-info {
            background: #e3f2fd;
            padding: 12px;
            border: 1px solid #bbdefb;
            border-radius: 3px;
            margin-top: 10px;
        }
        
        .file-details {
            display: flex;
            align-items: center;
            margin-bottom: 8px;
        }
        
        .file-icon {
            font-size: 1.5rem;
            margin-right: 10px;
        }
        
        .file-name {
            font-weight: 600;
            color: #1565c0;
            flex: 1;
        }
        
        .file-meta {
            font-size: 0.9rem;
            color: #666;
            margin-bottom: 10px;
        }
        
        .file-actions {
            display: flex;
            gap: 10px;
        }
        
        .no-file {
            color: #656d76;
            font-style: italic;
            padding: 10px;
            background: #f1f3f4;
            border-radius: 3px;
            text-align: center;
        }
        
        .resume-text {
            background: white;
            padding: 12px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            white-space: pre-wrap;
            font-family: inherit;
            line-height: 1.5;
            color: #24292f;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>👤 지원자 상세 정보</h1>
        </div>
        
        <% if (candidate != null) { %>
            <div class="info-section">
                <h3>📋 기본 정보</h3>
                <div class="info-item">
                    <span class="label">ID:</span> 
                    <span class="value"><%=candidate.getId()%></span>
                </div>
                <div class="info-item">
                    <span class="label">이름:</span> 
                    <span class="value"><%=candidate.getName()%></span>
                </div>
                <div class="info-item">
                    <span class="label">이메일:</span> 
                    <span class="value"><%=candidate.getEmail()%></span>
                </div>
                <div class="info-item">
                    <span class="label">전화번호:</span> 
                    <span class="value"><%=candidate.getPhone() != null ? candidate.getPhone() : "-"%></span>
                </div>
                <div class="info-item">
                    <span class="label">지원팀:</span> 
                    <span class="value"><%=candidate.getTeam() != null ? candidate.getTeam() : "미정"%></span>
                </div>
                <div class="info-item">
                    <span class="label">상태:</span> 
                    <span class="value"><%=candidate.getStatus() != null ? candidate.getStatus() : "대기"%></span>
                </div>
                <div class="info-item">
                    <span class="label">등록일:</span> 
                    <span class="value"><%=candidate.getCreatedAt() != null ? candidate.getCreatedAt().toString().substring(0, 19) : "-"%></span>
                </div>
            </div>
            
            <!-- 이력서 파일 정보 섹션 -->
            <div class="info-section">
                <h3>📎 첨부 이력서</h3>
                <% if (candidate.hasResumeFile()) { %>
                    <div class="file-info">
                        <div class="file-details">
                            <span class="file-icon"><%= candidate.getResumeFileIcon() %></span>
                            <span class="file-name"><%= candidate.getResumeFileName() %></span>
                        </div>
                        <div class="file-meta">
                            파일 형식: <%= candidate.getResumeFileTypeDisplay() %> | 
                            크기: <%= candidate.getResumeFileSizeFormatted() %> | 
                            업로드: <%= candidate.getResumeUploadedAtFormatted() %>
                        </div>
                        <div class="file-actions">
                            <a href="candidates/download-resume?candidateId=<%= candidate.getId() %>" 
                               class="btn btn-info" target="_blank">💾 이력서 다운로드</a>
                            <a href="candidates?action=delete-resume&id=<%= candidate.getId() %>" 
                               class="btn btn-danger" 
                               onclick="return confirm('이력서 파일을 삭제하시겠습니까?')">🗑️ 파일 삭제</a>
                        </div>
                    </div>
                <% } else { %>
                    <div class="no-file">
                        📄 첨부된 이력서 파일이 없습니다.
                    </div>
                <% } %>
            </div>
            
            <div class="info-section">
                <h3>📝 이력서 (텍스트 요약)</h3>
                <% if (candidate.getResume() != null && !candidate.getResume().trim().isEmpty()) { %>
                    <div class="resume-text"><%=candidate.getResume()%></div>
                <% } else { %>
                    <div class="no-file">이력서 요약이 등록되지 않았습니다.</div>
                <% } %>
            </div>
            
            <div style="text-align: center; margin-top: 30px;">
                <a href="candidates?action=edit&id=<%=candidate.getId()%>" class="btn btn-primary">✏️ 정보 수정</a>
                <a href="candidates" class="btn btn-secondary">📋 목록으로 돌아가기</a>
            </div>
        <% } else { %>
            <div style="text-align: center; padding: 40px;">
                <h3>❌ 지원자 정보를 찾을 수 없습니다</h3>
                <a href="candidates" class="btn btn-primary">📋 지원자 목록으로 돌아가기</a>
            </div>
        <% } %>
    </div>
</body>
</html>
