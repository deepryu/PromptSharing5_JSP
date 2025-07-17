<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.model.EvaluationCriteria" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.math.BigDecimal" %>
<%
    // ?�션 검�?- username ?�성 ?�용
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<EvaluationCriteria> criteriaList = (List<EvaluationCriteria>) request.getAttribute("criteriaList");
    @SuppressWarnings("unchecked")
    Map<String, Object> statistics = (Map<String, Object>) request.getAttribute("statistics");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    
    if (criteriaList == null) criteriaList = new java.util.ArrayList<>();
    if (statistics == null) statistics = new java.util.HashMap<>();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>?��? 기�? 관�?- PromptSharing</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            background: #f0f0f0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
        }
        
        .criteria-container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .criteria-header {
            background: #0078d4;
            color: white;
            padding: 15px 25px;
            border: 1px solid #106ebe;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .criteria-header h1 {
            margin: 0;
            font-size: 1.3rem;
            font-weight: 600;
        }
        
        .criteria-header p {
            margin: 5px 0 0 0;
            font-size: 0.9rem;
            opacity: 0.9;
        }
        
        .stats-grid {
            display: flex;
            background: white;
            border: 1px solid #d0d7de;
            margin-bottom: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .stat-card {
            flex: 1;
            padding: 15px 20px;
            text-align: center;
            border-right: 1px solid #d0d7de;
            background: white;
            transition: background-color 0.2s;
        }
        
        .stat-card:last-child {
            border-right: none;
        }
        
        .stat-card:hover {
            background: #f6f8fa;
        }
        
        .stat-number {
            font-size: 1.5em;
            font-weight: 600;
            color: #0969da;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: #656d76;
            font-size: 0.9rem;
        }
        
        .controls-section {
            background: white;
            border: 1px solid #d0d7de;
            padding: 15px 20px;
            margin-bottom: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .controls-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
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
        
        .btn-success {
            background: #1a7f37;
            color: white;
            border-color: #1a7f37;
        }
        
        .btn-success:hover {
            background: #166b32;
            border-color: #166b32;
        }
        
        .btn-warning {
            background: #fb8500;
            color: white;
            border-color: #fb8500;
        }
        
        .btn-warning:hover {
            background: #e07600;
            border-color: #e07600;
        }
        
        .btn-danger {
            background: #cf222e;
            color: white;
            border-color: #cf222e;
        }
        
        .btn-danger:hover {
            background: #b91c1c;
            border-color: #b91c1c;
        }
        
        .criteria-table {
            background: white;
            border: 1px solid #d0d7de;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .table th {
            background: #f6f8fa;
            border-bottom: 1px solid #d0d7de;
            color: #24292f;
            padding: 12px 15px;
            text-align: left;
            font-weight: 600;
            font-size: 0.9rem;
        }
        
        .table td {
            padding: 12px 15px;
            border-bottom: 1px solid #d0d7de;
            vertical-align: middle;
            font-size: 0.9rem;
        }
        
        .table tbody tr:hover {
            background-color: #f6f8fa;
        }
        
        .weight-bar {
            background: #e9ecef;
            border-radius: 10px;
            height: 20px;
            position: relative;
            overflow: hidden;
        }
        
        .weight-fill {
            height: 100%;
            border-radius: 10px;
            background: linear-gradient(45deg, #28a745, #20c997);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 0.8rem;
        }
        
        .status-badge {
            padding: 6px 12px;
            border-radius: 15px;
            font-weight: bold;
            font-size: 0.8rem;
        }
        
        .status-active {
            background: linear-gradient(45deg, #4CAF50, #8BC34A);
            color: white;
        }
        
        .status-inactive {
            background: linear-gradient(45deg, #FF5722, #FF9800);
            color: white;
        }
        
        .importance-badge {
            padding: 4px 8px;
            border-radius: 10px;
            font-size: 0.75rem;
            font-weight: bold;
        }
        
        .importance-high {
            background: #ff6b6b;
            color: white;
        }
        
        .importance-medium {
            background: #feca57;
            color: white;
        }
        
        .importance-low {
            background: #54a0ff;
            color: white;
        }
        
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        
        .btn-sm {
            padding: 6px 12px;
            font-size: 0.8rem;
            border-radius: 15px;
        }
        
        .alert {
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-weight: bold;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-danger {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #6c757d;
        }
        
        .empty-state h3 {
            color: #495057;
            margin-bottom: 15px;
        }
        
        .filter-section {
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: wrap;
        }
        
        .filter-group {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .filter-group label {
            font-weight: 500;
            color: #495057;
        }
        
        .filter-group select {
            padding: 8px 12px;
            border: 2px solid #dee2e6;
            border-radius: 20px;
            background: white;
        }
        
        @media (max-width: 768px) {
            .criteria-container {
                padding: 15px;
            }
            
            .controls-row {
                flex-direction: column;
                align-items: stretch;
            }
            
            .filter-section {
                flex-direction: column;
                align-items: stretch;
            }
            
            .table-responsive {
                overflow-x: auto;
            }
            
            .table th,
            .table td {
                padding: 10px 8px;
                font-size: 0.9rem;
            }
            
            .action-buttons {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="criteria-container">
        <div class="criteria-header">
            <h1>?�️ ?��? 기�? 관�?/h1>
            <p>면접 ?��? 기�???체계?�으�?관리하�??�영?????�습?�다</p>
        </div>

        <!-- ?�계 ?�션 -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-number"><%= statistics.getOrDefault("totalCriteria", 0) %></div>
                <div class="stat-label">?�� ?�체 ?��?기�?</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= statistics.getOrDefault("activeCriteria", 0) %></div>
                <div class="stat-label">???�성 기�?</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= statistics.getOrDefault("totalMaxScore", 0) %></div>
                <div class="stat-label">?�� �?만점</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= String.format("%.1f%%", ((BigDecimal) statistics.getOrDefault("totalWeight", BigDecimal.ZERO)).multiply(new BigDecimal("100"))) %></div>
                <div class="stat-label">?�️ �?가중치</div>
            </div>
        </div>

        <% if (errorMessage != null) { %>
            <div class="alert alert-danger">
                ?�️ <%= errorMessage %>
            </div>
        <% } %>

        <% if (successMessage != null) { %>
            <div class="alert alert-success">
                ??<%= successMessage %>
            </div>
        <% } %>

        <!-- 컨트�??�션 -->
        <div class="controls-section">
            <div class="controls-row">
                <div class="filter-section">
                    <div class="filter-group">
                        <label for="statusFilter">?�태:</label>
                        <select id="statusFilter" onchange="filterCriteria()">
                            <option value="all">?�체</option>
                            <option value="active">?�성</option>
                            <option value="inactive">비활??/option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label for="weightFilter">가중치:</label>
                        <select id="weightFilter" onchange="filterCriteria()">
                            <option value="all">?�체</option>
                            <option value="high">?�음 (0.2+)</option>
                            <option value="medium">보통 (0.1-0.2)</option>
                            <option value="low">??�� (0.1 미만)</option>
                        </select>
                    </div>
                </div>
                <div style="display: flex; gap: 10px;">
                    <a href="criteria?action=new" class="btn btn-success">
                        ?????��?기�?
                    </a>
                    <a href="javascript:exportCriteria()" class="btn btn-primary">
                        ?�� ?�보?�기
                    </a>
                </div>
            </div>
        </div>

        <!-- ?��?기�? ?�이�?-->
        <div class="criteria-table">
            <% if (criteriaList.isEmpty()) { %>
                <div class="empty-state">
                    <h3>?�� ?�록???��? 기�????�습?�다</h3>
                    <p>?�로???��? 기�???추�??�여 체계?�인 면접 ?��?�??�작?�세??</p>
                    <a href="criteria?action=new" class="btn btn-success" style="margin-top: 20px;">
                        ??�?번째 ?��?기�? 추�?
                    </a>
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>?��?기�?�?/th>
                                <th>?�명</th>
                                <th>최�??�수</th>
                                <th>가중치</th>
                                <th>중요??/th>
                                <th>?�태</th>
                                <th>관�?/th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (EvaluationCriteria criteria : criteriaList) { %>
                                <tr data-status="<%= criteria.isActive() ? "active" : "inactive" %>" 
                                    data-weight="<%= criteria.getWeightImportanceLevel() %>">
                                    <td><strong>#<%= criteria.getId() %></strong></td>
                                    <td>
                                        <strong><%= criteria.getCriteriaName() %></strong>
                                    </td>
                                    <td>
                                        <div style="max-width: 200px; overflow: hidden; text-overflow: ellipsis;">
                                            <%= criteria.getDescription() != null ? 
                                                (criteria.getDescription().length() > 50 ? 
                                                    criteria.getDescription().substring(0, 50) + "..." : 
                                                    criteria.getDescription()) : "" %>
                                        </div>
                                    </td>
                                    <td>
                                        <span style="font-weight: bold; color: #667eea;">
                                            <%= criteria.getMaxScore() %>??
                                        </span>
                                    </td>
                                    <td>
                                        <div class="weight-bar">
                                            <div class="weight-fill" style="width: <%= criteria.getWeightPercentage() %>%;">
                                                <%= String.format("%.1f%%", criteria.getWeightPercentage()) %>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="importance-badge importance-<%= criteria.getWeightImportanceLevel() %>">
                                            <%= criteria.getWeightImportanceText() %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="status-badge <%= criteria.isActive() ? "status-active" : "status-inactive" %>">
                                            <%= criteria.isActive() ? "?�성" : "비활?? %>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="action-buttons">
                                            <a href="criteria?action=detail&id=<%= criteria.getId() %>" 
                                               class="btn btn-primary btn-sm" title="?�세보기">
                                                ?���?
                                            </a>
                                            <a href="criteria?action=edit&id=<%= criteria.getId() %>" 
                                               class="btn btn-warning btn-sm" title="?�정">
                                                ?�️
                                            </a>
                                            <a href="javascript:toggleStatus(<%= criteria.getId() %>, <%= criteria.isActive() %>)" 
                                               class="btn btn-primary btn-sm" title="?�태 변�?>
                                                ?��
                                            </a>
                                            <a href="javascript:deleteCriteria(<%= criteria.getId() %>)" 
                                               class="btn btn-danger btn-sm" title="??��">
                                                ?���?
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </div>

    <script>
        // 메시지 ?�동 ?��?
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                alert.style.opacity = '0';
                setTimeout(() => alert.remove(), 300);
            });
        }, 3000);

        // ?�터�??�수
        function filterCriteria() {
            const statusFilter = document.getElementById('statusFilter').value;
            const weightFilter = document.getElementById('weightFilter').value;
            const rows = document.querySelectorAll('tbody tr');

            rows.forEach(row => {
                let showRow = true;

                // ?�태 ?�터
                if (statusFilter !== 'all') {
                    const rowStatus = row.getAttribute('data-status');
                    if (rowStatus !== statusFilter) {
                        showRow = false;
                    }
                }

                // 가중치 ?�터
                if (weightFilter !== 'all') {
                    const rowWeight = row.getAttribute('data-weight');
                    if (rowWeight !== weightFilter) {
                        showRow = false;
                    }
                }

                row.style.display = showRow ? '' : 'none';
            });
        }

        // ?�태 ?��? ?�수
        function toggleStatus(criteriaId, isActive) {
            const action = isActive ? '비활?�화' : '?�성??;
            if (confirm(`?�말�????��?기�???${action}?�시겠습?�까?`)) {
                window.location.href = `criteria?action=toggle&id=${criteriaId}`;
            }
        }

        // ??�� ?�수
        function deleteCriteria(criteriaId) {
            if (confirm('?�말�????��?기�?????��?�시겠습?�까?\n??��???��?기�??� 복구?????�습?�다.')) {
                window.location.href = `criteria?action=delete&id=${criteriaId}`;
            }
        }

        // ?�보?�기 ?�수
        function exportCriteria() {
            if (confirm('?��?기�? ?�이?��? CSV ?�일�??�보?�시겠습?�까?')) {
                window.location.href = 'criteria?action=export';
            }
        }

        // ?�보???�축??
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey || e.metaKey) {
                switch(e.key) {
                    case 'n':
                        e.preventDefault();
                        window.location.href = 'criteria?action=new';
                        break;
                    case 'f':
                        e.preventDefault();
                        document.getElementById('statusFilter').focus();
                        break;
                }
            }
        });
    </script>
</body>
</html> 
