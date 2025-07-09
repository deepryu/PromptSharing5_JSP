-- 류승환(ID 563) 인터뷰 결과와 일정 연결 수정
-- 문제: 인터뷰 결과(ID 243)의 schedule_id가 NULL로 되어 있어서 Schedule ID 196과 연결되지 않음
-- 해결: schedule_id를 196으로 업데이트

-- 1. 수정 전 상태 확인
SELECT 'BEFORE UPDATE' as status, 
       id, candidate_id, schedule_id, interview_date, interview_type, result_status 
FROM interview_results 
WHERE id = 243;

-- 2. Schedule ID 연결 수정
UPDATE interview_results 
SET schedule_id = 196,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 243 
  AND candidate_id = 563 
  AND schedule_id IS NULL;

-- 3. 수정 결과 확인
SELECT 'AFTER UPDATE' as status, 
       id, candidate_id, schedule_id, interview_date, interview_type, result_status 
FROM interview_results 
WHERE id = 243;

-- 4. 연결 관계 최종 확인
SELECT 'FINAL CHECK' as status,
       s.id as schedule_id,
       s.candidate_id,
       s.interview_date as schedule_date,
       s.interview_type as schedule_type,
       r.id as result_id,
       r.schedule_id as linked_schedule_id,
       r.interview_type as result_type,
       r.result_status
FROM interview_schedules s
LEFT JOIN interview_results r ON s.id = r.schedule_id
WHERE s.id = 196; 