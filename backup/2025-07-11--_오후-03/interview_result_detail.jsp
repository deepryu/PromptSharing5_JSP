<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.model.InterviewResult" %>
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
    <title>?명꽣酉?寃곌낵 ?곸꽭蹂닿린 - 梨꾩슜 愿由??쒖뒪??/title>
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
        
        .main-dashboard {
            background: white;
            border: 1px solid #d0d7de;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .dashboard-header {
            background: #0078d4;
            color: white;
            padding: 15px 25px;
            border-bottom: 1px solid #106ebe;
        }
        
        .dashboard-header h1 {
            margin: 0;
            font-size: 1.3rem;
            font-weight: 600;
        }
        
        .dashboard-content {
            padding: 20px;
        }

        .detail-container {
            background: white;
            border: 1px solid #d0d7de;
            margin-bottom: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .detail-header {
            background: #f6f8fa;
            padding: 12px 20px;
            border-bottom: 1px solid #d0d7de;
            font-weight: 600;
            font-size: 1rem;
            color: #24292f;
        }

        .detail-content {
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

        .score-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1px;
            background: #d0d7de;
            border: 1px solid #d0d7de;
            margin-bottom: 20px;
        }

        .score-item {
            background: white;
            padding: 15px 20px;
            text-align: center;
        }

        .score-item.overall-score {
            background: #f6ffed;
            border-left: 4px solid #52c41a;
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

        .overall-score .score-value {
            color: #1a7f37;
            font-size: 1.6rem;
        }

        .status-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .status-pending { 
            background: #fef3c7;
            color: #d97706;
            border: 1px solid #fcd34d;
        }
        .status-pass { 
            background: #dcfce7;
            color: #16a34a;
            border: 1px solid #86efac;
        }
        .status-fail { 
            background: #fee2e2;
            color: #dc2626;
            border: 1px solid #fca5a5;
        }
        .status-hold { 
            background: #f3e8ff;
            color: #9333ea;
            border: 1px solid #c4b5fd;
        }

        .recommendation-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .recommendation-yes { 
            background: #dcfce7;
            color: #16a34a;
            border: 1px solid #86efac;
        }
        .recommendation-no { 
            background: #fee2e2;
            color: #dc2626;
            border: 1px solid #fca5a5;
        }

        .text-section {
            margin-bottom: 20px;
        }

        .text-content {
            background: #f6f8fa;
            border: 1px solid #d0d7de;
            padding: 15px;
            min-height: 60px;
            white-space: pre-wrap;
            font-family: inherit;
            font-size: 0.9rem;
            color: #24292f;
        }

        .empty-content {
            color: #656d76;
            font-style: italic;
        }

        .action-buttons {
            display: flex;
            gap: 10px;
            padding: 20px;
            background: #f6f8fa;
            border-top: 1px solid #d0d7de;
            margin: 20px -20px -20px -20px;
        }

        .btn {
            padding: 8px 16px;
            border-radius: 3px;
            font-weight: 500;
            text-decoration: none;
            border: 1px solid #d0d7de;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 0.85rem;
        }

        .btn-primary {
            background: #0078d4;
            color: white;
            border-color: #106ebe;
        }

        .btn-primary:hover {
            background: #106ebe;
        }

        .btn-secondary {
            background: white;
            color: #24292f;
            border-color: #d0d7de;
        }

        .btn-secondary:hover {
            background: #f6f8fa;
            border-color: #8c959f;
        }

        .btn-danger {
            background: #dc2626;
            color: white;
            border-color: #b91c1c;
        }

        .btn-danger:hover {
            background: #b91c1c;
        }

        .alert {
            padding: 12px 16px;
            margin-bottom: 20px;
            border-radius: 3px;
            border: 1px solid;
            font-size: 0.9rem;
        }

        .alert-success {
            background: #dcfce7;
            color: #16a34a;
            border-color: #86efac;
        }

        .alert-error {
            background: #fee2e2;
            color: #dc2626;
            border-color: #fca5a5;
        }

        .metadata {
            font-size: 0.8rem;
            color: #656d76;
            padding-top: 15px;
            border-top: 1px solid #d0d7de;
            text-align: center;
        }

        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }
            
            .top-bar {
                margin: -10px -10px 20px -10px;
                padding: 12px;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
            
            .score-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .action-buttons {
                flex-direction: column;
                margin: 20px -10px -10px -10px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h2>?뱤 梨꾩슜 愿由??쒖뒪??/h2>
        </div>

        <div class="main-dashboard">
            <div class="dashboard-header">
                <h1>?명꽣酉?寃곌낵 ?곸꽭蹂닿린</h1>
            </div>
            
            <div class="dashboard-content">
                <!-- ?깃났/?ㅻ쪟 硫붿떆吏 -->
                <c:if test="${not empty successMessage}">
                    <div class="alert alert-success">
                        ${successMessage}
                    </div>
                </c:if>
                
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-error">
                        ${errorMessage}
                    </div>
                </c:if>

                <c:if test="${not empty result}">
                    <!-- 湲곕낯 ?뺣낫 -->
                    <div class="detail-container">
                        <div class="detail-header">湲곕낯 ?뺣낫</div>
                        <div class="detail-content">
                            <div class="info-grid">
                                <div class="info-item">
                                    <span class="info-label">吏?먯옄紐?</span>
                                    <span class="info-value">${result.candidateName}</span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">硫댁젒愿:</span>
                                    <span class="info-value">${result.interviewerName}</span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">硫댁젒?쇱옄:</span>
                                    <span class="info-value">${result.interviewDateFormatted}</span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">硫댁젒?좏삎:</span>
                                    <span class="info-value">${result.interviewType}</span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">寃곌낵?곹깭:</span>
                                    <span class="info-value">
                                        <span class="status-badge status-${result.resultStatus}">${result.resultStatusDisplayName}</span>
                                    </span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">梨꾩슜異붿쿇:</span>
                                    <span class="info-value">
                                        <span class="recommendation-badge recommendation-${result.hireRecommendation}">${result.hireRecommendationDisplayName}</span>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ?됯? ?먯닔 -->
                    <div class="detail-container">
                        <div class="detail-header">?됯? ?먯닔</div>
                        <div class="detail-content">
                            <div class="score-grid">
                                <div class="score-item">
                                    <div class="score-label">湲곗닠??웾</div>
                                    <div class="score-value">${result.technicalScore != null ? result.technicalScore : '誘명룊媛'}</div>
                                </div>
                                <div class="score-item">
                                    <div class="score-label">?섏궗?뚰넻</div>
                                    <div class="score-value">${result.communicationScore != null ? result.communicationScore : '誘명룊媛'}</div>
                                </div>
                                <div class="score-item">
                                    <div class="score-label">臾몄젣?닿껐</div>
                                    <div class="score-value">${result.problemSolvingScore != null ? result.problemSolvingScore : '誘명룊媛'}</div>
                                </div>
                                <div class="score-item">
                                    <div class="score-label">?낅Т?쒕룄</div>
                                    <div class="score-value">${result.attitudeScore != null ? result.attitudeScore : '誘명룊媛'}</div>
                                </div>
                                <div class="score-item overall-score">
                                    <div class="score-label">醫낇빀?먯닔</div>
                                    <div class="score-value">${result.overallScoreFormatted}</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ?됯? ?댁슜 -->
                    <div class="detail-container">
                        <div class="detail-header">?됯? ?댁슜</div>
                        <div class="detail-content">
                            <div class="text-section">
                                <div class="info-label">媛뺤젏</div>
                                <div class="text-content">
                                    <c:choose>
                                        <c:when test="${not empty result.strengths}">
                                            ${result.strengths}
                                        </c:when>
                                        <c:otherwise>
                                            <span class="empty-content">媛뺤젏??????됯?媛 ?낅젰?섏? ?딆븯?듬땲??</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="text-section">
                                <div class="info-label">?쎌젏</div>
                                <div class="text-content">
                                    <c:choose>
                                        <c:when test="${not empty result.weaknesses}">
                                            ${result.weaknesses}
                                        </c:when>
                                        <c:otherwise>
                                            <span class="empty-content">?쎌젏??????됯?媛 ?낅젰?섏? ?딆븯?듬땲??</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="text-section">
                                <div class="info-label">?곸꽭 ?쇰뱶諛?/div>
                                <div class="text-content">
                                    <c:choose>
                                        <c:when test="${not empty result.detailedFeedback}">
                                            ${result.detailedFeedback}
                                        </c:when>
                                        <c:otherwise>
                                            <span class="empty-content">?곸꽭 ?쇰뱶諛깆씠 ?낅젰?섏? ?딆븯?듬땲??</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="text-section">
                                <div class="info-label">媛쒖꽑 ?쒖븞?ы빆</div>
                                <div class="text-content">
                                    <c:choose>
                                        <c:when test="${not empty result.improvementSuggestions}">
                                            ${result.improvementSuggestions}
                                        </c:when>
                                        <c:otherwise>
                                            <span class="empty-content">媛쒖꽑 ?쒖븞?ы빆???낅젰?섏? ?딆븯?듬땲??</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <c:if test="${not empty result.nextStep}">
                                <div class="text-section">
                                    <div class="info-label">?ㅼ쓬 ?④퀎</div>
                                    <div class="text-content">${result.nextStep}</div>
                                </div>
                            </c:if>

                            <div class="metadata">
                                ?깅줉?? ${result.formattedCreatedAt} | ?섏젙?? ${result.formattedUpdatedAt}
                            </div>
                        </div>
                    </div>
                </c:if>

                <c:if test="${empty result}">
                    <div class="alert alert-error">
                        ?명꽣酉?寃곌낵瑜?李얠쓣 ???놁뒿?덈떎.
                    </div>
                </c:if>

                <!-- ?≪뀡 踰꾪듉 -->
                <div class="action-buttons">
                    <a href="results" class="btn btn-secondary">
                        ??紐⑸줉?쇰줈
                    </a>
                    
                    <c:if test="${not empty result}">
                        <a href="results?action=edit&id=${result.id}" class="btn btn-primary">
                            ?륅툘 ?섏젙
                        </a>
                        
                        <a href="results?action=delete&id=${result.id}" class="btn btn-danger" 
                           onclick="return confirm('?뺣쭚濡????명꽣酉?寃곌낵瑜???젣?섏떆寃좎뒿?덇퉴?')">
                            ?뿊截???젣
                        </a>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</body>
</html> 
