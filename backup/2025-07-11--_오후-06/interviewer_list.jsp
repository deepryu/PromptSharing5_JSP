<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map, com.example.model.Interviewer" %>
<%
    String username = (String)session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    List<Interviewer> interviewers = (List<Interviewer>) request.getAttribute("interviewers");
    Map<String, Integer> stats = (Map<String, Integer>) request.getAttribute("stats");
    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
    String filterType = (String) request.getAttribute("filterType");
    String filterValue = (String) request.getAttribute("filterValue");
    
    if (interviewers == null) interviewers = new java.util.ArrayList<>();
    if (stats == null) stats = new java.util.HashMap<>();
%>
<!DOCTYPE html>
<html>
<head>
    <title>면접관 관리</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            background: #f0f0f0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
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
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .dashboard-header h1 {
            margin: 0;
            font-size: 1.3rem;
            font-weight: 600;
        }
        
        .dashboard-content {
            padding: 20px;
        }
        
        .btn-primary {
            background: #1f883d;
            color: white;
            border: 1px solid #1a7f37;
            padding: 8px 16px;
            border-radius: 3px;
            text-decoration: none;
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
            padding: 6px 12px;
            border-radius: 3px;
            text-decoration: none;
            font-size: 0.85rem;
            cursor: pointer;
            transition: all 0.2s;
            margin-left: 8px;
        }
        
        .btn-secondary:hover {
            background: #f6f8fa;
            border-color: #8c959f;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .stat-card {
            background: #f6f8fa;
            border: 1px solid #d0d7de;
            padding: 15px;
            border-radius: 3px;
        }
        
        .stat-number {
            font-size: 1.8rem;
            font-weight: 600;
            color: #0969da;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: #656d76;
            font-size: 0.9rem;
        }
        
        .search-filter-bar {
            background: #f6f8fa;
            border: 1px solid #d0d7de;
            padding: 15px 20px;
            margin-bottom: 20px;
            border-radius: 3px;
        }
        
        .search-container {
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: wrap;
        }
        
        .search-section {
            display: flex;
            gap: 0;
            align-items: center;
        }
        
        .search-group, .filter-group {
            display: flex;
            gap: 8px;
            align-items: center;
        }
        
        .search-group label, .filter-group label {
            font-weight: 600;
            color: #24292f;
            font-size: 0.9rem;
            white-space: nowrap;
            margin-right: 5px;
        }
        
        .search-input {
            width: 200px;
            padding: 10px 14px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            font-size: 0.9rem;
            background: white;
            margin-right: 8px;
        }
        
        .search-input:focus, .filter-input:focus, .filter-select:focus {
            outline: none;
            border-color: #0969da;
            box-shadow: 0 0 0 3px rgba(9, 105, 218, 0.1);
        }
        
        .filter-select {
            padding: 10px 14px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            font-size: 0.9rem;
            width: 110px;
            background: white;
            margin-right: 8px;
        }
        
        .filter-input {
            width: 120px;
            padding: 10px 14px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            font-size: 0.9rem;
            background: white;
            margin-right: 8px;
        }
        
        .search-btn {
            padding: 10px 16px;
            border-radius: 3px;
            font-size: 0.9rem;
            cursor: pointer;
            transition: all 0.2s;
            white-space: nowrap;
            border: 1px solid;
            margin-left: 5px;
        }
        
        .actions-section {
            margin-left: auto;
            padding-left: 20px;
        }
        
        /* 구분선 스타일 개선 */
        .divider {
            height: 35px;
            width: 1px;
            background: #d0d7de;
            margin: 0 15px;
        }
        
        /* 반응형 디자인 */
        @media (max-width: 1000px) {
            .search-container {
                flex-direction: column;
                align-items: stretch;
                gap: 15px;
            }
            
            .search-section {
                justify-content: center;
                gap: 10px;
            }
            
            .search-group, .filter-group {
                gap: 8px;
            }
            
            .search-input {
                width: 180px;
                margin-right: 0;
            }
            
            .filter-input {
                width: 120px;
                margin-right: 0;
            }
            
            .filter-select {
                margin-right: 0;
            }
            
            .search-btn {
                margin-left: 0;
            }
            
            .actions-section {
                margin-left: 0;
                padding-left: 0;
                text-align: center;
            }
            
            .divider {
                display: none;
            }
        }
        
        .current-filter {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            padding: 8px 12px;
            border-radius: 3px;
            font-size: 0.8rem;
            color: #856404;
            text-align: center;
            max-width: 200px;
        }
        
        .interviewer-table {
            width: 100%;
            border-collapse: collapse;
            border: 1px solid #d0d7de;
        }
        
        .interviewer-table th {
            background: #f6f8fa;
            border: 1px solid #d0d7de;
            padding: 12px;
            text-align: left;
            font-weight: 600;
            color: #24292f;
            font-size: 0.9rem;
        }
        
        .interviewer-table td {
            border: 1px solid #d0d7de;
            padding: 12px;
            font-size: 0.9rem;
        }
        
        .interviewer-table tr:nth-child(even) {
            background: #f6f8fa;
        }
        
        .interviewer-table tr:hover {
            background: #eaeaea;
        }
        
        .status-active {
            color: #1a7f37;
            font-weight: 600;
        }
        
        .status-inactive {
            color: #d1242f;
            font-weight: 600;
        }
        
        .expertise-badge {
            background: #ddf4ff;
            color: #0969da;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.8rem;
            border: 1px solid #b6e3ff;
        }
        
        .role-badge {
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        
        .role-senior {
            background: #fff8dc;
            color: #bf8700;
            border: 1px solid #d4ac0d;
        }
        
        .role-lead {
            background: #ffeaa7;
            color: #6c5ce7;
            border: 1px solid #a29bfe;
        }
        
        .role-junior {
            background: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
        }
        
        .message {
            padding: 12px 16px;
            margin-bottom: 20px;
            border-radius: 3px;
            border: 1px solid;
        }
        
        .message.success {
            background: #d4edda;
            color: #155724;
            border-color: #c3e6cb;
        }
        
        .message.error {
            background: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #656d76;
        }
        
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        
        .btn-sm {
            padding: 4px 8px;
            font-size: 0.8rem;
            border-radius: 3px;
            text-decoration: none;
            border: 1px solid;
            cursor: pointer;
        }
        
        .btn-edit {
            background: #fff3cd;
            color: #856404;
            border-color: #ffeaa7;
        }
        
        .btn-edit:hover {
            background: #ffeaa7;
        }
        
        .btn-delete {
            background: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }
        
        .btn-delete:hover {
            background: #f5c6cb;
        }
        
        .btn-view {
            background: #d1ecf1;
            color: #0c5460;
            border-color: #bee5eb;
        }
        
        .btn-view:hover {
            background: #bee5eb;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h2>👨‍💼 면접관(관리자) 관리</h2>
            <div class="nav-buttons">
                <a href="main.jsp" class="btn">🏠 메인</a>
                <a href="candidates" class="btn">👥 인터뷰 대상자 관리</a>
                <a href="interview/list" class="btn">📅 인터뷰 일정 관리</a>
                <a href="questions" class="btn">💡 질문/평가 항목 관리</a>
                <a href="results" class="btn">📝 인터뷰 결과 기록/관리</a>
                <a href="statistics" class="btn">📊 통계 및 리포트</a>
                <a href="logout" class="btn btn-danger">🚪 로그아웃</a>
            </div>
        </div>
        
        <div class="main-dashboard">
            <div class="dashboard-header">
                <h1>면접관 관리</h1>
                <a href="interviewers?action=new" class="btn-primary">➕ 새 면접관 등록</a>
            </div>
            <div class="dashboard-content">
                <!-- 성공/오류 메시지 -->
                <% if (successMessage != null) { %>
                    <div class="message success">✅ <%= successMessage %></div>
                <% } %>
                <% if (errorMessage != null) { %>
                    <div class="message error">❌ <%= errorMessage %></div>
                <% } %>
                
                <!-- 통계 카드 -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-number"><%= stats.getOrDefault("total", 0) %></div>
                        <div class="stat-label">전체 면접관</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= stats.getOrDefault("active", 0) %></div>
                        <div class="stat-label">활성 면접관</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= stats.getOrDefault("total", 0) - stats.getOrDefault("active", 0) %></div>
                        <div class="stat-label">비활성 면접관</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= interviewers.size() %></div>
                        <div class="stat-label">현재 표시</div>
                    </div>
                </div>
                
                <!-- 검색 및 필터 -->
                <div class="search-filter-bar">
                    <div class="search-container">
                        <!-- 검색 그룹 -->
                        <form method="get" action="interviewers" class="search-section">
                            <input type="hidden" name="action" value="search">
                            <div class="search-group">
                                <label>🔍 검색</label>
                                <input type="text" name="keyword" placeholder="이름, 이메일, 부서로 검색..." 
                                       value="<%= searchKeyword != null ? searchKeyword : "" %>" class="search-input">
                                <button type="submit" class="btn-primary search-btn">검색</button>
                            </div>
                        </form>
                        
                        <!-- 구분선 -->
                        <div class="divider"></div>
                        
                        <!-- 필터 그룹 -->
                        <form method="get" action="interviewers" class="search-section">
                            <input type="hidden" name="action" value="filter">
                            <div class="filter-group">
                                <label>🔽 필터</label>
                                <select name="filterType" class="filter-select">
                                    <option value="department" <%= "department".equals(filterType) ? "selected" : "" %>>부서별</option>
                                    <option value="expertise" <%= "expertise".equals(filterType) ? "selected" : "" %>>전문분야별</option>
                                </select>
                                <input type="text" name="filterValue" placeholder="값 입력..." 
                                       value="<%= filterValue != null ? filterValue : "" %>" class="filter-input">
                                <button type="submit" class="btn-primary search-btn">적용</button>
                            </div>
                        </form>
                        
                        <!-- 액션 버튼 -->
                        <div class="actions-section">
                            <a href="interviewers" class="btn-secondary" style="text-decoration: none;">🔄 전체보기</a>
                        </div>
                    </div>
                    
                    <!-- 현재 검색/필터 조건 표시 -->
                    <% if (searchKeyword != null || filterValue != null) { %>
                        <div style="margin-top: 10px; padding-top: 10px; border-top: 1px solid #d0d7de;">
                            <div style="background: #e1f5fe; border: 1px solid #b3e5fc; padding: 6px 12px; border-radius: 3px; font-size: 0.8rem; color: #01579b; display: inline-block;">
                                <strong>현재 조건:</strong>
                                <% if (searchKeyword != null) { %>
                                    검색 "<%= searchKeyword %>"
                                <% } %>
                                <% if (searchKeyword != null && filterValue != null) { %> | <% } %>
                                <% if (filterValue != null) { %>
                                    <%= filterType.equals("department") ? "부서" : "전문분야" %> "<%= filterValue %>"
                                <% } %>
                            </div>
                        </div>
                    <% } %>
                </div>
                
                <!-- 면접관 목록 테이블 -->
                <% if (interviewers.isEmpty()) { %>
                    <div class="empty-state">
                        <h3>등록된 면접관이 없습니다</h3>
                        <p>새로운 면접관을 등록해보세요.</p>
                        <a href="interviewers?action=new" class="btn-primary">➕ 첫 번째 면접관 등록</a>
                    </div>
                <% } else { %>
                    <table class="interviewer-table">
                        <thead>
                            <tr>
                                <th>이름</th>
                                <th>이메일</th>
                                <th>부서</th>
                                <th>직책</th>
                                <th>전문분야</th>
                                <th>역할</th>
                                <th>연락처</th>
                                <th>상태</th>
                                <th>작업</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Interviewer interviewer : interviewers) { %>
                                <tr>
                                    <td><strong><%= interviewer.getName() %></strong></td>
                                    <td><%= interviewer.getEmail() %></td>
                                    <td><%= interviewer.getDepartment() %></td>
                                    <td><%= interviewer.getPosition() != null ? interviewer.getPosition() : "-" %></td>
                                    <td>
                                        <span class="expertise-badge"><%= interviewer.getExpertise() %></span>
                                    </td>
                                    <td>
                                        <span class="role-badge role-<%= interviewer.getRole().toLowerCase() %>">
                                            <%= interviewer.getRole() %>
                                        </span>
                                    </td>
                                    <td><%= interviewer.getPhoneNumber() != null ? interviewer.getPhoneNumber() : "-" %></td>
                                    <td>
                                        <span class="<%= interviewer.isActive() ? "status-active" : "status-inactive" %>">
                                            <%= interviewer.isActive() ? "활성" : "비활성" %>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="action-buttons">
                                            <a href="interviewers?action=detail&id=<%= interviewer.getId() %>" 
                                               class="btn-sm btn-view">상세</a>
                                            <a href="interviewers?action=edit&id=<%= interviewer.getId() %>" 
                                               class="btn-sm btn-edit">수정</a>
                                            <% if (interviewer.isActive()) { %>
                                                <a href="interviewers?action=delete&id=<%= interviewer.getId() %>" 
                                                   class="btn-sm btn-delete" 
                                                   onclick="return confirm('이 면접관을 비활성화하시겠습니까?')">비활성화</a>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html> 