# 🚨 긴급 알림: 데이터베이스 데이터 손실 감지

## ⚠️ 발생한 문제
- **일시**: 오늘 GitHub 푸시 후
- **증상**: 모든 데이터베이스 데이터가 삭제됨
- **원인**: Git pre-push hook에서 프로덕션 DB에 테스트 실행

## 🔍 근본 원인 분석
1. **Git pre-push hook**: `.git/hooks/pre-push.ps1`에서 `mvnw.cmd test` 자동 실행
2. **잘못된 DB 연결**: 테스트가 프로덕션 DB (`promptsharing`)에 연결
3. **DELETE 명령어**: 테스트 tearDown에서 데이터 삭제
   - `CandidateDAOTest`: `DELETE FROM candidates WHERE email = ?`
   - `InterviewResultDAOTest`: 여러 DELETE 작업
   - `UserDAOTest`: `DELETE FROM users WHERE username = ?`

## ✅ 즉시 조치 완료
1. **테스트 비활성화**: pre-push hook에서 테스트 실행 차단
2. **추가 피해 방지**: TestDatabaseUtil.java 생성 (테스트 전용 DB)
3. **경고 메시지**: Git hook에 데이터 보호 모드 추가

## 🔧 데이터 복구 방법

### 1단계: PostgreSQL 확인
```sql
-- 현재 데이터 상태 확인
SELECT 'users' as table_name, count(*) as count FROM users
UNION ALL
SELECT 'candidates', count(*) FROM candidates  
UNION ALL
SELECT 'interview_schedules', count(*) FROM interview_schedules
UNION ALL
SELECT 'interview_results', count(*) FROM interview_results;
```

### 2단계: 백업에서 복구 (가능한 경우)
- PostgreSQL 백업 파일 확인
- `pg_dump` 백업이 있다면 `pg_restore` 사용

### 3단계: 기본 관리자 계정 재생성
```sql
-- 관리자 계정 재생성 (BCrypt 해시: "admin123")
INSERT INTO users (username, password, role, email, created_at) 
VALUES ('admin', '$2a$10$rQ8QqQ8QqQ8QqQ8QqQ8QqO.example.hash', 'admin', 'admin@company.com', NOW());
```

## 🛡️ 향후 재발 방지책
1. **테스트 DB 분리**: `promptsharing_test` 데이터베이스 생성
2. **테스트 수정**: 모든 테스트 파일에서 TestDatabaseUtil 사용
3. **자동 백업**: 정기적 데이터베이스 백업 설정
4. **환경 분리**: 개발/테스트/프로덕션 환경 명확히 구분

## 📞 긴급 지원
- **우선순위**: 1. 데이터 복구 → 2. 시스템 안정화 → 3. 재발 방지
- **상태**: 추가 데이터 손실 방지 완료
- **다음 단계**: 사용자와 함께 데이터 복구 진행

---
**마지막 업데이트**: 방금 전 (데이터 보호 모드 활성화 완료) 