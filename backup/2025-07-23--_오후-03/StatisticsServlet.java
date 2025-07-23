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
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

@WebServlet("/statistics")
public class StatisticsServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 세션 검증
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            // 통계 데이터 수집
            Map<String, Object> statistics = gatherStatistics();
            Map<String, Object> monthlyStats = getMonthlyStatistics();
            Map<String, Object> interviewerStats = getInterviewerStatistics();
            Map<String, Object> candidateStats = getCandidateStatistics();
            
            // JSP로 데이터 전달
            request.setAttribute("statistics", statistics);
            request.setAttribute("monthlyStats", monthlyStats);
            request.setAttribute("interviewerStats", interviewerStats);
            request.setAttribute("candidateStats", candidateStats);
            
            request.getRequestDispatcher("statistics.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "통계 데이터를 가져오는 중 오류가 발생했습니다: " + e.getMessage());
            request.getRequestDispatcher("statistics.jsp").forward(request, response);
        }
    }
    
    private Map<String, Object> gatherStatistics() throws SQLException {
        Map<String, Object> stats = new HashMap<>();
        
        try (Connection conn = DatabaseUtil.getConnection()) {
            // 전체 통계
            stats.put("totalCandidates", getTotalCount(conn, "candidates"));
            stats.put("totalInterviewers", getTotalCount(conn, "interviewers WHERE is_active = true"));
            stats.put("totalSchedules", getTotalCount(conn, "interview_schedules"));
            stats.put("totalResults", getTotalCount(conn, "interview_results"));
            stats.put("totalQuestions", getTotalCount(conn, "interview_questions WHERE is_active = true"));
            stats.put("totalCriteria", getTotalCount(conn, "evaluation_criteria WHERE is_active = true"));
            
            // 이번 달 통계
            String currentMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
            stats.put("thisMonthSchedules", getMonthlyCount(conn, "interview_schedules", "interview_date", currentMonth));
            stats.put("thisMonthResults", getMonthlyCount(conn, "interview_results", "created_at", currentMonth));
            stats.put("thisMonthCandidates", getMonthlyCount(conn, "candidates", "created_at", currentMonth));
            
            // 상태별 통계
            stats.put("scheduledInterviews", getStatusCount(conn, "interview_schedules", "status", "SCHEDULED"));
            stats.put("completedInterviews", getStatusCount(conn, "interview_schedules", "status", "COMPLETED"));
            stats.put("canceledInterviews", getStatusCount(conn, "interview_schedules", "status", "CANCELED"));
            
            // 평가 결과 통계
            stats.put("passedCandidates", getStatusCount(conn, "interview_results", "result_status", "pass"));
            stats.put("failedCandidates", getStatusCount(conn, "interview_results", "result_status", "fail"));
            stats.put("pendingCandidates", getStatusCount(conn, "interview_results", "result_status", "pending"));
        }
        
        return stats;
    }
    
    private Map<String, Object> getMonthlyStatistics() throws SQLException {
        Map<String, Object> monthlyStats = new HashMap<>();
        List<Map<String, Object>> monthlyData = new ArrayList<>();
        
        try (Connection conn = DatabaseUtil.getConnection()) {
            String sql = "SELECT " +
                "TO_CHAR(interview_date, 'YYYY-MM') as month, " +
                "COUNT(*) as total_interviews, " +
                "COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END) as completed, " +
                "COUNT(CASE WHEN status = 'CANCELED' THEN 1 END) as canceled " +
                "FROM interview_schedules " +
                "WHERE interview_date >= CURRENT_DATE - INTERVAL '6 months' " +
                "GROUP BY TO_CHAR(interview_date, 'YYYY-MM') " +
                "ORDER BY month DESC " +
                "LIMIT 6";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                ResultSet rs = pstmt.executeQuery();
                while (rs.next()) {
                    Map<String, Object> monthData = new HashMap<>();
                    monthData.put("month", rs.getString("month"));
                    monthData.put("totalInterviews", rs.getInt("total_interviews"));
                    monthData.put("completed", rs.getInt("completed"));
                    monthData.put("canceled", rs.getInt("canceled"));
                    monthlyData.add(monthData);
                }
            }
        }
        
        monthlyStats.put("monthlyData", monthlyData);
        return monthlyStats;
    }
    
    private Map<String, Object> getInterviewerStatistics() throws SQLException {
        Map<String, Object> interviewerStats = new HashMap<>();
        List<Map<String, Object>> topInterviewers = new ArrayList<>();
        
        try (Connection conn = DatabaseUtil.getConnection()) {
            // interview_schedules 테이블에는 interviewer_name 컬럼만 있으므로 이름 기준으로 통계 생성
            String sql = "SELECT " +
                "isch.interviewer_name, " +
                "COUNT(DISTINCT isch.id) as total_interviews, " +
                "COUNT(DISTINCT ir.id) as total_evaluations, " +
                "AVG(CASE WHEN ir.overall_score IS NOT NULL THEN ir.overall_score END) as avg_score, " +
                "COUNT(CASE WHEN isch.status = 'completed' THEN 1 END) as completed_interviews " +
                "FROM interview_schedules isch " +
                "LEFT JOIN interview_results ir ON isch.interviewer_name = ir.interviewer_name " +
                "WHERE isch.interviewer_name IS NOT NULL AND isch.interviewer_name != '' " +
                "GROUP BY isch.interviewer_name " +
                "HAVING COUNT(DISTINCT isch.id) > 0 " +
                "ORDER BY total_interviews DESC, avg_score DESC NULLS LAST " +
                "LIMIT 10";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                ResultSet rs = pstmt.executeQuery();
                while (rs.next()) {
                    Map<String, Object> interviewer = new HashMap<>();
                    interviewer.put("name", rs.getString("interviewer_name"));
                    interviewer.put("department", "미확인"); // interviewers 테이블과 연결되지 않음
                    interviewer.put("totalInterviews", rs.getInt("total_interviews"));
                    interviewer.put("totalEvaluations", rs.getInt("total_evaluations"));
                    double avgScore = rs.getDouble("avg_score");
                    interviewer.put("avgScore", rs.wasNull() ? 0.0 : avgScore);
                    interviewer.put("completedInterviews", rs.getInt("completed_interviews"));
                    topInterviewers.add(interviewer);
                }
            }
        }
        
        interviewerStats.put("topInterviewers", topInterviewers);
        return interviewerStats;
    }
    
    private Map<String, Object> getCandidateStatistics() throws SQLException {
        Map<String, Object> candidateStats = new HashMap<>();
        
        try (Connection conn = DatabaseUtil.getConnection()) {
            // 팀별 분포 (position 대신 team 사용)
            List<Map<String, Object>> teamStats = new ArrayList<>();
            String teamSql = "SELECT " +
                "COALESCE(team, '미지정') as team, " +
                "COUNT(*) as count " +
                "FROM candidates " +
                "GROUP BY team " +
                "ORDER BY count DESC";
            
            try (PreparedStatement pstmt = conn.prepareStatement(teamSql)) {
                ResultSet rs = pstmt.executeQuery();
                while (rs.next()) {
                    Map<String, Object> stat = new HashMap<>();
                    stat.put("team", rs.getString("team"));
                    stat.put("count", rs.getInt("count"));
                    teamStats.add(stat);
                }
            }
            
            // 월별 지원자 등록 추이 (experience 대신)
            List<Map<String, Object>> monthlyRegistration = new ArrayList<>();
            String monthlySql = "SELECT " +
                "TO_CHAR(created_at, 'YYYY-MM') as month, " +
                "COUNT(*) as count " +
                "FROM candidates " +
                "WHERE created_at >= CURRENT_DATE - INTERVAL '6 months' " +
                "GROUP BY TO_CHAR(created_at, 'YYYY-MM') " +
                "ORDER BY month DESC " +
                "LIMIT 6";
            
            try (PreparedStatement pstmt = conn.prepareStatement(monthlySql)) {
                ResultSet rs = pstmt.executeQuery();
                while (rs.next()) {
                    Map<String, Object> stat = new HashMap<>();
                    stat.put("month", rs.getString("month"));
                    stat.put("count", rs.getInt("count"));
                    monthlyRegistration.add(stat);
                }
            }
            
            candidateStats.put("teamStats", teamStats);
            candidateStats.put("monthlyRegistration", monthlyRegistration);
        }
        
        return candidateStats;
    }
    
    private int getTotalCount(Connection conn, String table) throws SQLException {
        String sql = "SELECT COUNT(*) FROM " + table;
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            ResultSet rs = pstmt.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
    
    private int getMonthlyCount(Connection conn, String table, String dateColumn, String month) throws SQLException {
        String sql = "SELECT COUNT(*) FROM " + table + " WHERE TO_CHAR(" + dateColumn + ", 'YYYY-MM') = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, month);
            ResultSet rs = pstmt.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
    
    private int getStatusCount(Connection conn, String table, String column, String status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM " + table + " WHERE " + column + " = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            ResultSet rs = pstmt.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
} 