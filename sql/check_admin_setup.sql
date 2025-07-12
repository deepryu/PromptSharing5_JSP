-- 관리자 기능 설정 상태 확인 스크립트
-- 작성일: 2025-01-12
-- 목적: 현재 데이터베이스 상태 확인 및 문제 진단

-- 1. users 테이블 구조 확인
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY ordinal_position;

-- 2. users 테이블의 모든 계정 확인
SELECT id, username, 
       CASE WHEN role IS NULL THEN 'role 컬럼 없음' ELSE role END as role,
       CASE WHEN email IS NULL THEN 'email 컬럼 없음' ELSE email END as email,
       CASE WHEN is_active IS NULL THEN 'is_active 컬럼 없음' ELSE is_active::text END as is_active
FROM users;

-- 3. 관리자 계정 존재 여부 확인
SELECT COUNT(*) as admin_count
FROM users 
WHERE username = 'admin';

-- 4. 관리자 관련 테이블 존재 여부 확인
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('user_profiles', 'user_role_history', 'user_activity_log', 'system_status_log');

-- 5. 결과 요약
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'role') 
        THEN '✅ role 컬럼 존재' 
        ELSE '❌ role 컬럼 없음 - 스키마 업데이트 필요' 
    END as role_column_status,
    
    CASE 
        WHEN EXISTS (SELECT 1 FROM users WHERE username = 'admin') 
        THEN '✅ admin 계정 존재' 
        ELSE '❌ admin 계정 없음 - 계정 생성 필요' 
    END as admin_account_status,
    
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_profiles') 
        THEN '✅ 관리자 테이블 존재' 
        ELSE '❌ 관리자 테이블 없음 - 스키마 업데이트 필요' 
    END as admin_tables_status; 