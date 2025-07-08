-- interview_results 테이블 스키마 업데이트
-- 기존 폼과 호환되도록 컬럼 타입 및 제약조건 수정

-- 1. hire_recommendation을 BOOLEAN에서 VARCHAR로 변경
ALTER TABLE interview_results 
ALTER COLUMN hire_recommendation TYPE VARCHAR(10) 
USING CASE 
    WHEN hire_recommendation = true THEN 'yes'
    WHEN hire_recommendation = false THEN 'no'
    ELSE 'no'
END;

-- 2. hire_recommendation 기본값을 'no'로 설정
ALTER TABLE interview_results 
ALTER COLUMN hire_recommendation SET DEFAULT 'no';

-- 3. hire_recommendation에 체크 제약조건 추가
ALTER TABLE interview_results 
ADD CONSTRAINT chk_hire_recommendation 
CHECK (hire_recommendation IN ('yes', 'no'));

-- 4. 점수 범위를 0-100점으로 변경
ALTER TABLE interview_results 
DROP CONSTRAINT IF EXISTS interview_results_technical_score_check;

ALTER TABLE interview_results 
DROP CONSTRAINT IF EXISTS interview_results_communication_score_check;

ALTER TABLE interview_results 
DROP CONSTRAINT IF EXISTS interview_results_problem_solving_score_check;

ALTER TABLE interview_results 
DROP CONSTRAINT IF EXISTS interview_results_attitude_score_check;

ALTER TABLE interview_results 
DROP CONSTRAINT IF EXISTS interview_results_overall_score_check;

-- 새로운 점수 제약조건 추가 (0-100점)
ALTER TABLE interview_results 
ADD CONSTRAINT chk_technical_score 
CHECK (technical_score >= 0 AND technical_score <= 100);

ALTER TABLE interview_results 
ADD CONSTRAINT chk_communication_score 
CHECK (communication_score >= 0 AND communication_score <= 100);

ALTER TABLE interview_results 
ADD CONSTRAINT chk_problem_solving_score 
CHECK (problem_solving_score >= 0 AND problem_solving_score <= 100);

ALTER TABLE interview_results 
ADD CONSTRAINT chk_attitude_score 
CHECK (attitude_score >= 0 AND attitude_score <= 100);

-- 5. overall_score를 0-100점 범위로 변경
ALTER TABLE interview_results 
ALTER COLUMN overall_score TYPE DECIMAL(5,2);

ALTER TABLE interview_results 
ADD CONSTRAINT chk_overall_score 
CHECK (overall_score >= 0.0 AND overall_score <= 100.0);

-- 6. interview_date를 TIMESTAMP로 변경 (시간 포함)
ALTER TABLE interview_results 
ALTER COLUMN interview_date TYPE TIMESTAMP;

-- 스키마 업데이트 완료
SELECT 'interview_results 스키마가 성공적으로 업데이트되었습니다.' AS message; 