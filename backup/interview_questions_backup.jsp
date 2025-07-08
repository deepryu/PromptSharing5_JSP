<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String username = (String)session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%><%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
        <!-- ?ㅻ뜑 -->
        <div class="question-header">
            <div>
                <h1>?뱷 ?명꽣酉?吏덈Ц 愿由?/h1>
            </div>
            <div class="nav-buttons">
                <button class="btn btn-light" onclick="location.href='main.jsp'">?룧 ??/button>
                <button class="btn btn-light" onclick="location.href='candidates'">?뫁 吏?먯옄愿由?/button>
                <button class="btn btn-light" onclick="location.href='schedules'">?뱟 ?쇱젙愿由?/button>
                <button class="btn btn-light" onclick="location.href='results'">?뱤 寃곌낵愿由?/button>
                <button class="btn btn-light" onclick="location.href='criteria'">?뱤 ?됯?湲곗?</button>
                <button class="btn btn-danger" onclick="location.href='logout'">?슞 濡쒓렇?꾩썐</button>
            </div>
        </div>

        <!-- ?듦퀎 移대뱶 -->
        <div class="question-stats">
            <div class="stat-card">
                <div class="stat-number">${totalQuestions}</div>
                <div class="stat-label">?꾩껜 ?쒖꽦 吏덈Ц</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">${techQuestions}</div>
                <div class="stat-label">湲곗닠 吏덈Ц</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">${personalityQuestions}</div>
                <div class="stat-label">?몄꽦 吏덈Ц</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">${experienceQuestions}</div>
                <div class="stat-label">寃쏀뿕 吏덈Ц</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">${situationQuestions}</div>
                <div class="stat-label">?곹솴 吏덈Ц</div>
            </div>
        </div>



        <!-- 紐⑤뱺 而⑦듃濡ㅼ쓣 ??以꾨줈 諛곗튂?섎뒗 ?듯빀 ?덉씠?꾩썐 -->
        <div style="background: white; border: 1px solid #d0d7de; padding: 15px; margin-bottom: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
            
            <!-- 罹먯떆 諛⑹?: 2025-06-26-15:10 - 移댄뀒怨좊━/?쒖씠???곗꽑 諛곗튂 -->
            
            <!-- 5媛??꾩씠?쒖쓣 ??以꾨줈 諛곗튂?섎뒗 HTML ?뚯씠釉?(移댄뀒怨좊━, ?쒖씠???곗꽑) -->
            <table cellpadding="0" cellspacing="0" border="0" style="width: 100%; border-collapse: separate; border-spacing: 15px 0;">
                <tr style="vertical-align: middle;">
                    
                    <!-- 1-2. 移댄뀒怨좊━? ?쒖씠???듯빀 ?꾪꽣 -->
                    <td colspan="2" style="white-space: nowrap; padding: 0; vertical-align: middle;">
                        <form action="questions" method="get" style="display: inline; margin: 0;" id="combinedFilterForm">
                            <input type="hidden" name="action" value="filter">
                            
                            <span style="font-weight: 500; color: #24292f; margin-right: 8px;">移댄뀒怨좊━:</span>
                            <select name="category" onchange="document.getElementById('combinedFilterForm').submit()" 
                                    style="padding: 6px 10px; border: 1px solid #d0d7de; border-radius: 3px; background: white; min-width: 90px; font-size: 14px; vertical-align: middle; margin-right: 20px;">
                                <option value="all">?꾩껜</option>
                                <option value="湲곗닠" <c:if test="${filterCategory eq '湲곗닠'}">selected</c:if>>湲곗닠</option>
                                <option value="?몄꽦" <c:if test="${filterCategory eq '?몄꽦'}">selected</c:if>>?몄꽦</option>
                                <option value="寃쏀뿕" <c:if test="${filterCategory eq '寃쏀뿕'}">selected</c:if>>寃쏀뿕</option>
                                <option value="?곹솴" <c:if test="${filterCategory eq '?곹솴'}">selected</c:if>>?곹솴</option>
                            </select>
                            
                            <span style="font-weight: 500; color: #24292f; margin-right: 8px;">?쒖씠??</span>
                            <select name="difficulty" onchange="document.getElementById('combinedFilterForm').submit()" 
                                    style="padding: 6px 10px; border: 1px solid #d0d7de; border-radius: 3px; background: white; min-width: 130px; font-size: 14px; vertical-align: middle;">
                                <option value="all">?꾩껜</option>
                                <option value="1" <c:if test="${filterDifficulty eq '1'}">selected</c:if>>?끸쁿?녳쁿??(?ъ?)</option>
                                <option value="2" <c:if test="${filterDifficulty eq '2'}">selected</c:if>>?끸쁾?녳쁿??(蹂댄넻)</option>
                                <option value="3" <c:if test="${filterDifficulty eq '3'}">selected</c:if>>?끸쁾?끸쁿??(?대젮?)</option>
                                <option value="4" <c:if test="${filterDifficulty eq '4'}">selected</c:if>>?끸쁾?끸쁾??(留ㅼ슦?대젮?)</option>
                                <option value="5" <c:if test="${filterDifficulty eq '5'}">selected</c:if>>?끸쁾?끸쁾??(理쒓퀬?쒖씠??</option>
                            </select>
                            
                            <!-- ?꾪꽣 珥덇린??踰꾪듉 -->
                            <c:if test="${(filterCategory != null && filterCategory != 'all') || filterDifficulty != null}">
                                <button type="button" onclick="location.href='questions'" 
                                        style="background: #f6f8fa; color: #24292f; border: 1px solid #d0d7de; padding: 6px 12px; border-radius: 3px; cursor: pointer; margin-left: 10px; vertical-align: middle; font-size: 14px;">
                                    ?봽 ?꾪꽣 珥덇린??
                                </button>
                            </c:if>
                        </form>
                    </td>
                    
                    <!-- 3. 寃?됱갹怨?4. 寃??踰꾪듉 (?섎굹???쇱쑝濡??듯빀) -->
                    <td style="white-space: nowrap; padding: 0; vertical-align: middle;">
                        <form action="questions" method="get" style="display: inline; margin: 0;">
                            <input type="hidden" name="action" value="search">
                            <input type="text" name="keyword" placeholder="吏덈Ц ?댁슜 寃??.." 
                                   value="${searchKeyword}" 
                                   style="padding: 6px 10px; border: 1px solid #d0d7de; border-radius: 3px; width: 180px; font-size: 14px; vertical-align: middle; margin-right: 5px; height: 32px; box-sizing: border-box;">
                            <button type="submit"
                                    style="background: #0969da; color: white; border: 1px solid #0969da; padding: 6px 12px; border-radius: 3px; cursor: pointer; white-space: nowrap; vertical-align: middle; font-size: 14px; height: 32px; box-sizing: border-box;">
                                ?뵇 寃??
                            </button>
                        </form>
                        <c:if test="${searchKeyword != null}">
                            <button onclick="location.href='questions'" 
                                    style="background: #f6f8fa; color: #24292f; border: 1px solid #d0d7de; padding: 6px 12px; border-radius: 3px; cursor: pointer; margin-left: 5px; vertical-align: middle; font-size: 14px; height: 32px; box-sizing: border-box;">
                                ??珥덇린??
                            </button>
                        </c:if>
                    </td>
                    
                    <!-- 5. ??吏덈Ц ?깅줉 踰꾪듉 (留?留덉?留? -->
                    <td style="white-space: nowrap; padding: 0; vertical-align: middle;">
                        <button onclick="location.href='questions?action=new'" 
                                style="background: #2da44e; color: white; border: 1px solid #2da44e; padding: 8px 16px; border-radius: 3px; cursor: pointer; font-weight: 500; white-space: nowrap;">
                            ????吏덈Ц ?깅줉
                        </button>
                    </td>
                    
                </tr>
            </table>
        </div>
        


        <!-- 寃곌낵 ?뺣낫 -->
        <c:if test="${searchKeyword != null}">
            <div class="alert alert-info">
                '<strong>${searchKeyword}</strong>' 寃??寃곌낵: ${searchResultCount}媛?
            </div>
        </c:if>
        
        <c:if test="${filterResultCount != null}">
            <div class="alert alert-info">
                ?꾪꽣 寃곌낵: ${filterResultCount}媛?
                <c:if test="${filterCategory != null && filterCategory != 'all'}"> (移댄뀒怨좊━: ${filterCategory})</c:if>
                <c:if test="${filterDifficulty != null}"> (?쒖씠?? ${filterDifficulty})</c:if>
            </div>
        </c:if>
        


        <!-- 吏덈Ц 紐⑸줉 -->
        <div class="question-table">
            <div class="table-header">
                <div style="display: grid; grid-template-columns: 1fr auto auto auto auto; gap: 15px;">
                    <div>吏덈Ц ?댁슜</div>
                    <div style="text-align: center;">移댄뀒怨좊━</div>
                    <div style="text-align: center;">?쒖씠??/div>
                    <div style="text-align: center;">?곹깭</div>
                    <div style="text-align: center;">?묒뾽</div>
                </div>
            </div>
            
            <c:choose>
                <c:when test="${empty questions}">
                    <div class="no-questions">
                        <h3>?뱷 ?깅줉??吏덈Ц???놁뒿?덈떎</h3>
                        <p>?덈줈???명꽣酉?吏덈Ц???깅줉?대낫?몄슂!</p>
                        <button class="btn btn-primary" onclick="location.href='questions?action=new'">
                            ??泥?踰덉㎏ 吏덈Ц ?깅줉?섍린
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
                                        ?앹꽦?? ${question.formattedCreatedAt}
                                        <c:if test="${not empty question.expectedAnswerSummary}">
                                            | ?덉긽?듬?: ${question.expectedAnswerSummary}
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
                                            title="?곸꽭蹂닿린">?몓</button>
                                    <button class="btn-icon btn-edit" 
                                            onclick="location.href='questions?action=edit&id=${question.id}'"
                                            title="?섏젙">??/button>
                                    <button class="btn-icon btn-toggle" 
                                            onclick="toggleQuestion(${question.id})"
                                            title="?쒖꽦??鍮꾪솢?깊솕">?봽</button>
                                    <button class="btn-icon btn-delete" 
                                            onclick="deleteQuestion(${question.id})"
                                            title="??젣">?뿊</button>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
        
        <!-- 硫붿떆吏 ?쒖떆 -->
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
            if (confirm('?뺣쭚濡???吏덈Ц????젣?섏떆寃좎뒿?덇퉴?\n(?ㅼ젣濡쒕뒗 鍮꾪솢?깊솕?⑸땲??')) {
                location.href = 'questions?action=delete&id=' + id;
            }
        }
        
        function toggleQuestion(id) {
            if (confirm('??吏덈Ц???쒖꽦???곹깭瑜?蹂寃쏀븯?쒓쿋?듬땲源?')) {
                location.href = 'questions?action=toggle&id=' + id;
            }
        }
        
        // 硫붿떆吏 ?먮룞 ?④?
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
