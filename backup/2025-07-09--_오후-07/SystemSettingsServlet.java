package com.example.controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.example.model.SystemSettings;
import com.example.model.SystemSettingsDAO;

@WebServlet("/settings")
public class SystemSettingsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private SystemSettingsDAO settingsDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        try {
            settingsDAO = new SystemSettingsDAO();
        } catch (Exception e) {
            System.err.println("SystemSettingsServlet 초기화 실패: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 세션 검증
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        try {
            switch (action) {
                case "list":
                    showSettingsList(request, response);
                    break;
                case "edit":
                    editSetting(request, response);
                    break;
                case "backup":
                    showBackupPage(request, response);
                    break;
                case "logs":
                    showSystemLogs(request, response);
                    break;
                default:
                    showSettingsList(request, response);
                    break;
            }
        } catch (Exception e) {
            System.err.println("SystemSettingsServlet GET 오류: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "시스템 오류가 발생했습니다: " + e.getMessage());
            showSettingsList(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        // 세션 검증
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) action = "update";
        
        try {
            switch (action) {
                case "update":
                    updateSettings(request, response);
                    break;
                case "backup":
                    performBackup(request, response);
                    break;
                case "reset":
                    resetSettings(request, response);
                    break;
                default:
                    showSettingsList(request, response);
                    break;
            }
        } catch (Exception e) {
            System.err.println("SystemSettingsServlet POST 오류: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "설정 업데이트 중 오류가 발생했습니다: " + e.getMessage());
            showSettingsList(request, response);
        }
    }
    
    private void showSettingsList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 모든 시스템 설정 조회
            Map<String, SystemSettings> allSettings = settingsDAO.getAllSettings();
            request.setAttribute("settings", allSettings);
            
            // 시스템 통계 정보
            Map<String, Object> systemStats = new HashMap<>();
            systemStats.put("totalSettings", allSettings.size());
            systemStats.put("javaVersion", System.getProperty("java.version"));
            systemStats.put("osName", System.getProperty("os.name"));
            systemStats.put("osVersion", System.getProperty("os.version"));
            systemStats.put("maxMemory", Runtime.getRuntime().maxMemory() / (1024 * 1024)); // MB
            systemStats.put("freeMemory", Runtime.getRuntime().freeMemory() / (1024 * 1024)); // MB
            systemStats.put("totalMemory", Runtime.getRuntime().totalMemory() / (1024 * 1024)); // MB
            
            request.setAttribute("systemStats", systemStats);
            
        } catch (Exception e) {
            System.err.println("설정 목록 조회 실패: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("settings", new HashMap<String, SystemSettings>());
            request.setAttribute("errorMessage", "설정을 불러오는데 실패했습니다: " + e.getMessage());
        }
        
        try {
            request.getRequestDispatcher("system_settings.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("JSP 포워딩 실패: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "페이지 로딩 실패: " + e.getMessage());
        }
    }
    
    private void editSetting(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String settingKey = request.getParameter("key");
        if (settingKey == null || settingKey.trim().isEmpty()) {
            response.sendRedirect("settings");
            return;
        }
        
        try {
            SystemSettings setting = settingsDAO.getSettingByKey(settingKey);
            if (setting == null) {
                request.setAttribute("errorMessage", "존재하지 않는 설정입니다: " + settingKey);
                showSettingsList(request, response);
                return;
            }
            
            request.setAttribute("setting", setting);
            request.getRequestDispatcher("system_settings_edit.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("설정 편집 페이지 로드 실패: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "설정 편집 페이지를 불러오는데 실패했습니다.");
            showSettingsList(request, response);
        }
    }
    
    private void updateSettings(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            String settingKey = request.getParameter("settingKey");
            String settingValue = request.getParameter("settingValue");
            String description = request.getParameter("description");
            
            if (settingKey == null || settingKey.trim().isEmpty()) {
                request.setAttribute("errorMessage", "설정 키가 필요합니다.");
                showSettingsList(request, response);
                return;
            }
            
            SystemSettings setting = new SystemSettings();
            setting.setSettingKey(settingKey.trim());
            setting.setSettingValue(settingValue != null ? settingValue.trim() : "");
            setting.setDescription(description != null ? description.trim() : "");
            setting.setCategory("SYSTEM");
            setting.setIsActive(true);
            
            boolean success = settingsDAO.updateSetting(setting);
            
            if (success) {
                HttpSession session = request.getSession();
                session.setAttribute("successMessage", "설정이 성공적으로 업데이트되었습니다.");
            } else {
                request.setAttribute("errorMessage", "설정 업데이트에 실패했습니다.");
            }
            
        } catch (Exception e) {
            System.err.println("설정 업데이트 중 오류: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "설정 업데이트 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        response.sendRedirect("settings");
    }
    
    private void showBackupPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 백업 관련 정보 준비
            Map<String, Object> backupInfo = new HashMap<>();
            backupInfo.put("lastBackupDate", "2025-06-27");
            backupInfo.put("backupSize", "2.5 MB");
            backupInfo.put("backupLocation", "/backup/system/");
            
            request.setAttribute("backupInfo", backupInfo);
            request.getRequestDispatcher("system_backup.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("백업 페이지 로드 실패: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "백업 페이지를 불러오는데 실패했습니다.");
            showSettingsList(request, response);
        }
    }
    
    private void showSystemLogs(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 시스템 로그 정보 (실제로는 파일에서 읽어와야 함)
            request.setAttribute("logs", "시스템 로그 기능은 준비 중입니다.");
            request.getRequestDispatcher("system_logs.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("시스템 로그 조회 실패: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "시스템 로그를 불러오는데 실패했습니다.");
            showSettingsList(request, response);
        }
    }
    
    private void performBackup(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 실제 백업 로직은 여기에 구현
            // 현재는 시뮬레이션
            Thread.sleep(1000); // 백업 시뮬레이션
            
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "시스템 백업이 성공적으로 완료되었습니다.");
            
        } catch (Exception e) {
            System.err.println("백업 수행 중 오류: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "백업 수행 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        response.sendRedirect("settings?action=backup");
    }
    
    private void resetSettings(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 설정 초기화 로직
            boolean success = settingsDAO.resetToDefaults();
            
            HttpSession session = request.getSession();
            if (success) {
                session.setAttribute("successMessage", "시스템 설정이 기본값으로 초기화되었습니다.");
            } else {
                session.setAttribute("errorMessage", "설정 초기화에 실패했습니다.");
            }
            
        } catch (Exception e) {
            System.err.println("설정 초기화 중 오류: " + e.getMessage());
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "설정 초기화 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        response.sendRedirect("settings");
    }
} 