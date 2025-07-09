-- schedule_id가 NULL인 모든 인터뷰 결과 자동 연결
-- 문제: 인터뷰 결과는 있지만 schedule_id가 NULL이어서 상태가 "예정"으로 표시됨
-- 해결: candidate_id와 날짜를 기준으로 자동 연결

-- 1. 현재 NULL schedule_id를 가진 결과들 확인
SELECT 'NULL_SCHEDULE_RESULTS' as status,
       r.id as result_id,
       r.candidate_id,
       r.schedule_id,
       r.interview_date,
       r.interview_type,
       r.result_status
FROM interview_results r
WHERE r.schedule_id IS NULL
ORDER BY r.candidate_id, r.interview_date;

-- 2. 연결 가능한 스케줄 확인 (candidate_id와 날짜 매칭)
SELECT 'LINKABLE_SCHEDULES' as status,
       r.id as result_id,
       r.candidate_id,
       r.interview_date as result_date,
       s.id as schedule_id,
       s.interview_date as schedule_date,
       s.interview_type as schedule_type,
       r.interview_type as result_type
FROM interview_results r
LEFT JOIN interview_schedules s ON (
    r.candidate_id = s.candidate_id 
    AND r.interview_date = s.interview_date
)
WHERE r.schedule_id IS NULL
  AND s.id IS NOT NULL
ORDER BY r.candidate_id, r.interview_date;

-- 3. 자동 연결 실행 (candidate_id와 interview_date 기준 매칭)
UPDATE interview_results 
SET schedule_id = (
    SELECT s.id 
    FROM interview_schedules s 
    WHERE s.candidate_id = interview_results.candidate_id 
      AND s.interview_date = interview_results.interview_date
    LIMIT 1
),
updated_at = CURRENT_TIMESTAMP
WHERE schedule_id IS NULL
  AND EXISTS (
    SELECT 1 
    FROM interview_schedules s 
    WHERE s.candidate_id = interview_results.candidate_id 
      AND s.interview_date = interview_results.interview_date
  );

-- 4. 연결 결과 확인
SELECT 'AFTER_AUTO_LINK' as status,
       r.id as result_id,
       r.candidate_id,
       r.schedule_id,
       r.interview_date,
       r.interview_type,
       r.result_status,
       c.name as candidate_name
FROM interview_results r
JOIN candidates c ON r.candidate_id = c.id
WHERE r.candidate_id IN (563, 564)  -- 문제가 있던 지원자들 확인
ORDER BY r.candidate_id, r.interview_date;

-- 5. 최종 검증 - 모든 연결 관계 확인
SELECT 'FINAL_VERIFICATION' as status,
       s.id as schedule_id,
       s.candidate_id,
       c.name as candidate_name,
       s.interview_date,
       s.interview_type as schedule_type,
       r.id as result_id,
       r.interview_type as result_type,
       r.result_status
FROM interview_schedules s
JOIN candidates c ON s.candidate_id = c.id
LEFT JOIN interview_results r ON s.id = r.schedule_id
WHERE s.candidate_id IN (563, 564)
ORDER BY s.candidate_id, s.interview_date; 