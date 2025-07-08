-- 인터뷰 결과 테이블 생성
CREATE TABLE interview_results (
    id SERIAL PRIMARY KEY,
    candidate_id INTEGER NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    schedule_id INTEGER REFERENCES interview_schedules(id) ON DELETE SET NULL,
    interviewer_name VARCHAR(100) NOT NULL,
    interview_date DATE NOT NULL,
    interview_type VARCHAR(50) DEFAULT '기술면접',
    
    -- 평가 점수 (1-5점 척도)
    technical_score INTEGER CHECK (technical_score >= 1 AND technical_score <= 5),
    communication_score INTEGER CHECK (communication_score >= 1 AND communication_score <= 5),
    problem_solving_score INTEGER CHECK (problem_solving_score >= 1 AND problem_solving_score <= 5),
    attitude_score INTEGER CHECK (attitude_score >= 1 AND attitude_score <= 5),
    overall_score DECIMAL(3,2) CHECK (overall_score >= 1.0 AND overall_score <= 5.0),
    
    -- 평가 내용
    strengths TEXT,
    weaknesses TEXT,
    detailed_feedback TEXT,
    improvement_suggestions TEXT,
    
    -- 최종 결과
    result_status VARCHAR(20) DEFAULT 'pending', -- pending, pass, fail, hold
    hire_recommendation BOOLEAN DEFAULT false,
    next_step VARCHAR(100), -- 다음 단계 (2차 면접, 최종 면접, 입사 제안 등)
    
    -- 메타데이터
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- 인덱스를 위한 제약조건
    UNIQUE(candidate_id, interview_date, interviewer_name)
);

-- 인덱스 생성
CREATE INDEX idx_interview_results_candidate ON interview_results(candidate_id);
CREATE INDEX idx_interview_results_date ON interview_results(interview_date);
CREATE INDEX idx_interview_results_status ON interview_results(result_status);
CREATE INDEX idx_interview_results_score ON interview_results(overall_score);

-- 업데이트 시간 자동 갱신을 위한 트리거
CREATE OR REPLACE FUNCTION update_interview_results_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_interview_results_updated_at_trigger
    BEFORE UPDATE ON interview_results
    FOR EACH ROW
    EXECUTE FUNCTION update_interview_results_updated_at();

-- 테이블 생성 완료
SELECT 'interview_results 테이블이 성공적으로 생성되었습니다.' AS message; 