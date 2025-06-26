<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>인터뷰 일정 상세</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .detail-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 12px;
            margin-bottom: 30px;
            text-align: center;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .detail-header h1 {
            margin: 0;
            font-size: 2.2em;
            font-weight: 300;
        }
        
        .detail-header .subtitle {
            margin-top: 10px;
            opacity: 0.9;
            font-size: 1.1em;
        }
        
        .detail-content {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            margin-bottom: 20px;
        }
        
        .detail-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
        }
        
        .detail-section {
            border-left: 4px solid #667eea;
            padding-left: 20px;
        }
        
        .section-title {
            font-size: 1.3em;
            font-weight: 600;
            color: #333;
            margin-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
            padding-bottom: 8px;
        }
        
        .detail-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #f5f5f5;
        }
        
        .detail-item:last-child {
            border-bottom: none;
        }
        
        .detail-label {
            font-weight: 600;
            color: #555;
            min-width: 120px;
        }
        
        .detail-value {
            color: #333;
            font-weight: 500;
            text-align: right;
        }
        
        .schedule-status {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            text-align: center;
            display: inline-block;
        }
        
        .status-scheduled { background: #e3f2fd; color: #1976d2; }
        .status-in_progress { background: #fff3e0; color: #f57c00; }
        .status-completed { background: #e8f5e8; color: #388e3c; }
        .status-cancelled { background: #ffebee; color: #d32f2f; }
        .status-postponed { background: #f3e5f5; color: #7b1fa2; }
        
        .interview-type {
            background: #f8f9fa;
            color: #495057;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
        }
        
        .datetime-display {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            margin: 20px 0;
        }
        
        .date-time {
            font-size: 1.5em;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .duration-info {
            opacity: 0.9;
            font-size: 1.1em;
        }
        
        .notes-section {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-top: 20px;
        }
        
        .notes-content {
            line-height: 1.6;
            white-space: pre-wrap;
            color: #555;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 6px;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-block;
        }
        
        .btn-primary {
            background: #007bff;
            color: white;
        }
        
        .btn-primary:hover {
            background: #0056b3;
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #545b62;
        }
        
        .btn-danger {
            background: #dc3545;
            color: white;
        }
        
        .btn-danger:hover {
            background: #c82333;
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
        <div class="header">
            <h1>인터뷰 일정 상세</h1>
            <nav>
                <a href="main.jsp">홈</a>
                <a href="candidates">지원자 관리</a>
                <a href="interview/list" class="active">일정 관리</a>
                <a href="logout">로그아웃</a>
            </nav>
        </div>

        <c:choose>
            <c:when test="${not empty schedule}">
                <div class="detail-header">
                    <h1>인터뷰 일정</h1>
                    <div class="subtitle">
                        <a href="../candidates?action=detail&id=${schedule.candidateId}" class="candidate-link" style="color: white;">
                            ${schedule.candidateName}
                        </a>님과의 인터뷰
                    </div>
                </div>

                <div class="detail-content">
                    <div class="datetime-display">
                        <div class="date-time">
                            ${schedule.interviewDateFormatted} ${schedule.interviewTimeFormatted}
                        </div>
                        <div class="duration-info">
                            소요시간: ${schedule.durationFormatted}
                        </div>
                    </div>

                    <div class="detail-grid">
                        <div class="detail-section">
                            <div class="section-title">기본 정보</div>
                            
                            <div class="detail-item">
                                <span class="detail-label">지원자</span>
                                <span class="detail-value">
                                    <a href="../candidates?action=detail&id=${schedule.candidateId}" class="candidate-link">
                                        ${schedule.candidateName}
                                    </a>
                                </span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">면접관</span>
                                <span class="detail-value">${schedule.interviewerName}</span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">인터뷰 유형</span>
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
                            <div class="section-title">일정 상태</div>
                            
                            <div class="detail-item">
                                <span class="detail-label">현재 상태</span>
                                <span class="detail-value">
                                    <span class="schedule-status status-${schedule.status}">
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
                            <div class="section-title">메모</div>
                            <div class="notes-content">${schedule.notes}</div>
                        </div>
                    </c:if>
                </div>

                <div class="action-buttons">
                    <a href="edit?id=${schedule.id}" class="btn btn-primary">수정</a>
                    <a href="list" class="btn btn-secondary">목록으로</a>
                    <a href="delete?id=${schedule.id}" class="btn btn-danger" 
                       onclick="return confirm('정말 이 인터뷰 일정을 삭제하시겠습니까?')">삭제</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="detail-content" style="text-align: center; padding: 50px;">
                    <h2>인터뷰 일정을 찾을 수 없습니다</h2>
                    <p>요청하신 인터뷰 일정이 존재하지 않거나 삭제되었습니다.</p>
                    <a href="list" class="btn btn-primary">목록으로 돌아가기</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html> 