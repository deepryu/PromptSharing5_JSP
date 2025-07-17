-- =========================================
-- 권한 체계 변경 SQL 스크립트
-- 4가지 권한 → 2가지 권한으로 간소화
-- =========================================
-- 목적: USER/SUPER_ADMIN 권한을 제거하고 INTERVIEWER/ADMIN 2가지 권한만 사용
-- 작성일: 2025-01-14
-- 
-- 변경 내용:
-- 1. USER (일반 사용자) → INTERVIEWER (면접관) 권한으로 변경
-- 2. SUPER_ADMIN (최고 관리자) → ADMIN (관리자) 권한으로 변경
-- 3. 기존 INTERVIEWER, ADMIN 권한은 유지
-- =========================================

-- 백업을 위한 현재 권한 상태 확인
SELECT 
    role as "현재 권한",
    COUNT(*) as "사용자 수"
FROM users 
GROUP BY role 
ORDER BY role;

-- 현재 사용자별 상세 정보 (변경 전)
SELECT 
    id,
    username,
    role,
    full_name,
    email,
    is_active,
    created_at,
    last_login
FROM users 
ORDER BY role, username;

-- 1단계: USER 권한을 INTERVIEWER로 변경
UPDATE users 
SET role = 'INTERVIEWER'
WHERE role = 'USER';

-- 변경된 USER 사용자 확인
SELECT 
    '1단계 완료: USER → INTERVIEWER' as "변경단계",
    COUNT(*) as "변경된사용자수"
FROM users 
WHERE role = 'INTERVIEWER';

-- 2단계: SUPER_ADMIN 권한을 ADMIN으로 변경  
UPDATE users 
SET role = 'ADMIN'
WHERE role = 'SUPER_ADMIN';

-- 변경된 SUPER_ADMIN 사용자 확인
SELECT 
    '2단계 완료: SUPER_ADMIN → ADMIN' as "변경단계",
    COUNT(*) as "기존ADMIN수",
    (SELECT COUNT(*) FROM users WHERE role = 'ADMIN') as "총ADMIN수"
FROM users 
WHERE role = 'ADMIN';

-- 최종 변경 결과 확인
SELECT 
    role as "변경된 권한",
    COUNT(*) as "사용자 수",
    STRING_AGG(username, ', ') as "사용자명"
FROM users 
GROUP BY role 
ORDER BY role;

-- 권한별 사용자 상세 정보 확인 (변경 후)
SELECT 
    id,
    username,
    role as "권한",
    full_name as "이름",
    email as "이메일",
    is_active as "활성상태",
    created_at as "생성일",
    last_login as "마지막로그인"
FROM users 
ORDER BY role, username;

-- 변경 사항 요약
SELECT 
    '권한 체계 간소화 완료' as "작업상태",
    'USER → INTERVIEWER, SUPER_ADMIN → ADMIN' as "변경내용",
    (SELECT COUNT(*) FROM users WHERE role = 'INTERVIEWER') as "INTERVIEWER수",
    (SELECT COUNT(*) FROM users WHERE role = 'ADMIN') as "ADMIN수",
    (SELECT COUNT(*) FROM users WHERE is_active = true) as "활성사용자수",
    (SELECT COUNT(*) FROM users) as "전체사용자수"; 