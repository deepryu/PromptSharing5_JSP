-- 긴급 관리자 계정 설정 스크립트
-- 작성일: 2025-01-12
-- 목적: 기존 계정을 이용한 임시 관리자 권한 부여

-- 방법 1: 기존 계정에 임시 admin 권한 부여 (role 컬럼이 없는 경우)
-- 주의: 이 방법은 role 컬럼이 추가되기 전 임시 방편입니다.

-- 현재 계정 확인
SELECT id, username, password FROM users;

-- 방법 2: 기존 계정의 비밀번호를 admin123으로 변경
-- 주의: 실제 사용자 계정명을 확인 후 실행하세요
-- UPDATE users SET password = 'admin123' WHERE username = '실제사용자명';

-- 방법 3: 임시 admin 계정 직접 생성 (role 컬럼 없이)
-- 주의: role 컬럼이 없어도 username으로 admin 인식하도록 코드 수정 필요
INSERT INTO users (username, password) VALUES ('admin', 'admin123')
ON CONFLICT (username) DO UPDATE SET password = 'admin123';

-- 확인
SELECT * FROM users WHERE username = 'admin'; 