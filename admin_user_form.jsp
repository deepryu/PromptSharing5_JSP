<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 세션 검증
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 관리자 권한 확인
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "관리자 권한이 필요합니다.");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>새 사용자 추가 - 관리자 대시보드</title>
    <base href="${pageContext.request.contextPath}/">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background-color: #f0f0f0;
            color: #24292f;
            line-height: 1.6;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .top-bar {
            background-color: #0078d4;
            color: white;
            padding: 15px 20px;
            margin-bottom: 30px;
            border-radius: 8px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .top-bar h1 {
            font-size: 24px;
            font-weight: 600;
        }
        
        .back-link {
            color: white;
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 6px;
            transition: background-color 0.2s;
        }
        
        .back-link:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }
        
        .main-dashboard {
            background-color: white;
            border-radius: 8px;
            border: 1px solid #d0d7de;
            overflow: hidden;
        }
        
        .dashboard-header {
            background-color: #f6f8fa;
            padding: 20px;
            border-bottom: 1px solid #d0d7de;
        }
        
        .dashboard-header h2 {
            font-size: 20px;
            font-weight: 600;
            color: #24292f;
        }
        
        .dashboard-content {
            padding: 20px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #24292f;
        }
        
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            font-size: 14px;
            transition: border-color 0.2s;
        }
        
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #0078d4;
            box-shadow: 0 0 0 3px rgba(0, 120, 212, 0.1);
        }
        
        .form-group small {
            display: block;
            margin-top: 4px;
            color: #656d76;
            font-size: 12px;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        
        .checkbox-group {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .checkbox-group input[type="checkbox"] {
            width: auto;
            margin: 0;
        }
        
        .btn {
            display: inline-block;
            padding: 12px 24px;
            font-size: 14px;
            font-weight: 600;
            border-radius: 6px;
            border: 1px solid transparent;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .btn-primary {
            background-color: #1f883d;
            color: white;
            border-color: #1f883d;
        }
        
        .btn-primary:hover {
            background-color: #1a7f37;
            border-color: #1a7f37;
        }
        
        .btn-secondary {
            background-color: white;
            color: #24292f;
            border-color: #d0d7de;
        }
        
        .btn-secondary:hover {
            background-color: #f3f4f6;
            border-color: #d0d7de;
        }
        
        .form-actions {
            display: flex;
            gap: 10px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #d0d7de;
        }
        
        .error {
            background-color: #ffebee;
            color: #c62828;
            padding: 12px;
            border-radius: 6px;
            border-left: 4px solid #c62828;
            margin-bottom: 20px;
        }
        
        .success {
            background-color: #e8f5e8;
            color: #1f883d;
            padding: 12px;
            border-radius: 6px;
            border-left: 4px solid #1f883d;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h1>➕ 새 사용자 추가</h1>
            <a href="admin/dashboard" class="back-link">← 대시보드로 돌아가기</a>
        </div>
        
        <div class="main-dashboard">
            <div class="dashboard-header">
                <h2>사용자 정보 입력</h2>
            </div>
            
            <div class="dashboard-content">
                <% if (request.getAttribute("error") != null) { %>
                    <div class="error">
                        <strong>오류:</strong> <%= request.getAttribute("error") %>
                    </div>
                <% } %>
                
                <% if (request.getAttribute("success") != null) { %>
                    <div class="success">
                        <strong>성공:</strong> <%= request.getAttribute("success") %>
                    </div>
                <% } %>
                
                <form action="admin/user/add" method="post">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="username">사용자명 *</label>
                            <input type="text" id="username" name="username" required>
                            <small>영문, 숫자, 언더스코어(_)만 사용 가능</small>
                        </div>
                        
                        <div class="form-group">
                            <label for="email">이메일</label>
                            <input type="email" id="email" name="email">
                            <small>선택사항</small>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="password">비밀번호 *</label>
                            <input type="password" id="password" name="password" required>
                            <small>최소 6자 이상</small>
                        </div>
                        
                        <div class="form-group">
                            <label for="confirmPassword">비밀번호 확인 *</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" required>
                            <small>위와 동일하게 입력</small>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="fullName">전체 이름</label>
                            <input type="text" id="fullName" name="fullName">
                            <small>표시될 이름</small>
                        </div>
                        
                        <div class="form-group">
                            <label for="role">역할 *</label>
                            <select id="role" name="role" required>
                                <option value="">역할 선택</option>
                                <option value="USER">일반 사용자</option>
                                <option value="INTERVIEWER">면접관</option>
                                <option value="ADMIN">관리자</option>
                                <option value="SUPER_ADMIN">최고 관리자</option>
                            </select>
                            <small>사용자의 시스템 권한 레벨</small>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <div class="checkbox-group">
                            <input type="checkbox" id="isActive" name="isActive" value="true" checked>
                            <label for="isActive">활성 계정</label>
                        </div>
                        <small>체크 해제 시 비활성 계정으로 생성됩니다.</small>
                    </div>
                    
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">사용자 추가</button>
                        <a href="admin/dashboard" class="btn btn-secondary">취소</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script>
        // 비밀번호 확인 검증
        document.getElementById('confirmPassword').addEventListener('input', function() {
            const password = document.getElementById('password').value;
            const confirmPassword = this.value;
            
            if (password !== confirmPassword) {
                this.setCustomValidity('비밀번호가 일치하지 않습니다.');
            } else {
                this.setCustomValidity('');
            }
        });
    </script>
</body>
</html> 