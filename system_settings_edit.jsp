<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.model.SystemSettings" %>
<%
    // 세션 검증 - username 속성 사용
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    SystemSettings setting = (SystemSettings) request.getAttribute("setting");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    
    if (setting == null) {
        response.sendRedirect("settings");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>시스템 설정 수정 - 채용 관리 시스템 V1.0</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            background: #f0f0f0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
        }
        
        .container {
            max-width: 1000px;
            margin: 0 auto;
        }
        
        .top-bar {
            background: white;
            border: 1px solid #d0d7de;
            padding: 10px 20px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .top-bar h2 {
            margin: 0;
            color: #24292f;
            font-size: 1.2rem;
            font-weight: 600;
        }
        
        .top-bar a {
            padding: 6px 12px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            background: white;
            color: #24292f;
            cursor: pointer;
            font-size: 0.85rem;
            transition: all 0.2s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        
        .top-bar a:hover {
            background: #f6f8fa;
            border-color: #8c959f;
        }
        
        .main-dashboard {
            background: white;
            border: 1px solid #d0d7de;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .dashboard-header {
            background: #0078d4;
            color: white;
            padding: 15px 25px;
            border-bottom: 1px solid #106ebe;
        }
        
        .dashboard-header h1 {
            margin: 0;
            font-size: 1.3rem;
            font-weight: 600;
        }
        
        .dashboard-content {
            padding: 20px;
        }
        
        .form-section {
            margin-bottom: 25px;
            border: 1px solid #d0d7de;
            border-radius: 6px;
        }
        
        .form-section-header {
            background: #f6f8fa;
            border-bottom: 1px solid #d0d7de;
            padding: 12px 16px;
            font-weight: 600;
            color: #24292f;
            font-size: 0.95rem;
        }
        
        .form-section-content {
            padding: 16px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group:last-child {
            margin-bottom: 0;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
            color: #24292f;
            font-size: 0.9rem;
        }
        
        .required {
            color: #cf222e;
        }
        
        .form-control {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            font-size: 0.9rem;
            transition: all 0.2s;
            box-sizing: border-box;
            font-family: inherit;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #0969da;
            box-shadow: 0 0 0 3px rgba(9, 105, 218, 0.15);
        }
        
        .form-control.readonly {
            background-color: #f6f8fa;
            color: #656d76;
        }
        
        textarea.form-control {
            resize: vertical;
            min-height: 80px;
            line-height: 1.4;
        }
        
        .setting-info {
            background: #fff8c5;
            border: 1px solid #d4ac0d;
            border-radius: 6px;
            padding: 16px;
            margin-bottom: 20px;
        }
        
        .setting-info-title {
            font-weight: 600;
            color: #24292f;
            margin-bottom: 8px;
            font-size: 0.9rem;
        }
        
        .setting-info-content {
            color: #656d76;
            font-size: 0.85rem;
            line-height: 1.4;
        }
        
        .setting-info-content strong {
            color: #24292f;
        }
        
        .button-group {
            display: flex;
            gap: 8px;
            justify-content: flex-end;
            padding-top: 16px;
            border-top: 1px solid #d0d7de;
            margin-top: 20px;
        }
        
        .btn {
            padding: 6px 16px;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            font-size: 0.9rem;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s;
            text-align: center;
        }
        
        .btn-primary {
            background: #1f883d;
            border-color: #1f883d;
            color: white;
        }
        
        .btn-primary:hover {
            background: #1a7f37;
            border-color: #1a7f37;
        }
        
        .btn-secondary {
            background: white;
            color: #24292f;
        }
        
        .btn-secondary:hover {
            background: #f6f8fa;
            border-color: #8c959f;
        }
        
        .alert {
            padding: 12px 16px;
            border-radius: 6px;
            margin-bottom: 16px;
            border: 1px solid transparent;
            font-size: 0.9rem;
        }
        
        .alert-danger {
            background-color: #ffebe9;
            border-color: #ffcdd2;
            color: #cf222e;
        }
        
        .alert-success {
            background-color: #dafbe1;
            border-color: #a2d2a8;
            color: #1f883d;
        }
        
        .form-help {
            font-size: 0.8rem;
            color: #656d76;
            margin-top: 4px;
            line-height: 1.3;
        }
        
        @media (max-width: 768px) {
            .container {
                margin: 10px;
                padding: 0 10px;
            }
            
            .dashboard-content {
                padding: 12px;
            }
            
            .button-group {
                flex-direction: column;
            }
            
            .btn {
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h2>🔧 시스템 설정 수정</h2>
            <div>
                <span style="margin-right: 15px; color: #656d76;">안녕하세요, <%= username %>님</span>
                <a href="settings">🔙 설정 목록</a>
            </div>
        </div>
        
        <% if (errorMessage != null) { %>
            <div class="alert alert-danger">
                <%= errorMessage %>
            </div>
        <% } %>
        
        <% if (successMessage != null) { %>
            <div class="alert alert-success">
                <%= successMessage %>
            </div>
        <% } %>
        
        <div class="main-dashboard">
            <div class="dashboard-header">
                <h1>설정 정보 수정</h1>
            </div>
            <div class="dashboard-content">
                <div class="setting-info">
                    <div class="setting-info-title">📋 현재 설정 정보</div>
                    <div class="setting-info-content">
                        설정 키: <strong><%= setting.getSettingKey() %></strong><br>
                        카테고리: <strong><%= setting.getCategory() %></strong><br>
                        마지막 수정: <strong><%= setting.getUpdatedAt() != null ? setting.getUpdatedAt() : "정보 없음" %></strong>
                    </div>
                </div>
                
                <form action="settings" method="post" id="editForm">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="settingKey" value="<%= setting.getSettingKey() %>">
                    
                    <div class="form-section">
                        <div class="form-section-header">
                            ⚙️ 기본 정보
                        </div>
                        <div class="form-section-content">
                            <div class="form-group">
                                <label for="settingKey">설정 키 <span class="required">*</span></label>
                                <input type="text" 
                                       id="settingKey" 
                                       name="settingKeyDisplay" 
                                       value="<%= setting.getSettingKey() %>" 
                                       class="form-control readonly" 
                                       readonly>
                                <div class="form-help">설정 키는 변경할 수 없습니다.</div>
                            </div>
                            
                            <div class="form-group">
                                <label for="settingValue">설정 값 <span class="required">*</span></label>
                                <textarea id="settingValue" 
                                          name="settingValue" 
                                          class="form-control" 
                                          placeholder="설정 값을 입력하세요"
                                          required><%= setting.getSettingValue() != null ? setting.getSettingValue() : "" %></textarea>
                                <div class="form-help">이 설정의 실제 값을 입력하세요.</div>
                            </div>
                            
                            <div class="form-group">
                                <label for="description">설명</label>
                                <textarea id="description" 
                                          name="description" 
                                          class="form-control" 
                                          placeholder="설정에 대한 설명을 입력하세요"
                                          rows="3"><%= setting.getDescription() != null ? setting.getDescription() : "" %></textarea>
                                <div class="form-help">이 설정이 무엇을 하는지 설명해주세요.</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="button-group">
                        <a href="settings" class="btn btn-secondary">
                            ❌ 취소
                        </a>
                        <button type="submit" class="btn btn-primary" onclick="return confirmUpdate()">
                            💾 저장
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script>
        function confirmUpdate() {
            const settingKey = document.getElementById('settingKey').value;
            const settingValue = document.getElementById('settingValue').value.trim();
            
            if (!settingValue) {
                alert('설정 값을 입력해주세요.');
                document.getElementById('settingValue').focus();
                return false;
            }
            
            return confirm('설정 "' + settingKey + '"을(를) 수정하시겠습니까?');
        }
        
        // 폼 검증
        document.getElementById('editForm').addEventListener('submit', function(e) {
            const settingValue = document.getElementById('settingValue').value.trim();
            
            if (!settingValue) {
                e.preventDefault();
                alert('설정 값을 입력해주세요.');
                document.getElementById('settingValue').focus();
                return false;
            }
        });
        
        // 자동 크기 조정
        document.querySelectorAll('textarea').forEach(function(textarea) {
            textarea.addEventListener('input', function() {
                this.style.height = 'auto';
                this.style.height = (this.scrollHeight) + 'px';
            });
        });
    </script>
</body>
</html>