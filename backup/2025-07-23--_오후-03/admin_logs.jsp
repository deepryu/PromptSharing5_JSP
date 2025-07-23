<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map, com.example.model.ActivityHistory" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // 세션 검증
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (!"ADMIN".equals(role)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "관리자 권한이 필요합니다.");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그 관리 - 관리자</title>
    <base href="${pageContext.request.contextPath}/">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Noto Sans', Helvetica, Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f6f8fa;
            color: #24292f;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f0f0f0;
            min-height: 100vh;
        }
        
        .top-bar {
            background-color: #0078d4;
            color: white;
            padding: 15px 20px;
            margin: -20px -20px 20px -20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 3px solid #106ebe;
        }
        
        .top-bar h1 {
            margin: 0;
            font-size: 24px;
            font-weight: 600;
        }
        
        .top-bar .nav-links a {
            color: white;
            text-decoration: none;
            margin-left: 20px;
            padding: 8px 16px;
            border-radius: 6px;
            transition: background-color 0.2s;
        }
        
        .top-bar .nav-links a:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }
        
        .main-dashboard {
            background-color: white;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            overflow: hidden;
        }
        
        .dashboard-header {
            background-color: #f6f8fa;
            padding: 16px 20px;
            border-bottom: 1px solid #d0d7de;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .dashboard-header h2 {
            margin: 0;
            color: #24292f;
            font-size: 20px;
            font-weight: 600;
        }
        
        .dashboard-content {
            padding: 20px;
        }
        
        .search-panel {
            background-color: #f6f8fa;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .search-form {
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: wrap;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        
        .form-group label {
            font-weight: 600;
            color: #24292f;
            font-size: 14px;
        }
        
        .form-control {
            padding: 8px 12px;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            font-size: 14px;
            background-color: white;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #0078d4;
            box-shadow: 0 0 0 3px rgba(0, 120, 212, 0.1);
        }
        
        .btn {
            padding: 8px 16px;
            border: 1px solid #d0d7de;
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
            background-color: #0078d4;
            color: white;
            border-color: #0078d4;
        }
        
        .btn-primary:hover {
            background-color: #106ebe;
            border-color: #106ebe;
        }
        
        .btn-secondary {
            background-color: white;
            color: #24292f;
        }
        
        .btn-secondary:hover {
            background-color: #f6f8fa;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .stat-card {
            background-color: #f6f8fa;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            padding: 16px;
            text-align: center;
        }
        
        .stat-number {
            font-size: 24px;
            font-weight: 600;
            color: #0078d4;
            margin-bottom: 5px;
        }
        
        .stat-label {
            font-size: 14px;
            color: #656d76;
        }
        
        .logs-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        
        .logs-table th,
        .logs-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #d0d7de;
        }
        
        .logs-table th {
            background-color: #f6f8fa;
            font-weight: 600;
            color: #24292f;
            font-size: 14px;
        }
        
        .logs-table td {
            font-size: 14px;
            color: #24292f;
        }
        
        .logs-table tr:hover {
            background-color: #f6f8fa;
        }
        
        .action-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
            text-transform: uppercase;
        }
        
        .action-login { background-color: #dcfce7; color: #166534; }
        .action-logout { background-color: #fee2e2; color: #991b1b; }
        .action-create { background-color: #dbeafe; color: #1e40af; }
        .action-update { background-color: #fef3c7; color: #92400e; }
        .action-delete { background-color: #fecaca; color: #dc2626; }
        .action-view { background-color: #e5e7eb; color: #374151; }
        .action-search { background-color: #f3e8ff; color: #7c3aed; }
        
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #656d76;
        }
        
        .empty-state-icon {
            font-size: 48px;
            margin-bottom: 16px;
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            margin-top: 20px;
            padding: 20px;
        }
        
        .error-message {
            background-color: #fef2f2;
            border: 1px solid #fecaca;
            color: #dc2626;
            padding: 12px 16px;
            border-radius: 6px;
            margin-bottom: 20px;
        }
        
        /* 가로 정렬 폼 스타일 */
        .horizontal-form {
            display: flex;
            flex-wrap: wrap;
            align-items: flex-end;
            gap: 15px;
        }
        
        .horizontal-form .form-group {
            display: flex;
            flex-direction: column;
            min-width: 120px;
        }
        
        .horizontal-form .form-group.button-group {
            min-width: auto;
        }
        
        .horizontal-form .form-group label {
            margin-bottom: 5px;
            font-size: 12px;
            font-weight: 500;
            color: #656d76;
        }
        
        .horizontal-form .form-control {
            padding: 8px 12px;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            font-size: 14px;
            min-width: 100px;
        }
        
        .horizontal-form .button-container {
            display: flex;
            gap: 8px;
        }
        
        /* 반응형 처리 */
        @media (max-width: 768px) {
            .horizontal-form {
                flex-direction: column;
                align-items: stretch;
            }
            
            .horizontal-form .form-group {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h1>📊 로그 관리</h1>
            <div class="nav-links">
                <a href="admin/dashboard">관리자 대시보드</a>
                <a href="admin/users">사용자 관리</a>
                <a href="main.jsp">메인 페이지</a>
                <a href="logout">로그아웃</a>
            </div>
        </div>

        <div class="main-dashboard">
            <div class="dashboard-header">
                <h2>📋 시스템 활동 로그</h2>
                <div>
                    <span style="color: #656d76; font-size: 14px;">
                        총 ${requestScope.logStats.totalLogs}건의 로그
                    </span>
                </div>
            </div>

            <div class="dashboard-content">
                <!-- 오류 메시지 표시 -->
                <c:if test="${not empty requestScope.error}">
                    <div class="error-message">
                        ${requestScope.error}
                    </div>
                </c:if>

                <!-- 통계 정보 -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-number">${requestScope.logStats.totalLogs}</div>
                        <div class="stat-label">전체 로그</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${requestScope.logStats.todayLogs}</div>
                        <div class="stat-label">오늘 로그</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${requestScope.logStats.recentLogins}</div>
                        <div class="stat-label">최근 로그인</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${requestScope.actionCounts.size()}</div>
                        <div class="stat-label">액션 유형</div>
                    </div>
                </div>

                <!-- 검색 패널 -->
                <div class="search-panel">
                    <form method="GET" action="admin/logs" class="search-form horizontal-form">
                        <div class="form-group">
                            <label for="searchType">검색 유형</label>
                            <select name="searchType" id="searchType" class="form-control">
                                <option value="" ${empty param.searchType ? 'selected' : ''}>전체 로그</option>
                                <option value="username" ${param.searchType == 'username' ? 'selected' : ''}>사용자별</option>
                                <option value="today" ${param.searchType == 'today' ? 'selected' : ''}>오늘 로그</option>
                                <option value="login" ${param.searchType == 'login' ? 'selected' : ''}>로그인 로그</option>
                            </select>
                        </div>
                        
                        <div class="form-group" id="searchValueGroup" style="${param.searchType == 'username' ? 'display: flex' : 'display: none'}; flex-direction: column;">
                            <label for="searchValue">사용자명</label>
                            <input type="text" name="searchValue" id="searchValue" 
                                   value="${param.searchValue}" placeholder="사용자명 입력" class="form-control">
                        </div>
                        
                        <div class="form-group">
                            <label for="limit">표시 개수</label>
                            <select name="limit" id="limit" class="form-control">
                                <option value="10" ${param.limit == '10' ? 'selected' : ''}>10개</option>
                                <option value="50" ${empty param.limit or param.limit == '50' ? 'selected' : ''}>50개</option>
                                <option value="100" ${param.limit == '100' ? 'selected' : ''}>100개</option>
                                <option value="500" ${param.limit == '500' ? 'selected' : ''}>500개</option>
                            </select>
                        </div>
                        
                        <div class="form-group button-group">
                            <label>&nbsp;</label> <!-- 높이 맞춤용 빈 라벨 -->
                            <div class="button-container">
                                <button type="submit" class="btn btn-primary">🔍 검색</button>
                                <a href="admin/logs" class="btn btn-secondary">🔄 초기화</a>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- 로그 테이블 -->
                <c:choose>
                    <c:when test="${not empty requestScope.activities}">
                        <table class="logs-table">
                            <thead>
                                <tr>
                                    <th>시간</th>
                                    <th>사용자</th>
                                    <th>액션</th>
                                    <th>대상</th>
                                    <th>설명</th>
                                    <th>IP 주소</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="activity" items="${requestScope.activities}">
                                    <tr>
                                        <td>
                                            <fmt:formatDate value="${activity.createdAt}" 
                                                          pattern="MM-dd HH:mm:ss" />
                                        </td>
                                        <td><strong>${activity.username}</strong></td>
                                        <td>
                                            <span class="action-badge action-${activity.action}">
                                                ${activity.action}
                                            </span>
                                        </td>
                                        <td>
                                            <c:if test="${not empty activity.targetType}">
                                                ${activity.targetType}
                                                <c:if test="${not empty activity.targetId}">
                                                    #${activity.targetId}
                                                </c:if>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty activity.targetName}">
                                                    ${activity.targetName}
                                                </c:when>
                                                <c:otherwise>
                                                    ${activity.description}
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <code style="font-size: 12px; color: #656d76;">
                                                ${activity.ipAddress}
                                            </code>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                        
                        <div class="pagination">
                            <span style="color: #656d76; font-size: 14px;">
                                ${requestScope.activities.size()}건의 로그를 표시 중
                            </span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state">
                            <div class="empty-state-icon">📝</div>
                            <h3>로그가 없습니다</h3>
                            <p>검색 조건을 변경하거나 전체 로그를 확인해보세요.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <script>
        // 검색 유형 변경 시 사용자명 입력 필드 표시/숨김
        document.getElementById('searchType').addEventListener('change', function() {
            const searchValueGroup = document.getElementById('searchValueGroup');
            if (this.value === 'username') {
                searchValueGroup.style.display = 'flex';
                searchValueGroup.style.flexDirection = 'column';
                document.getElementById('searchValue').required = true;
            } else {
                searchValueGroup.style.display = 'none';
                document.getElementById('searchValue').required = false;
                document.getElementById('searchValue').value = '';
            }
        });

        // 페이지 로드 시 검색 유형에 따른 필드 표시
        document.addEventListener('DOMContentLoaded', function() {
            const searchType = document.getElementById('searchType').value;
            const searchValueGroup = document.getElementById('searchValueGroup');
            
            if (searchType === 'username') {
                searchValueGroup.style.display = 'flex';
                searchValueGroup.style.flexDirection = 'column';
                document.getElementById('searchValue').required = true;
            } else {
                searchValueGroup.style.display = 'none';
                document.getElementById('searchValue').required = false;
            }
        });

        // 테이블 행 클릭 시 상세 정보 토글
        document.querySelectorAll('.logs-table tbody tr').forEach(row => {
            row.addEventListener('click', function() {
                // 행 하이라이트 토글
                this.style.backgroundColor = this.style.backgroundColor ? '' : '#f0f8ff';
            });
        });

        console.log('📊 로그 관리 페이지 로드 완료');
    </script>
</body>
</html> 