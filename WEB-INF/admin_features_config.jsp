<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.HashMap, java.util.Map" %>
<%!
    // 관리자 기능 개발 상태 관리
    public static class AdminFeatureConfig {
        
        // 기능 상태 상수
        public static final String STATUS_READY = "READY";           // 사용 가능
        public static final String STATUS_DEVELOPMENT = "DEVELOPMENT"; // 개발 중
        public static final String STATUS_PLANNED = "PLANNED";       // 계획됨
        public static final String STATUS_DISABLED = "DISABLED";     // 비활성화
        
        // 관리자 기능별 개발 상태 맵
        private static final Map<String, Map<String, String>> ADMIN_FEATURES = new HashMap<>();
        
        static {
            // 사용자 관리
            Map<String, String> userManagement = new HashMap<>();
            userManagement.put("status", STATUS_READY);
            userManagement.put("name", "사용자 관리");
            userManagement.put("description", "사용자 계정 생성, 수정, 삭제 및 권한 관리");
            userManagement.put("url", "admin/users");
            userManagement.put("expected", "완료");
            ADMIN_FEATURES.put("users", userManagement);
            
            // 시스템 설정 (이미 구현됨)
            Map<String, String> systemSettings = new HashMap<>();
            systemSettings.put("status", STATUS_READY);
            systemSettings.put("name", "시스템 설정");
            systemSettings.put("description", "시스템 전반적인 설정 관리");
            systemSettings.put("url", "settings");
            systemSettings.put("expected", "완료");
            ADMIN_FEATURES.put("settings", systemSettings);
            
            // 로그 관리
            Map<String, String> logManagement = new HashMap<>();
            logManagement.put("status", STATUS_READY);
            logManagement.put("name", "로그 관리");
            logManagement.put("description", "시스템 로그 조회 및 분석");
            logManagement.put("url", "admin/logs");
            logManagement.put("expected", "완료");
            ADMIN_FEATURES.put("logs", logManagement);
            
            // 보고서 관리
            Map<String, String> reports = new HashMap<>();
            reports.put("status", STATUS_DEVELOPMENT);
            reports.put("name", "보고서 관리");
            reports.put("description", "각종 통계 및 보고서 생성");
            reports.put("url", "under_construction.jsp?feature=보고서 관리&returnUrl=admin/dashboard");
            reports.put("expected", "3-4주 내");
            ADMIN_FEATURES.put("reports", reports);
            
            // 알림 관리
            Map<String, String> notifications = new HashMap<>();
            notifications.put("status", STATUS_PLANNED);
            notifications.put("name", "알림 관리");
            notifications.put("description", "시스템 알림 및 공지사항 관리");
            notifications.put("url", "under_construction.jsp?feature=알림 관리&returnUrl=admin/dashboard");
            notifications.put("expected", "4-5주 내");
            ADMIN_FEATURES.put("notifications", notifications);
            
            // 백업 관리
            Map<String, String> backup = new HashMap<>();
            backup.put("status", STATUS_PLANNED);
            backup.put("name", "백업 관리");
            backup.put("description", "데이터베이스 백업 및 복구");
            backup.put("url", "under_construction.jsp?feature=백업 관리&returnUrl=admin/dashboard");
            backup.put("expected", "5-6주 내");
            ADMIN_FEATURES.put("backup", backup);
            
            // 보안 관리
            Map<String, String> security = new HashMap<>();
            security.put("status", STATUS_PLANNED);
            security.put("name", "보안 관리");
            security.put("description", "접근 제어 및 보안 설정");
            security.put("url", "under_construction.jsp?feature=보안 관리&returnUrl=admin/dashboard");
            security.put("expected", "6-7주 내");
            ADMIN_FEATURES.put("security", security);
            
            // 권한 관리
            Map<String, String> roles = new HashMap<>();
            roles.put("status", STATUS_PLANNED);
            roles.put("name", "권한 관리");
            roles.put("description", "사용자 권한 및 역할 관리");
            roles.put("url", "under_construction.jsp?feature=권한 관리&returnUrl=admin/dashboard");
            roles.put("expected", "7-8주 내");
            ADMIN_FEATURES.put("roles", roles);
            
            // 시스템 유지보수
            Map<String, String> maintenance = new HashMap<>();
            maintenance.put("status", STATUS_PLANNED);
            maintenance.put("name", "시스템 유지보수");
            maintenance.put("description", "시스템 점검 및 유지보수 도구");
            maintenance.put("url", "under_construction.jsp?feature=시스템 유지보수&returnUrl=admin/dashboard");
            maintenance.put("expected", "8-9주 내");
            ADMIN_FEATURES.put("maintenance", maintenance);
        }
        
        // 기능 정보 가져오기
        public static Map<String, String> getFeature(String featureKey) {
            return ADMIN_FEATURES.get(featureKey);
        }
        
        // 모든 기능 가져오기
        public static Map<String, Map<String, String>> getAllFeatures() {
            return ADMIN_FEATURES;
        }
        
        // 기능 사용 가능 여부 확인
        public static boolean isFeatureReady(String featureKey) {
            Map<String, String> feature = ADMIN_FEATURES.get(featureKey);
            return feature != null && STATUS_READY.equals(feature.get("status"));
        }
        
        // 기능 개발 중 여부 확인
        public static boolean isFeatureInDevelopment(String featureKey) {
            Map<String, String> feature = ADMIN_FEATURES.get(featureKey);
            return feature != null && STATUS_DEVELOPMENT.equals(feature.get("status"));
        }
        
        // 기능 계획됨 여부 확인
        public static boolean isFeaturePlanned(String featureKey) {
            Map<String, String> feature = ADMIN_FEATURES.get(featureKey);
            return feature != null && STATUS_PLANNED.equals(feature.get("status"));
        }
        
        // 상태별 CSS 클래스 반환
        public static String getStatusClass(String featureKey) {
            Map<String, String> feature = ADMIN_FEATURES.get(featureKey);
            if (feature == null) return "feature-disabled";
            
            String status = feature.get("status");
            switch (status) {
                case STATUS_READY: return "feature-ready";
                case STATUS_DEVELOPMENT: return "feature-development";
                case STATUS_PLANNED: return "feature-planned";
                default: return "feature-disabled";
            }
        }
        
        // 상태별 아이콘 반환
        public static String getStatusIcon(String featureKey) {
            Map<String, String> feature = ADMIN_FEATURES.get(featureKey);
            if (feature == null) return "❌";
            
            String status = feature.get("status");
            switch (status) {
                case STATUS_READY: return "✅";
                case STATUS_DEVELOPMENT: return "🚧";
                case STATUS_PLANNED: return "📋";
                default: return "❌";
            }
        }
    }
%>

<%-- 이 설정을 다른 페이지에서 사용하려면 다음과 같이 include 하세요:
     <%@ include file="/WEB-INF/admin_features_config.jsp" %>
--%> 