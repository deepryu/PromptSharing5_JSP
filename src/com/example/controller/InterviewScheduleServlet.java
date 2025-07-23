package com.example.controller;

import com.example.model.InterviewSchedule;
import com.example.model.InterviewScheduleDAO;
import com.example.model.CandidateDAO;
import com.example.model.Candidate;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet("/interview/*")
public class InterviewScheduleServlet extends HttpServlet {
    private InterviewScheduleDAO scheduleDAO;
    private CandidateDAO candidateDAO;

    @Override
    public void init() throws ServletException {
        scheduleDAO = new InterviewScheduleDAO();
        candidateDAO = new CandidateDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/")) {
            pathInfo = "/list";
        }

        switch (pathInfo) {
            case "/list":
                listSchedules(request, response);
                break;
            case "/add":
                showAddForm(request, response);
                break;
            case "/edit":
                showEditForm(request, response);
                break;
            case "/detail":
                showScheduleDetail(request, response);
                break;
            case "/calendar":
                showCalendarView(request, response);
                break;
            case "/candidate":
                showCandidateSchedules(request, response);
                break;
            case "/delete":
                deleteSchedule(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        switch (pathInfo) {
            case "/add":
                addSchedule(request, response);
                break;
            case "/edit":
                updateSchedule(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                break;
        }
    }

    private void listSchedules(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String status = request.getParameter("status");
        String startDateParam = request.getParameter("startDate");
        String endDateParam = request.getParameter("endDate");
        String filter = request.getParameter("filter");

        // filter 파라미터 처리
        if ((startDateParam == null || startDateParam.isEmpty() || endDateParam == null || endDateParam.isEmpty()) 
            && filter != null && !filter.isEmpty()) {
            java.time.LocalDate today = java.time.LocalDate.now();
            switch (filter) {
                case "today":
                    startDateParam = endDateParam = today.toString();
                    break;
                case "week":
                    java.time.DayOfWeek firstDayOfWeek = java.time.DayOfWeek.MONDAY;
                    java.time.LocalDate weekStart = today.with(java.time.temporal.TemporalAdjusters.previousOrSame(firstDayOfWeek));
                    java.time.LocalDate weekEnd = weekStart.plusDays(6);
                    startDateParam = weekStart.toString();
                    endDateParam = weekEnd.toString();
                    break;
                case "month":
                    java.time.LocalDate monthStart = today.withDayOfMonth(1);
                    java.time.LocalDate monthEnd = today.withDayOfMonth(today.lengthOfMonth());
                    startDateParam = monthStart.toString();
                    endDateParam = monthEnd.toString();
                    break;
            }
        }

        List<InterviewSchedule> schedules;
        if (startDateParam != null && !startDateParam.isEmpty() && endDateParam != null && !endDateParam.isEmpty()) {
            try {
                Date start = Date.valueOf(startDateParam);
                Date end = Date.valueOf(endDateParam);
                schedules = scheduleDAO.getSchedulesByDateRange(start, end, status);
            } catch (IllegalArgumentException e) {
                schedules = scheduleDAO.getAllSchedules();
            }
        } else if (status != null && !status.isEmpty()) {
            schedules = scheduleDAO.getSchedulesByStatus(status);
        } else {
            schedules = scheduleDAO.getAllSchedules();
        }
        request.setAttribute("schedules", schedules);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedStartDate", startDateParam);
        request.setAttribute("selectedEndDate", endDateParam);
        request.getRequestDispatcher("/interview_schedules.jsp").forward(request, response);
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<Candidate> candidates = candidateDAO.getAllCandidates();
        request.setAttribute("candidates", candidates);
        
        String candidateId = request.getParameter("candidateId");
        if (candidateId != null) {
            request.setAttribute("selectedCandidateId", candidateId);
        }
        
        request.getRequestDispatcher("/interview_schedule_form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        InterviewSchedule schedule = scheduleDAO.getScheduleById(id);
        List<Candidate> candidates = candidateDAO.getAllCandidates();
        
        request.setAttribute("schedule", schedule);
        request.setAttribute("candidates", candidates);
        request.getRequestDispatcher("/interview_schedule_form.jsp").forward(request, response);
    }

    private void showScheduleDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        InterviewSchedule schedule = scheduleDAO.getScheduleById(id);
        
        if (schedule != null) {
            request.setAttribute("schedule", schedule);
            response.setContentType("text/html; charset=UTF-8");
            response.setCharacterEncoding("UTF-8");
            request.getRequestDispatcher("/interview_schedule_detail.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void showCalendarView(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<InterviewSchedule> schedules = scheduleDAO.getAllSchedules();
        request.setAttribute("schedules", schedules);
        request.getRequestDispatcher("/interview_calendar.jsp").forward(request, response);
    }

    private void showCandidateSchedules(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int candidateId = Integer.parseInt(request.getParameter("candidateId"));
        List<InterviewSchedule> schedules = scheduleDAO.getSchedulesByCandidateId(candidateId);
        Candidate candidate = candidateDAO.getCandidateById(candidateId);
        
        request.setAttribute("schedules", schedules);
        request.setAttribute("candidate", candidate);
        request.getRequestDispatcher("/candidate_schedules.jsp").forward(request, response);
    }

    private void addSchedule(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            InterviewSchedule schedule = createScheduleFromRequest(request);
            
            // 시간 충돌 체크
            if (scheduleDAO.hasTimeConflict(schedule.getInterviewDate(), 
                    schedule.getInterviewTime(), schedule.getDuration(), 0)) {
                request.setAttribute("error", "해당 시간에 이미 다른 면접이 예정되어 있습니다.");
                showAddForm(request, response);
                return;
            }
            
            if (scheduleDAO.addSchedule(schedule)) {
                String from = request.getParameter("from");
                if (from != null && from.equals("candidates")) {
                    response.sendRedirect(request.getContextPath() + "/candidates");
                } else {
                    response.sendRedirect(request.getContextPath() + "/interview/list");
                }
            } else {
                request.setAttribute("error", "일정 등록 중 오류가 발생했습니다.");
                showAddForm(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "잘못된 입력값입니다: " + e.getMessage());
            showAddForm(request, response);
        }
    }

    private void updateSchedule(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            InterviewSchedule schedule = createScheduleFromRequest(request);
            schedule.setId(id);
            
            // 시간 충돌 체크 (자기 자신 제외)
            if (scheduleDAO.hasTimeConflict(schedule.getInterviewDate(), 
                    schedule.getInterviewTime(), schedule.getDuration(), id)) {
                request.setAttribute("error", "해당 시간에 이미 다른 면접이 예정되어 있습니다.");
                showEditForm(request, response);
                return;
            }
            
            if (scheduleDAO.updateSchedule(schedule)) {
                String from = request.getParameter("from");
                if ("candidates".equals(from)) {
                    response.sendRedirect(request.getContextPath() + "/candidates");
                } else {
                    response.sendRedirect(request.getContextPath() + "/interview/list");
                }
            } else {
                request.setAttribute("error", "일정 수정 중 오류가 발생했습니다.");
                showEditForm(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "잘못된 입력값입니다: " + e.getMessage());
            showEditForm(request, response);
        }
    }

    private void deleteSchedule(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        
        if (scheduleDAO.deleteSchedule(id)) {
            response.sendRedirect(request.getContextPath() + "/interview/list");
        } else {
            request.setAttribute("error", "일정 삭제 중 오류가 발생했습니다.");
            listSchedules(request, response);
        }
    }

    private InterviewSchedule createScheduleFromRequest(HttpServletRequest request) 
            throws ParseException {
        InterviewSchedule schedule = new InterviewSchedule();
        
        schedule.setCandidateId(Integer.parseInt(request.getParameter("candidateId")));
        schedule.setInterviewerName(request.getParameter("interviewerName"));
        
        // 날짜 파싱
        String dateStr = request.getParameter("interviewDate");
        schedule.setInterviewDate(Date.valueOf(dateStr));
        
        // 시간 파싱
        String timeStr = request.getParameter("interviewTime");
        schedule.setInterviewTime(Time.valueOf(timeStr + ":00"));
        
        schedule.setDuration(Integer.parseInt(request.getParameter("duration")));
        schedule.setLocation(request.getParameter("location"));
        schedule.setInterviewType(request.getParameter("interviewType"));
        schedule.setStatus(request.getParameter("status"));
        schedule.setNotes(request.getParameter("notes"));
        
        return schedule;
    }
} 