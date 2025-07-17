-- ================================================================
-- 테스트 데이터베이스 생성 (개별 명령어 실행용)
-- 중요: 각 명령어를 개별적으로 복사해서 psql에서 실행하세요!
-- 파일 전체를 한번에 실행하지 마세요!
-- ================================================================

-- 명령어 1: 기존 테스트 DB 삭제 (있다면)
-- 복사해서 실행: DROP DATABASE IF EXISTS promptsharing_test;

-- 명령어 2: 테스트 DB 생성
-- 복사해서 실행: 
-- CREATE DATABASE promptsharing_test
--     WITH 
--     OWNER = postgres
--     ENCODING = 'UTF8'
--     LC_COLLATE = 'Korean_Korea.949'
--     LC_CTYPE = 'Korean_Korea.949'
--     TABLESPACE = pg_default
--     CONNECTION LIMIT = -1;

-- 명령어 3: 데이터베이스 전환
-- psql에서 수동 실행: \c promptsharing_test

-- 이후 sql/create_test_database_step2.sql의 테이블 생성 부분을 실행하세요 