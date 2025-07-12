<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>인터뷰 질문 관리 - 채용 관리 시스템 V1.0</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/common.css">
    <style>
        /* 인터뷰 질문 페이지 전용 스타일 */
        
        /* 질문 목록 테이블 스타일 */
        .question-table {
            background: white;
            border: 1px solid #d0d7de;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .table-header {
            background: #f6f8fa;
            border-bottom: 1px solid #d0d7de;
            padding: 12px 20px;
            font-weight: 600;
            color: #24292f;
            font-size: 0.9rem;
        }
        
        .question-item {
            padding: 15px 20px;
            border-bottom: 1px solid #d0d7de;
            transition: background-color 0.2s;
        }
        
        .question-item:last-child {
            border-bottom: none;
        }
        
        .question-item:hover {
            background: #f6f8fa;
        }
        
        .question-content {
            display: grid;
            grid-template-columns: 1fr auto auto auto auto;
            gap: 15px;
            align-items: center;
        }
        
        .question-text {
            font-weight: 500;
            color: #24292f;
            font-size: 0.95rem;
        }
        
        .question-meta {
            font-size: 0.8rem;
            color: #656d76;
            margin-top: 5px;
        }
        
        .category-badge {
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: 500;
            border: 1px solid;
        }
        
        .category-tech { 
            background: #dbeafe; 
            color: #1e40af; 
            border-color: #93c5fd; 
        }
        
        .category-personality { 
            background: #f3e8ff; 
            color: #7c3aed; 
            border-color: #c4b5fd; 
        }
        
        .category-experience { 
            background: #dcfce7; 
            color: #16a34a; 
            border-color: #86efac; 
        }
        
        .category-situation { 
            background: #fed7aa; 
            color: #ea580c; 
            border-color: #fdba74; 
        }
        
        .category-default { 
            background: #f6f8fa; 
            color: #656d76; 
            border-color: #d0d7de; 
        }
        
        .difficulty-stars {
            color: #fb8500;
            font-size: 1em;
        }
        
        .status-badge {
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: 500;
            border: 1px solid;
        }
        
        .status-active { 
            background: #dcfce7; 
            color: #16a34a; 
            border-color: #86efac; 
        }
        
        .status-inactive { 
            background: #fee2e2; 
            color: #dc2626; 
            border-color: #fca5a5; 
        }
        
        .action-buttons {
            display: flex;
            gap: 4px;
        }
        
        .btn-icon {
            width: 28px;
            height: 28px;
            border-radius: 3px;
            border: 1px solid #d0d7de;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            transition: all 0.2s;
            background: white;
        }
        
        .btn-view { 
            color: #0969da; 
            border-color: #0969da; 
        }
        
        .btn-edit { 
            color: #1a7f37; 
            border-color: #1a7f37; 
        }
        
        .btn-delete { 
            color: #cf222e; 
            border-color: #cf222e; 
        }
        
        .btn-toggle { 
            color: #9a6700; 
            border-color: #9a6700; 
        }
        
        .btn-icon:hover {
            background: #f6f8fa;
            transform: scale(1.05);
        }
        
        .no-questions {
            text-align: center;
            padding: 60px 20px;
            color: #656d76;
        }
        
        .no-questions h3 {
            color: #24292f;
            margin-bottom: 10px;
        }
        
        .search-highlight {
            background: #fff8c4;
            padding: 1px 3px;
            border-radius: 2px;
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
            background: #6e7681;
            color: white;
            border-color: #6e7681;
        }
        
        .btn-secondary:hover {
            background: #656d76;
            border-color: #656d76;
        }
        
        .btn-light {
            background: #f6f8fa;
            color: #24292f;
            border-color: #d0d7de;
        }
        
        .btn-light:hover {
            background: #f3f4f6;
            border-color: #8c959f;
        }
        
        .alert {
            padding: 12px 16px;
            margin: 10px 0;
            border-radius: 3px;
            border: 1px solid;
        }
        
        .alert-info {
            background: #dbeafe;
            color: #1e40af;
            border-color: #93c5fd;
        }
        
        .alert-success {
            background: #dcfce7;
            color: #16a34a;
            border-color: #86efac;
        }
        
        .alert-danger {
            background: #fee2e2;
            color: #dc2626;
            border-color: #fca5a5;
        }
        
        input[type="text"], select {
            padding: 6px 8px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            font-size: 0.85rem;
            background: white;
        }
        
        /* 질문 카테고리 배지 및 난이도 스타일 */
        .category-badge {
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: 500;
            text-align: center;
            display: inline-block;
            white-space: nowrap;
        }
        
        .difficulty-stars {
            color: #f59e0b;
            font-size: 0.9rem;
        }
        
        /* 액션 버튼 스타일 */
        .action-buttons {
            display: flex;
            gap: 4px;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .btn-icon {
            padding: 4px 8px;
            border: 1px solid #d0d7de;
            border-radius: 3px;
            background: white;
            cursor: pointer;
            font-size: 0.8rem;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        
        .btn-icon:hover {
            background: #f6f8fa;
        }
        
        .btn-view { color: #0969da; }
        .btn-edit { color: #7c3aed; }
        .btn-toggle { color: #0d9488; }
        .btn-delete { color: #dc2626; }
        
        /* 질문이 없을 때 표시 */
        .no-questions {
            text-align: center;
            padding: 40px 20px;
            color: #656d76;
        }
        
        .no-questions h3 {
            margin: 0 0 10px 0;
            color: #24292f;
        }
        
        /* 클릭 가능한 통계 카드 스타일 */
        .stat-item.clickable {
            cursor: pointer;
            position: relative;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }
        
        .stat-item.clickable:hover {
            background: #e6f3ff;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            border-color: #bfdbfe;
        }
        
        .stat-item.clickable.active {
            background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
            border: 2px solid #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1), 
                        0 4px 12px rgba(59, 130, 246, 0.3);
            transform: translateY(-1px);
        }
        
        .stat-item.clickable.active .stat-number {
            color: #1d4ed8;
            font-weight: 700;
            text-shadow: 0 1px 2px rgba(29, 78, 216, 0.1);
        }
        
        .stat-item.clickable.active .stat-label {
            color: #1e40af;
            font-weight: 600;
        }
        
        .stat-item.clickable::before {
            content: '';
            position: absolute;
            top: -2px;
            left: -2px;
            right: -2px;
            bottom: -2px;
            background: linear-gradient(45deg, #3b82f6, #1d4ed8);
            border-radius: 6px;
            opacity: 0;
            z-index: -1;
            transition: opacity 0.3s;
        }
        
        .stat-item.clickable.active::before {
            opacity: 0.1;
        }
        
        .stat-item.clickable::after {
            content: '👆';
            position: absolute;
            top: 5px;
            right: 8px;
            font-size: 0.7rem;
            opacity: 0;
            transition: opacity 0.2s;
        }
        
        .stat-item.clickable:hover::after {
            opacity: 0.7;
        }
        
        .stat-item.clickable.active::after {
            content: '✓';
            opacity: 1;
            color: #1d4ed8;
            font-weight: bold;
            font-size: 0.8rem;
        }

    </style>
</head>
<body>
    <div class="container">
        <!-- 헤더 바 -->
        <div class="top-bar">
            <h2>📊 채용 관리 시스템</h2>
            <div class="nav-buttons">
                <a href="main.jsp" class="btn">🏠 메인</a>
                <a href="candidates" class="btn">👥 인터뷰 대상자 관리</a>
                <a href="interview/list" class="btn">📅 인터뷰 일정 관리</a>
                <a href="results" class="btn">📝 인터뷰 결과 기록/관리</a>
                <a href="statistics" class="btn">📊 통계 및 리포트</a>
                <a href="logout" class="btn btn-danger">🚪 로그아웃</a>
            </div>
        </div>
        
        <div class="main-content">
            <div class="content-header">
                <h1 style="text-align: center;">💡 인터뷰 질문 관리</h1>
            </div>
            <div class="content-body">
                <!-- 통계 바 -->
                <div class="stats-bar">
                    <div class="stat-item clickable ${filterCategory == null || filterCategory == 'all' ? 'active' : ''}" 
                         onclick="filterByCategory('all')" 
                         title="전체 질문 보기">
                        <div class="stat-number">${totalQuestions}</div>
                        <div class="stat-label">총 질문</div>
                    </div>
                    <c:forEach var="entry" items="${categoryStatistics}">
                        <div class="stat-item clickable ${filterCategory == entry.key ? 'active' : ''}" 
                             onclick="filterByCategory('${entry.key}')" 
                             title="${entry.key} 카테고리 질문만 보기">
                            <div class="stat-number">${entry.value}</div>
                            <div class="stat-label">
                                <c:choose>
                                    <c:when test="${entry.key == '기술'}">💻 기술</c:when>
                                    <c:when test="${entry.key == '기술-Java-초급'}">☕ Java 초급</c:when>
                                    <c:when test="${entry.key == '기술-Java-중급'}">☕ Java 중급</c:when>
                                    <c:when test="${entry.key == '기술-Java-고급'}">☕ Java 고급</c:when>
                                    <c:when test="${entry.key == '기술-Python-초급'}">🐍 Python 초급</c:when>
                                    <c:when test="${entry.key == '기술-Python-중급'}">🐍 Python 중급</c:when>
                                    <c:when test="${entry.key == '기술-Python-고급'}">🐍 Python 고급</c:when>
                                    <c:when test="${entry.key == '인성'}">👤 인성</c:when>
                                    <c:when test="${entry.key == '경험'}">📚 경험</c:when>
                                    <c:when test="${entry.key == '상황'}">🎯 상황</c:when>
                                    <c:otherwise>${entry.key}</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- 컨트롤 섹션 -->
                <div class="controls-section">
                    <div class="controls-grid">
                        <div class="search-container">
                            <form action="questions" method="get" style="display: inline; margin: 0;">
                                <input type="hidden" name="action" value="search">
                                <input type="text" name="keyword" id="searchInput" placeholder="질문 내용, 예상답변 검색..." value="${searchKeyword}">
                                <button type="submit" class="btn">🔍 검색</button>
                            </form>
                            <button type="button" class="btn" onclick="clearSearch()">🔄 초기화</button>
                        </div>
                        <div class="filter-controls">
                            <form id="filterForm" action="questions" method="get" style="display: inline; margin: 0;">
                                <input type="hidden" name="action" value="filter">
                                <input type="hidden" id="hiddenCategory" name="category" value="${filterCategory != null ? filterCategory : 'all'}">
                                <input type="hidden" id="hiddenDifficulty" name="difficulty" value="${filterDifficulty != null ? filterDifficulty : 'all'}">
                                
                                <select name="category" id="categorySelect" onchange="applyFilters()">
                                    <option value="all">전체 카테고리</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat}" ${filterCategory == cat ? 'selected' : ''}>${cat}</option>
                                    </c:forEach>
                                </select>
                                
                                <select name="difficulty" id="difficultySelect" onchange="applyFilters()">
                                    <option value="all">전체 난이도</option>
                                    <option value="1" ${filterDifficulty == 1 ? 'selected' : ''}>★☆☆☆☆ (1단계)</option>
                                    <option value="2" ${filterDifficulty == 2 ? 'selected' : ''}>★★☆☆☆ (2단계)</option>
                                    <option value="3" ${filterDifficulty == 3 ? 'selected' : ''}>★★★☆☆ (3단계)</option>
                                    <option value="4" ${filterDifficulty == 4 ? 'selected' : ''}>★★★★☆ (4단계)</option>
                                    <option value="5" ${filterDifficulty == 5 ? 'selected' : ''}>★★★★★ (5단계)</option>
                                </select>
                                
                                <button type="button" class="btn" onclick="clearAllFilters()">🔄 필터 초기화</button>
                            </form>
                        </div>
                        <a href="questions?action=new" class="btn btn-primary">➕ 새 질문 등록</a>
                    </div>
                </div>

        <!-- 결과 정보 -->
        <c:if test="${searchKeyword != null}">
            <div class="alert alert-info">
                '<strong>${searchKeyword}</strong>' 검색 결과: ${searchResultCount}개
            </div>
        </c:if>
        
        <c:if test="${filterResultCount != null}">
            <div class="alert alert-info">
                필터 결과: ${filterResultCount}개
            </div>
        </c:if>
        
        <c:if test="${randomQuestions == true}">
            <div class="alert alert-success">
                🎲 랜덤 질문 ${randomLimit}개가 추출되었습니다
                <c:if test="${randomCategory != null}"> (카테고리: ${randomCategory})</c:if>
                <c:if test="${randomDifficulty != null}"> (난이도: ${randomDifficulty})</c:if>
            </div>
        </c:if>

        <!-- 질문 목록 -->
        <div class="question-table">
            <div class="table-header">
                <div style="display: grid; grid-template-columns: 1fr auto auto auto auto; gap: 15px;">
                    <div>질문 내용</div>
                    <div style="text-align: center;">카테고리</div>
                    <div style="text-align: center;">난이도</div>
                    <div style="text-align: center;">상태</div>
                    <div style="text-align: center;">작업</div>
                </div>
            </div>
            
            <c:choose>
                <c:when test="${empty questions}">
                    <div class="no-questions">
                        <h3>📝 등록된 질문이 없습니다</h3>
                        <p>새로운 인터뷰 질문을 등록해보세요!</p>
                        <button class="btn btn-primary" onclick="location.href='questions?action=new'">
                            ➕ 첫 번째 질문 등록하기
                        </button>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="question" items="${questions}">
                        <div class="question-item">
                            <div class="question-content">
                                <div>
                                    <div class="question-text">${question.questionSummary}</div>
                                    <div class="question-meta">
                                        생성일: ${question.formattedCreatedAt}
                                        <c:if test="${not empty question.expectedAnswerSummary}">
                                            | 예상답변: ${question.expectedAnswerSummary}
                                        </c:if>
                                    </div>
                                </div>
                                
                                <div style="text-align: center;">
                                    <span class="category-badge ${question.categoryColorClass}">
                                        ${question.category}
                                    </span>
                                </div>
                                
                                <div style="text-align: center;">
                                    <span class="difficulty-stars" title="${question.difficultyText}">
                                        ${question.difficultyStars}
                                    </span>
                                </div>
                                
                                <div style="text-align: center;">
                                    <span class="status-badge ${question.activeStatusClass}">
                                        ${question.activeStatusText}
                                    </span>
                                </div>
                                
                                <div class="action-buttons">
                                    <button class="btn-icon btn-view" 
                                            onclick="location.href='questions?action=detail&id=${question.id}'"
                                            title="상세보기">👁</button>
                                    <button class="btn-icon btn-edit" 
                                            onclick="location.href='questions?action=edit&id=${question.id}'"
                                            title="수정">✏</button>
                                    <button class="btn-icon btn-toggle" 
                                            onclick="toggleQuestion(${question.id})"
                                            title="활성화/비활성화">🔄</button>
                                    <button class="btn-icon btn-delete" 
                                            onclick="deleteQuestion(${question.id})"
                                            title="삭제">🗑</button>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
        
        <!-- 메시지 표시 -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger" style="margin-top: 20px;">
                ${error}
            </div>
        </c:if>
        
        <c:if test="${not empty success}">
            <div class="alert alert-success" style="margin-top: 20px;">
                ${success}
            </div>
        </c:if>
            </div>
        </div>
    </div>

    <script>
        function clearSearch() {
            location.href = 'questions';
        }
        
        function deleteQuestion(id) {
            if (confirm('정말로 이 질문을 삭제하시겠습니까?\n(실제로는 비활성화됩니다)')) {
                location.href = 'questions?action=delete&id=' + id;
            }
        }
        
        function toggleQuestion(id) {
            if (confirm('이 질문의 활성화 상태를 변경하시겠습니까?')) {
                location.href = 'questions?action=toggle&id=' + id;
            }
        }
        
        // 카테고리별 필터링 함수 (기존 난이도 필터 유지)
        function filterByCategory(category) {
            // 시각적 피드백을 위한 즉시 업데이트
            updateActiveStatCard(category);
            
            // 현재 난이도 필터 값 가져오기
            const difficultySelect = document.getElementById('difficultySelect');
            const currentDifficulty = difficultySelect ? difficultySelect.value : 'all';
            
            // 셀렉트 박스 동기화
            const categorySelect = document.getElementById('categorySelect');
            if (categorySelect) {
                categorySelect.value = category;
            }
            
            // 복합 필터링 적용
            applyComplexFilter(category, currentDifficulty);
        }
        
        // 복합 필터링 적용 함수
        function applyComplexFilter(category, difficulty) {
            const params = new URLSearchParams();
            
            // 전체가 아닌 경우만 파라미터 추가
            if (category && category !== 'all') {
                params.set('category', category);
            }
            if (difficulty && difficulty !== 'all') {
                params.set('difficulty', difficulty);
            }
            
            // 필터가 있으면 filter 액션, 없으면 기본 페이지
            if (params.toString()) {
                params.set('action', 'filter');
                location.href = 'questions?' + params.toString();
            } else {
                location.href = 'questions';
            }
        }
        
        // 필터 적용 함수 (셀렉트 박스 변경 시)
        function applyFilters() {
            const categorySelect = document.getElementById('categorySelect');
            const difficultySelect = document.getElementById('difficultySelect');
            
            const category = categorySelect ? categorySelect.value : 'all';
            const difficulty = difficultySelect ? difficultySelect.value : 'all';
            
            // 카테고리 버튼 상태 업데이트
            updateActiveStatCard(category);
            
            // 복합 필터링 적용
            applyComplexFilter(category, difficulty);
        }
        
        // 모든 필터 초기화
        function clearAllFilters() {
            // 셀렉트 박스 초기화
            const categorySelect = document.getElementById('categorySelect');
            const difficultySelect = document.getElementById('difficultySelect');
            
            if (categorySelect) categorySelect.value = 'all';
            if (difficultySelect) difficultySelect.value = 'all';
            
            // 카테고리 버튼 상태 초기화
            updateActiveStatCard('all');
            
            // 전체 목록으로 이동
            location.href = 'questions';
        }
        
        // 활성 상태 카드 업데이트 (즉시 시각적 피드백)
        function updateActiveStatCard(selectedCategory) {
            const statItems = document.querySelectorAll('.stat-item.clickable');
            statItems.forEach(item => {
                item.classList.remove('active');
            });
            
            // 해당 카테고리 카드 활성화
            statItems.forEach(item => {
                const onclick = item.getAttribute('onclick');
                if (onclick && onclick.includes("'" + selectedCategory + "'")) {
                    item.classList.add('active');
                }
            });
        }
        
        // 페이지 로드 시 현재 필터 상태 반영
        document.addEventListener('DOMContentLoaded', function() {
            const currentCategory = '${filterCategory}' || 'all';
            const currentDifficulty = '${filterDifficulty}' || 'all';
            
            updateActiveStatCard(currentCategory);
            
            // 복합 필터 정보 표시
            if ((currentCategory && currentCategory !== 'all') || (currentDifficulty && currentDifficulty !== 'all')) {
                showComplexFilterInfo(currentCategory, currentDifficulty);
            }
        });
        
        // 복합 필터 정보 표시 함수
        function showComplexFilterInfo(category, difficulty) {
            const existingAlert = document.querySelector('.complex-filter-alert');
            if (existingAlert) {
                existingAlert.remove();
            }
            
            let filterText = '<strong>🔍 활성 필터:</strong> ';
            const filters = [];
            
            if (category && category !== 'all') {
                filters.push(`카테고리: ${category}`);
            }
            if (difficulty && difficulty !== 'all') {
                const difficultyText = ['', '★☆☆☆☆ (1단계)', '★★☆☆☆ (2단계)', '★★★☆☆ (3단계)', '★★★★☆ (4단계)', '★★★★★ (5단계)'][difficulty];
                filters.push(`난이도: ${difficultyText}`);
            }
            
            filterText += filters.join(' + ');
            
            const alertDiv = document.createElement('div');
            alertDiv.className = 'alert alert-info complex-filter-alert';
            alertDiv.innerHTML = `
                ${filterText}
                <button type="button" class="btn" onclick="clearAllFilters()" style="margin-left: 10px; padding: 2px 8px; font-size: 0.8rem;">
                    ❌ 모든 필터 해제
                </button>
            `;
            
            const controlsSection = document.querySelector('.controls-section');
            controlsSection.parentNode.insertBefore(alertDiv, controlsSection.nextSibling);
        }
        
        // 메시지 자동 숨김 (필터 알림은 제외)
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert:not(.complex-filter-alert)');
            alerts.forEach(alert => {
                alert.style.opacity = '0';
                setTimeout(() => alert.style.display = 'none', 300);
            });
        }, 5000);

    </script>
</body>
</html>