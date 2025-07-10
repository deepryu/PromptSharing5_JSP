-- interview_results 테이블의 면접유형 값 확인
-- 사용법: PostgreSQL에서 직접 실행

-- 1. 현재 저장된 모든 면접유형 값 확인
SELECT DISTINCT interview_type, COUNT(*) as count
FROM interview_results 
WHERE interview_type IS NOT NULL 
GROUP BY interview_type 
ORDER BY interview_type;

-- 2. 전체 면접 결과 데이터 확인 (최근 10개)
SELECT id, candidate_id, interviewer_name, interview_type, interview_date, result_status
FROM interview_results 
ORDER BY id DESC 
LIMIT 10;

-- 3. 면접유형별 상세 데이터 확인
SELECT interview_type, 
       candidate_id, 
       interviewer_name, 
       interview_date,
       result_status
FROM interview_results 
WHERE interview_type IS NOT NULL 
ORDER BY interview_type, interview_date DESC; 