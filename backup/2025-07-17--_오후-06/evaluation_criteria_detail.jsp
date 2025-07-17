<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.model.EvaluationCriteria" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.math.BigDecimal" %>
<%
    // ?�션 검�?
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    EvaluationCriteria criteria = (EvaluationCriteria) request.getAttribute("criteria");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    
    if (criteria == null && errorMessage == null) {
        response.sendRedirect("criteria");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>?��?기�? ?�세 - PromptSharing</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .detail-container {
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        
        .detail-header {
            text-align: center;
            margin-bottom: 30px;
            color: white;
        }
        
        .detail-header h1 {
            font-size: 2.5rem;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        
        .detail-content {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            margin-bottom: 20px;
        }
        
        .criteria-info {
            margin-bottom: 30px;
        }
        
        .info-row {
            display: flex;
            margin-bottom: 20px;
            align-items: center;
            padding: 15px;
            border-radius: 10px;
            background: #f8f9fa;
        }
        
        .info-label {
            font-weight: bold;
            color: #495057;
            width: 150px;
            flex-shrink: 0;
        }
        
        .info-value {
            flex: 1;
            color: #212529;
        }
        
        .criteria-name {
            font-size: 1.5rem;
            font-weight: bold;
            color: #2c3e50;
            background: #e8f4f8;
            padding: 20px;
            border-radius: 10px;
            border-left: 5px solid #3498db;
            margin-bottom: 20px;
        }
        
        .description-box {
            background: #f0f8e8;
            padding: 20px;
            border-radius: 10px;
            border-left: 5px solid #27ae60;
            white-space: pre-wrap;
            line-height: 1.6;
            margin-top: 10px;
        }
        
        .score-display {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            padding: 15px 25px;
            border-radius: 20px;
            font-size: 1.2rem;
            font-weight: bold;
            text-align: center;
            display: inline-block;
        }
        
        .weight-section {
            background: #fff3cd;
            border: 2px solid #ffc107;
            border-radius: 15px;
            padding: 20px;
            margin: 20px 0;
        }
        
        .weight-bar {
            background: #e9ecef;
            border-radius: 15px;
            height: 30px;
            position: relative;
            overflow: hidden;
            margin: 15px 0;
        }
        
        .weight-fill {
            height: 100%;
            border-radius: 15px;
            background: linear-gradient(45deg, #28a745, #20c997);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 1rem;
            transition: width 0.3s ease;
        }
        
        .importance-badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: bold;
            display: inline-block;
            margin-left: 10px;
        }
        
        .importance-high {
            background: linear-gradient(45deg, #ff6b6b, #ee5a52);
            color: white;
        }
        
        .importance-medium {
            background: linear-gradient(45deg, #feca57, #ff9ff3);
            color: white;
        }
        
        .importance-low {
            background: linear-gradient(45deg, #54a0ff, #2e86de);
            color: white;
        }
        
        .status-badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: bold;
            font-size: 1rem;
        }
        
        .status-active {
            background: linear-gradient(45deg, #4CAF50, #8BC34A);
            color: white;
        }
        
        .status-inactive {
            background: linear-gradient(45deg, #FF5722, #FF9800);
            color: white;
        }
        
        .calculation-section {
            background: #e7f3ff;
            border: 2px solid #4dabf7;
            border-radius: 15px;
            padding: 20px;
            margin: 20px 0;
        }
        
        .calculation-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid #ced4da;
        }
        
        .calculation-item:last-child {
            border-bottom: none;
            font-weight: bold;
            font-size: 1.1rem;
            color: #2c3e50;
            background: #f8f9fa;
            padding: 15px;
            border-radius: 10px;
            margin-top: 10px;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }
        
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 25px;
            font-weight: bold;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 1rem;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-primary {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
        }
        
        .btn-warning {
            background: linear-gradient(45deg, #ffc107, #ff8c00);
            color: white;
        }
        
        .btn-danger {
            background: linear-gradient(45deg, #dc3545, #c82333);
            color: white;
        }
        
        .btn-secondary {
            background: linear-gradient(45deg, #6c757d, #5a6268);
            color: white;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
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
        
        .metadata {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 20px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 10px;
        }
        
        .metadata-item {
            text-align: center;
        }
        
        .metadata-label {
            font-size: 0.9rem;
            color: #6c757d;
            margin-bottom: 5px;
        }
        
        .metadata-value {
            font-weight: bold;
            color: #495057;
            font-size: 1.1rem;
        }
        
        .usage-tips {
            background: #f8f9fa;
            border-left: 4px solid #17a2b8;
            padding: 20px;
            margin: 20px 0;
            border-radius: 0 10px 10px 0;
        }
        
        .usage-tips h4 {
            color: #17a2b8;
            margin-bottom: 15px;
        }
        
        .usage-tips ul {
            margin: 0;
            padding-left: 20px;
        }
        
        .usage-tips li {
            margin-bottom: 8px;
            color: #495057;
        }
        
        @media (max-width: 768px) {
            .detail-container {
                padding: 15px;
            }
            
            .detail-content {
                padding: 20px;
            }
            
            .info-row {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .info-label {
                width: auto;
                margin-bottom: 5px;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .btn {
                text-align: center;
                justify-content: center;
            }
            
            .calculation-item {
                flex-direction: column;
                align-items: flex-start;
                gap: 5px;
            }
        }
    </style>
</head>
<body>
    <div class="detail-container">
        <div class="detail-header">
            <h1>?�️ ?��?기�? ?�세</h1>
            <p>?��?기�????�세 ?�보�??�인?�고 관리할 ???�습?�다</p>
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

        <% if (criteria != null) { %>
            <div class="detail-content">
                <div class="criteria-info">
                    <div class="info-row">
                        <div class="info-label">?�� 기�? ID:</div>
                        <div class="info-value"><strong>#<%= criteria.getId() %></strong></div>
                    </div>
                    
                    <div class="info-row">
                        <div class="info-label">?�� ?�태:</div>
                        <div class="info-value">
                            <span class="status-badge <%= criteria.isActive() ? "status-active" : "status-inactive" %>">
                                <%= criteria.isActive() ? "?�성" : "비활?? %>
                            </span>
                        </div>
                    </div>
                </div>

                <div class="criteria-name">
                    ?�� <%= criteria.getCriteriaName() %>
                </div>

                <% if (criteria.getDescription() != null && !criteria.getDescription().trim().isEmpty()) { %>
                    <div class="info-row">
                        <div class="info-label">?�� ?�명:</div>
                    </div>
                    <div class="description-box">
                        <%= criteria.getDescription().replace("\n", "<br>") %>
                    </div>
                <% } %>

                <!-- ?�수 ?�보 -->
                <div style="margin: 30px 0;">
                    <div class="info-row">
                        <div class="info-label">?�� 최�? ?�수:</div>
                        <div class="info-value">
                            <span class="score-display">
                                <%= criteria.getMaxScore() %>??
                            </span>
                        </div>
                    </div>
                </div>

                <!-- 가중치 ?�보 -->
                <div class="weight-section">
                    <h4 style="margin-bottom: 15px; color: #856404;">?�️ 가중치 ?�보</h4>
                    <div class="info-row">
                        <div class="info-label">가중치 비율:</div>
                        <div class="info-value">
                            <strong><%= String.format("%.1f%%", criteria.getWeight().multiply(new BigDecimal("100")).doubleValue()) %></strong>
                            <span class="importance-badge importance-<%= criteria.getWeightImportanceLevel() %>">
                                <%= criteria.getWeightImportanceText() %>
                            </span>
                        </div>
                    </div>
                    <div class="weight-bar">
                        <div class="weight-fill" style="width: <%= criteria.getWeight().multiply(new BigDecimal("100")).doubleValue() %>%;">
                            <%= String.format("%.1f%%", criteria.getWeight().multiply(new BigDecimal("100")).doubleValue()) %>
                        </div>
                    </div>
                </div>

                <!-- 계산 ?�보 -->
                <div class="calculation-section">
                    <h4 style="margin-bottom: 15px; color: #0c5460;">?�� ?�수 계산 ?�보</h4>
                    <div class="calculation-item">
                        <span>기본 ?�수:</span>
                        <span><%= criteria.getMaxScore() %>??/span>
                    </div>
                    <div class="calculation-item">
                        <span>가중치:</span>
                        <span><%= String.format("%.3f", criteria.getWeight().doubleValue()) %></span>
                    </div>
                    <div class="calculation-item">
                        <span>?�� 가�??�용 ??최�??�수:</span>
                        <span><%= String.format("%.1f??, criteria.getMaxScore() * criteria.getWeight().doubleValue()) %></span>
                    </div>
                </div>

                <!-- ?�용 ??-->
                <div class="usage-tips">
                    <h4>?�� ?��? ?�용 ??/h4>
                    <ul>
                        <li><strong>가중치 <%= String.format("%.1f%%", criteria.getWeight().multiply(new BigDecimal("100")).doubleValue()) %></strong>???�체 ?��??�서 ??기�???차�??�는 비중?�니??</li>
                        <li>만점 ??<strong><%= String.format("%.1f??, criteria.getMaxScore() * criteria.getWeight().doubleValue()) %>??/strong>??최종 ?�수??반영?�니??</li>
                        <li>중요?��? <strong><%= criteria.getWeightImportanceText() %></strong>???��? ??��?�니??</li>
                        <% if (criteria.getWeight().compareTo(new BigDecimal("0.15")) >= 0) { %>
                            <li>?�️ 고중?�도 ?��?기�??��?�??�중???��?가 ?�요?�니??</li>
                        <% } %>
                    </ul>
                </div>

                <div class="metadata">
                    <div class="metadata-item">
                        <div class="metadata-label">?�성?�시</div>
                        <div class="metadata-value">
                            <%= criteria.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) %>
                        </div>
                    </div>
                    <div class="metadata-item">
                        <div class="metadata-label">최종 ?�정</div>
                        <div class="metadata-value">
                            <%= criteria.getUpdatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) %>
                        </div>
                    </div>
                    <div class="metadata-item">
                        <div class="metadata-label">가중치 ?�위</div>
                        <div class="metadata-value">
                            <%= criteria.getWeightImportanceText() %>
                        </div>
                    </div>
                    <div class="metadata-item">
                        <div class="metadata-label">?�율??지??/div>
                        <div class="metadata-value">
                            <%= String.format("%.2f", criteria.getMaxScore() * criteria.getWeight().doubleValue()) %>
                        </div>
                    </div>
                </div>

                <div class="action-buttons">
                    <a href="criteria?action=edit&id=<%= criteria.getId() %>" class="btn btn-warning">
                        ?�️ ?�정
                    </a>
                    <a href="javascript:toggleStatus(<%= criteria.getId() %>, <%= criteria.isActive() %>)" class="btn btn-primary">
                        ?�� <%= criteria.isActive() ? "비활?�화" : "?�성?? %>
                    </a>
                    <a href="javascript:deleteCriteria(<%= criteria.getId() %>)" class="btn btn-danger">
                        ?���???��
                    </a>
                    <a href="criteria" class="btn btn-secondary">
                        ?�� 목록?�로
                    </a>
                </div>
            </div>
        <% } %>
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

        // ?�보???�축??
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey || e.metaKey) {
                switch(e.key) {
                    case 'e':
                        e.preventDefault();
                        document.querySelector('.btn-warning').click();
                        break;
                    case 'Backspace':
                        e.preventDefault();
                        document.querySelector('.btn-secondary').click();
                        break;
                }
            }
        });

        // 가중치 �??�니메이??
        window.addEventListener('load', function() {
            const weightFill = document.querySelector('.weight-fill');
            if (weightFill) {
                const targetWidth = weightFill.style.width;
                weightFill.style.width = '0%';
                setTimeout(() => {
                    weightFill.style.width = targetWidth;
                }, 300);
            }
        });
    </script>
</body>
</html> 
