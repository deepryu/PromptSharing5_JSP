<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>인터뷰 질문 관리 - 채용 관리 시스템 V1.0</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            background: #f0f0f0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .question-header {
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
        
        .question-header h1 {
            margin: 0;
            font-size: 1.3rem;
            font-weight: 600;
        }
        
        .question-header p {
            margin: 5px 0 0 0;
            font-size: 0.9rem;
            opacity: 0.9;
        }
        
        .nav-buttons {
            display: flex;
            gap: 8px;
        }
        
        .nav-buttons .btn {
            padding: 6px 12px;
            font-size: 0.85rem;
            border: 1px solid rgba(255,255,255,0.3);
            background: rgba(255,255,255,0.1);
            color: white;
            text-decoration: none;
            border-radius: 3px;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        
        .nav-buttons .btn:hover {
            background: rgba(255,255,255,0.2);
        }
        
        .nav-buttons .btn-danger {
            background: #d13438;
            border-color: #b02a2f;
        }
        
        .nav-buttons .btn-danger:hover {
            background: #c23237;
        }
        
        .question-stats {
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
        
        .filters-section {
            background: white;
            border: 1px solid #d0d7de;
            padding: 15px 20px;
            margin-bottom: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .filter-row {
            display: flex !important;
            gap: 25px !important;
            align-items: center !important;
            flex-wrap: nowrap !important;
            margin-bottom: 12px !important;
            justify-content: flex-start !important;
        }
        
        .filter-row:last-child {
            margin-bottom: 0 !important;
        }
        
        .filter-group {
            display: flex !important;
            align-items: center !important;
            gap: 8px !important;
            flex-shrink: 0 !important;
        }
        
        .filter-group label {
            font-weight: 500 !important;
            font-size: 0.9rem !important;
            white-space: nowrap !important;
            color: #24292f !important;
            margin-right: 5px !important;
        }
        
        .filter-group select {
            min-width: 120px !important;
            padding: 5px 8px !important;
            border: 1px solid #d0d7de !important;
            border-radius: 3px !important;
        }
        
        .search-group {
            display: flex !important;
            align-items: center !important;
            gap: 8px !important;
            flex-shrink: 0 !important;
        }
        
        .random-section {
            background: #fff8dc;
            border: 1px solid #e8a317;
            color: #8a6914;
            padding: 15px 20px;
            margin-bottom: 20px;
            border-left: 4px solid #fb8500;
        }
        
        .random-section h3 {
            margin: 0 0 8px 0;
            font-size: 1.1rem;
        }
        
        .random-section p {
            margin: 0 0 12px 0;
            font-size: 0.9rem;
        }
        
        .random-controls {
            display: flex !important;
            gap: 25px !important;
            align-items: center !important;
            flex-wrap: nowrap !important;
            justify-content: flex-start !important;
        }
        
        .random-controls .control-group {
            display: flex !important;
            align-items: center !important;
            gap: 8px !important;
            flex-shrink: 0 !important;
        }
        
        .random-controls label {
            font-weight: 500 !important;
            font-size: 0.9rem !important;
            white-space: nowrap !important;
            margin-right: 5px !important;
        }
        
        .random-controls select {
            min-width: 100px !important;
            padding: 5px 8px !important;
            border: 1px solid #d0d7de !important;
            border-radius: 3px !important;
        }
        
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
        
        input[type="text"]:focus, select:focus {
            outline: none;
            border-color: #0969da;
            box-shadow: 0 0 0 2px rgba(9, 105, 218, 0.3);
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- 헤더 -->
        <div class="question-header">
            <div>
                <h1>📝 인터뷰 질문 관리</h1>
                <p>면접에서 사용할 질문들을 관리하고 난이도별로 분류할 수 있습니다</p>
            </div>
            <div class="nav-buttons">
                <button class="btn btn-light" onclick="location.href='main.jsp'">🏠 홈</button>
                <button class="btn btn-light" onclick="location.href='candidates'">👥 지원자관리</button>
                <button class="btn btn-light" onclick="location.href='schedules'">📅 일정관리</button>
                <button class="btn btn-light" onclick="location.href='criteria'">📊 평가기준</button>
                <button class="btn btn-danger" onclick="location.href='logout'">🚪 로그아웃</button>
            </div>
        </div>

        <!-- 통계 카드 -->
        <div class="question-stats">
            <div class="stat-card">
                <div class="stat-number">${totalQuestions}</div>
                <div class="stat-label">전체 활성 질문</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">${techQuestions}</div>
                <div class="stat-label">기술 질문</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">${personalityQuestions}</div>
                <div class="stat-label">인성 질문</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">${experienceQuestions}</div>
                <div class="stat-label">경험 질문</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">${situationQuestions}</div>
                <div class="stat-label">상황 질문</div>
            </div>
        </div>

        <!-- 랜덤 질문 섹션 -->
        <div class="random-section" style="background: #fff8dc; border: 1px solid #e8a317; color: #8a6914; padding: 15px 20px; margin-bottom: 20px; border-left: 4px solid #fb8500;">
            <h3 style="margin: 0 0 8px 0; font-size: 1.1rem;">🎲 랜덤 질문 추출</h3>
            <p style="margin: 0 0 12px 0; font-size: 0.9rem;">면접을 위한 랜덤 질문을 추출할 수 있습니다</p>
            
            <!-- 완전한 테이블 형태로 가로 배치 -->
            <table style="width: 100%; border-collapse: separate; border-spacing: 10px;">
                <tr>
                    <form action="questions" method="get">
                        <input type="hidden" name="action" value="random">
                        
                        <td style="text-align: left; white-space: nowrap; padding: 0;">
                            <label style="font-weight: 500; margin-right: 8px;">개수:</label>
                            <select name="limit" style="min-width: 70px; padding: 5px;">
                                <option value="5" ${randomLimit == 5 ? 'selected' : ''}>5개</option>
                                <option value="10" ${randomLimit == 10 ? 'selected' : ''}>10개</option>
                                <option value="15" ${randomLimit == 15 ? 'selected' : ''}>15개</option>
                                <option value="20" ${randomLimit == 20 ? 'selected' : ''}>20개</option>
                            </select>
                        </td>
                        
                        <td style="text-align: left; white-space: nowrap; padding: 0;">
                            <label style="font-weight: 500; margin-right: 8px;">카테고리:</label>
                            <select name="category" style="min-width: 70px; padding: 5px;">
                                <option value="all" ${randomCategory == null ? 'selected' : ''}>전체</option>
                                <option value="기술" ${randomCategory == '기술' ? 'selected' : ''}>기술</option>
                                <option value="인성" ${randomCategory == '인성' ? 'selected' : ''}>인성</option>
                                <option value="경험" ${randomCategory == '경험' ? 'selected' : ''}>경험</option>
                                <option value="상황" ${randomCategory == '상황' ? 'selected' : ''}>상황</option>
                            </select>
                        </td>
                        
                        <td style="text-align: left; white-space: nowrap; padding: 0;">
                            <label style="font-weight: 500; margin-right: 8px;">난이도:</label>
                            <select name="difficulty" style="min-width: 70px; padding: 5px;">
                                <option value="all" ${randomDifficulty == null ? 'selected' : ''}>전체</option>
                                <option value="1" ${randomDifficulty == 1 ? 'selected' : ''}>★☆☆☆☆</option>
                                <option value="2" ${randomDifficulty == 2 ? 'selected' : ''}>★★☆☆☆</option>
                                <option value="3" ${randomDifficulty == 3 ? 'selected' : ''}>★★★☆☆</option>
                                <option value="4" ${randomDifficulty == 4 ? 'selected' : ''}>★★★★☆</option>
                                <option value="5" ${randomDifficulty == 5 ? 'selected' : ''}>★★★★★</option>
                            </select>
                        </td>
                        
                        <td style="text-align: left; padding: 0;">
                            <button type="submit" class="btn btn-light" style="background: #2da44e; color: white; border: 1px solid #2da44e; padding: 6px 12px; border-radius: 3px; cursor: pointer;">🎯 랜덤 추출</button>
                        </td>
                    </form>
                </tr>
            </table>
        </div>

        <!-- 필터 및 검색 - 완전히 새로운 레이아웃 -->
        <div style="background: white; border: 1px solid #d0d7de; padding: 20px; margin-bottom: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
            
            <!-- 첫 번째 줄: 새 질문 등록 버튼과 검색 -->
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; flex-wrap: wrap; gap: 10px;">
                <button class="btn btn-primary" onclick="location.href='questions?action=new'" 
                        style="background: #2da44e; color: white; border: 1px solid #2da44e; padding: 8px 16px; border-radius: 3px; cursor: pointer; font-weight: 500;">
                    ➕ 새 질문 등록
                </button>
                
                <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
                    <form action="questions" method="get" style="display: flex; align-items: center; gap: 8px;">
                        <input type="hidden" name="action" value="search">
                        <input type="text" name="keyword" placeholder="질문 내용 검색..." 
                               value="${searchKeyword}" 
                               style="padding: 8px 12px; border: 1px solid #d0d7de; border-radius: 3px; width: 200px;">
                        <button type="submit" 
                                style="background: #0969da; color: white; border: 1px solid #0969da; padding: 8px 16px; border-radius: 3px; cursor: pointer;">
                            🔍 검색
                        </button>
                    </form>
                    <c:if test="${searchKeyword != null}">
                        <button onclick="location.href='questions'" 
                                style="background: #f6f8fa; color: #24292f; border: 1px solid #d0d7de; padding: 8px 12px; border-radius: 3px; cursor: pointer;">
                            ❌ 검색 초기화
                        </button>
                    </c:if>
                </div>
            </div>
            
            <!-- 두 번째 줄: 필터 옵션들 -->
            <div style="display: flex; align-items: center; gap: 20px; flex-wrap: wrap;">
                <div style="display: flex; align-items: center; gap: 8px;">
                    <form action="questions" method="get" style="display: flex; align-items: center; gap: 8px;">
                        <input type="hidden" name="action" value="filter">
                        <label style="font-weight: 500; color: #24292f; white-space: nowrap;">카테고리:</label>
                        <select name="category" onchange="this.form.submit()" 
                                style="padding: 6px 10px; border: 1px solid #d0d7de; border-radius: 3px; background: white; min-width: 100px;">
                            <option value="all">전체</option>
                            <option value="기술" ${filterCategory == '기술' ? 'selected' : ''}>기술</option>
                            <option value="인성" ${filterCategory == '인성' ? 'selected' : ''}>인성</option>
                            <option value="경험" ${filterCategory == '경험' ? 'selected' : ''}>경험</option>
                            <option value="상황" ${filterCategory == '상황' ? 'selected' : ''}>상황</option>
                        </select>
                    </form>
                </div>
                
                <div style="display: flex; align-items: center; gap: 8px;">
                    <form action="questions" method="get" style="display: flex; align-items: center; gap: 8px;">
                        <input type="hidden" name="action" value="filter">
                        <label style="font-weight: 500; color: #24292f; white-space: nowrap;">난이도:</label>
                        <select name="difficulty" onchange="this.form.submit()" 
                                style="padding: 6px 10px; border: 1px solid #d0d7de; border-radius: 3px; background: white; min-width: 120px;">
                            <option value="all">전체</option>
                            <option value="1" ${filterDifficulty == 1 ? 'selected' : ''}>★☆☆☆☆ (매우 쉬움)</option>
                            <option value="2" ${filterDifficulty == 2 ? 'selected' : ''}>★★☆☆☆ (쉬움)</option>
                            <option value="3" ${filterDifficulty == 3 ? 'selected' : ''}>★★★☆☆ (보통)</option>
                            <option value="4" ${filterDifficulty == 4 ? 'selected' : ''}>★★★★☆ (어려움)</option>
                            <option value="5" ${filterDifficulty == 5 ? 'selected' : ''}>★★★★★ (매우 어려움)</option>
                        </select>
                    </form>
                </div>
                
                <c:if test="${filterCategory != null || filterDifficulty != null}">
                    <button onclick="location.href='questions'" 
                            style="background: #f6f8fa; color: #24292f; border: 1px solid #d0d7de; padding: 6px 12px; border-radius: 3px; cursor: pointer;">
                        🔄 필터 초기화
                    </button>
                </c:if>
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

    <script>
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
        
        // 메시지 자동 숨김
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                alert.style.opacity = '0';
                setTimeout(() => alert.style.display = 'none', 300);
            });
        }, 5000);

    </script>
</body>
</html>