-- 면접유형 값 표준화 (기존 데이터 업데이트)
-- 사용법: PostgreSQL에서 직접 실행

-- 1. 현재 면접유형 값 확인
SELECT 'Before Update:' as status;
SELECT DISTINCT interview_type, COUNT(*) as count
FROM interview_results 
WHERE interview_type IS NOT NULL 
GROUP BY interview_type 
ORDER BY interview_type;

-- 2. interview_results 테이블의 면접유형 표준화
UPDATE interview_results 
SET interview_type = CASE 
    WHEN interview_type = '1차 면접' THEN '1차면접'
    WHEN interview_type = '2차 면접' THEN '2차면접'
    WHEN interview_type = '최종 면접' THEN '2차면접'  -- 최종면접도 2차면접으로 통합
    WHEN interview_type = '기술 면접' THEN '1차면접'  -- 기술면접은 1차면접으로 통합
    WHEN interview_type = '인성 면접' THEN '2차면접'  -- 인성면접은 2차면접으로 통합
    ELSE interview_type
END
WHERE interview_type IN ('1차 면접', '2차 면접', '최종 면접', '기술 면접', '인성 면접');

-- 3. interview_schedules 테이블도 동일하게 업데이트 (있다면)
UPDATE interview_schedules 
SET interview_type = CASE 
    WHEN interview_type = '1차 면접' THEN '1차면접'
    WHEN interview_type = '2차 면접' THEN '2차면접'
    WHEN interview_type = '최종 면접' THEN '2차면접'
    WHEN interview_type = '기술 면접' THEN '1차면접'
    WHEN interview_type = '인성 면접' THEN '2차면접'
    WHEN interview_type = '1차면접' THEN '1차면접'
    WHEN interview_type = '2차면접' THEN '2차면접'
    WHEN interview_type = '3차면접' THEN '2차면접'
    WHEN interview_type = '임원면접' THEN '2차면접'
    ELSE interview_type
END
WHERE interview_type IS NOT NULL;

-- 4. 업데이트 후 결과 확인
SELECT 'After Update:' as status;
SELECT DISTINCT interview_type, COUNT(*) as count
FROM interview_results 
WHERE interview_type IS NOT NULL 
GROUP BY interview_type 
ORDER BY interview_type;

-- 5. 업데이트된 면접결과 확인 (최근 10개)
SELECT id, candidate_id, interviewer_name, interview_type, interview_date, result_status
FROM interview_results 
ORDER BY id DESC 
LIMIT 10; 