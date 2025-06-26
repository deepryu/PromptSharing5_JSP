<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
    // 오늘 날짜 설정
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String today = sdf.format(new Date());
    request.setAttribute("today", today);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>인터뷰 일정 관리</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .table-container {
            width: 100%;
            overflow-x: auto;
            margin-top: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border-radius: 8px;
        }
        
        table {
            width: 100%;
            min-width: 1200px;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
        }
        
        table th, table td {
            padding: 12px 15px;
            text-align: center;
            border-bottom: 1px solid #eee;
        }
        
        table th {
            font-size: 1.1em;
            font-weight: 600;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-shadow: 0 1px 2px rgba(0,0,0,0.3);
            border: none;
            position: relative;
        }
        
        table th::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(45deg, rgba(255,255,255,0.1) 0%, transparent 50%);
            pointer-events: none;
        }
        
        table tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        
        table tr:hover {
            background-color: #e3f2fd;
            transition: background-color 0.3s ease;
        }
        
        /* 컬럼별 너비 조정 */
        table th:nth-child(1), table td:nth-child(1) { width: 12%; } /* 날짜/시간 */
        table th:nth-child(2), table td:nth-child(2) { width: 15%; } /* 지원자 */
        table th:nth-child(3), table td:nth-child(3) { width: 12%; } /* 면접관 */
        table th:nth-child(4), table td:nth-child(4) { width: 10%; } /* 유형 */
        table th:nth-child(5), table td:nth-child(5) { width: 15%; } /* 장소 */
        table th:nth-child(6), table td:nth-child(6) { width: 10%; } /* 소요시간 */
        table th:nth-child(7), table td:nth-child(7) { width: 10%; } /* 상태 */
        table th:nth-child(8), table td:nth-child(8) { width: 16%; } /* 관리 */
        
        .schedule-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 15px;
        }
        
        .filter-controls {
            display: flex;
            gap: 10px;
            align-items: center;
            flex-wrap: wrap;
        }
        
        .filter-controls select,
        .filter-controls input {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
        }
        
        .view-buttons {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        /* 지원자 목록과 동일한 버튼 스타일 */
        button {
            padding: 8px 16px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s;
            margin-right: 10px;
            margin-bottom: 10px;
            min-width: 80px;
            text-align: center;
        }
        
        button:hover {
            background-color: #0056b3;
        }
        
        /* 네비게이션 버튼 컨테이너 */
        .nav-buttons {
            margin-bottom: 20px;
            text-align: center;
        }
        
        .nav-buttons .nav-home-btn {
            margin: 0 8px 10px 8px;
        }
        
        /* 네비게이션 홈 버튼 스타일 */
        .nav-home-btn {
            padding: 8px 16px;
            background-color: #007bff;
            color: white !important;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s;
            margin-right: 10px;
            margin-bottom: 10px;
            text-decoration: none;
            display: inline-block;
            min-width: 80px;
            text-align: center;
        }
        
        .nav-home-btn:hover {
            background-color: #0056b3;
            text-decoration: none;
        }
        
        /* 로그아웃 버튼 스타일 */
        .nav-logout-btn {
            background-color: #dc3545 !important;
        }
        
        .nav-logout-btn:hover {
            background-color: #c82333 !important;
        }
        
        .view-btn {
            padding: 8px 16px;
            background: #f8f9fa;
            border: 1px solid #ddd;
            border-radius: 6px;
            text-decoration: none;
            color: #333;
            font-size: 14px;
            transition: all 0.3s ease;
            min-width: 80px;
            text-align: center;
            display: inline-block;
        }
        
        .view-btn:hover {
            background: #e9ecef;
        }
        
        .view-btn.active {
            background: #007bff;
            color: white;
            border-color: #007bff;
        }
        
        .schedule-status {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            text-align: center;
            min-width: 60px;
            display: inline-block;
        }
        
        .status-scheduled { background: #e3f2fd; color: #1976d2; }
        .status-in_progress { background: #fff3e0; color: #f57c00; }
        .status-completed { background: #e8f5e8; color: #388e3c; }
        .status-cancelled { background: #ffebee; color: #d32f2f; }
        .status-postponed { background: #f3e5f5; color: #7b1fa2; }
        
        .interview-type {
            padding: 2px 6px;
            background: #f5f5f5;
            border-radius: 4px;
            font-size: 11px;
            color: #666;
        }
        
        .action-buttons {
            display: flex;
            gap: 5px;
            justify-content: center;
        }
        
        .action-buttons a {
            color: #007bff;
            text-decoration: none;
            transition: text-decoration 0.2s;
        }
        
        .action-buttons a:hover {
            text-decoration: underline;
        }
        
        .no-schedules {
            text-align: center;
            padding: 40px;
            color: #666;
            font-style: italic;
        }
        
        .no-schedules h3 {
            margin-bottom: 15px;
        }
        
        .no-schedules p {
            margin-bottom: 20px;
        }
        
        .schedule-summary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 20px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .summary-stats {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
        }
        
        .stat-item {
            text-align: center;
        }
        
        .stat-number {
            font-size: 24px;
            font-weight: bold;
            display: block;
        }
        
        .stat-label {
            font-size: 12px;
            opacity: 0.9;
        }
        
        @media (max-width: 768px) {
            .container {
                max-width: 100%;
                padding: 10px;
            }
            
            .schedule-header {
                flex-direction: column;
                align-items: stretch;
            }
            
            .filter-controls {
                justify-content: center;
                flex-wrap: wrap;
                gap: 8px;
            }
            
            .view-buttons {
                justify-content: center;
                margin-top: 10px;
            }
            
            .summary-stats {
                justify-content: center;
            }
            
            .table-container {
                margin-top: 15px;
                box-shadow: 0 1px 4px rgba(0,0,0,0.1);
            }
            
            table {
                min-width: 800px;
                font-size: 14px;
            }
            
            table th, table td {
                padding: 8px 6px;
            }
            
            /* 모바일에서 컬럼 너비 재조정 */
            table th:nth-child(1), table td:nth-child(1) { width: 15%; }
            table th:nth-child(2), table td:nth-child(2) { width: 18%; }
            table th:nth-child(3), table td:nth-child(3) { width: 12%; }
            table th:nth-child(4), table td:nth-child(4) { width: 8%; }
            table th:nth-child(5), table td:nth-child(5) { width: 12%; }
            table th:nth-child(6), table td:nth-child(6) { width: 8%; }
            table th:nth-child(7), table td:nth-child(7) { width: 9%; }
            table th:nth-child(8), table td:nth-child(8) { width: 18%; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>인터뷰 일정 관리</h1>
            <div class="nav-buttons">
                <a href="../main.jsp" class="nav-home-btn">홈으로 이동</a>
                <a href="../candidates" class="nav-home-btn">지원자 관리</a>
                <a href="../logout" class="nav-home-btn nav-logout-btn">로그아웃</a>
            </div>
        </div>

        <div class="schedule-summary">
            <div class="summary-stats">
                <div class="stat-item">
                    <span class="stat-number">${schedules.size()}</span>
                    <span class="stat-label">전체 일정</span>
                </div>
                <div class="stat-item">
                    <span class="stat-number">
                        <c:set var="todayCount" value="0"/>
                        <c:forEach var="schedule" items="${schedules}">
                            <c:if test="${schedule.interviewDateFormatted == today}">
                                <c:set var="todayCount" value="${todayCount + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${todayCount}
                    </span>
                    <span class="stat-label">오늘 일정</span>
                </div>
                <div class="stat-item">
                    <span class="stat-number">
                        <c:set var="scheduledCount" value="0"/>
                        <c:forEach var="schedule" items="${schedules}">
                            <c:if test="${schedule.status == 'scheduled' || schedule.status == '예정'}">
                                <c:set var="scheduledCount" value="${scheduledCount + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${scheduledCount}
                    </span>
                    <span class="stat-label">예정 일정</span>
                </div>
            </div>
        </div>

        <div class="schedule-header">
            <div class="filter-controls">
                <select id="statusFilter" onchange="filterByStatus()">
                    <option value="">전체 상태</option>
                    <option value="scheduled" ${selectedStatus == 'scheduled' ? 'selected' : ''}>예정</option>
                    <option value="in_progress" ${selectedStatus == 'in_progress' ? 'selected' : ''}>진행중</option>
                    <option value="completed" ${selectedStatus == 'completed' ? 'selected' : ''}>완료</option>
                    <option value="cancelled" ${selectedStatus == 'cancelled' ? 'selected' : ''}>취소</option>
                    <option value="postponed" ${selectedStatus == 'postponed' ? 'selected' : ''}>연기</option>
                </select>
                
                <input type="date" id="dateFilter" value="${selectedDate}" onchange="filterByDate()">
                
                <button onclick="clearFilters()">필터 초기화</button>
            </div>
            
            <div class="view-buttons">
                <a href="list" class="view-btn active">리스트</a>
                <a href="calendar" class="view-btn">캘린더</a>
                <a href="add"><button>새 일정 등록</button></a>
            </div>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>

        <c:choose>
            <c:when test="${empty schedules}">
                <div class="no-schedules">
                    <h3>등록된 인터뷰 일정이 없습니다</h3>
                    <p>새로운 인터뷰 일정을 등록해보세요.</p>
                    <a href="add"><button>첫 일정 등록하기</button></a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>날짜/시간</th>
                                <th>지원자</th>
                                <th>면접관</th>
                                <th>유형</th>
                                <th>장소</th>
                                <th>소요시간</th>
                                <th>상태</th>
                                <th>관리</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="schedule" items="${schedules}">
                                <tr>
                                    <td>
                                        <div style="font-weight: bold;">${schedule.interviewDateFormatted}</div>
                                        <div style="color: #666; font-size: 14px;">${schedule.interviewTimeFormatted}</div>
                                    </td>
                                    <td>
                                        <a href="../candidates?action=detail&id=${schedule.candidateId}" 
                                           style="color: #007bff; text-decoration: none;">
                                            ${schedule.candidateName}
                                        </a>
                                    </td>
                                    <td>${schedule.interviewerName}</td>
                                    <td>
                                        <span class="interview-type">${schedule.interviewType}</span>
                                    </td>
                                    <td>${schedule.location}</td>
                                    <td>${schedule.durationFormatted}</td>
                                    <td>
                                        <span class="schedule-status status-${schedule.status}">
                                            ${schedule.statusDisplayName}
                                        </span>
                                    </td>
                                    <td>
                                        <div class="action-buttons">
                                            <a href="detail?id=${schedule.id}">상세</a> |
                                            <a href="edit?id=${schedule.id}">수정</a> |
                                            <a href="delete?id=${schedule.id}" 
                                               onclick="return confirm('정말 삭제하시겠습니까?')">삭제</a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <script>
        function filterByStatus() {
            const status = document.getElementById('statusFilter').value;
            const currentDate = document.getElementById('dateFilter').value;
            let url = 'list';
            const params = new URLSearchParams();
            
            if (status) params.append('status', status);
            if (currentDate) params.append('date', currentDate);
            
            if (params.toString()) {
                url += '?' + params.toString();
            }
            
            window.location.href = url;
        }
        
        function filterByDate() {
            const date = document.getElementById('dateFilter').value;
            const currentStatus = document.getElementById('statusFilter').value;
            let url = 'list';
            const params = new URLSearchParams();
            
            if (date) params.append('date', date);
            if (currentStatus) params.append('status', currentStatus);
            
            if (params.toString()) {
                url += '?' + params.toString();
            }
            
            window.location.href = url;
        }
        
        function clearFilters() {
            window.location.href = 'list';
        }
        
        // 오늘 날짜 설정
        document.addEventListener('DOMContentLoaded', function() {
            const today = new Date().toISOString().split('T')[0];
            // 현재 날짜가 없으면 오늘 날짜로 설정
            const dateFilter = document.getElementById('dateFilter');
            if (!dateFilter.value) {
                dateFilter.value = today;
            }
        });
    </script>
</body>
</html> 