-- 중복 질문 제거 전 백업 쿼리
-- 중복 제거 작업 전에 반드시 실행하여 데이터를 백업하세요!

-- 백업 테이블 생성 및 데이터 복사
CREATE TABLE interview_questions_backup AS 
SELECT * FROM interview_questions;

-- 백업 완료 확인
SELECT 
    '백업 완료!' as message,
    (SELECT COUNT(*) FROM interview_questions) as original_count,
    (SELECT COUNT(*) FROM interview_questions_backup) as backup_count;

-- 중복 질문 현황 확인
SELECT 
    '=== 중복 질문 현황 ===' as info;

SELECT 
    question_text,
    COUNT(*) as duplicate_count,
    MIN(id) as first_id,
    MAX(id) as last_id,
    STRING_AGG(id::text, ', ' ORDER BY id) as all_ids
FROM interview_questions 
GROUP BY question_text 
HAVING COUNT(*) > 1
ORDER BY question_text; 