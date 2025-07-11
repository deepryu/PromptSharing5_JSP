<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    <title>인터뷰 일정 상세 - 채용 관리 시스템</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/common.css">
    <style>
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f0f0f0;
            min-height: 100vh;
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
            background: #da3633;
            color: white;
            border-color: #da3633;
        }
        
        .btn-danger:hover {
            background: #b92b27;
            border-color: #b92b27;
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
        
        .detail-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            margin-bottom: 30px;
        }
        
        .detail-section {
            border: 1px solid #d0d7de;
            border-radius: 3px;
            padding: 20px;
            background: #f6f8fa;
        }
        
        .section-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: #24292f;
            margin-bottom: 15px;
            padding-bottom: 8px;
            border-bottom: 1px solid #d0d7de;
        }
        
        .detail-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 0;
            border-bottom: 1px solid #eaeef2;
        }
        
        .detail-item:last-child {
            border-bottom: none;
        }
        
        .detail-label {
            font-weight: 600;
            color: #656d76;
            min-width: 120px;
        }
        
        .detail-value {
            color: #24292f;
            font-weight: 500;
            text-align: right;
        }
        
        .status-badge {
            padding: 4px 8px;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: 500;
            text-align: center;
            display: inline-block;
        }
        
        .status-scheduled { background: #dcfce7; color: #16a34a; }
        .status-completed { background: #dbeafe; color: #2563eb; }
        .status-cancelled { background: #fecaca; color: #dc2626; }
        .status-postponed { background: #f3e8ff; color: #7c3aed; }
        
        .interview-type {
            background: #f6f8fa;
            color: #656d76;
            padding: 4px 8px;
            border-radius: 3px;
            font-size: 0.75rem;
            border: 1px solid #d0d7de;
        }
        
        .datetime-display {
            background: #0078d4;
            color: white;
            padding: 20px;
            border-radius: 3px;
            text-align: center;
            margin: 20px 0;
            border: 1px solid #106ebe;
        }
        
        .date-time {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 5px;
        }
        
        .duration-info {
            opacity: 0.9;
            font-size: 1rem;
        }
        
        .notes-section {
            background: #f6f8fa;
            padding: 20px;
            border-radius: 3px;
            margin-top: 20px;
            border: 1px solid #d0d7de;
        }
        
        .notes-content {
            line-height: 1.6;
            white-space: pre-wrap;
            color: #24292f;
        }
        
        .action-buttons {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-top: 30px;
            flex-wrap: wrap;
            padding-top: 20px;
            border-top: 1px solid #d0d7de;
        }
        
        .candidate-link {
            color: #007bff;
            text-decoration: none;
            font-weight: 500;
        }
        
        .candidate-link:hover {
            text-decoration: underline;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 15px;
            }
            
            .detail-header {
                padding: 20px;
            }
            
            .detail-header h1 {
                font-size: 1.8em;
            }
            
            .detail-content {
                padding: 20px;
            }
            
            .detail-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }
            
            .action-buttons {
                flex-direction: column;
                align-items: center;
            }
            
            .btn {
                width: 100%;
                max-width: 200px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <h2>📊 채용 관리 시스템</h2>
            <div class="nav-buttons">
                <a href="${pageContext.request.contextPath}/main.jsp" class="btn">🏠 메인</a>
                <a href="${pageContext.request.contextPath}/interview/list" class="btn">📅 일정관리</a>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger">🚪 로그아웃</a>
            </div>
        </div>
        
        <div class="main-content">
            <div class="content-header">
                <h1>📅 인터뷰 일정 상세</h1>
            </div>
            <div class="content-body">
                <c:choose>
                    <c:when test="${not empty schedule}">
                    <div class="datetime-display">
                        <div class="date-time">
                            ${schedule.interviewDateFormatted} ${schedule.interviewTimeFormatted}
                        </div>
                        <div class="duration-info">
                            인터뷰시간: ${schedule.durationFormatted}
                        </div>
                    </div>

                    <div class="detail-grid">
                        <div class="detail-section">
                            <div class="section-title">후보자 정보</div>
                            
                            <div class="detail-item">
                                <span class="detail-label">후보자</span>
                                <span class="detail-value">
                                    <a href="${pageContext.request.contextPath}/candidates?action=detail&id=${schedule.candidateId}" class="candidate-link">
                                        ${schedule.candidateName}
                                    </a>
                                </span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">면접관</span>
                                <span class="detail-value">${schedule.interviewerName}</span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">면접 유형</span>
                                <span class="detail-value">
                                    <span class="interview-type">${schedule.interviewType}</span>
                                </span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">장소</span>
                                <span class="detail-value">${schedule.location}</span>
                            </div>
                        </div>

                        <div class="detail-section">
                            <div class="section-title">면접 정보</div>
                            
                            <div class="detail-item">
                                <span class="detail-label">면접 상태</span>
                                <span class="detail-value">
                                                                    <span class="status-badge status-${schedule.status}">
                                    ${schedule.statusDisplayName}
                                </span>
                                </span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">등록일</span>
                                <span class="detail-value">
                                    <fmt:formatDate value="${schedule.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                                </span>
                            </div>
                            
                            <c:if test="${not empty schedule.updatedAt}">
                                <div class="detail-item">
                                    <span class="detail-label">수정일</span>
                                    <span class="detail-value">
                                        <fmt:formatDate value="${schedule.updatedAt}" pattern="yyyy-MM-dd HH:mm"/>
                                    </span>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <c:if test="${not empty schedule.notes}">
                        <div class="notes-section">
                            <div class="section-title">면접 후기</div>
                            <div class="notes-content">${schedule.notes}</div>
                        </div>
                    </c:if>
                </div>

                    <div class="action-buttons">
                        <a href="${pageContext.request.contextPath}/interview/edit?id=${schedule.id}" class="btn btn-primary">✏️ 수정</a>
                        <a href="${pageContext.request.contextPath}/interview/list" class="btn btn-secondary">📋 목록으로</a>
                        <a href="${pageContext.request.contextPath}/interview/delete?id=${schedule.id}" class="btn btn-danger" 
                           onclick="return confirm('정말 삭제하시겠습니까?')">🗑️ 삭제</a>
                    </div>
            </c:when>
            <c:otherwise>
                <div style="text-align: center; padding: 50px;">
                    <h2>📅 인터뷰 일정을 찾을 수 없습니다</h2>
                    <p>요청하신 인터뷰 일정이 존재하지 않거나 삭제되었습니다</p>
                    <a href="${pageContext.request.contextPath}/interview/list" class="btn btn-primary">📋 목록으로 돌아가기</a>
                </div>
            </c:otherwise>
        </c:choose>
            </div>
        </div>
    </div>
</body>
</html> 
