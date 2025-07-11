-- ================================================================
-- 긴급 데이터 복구 스크립트
-- 생성일: 오늘 (GitHub 푸시 후 데이터 손실 발생)
-- 목적: 기본 스키마 확인 및 관리자 계정 재생성
-- ================================================================

-- 1. 현재 데이터 상태 확인
SELECT '=== 현재 데이터베이스 상태 확인 ===' as status;

SELECT 'users' as table_name, count(*) as count FROM users
UNION ALL
SELECT 'candidates', count(*) FROM candidates  
UNION ALL
SELECT 'interview_schedules', count(*) FROM interview_schedules
UNION ALL
SELECT 'interview_results', count(*) FROM interview_results
UNION ALL
SELECT 'interview_questions', count(*) FROM interview_questions
UNION ALL
SELECT 'interviewers', count(*) FROM interviewers;

-- 2. 테이블 존재 여부 확인
SELECT '=== 테이블 존재 여부 확인 ===' as status;

SELECT 
    table_name,
    CASE WHEN table_name IS NOT NULL THEN 'EXISTS' ELSE 'MISSING' END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('users', 'candidates', 'interview_schedules', 'interview_results', 'interview_questions', 'interviewers')
ORDER BY table_name;

-- 3. 관리자 계정 재생성 (기존 admin 계정이 없는 경우)
SELECT '=== 관리자 계정 복구 ===' as status;

-- 기존 admin 계정 확인
SELECT count(*) as admin_count FROM users WHERE username = 'admin';

-- admin 계정이 없으면 생성
INSERT INTO users (username, password, role, email, created_at) 
SELECT 'admin', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'admin@company.com', NOW()
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'admin');

-- 관리자 계정 확인
SELECT username, role, email, created_at 
FROM users 
WHERE username = 'admin';

-- 4. 기본 시스템 설정 복구
SELECT '=== 시스템 설정 복구 ===' as status;

-- system_settings 테이블 확인 및 기본값 설정
INSERT INTO system_settings (setting_key, setting_value, description, updated_at, updated_by)
SELECT 'system_name', '채용 관리 시스템', '시스템 이름', NOW(), 'admin'
WHERE NOT EXISTS (SELECT 1 FROM system_settings WHERE setting_key = 'system_name');

INSERT INTO system_settings (setting_key, setting_value, description, updated_at, updated_by)
SELECT 'version', '1.3.0', '시스템 버전', NOW(), 'admin'
WHERE NOT EXISTS (SELECT 1 FROM system_settings WHERE setting_key = 'version');

INSERT INTO system_settings (setting_key, setting_value, description, updated_at, updated_by)
SELECT 'maintenance_mode', 'false', '유지보수 모드', NOW(), 'admin'
WHERE NOT EXISTS (SELECT 1 FROM system_settings WHERE setting_key = 'maintenance_mode');

-- 5. 기본 면접관 정보 복구 (admin)
SELECT '=== 기본 면접관 정보 복구 ===' as status;

INSERT INTO interviewers (name, department, email, phone, created_at)
SELECT 'Administrator', 'IT', 'admin@company.com', '02-0000-0000', NOW()
WHERE NOT EXISTS (SELECT 1 FROM interviewers WHERE email = 'admin@company.com');

-- 6. 샘플 질문 카테고리 복구
SELECT '=== 기본 질문 카테고리 복구 ===' as status;

INSERT INTO interview_questions (category, question_text, question_type, created_at)
SELECT 'Technical', '프로그래밍 언어에 대한 경험을 설명해 주세요.', 'open', NOW()
WHERE NOT EXISTS (SELECT 1 FROM interview_questions WHERE category = 'Technical' AND question_text LIKE '%프로그래밍 언어%');

INSERT INTO interview_questions (category, question_text, question_type, created_at)
SELECT 'Personal', '자신의 장단점에 대해 말씀해 주세요.', 'open', NOW()
WHERE NOT EXISTS (SELECT 1 FROM interview_questions WHERE category = 'Personal' AND question_text LIKE '%장단점%');

INSERT INTO interview_questions (category, question_text, question_type, created_at)
SELECT 'Experience', '이전 직장에서의 주요 성과를 설명해 주세요.', 'open', NOW()
WHERE NOT EXISTS (SELECT 1 FROM interview_questions WHERE category = 'Experience' AND question_text LIKE '%성과%');

-- 7. 복구 완료 상태 확인
SELECT '=== 복구 완료 상태 확인 ===' as status;

SELECT 'users' as table_name, count(*) as count FROM users
UNION ALL
SELECT 'interviewers', count(*) FROM interviewers
UNION ALL
SELECT 'interview_questions', count(*) FROM interview_questions
UNION ALL
SELECT 'system_settings', count(*) FROM system_settings;

-- 8. 복구 완료 메시지
SELECT '=== 긴급 복구 완료 ===' as status;
SELECT 'Admin 계정: admin / admin123' as login_info;
SELECT '다음 단계: 백업에서 실제 데이터 복구 필요' as next_step;

-- 복구 로그 기록
INSERT INTO activity_history (activity_type, description, created_at, created_by)
VALUES ('SYSTEM', '긴급 데이터 복구 스크립트 실행 완료', NOW(), 'admin'); 