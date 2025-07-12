# 관리자 기능 정의서 (ADMIN FEATURES SPECIFICATION)

## 📋 개요
JSP 기반 인터뷰 관리 시스템에 추가할 **관리자 기능**을 체계적으로 정의한 문서입니다.

---

## 🎯 관리자 기능 추가 목표

### 현재 상황 분석
✅ **구현 완료된 기능**:
- 기본 사용자 인증 시스템 (로그인/로그아웃)
- 지원자 관리 (CRUD)
- 인터뷰 일정 관리
- 면접관 관리
- 인터뷰 결과 관리
- 통계 및 리포트
- 3단계 보안 시스템 (AuthenticationFilter 포함)

❌ **부족한 관리자 기능**:
- 사용자 권한 관리 (현재 모든 사용자가 동일한 권한)
- 시스템 모니터링 및 로그 관리
- 데이터 백업/복구 기능
- 시스템 설정 고도화
- 감사 로그 (Audit Log)
- 관리자 대시보드
- 대량 데이터 처리

---

## 🏗️ 관리자 기능 아키텍처

### 권한 레벨 정의
```
👑 SUPER_ADMIN (최고 관리자)
├── 시스템 설정 변경
├── 사용자 계정 관리
├── 데이터 백업/복구
├── 시스템 모니터링
└── 모든 기능 접근 권한

🔧 ADMIN (관리자)
├── 사용자 관리 (생성/수정/비활성화)
├── 면접 데이터 관리
├── 통계 및 리포트
├── 알림 설정 관리
└── 일반 관리 업무

👨‍💼 INTERVIEWER (면접관)
├── 담당 인터뷰 일정 관리
├── 인터뷰 결과 입력
├── 지원자 정보 조회
└── 개인 통계 확인

👤 USER (일반 사용자)
├── 기본 조회 권한
├── 개인 정보 수정
└── 제한된 기능 접근
```

---

## 📊 1. 사용자 및 권한 관리

### 1.1 사용자 관리 시스템
**📝 구현 필요 사항**:
- `users` 테이블에 `role` 컬럼 추가
- `user_profiles` 테이블 생성 (확장 정보)
- 사용자 목록/등록/수정/비활성화 기능
- 패스워드 재설정 기능

**🗄️ 데이터베이스 스키마**:
```sql
-- users 테이블 확장
ALTER TABLE users ADD COLUMN role VARCHAR(20) DEFAULT 'USER';
ALTER TABLE users ADD COLUMN email VARCHAR(100) UNIQUE;
ALTER TABLE users ADD COLUMN full_name VARCHAR(100);
ALTER TABLE users ADD COLUMN is_active BOOLEAN DEFAULT true;
ALTER TABLE users ADD COLUMN last_login TIMESTAMP;
ALTER TABLE users ADD COLUMN failed_login_attempts INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN account_locked_until TIMESTAMP;

-- 사용자 프로필 테이블 생성
CREATE TABLE user_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    department VARCHAR(50),
    position VARCHAR(50),
    phone VARCHAR(20),
    avatar_url VARCHAR(200),
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 권한 로그 테이블
CREATE TABLE user_role_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    old_role VARCHAR(20),
    new_role VARCHAR(20),
    changed_by INTEGER REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT
);
```

**🎨 관리자 화면**:
- `admin_users.jsp` - 사용자 목록 및 관리
- `admin_user_form.jsp` - 사용자 등록/수정
- `admin_role_management.jsp` - 권한 관리

### 1.2 권한 기반 접근 제어 (RBAC)
**📝 구현 필요 사항**:
- 권한 검증 필터 확장
- 페이지별 권한 매트릭스 정의
- 메뉴 동적 생성 (권한에 따라)

**🔒 권한 매트릭스**:
| 기능 | USER | INTERVIEWER | ADMIN | SUPER_ADMIN |
|------|------|-------------|-------|-------------|
| 지원자 조회 | ✅ | ✅ | ✅ | ✅ |
| 지원자 등록/수정 | ❌ | ✅ | ✅ | ✅ |
| 인터뷰 일정 관리 | ❌ | ✅ (본인 것만) | ✅ | ✅ |
| 사용자 관리 | ❌ | ❌ | ✅ | ✅ |
| 시스템 설정 | ❌ | ❌ | ❌ | ✅ |
| 데이터 백업/복구 | ❌ | ❌ | ❌ | ✅ |

---

## 🖥️ 2. 관리자 대시보드

### 2.1 관리자 전용 대시보드
**📊 핵심 지표**:
- 시스템 상태 (DB 연결, 서버 상태)
- 사용자 활동 통계 (로그인, 활성 사용자)
- 인터뷰 진행 현황
- 데이터 증가 추세
- 시스템 알림 및 경고

**🗄️ 데이터베이스 스키마**:
```sql
-- 시스템 상태 로그
CREATE TABLE system_status_log (
    id SERIAL PRIMARY KEY,
    metric_name VARCHAR(50) NOT NULL,
    metric_value DECIMAL(10,2),
    unit VARCHAR(20),
    status VARCHAR(20) DEFAULT 'NORMAL',
    checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 사용자 활동 로그
CREATE TABLE user_activity_log (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(50) NOT NULL,
    resource_type VARCHAR(50),
    resource_id INTEGER,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**🎨 관리자 화면**:
- `admin_dashboard.jsp` - 메인 대시보드
- `admin_system_status.jsp` - 시스템 상태 모니터링
- `admin_user_activity.jsp` - 사용자 활동 모니터링

### 2.2 실시간 모니터링
**📊 모니터링 항목**:
- 동시 접속자 수
- 데이터베이스 연결 상태
- 서버 리소스 사용량
- 최근 에러 로그
- 시스템 성능 지표

---

## 🗄️ 3. 데이터 관리

### 3.1 데이터 백업 및 복구
**📝 구현 필요 사항**:
- 자동 백업 스케줄러
- 수동 백업 실행
- 백업 파일 관리
- 복구 기능
- 백업 상태 모니터링

**🗄️ 데이터베이스 스키마**:
```sql
-- 백업 이력 테이블
CREATE TABLE backup_history (
    id SERIAL PRIMARY KEY,
    backup_type VARCHAR(20) NOT NULL, -- 'FULL', 'INCREMENTAL', 'MANUAL'
    backup_size BIGINT,
    backup_path VARCHAR(500),
    backup_status VARCHAR(20) DEFAULT 'STARTED',
    error_message TEXT,
    started_by INTEGER REFERENCES users(id),
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);
```

**🎨 관리자 화면**:
- `admin_backup.jsp` - 백업 관리
- `admin_backup_history.jsp` - 백업 이력
- `admin_data_recovery.jsp` - 데이터 복구

### 3.2 데이터 정리 및 최적화
**📝 구현 필요 사항**:
- 오래된 로그 데이터 정리
- 데이터베이스 인덱스 최적화
- 통계 정보 업데이트
- 데이터 일관성 검사

---

## 📋 4. 시스템 설정 고도화

### 4.1 고급 시스템 설정
**📝 현재 `system_settings` 테이블 확장**:
```sql
-- 시스템 설정 카테고리 추가
ALTER TABLE system_settings ADD COLUMN data_type VARCHAR(20) DEFAULT 'STRING';
ALTER TABLE system_settings ADD COLUMN validation_rule TEXT;
ALTER TABLE system_settings ADD COLUMN is_encrypted BOOLEAN DEFAULT false;
ALTER TABLE system_settings ADD COLUMN display_order INTEGER DEFAULT 0;

-- 설정 변경 이력
CREATE TABLE system_settings_history (
    id SERIAL PRIMARY KEY,
    setting_id INTEGER REFERENCES system_settings(id),
    old_value TEXT,
    new_value TEXT,
    changed_by INTEGER REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT
);
```

**⚙️ 관리 가능한 설정**:
- 로그인 정책 (비밀번호 복잡도, 세션 타임아웃)
- 이메일 설정 (SMTP 서버, 알림 설정)
- 파일 업로드 설정 (최대 크기, 허용 확장자)
- 보안 설정 (로그인 시도 제한, IP 차단)
- 인터페이스 설정 (로고, 테마, 언어)

### 4.2 설정 관리 기능
**🎨 관리자 화면**:
- `admin_settings_general.jsp` - 일반 설정
- `admin_settings_security.jsp` - 보안 설정
- `admin_settings_email.jsp` - 이메일 설정
- `admin_settings_backup.jsp` - 백업 설정

---

## 📊 5. 감사 로그 (Audit Log)

### 5.1 감사 로그 시스템
**📝 로그 대상 작업**:
- 사용자 계정 변경 (생성, 수정, 삭제, 권한 변경)
- 중요 데이터 변경 (지원자 정보, 인터뷰 결과)
- 시스템 설정 변경
- 로그인/로그아웃 이벤트
- 파일 업로드/다운로드
- 데이터 백업/복구

**🗄️ 데이터베이스 스키마**:
```sql
-- 감사 로그 테이블
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(50) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    severity VARCHAR(20) DEFAULT 'INFO', -- 'INFO', 'WARNING', 'ERROR', 'CRITICAL'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 로그인 이력 테이블
CREATE TABLE login_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    login_type VARCHAR(20) DEFAULT 'SUCCESS', -- 'SUCCESS', 'FAILED', 'LOCKED'
    ip_address INET,
    user_agent TEXT,
    attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 5.2 감사 로그 관리
**🎨 관리자 화면**:
- `admin_audit_log.jsp` - 감사 로그 조회
- `admin_login_history.jsp` - 로그인 이력
- `admin_security_alerts.jsp` - 보안 경고

---

## 🔧 6. 시스템 유지보수

### 6.1 시스템 점검 도구
**📝 점검 항목**:
- 데이터베이스 연결 상태
- 테이블 무결성 검사
- 인덱스 상태 확인
- 로그 파일 크기 점검
- 디스크 공간 확인

**🗄️ 데이터베이스 스키마**:
```sql
-- 시스템 점검 이력
CREATE TABLE system_health_check (
    id SERIAL PRIMARY KEY,
    check_type VARCHAR(50) NOT NULL,
    check_result VARCHAR(20) NOT NULL, -- 'PASS', 'FAIL', 'WARNING'
    details TEXT,
    checked_by INTEGER REFERENCES users(id),
    checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 6.2 성능 모니터링
**📊 모니터링 지표**:
- 데이터베이스 쿼리 성능
- 페이지 로딩 시간
- 메모리 사용량
- 동시 접속자 수

---

## 🎯 7. 구현 우선순위

### Phase 1: 기본 관리자 기능 (1-2주)
1. **사용자 권한 관리**
   - `users` 테이블에 `role` 컬럼 추가
   - 권한 기반 접근 제어 구현
   - 관리자 사용자 관리 화면

2. **기본 관리자 대시보드**
   - 시스템 상태 요약
   - 사용자 활동 통계
   - 기본 관리 메뉴

### Phase 2: 데이터 관리 (2-3주)
1. **백업/복구 시스템**
   - 수동 백업 기능
   - 백업 이력 관리
   - 기본 복구 기능

2. **감사 로그 시스템**
   - 주요 작업 로그 기록
   - 로그인 이력 관리
   - 보안 이벤트 모니터링

### Phase 3: 고급 관리 기능 (3-4주)
1. **시스템 설정 고도화**
   - 설정 카테고리 관리
   - 설정 변경 이력
   - 보안 설정 강화

2. **시스템 모니터링**
   - 실시간 상태 모니터링
   - 성능 지표 수집
   - 자동 알림 시스템

### Phase 4: 최적화 및 고도화 (4-5주)
1. **고급 데이터 분석**
   - 사용자 행동 분석
   - 시스템 성능 분석
   - 예측 분석 기능

2. **자동화 도구**
   - 자동 백업 스케줄러
   - 자동 데이터 정리
   - 자동 시스템 점검

---

## 📋 8. 기술 구현 가이드

### 8.1 권한 검증 구현
```java
// RoleBasedFilter.java
@WebFilter("/*")
public class RoleBasedFilter implements Filter {
    private static final Map<String, String[]> ROLE_PERMISSIONS = new HashMap<>();
    
    static {
        ROLE_PERMISSIONS.put("/admin/*", new String[]{"ADMIN", "SUPER_ADMIN"});
        ROLE_PERMISSIONS.put("/interview/*", new String[]{"INTERVIEWER", "ADMIN", "SUPER_ADMIN"});
        // ...
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) {
        HttpServletRequest req = (HttpServletRequest) request;
        String path = req.getRequestURI();
        String userRole = getUserRole(req);
        
        if (hasPermission(path, userRole)) {
            chain.doFilter(request, response);
        } else {
            // 권한 없음 처리
            ((HttpServletResponse) response).sendRedirect("unauthorized.jsp");
        }
    }
}
```

### 8.2 감사 로그 구현
```java
// AuditLogger.java
public class AuditLogger {
    public static void logUserAction(String action, String resourceType, 
                                   Integer resourceId, String oldValues, 
                                   String newValues, HttpServletRequest request) {
        try (Connection conn = DatabaseUtil.getConnection()) {
            String sql = "INSERT INTO audit_log (user_id, action, resource_type, " +
                        "resource_id, old_values, new_values, ip_address, user_agent) " +
                        "VALUES (?, ?, ?, ?, ?::jsonb, ?::jsonb, ?::inet, ?)";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, getUserId(request));
            ps.setString(2, action);
            ps.setString(3, resourceType);
            ps.setObject(4, resourceId);
            ps.setString(5, oldValues);
            ps.setString(6, newValues);
            ps.setString(7, request.getRemoteAddr());
            ps.setString(8, request.getHeader("User-Agent"));
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
```

### 8.3 시스템 상태 모니터링
```java
// SystemHealthChecker.java
public class SystemHealthChecker {
    public static SystemStatus checkSystemHealth() {
        SystemStatus status = new SystemStatus();
        
        // 데이터베이스 연결 체크
        status.setDatabaseStatus(checkDatabaseConnection());
        
        // 메모리 사용량 체크
        status.setMemoryUsage(getMemoryUsage());
        
        // 활성 세션 수
        status.setActiveSessionCount(getActiveSessionCount());
        
        return status;
    }
}
```

---

## 📈 9. 성공 지표 (KPI)

### 9.1 관리 효율성 지표
- **사용자 관리 시간 단축**: 50% 이상
- **시스템 모니터링 자동화**: 80% 이상
- **보안 이벤트 감지 시간**: 실시간 (5분 이내)
- **데이터 백업 성공률**: 99% 이상

### 9.2 시스템 안정성 지표
- **시스템 가용성**: 99.5% 이상
- **응답 시간**: 평균 2초 이내
- **데이터 무결성**: 100% 보장
- **보안 사고 발생**: 0건

---

## 🔒 10. 보안 고려사항

### 10.1 관리자 기능 보안
- **다단계 인증**: 관리자 계정 2FA 적용
- **IP 화이트리스트**: 관리자 접근 IP 제한
- **세션 타임아웃**: 관리자 세션 짧은 유지
- **감사 로그**: 모든 관리자 작업 기록

### 10.2 데이터 보안
- **백업 암호화**: 백업 파일 AES 암호화
- **접근 로그**: 민감 데이터 접근 모두 기록
- **데이터 마스킹**: 개인정보 조회 시 마스킹
- **권한 분리**: 최소 권한 원칙 적용

---

## 📚 11. 관련 문서

### 11.1 기술 문서
- `docs/PROJECT_GUIDE.md` - 전체 프로젝트 가이드
- `docs/SECURITY_GUIDE.md` - 보안 가이드
- `docs/DATABASE_SCHEMA_ANALYSIS.md` - 데이터베이스 스키마

### 11.2 구현 문서
- `docs/ADMIN_IMPLEMENTATION_GUIDE.md` - 구현 가이드 (향후 생성)
- `docs/ADMIN_API_REFERENCE.md` - API 레퍼런스 (향후 생성)
- `docs/ADMIN_USER_MANUAL.md` - 사용자 매뉴얼 (향후 생성)

---

## 🎯 결론

이 관리자 기능 추가를 통해 JSP 인터뷰 관리 시스템은 **Enterprise 급 관리 시스템**으로 발전할 수 있습니다. 

**핵심 가치**:
- 🔧 **효율적인 관리**: 사용자 및 시스템 관리 자동화
- 🛡️ **강화된 보안**: 권한 기반 접근 제어 및 감사 로그
- 📊 **데이터 기반 의사결정**: 실시간 모니터링 및 분석
- 🚀 **확장 가능한 아키텍처**: 향후 요구사항 대응 가능

**구현 완료 시 기대 효과**:
- 시스템 관리 효율성 **50% 향상**
- 보안 사고 위험 **90% 감소**
- 데이터 관리 안정성 **99% 보장**
- 관리자 업무 만족도 **대폭 향상** 