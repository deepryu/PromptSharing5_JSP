<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.text.SimpleDateFormat, java.util.Date, com.example.model.InterviewResultDAO, com.example.model.InterviewResult" %>
<%
    // 세션에서 사용자 권한 정보 가져오기
    String username = (String)session.getAttribute("username");
    String userRole = (String)session.getAttribute("userRole");
    Boolean isInterviewer = (Boolean)session.getAttribute("isInterviewer");
    Boolean isAdmin = (Boolean)session.getAttribute("isAdmin");
    
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 인터뷰 일정 관리 권한 확인 (INTERVIEWER와 ADMIN 모두 가능)
    boolean canManageSchedules = (isInterviewer != null && isInterviewer) || 
                                (isAdmin != null && isAdmin) || 
                                ("INTERVIEWER".equals(userRole)) || 
                                ("ADMIN".equals(userRole));

    // 오늘 날짜 설정
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String today = sdf.format(new Date());
    request.setAttribute("today", today);

    InterviewResultDAO resultDAO = new InterviewResultDAO();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>인터뷰 일정 관리 - 채용 관리 시스템</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/common.css">
    <style>
        /* 인터뷰 일정 페이지 전용 스타일 */
        
        /* 상태 배지 스타일 - 테이블용 */
        .status-badge {
            padding: 4px 8px;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: 500;
            text-align: center;
            display: inline-block;
            min-width: 60px;
            line-height: 1.2;
        }
        
        /* 상태 배지별 색상 */
        .status-badge.status-scheduled {
            background: #dcfce7;
            color: #16a34a;
        }
        
        .status-badge.status-completed {
            background: #dbeafe;
            color: #2563eb;
        }
        
        .status-badge.status-cancelled {
            background: #fecaca;
            color: #dc2626;
        }
        
        .status-badge.status-postponed {
            background: #f3e8ff;
            color: #7c3aed;
        }
        
        /* 테이블 스타일 강화 */
        .table-container {
            background: white;
            border-radius: 3px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        /* 테이블 전체 정렬 개선 */
        #schedulesTable {
            width: 100%;
            border-collapse: collapse;
            margin: 0;
            background: white;
        }
        
        #schedulesTable th {
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
        
        #schedulesTable th:last-child {
            border-right: none;
        }
        
        #schedulesTable td {
            vertical-align: middle;
            border-bottom: 1px solid #eaeef2;
            border-right: 1px solid #eaeef2;
            padding: 10px 8px;
            font-size: 0.9rem;
        }
        
        #schedulesTable td:last-child {
            border-right: none;
        }
        
        /* 컬럼별 정렬 및 너비 설정 */
        #schedulesTable th:nth-child(1), 
        #schedulesTable td:nth-child(1) { /* ID */
            width: 60px;
            text-align: center;
            font-weight: 600;
            color: #0969da;
        }
        
        #schedulesTable th:nth-child(2), 
        #schedulesTable td:nth-child(2) { /* 지원자명 */
            width: 130px;
            text-align: left;
            font-weight: 600;
            color: #24292f;
        }
        
        #schedulesTable th:nth-child(3), 
        #schedulesTable td:nth-child(3) { /* 지원직무 */
            width: 130px;
            text-align: left;
            color: #656d76;
        }
        
        #schedulesTable th:nth-child(4), 
        #schedulesTable td:nth-child(4) { /* 면접일 */
            width: 110px;
            text-align: center;
            font-family: 'Courier New', monospace;
        }
        
        #schedulesTable th:nth-child(5), 
        #schedulesTable td:nth-child(5) { /* 면접시간 */
            width: 90px;
            text-align: center;
            font-family: 'Courier New', monospace;
        }
        
        #schedulesTable th:nth-child(6), 
        #schedulesTable td:nth-child(6) { /* 면접관 */
            width: 110px;
            text-align: center;
            color: #24292f;
        }
        
        #schedulesTable th:nth-child(7), 
        #schedulesTable td:nth-child(7) { /* 상태 */
            width: 100px;
            text-align: center;
        }
        
        #schedulesTable th:nth-child(8), 
        #schedulesTable td:nth-child(8) { /* 액션 */
            width: 220px;
            text-align: center;
        }
        
        /* 테이블 행 스타일 */
        #schedulesTable tbody tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        
        #schedulesTable tbody tr:nth-child(odd) {
            background-color: white;
        }
        
        #schedulesTable tbody tr:hover {
            background-color: #e6f3ff !important;
            transform: scale(1.01);
            transition: all 0.2s ease;
        }
        
        /* 액션 버튼 정렬 */
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
        
        /* 통계 카드 크기 축소 */
        .stats-bar {
            margin-bottom: 15px;
        }
        
        .stat-item {
            padding: 10px 15px;
            min-height: 60px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        .stat-number {
            font-size: 1.3rem;
            font-weight: 600;
            color: #0969da;
            margin-bottom: 3px;
        }
        
        .stat-label {
            color: #656d76;
            font-size: 0.8rem;
            margin: 0;
        }
        
        /* 반응형 테이블 */
        @media (max-width: 768px) {
            #schedulesTable {
                font-size: 0.8rem;
            }
            
            .action-buttons .btn {
                padding: 3px 6px;
                font-size: 0.75rem;
            }
            
            .stat-item {
                padding: 8px 12px;
                min-height: 50px;
            }
            
            .stat-number {
                font-size: 1.1rem;
            }
            
            .stat-label {
                font-size: 0.75rem;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h2>📊 채용 관리 시스템</h2>
            <div class="nav-buttons">
                <a href="main.jsp" class="btn">🏠 메인</a>
                <a href="candidates" class="btn">👥 인터뷰 대상자 관리</a>
                <a href="questions" class="btn">💡 질문/평가 항목 관리</a>
                <a href="results" class="btn">📝 인터뷰 결과 기록/관리</a>
                <a href="statistics" class="btn">📊 통계 및 리포트</a>
                <a href="logout" class="btn btn-danger">🚪 로그아웃</a>
            </div>
        </div>
        
        <div class="main-content">
            <div class="content-header">
                <h1 style="text-align: center;">📅 인터뷰 일정 관리</h1>
            </div>
            <div class="content-body">
                <!-- 통계 바 -->
                <div class="stats-bar">
                    <div class="stat-item">
                        <div class="stat-number">${fn:length(schedules)}</div>
                        <div class="stat-label">총 일정</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">
                            <c:set var="todayCount" value="0"/>
                            <c:forEach var="schedule" items="${schedules}">
                                <c:if test="${schedule.interviewDate eq today}">
                                    <c:set var="todayCount" value="${todayCount + 1}"/>
                                </c:if>
                            </c:forEach>
                            ${todayCount}
                        </div>
                        <div class="stat-label">오늘 면접</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">
                            <c:set var="scheduledCount" value="0"/>
                            <c:forEach var="schedule" items="${schedules}">
                                <c:if test="${schedule.status eq 'SCHEDULED'}">
                                    <c:set var="scheduledCount" value="${scheduledCount + 1}"/>
                                </c:if>
                            </c:forEach>
                            ${scheduledCount}
                        </div>
                        <div class="stat-label">예정된 면접</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">
                            <c:set var="completedCount" value="0"/>
                            <c:forEach var="schedule" items="${schedules}">
                                <c:if test="${schedule.status eq 'COMPLETED'}">
                                    <c:set var="completedCount" value="${completedCount + 1}"/>
                                </c:if>
                            </c:forEach>
                            ${completedCount}
                        </div>
                        <div class="stat-label">완료된 면접</div>
                    </div>
                </div>
                
                <!-- 컨트롤 섹션 -->
                <div class="controls-section">
                    <div class="filter-controls">
                        <input type="date" id="dateFilter" value="${today}" onchange="filterByDate()">
                        <select id="statusFilter" onchange="filterByStatus()">
                            <option value="">전체 상태</option>
                            <option value="SCHEDULED">예정</option>
                            <option value="COMPLETED">완료</option>
                            <option value="CANCELLED">취소</option>
                        </select>
                        <input type="text" id="searchInput" placeholder="지원자명으로 검색..." onkeyup="searchSchedules()">
                        <button type="button" class="btn" onclick="clearFilters()">🔄 초기화</button>
                    </div>
                    <div class="view-controls">
                        <a href="interview/add" class="btn btn-primary" onclick="return checkSchedulePermission()">➕ 새 일정 추가</a>
                        <a href="interview/calendar" class="btn">📅 캘린더 보기</a>
                    </div>
                </div>
                

                
                <!-- 일정 목록 테이블 -->
                <div class="table-container">
                    <table id="schedulesTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>지원자명</th>
                                <th>지원직무</th>
                                <th>면접일</th>
                                <th>면접시간</th>
                                <th>면접관</th>
                                <th>상태</th>
                                <th>액션</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty schedules}">
                                    <c:forEach var="schedule" items="${schedules}">
                                        <tr data-date="${schedule.interviewDate}" data-status="${schedule.status}">
                                            <td data-label="ID">${schedule.id}</td>
                                            <td data-label="지원자명">${schedule.candidateName}</td>
                                            <td data-label="지원직무">${schedule.candidatePosition}</td>
                                            <td data-label="면접일">${schedule.interviewDate}</td>
                                            <td data-label="면접시간">${schedule.interviewTime}</td>
                                            <td data-label="면접관">${schedule.interviewerName}</td>
                                                                        <td data-label="상태">
                                <c:set var="interviewType" value="${schedule.interviewType}" />
                                <c:set var="scheduleStatus" value="${schedule.status}" />
                                <c:set var="scheduleId" value="${schedule.id}" />
                                <%
                                    // 해당 일정의 면접결과 조회
                                    String resultStatus = "";
                                    try {
                                        Integer scheduleId = (Integer) pageContext.getAttribute("scheduleId");
                                        if (scheduleId != null) {
                                            com.example.model.InterviewResult result = resultDAO.getResultByScheduleId(scheduleId);
                                            if (result != null) {
                                                String status = result.getResultStatus(); // "pending", "pass", "fail", "hold"
                                                // 상태를 한글로 변환
                                                if ("pass".equals(status)) {
                                                    resultStatus = "합격";
                                                } else if ("fail".equals(status)) {
                                                    resultStatus = "불합격";
                                                } else if ("hold".equals(status)) {
                                                    resultStatus = "보류";
                                                } else if ("pending".equals(status)) {
                                                    resultStatus = "대기";
                                                } else {
                                                    resultStatus = status; // 원본 값 사용
                                                }
                                            }
                                        }
                                    } catch (Exception e) {
                                        // 결과가 없거나 오류 시 빈 문자열 유지
                                    }
                                    
                                    String interviewType = (String) pageContext.getAttribute("interviewType");
                                    String scheduleStatus = (String) pageContext.getAttribute("scheduleStatus");
                                    
                                    String combinedStatus = "";
                                    // 면접유형이 있으면 추가
                                    if (interviewType != null && !"-".equals(interviewType) && !interviewType.trim().isEmpty() && !"".equals(interviewType) && !"null".equals(interviewType)) {
                                        combinedStatus = interviewType;
                                    }
                                    
                                    // 면접결과가 있으면 추가
                                    if (resultStatus != null && !resultStatus.trim().isEmpty() && !"미등록".equals(resultStatus)) {
                                        if (!combinedStatus.isEmpty()) {
                                            combinedStatus += " / " + resultStatus;
                                        } else {
                                            combinedStatus = resultStatus;
                                        }
                                    }
                                    
                                    // 둘 다 없으면 기본 상태 표시
                                    if (combinedStatus.isEmpty()) {
                                        if ("SCHEDULED".equals(scheduleStatus)) {
                                            combinedStatus = "예정";
                                        } else if ("COMPLETED".equals(scheduleStatus)) {
                                            combinedStatus = "완료";
                                        } else if ("CANCELLED".equals(scheduleStatus)) {
                                            combinedStatus = "취소";
                                        } else {
                                            combinedStatus = scheduleStatus != null ? scheduleStatus : "미정";
                                        }
                                    }
                                    
                                    pageContext.setAttribute("combinedStatus", combinedStatus);
                                %>
                                <span class="status-badge 
                                    <% if (combinedStatus.contains("예정") || "SCHEDULED".equals(scheduleStatus)) { %>status-scheduled
                                    <% } else if (combinedStatus.contains("합격") || combinedStatus.contains("채용") || combinedStatus.contains("통과") || combinedStatus.contains("완료") || "COMPLETED".equals(scheduleStatus)) { %>status-completed
                                    <% } else if (combinedStatus.contains("불합격") || combinedStatus.contains("탈락") || combinedStatus.contains("취소") || "CANCELLED".equals(scheduleStatus)) { %>status-cancelled
                                    <% } else if (combinedStatus.contains("대기") || combinedStatus.contains("보류")) { %>status-postponed
                                    <% } else { %>status-scheduled<% } %>">
                                    <%= combinedStatus %>
                                </span>
                            </td>
                                            <td data-label="액션">
                                                <div class="action-buttons">
                                                    <a href="interview/detail?id=${schedule.id}" class="btn">👁️ 보기</a>
                                                    <a href="interview/edit?id=${schedule.id}" class="btn">✏️ 수정</a>
                                                    <c:if test="${schedule.status eq 'SCHEDULED'}">
                                                        <a href="results/add?scheduleId=${schedule.id}" class="btn btn-primary">📝 결과 기록</a>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="8" class="text-center">등록된 인터뷰 일정이 없습니다.</td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

<script>
// 날짜별 필터링
function filterByDate() {
    const dateFilter = document.getElementById('dateFilter').value;
    const rows = document.querySelectorAll('#schedulesTable tbody tr');
    
    rows.forEach(row => {
        const rowDate = row.getAttribute('data-date');
        if (!dateFilter || rowDate === dateFilter) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
}

// 상태별 필터링
function filterByStatus() {
    const statusFilter = document.getElementById('statusFilter').value;
    const rows = document.querySelectorAll('#schedulesTable tbody tr');
    
    rows.forEach(row => {
        const rowStatus = row.getAttribute('data-status');
        if (!statusFilter || rowStatus === statusFilter) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
}

// 검색 기능
function searchSchedules() {
    const searchInput = document.getElementById('searchInput').value.toLowerCase();
    const table = document.getElementById('schedulesTable');
    
    if (table) {
        const rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
        for (let i = 0; i < rows.length; i++) {
            const row = rows[i];
            const candidateName = row.cells[1] ? row.cells[1].textContent.toLowerCase() : '';
            
            if (candidateName.includes(searchInput)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        }
    }
}

// 필터 초기화
function clearFilters() {
    document.getElementById('dateFilter').value = '';
    document.getElementById('statusFilter').value = '';
    document.getElementById('searchInput').value = '';
    
    const rows = document.querySelectorAll('#schedulesTable tbody tr');
    rows.forEach(row => {
        row.style.display = '';
    });
}

// 인터뷰 일정 관리 권한 체크
function checkSchedulePermission() {
    const canManageSchedules = <%= canManageSchedules %>;
    
    if (!canManageSchedules) {
        alert('❌ 실행 권한이 없습니다\n\n인터뷰 일정 추가는 면접관(INTERVIEWER) 이상의 권한이 필요합니다.');
        return false; // 페이지 이동 막기
    }
    
    return true; // 페이지 이동 허용
}
</script>

</body>
</html> 
