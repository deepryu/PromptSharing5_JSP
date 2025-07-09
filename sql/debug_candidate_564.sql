-- ID 564 지원자 데이터 디버깅 SQL
-- 문제: 인터뷰 결과가 있는데 상태가 "예정"으로 표시됨

-- 1. 지원자 기본 정보 확인
SELECT 'CANDIDATE INFO' as type, id, name, email, created_at
FROM candidates 
WHERE id = 564;

-- 2. 인터뷰 일정 확인
SELECT 'SCHEDULE INFO' as type, id, candidate_id, interview_date, interview_time, interview_type, location, interviewer_name
FROM interview_schedules 
WHERE candidate_id = 564;

-- 3. 인터뷰 결과 확인 (candidate_id 기준)
SELECT 'RESULTS BY CANDIDATE_ID' as type, id, candidate_id, schedule_id, interview_date, interview_type, result_status, interviewer_name
FROM interview_results 
WHERE candidate_id = 564;

-- 4. 최신 스케줄 조회 (CandidateDAO에서 사용하는 쿼리와 동일)
SELECT 'LATEST SCHEDULE' as type, id, candidate_id, interview_date, interview_time 
FROM interview_schedules 
WHERE candidate_id = 564
ORDER BY interview_date DESC, interview_time DESC
LIMIT 1;

-- 5. Schedule ID별 결과 확인 (564번의 최신 스케줄 ID를 사용)
-- 이 쿼리는 위 결과를 보고 실제 schedule_id를 넣어서 실행해야 함
SELECT 'CHECK SCHEDULE_ID LINK' as type, 
       s.id as schedule_id,
       r.id as result_id,
       r.schedule_id as result_schedule_id,
       r.interview_type,
       r.result_status
FROM interview_schedules s
LEFT JOIN interview_results r ON s.id = r.schedule_id
WHERE s.candidate_id = 564;

-- 6. NULL schedule_id를 가진 결과들 확인
SELECT 'NULL_SCHEDULE_ID_RESULTS' as type, id, candidate_id, schedule_id, interview_date, interview_type, result_status
FROM interview_results 
WHERE candidate_id = 564 AND schedule_id IS NULL; 