<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String username = (String)session.getAttribute("username");
    if (username == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%><%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>인터뷰 일정 캘린더 - 채용 관리 시스템</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .calendar-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .view-buttons {
            display: flex;
            gap: 10px;
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
        }
        
        .view-btn:hover {
            background: #e9ecef;
        }
        
        .view-btn.active {
            background: #007bff;
            color: white;
            border-color: #007bff;
        }
        
        .calendar-container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .calendar-nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .nav-button {
            background: none;
            border: none;
            color: white;
            font-size: 18px;
            cursor: pointer;
            padding: 8px 12px;
            border-radius: 6px;
            transition: background 0.3s ease;
        }
        
        .nav-button:hover {
            background: rgba(255,255,255,0.2);
        }
        
        .calendar-title {
            font-size: 20px;
            font-weight: bold;
        }
        
        .calendar-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
        }
        
        .calendar-header-cell {
            padding: 15px 10px;
            text-align: center;
            font-weight: bold;
            background: #f8f9fa;
            border-bottom: 1px solid #ddd;
            color: #666;
        }
        
        .calendar-cell {
            min-height: 120px;
            border-right: 1px solid #eee;
            border-bottom: 1px solid #eee;
            padding: 8px;
            position: relative;
            background: white;
            transition: background 0.3s ease;
        }
        
        .calendar-cell:hover {
            background: #f8f9fa;
        }
        
        .calendar-cell.other-month {
            background: #fafafa;
            color: #ccc;
        }
        
        .calendar-cell.today {
            background: #e3f2fd;
            border: 2px solid #2196f3;
        }
        
        .calendar-cell.has-schedules {
            background: #fff8e1;
        }
        
        .date-number {
            font-weight: bold;
            margin-bottom: 5px;
            font-size: 14px;
        }
        
        .schedule-item {
            background: #007bff;
            color: white;
            padding: 2px 6px;
            margin-bottom: 2px;
            border-radius: 3px;
            font-size: 11px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: block;
            text-decoration: none;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        
        .schedule-item:hover {
            background: #0056b3;
            transform: scale(1.02);
        }
        
        .schedule-item.type-기술면접 { background: #28a745; }
        .schedule-item.type-실무면접 { background: #17a2b8; }
        .schedule-item.type-임원면접 { background: #dc3545; }
        .schedule-item.type-인성면접 { background: #6f42c1; }
        .schedule-item.type-화상면접 { background: #fd7e14; }
        
        .schedule-item.status-completed { opacity: 0.6; }
        .schedule-item.status-cancelled { background: #6c757d; }
        
        .schedule-count {
            font-size: 10px;
            color: #666;
            text-align: center;
            margin-top: 3px;
        }
        
        .add-schedule-btn {
            position: absolute;
            top: 2px;
            right: 2px;
            width: 20px;
            height: 20px;
            background: #28a745;
            color: white;
            border: none;
            border-radius: 50%;
            font-size: 12px;
            cursor: pointer;
            opacity: 0;
            transition: opacity 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
        }
        
        .calendar-cell:hover .add-schedule-btn {
            opacity: 1;
        }
        
        .schedule-legend {
            display: flex;
            gap: 15px;
            margin-top: 20px;
            flex-wrap: wrap;
            justify-content: center;
        }
        
        .legend-item {
            display: flex;
            align-items: center;
            gap: 5px;
            font-size: 12px;
        }
        
        .legend-color {
            width: 12px;
            height: 12px;
            border-radius: 2px;
        }
        
        @media (max-width: 768px) {
            .calendar-grid {
                font-size: 12px;
            }
            
            .calendar-cell {
                min-height: 80px;
                padding: 4px;
            }
            
            .schedule-item {
                font-size: 10px;
                padding: 1px 3px;
            }
            
            .calendar-nav {
                padding: 15px;
            }
            
            .calendar-header {
                flex-direction: column;
                gap: 10px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>인터뷰 일정 관리</h1>
            <nav>
                <a href="../main.jsp">메인</a>
                <a href="../candidates">지원자관리</a>
                <a href="list" class="active">일정관리</a>
                <a href="../logout">로그아웃</a>
            </nav>
        </div>

        <div class="calendar-header">
            <h2>인터뷰 일정 캘린더</h2>
            <div class="view-buttons">
                <a href="list" class="view-btn">리스트</a>
                <a href="calendar" class="view-btn active">캘린더</a>
                <a href="add" class="btn btn-primary">새 일정 등록</a>
            </div>
        </div>

        <div class="calendar-container">
            <div class="calendar-nav">
                <button class="nav-button" onclick="previousMonth()">이전</button>
                <div class="calendar-title" id="currentMonth"></div>
                <button class="nav-button" onclick="nextMonth()">다음</button>
            </div>
            
            <div class="calendar-grid">
                <!-- 요일 헤더 -->
                <div class="calendar-header-cell">일</div>
                <div class="calendar-header-cell">월</div>
                <div class="calendar-header-cell">화</div>
                <div class="calendar-header-cell">수</div>
                <div class="calendar-header-cell">목</div>
                <div class="calendar-header-cell">금</div>
                <div class="calendar-header-cell">토</div>
                
                <!-- 캘린더 셀들 -->
                <div id="calendarCells"></div>
            </div>
        </div>

        <div class="schedule-legend">
            <div class="legend-item">
                <div class="legend-color" style="background: #28a745;"></div>
                <span>기술면접</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #17a2b8;"></div>
                <span>실무면접</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #dc3545;"></div>
                <span>임원면접</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #6f42c1;"></div>
                <span>인성면접</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #fd7e14;"></div>
                <span>화상면접</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #6c757d;"></div>
                <span>취소</span>
            </div>
        </div>
    </div>

    <script>
        // 일정 데이터
        const schedules = [
            <c:forEach var="schedule" items="${schedules}" varStatus="status">
            {
                id: ${schedule.id},
                candidateId: ${schedule.candidateId},
                candidateName: '${schedule.candidateName}',
                interviewerName: '${schedule.interviewerName}',
                date: '${schedule.interviewDateFormatted}',
                time: '${schedule.interviewTimeFormatted}',
                type: '${schedule.interviewType}',
                status: '${schedule.status}',
                location: '${schedule.location}',
                duration: ${schedule.duration}
            }<c:if test="${!status.last}">,</c:if>
            </c:forEach>
        ];

        let currentDate = new Date();
        
        function renderCalendar() {
            const year = currentDate.getFullYear();
            const month = currentDate.getMonth();
            
            // 현재 월 표시
            document.getElementById('currentMonth').textContent = 
                `${year}년 ${month + 1}월`;
            
            // 캘린더 셀들 초기화
            const cellsContainer = document.getElementById('calendarCells');
            cellsContainer.innerHTML = '';
            
            // 해당 월의 첫째 날과 마지막 날 계산
            const firstDay = new Date(year, month, 1);
            const lastDay = new Date(year, month + 1, 0);
            
            // 캘린더 시작일 계산 (월의 첫째 날을 기준으로 일요일로 맞춤)
            const startDate = new Date(firstDay);
            startDate.setDate(startDate.getDate() - firstDay.getDay());
            
            // 6일 * 7주 = 42셀 생성
            for (let i = 0; i < 42; i++) {
                const cellDate = new Date(startDate);
                cellDate.setDate(startDate.getDate() + i);
                
                const cell = createCalendarCell(cellDate, month);
                cellsContainer.appendChild(cell);
            }
        }
        
        function createCalendarCell(date, currentMonth) {
            const cell = document.createElement('div');
            cell.className = 'calendar-cell';
            
            const dateStr = date.toISOString().split('T')[0];
            const dayNumber = date.getDate();
            const isCurrentMonth = date.getMonth() === currentMonth;
            const isToday = dateStr === new Date().toISOString().split('T')[0];
            
            // 셀 클래스 추가
            if (!isCurrentMonth) {
                cell.classList.add('other-month');
            }
            if (isToday) {
                cell.classList.add('today');
            }
            
            // 해당 날짜의 일정 가져오기
            const daySchedules = schedules.filter(s => s.date === dateStr);
            
            if (daySchedules.length > 0) {
                cell.classList.add('has-schedules');
            }
            
            // 날짜 표시
            const dateElement = document.createElement('div');
            dateElement.className = 'date-number';
            dateElement.textContent = dayNumber;
            cell.appendChild(dateElement);
            
            // 일정 표시 (최대 3개까지만 표시)
            const maxDisplay = 3;
            daySchedules.slice(0, maxDisplay).forEach(schedule => {
                const scheduleElement = document.createElement('a');
                scheduleElement.className = 
                    `schedule-item type-${schedule.type} status-${schedule.status}`;
                scheduleElement.href = `detail?id=${schedule.id}`;
                scheduleElement.textContent = 
                    `${schedule.time} ${schedule.candidateName}`;
                scheduleElement.title = 
                    `${schedule.time} - ${schedule.candidateName} (${schedule.type})`;
                cell.appendChild(scheduleElement);
            });
            
            // 일정 더보기 표시
            if (daySchedules.length > maxDisplay) {
                const moreElement = document.createElement('div');
                moreElement.className = 'schedule-count';
                moreElement.textContent = `+${daySchedules.length - maxDisplay}개`;
                cell.appendChild(moreElement);
            }
            
            // 일정 추가 버튼 표시
            if (isCurrentMonth && date >= new Date().setHours(0,0,0,0)) {
                const addBtn = document.createElement('a');
                addBtn.className = 'add-schedule-btn';
                addBtn.href = `add?date=${dateStr}`;
                addBtn.textContent = '+';
                addBtn.title = '일정 추가';
                cell.appendChild(addBtn);
            }
            
            return cell;
        }
        
        function previousMonth() {
            currentDate.setMonth(currentDate.getMonth() - 1);
            renderCalendar();
        }
        
        function nextMonth() {
            currentDate.setMonth(currentDate.getMonth() + 1);
            renderCalendar();
        }
        
        // 페이지 로드 시 캘린더 렌더링
        document.addEventListener('DOMContentLoaded', function() {
            renderCalendar();
        });
    </script>
</body>
</html> 
