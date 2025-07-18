<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
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
<html>
<head>
    <title>?΅κ³ λ°?λ¦¬ν¬??/title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            background: #f0f0f0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
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
        
        .top-bar .nav-links a {
            color: #24292f;
            text-decoration: none;
            margin-left: 15px;
            font-size: 0.9rem;
            padding: 6px 12px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            transition: all 0.2s;
        }
        
        .top-bar .nav-links a:hover {
            background: #f6f8fa;
            border-color: #8c959f;
        }
        
        .main-dashboard {
            background: white;
            border: 1px solid #d0d7de;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .dashboard-header {
            background: #0078d4;
            color: white;
            padding: 15px 25px;
            border-bottom: 1px solid #106ebe;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .dashboard-header h1 {
            margin: 0;
            font-size: 1.3rem;
            font-weight: 600;
        }
        
        .dashboard-content {
            padding: 20px;
        }
        
        .stats-overview {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: #f6f8fa;
            border: 1px solid #d0d7de;
            padding: 20px;
            border-radius: 6px;
            text-align: center;
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
            font-size: 2.2rem;
            font-weight: 700;
            margin-bottom: 8px;
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
            font-size: 0.9rem;
            font-weight: 500;
        }
        
        .section {
            background: white;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            margin-bottom: 20px;
            overflow: hidden;
        }
        
        .section-header {
            background: #f6f8fa;
            border-bottom: 1px solid #d0d7de;
            padding: 15px 20px;
        }
        
        .section-header h3 {
            margin: 0;
            color: #24292f;
            font-size: 1.1rem;
            font-weight: 600;
        }
        
        .section-content {
            padding: 20px;
        }
        
        .two-column {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        
        .stats-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .stats-table th,
        .stats-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #d0d7de;
        }
        
        .stats-table th {
            background: #f6f8fa;
            font-weight: 600;
            color: #24292f;
            font-size: 0.9rem;
        }
        
        .stats-table tr:hover {
            background: #f6f8fa;
        }
        
        .badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        
        .badge-primary {
            background: #ddf4ff;
            color: #0969da;
            border: 1px solid #b6e3ff;
        }
        
        .badge-success {
            background: #dcfce7;
            color: #16a34a;
            border: 1px solid #86efac;
        }
        
        .monthly-chart {
            padding: 20px;
            text-align: center;
        }
        
        .chart-bar {
            display: inline-block;
            margin: 0 5px;
            text-align: center;
            vertical-align: bottom;
        }
        
        .bar {
            width: 40px;
            background: #0969da;
            margin-bottom: 10px;
            border-radius: 2px 2px 0 0;
            position: relative;
        }
        
        .bar-completed {
            background: #16a34a;
        }
        
        .bar-canceled {
            background: #dc2626;
            margin-left: 2px;
        }
        
        .bar-label {
            font-size: 0.8rem;
            color: #656d76;
            transform: rotate(-45deg);
            transform-origin: center;
            white-space: nowrap;
        }
        
        .alert {
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 20px;
        }
        
        .alert-danger {
            background: #fee2e2;
            color: #dc2626;
            border: 1px solid #fca5a5;
        }
        
        .no-data {
            text-align: center;
            color: #656d76;
            font-style: italic;
            padding: 40px;
        }
        
        @media (max-width: 768px) {
            .two-column {
                grid-template-columns: 1fr;
            }
            
            .stats-overview {
                grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h2>? ?΅κ³ λ°?λ¦¬ν¬??/h2>
            <div class="nav-links">
                <a href="main.jsp">?  ??/a>
                <a href="candidates">?₯ μ§?μ</a>
                <a href="interview/list">? ?Όμ κ΄λ¦?/a>
                <a href="questions">?‘ μ§λ¬Έκ΄λ¦?/a>
                <a href="results">? κ²°κ³Όκ΄λ¦?/a>
                <a href="statistics">? ?΅κ³</a>
                <a href="interviewers">?¨?π?λ©΄μ κ΄</a>
                <a href="notifications">? ?λ¦Ό</a>
                <a href="settings">?οΈ ?€μ </a>
                <a href="logout">?ͺ λ‘κ·Έ?μ</a>
            </div>
        </div>
        
        <div class="main-dashboard">
            <div class="dashboard-header">
                <h1>μ±μ© κ΄λ¦??μ€???΅κ³</h1>
            </div>
            <div class="dashboard-content">
                <% if (errorMessage != null) { %>
                    <div class="alert alert-danger">
                        ? οΈ <%= errorMessage %>
                    </div>
                <% } else { %>
                
                <!-- ?μ²΄ ?΅κ³ κ°μ -->
                <div class="stats-overview">
                    <div class="stat-card primary">
                        <div class="stat-number"><%= statistics.get("totalCandidates") != null ? statistics.get("totalCandidates") : 0 %></div>
                        <div class="stat-label">μ΄?μ§?μ</div>
                    </div>
                    <div class="stat-card success">
                        <div class="stat-number"><%= statistics.get("totalInterviewers") != null ? statistics.get("totalInterviewers") : 0 %></div>
                        <div class="stat-label">?μ± λ©΄μ κ΄</div>
                    </div>
                    <div class="stat-card warning">
                        <div class="stat-number"><%= statistics.get("totalSchedules") != null ? statistics.get("totalSchedules") : 0 %></div>
                        <div class="stat-label">μ΄?λ©΄μ  ?Όμ </div>
                    </div>
                    <div class="stat-card danger">
                        <div class="stat-number"><%= statistics.get("totalResults") != null ? statistics.get("totalResults") : 0 %></div>
                        <div class="stat-label">?κ? κ²°κ³Ό</div>
                    </div>
                </div>
                
                <!-- ?΄λ² ???΅κ³ -->
                <div class="section">
                    <div class="section-header">
                        <h3>? ?΄λ² ???λ</h3>
                    </div>
                    <div class="section-content">
                        <div class="stats-overview">
                            <div class="stat-card">
                                <div class="stat-number"><%= statistics.get("thisMonthCandidates") != null ? statistics.get("thisMonthCandidates") : 0 %></div>
                                <div class="stat-label">? κ· μ§?μ</div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-number"><%= statistics.get("thisMonthSchedules") != null ? statistics.get("thisMonthSchedules") : 0 %></div>
                                <div class="stat-label">λ©΄μ  ?Όμ </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-number"><%= statistics.get("thisMonthResults") != null ? statistics.get("thisMonthResults") : 0 %></div>
                                <div class="stat-label">?κ? ?λ£</div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="two-column">
                    <!-- λ©΄μ  ?ν ?΅κ³ -->
                    <div class="section">
                        <div class="section-header">
                            <h3>? λ©΄μ  ?ν©</h3>
                        </div>
                        <div class="section-content">
                            <table class="stats-table">
                                <tr>
                                    <td>?μ ??λ©΄μ </td>
                                    <td><span class="badge badge-primary"><%= statistics.get("scheduledInterviews") != null ? statistics.get("scheduledInterviews") : 0 %>κ±?/span></td>
                                </tr>
                                <tr>
                                    <td>?λ£??λ©΄μ </td>
                                    <td><span class="badge badge-success"><%= statistics.get("completedInterviews") != null ? statistics.get("completedInterviews") : 0 %>κ±?/span></td>
                                </tr>
                                <tr>
                                    <td>μ·¨μ??λ©΄μ </td>
                                    <td><span class="badge"><%= statistics.get("canceledInterviews") != null ? statistics.get("canceledInterviews") : 0 %>κ±?/span></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    
                    <!-- ?κ? κ²°κ³Ό ?΅κ³ -->
                    <div class="section">
                        <div class="section-header">
                            <h3>???κ? κ²°κ³Ό</h3>
                        </div>
                        <div class="section-content">
                            <table class="stats-table">
                                <tr>
                                    <td>?©κ²©</td>
                                    <td><span class="badge badge-success"><%= statistics.get("passedCandidates") != null ? statistics.get("passedCandidates") : 0 %>λͺ?/span></td>
                                </tr>
                                <tr>
                                    <td>λΆν©κ²?/td>
                                    <td><span class="badge"><%= statistics.get("failedCandidates") != null ? statistics.get("failedCandidates") : 0 %>λͺ?/span></td>
                                </tr>
                                <tr>
                                    <td>κ²? μ€</td>
                                    <td><span class="badge badge-primary"><%= statistics.get("pendingCandidates") != null ? statistics.get("pendingCandidates") : 0 %>λͺ?/span></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
                
                <!-- ?λ³ ?΅κ³ -->
                <div class="section">
                    <div class="section-header">
                        <h3>? μ΅κ·Ό 6κ°μ λ©΄μ  μΆμ΄</h3>
                    </div>
                    <div class="section-content">
                        <% 
                        List<Map<String, Object>> monthlyData = (List<Map<String, Object>>) monthlyStats.get("monthlyData");
                        if (monthlyData != null && !monthlyData.isEmpty()) {
                        %>
                            <div class="monthly-chart">
                                <% for (Map<String, Object> month : monthlyData) { %>
                                    <div class="chart-bar">
                                        <div class="bar" style="height: <%= Math.max(((Integer)month.get("totalInterviews")) * 3, 10) %>px;">
                                            <span style="position: absolute; top: -20px; left: 50%; transform: translateX(-50%); font-size: 0.8rem; color: #24292f;">
                                                <%= month.get("totalInterviews") %>
                                            </span>
                                        </div>
                                        <div class="bar-label"><%= month.get("month") %></div>
                                    </div>
                                <% } %>
                            </div>
                        <% } else { %>
                            <div class="no-data">μ΅κ·Ό 6κ°μκ°?λ©΄μ  ?°μ΄?°κ? ?μ΅?λ€.</div>
                        <% } %>
                    </div>
                </div>
                
                <div class="two-column">
                    <!-- ?°μ λ©΄μ κ΄ -->
                    <div class="section">
                        <div class="section-header">
                            <h3>? ?λ λ©΄μ κ΄ TOP 5</h3>
                        </div>
                        <div class="section-content">
                            <% 
                            List<Map<String, Object>> topInterviewers = (List<Map<String, Object>>) interviewerStats.get("topInterviewers");
                            if (topInterviewers != null && !topInterviewers.isEmpty()) {
                            %>
                                <table class="stats-table">
                                    <thead>
                                        <tr>
                                            <th>λ©΄μ κ΄</th>
                                            <th>λΆ??/th>
                                            <th>λ©΄μ  ??/th>
                                            <th>?κ·  ?μ</th>
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
                                                <td><span class="badge badge-primary"><%= interviewer.get("totalInterviews") %>κ±?/span></td>
                                                <td>
                                                    <% 
                                                    Object avgScore = interviewer.get("avgScore");
                                                    if (avgScore != null && !avgScore.toString().equals("0.0")) {
                                                    %>
                                                        <%= String.format("%.1f", ((Double)avgScore)) %>??
                                                    <% } else { %>
                                                        -
                                                    <% } %>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            <% } else { %>
                                <div class="no-data">λ©΄μ κ΄ ?λ ?°μ΄?°κ? ?μ΅?λ€.</div>
                            <% } %>
                        </div>
                    </div>
                    
                    <!-- μ§?μ λΆν¬ -->
                    <div class="section">
                        <div class="section-header">
                            <h3>?₯ μ§?μ ?λ³?λΆν¬</h3>
                        </div>
                        <div class="section-content">
                            <% 
                            List<Map<String, Object>> teamStats = (List<Map<String, Object>>) candidateStats.get("teamStats");
                            if (teamStats != null && !teamStats.isEmpty()) {
                            %>
                                <table class="stats-table">
                                    <thead>
                                        <tr>
                                            <th>μ§?ν?</th>
                                            <th>μ§?μ ??/th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Map<String, Object> team : teamStats) { %>
                                            <tr>
                                                <td><%= team.get("team") %></td>
                                                <td><span class="badge badge-primary"><%= team.get("count") %>λͺ?/span></td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            <% } else { %>
                                <div class="no-data">μ§?μ ?°μ΄?°κ? ?μ΅?λ€.</div>
                            <% } %>
                        </div>
                    </div>
                </div>
                
                <!-- ?λ³ μ§?μ ?±λ‘ μΆμ΄ -->
                <div class="section">
                    <div class="section-header">
                        <h3>? μ΅κ·Ό 6κ°μ μ§?μ ?±λ‘ μΆμ΄</h3>
                    </div>
                    <div class="section-content">
                        <% 
                        List<Map<String, Object>> monthlyRegistration = (List<Map<String, Object>>) candidateStats.get("monthlyRegistration");
                        if (monthlyRegistration != null && !monthlyRegistration.isEmpty()) {
                        %>
                            <div class="stats-overview">
                                <% for (Map<String, Object> month : monthlyRegistration) { %>
                                    <div class="stat-card">
                                        <div class="stat-number"><%= month.get("count") %></div>
                                        <div class="stat-label"><%= month.get("month") %></div>
                                    </div>
                                <% } %>
                            </div>
                        <% } else { %>
                            <div class="no-data">μ΅κ·Ό μ§?μ ?±λ‘ ?°μ΄?°κ? ?μ΅?λ€.</div>
                        <% } %>
                    </div>
                </div>
                
                <% } %>
            </div>
        </div>
    </div>
</body>
</html> 
