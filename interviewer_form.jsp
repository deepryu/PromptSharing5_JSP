<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.model.Interviewer" %>
<%
    String username = (String)session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    Interviewer interviewer = (Interviewer) request.getAttribute("interviewer");
    String errorMessage = (String) request.getAttribute("errorMessage");
    boolean isEdit = (interviewer != null && interviewer.getId() != null);
%>
<!DOCTYPE html>
<html>
<head>
    <title><%= isEdit ? "면접관 수정" : "면접관 등록" %></title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            background: #f0f0f0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
        }
        
        .container {
            max-width: 800px;
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
            padding: 30px;
        }
        
        .form-section {
            background: #f6f8fa;
            border: 1px solid #d0d7de;
            padding: 25px;
            border-radius: 3px;
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group.full-width {
            grid-column: 1 / -1;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 6px;
            color: #24292f;
            font-weight: 600;
            font-size: 0.9rem;
        }
        
        .form-group label.required::after {
            content: " *";
            color: #d73a49;
        }
        
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            font-size: 0.9rem;
            box-sizing: border-box;
        }
        
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #0969da;
            box-shadow: 0 0 0 3px rgba(9, 105, 218, 0.1);
        }
        
        .form-group textarea {
            resize: vertical;
            min-height: 80px;
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
        
        .btn-primary {
            background: #1f883d;
            color: white;
            border: 1px solid #1a7f37;
            padding: 10px 20px;
            border-radius: 3px;
            font-size: 0.9rem;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .btn-primary:hover {
            background: #1a7f37;
            border-color: #1a7f37;
        }
        
        .btn-secondary {
            background: white;
            color: #24292f;
            border: 1px solid #d0d7de;
            padding: 8px 16px;
            border-radius: 3px;
            text-decoration: none;
            font-size: 0.9rem;
            cursor: pointer;
            transition: all 0.2s;
            margin-left: 10px;
        }
        
        .btn-secondary:hover {
            background: #f6f8fa;
            border-color: #8c959f;
        }
        
        .button-group {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #d0d7de;
        }
        
        .message {
            padding: 12px 16px;
            margin-bottom: 20px;
            border-radius: 3px;
            border: 1px solid;
        }
        
        .message.error {
            background: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }
        
        .field-description {
            font-size: 0.8rem;
            color: #656d76;
            margin-top: 4px;
        }
        
        .required-note {
            color: #656d76;
            font-size: 0.8rem;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h2>👨‍💼 <%= isEdit ? "면접관 수정" : "면접관 등록" %></h2>
            <div>
                <span style="margin-right: 15px; color: #656d76;">안녕하세요, <%= username %>님</span>
                <a href="interviewers" class="btn-secondary">📋 면접관 목록</a>
            </div>
        </div>
        
        <div class="main-dashboard">
            <div class="dashboard-header">
                <h1><%= isEdit ? "면접관 정보 수정" : "새 면접관 등록" %></h1>
            </div>
            <div class="dashboard-content">
                <!-- 오류 메시지 -->
                <% if (errorMessage != null) { %>
                    <div class="message error">❌ <%= errorMessage %></div>
                <% } %>
                
                <form method="post" action="interviewers">
                    <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>">
                    <% if (isEdit) { %>
                        <input type="hidden" name="id" value="<%= interviewer.getId() %>">
                    <% } %>
                    
                    <div class="form-section">
                        <div class="required-note">* 표시된 항목은 필수 입력 사항입니다.</div>
                        
                        <div class="form-grid">
                            <!-- 기본 정보 -->
                            <div class="form-group">
                                <label for="name" class="required">이름</label>
                                <input type="text" id="name" name="name" 
                                       value="<%= interviewer != null && interviewer.getName() != null ? interviewer.getName() : "" %>" 
                                       required maxlength="100">
                                <div class="field-description">면접관의 실명을 입력해주세요.</div>
                            </div>
                            
                            <div class="form-group">
                                <label for="email" class="required">이메일</label>
                                <input type="email" id="email" name="email" 
                                       value="<%= interviewer != null && interviewer.getEmail() != null ? interviewer.getEmail() : "" %>" 
                                       required maxlength="150">
                                <div class="field-description">회사 이메일 주소를 입력해주세요.</div>
                            </div>
                            
                            <div class="form-group">
                                <label for="department" class="required">부서</label>
                                <select id="department" name="department" required>
                                    <option value="">부서를 선택하세요</option>
                                    <option value="개발팀" <%= interviewer != null && "개발팀".equals(interviewer.getDepartment()) ? "selected" : "" %>>개발팀</option>
                                    <option value="인사팀" <%= interviewer != null && "인사팀".equals(interviewer.getDepartment()) ? "selected" : "" %>>인사팀</option>
                                    <option value="경영지원팀" <%= interviewer != null && "경영지원팀".equals(interviewer.getDepartment()) ? "selected" : "" %>>경영지원팀</option>
                                    <option value="디자인팀" <%= interviewer != null && "디자인팀".equals(interviewer.getDepartment()) ? "selected" : "" %>>디자인팀</option>
                                    <option value="마케팅팀" <%= interviewer != null && "마케팅팀".equals(interviewer.getDepartment()) ? "selected" : "" %>>마케팅팀</option>
                                    <option value="영업팀" <%= interviewer != null && "영업팀".equals(interviewer.getDepartment()) ? "selected" : "" %>>영업팀</option>
                                    <option value="기타" <%= interviewer != null && "기타".equals(interviewer.getDepartment()) ? "selected" : "" %>>기타</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label for="position">직책</label>
                                <input type="text" id="position" name="position" 
                                       value="<%= interviewer != null && interviewer.getPosition() != null ? interviewer.getPosition() : "" %>" 
                                       maxlength="100" placeholder="예: 시니어 개발자, 팀장, 매니저">
                            </div>
                            
                            <div class="form-group">
                                <label for="phoneNumber">연락처</label>
                                <input type="tel" id="phoneNumber" name="phoneNumber" 
                                       value="<%= interviewer != null && interviewer.getPhoneNumber() != null ? interviewer.getPhoneNumber() : "" %>" 
                                       maxlength="20" placeholder="010-1234-5678">
                            </div>
                            
                            <div class="form-group">
                                <label for="expertise">전문분야</label>
                                <select id="expertise" name="expertise">
                                    <option value="기술" <%= interviewer != null && "기술".equals(interviewer.getExpertise()) ? "selected" : "" %>>기술</option>
                                    <option value="인사" <%= interviewer != null && "인사".equals(interviewer.getExpertise()) ? "selected" : "" %>>인사</option>
                                    <option value="경영" <%= interviewer != null && "경영".equals(interviewer.getExpertise()) ? "selected" : "" %>>경영</option>
                                    <option value="디자인" <%= interviewer != null && "디자인".equals(interviewer.getExpertise()) ? "selected" : "" %>>디자인</option>
                                    <option value="마케팅" <%= interviewer != null && "마케팅".equals(interviewer.getExpertise()) ? "selected" : "" %>>마케팅</option>
                                    <option value="영업" <%= interviewer != null && "영업".equals(interviewer.getExpertise()) ? "selected" : "" %>>영업</option>
                                </select>
                                <div class="field-description">면접 시 주로 담당할 분야를 선택해주세요.</div>
                            </div>
                            
                            <div class="form-group">
                                <label for="role">역할</label>
                                <select id="role" name="role">
                                    <option value="JUNIOR" <%= interviewer != null && "JUNIOR".equals(interviewer.getRole()) ? "selected" : "" %>>JUNIOR</option>
                                    <option value="SENIOR" <%= interviewer != null && "SENIOR".equals(interviewer.getRole()) ? "selected" : "" %>>SENIOR</option>
                                    <option value="LEAD" <%= interviewer != null && "LEAD".equals(interviewer.getRole()) ? "selected" : "" %>>LEAD</option>
                                </select>
                                <div class="field-description">면접에서의 역할 수준을 선택해주세요.</div>
                            </div>
                            
                            <div class="form-group">
                                <div class="checkbox-group">
                                    <input type="checkbox" id="isActive" name="isActive" value="true" 
                                           <%= interviewer == null || interviewer.isActive() ? "checked" : "" %>>
                                    <label for="isActive">활성 상태</label>
                                </div>
                                <div class="field-description">체크 해제 시 면접관이 비활성화됩니다.</div>
                            </div>
                            
                            <div class="form-group full-width">
                                <label for="notes">비고</label>
                                <textarea id="notes" name="notes" placeholder="면접관에 대한 추가 정보나 특이사항을 입력해주세요."><%= interviewer != null && interviewer.getNotes() != null ? interviewer.getNotes() : "" %></textarea>
                                <div class="field-description">경력, 전문분야 상세, 특이사항 등을 자유롭게 입력해주세요.</div>
                            </div>
                        </div>
                        
                        <div class="button-group">
                            <button type="submit" class="btn-primary">
                                <%= isEdit ? "💾 수정 완료" : "✅ 등록 완료" %>
                            </button>
                            <a href="interviewers" class="btn btn-secondary">❌ 취소</a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script>
        // 폼 유효성 검사
        document.querySelector('form').addEventListener('submit', function(e) {
            const name = document.getElementById('name').value.trim();
            const email = document.getElementById('email').value.trim();
            const department = document.getElementById('department').value;
            
            if (!name) {
                alert('이름을 입력해주세요.');
                e.preventDefault();
                document.getElementById('name').focus();
                return;
            }
            
            if (!email) {
                alert('이메일을 입력해주세요.');
                e.preventDefault();
                document.getElementById('email').focus();
                return;
            }
            
            if (!department) {
                alert('부서를 선택해주세요.');
                e.preventDefault();
                document.getElementById('department').focus();
                return;
            }
            
            // 이메일 형식 검증
            const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailPattern.test(email)) {
                alert('올바른 이메일 형식을 입력해주세요.');
                e.preventDefault();
                document.getElementById('email').focus();
                return;
            }
        });
    </script>
</body>
</html> 