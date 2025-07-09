<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.model.*" %>
<%@ page import="java.util.*" %>
<%
    // 세션 검증
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    boolean isEdit = request.getAttribute("id") != null;
    InterviewResult result = (InterviewResult) request.getAttribute("result");
    List<Candidate> candidates = (List<Candidate>) request.getAttribute("candidates");
    List<InterviewQuestion> questions = (List<InterviewQuestion>) request.getAttribute("questions");
    String error = (String) request.getAttribute("errorMessage");
    String selectedCandidateId = request.getParameter("candidateId");
    
    // 선택된 질문 정보
    List<Integer> selectedQuestionIds = (List<Integer>) request.getAttribute("selectedQuestionIds");
    List<String> selectedCategories = (List<String>) request.getAttribute("selectedCategories");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= isEdit ? "인터뷰 결과 수정" : "인터뷰 결과 등록" %> - 채용 관리 시스템</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            background: #f0f0f0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
        }
        
        .container {
            max-width: 800px;
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
        
        .nav-buttons {
            display: flex;
            gap: 8px;
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
        
        .btn-secondary {
            background: #6c757d;
            color: white;
            border-color: #6c757d;
        }
        
        .btn-secondary:hover {
            background: #5c636a;
            border-color: #5c636a;
        }
        
        .main-content {
            background: white;
            border: 1px solid #d0d7de;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .content-header {
            background: #0078d4;
            color: white;
            padding: 15px 25px;
            border-bottom: 1px solid #106ebe;
        }
        
        .content-header h1 {
            margin: 0;
            font-size: 1.3rem;
            font-weight: 600;
        }
        
        .content-body {
            padding: 30px;
        }
        
        .alert {
            padding: 12px 16px;
            border-radius: 3px;
            margin-bottom: 20px;
            border: 1px solid;
        }
        
        .alert-error {
            background: #fecaca;
            color: #dc2626;
            border-color: #fca5a5;
        }
        
        .form-section {
            margin-bottom: 30px;
        }
        
        .form-section h3 {
            font-size: 1.1rem;
            font-weight: 600;
            color: #24292f;
            margin-bottom: 15px;
            padding-bottom: 8px;
            border-bottom: 1px solid #d0d7de;
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group.full-width {
            grid-column: 1 / -1;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 600;
            color: #24292f;
            font-size: 0.9rem;
        }
        
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            font-size: 0.9rem;
            background: white;
            box-sizing: border-box;
        }
        
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            border-color: #0969da;
            outline: none;
            box-shadow: 0 0 0 2px rgba(9, 105, 218, 0.3);
        }
        
        .form-group textarea {
            min-height: 80px;
            resize: vertical;
        }
        
        .score-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 15px;
        }
        
        .score-input {
            text-align: center;
        }
        
        .score-input input {
            text-align: center;
            font-weight: 600;
        }
        
        .form-actions {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #d0d7de;
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }
        
        .required {
            color: #cf222e;
        }
        
        .help-text {
            font-size: 0.8rem;
            color: #656d76;
            margin-top: 4px;
        }
        
        /* 인터뷰 질문 선택 섹션 스타일 */
        .questions-section {
            max-height: 400px;
            overflow-y: auto;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            background: #f6f8fa;
        }
        
        .questions-header {
            padding: 12px 15px;
            background: #f0f6fc;
            border-bottom: 1px solid #d0d7de;
            font-weight: 600;
            color: #24292f;
            position: sticky;
            top: 0;
            z-index: 1;
        }
        
        .question-item {
            padding: 12px 15px;
            border-bottom: 1px solid #d0d7de;
            background: white;
            transition: background-color 0.2s;
        }
        
        .question-item:hover {
            background: #f6f8fa;
        }
        
        .question-item:last-child {
            border-bottom: none;
        }
        
        .question-checkbox {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            cursor: pointer;
        }
        
        .question-checkbox input[type="checkbox"] {
            margin: 0;
            width: auto;
            flex-shrink: 0;
            margin-top: 2px;
        }
        
        .question-content {
            flex: 1;
        }
        
        .question-title {
            font-weight: 600;
            color: #24292f;
            margin-bottom: 4px;
            line-height: 1.4;
        }
        
        .question-meta {
            display: flex;
            gap: 12px;
            margin-bottom: 6px;
        }
        
        .question-badge {
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 500;
        }
        
        .badge-category {
            background: #dbeafe;
            color: #1e40af;
        }
        
        .badge-difficulty {
            background: #fef3c7;
            color: #92400e;
        }
        
        .question-text {
            font-size: 0.85rem;
            color: #656d76;
            line-height: 1.4;
        }
        
        .selected-questions-summary {
            background: #f6fbf9;
            border: 1px solid #1f883d;
            border-radius: 8px;
            padding: 16px;
            margin-top: 16px;
        }
        
        .selected-questions-summary h4 {
            margin: 0 0 12px 0;
            color: #1f883d;
            font-size: 1.1rem;
        }
        
        .selected-total {
            background: white;
            border: 1px solid #0969da;
            border-radius: 6px;
            padding: 8px 12px;
            text-align: center;
        }
        
        .selected-categories {
            margin-top: 12px;
        }
        
        .selected-categories strong {
            color: #24292f;
            font-size: 0.9rem;
        }
        
        .category-summary {
            display: inline-block;
            margin: 2px;
        }
        
        /* 카테고리 필터 토글 버튼 스타일 */
        .category-filters {
            border: 1px solid #d0d7de;
            border-radius: 3px;
            background: #f6f8fa;
            padding: 12px;
        }
        
        .category-toggle-buttons {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }
        
        .category-btn {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 8px 12px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            background: white;
            color: #24292f;
            cursor: pointer;
            font-size: 0.8rem;
            text-decoration: none;
            transition: all 0.2s;
            min-width: 70px;
        }
        
        .category-btn:hover {
            background: #f6f8fa;
            border-color: #8c959f;
        }
        
        .category-btn.active {
            background: #0969da;
            color: white;
            border-color: #0969da;
        }
        
        .category-btn.has-selected {
            background: #d1e7dd !important;
            border-color: #198754 !important;
        }
        
        .category-btn.has-selected .count {
            color: #198754 !important;
        }
        
        .category-btn.has-selected.active {
            background: #198754 !important;
            color: white !important;
            border-color: #198754 !important;
        }
        
        .category-btn.has-selected.active .count {
            color: white !important;
        }
        
        .category-btn .count {
            font-size: 1.1rem;
            font-weight: 700;
            color: #0969da;
            margin-bottom: 2px;
        }
        
        .category-btn.active .count {
            color: white;
        }
        
        .category-btn .label {
            font-size: 0.75rem;
            font-weight: 500;
            text-align: center;
            line-height: 1.2;
        }
    </style>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const isEditMode = <%= isEdit %>;
            
            // 페이지 로드 시 점수 계산 (수정 모드인 경우)
            if (isEditMode) {
                calculateOverallScore();
            }
            
            // 수정 모드인 경우 추가 초기화 (타이밍 보장)
            if (isEditMode) {
                // 즉시 체크된 질문들 확인
                const initialCheckedQuestions = document.querySelectorAll('input[name="selectedQuestions"]:checked');
                
                // 100ms 후 다시 한번 업데이트 (DOM 완전 로드 보장)
                setTimeout(function() {
                    // 현재 체크된 질문들 확인
                    const checkedQuestions = document.querySelectorAll('input[name="selectedQuestions"]:checked');
                    
                    if (checkedQuestions.length > 0) {
                        const summaryDiv = document.getElementById('selectedQuestionsSummary');
                        if (summaryDiv) {
                            summaryDiv.style.display = 'block';
                        }
                    }
                    
                    // 강제로 함수들 재실행
                    updateSelectedQuestions();
                    updateCategorySelection();
                }, 100);
            }
        });
        
        function validateForm() {
            // 점수 유효성 검사
            const scoreInputs = document.querySelectorAll('input[type="number"][min="0"][max="100"]');
            for (let input of scoreInputs) {
                const value = parseFloat(input.value);
                if (input.value && (value < 0 || value > 100)) {
                    alert('점수는 0-100 사이의 값이어야 합니다.');
                    input.focus();
                    return false;
                }
            }
            
            // 최종 제출 전 종합점수 재계산
            calculateOverallScore();
            
            return true;
        }
        
        // 질문 선택 관련 함수들
        function updateSelectedQuestions() {
            const allCheckboxes = document.querySelectorAll('input[name="selectedQuestions"]');
            
            // 🔥 중요: 모든 체크박스 중 선택된 것을 확인 (보이지 않는 것도 포함)
            const checkedCheckboxes = Array.from(allCheckboxes).filter(cb => cb.checked);
            
            const summaryDiv = document.getElementById('selectedQuestionsSummary');
            const totalCountSpan = document.getElementById('totalSelectedCount');
            const categoryDiv = document.getElementById('selectedByCategory');
            
            if (checkedCheckboxes.length > 0) {
                summaryDiv.style.display = 'block';
                
                // 총 개수 업데이트
                totalCountSpan.textContent = checkedCheckboxes.length;
                
                // 카테고리별 선택된 질문 수 계산
                const categoryCount = {};
                
                checkedCheckboxes.forEach((cb, index) => {
                    const questionItem = cb.closest('.question-item');
                    if (questionItem) {
                        const category = questionItem.getAttribute('data-category');
                        
                        // 카테고리 매핑 함수
                        function mapCategoryName(originalCategory) {
                            const mapping = {
                                '기술': '일반 기술',
                                '기술-Java-초급': 'Java 초급',
                                '기술-Java-중급': 'Java 중급', 
                                '기술-Java-고급': 'Java 고급',
                                '기술-Python-초급': 'Python 초급',
                                '기술-Python-중급': 'Python 중급',
                                '기술-Python-고급': 'Python 고급',
                                '인성': '인성 질문',
                                '경험': '경험 질문',
                                '상황': '상황 질문'
                            };
                            
                            return mapping[originalCategory] || originalCategory;
                        }
                        
                        const displayCategory = mapCategoryName(category);
                        
                        // 카운트 증가
                        categoryCount[displayCategory] = (categoryCount[displayCategory] || 0) + 1;
                    }
                });
                
                // 카테고리별 요약 HTML 생성 - 더 명확한 표시
                let categoryHtml = '';
                const categoryNames = Object.keys(categoryCount);
                
                if (categoryNames.length > 0) {
                    // 카테고리별로 정렬하여 표시
                    const sortedCategories = categoryNames.sort();
                    categoryHtml = '<div style="display: flex; flex-wrap: wrap; gap: 8px;">';
                    
                    sortedCategories.forEach(categoryName => {
                        const count = categoryCount[categoryName];
                        categoryHtml += '<span class="category-summary" style="background: #f1f8ff; border: 1px solid #0969da; color: #0969da; padding: 4px 8px; border-radius: 6px; font-size: 0.85rem; font-weight: 500;">';
                        categoryHtml += categoryName + ': ' + count + '개</span>';
                    });
                    
                    categoryHtml += '</div>';
                } else {
                    categoryHtml = '<span style="color: #656d76; font-style: italic;">카테고리 정보 없음</span>';
                }
                
                categoryDiv.innerHTML = categoryHtml;
            } else {
                summaryDiv.style.display = 'none';
                categoryDiv.innerHTML = '';
                totalCountSpan.textContent = '0';
            }
            
            // 카테고리 선택 상태 업데이트
            updateCategorySelection();
        }
        
        // JSP에서 JavaScript로 변수 전달
        const isEditMode = <%= isEdit ? "true" : "false" %>;
        
        // 종합점수 자동 계산 함수
        function calculateOverallScore() {
            const technicalScore = parseFloat(document.getElementById('technicalScore').value) || 0;
            const communicationScore = parseFloat(document.getElementById('communicationScore').value) || 0;
            const problemSolvingScore = parseFloat(document.getElementById('problemSolvingScore').value) || 0;
            const attitudeScore = parseFloat(document.getElementById('attitudeScore').value) || 0;
            
            // 입력된 점수가 있는 항목들만 계산에 포함
            const scores = [];
            if (technicalScore > 0) scores.push(technicalScore);
            if (communicationScore > 0) scores.push(communicationScore);
            if (problemSolvingScore > 0) scores.push(problemSolvingScore);
            if (attitudeScore > 0) scores.push(attitudeScore);
            
            let overallScore = 0;
            if (scores.length > 0) {
                // 평균 계산
                const sum = scores.reduce((total, score) => total + score, 0);
                overallScore = sum / scores.length;
                
                // 소수점 첫째자리까지 반올림
                overallScore = Math.round(overallScore * 10) / 10;
            }
            
            // 종합점수 필드에 자동 입력
            document.getElementById('overallScore').value = overallScore > 0 ? overallScore : '';
            
            // 종합점수 필드 스타일 업데이트 (자동계산됨을 표시)
            const overallScoreInput = document.getElementById('overallScore');
            if (overallScore > 0) {
                overallScoreInput.style.backgroundColor = '#f0f9ff';
                overallScoreInput.style.borderColor = '#0078d4';
            } else {
                overallScoreInput.style.backgroundColor = '';
                overallScoreInput.style.borderColor = '';
            }
        }
        
        function toggleAllQuestions() {
            const allCheckboxes = document.querySelectorAll('input[name="selectedQuestions"]');
            const visibleCheckboxes = Array.from(allCheckboxes).filter(cb => {
                const questionItem = cb.closest('.question-item');
                return questionItem && questionItem.style.display !== 'none';
            });
            const allChecked = visibleCheckboxes.every(cb => cb.checked);
            
            visibleCheckboxes.forEach(cb => {
                cb.checked = !allChecked;
            });
            
            updateSelectedQuestions();
        }
        
        function clearAllQuestions() {
            const allCheckboxes = document.querySelectorAll('input[name="selectedQuestions"]');
            const visibleCheckboxes = Array.from(allCheckboxes).filter(cb => {
                const questionItem = cb.closest('.question-item');
                return questionItem && questionItem.style.display !== 'none';
            });
            visibleCheckboxes.forEach(cb => {
                cb.checked = false;
            });
            updateSelectedQuestions();
        }
        
        // 카테고리 필터링 함수
        function filterByCategory(category) {
            // 모든 카테고리 버튼에서 active 클래스 제거
            document.querySelectorAll('.category-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            
            // 클릭된 버튼에 active 클래스 추가
            const activeButton = document.querySelector('[data-category="' + category + '"]');
            if (activeButton) {
                activeButton.classList.add('active');
            }
            
            // 질문 아이템들 필터링
            const questionItems = document.querySelectorAll('.question-item[data-category]');
            let visibleCount = 0;
            
            questionItems.forEach(item => {
                const itemCategory = item.getAttribute('data-category');
                
                let shouldShow = false;
                
                if (category === 'all') {
                    shouldShow = true;
                } else if (category === '일반 기술' && itemCategory === '기술') {
                    shouldShow = true;
                } else if (itemCategory === category) {
                    shouldShow = true;
                }
                
                if (shouldShow) {
                    item.style.display = '';  // 기본 display 값으로 복원
                    visibleCount++;
                } else {
                    item.style.display = 'none';
                }
            });
            
            // 카테고리 이름 표시 업데이트
            const categoryDisplay = document.getElementById('categoryDisplay');
            if (categoryDisplay) {
                let categoryText = '';
                if (category === 'all') {
                    categoryText = '';
                } else if (category === '일반 기술') {
                    categoryText = '- 일반 기술 ';
                } else if (category === '기술-Java-초급') {
                    categoryText = '- Java 초급 ';
                } else if (category === '기술-Java-중급') {
                    categoryText = '- Java 중급 ';
                } else if (category === '기술-Java-고급') {
                    categoryText = '- Java 고급 ';
                } else if (category === '기술-Python-초급') {
                    categoryText = '- Python 초급 ';
                } else if (category === '기술-Python-중급') {
                    categoryText = '- Python 중급 ';
                } else if (category === '기술-Python-고급') {
                    categoryText = '- Python 고급 ';
                } else if (category === '인성') {
                    categoryText = '- 인성 질문 ';
                } else if (category === '경험') {
                    categoryText = '- 경험 질문 ';
                } else if (category === '상황') {
                    categoryText = '- 상황 질문 ';
                } else {
                    categoryText = '- ' + category + ' ';
                }
                categoryDisplay.textContent = categoryText;
            }
            
            // 질문 개수 업데이트
            const countDisplay = document.getElementById('questionCountDisplay');
            if (countDisplay) {
                countDisplay.textContent = visibleCount;
            }
            
            // 선택된 질문 수 업데이트
            updateSelectedQuestions();
        }
        
        // 페이지 로드 시 카테고리별 실제 개수 계산
        function updateCategoryCounts() {
            const questionItems = document.querySelectorAll('.question-item[data-category]');
            const counts = {};
            
            // 전체 개수 계산
            counts['all'] = questionItems.length;
            
            // 각 카테고리별 개수 계산
            questionItems.forEach(item => {
                const category = item.getAttribute('data-category');
                if (category === '기술') {
                    counts['일반 기술'] = (counts['일반 기술'] || 0) + 1;
                } else {
                    counts[category] = (counts[category] || 0) + 1;
                }
            });
            
            // 버튼들의 개수 업데이트
            Object.keys(counts).forEach(category => {
                const button = document.querySelector('[data-category="' + category + '"]');
                if (button) {
                    const countSpan = button.querySelector('.count');
                    if (countSpan) {
                        countSpan.textContent = counts[category] || 0;
                    }
                }
            });
        }
        
        // 선택된 질문이 있는 카테고리를 녹색으로 표시 (전체 선택된 질문 기준)
        function updateCategorySelection() {
            // 🔥 중요: 모든 선택된 질문을 확인 (보이지 않는 것도 포함)
            const checkedQuestions = document.querySelectorAll('input[name="selectedQuestions"]:checked');
            const selectedCategories = new Set();
            
            checkedQuestions.forEach((checkbox, index) => {
                const questionItem = checkbox.closest('.question-item');
                if (questionItem) {
                    const category = questionItem.getAttribute('data-category');
                    
                    // 카테고리를 그대로 추가 (빈 문자열 체크 추가)
                    if (category && category.trim() !== '') {
                        selectedCategories.add(category);
                    } else {
                        console.warn('빈 카테고리 발견:', category);
                    }
                }
            });
            
            // 모든 카테고리 버튼에서 has-selected 클래스 제거
            document.querySelectorAll('.category-btn').forEach(btn => {
                btn.classList.remove('has-selected');
            });
            
            // 선택된 카테고리 버튼에 has-selected 클래스 추가
            selectedCategories.forEach((category, index) => {
                // 카테고리별 매핑으로 버튼 찾기
                let buttonCategory = category;
                if (category === '기술') {
                    buttonCategory = '일반 기술';
                }
                
                const button = document.querySelector('[data-category="' + buttonCategory + '"]');
                if (button) {
                    button.classList.add('has-selected');
                } else {
                    console.warn('카테고리 "' + buttonCategory + '"의 버튼을 찾을 수 없음');
                }
            });
            
            // 전체 버튼도 선택된 질문이 있으면 has-selected 클래스 추가
            if (checkedQuestions.length > 0) {
                const allButton = document.querySelector('[data-category="all"]');
                if (allButton) {
                    allButton.classList.add('has-selected');
                }
            }
        }
    </script>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h2>📊 <%= isEdit ? "인터뷰 결과 수정" : "인터뷰 결과 등록" %></h2>
            <div class="nav-buttons">
                <a href="${pageContext.request.contextPath}/main.jsp" class="btn">🏠 홈</a>
                <a href="${pageContext.request.contextPath}/results" class="btn">📊 결과관리</a>
                <a href="${pageContext.request.contextPath}/candidates" class="btn">👥 지원자</a>
                <a href="${pageContext.request.contextPath}/interview/list" class="btn">📅 일정관리</a>
            </div>
        </div>
        
        <div class="main-content">
            <div class="content-header">
                <h1><%= isEdit ? "인터뷰 결과 수정" : "새로운 인터뷰 결과 등록" %></h1>
            </div>
            <div class="content-body">
                <% if (error != null && !error.isEmpty()) { %>
                    <div class="alert alert-error"><%= error %></div>
                <% } %>
                
                <form method="post" action="${pageContext.request.contextPath}/<%= isEdit ? "results/edit" : "results/add" %>" onsubmit="return validateForm()">
                    <%-- [DEBUG] from 파라미터 값: <%= request.getParameter("from") %> --%>
                    <% if (isEdit) { %>
                        <input type="hidden" name="id" value="<%= result.getId() %>">
                    <% } %>
                    <%-- from 파라미터 전달 --%>
                    <% String from = request.getParameter("from"); if (from != null && !from.isEmpty()) { %>
                        <input type="hidden" name="from" value="<%= from %>">
                    <% } %>
                    <%-- scheduleId 파라미터 전달 --%>
                    <% String scheduleId = request.getParameter("scheduleId"); if (scheduleId != null && !scheduleId.isEmpty()) { %>
                        <input type="hidden" name="scheduleId" value="<%= scheduleId %>">
                    <% } %>
                    
                    <!-- 기본 정보 -->
                    <div class="form-section">
                        <h3>📋 기본 정보</h3>
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="candidateId">지원자 <span class="required">*</span></label>
                                <select name="candidateId" id="candidateId" required>
                                    <option value="">지원자 선택</option>
                                    <% if (candidates != null) {
                                        for (Candidate candidate : candidates) {
                                            boolean selected = false;
                                            if (isEdit && result.getCandidateId() == candidate.getId()) {
                                                selected = true;
                                            } else if (selectedCandidateId != null && selectedCandidateId.equals(String.valueOf(candidate.getId()))) {
                                                selected = true;
                                            } else if (request.getAttribute("schedule") != null) {
                                                com.example.model.InterviewSchedule schedule = (com.example.model.InterviewSchedule)request.getAttribute("schedule");
                                                if (schedule.getCandidateId() == candidate.getId()) selected = true;
                                            }
                                    %>
                                        <option value="<%= candidate.getId() %>" <%= selected ? "selected" : "" %>>
                                            <%= candidate.getName() %> (<%= candidate.getEmail() %>)
                                        </option>
                                    <% }
                                    } %>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label for="interviewerName">면접관 <span class="required">*</span></label>
                                <input type="text" name="interviewerName" id="interviewerName" 
                                       value="<%= isEdit ? result.getInterviewerName() : (request.getAttribute("schedule") != null ? ((com.example.model.InterviewSchedule)request.getAttribute("schedule")).getInterviewerName() : "") %>" 
                                       placeholder="면접관 이름" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="interviewDate">면접 일시 <span class="required">*</span></label>
                                <input type="datetime-local" name="interviewDate" id="interviewDate" 
                                       value="<%= isEdit ? result.getInterviewDateForInput() : (request.getAttribute("schedule") != null ? ((com.example.model.InterviewSchedule)request.getAttribute("schedule")).getInterviewDateFormatted() + "T" + ((com.example.model.InterviewSchedule)request.getAttribute("schedule")).getInterviewTimeFormatted() : "") %>" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="interviewType">면접 유형 <span class="required">*</span></label>
                                <select name="interviewType" id="interviewType" required>
                                    <option value="">면접 유형 선택</option>
                                    <option value="1차 면접" <%= (isEdit && "1차 면접".equals(result.getInterviewType())) || (request.getAttribute("schedule") != null && "1차 면접".equals(((com.example.model.InterviewSchedule)request.getAttribute("schedule")).getInterviewType())) ? "selected" : "" %>>1차 면접</option>
                                    <option value="2차 면접" <%= (isEdit && "2차 면접".equals(result.getInterviewType())) || (request.getAttribute("schedule") != null && "2차 면접".equals(((com.example.model.InterviewSchedule)request.getAttribute("schedule")).getInterviewType())) ? "selected" : "" %>>2차 면접</option>
                                    <option value="최종 면접" <%= (isEdit && "최종 면접".equals(result.getInterviewType())) || (request.getAttribute("schedule") != null && "최종 면접".equals(((com.example.model.InterviewSchedule)request.getAttribute("schedule")).getInterviewType())) ? "selected" : "" %>>최종 면접</option>
                                    <option value="기술 면접" <%= (isEdit && "기술 면접".equals(result.getInterviewType())) || (request.getAttribute("schedule") != null && "기술 면접".equals(((com.example.model.InterviewSchedule)request.getAttribute("schedule")).getInterviewType())) ? "selected" : "" %>>기술 면접</option>
                                    <option value="인성 면접" <%= (isEdit && "인성 면접".equals(result.getInterviewType())) || (request.getAttribute("schedule") != null && "인성 면접".equals(((com.example.model.InterviewSchedule)request.getAttribute("schedule")).getInterviewType())) ? "selected" : "" %>>인성 면접</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 인터뷰 질문 선택 -->
                    <div class="form-section">
                        <h3>❓ 인터뷰 질문 선택</h3>
                        

                        
                        <div class="form-group full-width">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
                                <div>
                                    <label>면접에서 사용할 질문을 선택하세요</label>
                                    <div class="help-text">질문을 선택하면 면접 진행 시 체크박스로 질문 완료 여부를 확인할 수 있습니다.</div>
                                </div>
                                <div style="display: flex; gap: 8px;">
                                    <button type="button" class="btn" onclick="toggleAllQuestions()">전체선택/해제</button>
                                    <button type="button" class="btn" onclick="clearAllQuestions()">선택초기화</button>
                                </div>
                            </div>
                            
                            <!-- 카테고리 필터 토글 버튼 -->
                            <div class="category-filters" style="margin-bottom: 15px;">
                                <div class="category-toggle-buttons">
                                    <button type="button" class="category-btn active" data-category="all" onclick="filterByCategory('all')">
                                        <span class="count">39</span>
                                        <span class="label">전체 활성 질문</span>
                                    </button>
                                    <button type="button" class="category-btn" data-category="일반 기술" onclick="filterByCategory('일반 기술')">
                                        <span class="count">11</span>
                                        <span class="label">일반 기술</span>
                                    </button>
                                    <button type="button" class="category-btn" data-category="기술-Java-초급" onclick="filterByCategory('기술-Java-초급')">
                                        <span class="count">4</span>
                                        <span class="label">Java 초급</span>
                                    </button>
                                    <button type="button" class="category-btn" data-category="기술-Java-중급" onclick="filterByCategory('기술-Java-중급')">
                                        <span class="count">3</span>
                                        <span class="label">Java 중급</span>
                                    </button>
                                    <button type="button" class="category-btn" data-category="기술-Java-고급" onclick="filterByCategory('기술-Java-고급')">
                                        <span class="count">3</span>
                                        <span class="label">Java 고급</span>
                                    </button>
                                    <button type="button" class="category-btn" data-category="기술-Python-초급" onclick="filterByCategory('기술-Python-초급')">
                                        <span class="count">3</span>
                                        <span class="label">Python 초급</span>
                                    </button>
                                    <button type="button" class="category-btn" data-category="기술-Python-중급" onclick="filterByCategory('기술-Python-중급')">
                                        <span class="count">3</span>
                                        <span class="label">Python 중급</span>
                                    </button>
                                    <button type="button" class="category-btn" data-category="기술-Python-고급" onclick="filterByCategory('기술-Python-고급')">
                                        <span class="count">3</span>
                                        <span class="label">Python 고급</span>
                                    </button>
                                    <button type="button" class="category-btn" data-category="인성" onclick="filterByCategory('인성')">
                                        <span class="count">3</span>
                                        <span class="label">인성 질문</span>
                                    </button>
                                    <button type="button" class="category-btn" data-category="경험" onclick="filterByCategory('경험')">
                                        <span class="count">4</span>
                                        <span class="label">경험 질문</span>
                                    </button>
                                    <button type="button" class="category-btn" data-category="상황" onclick="filterByCategory('상황')">
                                        <span class="count">2</span>
                                        <span class="label">상황 질문</span>
                                    </button>
                                </div>
                            </div>
                            
                            <div class="questions-section">
                                <div class="questions-header">
                                    💡 인터뷰 질문 목록 <span id="categoryDisplay"></span>(<span id="questionCountDisplay"><%= questions != null ? questions.size() : 0 %></span>개)
                                </div>
                                
                                <% if (questions != null && !questions.isEmpty()) { %>
                                    <% for (InterviewQuestion question : questions) { 
                                        boolean isQuestionSelected = selectedQuestionIds != null && selectedQuestionIds.contains(question.getId());
                                    %>
                                        <div class="question-item" data-category="<%= question.getCategory() %>">
                                            <label class="question-checkbox">
                                                <input type="checkbox" name="selectedQuestions" value="<%= question.getId() %>" 
                                                       <%= isQuestionSelected ? "checked" : "" %> onchange="updateSelectedQuestions()">
                                                <div class="question-content">
                                                    <div class="question-title"><%= question.getQuestionText() %></div>
                                                    <div class="question-meta">
                                                        <span class="question-badge badge-category"><%= question.getCategory() %></span>
                                                        <span class="question-badge badge-difficulty"><%= question.getDifficultyText() %></span>
                                                    </div>
                                                    <div class="question-text"><%= question.getQuestionText() %></div>
                                                </div>
                                            </label>
                                        </div>
                                    <% } %>
                                <% } else { %>
                                    <div class="question-item">
                                        <div style="text-align: center; color: #656d76; padding: 20px;">
                                            등록된 인터뷰 질문이 없습니다.<br>
                                            <a href="${pageContext.request.contextPath}/questions?action=new" style="color: #0969da;">새 질문 등록하기</a>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                            
                            <div id="selectedQuestionsSummary" class="selected-questions-summary" style="display: none;">
                                <h4>✅ 선택된 질문</h4>
                                <div class="selected-total" id="selectedTotal" style="font-size: 1.1rem; font-weight: 600; margin-bottom: 12px; color: #0969da;">
                                    총 <span id="totalSelectedCount">0</span>개 질문 선택됨
                                </div>
                                <div class="selected-categories" id="selectedCategories" style="margin-bottom: 8px;">
                                    <strong>카테고리별 선택 현황:</strong>
                                    <div id="selectedByCategory" class="selected-by-category" style="margin-top: 8px;"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 평가 점수 -->
                    <div class="form-section">
                        <h3>📊 평가 점수</h3>
                        <div class="score-grid">
                            <div class="form-group score-input">
                                <label for="technicalScore">기술 역량</label>
                                <input type="number" name="technicalScore" id="technicalScore" 
                                       min="0" max="100" step="0.1"
                                       value="<%= isEdit && result.getTechnicalScore() != null ? result.getTechnicalScore() : "" %>" 
                                       placeholder="0-100">
                                <div class="help-text">기술적 능력</div>
                            </div>
                            
                            <div class="form-group score-input">
                                <label for="communicationScore">의사소통</label>
                                <input type="number" name="communicationScore" id="communicationScore" 
                                       min="0" max="100" step="0.1"
                                       value="<%= isEdit && result.getCommunicationScore() != null ? result.getCommunicationScore() : "" %>" 
                                       placeholder="0-100">
                                <div class="help-text">소통 능력</div>
                            </div>
                            
                            <div class="form-group score-input">
                                <label for="problemSolvingScore">문제해결</label>
                                <input type="number" name="problemSolvingScore" id="problemSolvingScore" 
                                       min="0" max="100" step="0.1"
                                       value="<%= isEdit && result.getProblemSolvingScore() != null ? result.getProblemSolvingScore() : "" %>" 
                                       placeholder="0-100">
                                <div class="help-text">문제 해결력</div>
                            </div>
                            
                            <div class="form-group score-input">
                                <label for="attitudeScore">업무 태도</label>
                                <input type="number" name="attitudeScore" id="attitudeScore" 
                                       min="0" max="100" step="0.1"
                                       value="<%= isEdit && result.getAttitudeScore() != null ? result.getAttitudeScore() : "" %>" 
                                       placeholder="0-100">
                                <div class="help-text">근무 태도</div>
                            </div>
                            
                            <div class="form-group score-input">
                                <label for="overallScore">종합 점수 🤖</label>
                                <input type="number" name="overallScore" id="overallScore" 
                                       min="0" max="100" step="0.1"
                                       value="<%= isEdit && result.getOverallScore() != null ? result.getOverallScore() : "" %>" 
                                       placeholder="자동계산됨" readonly>
                                <div class="help-text">4개 항목 평균 (자동계산)</div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 평가 내용 -->
                    <div class="form-section">
                        <h3>📝 평가 내용</h3>
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="strengths">강점</label>
                                <textarea name="strengths" id="strengths" 
                                          placeholder="지원자의 강점을 기술해주세요"><%= isEdit && result.getStrengths() != null ? result.getStrengths() : "" %></textarea>
                            </div>
                            
                            <div class="form-group">
                                <label for="weaknesses">약점</label>
                                <textarea name="weaknesses" id="weaknesses" 
                                          placeholder="개선이 필요한 부분을 기술해주세요"><%= isEdit && result.getWeaknesses() != null ? result.getWeaknesses() : "" %></textarea>
                            </div>
                            
                            <div class="form-group full-width">
                                <label for="detailedFeedback">상세 피드백</label>
                                <textarea name="detailedFeedback" id="detailedFeedback" 
                                          placeholder="면접에 대한 상세한 피드백을 작성해주세요"><%= isEdit && result.getDetailedFeedback() != null ? result.getDetailedFeedback() : "" %></textarea>
                            </div>
                            
                            <div class="form-group full-width">
                                <label for="improvementSuggestions">개선 제안사항</label>
                                <textarea name="improvementSuggestions" id="improvementSuggestions" 
                                          placeholder="향후 개선할 수 있는 방향을 제안해주세요"><%= isEdit && result.getImprovementSuggestions() != null ? result.getImprovementSuggestions() : "" %></textarea>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 결과 및 다음 단계 -->
                    <div class="form-section">
                        <h3>✅ 결과 및 다음 단계</h3>
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="resultStatus">결과 상태 <span class="required">*</span></label>
                                <select name="resultStatus" id="resultStatus" required>
                                    <option value="">상태 선택</option>
                                    <option value="pending" <%= isEdit && "pending".equals(result.getResultStatus()) ? "selected" : "" %>>검토중</option>
                                    <option value="pass" <%= isEdit && "pass".equals(result.getResultStatus()) ? "selected" : "" %>>합격</option>
                                    <option value="fail" <%= isEdit && "fail".equals(result.getResultStatus()) ? "selected" : "" %>>불합격</option>
                                    <option value="hold" <%= isEdit && "hold".equals(result.getResultStatus()) ? "selected" : "" %>>보류</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label for="hireRecommendation">채용 추천</label>
                                <select name="hireRecommendation" id="hireRecommendation">
                                    <option value="">추천 여부 선택</option>
                                    <option value="yes" <%= isEdit && "yes".equals(result.getHireRecommendation()) ? "selected" : "" %>>추천</option>
                                    <option value="no" <%= isEdit && "no".equals(result.getHireRecommendation()) ? "selected" : "" %>>비추천</option>
                                </select>
                            </div>
                            
                            <div class="form-group full-width">
                                <label for="nextStep">다음 단계</label>
                                <textarea name="nextStep" id="nextStep" 
                                          placeholder="다음 진행해야 할 단계나 절차를 기술해주세요"><%= isEdit && result.getNextStep() != null ? result.getNextStep() : "" %></textarea>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 폼 액션 버튼 -->
                    <div class="form-actions">
                        <a href="results" class="btn btn-secondary">취소</a>
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "수정 완료" : "등록 완료" %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html> 