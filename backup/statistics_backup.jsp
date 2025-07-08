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
    <title>?µÍ≥Ñ Î∞?Î¶¨Ìè¨??/title>
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
            <h2>?ìä ?µÍ≥Ñ Î∞?Î¶¨Ìè¨??/h2>
            <div class="nav-links">
                <a href="main.jsp">?è† ??/a>
                <a href="candidates">?ë• ÏßÄ?êÏûê</a>
                <a href="interview/list">?ìÖ ?ºÏ†ïÍ¥ÄÎ¶?/a>
                <a href="questions">?í° ÏßàÎ¨∏Í¥ÄÎ¶?/a>
                <a href="results">?ìù Í≤∞Í≥ºÍ¥ÄÎ¶?/a>
                <a href="statistics">?ìä ?µÍ≥Ñ</a>
                <a href="interviewers">?ë®?çüí?Î©¥Ï†ëÍ¥Ä</a>
                <a href="notifications">?îî ?åÎ¶º</a>
                <a href="settings">?ôÔ∏è ?§Ï†ï</a>
                <a href="logout">?ö™ Î°úÍ∑∏?ÑÏõÉ</a>
            </div>
        </div>
        
        <div class="main-dashboard">
            <div class="dashboard-header">
                <h1>Ï±ÑÏö© Í¥ÄÎ¶??úÏä§???µÍ≥Ñ</h1>
            </div>
            <div class="dashboard-content">
                <% if (errorMessage != null) { %>
                    <div class="alert alert-danger">
                        ?†Ô∏è <%= errorMessage %>
                    </div>
                <% } else { %>
                
                <!-- ?ÑÏ≤¥ ?µÍ≥Ñ Í∞úÏöî -->
                <div class="stats-overview">
                    <div class="stat-card primary">
                        <div class="stat-number"><%= statistics.get("totalCandidates") != null ? statistics.get("totalCandidates") : 0 %></div>
                        <div class="stat-label">Ï¥?ÏßÄ?êÏûê</div>
                    </div>
                    <div class="stat-card success">
                        <div class="stat-number"><%= statistics.get("totalInterviewers") != null ? statistics.get("totalInterviewers") : 0 %></div>
                        <div class="stat-label">?úÏÑ± Î©¥Ï†ëÍ¥Ä</div>
                    </div>
                    <div class="stat-card warning">
                        <div class="stat-number"><%= statistics.get("totalSchedules") != null ? statistics.get("totalSchedules") : 0 %></div>
                        <div class="stat-label">Ï¥?Î©¥Ï†ë ?ºÏ†ï</div>
                    </div>
                    <div class="stat-card danger">
                        <div class="stat-number"><%= statistics.get("totalResults") != null ? statistics.get("totalResults") : 0 %></div>
                        <div class="stat-label">?âÍ? Í≤∞Í≥º</div>
                    </div>
                </div>
                
                <!-- ?¥Î≤à ???µÍ≥Ñ -->
                <div class="section">
                    <div class="section-header">
                        <h3>?ìÖ ?¥Î≤à ???úÎèô</h3>
                    </div>
                    <div class="section-content">
                        <div class="stats-overview">
                            <div class="stat-card">
                                <div class="stat-number"><%= statistics.get("thisMonthCandidates") != null ? statistics.get("thisMonthCandidates") : 0 %></div>
                                <div class="stat-label">?†Í∑ú ÏßÄ?êÏûê</div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-number"><%= statistics.get("thisMonthSchedules") != null ? statistics.get("thisMonthSchedules") : 0 %></div>
                                <div class="stat-label">Î©¥Ï†ë ?ºÏ†ï</div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-number"><%= statistics.get("thisMonthResults") != null ? statistics.get("thisMonthResults") : 0 %></div>
                                <div class="stat-label">?âÍ? ?ÑÎ£å</div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="two-column">
                    <!-- Î©¥Ï†ë ?ÅÌÉú ?µÍ≥Ñ -->
                    <div class="section">
                        <div class="section-header">
                            <h3>?ìã Î©¥Ï†ë ?ÑÌô©</h3>
                        </div>
                        <div class="section-content">
                            <table class="stats-table">
                                <tr>
                                    <td>?àÏ†ï??Î©¥Ï†ë</td>
                                    <td><span class="badge badge-primary"><%= statistics.get("scheduledInterviews") != null ? statistics.get("scheduledInterviews") : 0 %>Í±?/span></td>
                                </tr>
                                <tr>
                                    <td>?ÑÎ£å??Î©¥Ï†ë</td>
                                    <td><span class="badge badge-success"><%= statistics.get("completedInterviews") != null ? statistics.get("completedInterviews") : 0 %>Í±?/span></td>
                                </tr>
                                <tr>
                                    <td>Ï∑®ÏÜå??Î©¥Ï†ë</td>
                                    <td><span class="badge"><%= statistics.get("canceledInterviews") != null ? statistics.get("canceledInterviews") : 0 %>Í±?/span></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    
                    <!-- ?âÍ? Í≤∞Í≥º ?µÍ≥Ñ -->
                    <div class="section">
                        <div class="section-header">
                            <h3>???âÍ? Í≤∞Í≥º</h3>
                        </div>
                        <div class="section-content">
                            <table class="stats-table">
                                <tr>
                                    <td>?©Í≤©</td>
                                    <td><span class="badge badge-success"><%= statistics.get("passedCandidates") != null ? statistics.get("passedCandidates") : 0 %>Î™?/span></td>
                                </tr>
                                <tr>
                                    <td>Î∂àÌï©Í≤?/td>
                                    <td><span class="badge"><%= statistics.get("failedCandidates") != null ? statistics.get("failedCandidates") : 0 %>Î™?/span></td>
                                </tr>
                                <tr>
                                    <td>Í≤Ä?†Ï§ë</td>
                                    <td><span class="badge badge-primary"><%= statistics.get("pendingCandidates") != null ? statistics.get("pendingCandidates") : 0 %>Î™?/span></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
                
                <!-- ?îÎ≥Ñ ?µÍ≥Ñ -->
                <div class="section">
                    <div class="section-header">
                        <h3>?ìà ÏµúÍ∑º 6Í∞úÏõî Î©¥Ï†ë Ï∂îÏù¥</h3>
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
                            <div class="no-data">ÏµúÍ∑º 6Í∞úÏõîÍ∞?Î©¥Ï†ë ?∞Ïù¥?∞Í? ?ÜÏäµ?àÎã§.</div>
                        <% } %>
                    </div>
                </div>
                
                <div class="two-column">
                    <!-- ?∞Ïàò Î©¥Ï†ëÍ¥Ä -->
                    <div class="section">
                        <div class="section-header">
                            <h3>?èÜ ?úÎèô Î©¥Ï†ëÍ¥Ä TOP 5</h3>
                        </div>
                        <div class="section-content">
                            <% 
                            List<Map<String, Object>> topInterviewers = (List<Map<String, Object>>) interviewerStats.get("topInterviewers");
                            if (topInterviewers != null && !topInterviewers.isEmpty()) {
                            %>
                                <table class="stats-table">
                                    <thead>
                                        <tr>
                                            <th>Î©¥Ï†ëÍ¥Ä</th>
                                            <th>Î∂Ä??/th>
                                            <th>Î©¥Ï†ë ??/th>
                                            <th>?âÍ∑† ?êÏàò</th>
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
                                                <td><span class="badge badge-primary"><%= interviewer.get("totalInterviews") %>Í±?/span></td>
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
                                <div class="no-data">Î©¥Ï†ëÍ¥Ä ?úÎèô ?∞Ïù¥?∞Í? ?ÜÏäµ?àÎã§.</div>
                            <% } %>
                        </div>
                    </div>
                    
                    <!-- ÏßÄ?êÏûê Î∂ÑÌè¨ -->
                    <div class="section">
                        <div class="section-header">
                            <h3>?ë• ÏßÄ?êÏûê ?ÄÎ≥?Î∂ÑÌè¨</h3>
                        </div>
                        <div class="section-content">
                            <% 
                            List<Map<String, Object>> teamStats = (List<Map<String, Object>>) candidateStats.get("teamStats");
                            if (teamStats != null && !teamStats.isEmpty()) {
                            %>
                                <table class="stats-table">
                                    <thead>
                                        <tr>
                                            <th>ÏßÄ?êÌ?</th>
                                            <th>ÏßÄ?êÏûê ??/th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Map<String, Object> team : teamStats) { %>
                                            <tr>
                                                <td><%= team.get("team") %></td>
                                                <td><span class="badge badge-primary"><%= team.get("count") %>Î™?/span></td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            <% } else { %>
                                <div class="no-data">ÏßÄ?êÏûê ?∞Ïù¥?∞Í? ?ÜÏäµ?àÎã§.</div>
                            <% } %>
                        </div>
                    </div>
                </div>
                
                <!-- ?îÎ≥Ñ ÏßÄ?êÏûê ?±Î°ù Ï∂îÏù¥ -->
                <div class="section">
                    <div class="section-header">
                        <h3>?ìä ÏµúÍ∑º 6Í∞úÏõî ÏßÄ?êÏûê ?±Î°ù Ï∂îÏù¥</h3>
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
                            <div class="no-data">ÏµúÍ∑º ÏßÄ?êÏûê ?±Î°ù ?∞Ïù¥?∞Í? ?ÜÏäµ?àÎã§.</div>
                        <% } %>
                    </div>
                </div>
                
                <% } %>
            </div>
        </div>
    </div>
</body>
</html> 
