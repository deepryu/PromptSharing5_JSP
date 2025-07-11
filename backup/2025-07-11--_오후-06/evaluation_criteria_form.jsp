<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.model.EvaluationCriteria" %>
<%@ page import="java.math.BigDecimal" %>
<%
    // ?∏ÏÖò Í≤ÄÏ¶?- username ?çÏÑ± ?¨Ïö©
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    EvaluationCriteria criteria = (EvaluationCriteria) request.getAttribute("criteria");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    boolean isEdit = criteria != null && criteria.getId() != null;
    String pageTitle = isEdit ? "?âÍ?Í∏∞Ï? ?òÏ†ï" : "?âÍ?Í∏∞Ï? ?±Î°ù";
    
    // Í∏∞Î≥∏Í∞??§Ï†ï
    if (criteria == null) {
        criteria = new EvaluationCriteria();
        criteria.setMaxScore(10);
        criteria.setWeight(new BigDecimal("0.10"));
        criteria.setActive(true);
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> - PromptSharing</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .form-container {
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        
        .form-header {
            text-align: center;
            margin-bottom: 30px;
            color: white;
        }
        
        .form-header h1 {
            font-size: 2.5rem;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        
        .form-content {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            margin-bottom: 20px;
        }
        
        .form-layout {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            align-items: start;
        }
        
        .form-section {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 15px;
            border: 2px solid #e9ecef;
        }
        
        .form-section h3 {
            color: #495057;
            margin-bottom: 20px;
            font-size: 1.3rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #495057;
            font-size: 1rem;
        }
        
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #dee2e6;
            border-radius: 10px;
            font-size: 1rem;
            transition: all 0.3s ease;
            box-sizing: border-box;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .form-control.error {
            border-color: #dc3545;
            background-color: #fff5f5;
        }
        
        .form-control.success {
            border-color: #28a745;
            background-color: #f8fff9;
        }
        
        textarea.form-control {
            resize: vertical;
            min-height: 100px;
            line-height: 1.5;
        }
        
        .char-counter {
            text-align: right;
            font-size: 0.9rem;
            color: #6c757d;
            margin-top: 5px;
        }
        
        .char-counter.warning {
            color: #ffc107;
        }
        
        .char-counter.error {
            color: #dc3545;
        }
        
        .range-group {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .range-input {
            flex: 1;
        }
        
        .range-value {
            background: #667eea;
            color: white;
            padding: 8px 15px;
            border-radius: 20px;
            font-weight: bold;
            min-width: 60px;
            text-align: center;
        }
        
        .weight-display {
            background: linear-gradient(45deg, #28a745, #20c997);
            color: white;
            padding: 10px 15px;
            border-radius: 20px;
            font-weight: bold;
            text-align: center;
        }
        
        .toggle-switch {
            position: relative;
            width: 60px;
            height: 30px;
            background: #ccc;
            border-radius: 15px;
            cursor: pointer;
            transition: background 0.3s ease;
        }
        
        .toggle-switch.active {
            background: #4CAF50;
        }
        
        .toggle-slider {
            position: absolute;
            top: 3px;
            left: 3px;
            width: 24px;
            height: 24px;
            background: white;
            border-radius: 50%;
            transition: transform 0.3s ease;
        }
        
        .toggle-switch.active .toggle-slider {
            transform: translateX(30px);
        }
        
        .preview-section {
            background: #e8f4f8;
            border: 2px solid #3498db;
            border-radius: 15px;
            padding: 20px;
        }
        
        .preview-item {
            margin-bottom: 15px;
            padding: 10px;
            background: white;
            border-radius: 8px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .preview-label {
            font-weight: bold;
            color: #495057;
        }
        
        .preview-value {
            color: #667eea;
            font-weight: bold;
        }
        
        .weight-bar {
            background: #e9ecef;
            border-radius: 10px;
            height: 20px;
            position: relative;
            overflow: hidden;
            margin-top: 5px;
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
            transition: width 0.3s ease;
        }
        
        .form-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px solid #e9ecef;
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
        
        .help-text {
            font-size: 0.9rem;
            color: #6c757d;
            margin-top: 5px;
            font-style: italic;
        }
        
        .validation-message {
            color: #dc3545;
            font-size: 0.9rem;
            margin-top: 5px;
            display: none;
        }
        
        @media (max-width: 768px) {
            .form-container {
                padding: 15px;
            }
            
            .form-content {
                padding: 20px;
            }
            
            .form-layout {
                grid-template-columns: 1fr;
                gap: 20px;
            }
            
            .form-actions {
                flex-direction: column;
            }
            
            .range-group {
                flex-direction: column;
                align-items: stretch;
            }
        }
    </style>
</head>
<body>
    <div class="form-container">
        <div class="form-header">
            <h1>?ñÔ∏è <%= pageTitle %></h1>
            <p>Ï≤¥Í≥Ñ?ÅÏù∏ Î©¥Ï†ë ?âÍ?Î•??ÑÌïú ?âÍ? Í∏∞Ï????§Ï†ï?òÏÑ∏??/p>
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

        <div class="form-content">
            <form id="criteriaForm" method="post" action="criteria">
                <% if (isEdit) { %>
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<%= criteria.getId() %>">
                <% } else { %>
                    <input type="hidden" name="action" value="create">
                <% } %>

                <div class="form-layout">
                    <!-- Í∏∞Î≥∏ ?ïÎ≥¥ ?πÏÖò -->
                    <div class="form-section">
                        <h3>?ìã Í∏∞Î≥∏ ?ïÎ≥¥</h3>
                        
                        <div class="form-group">
                            <label for="criteriaName">?âÍ?Í∏∞Ï?Î™?*</label>
                            <input type="text" id="criteriaName" name="criteriaName" 
                                   class="form-control" required maxlength="100"
                                   value="<%= criteria.getCriteriaName() != null ? criteria.getCriteriaName() : "" %>"
                                   placeholder="?? Í∏∞Ïà† ??üâ, Ïª§Î??àÏ??¥ÏÖò ?•Î†•"
                                   oninput="updatePreview(); validateForm();">
                            <div class="char-counter">
                                <span id="nameCounter">0</span>/100
                            </div>
                            <div class="validation-message" id="nameError">
                                ?âÍ?Í∏∞Ï?Î™ÖÏùÑ ?ÖÎ†•?¥Ï£º?∏Ïöî.
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="description">?§Î™Ö</label>
                            <textarea id="description" name="description" 
                                      class="form-control" maxlength="500"
                                      placeholder="?âÍ?Í∏∞Ï????Ä???ÅÏÑ∏ ?§Î™Ö???ÖÎ†•?òÏÑ∏??.."
                                      oninput="updatePreview(); validateForm();"><%= criteria.getDescription() != null ? criteria.getDescription() : "" %></textarea>
                            <div class="char-counter">
                                <span id="descCounter">0</span>/500
                            </div>
                            <div class="help-text">
                                ?í° ?âÍ??êÍ? ?¥Ìï¥?òÍ∏∞ ?ΩÎèÑÎ°?Íµ¨Ï≤¥?ÅÏúºÎ°??ëÏÑ±?¥Ï£º?∏Ïöî
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label>?úÏÑ± ?ÅÌÉú</label>
                            <div style="display: flex; align-items: center; gap: 15px;">
                                <div class="toggle-switch <%= criteria.isActive() ? "active" : "" %>" 
                                     onclick="toggleActive()" id="statusToggle">
                                    <div class="toggle-slider"></div>
                                </div>
                                <span id="statusText"><%= criteria.isActive() ? "?úÏÑ±" : "ÎπÑÌôú?? %></span>
                                <input type="hidden" name="active" id="activeInput" 
                                       value="<%= criteria.isActive() %>">
                            </div>
                            <div class="help-text">
                                ?îÑ ?úÏÑ± ?ÅÌÉú???âÍ?Í∏∞Ï?Îß??§Ï†ú ?âÍ????¨Ïö©?©Îãà??
                            </div>
                        </div>
                    </div>

                    <!-- ?êÏàò Î∞?Í∞ÄÏ§ëÏπò ?πÏÖò -->
                    <div class="form-section">
                        <h3>?éØ ?êÏàò Î∞?Í∞ÄÏ§ëÏπò</h3>
                        
                        <div class="form-group">
                            <label for="maxScore">ÏµúÎ? ?êÏàò *</label>
                            <div class="range-group">
                                <input type="range" id="maxScore" name="maxScore" 
                                       class="range-input" min="1" max="100" step="1"
                                       value="<%= criteria.getMaxScore() %>"
                                       oninput="updateMaxScore(); updatePreview(); validateForm();">
                                <div class="range-value" id="maxScoreValue">
                                    <%= criteria.getMaxScore() %>??
                                </div>
                            </div>
                            <div class="help-text">
                                ?ìä ???âÍ?Í∏∞Ï???ÏµúÎ? ?çÎìù Í∞Ä???êÏàò
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="weight">Í∞ÄÏ§ëÏπò *</label>
                            <div class="range-group">
                                <input type="range" id="weight" name="weight" 
                                       class="range-input" min="0.01" max="1.00" step="0.01"
                                       value="<%= criteria.getWeight() %>"
                                       oninput="updateWeight(); updatePreview(); validateForm();">
                                <div class="weight-display" id="weightValue">
                                    <%= String.format("%.0f%%", criteria.getWeight().multiply(new BigDecimal("100")).doubleValue()) %>
                                </div>
                            </div>
                            <div class="weight-bar">
                                <div class="weight-fill" id="weightBar" 
                                     style="width: <%= criteria.getWeight().multiply(new BigDecimal("100")).doubleValue() %>%;">
                                    <%= String.format("%.1f%%", criteria.getWeight().multiply(new BigDecimal("100")).doubleValue()) %>
                                </div>
                            </div>
                            <div class="help-text">
                                ?ñÔ∏è ?ÑÏ≤¥ ?âÍ??êÏÑú ??Í∏∞Ï???Ï∞®Ï??òÎäî ÎπÑÏ§ë
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ÎØ∏Î¶¨Î≥¥Í∏∞ ?πÏÖò -->
                <div class="preview-section">
                    <h3>?ëÅÔ∏?ÎØ∏Î¶¨Î≥¥Í∏∞</h3>
                    <div class="preview-item">
                        <span class="preview-label">?âÍ?Í∏∞Ï?Î™?</span>
                        <span class="preview-value" id="previewName">?ÖÎ†•?¥Ï£º?∏Ïöî</span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">ÏµúÎ??êÏàò:</span>
                        <span class="preview-value" id="previewMaxScore"><%= criteria.getMaxScore() %>??/span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">Í∞ÄÏ§ëÏπò:</span>
                        <span class="preview-value" id="previewWeight">
                            <%= String.format("%.1f%%", criteria.getWeight().multiply(new BigDecimal("100")).doubleValue()) %>
                        </span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">Í∞ÄÏ§??êÏàò:</span>
                        <span class="preview-value" id="previewWeightedScore">
                            <%= String.format("%.1f??, criteria.getMaxScore() * criteria.getWeight().doubleValue()) %>
                        </span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">Ï§ëÏöî??</span>
                        <span class="preview-value" id="previewImportance">
                            <%= criteria.getWeightImportanceText() %>
                        </span>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary" id="submitBtn">
                        ?íæ <%= isEdit ? "?òÏ†ï?òÍ∏∞" : "?±Î°ù?òÍ∏∞" %>
                    </button>
                    <a href="criteria" class="btn btn-secondary">
                        ?©Ô∏è Ï∑®ÏÜå
                    </a>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Ï¥àÍ∏∞??
        document.addEventListener('DOMContentLoaded', function() {
            updatePreview();
            validateForm();
            updateCharCounters();
        });

        // Î¨∏Ïûê ??Ïπ¥Ïö¥???ÖÎç∞?¥Ìä∏
        function updateCharCounters() {
            const nameInput = document.getElementById('criteriaName');
            const descInput = document.getElementById('description');
            
            const nameCounter = document.getElementById('nameCounter');
            const descCounter = document.getElementById('descCounter');
            
            nameCounter.textContent = nameInput.value.length;
            descCounter.textContent = descInput.value.length;
            
            // Î¨∏Ïûê ?òÏóê ?∞Î•∏ ?âÏÉÅ Î≥ÄÍ≤?
            if (nameInput.value.length > 80) {
                nameCounter.parentElement.className = 'char-counter warning';
            } else if (nameInput.value.length > 95) {
                nameCounter.parentElement.className = 'char-counter error';
            } else {
                nameCounter.parentElement.className = 'char-counter';
            }
            
            if (descInput.value.length > 400) {
                descCounter.parentElement.className = 'char-counter warning';
            } else if (descInput.value.length > 480) {
                descCounter.parentElement.className = 'char-counter error';
            } else {
                descCounter.parentElement.className = 'char-counter';
            }
        }

        // ?úÏÑ± ?ÅÌÉú ?†Í?
        function toggleActive() {
            const toggle = document.getElementById('statusToggle');
            const input = document.getElementById('activeInput');
            const text = document.getElementById('statusText');
            
            const isActive = !toggle.classList.contains('active');
            
            if (isActive) {
                toggle.classList.add('active');
                text.textContent = '?úÏÑ±';
                input.value = 'true';
            } else {
                toggle.classList.remove('active');
                text.textContent = 'ÎπÑÌôú??;
                input.value = 'false';
            }
            
            updatePreview();
        }

        // ÏµúÎ? ?êÏàò ?ÖÎç∞?¥Ìä∏
        function updateMaxScore() {
            const maxScore = document.getElementById('maxScore').value;
            document.getElementById('maxScoreValue').textContent = maxScore + '??;
        }

        // Í∞ÄÏ§ëÏπò ?ÖÎç∞?¥Ìä∏
        function updateWeight() {
            const weight = parseFloat(document.getElementById('weight').value);
            const percentage = weight * 100;
            
            document.getElementById('weightValue').textContent = Math.round(percentage) + '%';
            
            const weightBar = document.getElementById('weightBar');
            weightBar.style.width = percentage + '%';
            weightBar.textContent = percentage.toFixed(1) + '%';
        }

        // ÎØ∏Î¶¨Î≥¥Í∏∞ ?ÖÎç∞?¥Ìä∏
        function updatePreview() {
            const name = document.getElementById('criteriaName').value || '?ÖÎ†•?¥Ï£º?∏Ïöî';
            const maxScore = parseInt(document.getElementById('maxScore').value);
            const weight = parseFloat(document.getElementById('weight').value);
            
            document.getElementById('previewName').textContent = name;
            document.getElementById('previewMaxScore').textContent = maxScore + '??;
            document.getElementById('previewWeight').textContent = (weight * 100).toFixed(1) + '%';
            document.getElementById('previewWeightedScore').textContent = (maxScore * weight).toFixed(1) + '??;
            
            // Ï§ëÏöî??Í≥ÑÏÇ∞
            let importance = '';
            if (weight >= 0.2) importance = '?íÏùå';
            else if (weight >= 0.1) importance = 'Î≥¥ÌÜµ';
            else importance = '??ùå';
            
            document.getElementById('previewImportance').textContent = importance;
            
            updateCharCounters();
        }

        // ??Í≤ÄÏ¶?
        function validateForm() {
            const name = document.getElementById('criteriaName').value.trim();
            const submitBtn = document.getElementById('submitBtn');
            const nameError = document.getElementById('nameError');
            
            let isValid = true;
            
            // ?âÍ?Í∏∞Ï?Î™?Í≤ÄÏ¶?
            if (name.length === 0) {
                nameError.style.display = 'block';
                document.getElementById('criteriaName').classList.add('error');
                isValid = false;
            } else if (name.length < 2) {
                nameError.textContent = '?âÍ?Í∏∞Ï?Î™ÖÏ? ÏµúÏÜå 2???¥ÏÉÅ ?ÖÎ†•?¥Ï£º?∏Ïöî.';
                nameError.style.display = 'block';
                document.getElementById('criteriaName').classList.add('error');
                isValid = false;
            } else {
                nameError.style.display = 'none';
                document.getElementById('criteriaName').classList.remove('error');
                document.getElementById('criteriaName').classList.add('success');
            }
            
            submitBtn.disabled = !isValid;
        }

        // ???úÏ∂ú ?¥Î≤§??
        document.getElementById('criteriaForm').addEventListener('submit', function(e) {
            if (!validateForm()) {
                e.preventDefault();
                alert('?ÖÎ†• ?ïÎ≥¥Î•??ïÏù∏?¥Ï£º?∏Ïöî.');
            }
        });

        // Î©îÏãúÏßÄ ?êÎèô ?®Í?
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                alert.style.opacity = '0';
                setTimeout(() => alert.remove(), 300);
            });
        }, 3000);

        // ?§Î≥¥???®Ï∂ï??
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey || e.metaKey) {
                switch(e.key) {
                    case 's':
                        e.preventDefault();
                        document.getElementById('submitBtn').click();
                        break;
                    case 'Escape':
                        e.preventDefault();
                        if (confirm('?ëÏÑ±Ï§ëÏù∏ ?¥Ïö©???àÏäµ?àÎã§. ?ïÎßê ?òÍ??úÍ≤†?µÎãàÍπ?')) {
                            window.location.href = 'criteria';
                        }
                        break;
                }
            }
        });
    </script>
</body>
</html> 
