<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.model.User" %>
<%
    // 세션 검증
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 관리자 권한 확인
    String role = (String) session.getAttribute("role");
    if (!"ADMIN".equals(role)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "관리자 권한이 필요합니다.");
        return;
    }
    
    // 📝 수정 모드인지 신규 모드인지 확인
    User user = (User) request.getAttribute("user");
    boolean isEditMode = (user != null);
    String pageTitle = isEditMode ? "사용자 정보 수정" : "새 사용자 추가";
    String formAction = isEditMode ? "admin/user/edit" : "admin/user/add";
    
    System.out.println("📝 [NEW admin_user_form.jsp] 모드: " + (isEditMode ? "수정" : "신규"));
    if (isEditMode && user != null) {
        System.out.println("📝 사용자 정보: ID=" + user.getId() + ", username=" + user.getUsername() + ", role=" + user.getRole());
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title><%= pageTitle %> - 관리자 대시보드</title>
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
            border-radius: 8px 8px 0 0;
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
            border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 6px;
            transition: background-color 0.2s;
        }
        
        .back-link:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }
        
        .main-dashboard {
            background-color: white;
            border-radius: 0 0 8px 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
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
            padding: 30px;
        }
        
        .form-row {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .form-group {
            flex: 1;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #24292f;
        }
        
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            font-size: 14px;
            font-family: inherit;
            background-color: #ffffff;
            transition: border-color 0.2s;
        }
        
        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #0078d4;
            box-shadow: 0 0 0 3px rgba(0, 120, 212, 0.1);
        }
        
        .form-group input[readonly] {
            background-color: #f6f8fa;
            color: #656d76;
        }
        
        .form-group small {
            display: block;
            margin-top: 5px;
            color: #656d76;
            font-size: 12px;
        }
        
        .form-actions {
            margin-top: 30px;
            display: flex;
            gap: 12px;
        }
        
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            transition: all 0.2s;
        }
        
        .btn-primary {
            background-color: #1f883d;
            color: white;
        }
        
        .btn-primary:hover {
            background-color: #1a7733;
        }
        
        .btn-secondary {
            background-color: white;
            color: #24292f;
            border: 1px solid #d0d7de;
        }
        
        .btn-secondary:hover {
            background-color: #f3f4f6;
        }
        
        .error {
            background-color: #fef2f2;
            border: 1px solid #fecaca;
            color: #dc2626;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 20px;
        }
        
        .success {
            background-color: #f0fdf4;
            border: 1px solid #bbf7d0;
            color: #16a34a;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h1><%= isEditMode ? "📝 사용자 정보 수정" : "➕ 새 사용자 추가" %></h1>
            <a href="admin/dashboard" class="back-link">← 대시보드로 돌아가기</a>
        </div>
        
        <div class="main-dashboard">
            <div class="dashboard-header">
                <h2><%= isEditMode ? "사용자 정보 수정" : "사용자 정보 입력" %></h2>
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
                
                <form action="<%= formAction %>" method="post" autocomplete="off" data-lpignore="true">
                    <% if (isEditMode) { %>
                        <input type="hidden" name="id" value="<%= user.getId() %>">
                    <% } %>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="username">사용자명 *</label>
                            <input type="text" 
                                   id="username" 
                                   name="username" 
                                   value="<%= isEditMode && user.getUsername() != null ? user.getUsername() : "" %>" 
                                   required 
                                   <%= isEditMode ? "readonly" : "" %>
                                   autocomplete="<%= isEditMode ? "username" : "new-username" %>"
                                   data-lpignore="true"
                                   data-form-type="other"
                                   spellcheck="false">
                            <small>영문, 숫자, 언더스코어(_)만 사용 가능</small>
                        </div>
                        
                        <div class="form-group">
                            <label for="email">이메일</label>
                            <input type="email" 
                                   id="email" 
                                   name="email" 
                                   value="<%= isEditMode && user.getEmail() != null ? user.getEmail() : "" %>"
                                   autocomplete="<%= isEditMode ? "email" : "new-email" %>"
                                   data-lpignore="true"
                                   data-form-type="other"
                                   spellcheck="false">
                            <small>선택사항</small>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="password">비밀번호 <%= isEditMode ? "" : "*" %></label>
                            <input type="password" 
                                   id="password" 
                                   name="password" 
                                   <%= isEditMode ? "" : "required" %>
                                   autocomplete="<%= isEditMode ? "current-password" : "new-password" %>"
                                   data-lpignore="true"
                                   data-form-type="other">
                            <small><%= isEditMode ? "변경하려면 입력하세요 (선택사항)" : "최소 6자 이상" %></small>
                        </div>
                        
                        <div class="form-group">
                            <label for="confirmPassword">비밀번호 확인 <%= isEditMode ? "" : "*" %></label>
                            <input type="password" 
                                   id="confirmPassword" 
                                   name="confirmPassword" 
                                   <%= isEditMode ? "" : "required" %>
                                   autocomplete="<%= isEditMode ? "current-password" : "new-password" %>"
                                   data-lpignore="true"
                                   data-form-type="other">
                            <small><%= isEditMode ? "비밀번호를 입력했다면 확인 입력" : "위와 동일하게 입력" %></small>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="fullName">전체 이름</label>
                            <input type="text" 
                                   id="fullName" 
                                   name="fullName" 
                                   value="<%= isEditMode && user.getFullName() != null ? user.getFullName() : "" %>"
                                   autocomplete="<%= isEditMode ? "name" : "new-name" %>"
                                   data-lpignore="true"
                                   data-form-type="other"
                                   spellcheck="false">
                            <small>표시될 이름</small>
                        </div>
                        
                        <div class="form-group">
                            <label for="role">역할 *</label>
                            <select id="role" name="role" required autocomplete="off">
                                <option value="">역할 선택</option>
                                <option value="INTERVIEWER" <%= isEditMode && user.getRole() != null && "INTERVIEWER".equals(user.getRole()) ? "selected" : "" %>>인터뷰어</option>
                                <option value="ADMIN" <%= isEditMode && user.getRole() != null && "ADMIN".equals(user.getRole()) ? "selected" : "" %>>관리자</option>
                            </select>
                            <small>사용자의 시스템 권한 레벨</small>
                        </div>
                    </div>
                    
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= isEditMode ? "수정 완료" : "사용자 추가" %>
                        </button>
                        <a href="admin/users" class="btn btn-secondary">취소</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script>
        console.log('📝 [NEW] admin_user_form.jsp 로드됨');
        console.log('📝 수정 모드:', <%= isEditMode %>);
        
        // 🔄 신규 모드에서만 폼 필드 초기화 (브라우저 자동완성 방지)
        function clearFormFieldsForNewMode() {
            const isEditMode = <%= isEditMode %>;
            if (isEditMode) {
                console.log('📝 수정 모드: 폼 초기화 건너뛰기');
                return;
            }
            
            console.log('🔄 신규 모드: 폼 필드 자동완성 방지 시작');
            
            // 신규 모드에서만 필드 초기화
            const fieldsToReset = ['username', 'email', 'password', 'confirmPassword', 'fullName'];
            
            fieldsToReset.forEach(fieldId => {
                const field = document.getElementById(fieldId);
                if (field && field.value !== '') {
                    console.log(`🔄 ${fieldId} 필드 자동완성 감지, 초기화 중...`);
                    field.value = '';
                    field.defaultValue = '';
                }
            });
            
            // 신규 모드에서 기본 역할 설정
            const roleSelect = document.getElementById('role');
            if (roleSelect) {
                if (roleSelect.value === '' || roleSelect.selectedIndex === 0) {
                    roleSelect.value = 'INTERVIEWER'; // 기본값: 인터뷰어
                    console.log('✅ 기본 역할 설정: 인터뷰어');
                }
            }
            
            console.log('✅ 신규 모드: 자동완성 방지 완료');
        }
        
        // 비밀번호 확인 검증
        function setupPasswordValidation() {
            const passwordField = document.getElementById('password');
            const confirmPasswordField = document.getElementById('confirmPassword');
            const isEditMode = <%= isEditMode %>;
            
            function validatePasswords() {
                if (!passwordField || !confirmPasswordField) return;
                
                const password = passwordField.value;
                const confirmPassword = confirmPasswordField.value;
                
                // 수정 모드에서 둘 다 비어있으면 검증 패스
                if (isEditMode && password === '' && confirmPassword === '') {
                    confirmPasswordField.setCustomValidity('');
                    return;
                }
                
                // 비밀번호가 입력되었다면 확인 필드와 일치해야 함
                if (password !== confirmPassword) {
                    confirmPasswordField.setCustomValidity('비밀번호가 일치하지 않습니다.');
                } else {
                    confirmPasswordField.setCustomValidity('');
                }
            }
            
            if (passwordField && confirmPasswordField) {
                passwordField.addEventListener('input', validatePasswords);
                confirmPasswordField.addEventListener('input', validatePasswords);
            }
        }
        
        // 페이지 로드 시 실행
        document.addEventListener('DOMContentLoaded', function() {
            console.log('📄 DOMContentLoaded 실행');
            
            // 비밀번호 검증 설정
            setupPasswordValidation();
            
            // 신규 모드에서만 자동완성 방지
            setTimeout(clearFormFieldsForNewMode, 100);
            
            console.log('✅ [NEW] 폼 초기화 완료');
        });
        
        // 페이지 표시 시에도 실행 (뒤로가기 등)
        window.addEventListener('pageshow', function(event) {
            console.log('📄 pageshow 이벤트');
            setTimeout(clearFormFieldsForNewMode, 50);
        });
        
        // 윈도우 포커스 시에도 실행
        window.addEventListener('focus', function() {
            console.log('📄 focus 이벤트');
            setTimeout(clearFormFieldsForNewMode, 50);
        });
    </script>
</body>
</html> 