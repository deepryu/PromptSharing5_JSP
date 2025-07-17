-- ================================================================
-- 테스트 전용 데이터베이스 생성 스크립트 (1단계)
-- 목적: promptsharing_test 데이터베이스 생성
-- 실행: PostgreSQL superuser (postgres)로 실행 필요
-- 주의: 이 스크립트는 트랜잭션 없이 개별 명령어로 실행해야 함
-- ================================================================

-- 1. 기존 테스트 DB가 있으면 제거 (주의: 기존 테스트 데이터 삭제됨)
DROP DATABASE IF EXISTS promptsharing_test;

-- 2. 테스트 전용 데이터베이스 생성
CREATE DATABASE promptsharing_test
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Korean_Korea.949'
    LC_CTYPE = 'Korean_Korea.949'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- 3. 데이터베이스 생성 완료 확인
SELECT 'promptsharing_test 데이터베이스 생성 완료!' as message; 