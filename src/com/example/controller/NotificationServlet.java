package com.example.controller;

import com.example.model.*;
import com.example.util.DatabaseUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.util.List;

@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {
    
    private NotificationDAO notificationDAO = new NotificationDAO();
    private ActivityHistoryDAO activityDAO = new ActivityHistoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            if ("markRead".equals(action)) {
                int notificationId = Integer.parseInt(request.getParameter("id"));
                notificationDAO.markAsRead(notificationId);
                response.sendRedirect("notifications");
                return;
            }
            
            if ("markAllRead".equals(action)) {
                notificationDAO.markAllAsRead(username);
                response.sendRedirect("notifications");
                return;
            }
            
            if ("delete".equals(action)) {
                int notificationId = Integer.parseInt(request.getParameter("id"));
                notificationDAO.deleteNotification(notificationId);
                response.sendRedirect("notifications");
                return;
            }
            
            // 기본 페이지 - 알림 및 히스토리 표시
            loadNotificationsAndHistory(request, username);
            request.getRequestDispatcher("notifications.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "오류가 발생했습니다: " + e.getMessage());
            request.getRequestDispatcher("notifications.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            if ("createNotification".equals(action)) {
                String title = request.getParameter("title");
                String content = request.getParameter("content");
                String type = request.getParameter("type");
                String targetUser = request.getParameter("targetUser");
                
                if (targetUser != null && targetUser.trim().isEmpty()) {
                    targetUser = null; // 전체 사용자 대상
                }
                
                Notification notification = new Notification(title, content, type, targetUser, "system", null);
                boolean success = notificationDAO.addNotification(notification);
                
                if (success) {
                    // 알림 생성 활동 기록
                    activityDAO.logCreate(username, "notification", null, title, "시스템 알림 생성");
                    request.setAttribute("success", "알림이 성공적으로 생성되었습니다.");
                } else {
                    request.setAttribute("error", "알림 생성에 실패했습니다.");
                }
            }
            
            loadNotificationsAndHistory(request, username);
            request.getRequestDispatcher("notifications.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "오류가 발생했습니다: " + e.getMessage());
            loadNotificationsAndHistory(request, username);
            request.getRequestDispatcher("notifications.jsp").forward(request, response);
        }
    }
    
    private void loadNotificationsAndHistory(HttpServletRequest request, String username) {
        try {
            // 사용자 알림 목록 (최근 20개)
            List<Notification> userNotifications = notificationDAO.getNotificationsByUser(username, 20);
            request.setAttribute("userNotifications", userNotifications);
            
            // 읽지 않은 알림 수
            int unreadCount = notificationDAO.getUnreadCount(username);
            request.setAttribute("unreadCount", unreadCount);
            
            // 전체 알림 목록 (관리자용, 최근 50개)
            List<Notification> allNotifications = notificationDAO.getAllNotifications(50);
            request.setAttribute("allNotifications", allNotifications);
            
            // 최근 활동 히스토리 (최근 50개)
            List<ActivityHistory> recentActivities = activityDAO.getAllActivities(50);
            request.setAttribute("recentActivities", recentActivities);
            
            // 오늘의 활동
            List<ActivityHistory> todayActivities = activityDAO.getTodayActivities();
            request.setAttribute("todayActivities", todayActivities);
            
            // 최근 로그인 기록 (최근 20개)
            List<ActivityHistory> recentLogins = activityDAO.getRecentLogins(20);
            request.setAttribute("recentLogins", recentLogins);
            
            // 사용자별 활동 히스토리 (최근 30개)
            List<ActivityHistory> userActivities = activityDAO.getActivitiesByUser(username, 30);
            request.setAttribute("userActivities", userActivities);
            
            // 통계 정보
            calculateStatistics(request);
            
        } catch (Exception e) {
            // 데이터베이스 테이블이 없거나 기타 오류 발생 시 기본값 설정
            request.setAttribute("userNotifications", null);
            request.setAttribute("unreadCount", 0);
            request.setAttribute("allNotifications", null);
            request.setAttribute("recentActivities", null);
            request.setAttribute("todayActivities", null);
            request.setAttribute("recentLogins", null);
            request.setAttribute("userActivities", null);
            
            // 데이터베이스 테이블이 없는 경우를 체크
            if (e.getMessage() != null && (e.getMessage().contains("relation") || e.getMessage().contains("table") || e.getMessage().contains("does not exist"))) {
                request.setAttribute("error", "데이터베이스 테이블이 아직 생성되지 않았습니다. sql/create_notifications_tables.sql 파일을 실행해주세요.");
            } else {
                request.setAttribute("error", "데이터 로드 중 오류가 발생했습니다: " + e.getMessage());
            }
        }
    }
    
    private void calculateStatistics(HttpServletRequest request) {
        try (Connection conn = DatabaseUtil.getConnection()) {
            // 기본 통계 정보 계산
            request.setAttribute("totalNotifications", notificationDAO.getAllNotifications(1000).size());
            request.setAttribute("totalActivities", activityDAO.getAllActivities(1000).size());
            request.setAttribute("todayActivitiesCount", activityDAO.getTodayActivities().size());
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
