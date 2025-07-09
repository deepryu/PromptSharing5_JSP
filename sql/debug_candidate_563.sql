-- ID 563 류승환 데이터 디버깅 SQL
-- 문제: "1차 면접" / "합격" 결과가 있는데 상태가 "예정"으로 표시됨

-- 1. 지원자 기본 정보 확인
SELECT 'CANDIDATE INFO' as type, id, name, email, created_at
FROM candidates 
WHERE id = 563;

-- 2. 인터뷰 일정 확인 (Schedule ID 196)
SELECT 'SCHEDULE INFO' as type, id, candidate_id, interview_date, interview_time, interview_type, location, interviewer_name, notes
FROM interview_schedules 
WHERE candidate_id = 563;

-- 3. 인터뷰 결과 확인 (schedule_id 기준)
SELECT 'RESULTS BY SCHEDULE_ID' as type, id, candidate_id, schedule_id, interview_date, interview_type, result_status, interviewer_name
FROM interview_results 
WHERE schedule_id = 196;

-- 4. 인터뷰 결과 확인 (candidate_id 기준)
SELECT 'RESULTS BY CANDIDATE_ID' as type, id, candidate_id, schedule_id, interview_date, interview_type, result_status, interviewer_name
FROM interview_results 
WHERE candidate_id = 563;

-- 5. Schedule ID 196 관련 모든 결과
SELECT 'ALL RESULTS FOR SCHEDULE 196' as type, id, candidate_id, schedule_id, interview_date, interview_type, result_status, interviewer_name
FROM interview_results 
WHERE schedule_id = 196 OR candidate_id = 563;

-- 6. 연결 관계 확인 (JOIN으로 확인)
SELECT 'JOIN CHECK' as type, 
       s.id as schedule_id, 
       s.candidate_id, 
       s.interview_date as schedule_date,
       s.interview_type as schedule_type,
       r.id as result_id,
       r.schedule_id as result_schedule_id,
       r.interview_date as result_date,
       r.interview_type as result_type,
       r.result_status
FROM interview_schedules s
LEFT JOIN interview_results r ON s.id = r.schedule_id
WHERE s.candidate_id = 563;

-- 7. 최신 스케줄 조회 (CandidateDAO에서 사용하는 쿼리와 동일)
SELECT 'LATEST SCHEDULE' as type, id, candidate_id, interview_date, interview_time 
FROM interview_schedules 
WHERE candidate_id = 563
ORDER BY interview_date DESC, interview_time DESC
LIMIT 1; 