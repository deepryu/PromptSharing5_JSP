<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String username = (String)session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%><%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>
        <c:choose>
            <c:when test="${question != null}">질문 수정</c:when>
            <c:otherwise>새 질문 등록</c:otherwise>
        </c:choose>
        - 채용 관리 시스템
    </title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            background: #f0f0f0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
        }
        
        .container {
            max-width: 1000px;
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
        
        .top-bar .nav-buttons {
            display: flex;
            gap: 8px;
        }
        
        .top-bar .btn {
            padding: 6px 12px;
            font-size: 0.85rem;
            border: 1px solid #d0d7de;
            background: white;
            color: #24292f;
            text-decoration: none;
            border-radius: 3px;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        
        .top-bar .btn:hover {
            background: #f6f8fa;
        }
        
        .top-bar .btn-danger {
            background: #da3633;
            color: white;
            border-color: #da3633;
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
            border-bottom: 1px solid #d0d7de;
        }
        
        .dashboard-header h1 {
            margin: 0;
            font-size: 1.4rem;
            font-weight: 600;
        }
        
        .dashboard-content {
            padding: 30px;
        }
        
        .form-section {
            margin-bottom: 30px;
        }
        
        .form-section h3 {
            color: #24292f;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #f0f0f0;
            font-size: 1.1rem;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #24292f;
        }
        
        .required {
            color: #dc3545;
        }
        
        .form-control {
            width: 100%;
            padding: 12px;
            border: 2px solid #d0d7de;
            border-radius: 6px;
            font-size: 14px;
            transition: border-color 0.3s;
            box-sizing: border-box;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #0078d4;
            box-shadow: 0 0 0 3px rgba(0,120,212,0.1);
        }
        
        textarea.form-control {
            resize: vertical;
            min-height: 120px;
        }
        
        .char-count {
            font-size: 0.85rem;
            color: #656d76;
            margin-top: 5px;
        }
        
        .help-text {
            font-size: 0.9rem;
            color: #656d76;
            margin-top: 8px;
        }
        
        .category-selector {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            margin-top: 10px;
        }
        
        .category-option {
            position: relative;
        }
        
        .category-option input[type="radio"] {
            display: none;
        }
        
        .category-option label {
            display: block;
            padding: 15px;
            border: 2px solid #d0d7de;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s;
            text-align: center;
            font-weight: 500;
            background: white;
        }
        
        .category-option label:hover {
            border-color: #0078d4;
            background: #f6f8fa;
        }
        
        .category-option input[type="radio"]:checked + label {
            border-color: #0078d4;
            background: #dbeafe;
            color: #0078d4;
        }
        
        .difficulty-selector {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 10px;
            margin-top: 10px;
        }
        
        .difficulty-option {
            position: relative;
        }
        
        .difficulty-option input[type="radio"] {
            display: none;
        }
        
        .difficulty-option label {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 15px 10px;
            border: 2px solid #d0d7de;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s;
            text-align: center;
            background: white;
            min-height: 70px;
        }
        
        .difficulty-option label:hover {
            border-color: #0078d4;
            background: #f6f8fa;
        }
        
        .difficulty-option input[type="radio"]:checked + label {
            border-color: #0078d4;
            background: #dbeafe;
            color: #0078d4;
        }
        
        .difficulty-stars {
            font-size: 1.2em;
            color: #ffc107;
            margin-bottom: 5px;
        }
        
        .difficulty-text {
            font-size: 0.85em;
            font-weight: 500;
        }
        
        .preview-section {
            background: #f6f8fa;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            padding: 20px;
            margin: 20px 0;
        }
        
        .preview-section h4 {
            margin-top: 0;
            color: #24292f;
        }
        
        .preview-content {
            background: white;
            border: 1px solid #d0d7de;
            border-radius: 4px;
            padding: 15px;
            font-size: 0.9rem;
            line-height: 1.5;
        }
        
        .form-actions {
            display: flex;
            gap: 10px;
            padding-top: 20px;
            border-top: 1px solid #d0d7de;
            margin-top: 30px;
        }
        
        .btn-form {
            padding: 12px 24px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }
        
        .btn-primary {
            background: #1f883d;
            color: white;
        }
        
        .btn-primary:hover {
            background: #1a7f37;
        }
        
        .btn-secondary {
            background: white;
            color: #24292f;
            border: 1px solid #d0d7de;
        }
        
        .btn-secondary:hover {
            background: #f6f8fa;
        }
        
        .alert {
            padding: 12px 16px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 6px;
        }
        
        .alert-danger {
            background: #fee2e2;
            border-color: #fca5a5;
            color: #dc2626;
        }
        
        .alert-success {
            background: #dcfce7;
            border-color: #86efac;
            color: #16a34a;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- 상단 네비게이션 바 -->
        <div class="top-bar">
            <h2>
                <c:choose>
                    <c:when test="${question != null}">✏️ 질문 수정</c:when>
                    <c:otherwise>➕ 새 질문 등록</c:otherwise>
                </c:choose>
            </h2>
            <div class="nav-buttons">
                <a href="questions" class="btn">📋 질문목록</a>
                <a href="main.jsp" class="btn">🏠 메인</a>
                <a href="logout" class="btn btn-danger">🚪 로그아웃</a>
            </div>
        </div>

        <!-- 메인 대시보드 -->
        <div class="main-dashboard">
            <div class="dashboard-header">
                <h1>
                    <c:choose>
                        <c:when test="${question != null}">질문 수정</c:when>
                        <c:otherwise>새 질문 등록</c:otherwise>
                    </c:choose>
                </h1>
            </div>
            <div class="dashboard-content">
                <!-- 에러/성공 메시지 -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        ${error}
                    </div>
                </c:if>
                
                <c:if test="${not empty success}">
                    <div class="alert alert-success">
                        ${success}
                    </div>
                </c:if>

                <!-- 질문 등록/수정 폼 -->
                <form id="questionForm" action="questions" method="post">
                    <input type="hidden" name="action" value="${question != null ? 'update' : 'create'}">
                    <c:if test="${question != null}">
                        <input type="hidden" name="id" value="${question.id}">
                    </c:if>
                    
                    <!-- 질문 내용 -->
                    <div class="form-section">
                        <h3>질문 내용</h3>
                        <div class="form-group">
                            <label for="questionText">질문 텍스트 <span class="required">*</span></label>
                            <textarea id="questionText" name="questionText" class="form-control" 
                                      placeholder="면접에서 사용할 질문을 입력하세요..."
                                      required maxlength="1000">${question != null ? question.questionText : ''}</textarea>
                            <div class="char-count">
                                <span id="charCount">0</span>/1000자
                            </div>
                            <div class="help-text">
                                구체적이고 명확한 질문을 작성해주세요. 최소 10자 이상 입력해야 합니다.
                            </div>
                        </div>
                    </div>
                    
                    <!-- 카테고리 선택 -->
                    <div class="form-section">
                        <h3>질문 카테고리</h3>
                        <div class="category-selector">
                            <div class="category-option">
                                <input type="radio" id="cat1" name="category" value="기술" 
                                       ${question == null || question.category == '기술' ? 'checked' : ''}>
                                <label for="cat1">💻 기술</label>
                            </div>
                            <div class="category-option">
                                <input type="radio" id="cat2" name="category" value="기술-Java-초급" 
                                       ${question != null && question.category == '기술-Java-초급' ? 'checked' : ''}>
                                <label for="cat2">☕ 기술-Java-초급</label>
                            </div>
                            <div class="category-option">
                                <input type="radio" id="cat3" name="category" value="기술-Java-중급" 
                                       ${question != null && question.category == '기술-Java-중급' ? 'checked' : ''}>
                                <label for="cat3">☕ 기술-Java-중급</label>
                            </div>
                            <div class="category-option">
                                <input type="radio" id="cat4" name="category" value="기술-Java-고급" 
                                       ${question != null && question.category == '기술-Java-고급' ? 'checked' : ''}>
                                <label for="cat4">☕ 기술-Java-고급</label>
                            </div>
                            <div class="category-option">
                                <input type="radio" id="cat5" name="category" value="기술-Python-초급" 
                                       ${question != null && question.category == '기술-Python-초급' ? 'checked' : ''}>
                                <label for="cat5">🐍 기술-Python-초급</label>
                            </div>
                            <div class="category-option">
                                <input type="radio" id="cat6" name="category" value="기술-Python-중급" 
                                       ${question != null && question.category == '기술-Python-중급' ? 'checked' : ''}>
                                <label for="cat6">🐍 기술-Python-중급</label>
                            </div>
                            <div class="category-option">
                                <input type="radio" id="cat7" name="category" value="기술-Python-고급" 
                                       ${question != null && question.category == '기술-Python-고급' ? 'checked' : ''}>
                                <label for="cat7">🐍 기술-Python-고급</label>
                            </div>
                            <div class="category-option">
                                <input type="radio" id="cat8" name="category" value="인성" 
                                       ${question != null && question.category == '인성' ? 'checked' : ''}>
                                <label for="cat8">👤 인성</label>
                            </div>
                            <div class="category-option">
                                <input type="radio" id="cat9" name="category" value="경험" 
                                       ${question != null && question.category == '경험' ? 'checked' : ''}>
                                <label for="cat9">📚 경험</label>
                            </div>
                            <div class="category-option">
                                <input type="radio" id="cat10" name="category" value="상황" 
                                       ${question != null && question.category == '상황' ? 'checked' : ''}>
                                <label for="cat10">🎯 상황</label>
                            </div>
                        </div>
                        <div class="help-text">
                            질문의 성격에 맞는 카테고리를 선택해주세요. 기술 질문의 경우 언어와 수준을 구체적으로 선택할 수 있습니다.
                        </div>
                    </div>
                    
                    <!-- 난이도 선택 -->
                    <div class="form-section">
                        <h3>질문 난이도</h3>
                        <div class="difficulty-selector">
                            <div class="difficulty-option">
                                <input type="radio" id="diff1" name="difficultyLevel" value="1"
                                       ${question != null && question.difficultyLevel == 1 ? 'checked' : ''}>
                                <label for="diff1">
                                    <div class="difficulty-stars">★☆☆☆☆</div>
                                    <div class="difficulty-text">매우 쉬움</div>
                                </label>
                            </div>
                            <div class="difficulty-option">
                                <input type="radio" id="diff2" name="difficultyLevel" value="2"
                                       ${question != null && question.difficultyLevel == 2 ? 'checked' : ''}>
                                <label for="diff2">
                                    <div class="difficulty-stars">★★☆☆☆</div>
                                    <div class="difficulty-text">쉬움</div>
                                </label>
                            </div>
                            <div class="difficulty-option">
                                <input type="radio" id="diff3" name="difficultyLevel" value="3"
                                       ${question == null || question.difficultyLevel == 3 ? 'checked' : ''}>
                                <label for="diff3">
                                    <div class="difficulty-stars">★★★☆☆</div>
                                    <div class="difficulty-text">보통</div>
                                </label>
                            </div>
                            <div class="difficulty-option">
                                <input type="radio" id="diff4" name="difficultyLevel" value="4"
                                       ${question != null && question.difficultyLevel == 4 ? 'checked' : ''}>
                                <label for="diff4">
                                    <div class="difficulty-stars">★★★★☆</div>
                                    <div class="difficulty-text">어려움</div>
                                </label>
                            </div>
                            <div class="difficulty-option">
                                <input type="radio" id="diff5" name="difficultyLevel" value="5"
                                       ${question != null && question.difficultyLevel == 5 ? 'checked' : ''}>
                                <label for="diff5">
                                    <div class="difficulty-stars">★★★★★</div>
                                    <div class="difficulty-text">매우 어려움</div>
                                </label>
                            </div>
                        </div>
                        <div class="help-text">
                            질문의 난이도를 설정하세요. 면접 대상자의 수준에 맞는 적절한 난이도의 질문을 선택할 수 있습니다.
                        </div>
                    </div>
                    
                    <!-- 예상 답변 -->
                    <div class="form-section">
                        <h3>예상 답변 (선택사항)</h3>
                        <div class="form-group">
                            <label for="expectedAnswer">예상되는 답변 또는 평가 기준</label>
                            <textarea id="expectedAnswer" name="expectedAnswer" class="form-control" 
                                      placeholder="이 질문에 대한 예상 답변이나 평가 기준을 입력하세요..."
                                      maxlength="2000">${question != null ? question.expectedAnswer : ''}</textarea>
                            <div class="char-count">
                                <span id="answerCharCount">0</span>/2000자
                            </div>
                            <div class="help-text">
                                면접관이 답변을 평가할 때 참고할 수 있는 내용을 작성해주세요.
                            </div>
                        </div>
                    </div>
                    
                    <!-- 미리보기 -->
                    <div class="preview-section">
                        <h4>💡 질문 미리보기</h4>
                        <div class="preview-content" id="questionPreview">
                            <strong>질문:</strong> <span id="previewQuestion">(질문을 입력하세요)</span><br><br>
                            <strong>카테고리:</strong> <span id="previewCategory">💻 기술</span><br>
                            <strong>난이도:</strong> <span id="previewDifficulty">★★★☆☆ (보통)</span><br><br>
                            <strong>예상답변:</strong> <span id="previewAnswer">(예상답변을 입력하세요)</span>
                        </div>
                    </div>
                    
                    <!-- 액션 버튼 -->
                    <div class="form-actions">
                        <button type="submit" class="btn-form btn-primary" id="submitBtn">
                            <c:choose>
                                <c:when test="${question != null}">✏️ 질문 수정 완료</c:when>
                                <c:otherwise>➕ 새 질문 등록</c:otherwise>
                            </c:choose>
                        </button>
                        <button type="button" class="btn-form btn-secondary" onclick="location.href='questions'">
                            ❌ 취소
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        console.log('[DEBUG] ========== interview_question_form.jsp 스크립트 로드 시작 ==========');
        
        // 문자 수 카운터
        function updateCharCount() {
            console.log('[DEBUG] updateCharCount 함수 호출');
            const questionText = document.getElementById('questionText');
            const expectedAnswer = document.getElementById('expectedAnswer');
            const charCount = document.getElementById('charCount');
            const answerCharCount = document.getElementById('answerCharCount');
            
            if (questionText && charCount) {
                const questionLength = questionText.value.length;
                charCount.textContent = questionLength;
                console.log('[DEBUG] 질문 텍스트 길이: ' + questionLength);
            }
            
            if (expectedAnswer && answerCharCount) {
                const answerLength = expectedAnswer.value.length;
                answerCharCount.textContent = answerLength;
                console.log('[DEBUG] 예상답변 텍스트 길이: ' + answerLength);
            }
        }
        
        // 미리보기 업데이트
        function updatePreview() {
            console.log('[DEBUG] updatePreview 함수 호출');
            const questionText = document.getElementById('questionText').value;
            const expectedAnswer = document.getElementById('expectedAnswer').value;
            const category = document.querySelector('input[name="category"]:checked');
            const difficulty = document.querySelector('input[name="difficultyLevel"]:checked');
            
            console.log('[DEBUG] 폼 데이터 수집:');
            console.log('[DEBUG]   - 질문: ' + (questionText ? questionText.substring(0, 50) + '...' : '(비어있음)'));
            console.log('[DEBUG]   - 예상답변: ' + (expectedAnswer ? expectedAnswer.substring(0, 30) + '...' : '(비어있음)'));
            console.log('[DEBUG]   - 카테고리: ' + (category ? category.value : '(선택되지 않음)'));
            console.log('[DEBUG]   - 난이도: ' + (difficulty ? difficulty.value : '(선택되지 않음)'));
            
            document.getElementById('previewQuestion').textContent = 
                questionText || '(질문을 입력하세요)';
            document.getElementById('previewAnswer').textContent = 
                expectedAnswer || '(예상답변을 입력하세요)';
            
            if (category) {
                let categoryText = category.value;
                let categoryIcon = {
                    '기술': '💻', 
                    '기술-Java-초급': '☕', 
                    '기술-Java-중급': '☕', 
                    '기술-Java-고급': '☕',
                    '기술-Python-초급': '🐍',
                    '기술-Python-중급': '🐍',
                    '기술-Python-고급': '🐍',
                    '인성': '👤', 
                    '경험': '📚', 
                    '상황': '🎯'
                }[categoryText] || '💻';
                document.getElementById('previewCategory').textContent = categoryIcon + ' ' + categoryText;
                console.log('[DEBUG] 카테고리 미리보기 업데이트: ' + categoryIcon + ' ' + categoryText);
            }
            
            if (difficulty) {
                let diffValue = parseInt(difficulty.value);
                let stars = '★'.repeat(diffValue) + '☆'.repeat(5 - diffValue);
                let diffText = ['', '매우 쉬움', '쉬움', '보통', '어려움', '매우 어려움'][diffValue];
                document.getElementById('previewDifficulty').textContent = stars + ' (' + diffText + ')';
                console.log('[DEBUG] 난이도 미리보기 업데이트: ' + stars + ' (' + diffText + ')');
            }
        }
        
        // 폼 제출 전 검증
        function validateForm() {
            console.log('[DEBUG] ========== 폼 검증 시작 ==========');
            const questionText = document.getElementById('questionText').value.trim();
            const category = document.querySelector('input[name="category"]:checked');
            const difficulty = document.querySelector('input[name="difficultyLevel"]:checked');
            
            console.log('[DEBUG] 검증 대상 데이터:');
            console.log('[DEBUG]   - 질문: ' + (questionText ? questionText.substring(0, 50) + '...' : '(비어있음)'));
            console.log('[DEBUG]   - 카테고리: ' + (category ? category.value : '(선택되지 않음)'));
            console.log('[DEBUG]   - 난이도: ' + (difficulty ? difficulty.value : '(선택되지 않음)'));
            
            if (!questionText) {
                console.log('[DEBUG] ❌ 검증 실패: 질문이 비어있음');
                alert('질문 내용을 입력해주세요.');
                return false;
            }
            
            if (questionText.length < 10) {
                console.log('[DEBUG] ❌ 검증 실패: 질문이 너무 짧음 (길이: ' + questionText.length + ')');
                alert('질문은 최소 10자 이상 입력해주세요.');
                return false;
            }
            
            if (!category) {
                console.log('[DEBUG] ❌ 검증 실패: 카테고리가 선택되지 않음');
                alert('카테고리를 선택해주세요.');
                return false;
            }
            
            if (!difficulty) {
                console.log('[DEBUG] ❌ 검증 실패: 난이도가 선택되지 않음');
                alert('난이도를 선택해주세요.');
                return false;
            }
            
            console.log('[DEBUG] ✅ 폼 검증 성공');
            return true;
        }
        
        // 이벤트 리스너 등록
        document.addEventListener('DOMContentLoaded', function() {
            console.log('[DEBUG] DOM 로드 완료 - 이벤트 리스너 등록 시작');
            
            const questionText = document.getElementById('questionText');
            const expectedAnswer = document.getElementById('expectedAnswer');
            const categoryInputs = document.querySelectorAll('input[name="category"]');
            const difficultyInputs = document.querySelectorAll('input[name="difficultyLevel"]');
            const form = document.getElementById('questionForm');
            
            // 초기 카운터 및 미리보기 설정
            updateCharCount();
            updatePreview();
            console.log('[DEBUG] 초기 상태 설정 완료');
            
            // 입력 이벤트 리스너
            if (questionText) {
                questionText.addEventListener('input', function() {
                    console.log('[DEBUG] 질문 텍스트 입력 이벤트 발생');
                    updateCharCount();
                    updatePreview();
                });
                console.log('[DEBUG] 질문 텍스트 이벤트 리스너 등록 완료');
            }
            
            if (expectedAnswer) {
                expectedAnswer.addEventListener('input', function() {
                    console.log('[DEBUG] 예상답변 텍스트 입력 이벤트 발생');
                    updateCharCount();
                    updatePreview();
                });
                console.log('[DEBUG] 예상답변 텍스트 이벤트 리스너 등록 완료');
            }
            
            categoryInputs.forEach(function(input, index) {
                input.addEventListener('change', function() {
                    console.log('[DEBUG] 카테고리 변경 이벤트 발생: ' + input.value);
                    updatePreview();
                });
            });
            console.log('[DEBUG] 카테고리 이벤트 리스너 등록 완료 (' + categoryInputs.length + '개)');
            
            difficultyInputs.forEach(function(input, index) {
                input.addEventListener('change', function() {
                    console.log('[DEBUG] 난이도 변경 이벤트 발생: ' + input.value);
                    updatePreview();
                });
            });
            console.log('[DEBUG] 난이도 이벤트 리스너 등록 완료 (' + difficultyInputs.length + '개)');
            
            // 폼 제출 이벤트
            if (form) {
                form.addEventListener('submit', function(e) {
                    console.log('[DEBUG] ========== 폼 제출 이벤트 발생 ==========');
                    console.log('[DEBUG] 폼 액션: ' + form.action);
                    console.log('[DEBUG] 폼 메소드: ' + form.method);
                    
                    if (!validateForm()) {
                        console.log('[DEBUG] ❌ 폼 검증 실패 - 제출 중단');
                        e.preventDefault();
                        return false;
                    }
                    
                    console.log('[DEBUG] ✅ 폼 검증 성공 - 서버로 제출');
                    
                    // 제출 버튼 비활성화
                    const submitBtn = document.getElementById('submitBtn');
                    if (submitBtn) {
                        submitBtn.disabled = true;
                        submitBtn.textContent = '처리 중...';
                        console.log('[DEBUG] 제출 버튼 비활성화');
                    }
                    
                    console.log('[DEBUG] ========== 폼 제출 완료 ==========');
                });
                console.log('[DEBUG] 폼 제출 이벤트 리스너 등록 완료');
            }
            
            console.log('[DEBUG] ========== 모든 이벤트 리스너 등록 완료 ==========');
        });
        
        console.log('[DEBUG] ========== interview_question_form.jsp 스크립트 로드 완료 ==========');
    </script>
</body>
</html>
