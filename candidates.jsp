<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.model.Candidate" %>
<%@ page import="com.example.model.InterviewScheduleDAO" %>
<%@ page import="com.example.model.InterviewResultDAO" %>
<%@ page import="com.example.model.InterviewSchedule" %>
<%@ page import="com.example.model.InterviewResult" %>
<%
    // 세션 검증
    String username = (String)session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    List<Candidate> candidates = (List<Candidate>) request.getAttribute("candidates");
    String error = request.getParameter("error");
    if (error != null && error.equals("duplicate")) {
%>
<script>
    alert('⚠️ 이미 동일한 지원자, 면접일, 면접관 조합의 면접결과가 등록되어 있습니다.');
    // URL에서 error 파라미터 제거 (히스토리 조작)
    if (window.history.replaceState) {
        const url = new URL(window.location);
        url.searchParams.delete('error');
        window.history.replaceState({}, document.title, url.pathname + url.search);
    }
</script>
<%
    }
    
    // DAO 인스턴스 생성
    InterviewScheduleDAO scheduleDAO = new InterviewScheduleDAO();
    InterviewResultDAO resultDAO = new InterviewResultDAO();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>인터뷰 대상자 관리 - 채용 관리 시스템</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/common.css">
    <style>
        /* 지원자 관리 페이지 전용 스타일 */
        
        /* 테이블 스타일 강화 */
        .table-container {
            background: white;
            border-radius: 3px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        #candidatesTable {
            width: 100%;
            border-collapse: collapse;
            margin: 0;
            background: white;
        }
        
        #candidatesTable th {
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
        
        #candidatesTable th:last-child {
            border-right: none;
        }
        
        #candidatesTable td {
            vertical-align: middle;
            border-bottom: 1px solid #eaeef2;
            border-right: 1px solid #eaeef2;
            padding: 10px 8px;
            font-size: 0.9rem;
        }
        
        #candidatesTable td:last-child {
            border-right: none;
        }
        
        /* 컬럼별 정렬 및 너비 설정 */
        #candidatesTable th:nth-child(1), 
        #candidatesTable td:nth-child(1) { /* ID */
            width: 50px;
            text-align: center;
            font-weight: 600;
            color: #0969da;
        }
        
        #candidatesTable th:nth-child(2), 
        #candidatesTable td:nth-child(2) { /* 이름 */
            width: 100px;
            text-align: left;
            font-weight: 600;
            color: #24292f;
        }
        
        #candidatesTable th:nth-child(3), 
        #candidatesTable td:nth-child(3) { /* 이메일 */
            width: 180px;
            text-align: left;
            color: #0969da;
            font-family: 'Courier New', monospace;
            font-size: 0.85rem;
        }
        
        #candidatesTable th:nth-child(4), 
        #candidatesTable td:nth-child(4) { /* 전화번호 */
            width: 120px;
            text-align: center;
            font-family: 'Courier New', monospace;
            color: #656d76;
        }
        
        #candidatesTable th:nth-child(5), 
        #candidatesTable td:nth-child(5) { /* 지원분야 */
            width: 100px;
            text-align: center;
            color: #24292f;
        }
        
        #candidatesTable th:nth-child(6), 
        #candidatesTable td:nth-child(6) { /* 인터뷰날짜 */
            width: 100px;
            text-align: center;
            font-family: 'Courier New', monospace;
            color: #656d76;
        }
        
        #candidatesTable th:nth-child(7), 
        #candidatesTable td:nth-child(7) { /* 시간 */
            width: 80px;
            text-align: center;
            font-family: 'Courier New', monospace;
            color: #656d76;
        }
        
        #candidatesTable th:nth-child(8), 
        #candidatesTable td:nth-child(8) { /* 상태 */
            width: 120px;
            text-align: center;
        }
        
        #candidatesTable th:nth-child(9), 
        #candidatesTable td:nth-child(9) { /* 액션 */
            width: 380px;
            text-align: center;
        }
        
        /* 테이블 행 스타일 */
        #candidatesTable tbody tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        
        #candidatesTable tbody tr:nth-child(odd) {
            background-color: white;
        }
        
        #candidatesTable tbody tr:hover {
            background-color: #e6f3ff !important;
            transform: scale(1.01);
            transition: all 0.2s ease;
        }
        
        /* 상태 배지 스타일 */
        .status-badge {
            padding: 4px 8px;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: 500;
            text-align: center;
            display: inline-block;
            min-width: 80px;
            line-height: 1.2;
            white-space: nowrap;
        }
        
        .status-scheduled {
            background: #dcfce7;
            color: #16a34a;
            border: 1px solid #86efac;
        }
        
        .status-completed {
            background: #dbeafe;
            color: #2563eb;
            border: 1px solid #93c5fd;
        }
        
        .status-cancelled {
            background: #fecaca;
            color: #dc2626;
            border: 1px solid #f87171;
        }
        
        .status-postponed {
            background: #f3e8ff;
            color: #7c3aed;
            border: 1px solid #c4b5fd;
        }
        
        /* 액션 버튼 스타일 개선 */
        .action-buttons {
            display: flex;
            flex-wrap: wrap;
            gap: 3px;
            justify-content: center;
            max-width: 100%;
        }
        
        .action-buttons .btn {
            font-size: 0.7rem;
            padding: 3px 6px;
            min-height: 24px;
            white-space: nowrap;
            text-align: center;
            flex-shrink: 0;
            border-radius: 3px;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s ease;
        }
        
        .action-buttons .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        
        .action-buttons .btn-view { 
            background-color: #6c757d; 
            color: white; 
        }
        
        .action-buttons .btn-edit { 
            background-color: #fd7e14; 
            color: white; 
        }
        
        .action-buttons .btn-schedule-add { 
            background-color: #20c997; 
            color: white; 
        }
        
        .action-buttons .btn-schedule-edit { 
            background-color: #17a2b8; 
            color: white; 
        }
        
        .action-buttons .btn-result-add { 
            background-color: #007bff; 
            color: white; 
        }
        
        .action-buttons .btn-result-edit { 
            background-color: #6f42c1; 
            color: white; 
        }
        
        .action-buttons .btn.disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none !important;
            box-shadow: none !important;
        }
        
        /* 반응형 테이블 */
        @media (max-width: 768px) {
            #candidatesTable {
                font-size: 0.8rem;
            }
            
            .action-buttons {
                gap: 2px;
            }
            
            .action-buttons .btn {
                font-size: 0.65rem;
                padding: 2px 4px;
                min-height: 20px;
            }
            
            #candidatesTable th:nth-child(9), 
            #candidatesTable td:nth-child(9) { /* 액션 */
                width: 320px;
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
                <a href="interview/list" class="btn">📅 인터뷰 일정 관리</a>
                <a href="questions" class="btn">💡 질문/평가 항목 관리</a>
                <a href="results" class="btn">📝 인터뷰 결과 기록/관리</a>
                <a href="statistics" class="btn">📊 통계 및 리포트</a>
                <a href="logout" class="btn btn-danger">🚪 로그아웃</a>
            </div>
        </div>
        
        <div class="main-content">
            <div class="content-header">
                <h1>👥 인터뷰 대상자 관리</h1>
            </div>
            <div class="content-body">
                <!-- 통계 바 -->
                <div class="stats-bar">
                    <div class="stat-item">
                        <div class="stat-number"><%= candidates != null ? candidates.size() : 0 %></div>
                        <div class="stat-label">총 지원자</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">
                            <%
                                int activeCount = 0;
                                if (candidates != null) {
                                    for (com.example.model.Candidate c : candidates) {
                                        if ("활성".equals(c.getStatus()) || "ACTIVE".equals(c.getStatus())) {
                                            activeCount++;
                                        }
                                    }
                                }
                                out.print(activeCount);
                            %>
                        </div>
                        <div class="stat-label">활성 지원자</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">
                            <%
                                int interviewedCount = 0;
                                if (candidates != null) {
                                    for (com.example.model.Candidate c : candidates) {
                                        if ("면접완료".equals(c.getStatus()) || "INTERVIEWED".equals(c.getStatus())) {
                                            interviewedCount++;
                                        }
                                    }
                                }
                                out.print(interviewedCount);
                            %>
                        </div>
                        <div class="stat-label">면접 완료</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">
                            <%
                                int hiredCount = 0;
                                if (candidates != null) {
                                    for (com.example.model.Candidate c : candidates) {
                                        if ("채용완료".equals(c.getStatus()) || "HIRED".equals(c.getStatus())) {
                                            hiredCount++;
                                        }
                                    }
                                }
                                out.print(hiredCount);
                            %>
                        </div>
                        <div class="stat-label">채용 완료</div>
                    </div>
                </div>
                
                <!-- 컨트롤 섹션 -->
                <div class="controls-section">
                    <div class="controls-grid">
                        <div class="search-container">
                            <input type="text" id="searchInput" placeholder="이름, 이메일, 전화번호로 검색..." onkeyup="searchCandidates()">
                            <button type="button" class="btn" onclick="clearSearch()">🔄 초기화</button>
                        </div>
                        <div class="filter-controls">
                            <select id="statusFilter" onchange="filterCandidates()">
                                <option value="">전체 상태</option>
                                <option value="활성">활성</option>
                                <option value="ACTIVE">활성(EN)</option>
                                <option value="면접완료">면접완료</option>
                                <option value="INTERVIEWED">면접완료(EN)</option>
                                <option value="채용완료">채용완료</option>
                                <option value="HIRED">채용완료(EN)</option>
                                <option value="탈락">탈락</option>
                                <option value="REJECTED">탈락(EN)</option>
                            </select>
                        </div>
                        <a href="${pageContext.request.contextPath}/candidates/add" class="btn btn-primary">➕ 새 지원자 추가</a>
                        <a href="${pageContext.request.contextPath}/candidates/export" class="btn">📊 Excel 내보내기</a>
                    </div>
                </div>
                
                <!-- 지원자 테이블 -->
                <div class="table-container">
                    <table id="candidatesTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>이름</th>
                                <th>이메일</th>
                                <th>전화번호</th>
                                <th>지원분야</th>
                                <th>인터뷰날짜</th>
                                <th>시간</th>
                                <th>상태</th>
                                <th>액션</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (candidates != null && !candidates.isEmpty()) { %>
                                <% for (Candidate candidate : candidates) { %>
                                    <tr data-status="<%= candidate.getStatus() %>">
                                        <td data-label="ID"><%= candidate.getId() %></td>
                                        <td data-label="이름"><%= candidate.getName() %></td>
                                        <td data-label="이메일"><%= candidate.getEmail() %></td>
                                        <td data-label="전화번호"><%= candidate.getPhone() %></td>
                                        <td data-label="지원분야"><%= candidate.getTeam() != null ? candidate.getTeam() : "미정" %></td>
                                        <td data-label="인터뷰날짜">
                                            <% 
                                                String interviewDateTime = candidate.getInterviewDateTime();
                                                if (interviewDateTime != null && !interviewDateTime.trim().isEmpty()) {
                                                    try {
                                                        // "yyyy-MM-dd HH:mm" 형식에서 날짜 부분만 추출
                                                        String[] dateTimeParts = interviewDateTime.split(" ");
                                                        if (dateTimeParts.length >= 1) {
                                                            out.print(dateTimeParts[0]); // 날짜 부분
                                                        } else {
                                                            out.print("미정");
                                                        }
                                                    } catch (Exception e) {
                                                        out.print("미정");
                                                    }
                                                } else {
                                                    out.print("미정");
                                                }
                                            %>
                                        </td>
                                        <td data-label="시간">
                                            <% 
                                                if (interviewDateTime != null && !interviewDateTime.trim().isEmpty()) {
                                                    try {
                                                        // "yyyy-MM-dd HH:mm" 형식에서 시간 부분만 추출
                                                        String[] dateTimeParts = interviewDateTime.split(" ");
                                                        if (dateTimeParts.length >= 2) {
                                                            out.print(dateTimeParts[1]); // 시간 부분
                                                        } else {
                                                            out.print("미정");
                                                        }
                                                    } catch (Exception e) {
                                                        out.print("미정");
                                                    }
                                                } else {
                                                    out.print("미정");
                                                }
                                            %>
                                        </td>
                                        <td data-label="상태">
                                                                        <%
                                // 면접유형과 인터뷰결과를 합쳐서 표시
                                String interviewType = candidate.getInterviewType();
                                String rawResultStatus = candidate.getInterviewResultStatus();
                                
                                // 영어 상태를 한글로 변환
                                String resultStatus = "";
                                if (rawResultStatus != null && !rawResultStatus.trim().isEmpty() && !"미등록".equals(rawResultStatus)) {
                                    if ("pass".equals(rawResultStatus)) {
                                        resultStatus = "합격";
                                    } else if ("fail".equals(rawResultStatus)) {
                                        resultStatus = "불합격";
                                    } else if ("hold".equals(rawResultStatus)) {
                                        resultStatus = "보류";
                                    } else if ("pending".equals(rawResultStatus)) {
                                        resultStatus = "대기";
                                    } else {
                                        resultStatus = rawResultStatus; // 원본 값 사용 (이미 한글인 경우)
                                    }
                                }
                                
                                String combinedStatus = "";
                                if (interviewType != null && !"-".equals(interviewType) && !interviewType.trim().isEmpty()) {
                                    combinedStatus = interviewType;
                                }
                                
                                if (!resultStatus.isEmpty()) {
                                    if (!combinedStatus.isEmpty()) {
                                        combinedStatus += " / " + resultStatus;
                                    } else {
                                        combinedStatus = resultStatus;
                                    }
                                }
                                
                                if (combinedStatus.isEmpty()) {
                                    combinedStatus = "미등록";
                                }
                            %>
                                                                        <span class="status-badge 
                                <% if ("미등록".equals(combinedStatus)) { %>status-scheduled
                                <% } else if (combinedStatus.contains("합격") || combinedStatus.contains("채용") || combinedStatus.contains("통과") || combinedStatus.contains("완료")) { %>status-completed
                                <% } else if (combinedStatus.contains("불합격") || combinedStatus.contains("탈락") || combinedStatus.contains("취소")) { %>status-cancelled
                                <% } else if (combinedStatus.contains("대기") || combinedStatus.contains("보류")) { %>status-postponed
                                <% } else { %>status-scheduled<% } %>">
                                                <%= combinedStatus %>
                                            </span>
                                        </td>
                                        <td data-label="액션">
                                            <!-- 디버깅: 상태 값 출력 -->
                                            <!-- DEBUG: ID=<%= candidate.getId() %>, hasSchedule=<%= candidate.getHasInterviewSchedule() %>, hasResult=<%= candidate.getHasInterviewResult() %> -->
                                            
                                            <div class="action-buttons">
                                                <!-- 1. 지원자보기 -->
                                                <a href="${pageContext.request.contextPath}/candidates/detail?id=<%= candidate.getId() %>" class="btn btn-view" title="지원자 상세정보 보기">
                                                    👁️ 보기
                                                </a>
                                                
                                                <!-- 2. 지원자수정 -->
                                                <a href="${pageContext.request.contextPath}/candidates/edit?id=<%= candidate.getId() %>" class="btn btn-edit" title="지원자 정보 수정">
                                                    ✏️ 수정
                                                </a>
                                                
                                                <!-- 3. 일정등록 (항상 표시, 일정이 있으면 비활성화) -->
                                                <% if (candidate.getHasInterviewSchedule()) { %>
                                                <span class="btn btn-schedule-add disabled" title="이미 인터뷰 일정이 등록되어 있습니다" style="background-color: #898989 !important; color: white !important; cursor: not-allowed;">
                                                    📅 일정등록
                                                </span>
                                                <% } else { %>
                                                <a href="${pageContext.request.contextPath}/interview/add?candidateId=<%= candidate.getId() %>&from=candidates" class="btn btn-schedule-add" title="새 인터뷰 일정 등록">
                                                    📅 일정등록
                                                </a>
                                                <% } %>
                                                
                                                <!-- 4. 일정수정 (기존 일정이 있을 때만) -->
                                                <% if (candidate.getHasInterviewSchedule() && candidate.getInterviewScheduleId() != null) { %>
                                                <a href="${pageContext.request.contextPath}/interview/edit?id=<%= candidate.getInterviewScheduleId() %>&from=candidates" class="btn btn-schedule-edit" title="기존 인터뷰 일정 수정">
                                                    📝 일정수정
                                                </a>
                                                <% } %>
                                                
                                                <!-- 5. 결과등록 (항상 표시, 일정이 없거나 결과가 있으면 비활성화) -->
                                                <% if (!candidate.getHasInterviewSchedule()) { %>
                                                <span class="btn btn-result-add disabled" title="먼저 인터뷰 일정을 등록해주세요" style="background-color: #898989 !important; color: white !important; cursor: not-allowed;">
                                                    📊 결과등록
                                                </span>
                                                <% } else if (candidate.getHasInterviewResult()) { %>
                                                <span class="btn btn-result-add disabled" title="이미 인터뷰 결과가 등록되어 있습니다" style="background-color: #898989 !important; color: white !important; cursor: not-allowed;">
                                                    📊 결과등록
                                                </span>
                                                <% } else { %>
                                                <a href="${pageContext.request.contextPath}/results/add?candidateId=<%= candidate.getId() %>&scheduleId=<%= candidate.getInterviewScheduleId() %>&from=candidates" class="btn btn-result-add" title="인터뷰 결과 등록">
                                                    📊 결과등록
                                                </a>
                                                <% } %>
                                                
                                                <!-- 6. 결과수정 (기존 결과가 있을 때만) -->
                                                <% if (candidate.getHasInterviewResult()) { %>
                                                <%
                                                    // 최신 결과 ID 가져오기
                                                    List<InterviewResult> candidateResults = resultDAO.getResultsByCandidateId(candidate.getId());
                                                    int latestResultId = 0;
                                                    if (candidateResults != null && !candidateResults.isEmpty()) {
                                                        latestResultId = candidateResults.get(0).getId();
                                                    }
                                                %>
                                                <a href="${pageContext.request.contextPath}/results/edit?id=<%= latestResultId %>&from=candidates" class="btn btn-result-edit" title="기존 인터뷰 결과 수정">
                                                    📈 결과수정
                                                </a>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                <% } %>
                            <% } else { %>
                                <tr>
                                    <td colspan="9" class="text-center">등록된 지원자가 없습니다.</td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

<script>
// 통합 검색 및 필터 기능
function filterTable() {
    const searchInput = document.getElementById('searchInput').value.toLowerCase();
    const statusFilter = document.getElementById('statusFilter').value;
    const table = document.getElementById('candidatesTable');
    const rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
    
    for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        const cells = row.getElementsByTagName('td');
        let shouldShow = true;
        
        // 검색어 필터 (이름, 이메일, 전화번호)
        if (searchInput && cells.length > 1) {
            const name = cells[1].textContent.toLowerCase();
            const email = cells[2].textContent.toLowerCase();
            const phone = cells[3].textContent.toLowerCase();
            
            if (!name.includes(searchInput) && !email.includes(searchInput) && !phone.includes(searchInput)) {
                shouldShow = false;
            }
        }
        
        // 상태 필터
        if (shouldShow && statusFilter) {
            const status = row.getAttribute('data-status');
            if (status !== statusFilter) {
                shouldShow = false;
            }
        }
        
        row.style.display = shouldShow ? '' : 'none';
    }
}

// 개별 함수들 (기존 호출 유지를 위해)
function searchCandidates() {
    filterTable();
}

function filterCandidates() {
    filterTable();
}

// 검색 초기화
function clearSearch() {
    document.getElementById('searchInput').value = '';
    document.getElementById('statusFilter').value = '';
    filterTable();
}
</script>

</body>
</html> 
</html> 