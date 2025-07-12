-- 간단한 admin 계정 생성 스크립트
-- 작성일: 2025-01-12
-- 목적: 기존 users 테이블에 admin 계정 추가 (테스트용)

-- 현재 users 테이블 구조 확인
SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'users' ORDER BY ordinal_position;

-- admin 계정 생성 (plain text 비밀번호 사용 - 테스트용)
INSERT INTO users (username, password) VALUES ('admin', 'admin123')
ON CONFLICT (username) DO UPDATE SET password = 'admin123';

-- 생성된 admin 계정 확인
SELECT * FROM users WHERE username = 'admin';

-- 모든 계정 확인
SELECT id, username, password FROM users; 