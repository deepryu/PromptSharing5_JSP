-- 면접관 테이블 생성
CREATE TABLE IF NOT EXISTS interviewers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    department VARCHAR(100) NOT NULL,
    position VARCHAR(100),
    phone_number VARCHAR(20),
    expertise VARCHAR(50) DEFAULT '기술',
    role VARCHAR(20) DEFAULT 'JUNIOR',
    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_interviewers_email ON interviewers(email);
CREATE INDEX IF NOT EXISTS idx_interviewers_department ON interviewers(department);
CREATE INDEX IF NOT EXISTS idx_interviewers_expertise ON interviewers(expertise);
CREATE INDEX IF NOT EXISTS idx_interviewers_active ON interviewers(is_active);
CREATE INDEX IF NOT EXISTS idx_interviewers_name ON interviewers(name);

-- 샘플 데이터 삽입
INSERT INTO interviewers (name, email, department, position, phone_number, expertise, role, is_active, notes) VALUES
('김기술', 'kim.tech@company.com', '개발팀', '시니어 개발자', '010-1234-5678', '기술', 'SENIOR', true, 'Java, Spring 전문가'),
('이인사', 'lee.hr@company.com', '인사팀', '인사 매니저', '010-2345-6789', '인사', 'LEAD', true, '10년 경력의 인사 전문가'),
('박경영', 'park.mgmt@company.com', '경영지원팀', '팀장', '010-3456-7890', '경영', 'SENIOR', true, 'MBA 출신, 전략 기획 전문'),
('최개발', 'choi.dev@company.com', '개발팀', '주니어 개발자', '010-4567-8901', '기술', 'JUNIOR', true, 'React, Node.js 전문'),
('정디자인', 'jung.design@company.com', '디자인팀', '시니어 디자이너', '010-5678-9012', '디자인', 'SENIOR', true, 'UI/UX 디자인 10년 경력')
ON CONFLICT (email) DO NOTHING;

-- 트리거 함수 생성 (updated_at 자동 업데이트)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 트리거 생성
DROP TRIGGER IF EXISTS update_interviewers_updated_at ON interviewers;
CREATE TRIGGER update_interviewers_updated_at
    BEFORE UPDATE ON interviewers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column(); 