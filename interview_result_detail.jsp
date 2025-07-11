<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // 세션 검증
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>인터뷰 결과 상세보기 - 채용 관리 시스템</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/common.css">
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
        
        .btn-danger {
            background: #cf222e;
            color: white;
            border-color: #cf222e;
        }
        
        .btn-danger:hover {
            background: #b91c28;
            border-color: #b91c28;
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
            padding: 20px;
        }

        .detail-section {
            background: white;
            border: 1px solid #d0d7de;
            margin-bottom: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .section-header {
            background: #f6f8fa;
            padding: 12px 20px;
            border-bottom: 1px solid #d0d7de;
            font-weight: 600;
            font-size: 1rem;
            color: #24292f;
        }

        .section-content {
            padding: 20px;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1px;
            background: #d0d7de;
            border: 1px solid #d0d7de;
            margin-bottom: 20px;
        }

        .info-item {
            background: white;
            padding: 12px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.9rem;
        }

        .info-label {
            font-weight: 600;
            color: #24292f;
            margin-right: 10px;
        }

        .info-value {
            color: #656d76;
            text-align: right;
            flex: 1;
        }

        .score-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }

        .score-card {
            background: white;
            border: 1px solid #d0d7de;
            padding: 15px;
            text-align: center;
            border-radius: 3px;
        }

        .score-card.overall {
            background: #f6ffed;
            border-color: #52c41a;
        }

        .score-label {
            font-size: 0.85rem;
            color: #656d76;
            margin-bottom: 8px;
            font-weight: 500;
        }

        .score-value {
            font-size: 1.4rem;
            font-weight: 600;
            color: #0969da;
        }

        .score-card.overall .score-value {
            color: #1a7f37;
            font-size: 1.6rem;
        }

        .score-stars {
            color: #ffc107;
            font-size: 1.2rem;
            margin-bottom: 5px;
        }

        .status-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: 600;
            border: 1px solid;
        }

        .status-pending { 
            background: #fff8e1;
            color: #f57c00;
            border-color: #ffcc02;
        }
        
        .status-pass { 
            background: #dcfce7;
            color: #16a34a;
            border-color: #86efac;
        }
        
        .status-fail { 
            background: #fecaca;
            color: #dc2626;
            border-color: #fca5a5;
        }
        
        .status-hold { 
            background: #e0f2fe;
            color: #0288d1;
            border-color: #81d4fa;
        }

        .recommendation-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: 600;
            border: 1px solid;
        }

        .recommendation-yes { 
            background: #dcfce7;
            color: #16a34a;
            border-color: #86efac;
        }
        
        .recommendation-no { 
            background: #fecaca;
            color: #dc2626;
            border-color: #fca5a5;
        }

        .type-badge {
            background: #f6f8fa;
            color: #656d76;
            border: 1px solid #d0d7de;
            padding: 4px 8px;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: 500;
        }

        .comment-section {
            background: #f6f8fa;
            padding: 15px;
            border-radius: 3px;
            border-left: 4px solid #0969da;
        }

        .comment-title {
            font-weight: 600;
            color: #24292f;
            margin-bottom: 8px;
        }

        .comment-content {
            color: #656d76;
            line-height: 1.5;
            white-space: pre-line;
        }

        .action-buttons {
            text-align: center;
            padding: 20px 0;
            border-top: 1px solid #d0d7de;
            margin-top: 20px;
        }

        .action-buttons .btn {
            margin: 0 10px;
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
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h2>📝 인터뷰 결과 상세보기</h2>
            <div class="nav-buttons">
                <a href="main.jsp" class="btn">🏠 메인</a>
                <a href="results" class="btn">📋 결과 목록</a>
                <a href="candidates" class="btn">👥 지원자 관리</a>
                <a href="interview/list" class="btn">📅 일정 관리</a>
                <a href="logout" class="btn btn-danger">🚪 로그아웃</a>
            </div>
        </div>

        <div class="main-content">
            <div class="content-header">
                <h1>인터뷰 결과 상세 정보</h1>
            </div>
            <div class="content-body">
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-error">${errorMessage}</div>
                </c:if>

                <c:if test="${not empty result}">
                    <!-- 기본 정보 -->
                    <div class="detail-section">
                        <div class="section-header">
                            👤 기본 정보
                        </div>
                        <div class="section-content">
                            <div class="info-grid">
                                <div class="info-item">
                                    <span class="info-label">지원자명:</span>
                                    <span class="info-value">
                                        <a href="candidates?action=detail&id=${result.candidateId}" 
                                           style="color: #0969da; text-decoration: none;">
                                            ${result.candidateName}
                                        </a>
                                    </span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">면접관:</span>
                                    <span class="info-value">${result.interviewerName}</span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">면접일:</span>
                                    <span class="info-value">${result.interviewDateFormatted}</span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">면접 유형:</span>
                                    <span class="info-value">
                                        <span class="type-badge">${result.interviewType}</span>
                                    </span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">결과 상태:</span>
                                    <span class="info-value">
                                        <span class="status-badge ${result.resultStatusClass}">
                                            ${result.resultStatusDisplayName}
                                        </span>
                                    </span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">채용 추천:</span>
                                    <span class="info-value">
                                        <span class="recommendation-badge ${result.hireRecommendationClass}">
                                            ${result.hireRecommendationDisplayName}
                                        </span>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 점수 정보 -->
                    <div class="detail-section">
                        <div class="section-header">
                            📊 평가 점수
                        </div>
                        <div class="section-content">
                            <div class="score-section">
                                <c:if test="${result.overallScore != null}">
                                    <div class="score-card overall">
                                        <div class="score-label">전체 점수</div>
                                        <div class="score-stars">${result.overallScoreStars}</div>
                                        <div class="score-value">${result.overallScoreFormatted}점</div>
                                    </div>
                                </c:if>
                                
                                <c:if test="${result.technicalScore != null}">
                                    <div class="score-card">
                                        <div class="score-label">기술 역량</div>
                                        <div class="score-stars">${result.getScoreStars(result.technicalScore)}</div>
                                        <div class="score-value">${result.technicalScore}점</div>
                                    </div>
                                </c:if>
                                
                                <c:if test="${result.communicationScore != null}">
                                    <div class="score-card">
                                        <div class="score-label">의사소통</div>
                                        <div class="score-stars">${result.getScoreStars(result.communicationScore)}</div>
                                        <div class="score-value">${result.communicationScore}점</div>
                                    </div>
                                </c:if>
                                
                                <c:if test="${result.problemSolvingScore != null}">
                                    <div class="score-card">
                                        <div class="score-label">문제해결</div>
                                        <div class="score-stars">${result.getScoreStars(result.problemSolvingScore)}</div>
                                        <div class="score-value">${result.problemSolvingScore}점</div>
                                    </div>
                                </c:if>
                                
                                <c:if test="${result.attitudeScore != null}">
                                    <div class="score-card">
                                        <div class="score-label">태도/자세</div>
                                        <div class="score-stars">${result.getScoreStars(result.attitudeScore)}</div>
                                        <div class="score-value">${result.attitudeScore}점</div>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>

                    <!-- 상세 피드백 -->
                    <c:if test="${not empty result.detailedFeedback}">
                        <div class="detail-section">
                            <div class="section-header">
                                💬 면접관 피드백
                            </div>
                            <div class="section-content">
                                <div class="comment-section">
                                    <div class="comment-content">${result.detailedFeedback}</div>
                                </div>
                            </div>
                        </div>
                    </c:if>

                    <!-- 강점과 약점 -->
                    <c:if test="${not empty result.strengths || not empty result.weaknesses}">
                        <div class="detail-section">
                            <div class="section-header">
                                📝 평가 상세
                            </div>
                            <div class="section-content">
                                <c:if test="${not empty result.strengths}">
                                    <div class="comment-section" style="margin-bottom: 15px;">
                                        <div class="comment-title">💪 강점</div>
                                        <div class="comment-content">${result.strengths}</div>
                                    </div>
                                </c:if>
                                
                                <c:if test="${not empty result.weaknesses}">
                                    <div class="comment-section" style="margin-bottom: 15px; border-left-color: #ff6b6b;">
                                        <div class="comment-title">🔍 개선점</div>
                                        <div class="comment-content">${result.weaknesses}</div>
                                    </div>
                                </c:if>
                                
                                <c:if test="${not empty result.improvementSuggestions}">
                                    <div class="comment-section" style="border-left-color: #ffa500;">
                                        <div class="comment-title">💡 개선 제안</div>
                                        <div class="comment-content">${result.improvementSuggestions}</div>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </c:if>

                    <!-- 다음 단계 -->
                    <c:if test="${not empty result.nextStep}">
                        <div class="detail-section">
                            <div class="section-header">
                                🚀 다음 단계
                            </div>
                            <div class="section-content">
                                <div class="comment-section" style="border-left-color: #28a745;">
                                    <div class="comment-content">${result.nextStep}</div>
                                </div>
                            </div>
                        </div>
                    </c:if>

                    <!-- 메타 정보 -->
                    <div class="detail-section">
                        <div class="section-header">
                            📅 등록 정보
                        </div>
                        <div class="section-content">
                            <div class="info-grid">
                                <div class="info-item">
                                    <span class="info-label">등록일시:</span>
                                    <span class="info-value">${result.formattedCreatedAt}</span>
                                </div>
                                <c:if test="${not empty result.formattedUpdatedAt}">
                                    <div class="info-item">
                                        <span class="info-label">최종 수정:</span>
                                        <span class="info-value">${result.formattedUpdatedAt}</span>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>

                    <!-- 액션 버튼 -->
                    <div class="action-buttons">
                        <a href="results?action=edit&id=${result.id}" class="btn btn-primary">✏️ 수정</a>
                        <a href="results" class="btn btn-secondary">📋 목록으로</a>
                        <a href="results?action=delete&id=${result.id}" 
                           class="btn btn-danger"
                           onclick="return confirm('정말로 이 인터뷰 결과를 삭제하시겠습니까?');">🗑️ 삭제</a>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</body>
</html> 
