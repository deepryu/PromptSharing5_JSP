<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.model.InterviewQuestion" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    // ?∏ÏÖò Í≤ÄÏ¶?
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    InterviewQuestion question = (InterviewQuestion) request.getAttribute("question");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    
    if (question == null && errorMessage == null) {
        response.sendRedirect("questions");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ÏßàÎ¨∏ ?ÅÏÑ∏ - PromptSharing</title>
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
        
        .question-info {
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
        
        .question-text {
            font-size: 1.2rem;
            line-height: 1.6;
            color: #2c3e50;
            background: #e8f4f8;
            padding: 20px;
            border-radius: 10px;
            border-left: 5px solid #3498db;
        }
        
        .expected-answer {
            background: #f0f8e8;
            padding: 20px;
            border-radius: 10px;
            border-left: 5px solid #27ae60;
            white-space: pre-wrap;
            line-height: 1.6;
        }
        
        .category-badge {
            padding: 8px 16px;
            border-radius: 20px;
            color: white;
            font-weight: bold;
            display: inline-block;
        }
        
        .category-technical { background: linear-gradient(45deg, #667eea, #764ba2); }
        .category-personality { background: linear-gradient(45deg, #f093fb, #f5576c); }
        .category-experience { background: linear-gradient(45deg, #4facfe, #00f2fe); }
        .category-situation { background: linear-gradient(45deg, #43e97b, #38f9d7); }
        
        .difficulty-stars {
            color: #ffc107;
            font-size: 1.2rem;
        }
        
        .status-badge {
            padding: 6px 12px;
            border-radius: 15px;
            font-weight: bold;
            font-size: 0.9rem;
        }
        
        .status-active {
            background: linear-gradient(45deg, #4CAF50, #8BC34A);
            color: white;
        }
        
        .status-inactive {
            background: linear-gradient(45deg, #FF5722, #FF9800);
            color: white;
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
        }
    </style>
</head>
<body>
    <div class="detail-container">
        <div class="detail-header">
            <h1>?ìù Î©¥Ï†ë ÏßàÎ¨∏ ?ÅÏÑ∏</h1>
            <p>ÏßàÎ¨∏???ÅÏÑ∏ ?ïÎ≥¥Î•??ïÏù∏?òÍ≥† Í¥ÄÎ¶¨Ìï† ???àÏäµ?àÎã§</p>
        </div>

        <% if (errorMessage != null) { %>
            <div class="alert alert-danger">
                ?†Ô∏è <%= errorMessage %>
            </div>
        <% } %>

        <% if (successMessage != null) { %>
            <div class="alert alert-success">
                ??<%= successMessage %>
            </div>
        <% } %>

        <% if (question != null) { %>
            <div class="detail-content">
                <div class="question-info">
                    <div class="info-row">
                        <div class="info-label">?ìå ÏßàÎ¨∏ ID:</div>
                        <div class="info-value"><strong>#<%= question.getId() %></strong></div>
                    </div>
                    
                    <div class="info-row">
                        <div class="info-label">?ìÇ Ïπ¥ÌÖåÍ≥†Î¶¨:</div>
                        <div class="info-value">
                            <span class="category-badge category-<%= question.getCategory().toLowerCase() %>">
                                <%= question.getCategoryText() %>
                            </span>
                        </div>
                    </div>
                    
                    <div class="info-row">
                        <div class="info-label">‚≠??úÏù¥??</div>
                        <div class="info-value">
                            <span class="difficulty-stars"><%= question.getDifficultyStars() %></span>
                            (<%= question.getDifficultyText() %>)
                        </div>
                    </div>
                    
                    <div class="info-row">
                        <div class="info-label">?îÑ ?ÅÌÉú:</div>
                        <div class="info-value">
                            <span class="status-badge <%= question.isActive() ? "status-active" : "status-inactive" %>">
                                <%= question.isActive() ? "?úÏÑ±" : "ÎπÑÌôú?? %>
                            </span>
                        </div>
                    </div>
                </div>

                <div class="info-row">
                    <div class="info-label">??ÏßàÎ¨∏ ?¥Ïö©:</div>
                </div>
                <div class="question-text">
                    <%= question.getQuestionText().replace("\n", "<br>") %>
                </div>

                <% if (question.getExpectedAnswer() != null && !question.getExpectedAnswer().trim().isEmpty()) { %>
                    <div style="margin-top: 25px;">
                        <div class="info-row">
                            <div class="info-label">?í° ?àÏÉÅ ?µÎ?:</div>
                        </div>
                        <div class="expected-answer">
                            <%= question.getExpectedAnswer().replace("\n", "<br>") %>
                        </div>
                    </div>
                <% } %>

                <div class="metadata">
                    <div class="metadata-item">
                        <div class="metadata-label">?ùÏÑ±?ºÏãú</div>
                        <div class="metadata-value">
                            <%= question.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) %>
                        </div>
                    </div>
                    <div class="metadata-item">
                        <div class="metadata-label">ÏµúÏ¢Ö ?òÏ†ï</div>
                        <div class="metadata-value">
                            <%= question.getUpdatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) %>
                        </div>
                    </div>
                    <div class="metadata-item">
                        <div class="metadata-label">ÏßàÎ¨∏ Í∏∏Ïù¥</div>
                        <div class="metadata-value">
                            <%= question.getQuestionText().length() %>??
                        </div>
                    </div>
                    <% if (question.getExpectedAnswer() != null) { %>
                    <div class="metadata-item">
                        <div class="metadata-label">?µÎ? Í∏∏Ïù¥</div>
                        <div class="metadata-value">
                            <%= question.getExpectedAnswer().length() %>??
                        </div>
                    </div>
                    <% } %>
                </div>

                <div class="action-buttons">
                    <a href="questions?action=edit&id=<%= question.getId() %>" class="btn btn-warning">
                        ?èÔ∏è ?òÏ†ï
                    </a>
                    <a href="javascript:toggleStatus(<%= question.getId() %>, <%= question.isActive() %>)" class="btn btn-primary">
                        ?îÑ <%= question.isActive() ? "ÎπÑÌôú?±Ìôî" : "?úÏÑ±?? %>
                    </a>
                    <a href="javascript:deleteQuestion(<%= question.getId() %>)" class="btn btn-danger">
                        ?óëÔ∏???†ú
                    </a>
                    <a href="questions" class="btn btn-secondary">
                        ?ìã Î™©Î°ù?ºÎ°ú
                    </a>
                </div>
            </div>
        <% } %>
    </div>

    <script>
        // Î©îÏãúÏßÄ ?êÎèô ?®Í?
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                alert.style.opacity = '0';
                setTimeout(() => alert.remove(), 300);
            });
        }, 3000);

        // ?ÅÌÉú ?†Í? ?®Ïàò
        function toggleStatus(questionId, isActive) {
            const action = isActive ? 'ÎπÑÌôú?±Ìôî' : '?úÏÑ±??;
            if (confirm(`?ïÎßêÎ°???ÏßàÎ¨∏??${action}?òÏãúÍ≤†Ïäµ?àÍπå?`)) {
                window.location.href = `questions?action=toggle&id=${questionId}`;
            }
        }

        // ??†ú ?®Ïàò
        function deleteQuestion(questionId) {
            if (confirm('?ïÎßêÎ°???ÏßàÎ¨∏????†ú?òÏãúÍ≤†Ïäµ?àÍπå?\n??†ú??ÏßàÎ¨∏?Ä Î≥µÍµ¨?????ÜÏäµ?àÎã§.')) {
                window.location.href = `questions?action=delete&id=${questionId}`;
            }
        }

        // ?§Î≥¥???®Ï∂ï??
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
    </script>
</body>
</html> 
