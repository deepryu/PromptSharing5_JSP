<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String username = (String)session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%><%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
    <title>인터뷰 일정 관리 - 채용 관리 시스템</title>
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
        
        .btn-danger {
            background: #da3633;
            color: white;
            border-color: #da3633;
        }
        
        .btn-danger:hover {
            background: #cf222e;
            border-color: #cf222e;
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
            display: flex;
            justify-content: space-between;
            align-items: center;
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
            padding: 6px 10px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            font-size: 0.85rem;
            background: white;
            color: #24292f;
        }
        
        .view-controls {
            display: flex;
            gap: 8px;
            align-items: center;
        }
        
        .view-btn {
            padding: 6px 12px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            background: white;
            color: #24292f;
            text-decoration: none;
            font-size: 0.85rem;
            transition: all 0.2s;
        }
        
        .view-btn:hover {
            background: #f6f8fa;
            border-color: #8c959f;
        }
        
        .view-btn.active {
            background: #0969da;
            color: white;
            border-color: #0969da;
        }
        
        .schedule-table-container {
            background: white;
            border: 1px solid #d0d7de;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .table th,
        .table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #d0d7de;
            font-size: 0.85rem;
        }
        
        .table th {
            background: #f6f8fa;
            font-weight: 600;
            color: #24292f;
        }
        
        .table tr:hover {
            background: #f6f8fa;
        }
        
        .status-badge {
            padding: 2px 8px;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: 500;
            text-transform: uppercase;
        }
        
        .status-scheduled {
            background: #dbeafe;
            color: #1e40af;
        }
        
        .status-completed {
            background: #dcfce7;
            color: #166534;
        }
        
        .status-cancelled {
            background: #fee2e2;
            color: #dc2626;
        }
        
        .actions {
            display: flex;
            gap: 5px;
        }
        
        .btn-sm {
            padding: 4px 8px;
            font-size: 0.75rem;
        }
        
        .no-data {
            text-align: center;
            padding: 40px 20px;
            color: #656d76;
            font-style: italic;
        }
        
        .alert {
            padding: 12px 15px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 3px;
        }
        
        .alert-success {
            color: #0f5132;
            background-color: #d1e7dd;
            border-color: #badbcc;
        }
        
        .alert-danger {
            color: #842029;
            background-color: #f8d7da;
            border-color: #f5c2c7;
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 5px;
            margin-top: 20px;
            padding: 15px;
        }
        
        .pagination a,
        .pagination span {
            padding: 6px 12px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            text-decoration: none;
            color: #24292f;
            font-size: 0.85rem;
        }
        
        .pagination a:hover {
            background: #f6f8fa;
            border-color: #8c959f;
        }
        
        .pagination .current {
            background: #0969da;
            color: white;
            border-color: #0969da;
        }
        
        .date-filter {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .date-filter label {
            font-size: 0.85rem;
            color: #24292f;
            font-weight: 500;
        }
        
        .quick-filters {
            display: flex;
            gap: 5px;
        }
        
        .quick-filter {
            padding: 4px 8px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            background: white;
            color: #24292f;
            text-decoration: none;
            font-size: 0.75rem;
            transition: all 0.2s;
        }
        
        .quick-filter:hover,
        .quick-filter.active {
            background: #f6f8fa;
            border-color: #8c959f;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Top Bar -->
        <div class="top-bar">
            <h2>인터뷰 일정 관리</h2>
            <div class="nav-buttons">
                <a href="main.jsp" class="btn">메인으로</a>
                <a href="logout" class="btn">로그아웃</a>
            </div>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <div class="content-header">
                <h1>📅 인터뷰 일정 관리</h1>
            </div>
            <div class="content-body">
                <!-- Success/Error Messages -->
                <c:if test="${not empty param.success}">
                    <div class="alert alert-success">
                        <c:choose>
                            <c:when test="${param.success == 'added'}">인터뷰 일정이 성공적으로 등록되었습니다.</c:when>
                            <c:when test="${param.success == 'updated'}">인터뷰 일정이 성공적으로 수정되었습니다.</c:when>
                            <c:when test="${param.success == 'deleted'}">인터뷰 일정이 성공적으로 삭제되었습니다.</c:when>
                        </c:choose>
                    </div>
                </c:if>
                
                <c:if test="${not empty param.error}">
                    <div class="alert alert-danger">
                        <c:choose>
                            <c:when test="${param.error == 'conflict'}">선택한 시간에 이미 다른 인터뷰 일정이 있습니다.</c:when>
                            <c:when test="${param.error == 'notfound'}">요청한 인터뷰 일정을 찾을 수 없습니다.</c:when>
                            <c:otherwise>처리 중 오류가 발생했습니다.</c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

                <!-- Statistics Bar -->
                <div class="stats-bar">
                    <div class="stat-item">
                        <div class="stat-number">${totalSchedules}</div>
                        <div class="stat-label">전체 일정</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">${todaySchedules}</div>
                        <div class="stat-label">오늘 일정</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">${upcomingSchedules}</div>
                        <div class="stat-label">예정 일정</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">${completedSchedules}</div>
                        <div class="stat-label">완료 일정</div>
                    </div>
                </div>

                <!-- Controls Section -->
                <div class="controls-section">
                    <div class="filter-controls">
                        <div class="date-filter">
                            <label>기간:</label>
                            <input type="date" id="startDate" name="startDate" value="${param.startDate}">
                            <span>~</span>
                            <input type="date" id="endDate" name="endDate" value="${param.endDate}">
                        </div>
                        
                        <select id="statusFilter" name="status">
                            <option value="">전체 상태</option>
                            <option value="scheduled" ${param.status == 'scheduled' ? 'selected' : ''}>예정</option>
                            <option value="completed" ${param.status == 'completed' ? 'selected' : ''}>완료</option>
                            <option value="cancelled" ${param.status == 'cancelled' ? 'selected' : ''}>취소</option>
                        </select>
                        
                        <button type="button" class="btn" onclick="applyFilters()">필터 적용</button>
                        <button type="button" class="btn" onclick="resetFilters()">초기화</button>
                    </div>
                    
                    <div class="view-controls">
                        <div class="quick-filters">
                            <a href="${pageContext.request.contextPath}/interview/list?filter=today" class="quick-filter ${param.filter == 'today' ? 'active' : ''}">오늘</a>
                            <a href="${pageContext.request.contextPath}/interview/list?filter=week" class="quick-filter ${param.filter == 'week' ? 'active' : ''}">이번주</a>
                            <a href="${pageContext.request.contextPath}/interview/list?filter=month" class="quick-filter ${param.filter == 'month' ? 'active' : ''}">이번달</a>
                        </div>
                        <a href="${pageContext.request.contextPath}/interview/calendar" class="view-btn">📅 캘린더 보기</a>
                        <a href="${pageContext.request.contextPath}/interview/add" class="btn btn-primary">새 일정 추가</a>
                    </div>
                </div>

                <!-- Schedule Table -->
                <div class="schedule-table-container">
                    <c:choose>
                        <c:when test="${not empty schedules}">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>일정 ID</th>
                                        <th>지원자</th>
                                        <th>면접관</th>
                                        <th>일시</th>
                                        <th>장소</th>
                                        <th>상태</th>
                                        <th>작업</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="schedule" items="${schedules}">
                                        <tr>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/interview/detail?id=${schedule.id}" style="color: #0969da; text-decoration: none;">
                                                    #${schedule.id}
                                                </a>
                                            </td>
                                            <td>
                                                <strong>${schedule.candidateName}</strong><br>
                                                <small style="color: #656d76;">${schedule.candidateEmail}</small>
                                            </td>
                                            <td>${schedule.interviewerName}</td>
                                            <td>
                                                <strong>${schedule.interviewDate}</strong><br>
                                                <small>${schedule.interviewTime}</small>
                                            </td>
                                            <td>${schedule.location}</td>
                                            <td>
                                                <span class="status-badge status-${schedule.status}">
                                                    <c:choose>
                                                        <c:when test="${schedule.status == 'scheduled'}">예정</c:when>
                                                        <c:when test="${schedule.status == 'completed'}">완료</c:when>
                                                        <c:when test="${schedule.status == 'cancelled'}">취소</c:when>
                                                        <c:otherwise>${schedule.status}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </td>
                                            <td>
                                                <div class="actions">
                                                    <a href="${pageContext.request.contextPath}/interview/detail?id=${schedule.id}" class="btn btn-sm">상세</a>
                                                    <a href="${pageContext.request.contextPath}/interview/edit?id=${schedule.id}" class="btn btn-sm">수정</a>
                                                    <c:if test="${schedule.status == 'scheduled'}">
                                                        <button type="button" class="btn btn-sm btn-danger" 
                                                                onclick="deleteSchedule(${schedule.id})">삭제</button>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>
                        <c:otherwise>
                            <div class="no-data">
                                <p>등록된 인터뷰 일정이 없습니다.</p>
                                <a href="interview/add" class="btn btn-primary">첫 번째 일정 등록하기</a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <div class="pagination">
                        <c:if test="${currentPage > 1}">
                            <a href="interview/list?page=${currentPage - 1}&${queryString}">이전</a>
                        </c:if>
                        
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <c:choose>
                                <c:when test="${i == currentPage}">
                                    <span class="current">${i}</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="interview/list?page=${i}&${queryString}">${i}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>
                        
                        <c:if test="${currentPage < totalPages}">
                            <a href="interview/list?page=${currentPage + 1}&${queryString}">다음</a>
                        </c:if>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <script>
        function applyFilters() {
            const startDate = document.getElementById('startDate').value;
            const endDate = document.getElementById('endDate').value;
            const status = document.getElementById('statusFilter').value;
            
            let url = 'interview/list?';
            const params = [];
            
            if (startDate) params.push('startDate=' + startDate);
            if (endDate) params.push('endDate=' + endDate);
            if (status) params.push('status=' + status);
            
            url += params.join('&');
            window.location.href = url;
        }
        
        function resetFilters() {
            window.location.href = 'interview/list';
        }
        
        function deleteSchedule(scheduleId) {
            if (confirm('정말로 이 인터뷰 일정을 삭제하시겠습니까?')) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'interview/delete';
                
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'id';
                input.value = scheduleId;
                
                form.appendChild(input);
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        // 오늘 날짜를 기본값으로 설정
        document.addEventListener('DOMContentLoaded', function() {
            const today = '${today}';
            if (!document.getElementById('startDate').value) {
                document.getElementById('startDate').value = today;
            }
        });
    </script>
</body>
</html> 
