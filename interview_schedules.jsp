<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.text.SimpleDateFormat, java.util.Date, com.example.model.InterviewResultDAO, com.example.model.InterviewResult" %>
<%
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
        .schedule-card {
            background: var(--bg-secondary);
            border: 1px solid var(--border-primary);
            border-radius: 3px;
            padding: var(--space-md);
            margin-bottom: var(--space-md);
            transition: box-shadow 0.2s;
        }
        
        .schedule-card:hover {
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .schedule-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--space-sm);
        }
        
        .schedule-time {
            font-weight: 600;
            color: var(--blue-primary);
            font-size: var(--font-lg);
        }
        
        .schedule-status {
            padding: var(--space-xs) var(--space-sm);
            border-radius: 3px;
            font-size: var(--font-xs);
            font-weight: 500;
        }
        
        .status-scheduled {
            background: #dcfce7;
            color: #16a34a;
        }
        
        .status-completed {
            background: #dbeafe;
            color: #2563eb;
        }
        
        .status-cancelled {
            background: #fecaca;
            color: #dc2626;
        }
        
        .candidate-info {
            margin-bottom: var(--space-sm);
        }
        
        .candidate-name {
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: var(--space-xs);
        }
        
        .candidate-position {
            color: var(--text-secondary);
            font-size: var(--font-sm);
        }
        
        .schedule-actions {
            display: flex;
            gap: var(--space-xs);
            flex-wrap: wrap;
        }
        
        .view-toggle {
            display: flex;
            gap: var(--space-sm);
            margin-bottom: var(--space-md);
        }
        
        .view-btn {
            padding: var(--space-sm) var(--space-md);
            border: 1px solid var(--border-primary);
            border-radius: 3px;
            background: var(--bg-secondary);
            color: var(--text-primary);
            text-decoration: none;
            font-size: var(--font-sm);
            transition: all 0.2s;
        }
        
        .view-btn.active {
            background: var(--blue-primary);
            color: white;
            border-color: var(--blue-primary);
        }
        
        .view-btn:hover {
            background: var(--bg-tertiary);
            border-color: var(--border-secondary);
        }
        
        .view-btn.active:hover {
            background: var(--blue-secondary);
        }
        
        @media (max-width: 767px) {
            .schedule-header {
                flex-direction: column;
                align-items: flex-start;
                gap: var(--space-sm);
            }
            
            .schedule-actions {
                width: 100%;
            }
            
            .schedule-actions .btn {
                flex: 1;
                justify-content: center;
                min-height: 44px;
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
                <h1>📅 인터뷰 일정 관리</h1>
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
                        <a href="interview/add" class="btn btn-primary">➕ 새 일정 추가</a>
                        <a href="interview/calendar" class="btn">📅 캘린더 보기</a>
                    </div>
                </div>
                
                <!-- 뷰 전환 버튼 -->
                <div class="view-toggle">
                    <a href="?view=list" class="view-btn ${empty param.view or param.view eq 'list' ? 'active' : ''}">📋 목록 보기</a>
                    <a href="?view=card" class="view-btn ${param.view eq 'card' ? 'active' : ''}">📇 카드 보기</a>
                </div>
                
                <!-- 일정 목록/카드 -->
                <c:choose>
                    <c:when test="${param.view eq 'card'}">
                        <!-- 카드 뷰 -->
                        <div class="schedules-container">
                            <c:choose>
                                <c:when test="${not empty schedules}">
                                    <c:forEach var="schedule" items="${schedules}">
                                        <div class="schedule-card" data-date="${schedule.interviewDate}" data-status="${schedule.status}">
                                            <div class="schedule-header">
                                                <div class="schedule-time">${schedule.interviewDate} ${schedule.interviewTime}</div>
                                                <div class="schedule-status status-${fn:toLowerCase(schedule.status)}">${schedule.status}</div>
                                            </div>
                                            <div class="candidate-info">
                                                <div class="candidate-name">${schedule.candidateName}</div>
                                                <div class="candidate-position">${schedule.candidatePosition}</div>
                                            </div>
                                            <div class="schedule-actions">
                                                <a href="interview/detail?id=${schedule.id}" class="btn">👁️ 보기</a>
                                                <a href="interview/edit?id=${schedule.id}" class="btn">✏️ 수정</a>
                                                <c:if test="${schedule.status eq 'SCHEDULED'}">
                                                    <a href="results/add?scheduleId=${schedule.id}" class="btn btn-primary">📝 결과 기록</a>
                                                </c:if>
                                                <a href="interview/delete?id=${schedule.id}" class="btn btn-danger" onclick="return confirm('정말 삭제하시겠습니까?')">🗑️ 삭제</a>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="alert alert-info">등록된 인터뷰 일정이 없습니다.</div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <!-- 테이블 뷰 -->
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
                                                        <span class="status-badge status-${fn:toLowerCase(schedule.status)}">${schedule.status}</span>
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
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

<script>
// 날짜별 필터링
function filterByDate() {
    const dateFilter = document.getElementById('dateFilter').value;
    const rows = document.querySelectorAll('#schedulesTable tbody tr, .schedule-card');
    
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
    const rows = document.querySelectorAll('#schedulesTable tbody tr, .schedule-card');
    
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
    const cards = document.querySelectorAll('.schedule-card');
    
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
    
    cards.forEach(card => {
        const candidateName = card.querySelector('.candidate-name').textContent.toLowerCase();
        if (candidateName.includes(searchInput)) {
            card.style.display = '';
        } else {
            card.style.display = 'none';
        }
    });
}

// 필터 초기화
function clearFilters() {
    document.getElementById('dateFilter').value = '';
    document.getElementById('statusFilter').value = '';
    document.getElementById('searchInput').value = '';
    
    const rows = document.querySelectorAll('#schedulesTable tbody tr, .schedule-card');
    rows.forEach(row => {
        row.style.display = '';
    });
}

// 모바일 테이블 변환
function toggleMobileTable() {
    const table = document.getElementById('schedulesTable');
    if (table && window.innerWidth <= 767) {
        table.classList.add('table-mobile-cards');
    } else if (table) {
        table.classList.remove('table-mobile-cards');
    }
}

// 페이지 로드 시와 창 크기 변경 시 실행
window.addEventListener('load', toggleMobileTable);
window.addEventListener('resize', toggleMobileTable);
</script>

</body>
</html> 
