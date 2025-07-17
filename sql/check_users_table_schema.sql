-- =========================================
-- users 테이블 스키마 확인 스크립트
-- =========================================
-- 목적: users 테이블의 실제 컬럼 구조 확인
-- 작성일: 2025-01-14
-- =========================================

-- 1. users 테이블의 컬럼 정보 확인
SELECT 
    column_name as "컬럼명",
    data_type as "데이터타입",
    is_nullable as "NULL허용",
    column_default as "기본값"
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY ordinal_position;

-- 2. users 테이블의 현재 데이터 확인
SELECT 
    id,
    username,
    role,
    is_active,
    created_at
FROM users 
ORDER BY id;

-- 3. 현재 권한별 사용자 수 확인
SELECT 
    role as "현재 권한",
    COUNT(*) as "사용자 수"
FROM users 
GROUP BY role 
ORDER BY role; 