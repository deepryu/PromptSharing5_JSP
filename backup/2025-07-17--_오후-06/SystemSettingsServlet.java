package com.example.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.example.model.SystemSettings;
import com.example.model.SystemSettingsDAO;
import com.example.util.BackupManagerUtil;
import com.example.util.SystemLogUtil;

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
            // 초기화 실패 시 조용히 처리
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
                case "deleteBackup":
                    deleteBackupFile(request, response);
                    break;
                case "reset":
                    resetSettings(request, response);
                    break;
                default:
                    showSettingsList(request, response);
                    break;
            }
        } catch (Exception e) {
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
            request.setAttribute("settings", new HashMap<String, SystemSettings>());
            request.setAttribute("errorMessage", "설정을 불러오는데 실패했습니다: " + e.getMessage());
        }
        
        try {
            request.getRequestDispatcher("system_settings.jsp").forward(request, response);
        } catch (Exception e) {
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
            request.setAttribute("errorMessage", "설정 업데이트 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        response.sendRedirect("settings");
    }
    
    private void showBackupPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 백업 파일 목록 조회
            List<Map<String, Object>> backupFiles = BackupManagerUtil.getBackupFiles();
            Map<String, Object> systemInfo = BackupManagerUtil.getSystemInfo();
            
            response.setContentType("text/html; charset=UTF-8");
            response.setCharacterEncoding("UTF-8");
            
            PrintWriter out = response.getWriter();
            out.println(generateBackupHTML(backupFiles, systemInfo));
            
        } catch (Exception e) {
            request.setAttribute("errorMessage", "백업 페이지를 불러오는데 실패했습니다.");
            showSettingsList(request, response);
        }
    }
    
    private void showSystemLogs(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 파라미터 처리
            String level = request.getParameter("level");
            String keyword = request.getParameter("keyword");
            String limitStr = request.getParameter("limit");
            
            int limit = 50;
            if (limitStr != null && !limitStr.isEmpty()) {
                try {
                    limit = Integer.parseInt(limitStr);
                } catch (NumberFormatException e) {
                    limit = 50;
                }
            }
            
            // 시스템 로그 및 통계 조회
            List<SystemLogUtil.LogEntry> logs;
            if (keyword != null && !keyword.trim().isEmpty()) {
                logs = SystemLogUtil.searchLogs(keyword, level, limit);
            } else {
                logs = SystemLogUtil.getSystemLogs(level, limit);
            }
            
            Map<String, Object> logStats = SystemLogUtil.getLogStatistics();
            Map<String, Object> systemStatus = SystemLogUtil.getSystemStatus();
            List<Map<String, Object>> logFiles = SystemLogUtil.getLogFiles();
            
            response.setContentType("text/html; charset=UTF-8");
            response.setCharacterEncoding("UTF-8");
            
            PrintWriter out = response.getWriter();
            out.println(generateSystemLogsHTML(logs, logStats, systemStatus, logFiles, level, keyword, limit));
            
        } catch (Exception e) {
            request.setAttribute("errorMessage", "시스템 로그를 불러오는데 실패했습니다.");
            showSettingsList(request, response);
        }
    }
    
    private void performBackup(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            String backupFileName = BackupManagerUtil.createDatabaseBackup();
            
            HttpSession session = request.getSession();
            if (backupFileName != null) {
                session.setAttribute("successMessage", "데이터베이스 백업이 성공적으로 생성되었습니다: " + backupFileName);
            } else {
                session.setAttribute("errorMessage", "백업 생성에 실패했습니다.");
            }
            
            response.sendRedirect("settings?action=backup");
            
        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "백업 생성 중 오류가 발생했습니다: " + e.getMessage());
            response.sendRedirect("settings?action=backup");
        }
    }
    
    private void deleteBackupFile(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            String fileName = request.getParameter("fileName");
            if (fileName != null && !fileName.isEmpty()) {
                boolean success = BackupManagerUtil.deleteBackupFile(fileName);
                
                HttpSession session = request.getSession();
                if (success) {
                    session.setAttribute("successMessage", "백업 파일이 삭제되었습니다: " + fileName);
                } else {
                    session.setAttribute("errorMessage", "백업 파일 삭제에 실패했습니다.");
                }
            }
            
            response.sendRedirect("settings?action=backup");
            
        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "백업 파일 삭제 중 오류가 발생했습니다: " + e.getMessage());
            response.sendRedirect("settings?action=backup");
        }
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
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "설정 초기화 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        response.sendRedirect("settings");
    }
    
    /**
     * 백업 관리 페이지 HTML 생성
     */
    private String generateBackupHTML(List<Map<String, Object>> backupFiles, Map<String, Object> systemInfo) {
        StringBuilder html = new StringBuilder();
        
        html.append("<!DOCTYPE html>\n");
        html.append("<html lang=\"ko\">\n");
        html.append("<head>\n");
        html.append("    <meta charset=\"UTF-8\">\n");
        html.append("    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n");
        html.append("    <title>백업 관리 - 시스템 설정</title>\n");
        html.append("    <link rel=\"icon\" type=\"image/x-icon\" href=\"favicon.ico\">\n");
        html.append("    <style>\n");
        html.append(getCommonCSS());
        html.append("    </style>\n");
        html.append("</head>\n");
        html.append("<body>\n");
        
        // 네비게이션
        html.append("    <div class=\"top-bar\">\n");
        html.append("        <div class=\"nav-links\">\n");
        html.append("            <a href=\"main.jsp\" class=\"nav-link\">🏠 메인</a>\n");
        html.append("            <a href=\"settings\" class=\"nav-link\">⚙️ 시스템 설정</a>\n");
        html.append("            <a href=\"admin/dashboard\" class=\"nav-link\">🛠️ 대시보드</a>\n");
        html.append("            <a href=\"logout\" class=\"nav-link logout\">🚪 로그아웃</a>\n");
        html.append("        </div>\n");
        html.append("    </div>\n");
        
        html.append("    <div class=\"container\">\n");
        html.append("        <div class=\"main-dashboard\">\n");
        html.append("            <div class=\"dashboard-header\">\n");
        html.append("                <h1>💾 백업 관리</h1>\n");
        html.append("            </div>\n");
        html.append("            <div class=\"dashboard-content\">\n");
        
        // 시스템 정보
        html.append("                <div class=\"stats-grid\">\n");
        html.append("                    <div class=\"stat-item\">\n");
        html.append("                        <div class=\"stat-number\">").append(systemInfo.getOrDefault("totalMemory", 0)).append("MB</div>\n");
        html.append("                        <div class=\"stat-label\">총 메모리</div>\n");
        html.append("                    </div>\n");
        html.append("                    <div class=\"stat-item\">\n");
        html.append("                        <div class=\"stat-number\">").append(systemInfo.getOrDefault("usedMemory", 0)).append("MB</div>\n");
        html.append("                        <div class=\"stat-label\">사용 메모리</div>\n");
        html.append("                    </div>\n");
        html.append("                    <div class=\"stat-item\">\n");
        html.append("                        <div class=\"stat-number\">").append(systemInfo.getOrDefault("dbName", "PostgreSQL")).append("</div>\n");
        html.append("                        <div class=\"stat-label\">데이터베이스</div>\n");
        html.append("                    </div>\n");
        html.append("                    <div class=\"stat-item\">\n");
        html.append("                        <div class=\"stat-number\">").append(backupFiles.size()).append("개</div>\n");
        html.append("                        <div class=\"stat-label\">백업 파일</div>\n");
        html.append("                    </div>\n");
        html.append("                </div>\n");
        
        // 백업 생성 버튼
        html.append("                <div style=\"margin: 20px 0; text-align: center;\">\n");
        html.append("                    <form method=\"post\" action=\"settings\" style=\"display: inline;\">\n");
        html.append("                        <input type=\"hidden\" name=\"action\" value=\"backup\">\n");
        html.append("                        <button type=\"submit\" class=\"btn-primary\" onclick=\"return confirm('새 백업을 생성하시겠습니까?');\">\n");
        html.append("                            💾 새 백업 생성\n");
        html.append("                        </button>\n");
        html.append("                    </form>\n");
        html.append("                </div>\n");
        
        // 백업 파일 목록
        html.append("                <div class=\"data-table\">\n");
        html.append("                    <div class=\"table-header\">\n");
        html.append("                        <h3>백업 파일 목록</h3>\n");
        html.append("                    </div>\n");
        
        if (backupFiles.isEmpty()) {
            html.append("                    <div class=\"empty-state\">\n");
            html.append("                        <h3>📁 백업 파일이 없습니다</h3>\n");
            html.append("                        <p>새 백업을 생성해주세요.</p>\n");
            html.append("                    </div>\n");
        } else {
            html.append("                    <table>\n");
            html.append("                        <thead>\n");
            html.append("                            <tr>\n");
            html.append("                                <th>파일명</th>\n");
            html.append("                                <th>크기</th>\n");
            html.append("                                <th>생성 시간</th>\n");
            html.append("                                <th>작업</th>\n");
            html.append("                            </tr>\n");
            html.append("                        </thead>\n");
            html.append("                        <tbody>\n");
            
            for (Map<String, Object> file : backupFiles) {
                html.append("                            <tr>\n");
                html.append("                                <td>").append(file.get("name")).append("</td>\n");
                html.append("                                <td>").append(file.get("size")).append("</td>\n");
                html.append("                                <td>").append(file.get("lastModified")).append("</td>\n");
                html.append("                                <td>\n");
                html.append("                                    <form method=\"post\" action=\"settings\" style=\"display: inline;\">\n");
                html.append("                                        <input type=\"hidden\" name=\"action\" value=\"deleteBackup\">\n");
                html.append("                                        <input type=\"hidden\" name=\"fileName\" value=\"").append(file.get("name")).append("\">\n");
                html.append("                                        <button type=\"submit\" class=\"btn-secondary\" onclick=\"return confirm('이 백업 파일을 삭제하시겠습니까?');\">\n");
                html.append("                                            🗑️ 삭제\n");
                html.append("                                        </button>\n");
                html.append("                                    </form>\n");
                html.append("                                </td>\n");
                html.append("                            </tr>\n");
            }
            
            html.append("                        </tbody>\n");
            html.append("                    </table>\n");
        }
        
        html.append("                </div>\n");
        html.append("            </div>\n");
        html.append("        </div>\n");
        html.append("    </div>\n");
        html.append("</body>\n");
        html.append("</html>\n");
        
        return html.toString();
    }
    
    /**
     * 시스템 로그 페이지 HTML 생성
     */
    private String generateSystemLogsHTML(List<SystemLogUtil.LogEntry> logs, Map<String, Object> logStats, 
                                         Map<String, Object> systemStatus, List<Map<String, Object>> logFiles,
                                         String level, String keyword, int limit) {
        StringBuilder html = new StringBuilder();
        
        html.append("<!DOCTYPE html>\n");
        html.append("<html lang=\"ko\">\n");
        html.append("<head>\n");
        html.append("    <meta charset=\"UTF-8\">\n");
        html.append("    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n");
        html.append("    <title>시스템 로그 - 시스템 설정</title>\n");
        html.append("    <link rel=\"icon\" type=\"image/x-icon\" href=\"favicon.ico\">\n");
        html.append("    <style>\n");
        html.append(getCommonCSS());
        html.append("        .log-entry { margin: 5px 0; padding: 8px; border-left: 3px solid #ddd; }\n");
        html.append("        .log-info { border-left-color: #17a2b8; }\n");
        html.append("        .log-warn { border-left-color: #ffc107; }\n");
        html.append("        .log-error { border-left-color: #dc3545; }\n");
        html.append("        .log-debug { border-left-color: #6c757d; }\n");
        html.append("        .log-timestamp { font-size: 0.9em; color: #666; }\n");
        html.append("        .log-level { font-weight: bold; margin-right: 10px; }\n");
        html.append("        .search-form { background: #f8f9fa; padding: 15px; margin: 20px 0; border-radius: 5px; }\n");
        html.append("    </style>\n");
        html.append("</head>\n");
        html.append("<body>\n");
        
        // 네비게이션
        html.append("    <div class=\"top-bar\">\n");
        html.append("        <div class=\"nav-links\">\n");
        html.append("            <a href=\"main.jsp\" class=\"nav-link\">🏠 메인</a>\n");
        html.append("            <a href=\"settings\" class=\"nav-link\">⚙️ 시스템 설정</a>\n");
        html.append("            <a href=\"admin/dashboard\" class=\"nav-link\">🛠️ 대시보드</a>\n");
        html.append("            <a href=\"logout\" class=\"nav-link logout\">🚪 로그아웃</a>\n");
        html.append("        </div>\n");
        html.append("    </div>\n");
        
        html.append("    <div class=\"container\">\n");
        html.append("        <div class=\"main-dashboard\">\n");
        html.append("            <div class=\"dashboard-header\">\n");
        html.append("                <h1>📋 시스템 로그</h1>\n");
        html.append("            </div>\n");
        html.append("            <div class=\"dashboard-content\">\n");
        
        // 시스템 상태
        html.append("                <div class=\"stats-grid\">\n");
        html.append("                    <div class=\"stat-item\">\n");
        html.append("                        <div class=\"stat-number\">").append(systemStatus.get("memoryUsage")).append("%</div>\n");
        html.append("                        <div class=\"stat-label\">메모리 사용률</div>\n");
        html.append("                    </div>\n");
        html.append("                    <div class=\"stat-item\">\n");
        html.append("                        <div class=\"stat-number\">").append(systemStatus.get("cpuUsage")).append("%</div>\n");
        html.append("                        <div class=\"stat-label\">CPU 사용률</div>\n");
        html.append("                    </div>\n");
        html.append("                    <div class=\"stat-item\">\n");
        html.append("                        <div class=\"stat-number\">").append(systemStatus.get("activeThreads")).append("개</div>\n");
        html.append("                        <div class=\"stat-label\">활성 스레드</div>\n");
        html.append("                    </div>\n");
        html.append("                    <div class=\"stat-item\">\n");
        html.append("                        <div class=\"stat-number\">").append(systemStatus.get("databaseStatus")).append("</div>\n");
        html.append("                        <div class=\"stat-label\">DB 상태</div>\n");
        html.append("                    </div>\n");
        html.append("                </div>\n");
        
        // 로그 검색 폼
        html.append("                <form method=\"get\" action=\"settings\" class=\"search-form\">\n");
        html.append("                    <input type=\"hidden\" name=\"action\" value=\"logs\">\n");
        html.append("                    <div style=\"display: flex; gap: 15px; align-items: center; flex-wrap: wrap;\">\n");
        html.append("                        <div>\n");
        html.append("                            <label>로그 레벨:</label>\n");
        html.append("                            <select name=\"level\">\n");
        html.append("                                <option value=\"ALL\"").append("ALL".equals(level) ? " selected" : "").append(">전체</option>\n");
        html.append("                                <option value=\"INFO\"").append("INFO".equals(level) ? " selected" : "").append(">INFO</option>\n");
        html.append("                                <option value=\"WARN\"").append("WARN".equals(level) ? " selected" : "").append(">WARN</option>\n");
        html.append("                                <option value=\"ERROR\"").append("ERROR".equals(level) ? " selected" : "").append(">ERROR</option>\n");
        html.append("                                <option value=\"DEBUG\"").append("DEBUG".equals(level) ? " selected" : "").append(">DEBUG</option>\n");
        html.append("                            </select>\n");
        html.append("                        </div>\n");
        html.append("                        <div>\n");
        html.append("                            <label>키워드:</label>\n");
        html.append("                            <input type=\"text\" name=\"keyword\" value=\"").append(keyword != null ? keyword : "").append("\" placeholder=\"검색어 입력\">\n");
        html.append("                        </div>\n");
        html.append("                        <div>\n");
        html.append("                            <label>표시 개수:</label>\n");
        html.append("                            <select name=\"limit\">\n");
        html.append("                                <option value=\"20\"").append(limit == 20 ? " selected" : "").append(">20개</option>\n");
        html.append("                                <option value=\"50\"").append(limit == 50 ? " selected" : "").append(">50개</option>\n");
        html.append("                                <option value=\"100\"").append(limit == 100 ? " selected" : "").append(">100개</option>\n");
        html.append("                            </select>\n");
        html.append("                        </div>\n");
        html.append("                        <button type=\"submit\" class=\"btn-primary\">🔍 검색</button>\n");
        html.append("                        <a href=\"settings?action=logs\" class=\"btn-secondary\">🔄 초기화</a>\n");
        html.append("                    </div>\n");
        html.append("                </form>\n");
        
        // 로그 엔트리들
        html.append("                <div class=\"data-table\">\n");
        html.append("                    <div class=\"table-header\">\n");
        html.append("                        <h3>로그 엔트리 (").append(logs.size()).append("개)</h3>\n");
        html.append("                    </div>\n");
        
        if (logs.isEmpty()) {
            html.append("                    <div class=\"empty-state\">\n");
            html.append("                        <h3>📝 조건에 맞는 로그가 없습니다</h3>\n");
            html.append("                        <p>검색 조건을 변경해보세요.</p>\n");
            html.append("                    </div>\n");
        } else {
            for (SystemLogUtil.LogEntry log : logs) {
                String logClass = "log-" + log.getLevel().toLowerCase();
                html.append("                    <div class=\"log-entry ").append(logClass).append("\">\n");
                html.append("                        <div class=\"log-timestamp\">").append(log.getTimestamp()).append("</div>\n");
                html.append("                        <div>\n");
                html.append("                            <span class=\"log-level\">[").append(log.getLevel()).append("]</span>\n");
                html.append("                            <span>").append(log.getSource()).append("</span>\n");
                html.append("                        </div>\n");
                html.append("                        <div>").append(log.getMessage()).append("</div>\n");
                html.append("                    </div>\n");
            }
        }
        
        html.append("                </div>\n");
        html.append("            </div>\n");
        html.append("        </div>\n");
        html.append("    </div>\n");
        html.append("</body>\n");
        html.append("</html>\n");
        
        return html.toString();
    }
    
    /**
     * 공통 CSS 스타일
     */
    private String getCommonCSS() {
        return "body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 0; background-color: #f0f0f0; }\n" +
               ".container { max-width: 1200px; margin: 0 auto; padding: 20px; }\n" +
               ".top-bar { background-color: #0078d4; color: white; padding: 10px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }\n" +
               ".nav-links { max-width: 1200px; margin: 0 auto; display: flex; gap: 20px; padding: 0 20px; }\n" +
               ".nav-link { color: white; text-decoration: none; padding: 8px 16px; border-radius: 4px; transition: background 0.3s; }\n" +
               ".nav-link:hover { background-color: rgba(255,255,255,0.1); }\n" +
               ".nav-link.logout { margin-left: auto; }\n" +
               ".main-dashboard { background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }\n" +
               ".dashboard-header { background: #0078d4; color: white; padding: 20px; border-radius: 8px 8px 0 0; }\n" +
               ".dashboard-header h1 { margin: 0; text-align: center; }\n" +
               ".dashboard-content { padding: 20px; }\n" +
               ".stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0; }\n" +
               ".stat-item { background: #f8f9fa; padding: 20px; border-radius: 8px; text-align: center; border: 1px solid #d0d7de; }\n" +
               ".stat-number { font-size: 2em; font-weight: bold; color: #0078d4; }\n" +
               ".stat-label { color: #656d76; margin-top: 8px; }\n" +
               ".btn-primary { background: #1f883d; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; text-decoration: none; display: inline-block; }\n" +
               ".btn-secondary { background: white; color: #24292f; border: 1px solid #d0d7de; padding: 10px 20px; border-radius: 6px; cursor: pointer; text-decoration: none; display: inline-block; }\n" +
               ".btn-primary:hover, .btn-secondary:hover { opacity: 0.9; }\n" +
               ".data-table { background: white; border: 1px solid #d0d7de; border-radius: 8px; margin: 20px 0; }\n" +
               ".table-header { background: #f6f8fa; padding: 15px; border-bottom: 1px solid #d0d7de; }\n" +
               ".table-header h3 { margin: 0; color: #24292f; }\n" +
               "table { width: 100%; border-collapse: collapse; }\n" +
               "th, td { padding: 12px; text-align: left; border-bottom: 1px solid #d0d7de; }\n" +
               "th { background: #f6f8fa; font-weight: 600; color: #24292f; }\n" +
               "tr:hover { background: #f6f8fa; }\n" +
               ".empty-state { text-align: center; padding: 40px; color: #656d76; }\n";
    }
} 