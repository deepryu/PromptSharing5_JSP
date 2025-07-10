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
        .action-buttons {
            display: flex;
            flex-direction: row;
            gap: var(--space-xs);
            flex-wrap: nowrap;
            max-width: 100%;
            overflow-x: auto;
        }
        
        .action-buttons .btn {
            font-size: var(--font-xs);
            padding: var(--space-xs) var(--space-sm);
            min-height: 28px;
            white-space: nowrap;
            text-align: center;
            flex-shrink: 0;
        }
        
        .action-buttons .btn-view { background-color: #6c757d; color: white; }
        .action-buttons .btn-edit { background-color: #fd7e14; color: white; }
        .action-buttons .btn-schedule-add { background-color: #20c997; color: white; }
        .action-buttons .btn-schedule-edit { background-color: #17a2b8; color: white; }
        .action-buttons .btn-result-add { background-color: #007bff; color: white; }
        .action-buttons .btn-result-edit { background-color: #6f42c1; color: white; }
        
        @media (max-width: 767px) {
            .action-buttons {
                gap: 2px;
            }
            
            .action-buttons .btn {
                min-height: 32px;
                font-size: 10px;
                padding: 4px 6px;
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
                                                String resultStatus = candidate.getInterviewResultStatus();
                                                
                                                String combinedStatus = "";
                                                if (interviewType != null && !"-".equals(interviewType) && !interviewType.trim().isEmpty()) {
                                                    combinedStatus = interviewType;
                                                }
                                                
                                                if (resultStatus != null && !resultStatus.trim().isEmpty() && !"미등록".equals(resultStatus)) {
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
                                                <% if ("미등록".equals(combinedStatus)) { %>status-pending
                                                <% } else if (combinedStatus.contains("합격") || combinedStatus.contains("채용") || combinedStatus.contains("통과")) { %>status-completed
                                                <% } else if (combinedStatus.contains("불합격") || combinedStatus.contains("탈락")) { %>status-rejected
                                                <% } else { %>status-in-progress<% } %>">
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
// 검색 기능
function searchCandidates() {
    const input = document.getElementById('searchInput');
    const filter = input.value.toLowerCase();
    const table = document.getElementById('candidatesTable');
    const rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
    
    for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        const cells = row.getElementsByTagName('td');
        let shouldShow = false;
        
        // 이름, 이메일, 전화번호에서 검색
        if (cells.length > 1) {
            const name = cells[1].textContent.toLowerCase();
            const email = cells[2].textContent.toLowerCase();
            const phone = cells[3].textContent.toLowerCase();
            
            if (name.includes(filter) || email.includes(filter) || phone.includes(filter)) {
                shouldShow = true;
            }
        }
        
        row.style.display = shouldShow ? '' : 'none';
    }
}

// 필터 기능
function filterCandidates() {
    const statusFilter = document.getElementById('statusFilter').value;
    const table = document.getElementById('candidatesTable');
    const rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
    
    for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        const status = row.getAttribute('data-status');
        
        if (statusFilter === '' || status === statusFilter) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    }
}

// 검색 초기화
function clearSearch() {
    document.getElementById('searchInput').value = '';
    document.getElementById('statusFilter').value = '';
    searchCandidates();
    filterCandidates();
}

// 모바일에서 테이블을 카드 형태로 변환
function toggleMobileTable() {
    const table = document.getElementById('candidatesTable');
    if (window.innerWidth <= 767) {
        table.classList.add('table-mobile-cards');
    } else {
        table.classList.remove('table-mobile-cards');
    }
}

// 페이지 로드 시와 창 크기 변경 시 실행
window.addEventListener('load', toggleMobileTable);
window.addEventListener('resize', toggleMobileTable);
</script>

</body>
</html> 