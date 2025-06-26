<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${empty schedule ? '인터뷰 일정 등록' : '인터뷰 일정 수정'}</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .form-container {
            max-width: 600px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .form-title {
            text-align: center;
            margin-bottom: 30px;
            color: #333;
            font-size: 24px;
            font-weight: bold;
        }
        
        .form-row {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .form-row .form-group {
            flex: 1;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #333;
        }
        
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            box-sizing: border-box;
            transition: border-color 0.3s ease;
        }
        
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #007bff;
            box-shadow: 0 0 0 2px rgba(0,123,255,0.25);
        }
        
        .form-group textarea {
            height: 100px;
            resize: vertical;
        }
        
        .required {
            color: #dc3545;
        }
        
        .form-buttons {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-top: 30px;
        }
        
        .candidate-info {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 20px;
            border-left: 4px solid #007bff;
        }
        
        .time-conflict-warning {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            color: #856404;
            padding: 10px;
            border-radius: 6px;
            margin-bottom: 15px;
            display: none;
        }
        
        .duration-presets {
            display: flex;
            gap: 10px;
            margin-top: 5px;
            flex-wrap: wrap;
        }
        
        .duration-preset {
            padding: 5px 10px;
            background: #f8f9fa;
            border: 1px solid #ddd;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            transition: all 0.3s ease;
        }
        
        .duration-preset:hover {
            background: #e9ecef;
        }
        
        .duration-preset.active {
            background: #007bff;
            color: white;
            border-color: #007bff;
        }
        
        @media (max-width: 768px) {
            .form-row {
                flex-direction: column;
                gap: 0;
            }
            
            .form-container {
                margin: 10px;
                padding: 20px;
            }
            
            .duration-presets {
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>인터뷰 일정 관리</h1>
            <nav>
                <a href="../main.jsp">홈</a>
                <a href="../candidates">지원자 관리</a>
                <a href="list" class="active">일정 관리</a>
                <a href="../logout">로그아웃</a>
            </nav>
        </div>

        <div class="form-container">
            <h2 class="form-title">
                ${empty schedule ? '새 인터뷰 일정 등록' : '인터뷰 일정 수정'}
            </h2>

            <c:if test="${not empty error}">
                <div class="alert alert-error">${error}</div>
            </c:if>

            <div class="time-conflict-warning" id="conflictWarning">
                <strong>⚠️ 시간 충돌 경고:</strong> 해당 시간에 이미 다른 면접이 예정되어 있습니다.
            </div>

            <form method="post" action="${empty schedule ? 'add' : 'edit'}" onsubmit="return validateForm()">
                <c:if test="${not empty schedule}">
                    <input type="hidden" name="id" value="${schedule.id}">
                </c:if>

                <div class="form-group">
                    <label for="candidateId">지원자 <span class="required">*</span></label>
                    <select name="candidateId" id="candidateId" required onchange="updateCandidateInfo()">
                        <option value="">지원자를 선택하세요</option>
                        <c:forEach var="candidate" items="${candidates}">
                            <option value="${candidate.id}" 
                                    ${(not empty schedule && schedule.candidateId == candidate.id) || 
                                      (not empty selectedCandidateId && selectedCandidateId == candidate.id) ? 'selected' : ''}
                                    data-name="${candidate.name}"
                                    data-team="${candidate.team}"
                                    data-email="${candidate.email}">
                                ${candidate.name} (${candidate.team})
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="candidate-info" id="candidateInfo" style="display: none;">
                    <h4>선택된 지원자 정보</h4>
                    <p><strong>이름:</strong> <span id="candidateName"></span></p>
                    <p><strong>지원팀:</strong> <span id="candidateTeam"></span></p>
                    <p><strong>이메일:</strong> <span id="candidateEmail"></span></p>
                </div>

                <div class="form-group">
                    <label for="interviewerName">면접관 <span class="required">*</span></label>
                    <input type="text" name="interviewerName" id="interviewerName" 
                           value="${schedule.interviewerName}" required 
                           placeholder="면접관 이름을 입력하세요">
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="interviewDate">면접 날짜 <span class="required">*</span></label>
                        <input type="date" name="interviewDate" id="interviewDate" 
                               value="${schedule.interviewDateFormatted}" required
                               min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>"
                               onchange="checkTimeConflict()">
                    </div>
                    <div class="form-group">
                        <label for="interviewTime">면접 시간 <span class="required">*</span></label>
                        <input type="time" name="interviewTime" id="interviewTime" 
                               value="${schedule.interviewTimeFormatted}" required
                               onchange="checkTimeConflict()">
                    </div>
                </div>

                <div class="form-group">
                    <label for="duration">소요시간 (분) <span class="required">*</span></label>
                    <input type="number" name="duration" id="duration" 
                           value="${empty schedule ? '60' : schedule.duration}" 
                           min="15" max="480" required onchange="checkTimeConflict()">
                    <div class="duration-presets">
                        <span class="duration-preset" onclick="setDuration(30)">30분</span>
                        <span class="duration-preset active" onclick="setDuration(60)">1시간</span>
                        <span class="duration-preset" onclick="setDuration(90)">1시간 30분</span>
                        <span class="duration-preset" onclick="setDuration(120)">2시간</span>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="interviewType">면접 유형</label>
                        <select name="interviewType" id="interviewType">
                            <option value="기술면접" ${schedule.interviewType == '기술면접' ? 'selected' : ''}>기술면접</option>
                            <option value="인성면접" ${schedule.interviewType == '인성면접' ? 'selected' : ''}>인성면접</option>
                            <option value="임원면접" ${schedule.interviewType == '임원면접' ? 'selected' : ''}>임원면접</option>
                            <option value="화상면접" ${schedule.interviewType == '화상면접' ? 'selected' : ''}>화상면접</option>
                            <option value="전화면접" ${schedule.interviewType == '전화면접' ? 'selected' : ''}>전화면접</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="status">상태</label>
                        <select name="status" id="status">
                            <option value="scheduled" ${schedule.status == 'scheduled' || empty schedule ? 'selected' : ''}>예정</option>
                            <option value="in_progress" ${schedule.status == 'in_progress' ? 'selected' : ''}>진행중</option>
                            <option value="completed" ${schedule.status == 'completed' ? 'selected' : ''}>완료</option>
                            <option value="cancelled" ${schedule.status == 'cancelled' ? 'selected' : ''}>취소</option>
                            <option value="postponed" ${schedule.status == 'postponed' ? 'selected' : ''}>연기</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label for="location">면접 장소</label>
                    <input type="text" name="location" id="location" 
                           value="${schedule.location}" 
                           placeholder="예: 회의실 A, 화상회의, 임원실 등">
                </div>

                <div class="form-group">
                    <label for="notes">참고사항</label>
                    <textarea name="notes" id="notes" 
                              placeholder="면접 관련 특이사항이나 준비할 내용을 입력하세요">${schedule.notes}</textarea>
                </div>

                <div class="form-buttons">
                    <button type="submit" class="btn btn-primary">
                        ${empty schedule ? '등록' : '수정'}
                    </button>
                    <a href="list" class="btn btn-secondary">취소</a>
                </div>
            </form>
        </div>
    </div>

    <script>
        function updateCandidateInfo() {
            const select = document.getElementById('candidateId');
            const info = document.getElementById('candidateInfo');
            const option = select.options[select.selectedIndex];
            
            if (select.value) {
                document.getElementById('candidateName').textContent = option.dataset.name;
                document.getElementById('candidateTeam').textContent = option.dataset.team || '미지정';
                document.getElementById('candidateEmail').textContent = option.dataset.email || '미입력';
                info.style.display = 'block';
            } else {
                info.style.display = 'none';
            }
        }
        
        function setDuration(minutes) {
            document.getElementById('duration').value = minutes;
            
            // 활성 상태 업데이트
            document.querySelectorAll('.duration-preset').forEach(preset => {
                preset.classList.remove('active');
            });
            event.target.classList.add('active');
            
            checkTimeConflict();
        }
        
        function checkTimeConflict() {
            // 실제 구현에서는 AJAX로 서버에 시간 충돌 체크 요청
            // 여기서는 UI만 구현
        }
        
        function validateForm() {
            const candidateId = document.getElementById('candidateId').value;
            const interviewerName = document.getElementById('interviewerName').value.trim();
            const interviewDate = document.getElementById('interviewDate').value;
            const interviewTime = document.getElementById('interviewTime').value;
            const duration = document.getElementById('duration').value;
            
            if (!candidateId) {
                alert('지원자를 선택해주세요.');
                return false;
            }
            
            if (!interviewerName) {
                alert('면접관 이름을 입력해주세요.');
                return false;
            }
            
            if (!interviewDate) {
                alert('면접 날짜를 선택해주세요.');
                return false;
            }
            
            if (!interviewTime) {
                alert('면접 시간을 선택해주세요.');
                return false;
            }
            
            if (!duration || duration < 15) {
                alert('소요시간은 최소 15분 이상이어야 합니다.');
                return false;
            }
            
            // 과거 날짜 체크
            const selectedDate = new Date(interviewDate + 'T' + interviewTime);
            const now = new Date();
            
            if (selectedDate < now) {
                alert('과거 날짜/시간은 선택할 수 없습니다.');
                return false;
            }
            
            return true;
        }
        
        // 페이지 로드 시 지원자 정보 업데이트
        document.addEventListener('DOMContentLoaded', function() {
            updateCandidateInfo();
            
            // 기본 소요시간에 따른 프리셋 활성화
            const duration = document.getElementById('duration').value;
            document.querySelectorAll('.duration-preset').forEach(preset => {
                preset.classList.remove('active');
                if (preset.textContent.includes(duration + '분') || 
                    (duration == '60' && preset.textContent.includes('1시간')) ||
                    (duration == '90' && preset.textContent.includes('1시간 30분')) ||
                    (duration == '120' && preset.textContent.includes('2시간'))) {
                    preset.classList.add('active');
                }
            });
        });
    </script>
</body>
</html> 