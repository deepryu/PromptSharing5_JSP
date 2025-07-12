<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.model.EvaluationCriteria" %>
<%@ page import="java.math.BigDecimal" %>
<%
    // ?�션 검�?- username ?�성 ?�용
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    EvaluationCriteria criteria = (EvaluationCriteria) request.getAttribute("criteria");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    boolean isEdit = criteria != null && criteria.getId() != null;
    String pageTitle = isEdit ? "?��?기�? ?�정" : "?��?기�? ?�록";
    
    // 기본�??�정
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
            background: white;
            color: #24292f;
            border: 1px solid #d0d7de;
            padding: 10px 20px;
            border-radius: 6px;
            font-size: 16px;
            font-weight: 500;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            line-height: 1.2;
            min-width: 80px;
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
            <h1>?�️ <%= pageTitle %></h1>
            <p>체계?�인 면접 ?��?�??�한 ?��? 기�????�정?�세??/p>
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

        <div class="form-content">
            <form id="criteriaForm" method="post" action="criteria">
                <% if (isEdit) { %>
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<%= criteria.getId() %>">
                <% } else { %>
                    <input type="hidden" name="action" value="create">
                <% } %>

                <div class="form-layout">
                    <!-- 기본 ?�보 ?�션 -->
                    <div class="form-section">
                        <h3>?�� 기본 ?�보</h3>
                        
                        <div class="form-group">
                            <label for="criteriaName">?��?기�?�?*</label>
                            <input type="text" id="criteriaName" name="criteriaName" 
                                   class="form-control" required maxlength="100"
                                   value="<%= criteria.getCriteriaName() != null ? criteria.getCriteriaName() : "" %>"
                                   placeholder="?? 기술 ??��, 커�??��??�션 ?�력"
                                   oninput="updatePreview(); validateForm();">
                            <div class="char-counter">
                                <span id="nameCounter">0</span>/100
                            </div>
                            <div class="validation-message" id="nameError">
                                ?��?기�?명을 ?�력?�주?�요.
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="description">?�명</label>
                            <textarea id="description" name="description" 
                                      class="form-control" maxlength="500"
                                      placeholder="?��?기�????�???�세 ?�명???�력?�세??.."
                                      oninput="updatePreview(); validateForm();"><%= criteria.getDescription() != null ? criteria.getDescription() : "" %></textarea>
                            <div class="char-counter">
                                <span id="descCounter">0</span>/500
                            </div>
                            <div class="help-text">
                                ?�� ?��??��? ?�해?�기 ?�도�?구체?�으�??�성?�주?�요
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label>?�성 ?�태</label>
                            <div style="display: flex; align-items: center; gap: 15px;">
                                <div class="toggle-switch <%= criteria.isActive() ? "active" : "" %>" 
                                     onclick="toggleActive()" id="statusToggle">
                                    <div class="toggle-slider"></div>
                                </div>
                                <span id="statusText"><%= criteria.isActive() ? "?�성" : "비활?? %></span>
                                <input type="hidden" name="active" id="activeInput" 
                                       value="<%= criteria.isActive() %>">
                            </div>
                            <div class="help-text">
                                ?�� ?�성 ?�태???��?기�?�??�제 ?��????�용?�니??
                            </div>
                        </div>
                    </div>

                    <!-- ?�수 �?가중치 ?�션 -->
                    <div class="form-section">
                        <h3>?�� ?�수 �?가중치</h3>
                        
                        <div class="form-group">
                            <label for="maxScore">최�? ?�수 *</label>
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
                                ?�� ???��?기�???최�? ?�득 가???�수
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="weight">가중치 *</label>
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
                                ?�️ ?�체 ?��??�서 ??기�???차�??�는 비중
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 미리보기 ?�션 -->
                <div class="preview-section">
                    <h3>?���?미리보기</h3>
                    <div class="preview-item">
                        <span class="preview-label">?��?기�?�?</span>
                        <span class="preview-value" id="previewName">?�력?�주?�요</span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">최�??�수:</span>
                        <span class="preview-value" id="previewMaxScore"><%= criteria.getMaxScore() %>??/span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">가중치:</span>
                        <span class="preview-value" id="previewWeight">
                            <%= String.format("%.1f%%", criteria.getWeight().multiply(new BigDecimal("100")).doubleValue()) %>
                        </span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">가�??�수:</span>
                        <span class="preview-value" id="previewWeightedScore">
                            <%= String.format("%.1f??, criteria.getMaxScore() * criteria.getWeight().doubleValue()) %>
                        </span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">중요??</span>
                        <span class="preview-value" id="previewImportance">
                            <%= criteria.getWeightImportanceText() %>
                        </span>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary" id="submitBtn">
                        ?�� <%= isEdit ? "?�정?�기" : "?�록?�기" %>
                    </button>
                    <a href="criteria" class="btn btn-secondary">
                        ?�️ 취소
                    </a>
                </div>
            </form>
        </div>
    </div>

    <script>
        // 초기??
        document.addEventListener('DOMContentLoaded', function() {
            updatePreview();
            validateForm();
            updateCharCounters();
        });

        // 문자 ??카운???�데?�트
        function updateCharCounters() {
            const nameInput = document.getElementById('criteriaName');
            const descInput = document.getElementById('description');
            
            const nameCounter = document.getElementById('nameCounter');
            const descCounter = document.getElementById('descCounter');
            
            nameCounter.textContent = nameInput.value.length;
            descCounter.textContent = descInput.value.length;
            
            // 문자 ?�에 ?�른 ?�상 변�?
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

        // ?�성 ?�태 ?��?
        function toggleActive() {
            const toggle = document.getElementById('statusToggle');
            const input = document.getElementById('activeInput');
            const text = document.getElementById('statusText');
            
            const isActive = !toggle.classList.contains('active');
            
            if (isActive) {
                toggle.classList.add('active');
                text.textContent = '?�성';
                input.value = 'true';
            } else {
                toggle.classList.remove('active');
                text.textContent = '비활??;
                input.value = 'false';
            }
            
            updatePreview();
        }

        // 최�? ?�수 ?�데?�트
        function updateMaxScore() {
            const maxScore = document.getElementById('maxScore').value;
            document.getElementById('maxScoreValue').textContent = maxScore + '??;
        }

        // 가중치 ?�데?�트
        function updateWeight() {
            const weight = parseFloat(document.getElementById('weight').value);
            const percentage = weight * 100;
            
            document.getElementById('weightValue').textContent = Math.round(percentage) + '%';
            
            const weightBar = document.getElementById('weightBar');
            weightBar.style.width = percentage + '%';
            weightBar.textContent = percentage.toFixed(1) + '%';
        }

        // 미리보기 ?�데?�트
        function updatePreview() {
            const name = document.getElementById('criteriaName').value || '?�력?�주?�요';
            const maxScore = parseInt(document.getElementById('maxScore').value);
            const weight = parseFloat(document.getElementById('weight').value);
            
            document.getElementById('previewName').textContent = name;
            document.getElementById('previewMaxScore').textContent = maxScore + '??;
            document.getElementById('previewWeight').textContent = (weight * 100).toFixed(1) + '%';
            document.getElementById('previewWeightedScore').textContent = (maxScore * weight).toFixed(1) + '??;
            
            // 중요??계산
            let importance = '';
            if (weight >= 0.2) importance = '?�음';
            else if (weight >= 0.1) importance = '보통';
            else importance = '??��';
            
            document.getElementById('previewImportance').textContent = importance;
            
            updateCharCounters();
        }

        // ??검�?
        function validateForm() {
            const name = document.getElementById('criteriaName').value.trim();
            const submitBtn = document.getElementById('submitBtn');
            const nameError = document.getElementById('nameError');
            
            let isValid = true;
            
            // ?��?기�?�?검�?
            if (name.length === 0) {
                nameError.style.display = 'block';
                document.getElementById('criteriaName').classList.add('error');
                isValid = false;
            } else if (name.length < 2) {
                nameError.textContent = '?��?기�?명�? 최소 2???�상 ?�력?�주?�요.';
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

        // ???�출 ?�벤??
        document.getElementById('criteriaForm').addEventListener('submit', function(e) {
            if (!validateForm()) {
                e.preventDefault();
                alert('?�력 ?�보�??�인?�주?�요.');
            }
        });

        // 메시지 ?�동 ?��?
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                alert.style.opacity = '0';
                setTimeout(() => alert.remove(), 300);
            });
        }, 3000);

        // ?�보???�축??
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey || e.metaKey) {
                switch(e.key) {
                    case 's':
                        e.preventDefault();
                        document.getElementById('submitBtn').click();
                        break;
                    case 'Escape':
                        e.preventDefault();
                        if (confirm('?�성중인 ?�용???�습?�다. ?�말 ?��??�겠?�니�?')) {
                            window.location.href = 'criteria';
                        }
                        break;
                }
            }
        });
    </script>
</body>
</html> 
