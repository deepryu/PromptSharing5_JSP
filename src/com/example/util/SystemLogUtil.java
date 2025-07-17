package com.example.util;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.regex.Pattern;

/**
 * 시스템 로그 관리 유틸리티 클래스
 */
public class SystemLogUtil {
    
    private static final String LOG_DIR = "logs/";
    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    
    /**
     * 로그 엔트리 클래스
     */
    public static class LogEntry {
        private String timestamp;
        private String level;
        private String message;
        private String source;
        
        public LogEntry(String timestamp, String level, String message, String source) {
            this.timestamp = timestamp;
            this.level = level;
            this.message = message;
            this.source = source;
        }
        
        // Getters
        public String getTimestamp() { return timestamp; }
        public String getLevel() { return level; }
        public String getMessage() { return message; }
        public String getSource() { return source; }
    }
    
    /**
     * 시스템 로그 조회 (시뮬레이션)
     */
    public static List<LogEntry> getSystemLogs(String level, int limit) {
        List<LogEntry> logs = new ArrayList<>();
        
        // 실제 환경에서는 로그 파일을 읽어오지만, 여기서는 시뮬레이션 데이터 생성
        String[] levels = {"INFO", "WARN", "ERROR", "DEBUG"};
        String[] sources = {"SystemSettingsServlet", "LoginServlet", "AdminServlet", "DatabaseUtil"};
        String[] messages = {
            "시스템 설정이 성공적으로 로드되었습니다",
            "사용자 로그인 성공: admin",
            "데이터베이스 연결이 성공했습니다",
            "백업 프로세스가 시작되었습니다",
            "메모리 사용량이 80%를 초과했습니다",
            "새로운 사용자가 등록되었습니다",
            "시스템 재시작이 감지되었습니다",
            "정기 백업이 완료되었습니다",
            "캐시가 정리되었습니다",
            "보안 검사가 수행되었습니다"
        };
        
        Random random = new Random();
        Calendar cal = Calendar.getInstance();
        
        for (int i = 0; i < Math.min(limit, 100); i++) {
            cal.add(Calendar.MINUTE, -random.nextInt(1440)); // 최근 24시간 내
            String timestamp = DATE_FORMAT.format(cal.getTime());
            String logLevel = levels[random.nextInt(levels.length)];
            String message = messages[random.nextInt(messages.length)];
            String source = sources[random.nextInt(sources.length)];
            
            // 레벨 필터링
            if (level == null || level.isEmpty() || level.equals("ALL") || level.equals(logLevel)) {
                logs.add(new LogEntry(timestamp, logLevel, message, source));
            }
        }
        
        // 시간순 정렬 (최신순)
        logs.sort((a, b) -> b.getTimestamp().compareTo(a.getTimestamp()));
        
        return logs.subList(0, Math.min(logs.size(), limit));
    }
    
    /**
     * 로그 통계 조회
     */
    public static Map<String, Object> getLogStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        // 전체 로그 조회
        List<LogEntry> allLogs = getSystemLogs("ALL", 1000);
        
        // 레벨별 카운트
        Map<String, Integer> levelCounts = new HashMap<>();
        levelCounts.put("INFO", 0);
        levelCounts.put("WARN", 0);
        levelCounts.put("ERROR", 0);
        levelCounts.put("DEBUG", 0);
        
        for (LogEntry log : allLogs) {
            levelCounts.put(log.getLevel(), levelCounts.getOrDefault(log.getLevel(), 0) + 1);
        }
        
        stats.put("totalLogs", allLogs.size());
        stats.put("levelCounts", levelCounts);
        
        // 최근 24시간 로그 수
        Calendar yesterday = Calendar.getInstance();
        yesterday.add(Calendar.DAY_OF_MONTH, -1);
        long recentLogs = allLogs.stream()
                .filter(log -> {
                    try {
                        Date logDate = DATE_FORMAT.parse(log.getTimestamp());
                        return logDate.after(yesterday.getTime());
                    } catch (Exception e) {
                        return false;
                    }
                })
                .count();
        
        stats.put("recentLogs", recentLogs);
        
        return stats;
    }
    
    /**
     * 로그 파일 목록 조회
     */
    public static List<Map<String, Object>> getLogFiles() {
        List<Map<String, Object>> logFiles = new ArrayList<>();
        
        // 시뮬레이션 로그 파일들
        String[] fileNames = {
            "application.log",
            "error.log",
            "access.log",
            "security.log",
            "database.log"
        };
        
        Random random = new Random();
        for (String fileName : fileNames) {
            Map<String, Object> fileInfo = new HashMap<>();
            fileInfo.put("name", fileName);
            fileInfo.put("size", formatFileSize(random.nextInt(10000000) + 1000000)); // 1MB ~ 10MB
            fileInfo.put("lastModified", new Date(System.currentTimeMillis() - random.nextInt(86400000))); // 최근 24시간
            fileInfo.put("lines", random.nextInt(50000) + 1000);
            logFiles.add(fileInfo);
        }
        
        return logFiles;
    }
    
    /**
     * 실시간 시스템 상태 조회
     */
    public static Map<String, Object> getSystemStatus() {
        Map<String, Object> status = new HashMap<>();
        
        // JVM 상태
        Runtime runtime = Runtime.getRuntime();
        long totalMemory = runtime.totalMemory();
        long freeMemory = runtime.freeMemory();
        long usedMemory = totalMemory - freeMemory;
        
        status.put("memoryUsage", Math.round((double) usedMemory / totalMemory * 100));
        status.put("totalMemoryMB", totalMemory / 1024 / 1024);
        status.put("usedMemoryMB", usedMemory / 1024 / 1024);
        status.put("freeMemoryMB", freeMemory / 1024 / 1024);
        
        // CPU 사용률 (시뮬레이션)
        Random random = new Random();
        status.put("cpuUsage", random.nextInt(30) + 10); // 10-40%
        
        // 스레드 정보
        ThreadGroup threadGroup = Thread.currentThread().getThreadGroup();
        status.put("activeThreads", threadGroup.activeCount());
        
        // 업타임 (시뮬레이션)
        long uptimeMillis = System.currentTimeMillis() % 86400000; // 하루 이내로 제한
        status.put("uptimeHours", uptimeMillis / 3600000);
        status.put("uptimeMinutes", (uptimeMillis % 3600000) / 60000);
        
        // 데이터베이스 연결 상태
        try {
            DatabaseUtil.getConnection().close();
            status.put("databaseStatus", "연결됨");
        } catch (Exception e) {
            status.put("databaseStatus", "연결 실패");
        }
        
        return status;
    }
    
    /**
     * 로그 검색
     */
    public static List<LogEntry> searchLogs(String keyword, String level, int limit) {
        List<LogEntry> allLogs = getSystemLogs(level, 1000);
        
        if (keyword == null || keyword.trim().isEmpty()) {
            return allLogs.subList(0, Math.min(allLogs.size(), limit));
        }
        
        Pattern pattern = Pattern.compile(keyword.toLowerCase());
        return allLogs.stream()
                .filter(log -> pattern.matcher(log.getMessage().toLowerCase()).find() ||
                              pattern.matcher(log.getSource().toLowerCase()).find())
                .limit(limit)
                .collect(ArrayList::new, (list, item) -> list.add(item), (list1, list2) -> list1.addAll(list2));
    }
    
    /**
     * 파일 크기 포맷팅
     */
    private static String formatFileSize(long bytes) {
        if (bytes < 1024) return bytes + " B";
        int exp = (int) (Math.log(bytes) / Math.log(1024));
        String pre = "KMGTPE".charAt(exp-1) + "";
        return String.format("%.1f %sB", bytes / Math.pow(1024, exp), pre);
    }
} 