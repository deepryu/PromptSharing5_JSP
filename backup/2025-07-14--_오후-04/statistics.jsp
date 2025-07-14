<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    // 세션 검증
    String username = (String)session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    Map<String, Object> statistics = (Map<String, Object>) request.getAttribute("statistics");
    Map<String, Object> monthlyStats = (Map<String, Object>) request.getAttribute("monthlyStats");
    Map<String, Object> interviewerStats = (Map<String, Object>) request.getAttribute("interviewerStats");
    Map<String, Object> candidateStats = (Map<String, Object>) request.getAttribute("candidateStats");
    String errorMessage = (String) request.getAttribute("errorMessage");
    
    if (statistics == null) statistics = new java.util.HashMap<>();
    if (monthlyStats == null) monthlyStats = new java.util.HashMap<>();
    if (interviewerStats == null) interviewerStats = new java.util.HashMap<>();
    if (candidateStats == null) candidateStats = new java.util.HashMap<>();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>통계 및 리포트 - 채용 관리 시스템</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            background: #f0f0f0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 15px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .top-bar {
            background: white;
            border: 1px solid #d0d7de;
            padding: 8px 15px;
            margin-bottom: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .top-bar h2 {
            margin: 0;
            color: #24292f;
            font-size: 1.1rem;
            font-weight: 600;
        }
        
        .top-bar .nav-buttons {
            display: flex;
            gap: 6px;
        }
        
        .top-bar .btn {
            padding: 5px 10px;
            font-size: 0.8rem;
            border: 1px solid #d0d7de;
            background: white;
            color: #24292f;
            text-decoration: none;
            border-radius: 3px;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        
        .top-bar .btn:hover {
            background: #f6f8fa;
        }
        
        .top-bar .btn-danger {
            background: #d13438;
            border-color: #b02a2f;
            color: white;
        }
        
        .top-bar .btn-danger:hover {
            background: #c23237;
        }
        
        .main-dashboard {
            background: white;
            border: 1px solid #d0d7de;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .dashboard-header {
            background: #0078d4;
            color: white;
            padding: 12px 20px;
            border-bottom: 1px solid #106ebe;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        .dashboard-header h1 {
            margin: 0;
            font-size: 1.2rem;
            font-weight: 600;
            text-align: center;
        }
        
        .dashboard-content {
            padding: 15px;
        }
        
        .stats-overview {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
            gap: 10px;
            margin-bottom: 20px;
        }
        
        .stat-card {
            background: #f6f8fa;
            border: 1px solid #d0d7de;
            padding: 12px;
            border-radius: 6px;
            text-align: center;
            transition: background-color 0.2s;
        }
        
        .stat-card:hover {
            background: #f0f6fc;
        }
        
        .stat-card.primary {
            background: #ddf4ff;
            border-color: #b6e3ff;
        }
        
        .stat-card.success {
            background: #dcfce7;
            border-color: #86efac;
        }
        
        .stat-card.warning {
            background: #fef3c7;
            border-color: #fcd34d;
        }
        
        .stat-card.danger {
            background: #fee2e2;
            border-color: #fca5a5;
        }
        
        .stat-number {
            font-size: 1.6rem;
            font-weight: 700;
            margin-bottom: 5px;
        }
        
        .stat-card.primary .stat-number {
            color: #0969da;
        }
        
        .stat-card.success .stat-number {
            color: #16a34a;
        }
        
        .stat-card.warning .stat-number {
            color: #d97706;
        }
        
        .stat-card.danger .stat-number {
            color: #dc2626;
        }
        
        .stat-label {
            color: #656d76;
            font-size: 0.8rem;
            font-weight: 500;
        }
        
        .section {
            background: white;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            margin-bottom: 15px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .section-header {
            background: #f6f8fa;
            border-bottom: 1px solid #d0d7de;
            padding: 10px 15px;
        }
        
        .section-header h3 {
            margin: 0;
            color: #24292f;
            font-size: 1.0rem;
            font-weight: 600;
        }
        
        .section-content {
            padding: 15px;
        }
        
        .two-column {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }
        
        .stats-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .stats-table th,
        .stats-table td {
            padding: 8px;
            text-align: left;
            border-bottom: 1px solid #d0d7de;
            font-size: 0.9rem;
        }
        
        .stats-table th {
            background: #f6f8fa;
            font-weight: 600;
            color: #24292f;
        }
        
        .badge {
            padding: 2px 6px;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 500;
            background: #f6f8fa;
            color: #656d76;
            border: 1px solid #d0d7de;
        }
        
        .badge-primary {
            background: #ddf4ff;
            color: #0969da;
            border-color: #b6e3ff;
        }
        
        .badge-success {
            background: #dcfce7;
            color: #16a34a;
            border-color: #86efac;
        }
        
        .monthly-chart {
            display: flex;
            align-items: end;
            gap: 10px;
            height: 120px;
            padding: 15px 0;
        }
        
        .chart-bar {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            position: relative;
        }
        
        .bar {
            width: 100%;
            background: #0969da;
            border-radius: 3px 3px 0 0;
            position: relative;
            min-height: 8px;
        }
        
        .bar-label {
            margin-top: 8px;
            font-size: 0.7rem;
            color: #656d76;
        }
        
        .no-data {
            text-align: center;
            color: #656d76;
            padding: 20px;
            font-size: 0.9rem;
        }
        
        .alert {
            padding: 10px 12px;
            margin-bottom: 15px;
            border: 1px solid transparent;
            border-radius: 3px;
        }
        
        .alert-danger {
            background: #fee2e2;
            border-color: #fca5a5;
            color: #dc2626;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- 상단 네비게이션 바 -->
        <div class="top-bar">
            <h2>📊 통계 및 리포트</h2>
            <div class="nav-buttons">
                <a href="main.jsp" class="btn">🏠 메인</a>
                <a href="candidates" class="btn">👥 인터뷰 대상자 관리</a>
                <a href="interview/list" class="btn">📅 인터뷰 일정 관리</a>
                <a href="questions" class="btn">💡 질문/평가 항목 관리</a>
                <a href="results" class="btn">📝 인터뷰 결과 기록/관리</a>
                <a href="logout" class="btn btn-danger">🚪 로그아웃</a>
            </div>
        </div>
        
        <!-- 메인 대시보드 -->
        <div class="main-dashboard">
            <div class="dashboard-header">
                <h1>📊 채용 관리 시스템 통계</h1>
            </div>
            <div class="dashboard-content">
                <% if (errorMessage != null) { %>
                    <div class="alert alert-danger">
                        ⚠️ <%= errorMessage %>
                    </div>
                <% } else { %>
                
                <!-- 전체 통계 개요 -->
                <div class="stats-overview">
                    <div class="stat-card primary">
                        <div class="stat-number"><%= statistics.get("totalCandidates") != null ? statistics.get("totalCandidates") : 0 %></div>
                        <div class="stat-label">총 지원자</div>
                    </div>
                    <div class="stat-card success">
                        <div class="stat-number"><%= statistics.get("totalInterviewers") != null ? statistics.get("totalInterviewers") : 0 %></div>
                        <div class="stat-label">활성 면접관</div>
                    </div>
                    <div class="stat-card warning">
                        <div class="stat-number"><%= statistics.get("totalSchedules") != null ? statistics.get("totalSchedules") : 0 %></div>
                        <div class="stat-label">총 면접 일정</div>
                    </div>
                    <div class="stat-card danger">
                        <div class="stat-number"><%= statistics.get("totalResults") != null ? statistics.get("totalResults") : 0 %></div>
                        <div class="stat-label">평가 결과</div>
                    </div>
                </div>
                
                <!-- 이번 달 통계 -->
                <div class="section">
                    <div class="section-header">
                        <h3>📅 이번 달 활동</h3>
                    </div>
                    <div class="section-content">
                        <div class="stats-overview">
                            <div class="stat-card">
                                <div class="stat-number"><%= statistics.get("thisMonthCandidates") != null ? statistics.get("thisMonthCandidates") : 0 %></div>
                                <div class="stat-label">신규 지원자</div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-number"><%= statistics.get("thisMonthSchedules") != null ? statistics.get("thisMonthSchedules") : 0 %></div>
                                <div class="stat-label">면접 일정</div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-number"><%= statistics.get("thisMonthResults") != null ? statistics.get("thisMonthResults") : 0 %></div>
                                <div class="stat-label">평가 완료</div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="two-column">
                    <!-- 면접 상태 통계 -->
                    <div class="section">
                        <div class="section-header">
                            <h3>📋 면접 현황</h3>
                        </div>
                        <div class="section-content">
                            <table class="stats-table">
                                <tr>
                                    <td>예정된 면접</td>
                                    <td><span class="badge badge-primary"><%= statistics.get("scheduledInterviews") != null ? statistics.get("scheduledInterviews") : 0 %>건</span></td>
                                </tr>
                                <tr>
                                    <td>완료된 면접</td>
                                    <td><span class="badge badge-success"><%= statistics.get("completedInterviews") != null ? statistics.get("completedInterviews") : 0 %>건</span></td>
                                </tr>
                                <tr>
                                    <td>취소된 면접</td>
                                    <td><span class="badge"><%= statistics.get("canceledInterviews") != null ? statistics.get("canceledInterviews") : 0 %>건</span></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    
                    <!-- 평가 결과 통계 -->
                    <div class="section">
                        <div class="section-header">
                            <h3>✅ 평가 결과</h3>
                        </div>
                        <div class="section-content">
                            <table class="stats-table">
                                <tr>
                                    <td>합격</td>
                                    <td><span class="badge badge-success"><%= statistics.get("passedCandidates") != null ? statistics.get("passedCandidates") : 0 %>명</span></td>
                                </tr>
                                <tr>
                                    <td>불합격</td>
                                    <td><span class="badge"><%= statistics.get("failedCandidates") != null ? statistics.get("failedCandidates") : 0 %>명</span></td>
                                </tr>
                                <tr>
                                    <td>검토중</td>
                                    <td><span class="badge badge-primary"><%= statistics.get("pendingCandidates") != null ? statistics.get("pendingCandidates") : 0 %>명</span></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
                
                <!-- 월별 통계 -->
                <div class="section">
                    <div class="section-header">
                        <h3>📈 최근 6개월 면접 추이</h3>
                    </div>
                    <div class="section-content">
                        <% 
                        List<Map<String, Object>> monthlyData = (List<Map<String, Object>>) monthlyStats.get("monthlyData");
                        if (monthlyData != null && !monthlyData.isEmpty()) {
                        %>
                            <div class="monthly-chart">
                                <% for (Map<String, Object> month : monthlyData) { %>
                                    <div class="chart-bar">
                                        <div class="bar" style="height: <%= Math.max(((Integer)month.get("totalInterviews")) * 2, 8) %>px;">
                                            <span style="position: absolute; top: -15px; left: 50%; transform: translateX(-50%); font-size: 0.7rem; color: #24292f;">
                                                <%= month.get("totalInterviews") %>
                                            </span>
                                        </div>
                                        <div class="bar-label"><%= month.get("month") %></div>
                                    </div>
                                <% } %>
                            </div>
                        <% } else { %>
                            <div class="no-data">최근 6개월간 면접 데이터가 없습니다.</div>
                        <% } %>
                    </div>
                </div>
                
                <div class="two-column">
                    <!-- 우수 면접관 -->
                    <div class="section">
                        <div class="section-header">
                            <h3>🏆 활동 면접관 TOP 5</h3>
                        </div>
                        <div class="section-content">
                            <% 
                            List<Map<String, Object>> topInterviewers = (List<Map<String, Object>>) interviewerStats.get("topInterviewers");
                            if (topInterviewers != null && !topInterviewers.isEmpty()) {
                            %>
                                <table class="stats-table">
                                    <thead>
                                        <tr>
                                            <th>면접관</th>
                                            <th>부서</th>
                                            <th>면접 수</th>
                                            <th>평균 점수</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                        int count = 0;
                                        for (Map<String, Object> interviewer : topInterviewers) { 
                                            if (count >= 5) break;
                                            count++;
                                        %>
                                            <tr>
                                                <td><%= interviewer.get("name") %></td>
                                                <td><%= interviewer.get("department") %></td>
                                                <td><span class="badge badge-primary"><%= interviewer.get("totalInterviews") %>건</span></td>
                                                <td>
                                                    <% 
                                                    Object avgScore = interviewer.get("avgScore");
                                                    if (avgScore != null && !avgScore.toString().equals("0.0")) {
                                                    %>
                                                        <%= String.format("%.1f", ((Double)avgScore)) %>점
                                                    <% } else { %>
                                                        -
                                                    <% } %>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            <% } else { %>
                                <div class="no-data">면접관 활동 데이터가 없습니다.</div>
                            <% } %>
                        </div>
                    </div>
                    
                    <!-- 지원자 분포 -->
                    <div class="section">
                        <div class="section-header">
                            <h3>👥 지원자 팀별 분포</h3>
                        </div>
                        <div class="section-content">
                            <% 
                            List<Map<String, Object>> teamDistribution = (List<Map<String, Object>>) candidateStats.get("teamDistribution");
                            if (teamDistribution != null && !teamDistribution.isEmpty()) {
                            %>
                                <table class="stats-table">
                                    <thead>
                                        <tr>
                                            <th>지원팀</th>
                                            <th>지원자 수</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Map<String, Object> team : teamDistribution) { %>
                                            <tr>
                                                <td><%= team.get("team") %></td>
                                                <td><span class="badge badge-primary"><%= team.get("count") %>명</span></td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            <% } else { %>
                                <div class="no-data">지원자 데이터가 없습니다.</div>
                            <% } %>
                        </div>
                    </div>
                </div>
                
                <!-- 월별 지원자 등록 추이 -->
                <div class="section">
                    <div class="section-header">
                        <h3>📊 최근 6개월 지원자 등록 추이</h3>
                    </div>
                    <div class="section-content">
                        <% 
                        List<Map<String, Object>> candidateMonthlyData = (List<Map<String, Object>>) candidateStats.get("monthlyData");
                        if (candidateMonthlyData != null && !candidateMonthlyData.isEmpty()) {
                        %>
                            <div class="monthly-chart">
                                <% for (Map<String, Object> month : candidateMonthlyData) { %>
                                    <div class="chart-bar">
                                        <div class="bar" style="height: <%= Math.max(((Integer)month.get("totalCandidates")) * 3, 8) %>px; background: #16a34a;">
                                            <span style="position: absolute; top: -15px; left: 50%; transform: translateX(-50%); font-size: 0.7rem; color: #24292f;">
                                                <%= month.get("totalCandidates") %>
                                            </span>
                                        </div>
                                        <div class="bar-label"><%= month.get("month") %></div>
                                    </div>
                                <% } %>
                            </div>
                        <% } else { %>
                            <div class="no-data">최근 지원자 등록 데이터가 없습니다.</div>
                        <% } %>
                    </div>
                </div>
                
                <% } %>
            </div>
        </div>
    </div>
</body>
</html> 