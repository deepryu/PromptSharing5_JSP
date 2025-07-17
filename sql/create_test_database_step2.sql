-- ================================================================
-- 테스트 전용 데이터베이스 스키마 생성 스크립트 (2단계)
-- 목적: promptsharing_test DB에 테이블 생성 및 테스트 데이터 삽입
-- 실행: promptsharing_test 데이터베이스에 연결된 상태에서 실행
-- 연결: psql -d promptsharing_test -U postgres
-- ================================================================

-- 프로덕션 DB 스키마를 테스트 DB로 복사

-- Users 테이블
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(20) DEFAULT 'USER',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Candidates 테이블
CREATE TABLE candidates (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    resume TEXT,
    status VARCHAR(20) DEFAULT 'APPLIED',
    applied_position VARCHAR(100),
    experience_years INTEGER,
    education VARCHAR(200),
    skills TEXT,
    cover_letter TEXT,
    resume_file_name VARCHAR(255),
    resume_file_path VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Interview Schedules 테이블
CREATE TABLE interview_schedules (
    id SERIAL PRIMARY KEY,
    candidate_id INTEGER REFERENCES candidates(id) ON DELETE CASCADE,
    interviewer_name VARCHAR(100) NOT NULL,
    interview_date TIMESTAMP NOT NULL,
    interview_type VARCHAR(50) DEFAULT '기술면접',
    location VARCHAR(200),
    notes TEXT,
    status VARCHAR(20) DEFAULT 'SCHEDULED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Interview Results 테이블
CREATE TABLE interview_results (
    id SERIAL PRIMARY KEY,
    candidate_id INTEGER NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    schedule_id INTEGER REFERENCES interview_schedules(id) ON DELETE SET NULL,
    interviewer_name VARCHAR(100) NOT NULL,
    interview_date TIMESTAMP NOT NULL,
    interview_type VARCHAR(50) DEFAULT '기술면접',
    technical_score INTEGER CHECK (technical_score >= 0 AND technical_score <= 100),
    communication_score INTEGER CHECK (communication_score >= 0 AND communication_score <= 100),
    problem_solving_score INTEGER CHECK (problem_solving_score >= 0 AND problem_solving_score <= 100),
    cultural_fit_score INTEGER CHECK (cultural_fit_score >= 0 AND cultural_fit_score <= 100),
    overall_evaluation TEXT,
    strengths TEXT,
    weaknesses TEXT,
    recommendation VARCHAR(20) CHECK (recommendation IN ('HIRE', 'NO_HIRE', 'CONSIDER')),
    detailed_feedback TEXT,
    additional_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Interview Questions 테이블
CREATE TABLE interview_questions (
    id SERIAL PRIMARY KEY,
    category VARCHAR(50) NOT NULL,
    question_text TEXT NOT NULL,
    question_type VARCHAR(20) DEFAULT 'open',
    difficulty_level VARCHAR(20) DEFAULT 'medium',
    expected_answer TEXT,
    evaluation_criteria TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Interviewers 테이블
CREATE TABLE interviewers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(100),
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    specialization TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- System Settings 테이블
CREATE TABLE system_settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50) DEFAULT 'system'
);

-- Activity History 테이블
CREATE TABLE activity_history (
    id SERIAL PRIMARY KEY,
    activity_type VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) DEFAULT 'system'
);

-- User Activity Log 테이블
CREATE TABLE user_activity_log (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    username VARCHAR(50),
    activity_type VARCHAR(50) NOT NULL,
    description TEXT,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 테스트용 기본 데이터 생성
INSERT INTO users (username, password, email, role) VALUES
('test_admin', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'test_admin@example.com', 'ADMIN'),
('test_user', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'test_user@example.com', 'USER');

INSERT INTO interviewers (name, department, email, phone) VALUES
('테스트 면접관', 'IT', 'test_interviewer@example.com', '02-0000-0000');

INSERT INTO interview_questions (category, question_text, question_type) VALUES
('Technical', '테스트용 기술 질문입니다.', 'open'),
('Personal', '테스트용 인성 질문입니다.', 'open');

INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('system_name', '테스트 채용 관리 시스템', '테스트 환경 시스템 이름'),
('version', '1.3.0-TEST', '테스트 환경 버전');

-- 테스트 DB 생성 완료 확인
SELECT '=== 테스트 데이터베이스 스키마 생성 완료 ===' as status;

SELECT 'users' as table_name, count(*) as count FROM users
UNION ALL
SELECT 'interviewers', count(*) FROM interviewers
UNION ALL
SELECT 'interview_questions', count(*) FROM interview_questions
UNION ALL
SELECT 'system_settings', count(*) FROM system_settings;

SELECT 'promptsharing_test 스키마 생성 완료!' as message;
SELECT '테스트 계정: test_admin / admin123' as login_info;
SELECT '주의: 이 DB는 테스트 전용입니다!' as warning; 