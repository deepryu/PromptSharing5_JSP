-- 테스트용 일반 사용자 계정 생성
-- 작성일: 2025-01-12
-- 목적: 권한 테스트를 위한 일반 사용자 계정 생성

-- 테스트 사용자 계정 생성 (plain text 비밀번호)
INSERT INTO users (username, password) VALUES ('testuser', 'test123')
ON CONFLICT (username) DO UPDATE SET password = 'test123';

-- 생성된 계정 확인
SELECT * FROM users WHERE username IN ('admin', 'testuser');

-- 현재 모든 계정 목록
SELECT id, username, password FROM users; 