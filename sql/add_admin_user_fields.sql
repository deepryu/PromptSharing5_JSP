-- Phase 1: 관리자 기능을 위한 사용자 테이블 확장
-- 작성일: 2025-01-12
-- 목적: users 테이블에 권한 관리 필드 추가 및 관련 테이블 생성

-- 1. users 테이블에 관리자 기능 필드 추가
ALTER TABLE users ADD COLUMN role VARCHAR(20) DEFAULT 'USER';
ALTER TABLE users ADD COLUMN email VARCHAR(100);
ALTER TABLE users ADD COLUMN full_name VARCHAR(100);
ALTER TABLE users ADD COLUMN is_active BOOLEAN DEFAULT true;
ALTER TABLE users ADD COLUMN last_login TIMESTAMP;
ALTER TABLE users ADD COLUMN failed_login_attempts INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN account_locked_until TIMESTAMP;

-- 2. email 필드에 UNIQUE 제약 조건 추가 (NULL 값은 제외)
CREATE UNIQUE INDEX idx_users_email_unique ON users(email) WHERE email IS NOT NULL;

-- 3. role 필드에 CHECK 제약 조건 추가 (유효한 권한만 허용)
ALTER TABLE users ADD CONSTRAINT chk_users_role 
CHECK (role IN ('USER', 'INTERVIEWER', 'ADMIN', 'SUPER_ADMIN'));

-- 4. 사용자 프로필 테이블 생성
CREATE TABLE user_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    department VARCHAR(50),
    position VARCHAR(50),
    phone VARCHAR(20),
    avatar_url VARCHAR(200),
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. 사용자 권한 변경 이력 테이블 생성
CREATE TABLE user_role_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    old_role VARCHAR(20),
    new_role VARCHAR(20),
    changed_by INTEGER REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT
);

-- 6. 사용자 활동 로그 테이블 생성
CREATE TABLE user_activity_log (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    action VARCHAR(50) NOT NULL,
    resource_type VARCHAR(50),
    resource_id INTEGER,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. 시스템 상태 로그 테이블 생성
CREATE TABLE system_status_log (
    id SERIAL PRIMARY KEY,
    metric_name VARCHAR(50) NOT NULL,
    metric_value DECIMAL(10,2),
    unit VARCHAR(20),
    status VARCHAR(20) DEFAULT 'NORMAL',
    checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. 인덱스 생성 (성능 최적화)
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_last_login ON users(last_login);
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_user_role_history_user_id ON user_role_history(user_id);
CREATE INDEX idx_user_activity_log_user_id ON user_activity_log(user_id);
CREATE INDEX idx_user_activity_log_created_at ON user_activity_log(created_at);
CREATE INDEX idx_system_status_log_metric_name ON system_status_log(metric_name);
CREATE INDEX idx_system_status_log_checked_at ON system_status_log(checked_at);

-- 9. 기본 관리자 계정 생성 (비밀번호: admin123)
-- BCrypt 해시된 비밀번호: $2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi
INSERT INTO users (username, password, role, email, full_name, is_active) VALUES 
('admin', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'SUPER_ADMIN', 'admin@company.com', '시스템 관리자', true);

-- 10. 기본 관리자 프로필 생성
INSERT INTO user_profiles (user_id, department, position, bio) VALUES 
((SELECT id FROM users WHERE username = 'admin'), 'IT', 'System Administrator', '시스템 전체 관리자');

-- 11. 기존 사용자들의 기본 정보 설정
UPDATE users SET 
    role = 'USER',
    is_active = true,
    failed_login_attempts = 0
WHERE role IS NULL;

-- 12. 확인용 쿼리 (실행 후 결과 확인)
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY ordinal_position;

-- 13. 생성된 테이블 확인
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('user_profiles', 'user_role_history', 'user_activity_log', 'system_status_log');

-- 14. 관리자 계정 생성 확인
SELECT id, username, role, email, full_name, is_active 
FROM users 
WHERE role IN ('ADMIN', 'SUPER_ADMIN'); 