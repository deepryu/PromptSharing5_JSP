<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // 세션 검증
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>인터뷰 결과 관리 - 채용 관리 시스템</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            background: #f0f0f0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
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
        
        .nav-buttons {
            display: flex;
            gap: 8px;
        }
        
        .btn {
            padding: 6px 12px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            background: white;
            color: #24292f;
            cursor: pointer;
            font-size: 0.85rem;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s;
        }
        
        .btn:hover {
            background: #f6f8fa;
            border-color: #8c959f;
        }
        
        .btn-primary {
            background: #2da44e;
            color: white;
            border-color: #2da44e;
        }
        
        .btn-primary:hover {
            background: #2c974b;
            border-color: #2c974b;
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
            border-color: #6c757d;
        }
        
        .btn-secondary:hover {
            background: #5c636a;
            border-color: #5c636a;
        }
        
        .btn-success {
            background: #2da44e;
            color: white;
            border-color: #2da44e;
        }
        
        .btn-success:hover {
            background: #2c974b;
            border-color: #2c974b;
        }
        
        .btn-warning {
            background: #fb8500;
            color: white;
            border-color: #fb8500;
        }
        
        .btn-warning:hover {
            background: #e07600;
            border-color: #e07600;
        }
        
        .btn-danger {
            background: #cf222e;
            color: white;
            border-color: #cf222e;
        }
        
        .btn-danger:hover {
            background: #b91c28;
            border-color: #b91c28;
        }
        
        .btn-sm {
            padding: 4px 8px;
            font-size: 0.75rem;
        }
        
        .main-content {
            background: white;
            border: 1px solid #d0d7de;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .content-header {
            background: #0078d4;
            color: white;
            padding: 15px 25px;
            border-bottom: 1px solid #106ebe;
        }
        
        .content-header h1 {
            margin: 0;
            font-size: 1.3rem;
            font-weight: 600;
        }
        
        .content-body {
            padding: 20px;
        }
        
        .stats-bar {
            display: flex;
            background: #f6f8fa;
            border: 1px solid #d0d7de;
            margin-bottom: 20px;
            border-radius: 3px;
        }
        
        .stat-item {
            flex: 1;
            padding: 12px 20px;
            text-align: center;
            border-right: 1px solid #d0d7de;
        }
        
        .stat-item:last-child {
            border-right: none;
        }
        
        .stat-number {
            font-size: 1.2em;
            font-weight: 600;
            color: #0969da;
            margin-bottom: 3px;
        }
        
        .stat-label {
            color: #656d76;
            font-size: 0.85rem;
        }
        
        .controls-section {
            background: #f6f8fa;
            border: 1px solid #d0d7de;
            padding: 15px 20px;
            margin-bottom: 20px;
            border-radius: 3px;
        }
        
        .controls-grid {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
        }
        
        .controls-left {
            display: flex;
            gap: 15px;
            align-items: center;
            flex: 1;
        }
        
        .controls-right {
            display: flex;
            gap: 15px;
            align-items: center;
            flex-shrink: 0;
        }
        
        .search-input {
            flex: 0 0 300px;
            padding: 6px 12px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            font-size: 0.85rem;
            background: white;
            width: 300px;
        }
        
        .search-input:focus {
            border-color: #0969da;
            outline: none;
            box-shadow: 0 0 0 2px rgba(9, 105, 218, 0.3);
        }
        
        .filter-select {
            padding: 6px 12px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            font-size: 0.85rem;
            background: white;
            flex-shrink: 0;
        }
        
        .filter-select:focus {
            border-color: #0969da;
            outline: none;
            box-shadow: 0 0 0 2px rgba(9, 105, 218, 0.3);
        }
        
        .results-table-container {
            background: white;
            border: 1px solid #d0d7de;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .table {
            width: 100%;
            border-collapse: collapse;
            margin: 0;
            background: white;
        }
        
        .table th {
            text-align: center;
            background: #f6f8fa;
            border-bottom: 2px solid #d0d7de;
            border-right: 1px solid #d0d7de;
            padding: 12px 8px;
            font-weight: 600;
            color: #24292f;
            font-size: 0.9rem;
            white-space: nowrap;
        }
        
        .table th:last-child {
            border-right: none;
        }
        
        .table td {
            vertical-align: middle;
            border-bottom: 1px solid #eaeef2;
            border-right: 1px solid #eaeef2;
            padding: 10px 8px;
            font-size: 0.9rem;
            text-align: center;
        }
        
        .table td:last-child {
            border-right: none;
        }
        
        /* 컬럼별 정렬 및 스타일 설정 */
        .table th:nth-child(1), 
        .table td:nth-child(1) { /* 지원자 */
            text-align: left;
            font-weight: 600;
            color: #24292f;
        }
        
        .table th:nth-child(2), 
        .table td:nth-child(2) { /* 면접관 */
            text-align: left;
            color: #24292f;
        }
        
        .table th:nth-child(3), 
        .table td:nth-child(3) { /* 면접일 */
            text-align: center;
            font-family: 'Courier New', monospace;
        }
        
        .table th:nth-child(4), 
        .table td:nth-child(4) { /* 유형 */
            text-align: center;
        }
        
        .table th:nth-child(5), 
        .table td:nth-child(5) { /* 전체점수 */
            text-align: center;
        }
        
        .table th:nth-child(6), 
        .table td:nth-child(6) { /* 상태 */
            text-align: center;
        }
        
        .table th:nth-child(7), 
        .table td:nth-child(7) { /* 추천여부 */
            text-align: center;
        }
        
        .table th:nth-child(8), 
        .table td:nth-child(8) { /* 등록일 */
            text-align: center;
            font-family: 'Courier New', monospace;
            font-size: 0.85rem;
        }
        
        .table th:nth-child(9), 
        .table td:nth-child(9) { /* 관리 */
            text-align: center;
        }
        
        /* 스트라이프 테이블 스타일 */
        .table tbody tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        
        .table tbody tr:nth-child(odd) {
            background-color: white;
        }
        
        .table tbody tr:hover {
            background-color: #e6f3ff !important;
            transform: scale(1.01);
            transition: all 0.2s ease;
        }
        
        .table tbody tr:last-child td {
            border-bottom: none;
        }
        
        .candidate-link {
            color: #0969da;
            text-decoration: none;
            font-weight: 500;
        }
        
        .candidate-link:hover {
            text-decoration: underline;
        }
        
        .status-badge {
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: 500;
            border: 1px solid;
        }
        
        .status-pending {
            background: #fff8e1;
            color: #f57c00;
            border-color: #ffcc02;
        }
        
        .status-pass {
            background: #dcfce7;
            color: #16a34a;
            border-color: #86efac;
        }
        
        .status-fail {
            background: #fecaca;
            color: #dc2626;
            border-color: #fca5a5;
        }
        
        .status-hold {
            background: #e0f2fe;
            color: #0288d1;
            border-color: #81d4fa;
        }
        
        .recommendation-badge {
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: 500;
            border: 1px solid;
        }
        
        .recommendation-yes {
            background: #dcfce7;
            color: #16a34a;
            border-color: #86efac;
        }
        
        .recommendation-no {
            background: #fecaca;
            color: #dc2626;
            border-color: #fca5a5;
        }
        
        .type-badge {
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: 500;
            background: #f6f8fa;
            color: #656d76;
            border: 1px solid #d0d7de;
        }
        
        .score-stars {
            color: #ffc107;
            font-size: 0.9rem;
        }
        
        .action-buttons {
            display: flex;
            gap: 4px;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .action-buttons .btn {
            padding: 4px 8px;
            font-size: 0.8rem;
            white-space: nowrap;
        }
        
        .action-links {
            display: flex;
            gap: 4px;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .action-link {
            color: #0969da;
            text-decoration: none;
            font-size: 0.8rem;
            padding: 4px 8px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            background: white;
            transition: all 0.2s;
            white-space: nowrap;
        }
        
        .action-link:hover {
            background: #f6f8fa;
            border-color: #8c959f;
            text-decoration: none;
        }
        
        .action-link.delete {
            color: #cf222e;
            border-color: #cf222e;
        }
        
        .action-link.delete:hover {
            background: #fdf2f2;
            border-color: #cf222e;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #656d76;
        }
        
        .empty-state h3 {
            color: #24292f;
            margin-bottom: 10px;
        }
        
        .alert {
            padding: 12px 16px;
            border-radius: 3px;
            margin-bottom: 20px;
            border: 1px solid;
        }
        
        .alert-success {
            background: #dcfce7;
            color: #16a34a;
            border-color: #86efac;
        }
        
        /* 반응형 테이블 */
        @media (max-width: 768px) {
            .table {
                font-size: 0.8rem;
            }
            
            .action-links .action-link {
                padding: 3px 6px;
                font-size: 0.75rem;
            }
            
            .controls-grid {
                flex-direction: column;
                align-items: stretch;
                gap: 10px;
            }
            
            .controls-left,
            .controls-right {
                justify-content: center;
                flex-wrap: wrap;
            }
            
            .search-input {
                width: 100%;
                flex: 1 1 auto;
                margin-bottom: 10px;
            }
            
            .filter-select {
                margin-bottom: 10px;
            }
            
            .btn {
                margin-bottom: 5px;
            }
        }
        
        .alert-error {
            background: #fecaca;
            color: #dc2626;
            border-color: #fca5a5;
        }
        
        .alert-info {
            background: #dbeafe;
            color: #1e40af;
            border-color: #93c5fd;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h2>📝 인터뷰 결과 기록/관리</h2>
            <div class="nav-buttons">
                <a href="main.jsp" class="btn">🏠 메인</a>
                <a href="candidates" class="btn">👥 인터뷰 대상자 관리</a>
                <a href="interview/list" class="btn">📅 인터뷰 일정 관리</a>
                <a href="questions" class="btn">💡 질문/평가 항목 관리</a>
                <a href="statistics" class="btn">📊 통계 및 리포트</a>
                <a href="logout" class="btn btn-danger">🚪 로그아웃</a>
            </div>
        </div>
        
        <!-- 알림 메시지 -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success">${successMessage}</div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error">${errorMessage}</div>
        </c:if>
        
        <div class="main-content">
            <div class="content-header">
                <h1 style="text-align: center;">📝 인터뷰 결과 목록</h1>
            </div>
            <div class="content-body">
                <!-- 통계 바 -->
                <div class="stats-bar">
                    <div class="stat-item">
                        <div class="stat-number">${totalResults}</div>
                        <div class="stat-label">전체 결과</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">${pendingCount}</div>
                        <div class="stat-label">검토중</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">${passCount}</div>
                        <div class="stat-label">합격</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">${failCount}</div>
                        <div class="stat-label">불합격</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">${holdCount}</div>
                        <div class="stat-label">보류</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">
                            <c:choose>
                                <c:when test="${averageScore != null}">
                                    <fmt:formatNumber value="${averageScore}" pattern="0.00"/>
                                </c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="stat-label">평균 점수</div>
                    </div>
                </div>

                <!-- 컨트롤 섹션 -->
                <div class="controls-section">
                    <div class="controls-grid">
                        <div class="controls-left">
                            <input type="text" id="searchKeyword" placeholder="지원자명, 면접관명으로 검색..." 
                                   value="${searchKeyword}" class="search-input">
                            <button type="button" class="btn btn-primary" onclick="searchResults()">🔍 검색</button>
                            <select id="statusFilter" onchange="filterResults()" class="filter-select">
                                <option value="all" ${filterStatus == 'all' || filterStatus == null ? 'selected' : ''}>전체 상태</option>
                                <option value="pending" ${filterStatus == 'pending' ? 'selected' : ''}>검토중</option>
                                <option value="pass" ${filterStatus == 'pass' ? 'selected' : ''}>합격</option>
                                <option value="fail" ${filterStatus == 'fail' ? 'selected' : ''}>불합격</option>
                                <option value="hold" ${filterStatus == 'hold' ? 'selected' : ''}>보류</option>
                            </select>
                            <a href="results" class="btn btn-secondary">🔄 초기화</a>
                        </div>
                        <div class="controls-right">
                            <a href="results?action=new" class="btn btn-primary">➕ 새 결과 등록</a>
                        </div>
                    </div>
                </div>

                <!-- 결과 정보 -->
                <c:if test="${searchKeyword != null}">
                    <div class="alert alert-info">
                        '<strong>${searchKeyword}</strong>' 검색 결과: ${searchResultCount}개
                    </div>
                </c:if>
                
                <c:if test="${filterResultCount != null}">
                    <div class="alert alert-info">
                        필터 결과: ${filterResultCount}개
                        <c:if test="${filterStatus != null && filterStatus != 'all'}"> (상태: ${filterStatus})</c:if>
                    </div>
                </c:if>

                <!-- 결과 테이블 -->
                <div class="results-table-container">
                    <c:choose>
                        <c:when test="${empty results}">
                            <div class="empty-state">
                                <h3>📋 등록된 인터뷰 결과가 없습니다</h3>
                                <p>새로운 인터뷰 결과를 등록해보세요!</p>
                                <a href="results?action=new" class="btn btn-primary">➕ 첫 번째 결과 등록하기</a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>지원자</th>
                                        <th>면접관</th>
                                        <th>면접일</th>
                                        <th>유형</th>
                                        <th>전체점수</th>
                                        <th>상태</th>
                                        <th>추천여부</th>
                                        <th>등록일</th>
                                        <th>관리</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="result" items="${results}">
                                        <tr>
                                            <td>
                                                <a href="candidates?action=detail&id=${result.candidateId}" class="candidate-link">
                                                    ${result.candidateName}
                                                </a>
                                            </td>
                                            <td>${result.interviewerName}</td>
                                            <td>${result.interviewDateFormatted}</td>
                                            <td>
                                                <span class="type-badge">${result.interviewType}</span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${result.overallScore != null}">
                                                        <div class="score-stars">${result.overallScoreStars}</div>
                                                        <div style="font-size: 12px; color: #666;">
                                                            ${result.overallScoreFormatted}점
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color: #656d76;">미평가</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <span class="status-badge ${result.resultStatusClass}">
                                                    ${result.resultStatusDisplayName}
                                                </span>
                                            </td>
                                            <td>
                                                <span class="recommendation-badge ${result.hireRecommendationClass}">
                                                    ${result.hireRecommendationDisplayName}
                                                </span>
                                            </td>
                                            <td>
                                                <div>${result.formattedCreatedAt}</div>
                                            </td>
                                            <td>
                                                <div class="action-links">
                                                    <a href="results?action=detail&id=${result.id}" class="action-link">상세</a>
                                                    <a href="results?action=edit&id=${result.id}" class="action-link">수정</a>
                                                    <a href="results?action=delete&id=${result.id}" 
                                                       class="action-link delete"
                                                       onclick="return confirm('정말 삭제하시겠습니까?');">삭제</a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
    
    <script>
    function searchResults() {
        const keyword = document.getElementById('searchKeyword').value;
        if (keyword.trim()) {
            location.href = 'results?action=search&keyword=' + encodeURIComponent(keyword);
        } else {
            location.href = 'results';
        }
    }
    
    function filterResults() {
        const status = document.getElementById('statusFilter').value;
        if (status && status !== 'all') {
            location.href = 'results?action=filter&status=' + status;
        } else {
            location.href = 'results';
        }
    }
    
    // Enter 키 검색 기능
    document.getElementById('searchKeyword').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            searchResults();
        }
    });
    </script>
</body>
</html>
