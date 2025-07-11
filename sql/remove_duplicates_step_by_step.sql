-- 인터뷰 질문 중복 제거 - 단계별 실행용
-- 아래 쿼리들을 하나씩 순서대로 실행하세요.

-- ============================================================================
-- 1단계: 현재 상황 확인 (실행해서 중복이 있는지 확인)
-- ============================================================================
SELECT 
    COUNT(*) as "총 질문 수",
    COUNT(DISTINCT question_text) as "고유 질문 수",
    COUNT(*) - COUNT(DISTINCT question_text) as "중복 개수"
FROM interview_questions;

-- ============================================================================
-- 2단계: 중복 질문 목록 확인 (어떤 질문들이 중복인지 확인)
-- ============================================================================
SELECT 
    question_text as "중복된 질문",
    COUNT(*) as "중복 횟수",
    STRING_AGG(id::text, ', ' ORDER BY id) as "질문 ID들"
FROM interview_questions 
GROUP BY question_text 
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- ============================================================================
-- 3단계: 백업 생성 (반드시 실행!)
-- ============================================================================
DROP TABLE IF EXISTS interview_questions_backup;
CREATE TABLE interview_questions_backup AS 
SELECT * FROM interview_questions;

-- 백업 확인
SELECT COUNT(*) as "백업된 질문 수" FROM interview_questions_backup;

-- ============================================================================
-- 4단계: 중복 제거 실행 (신중하게!)
-- 가장 먼저 생성된 질문(ID가 작은 것)만 남기고 나머지 삭제
-- ============================================================================
WITH duplicates_to_delete AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (PARTITION BY question_text ORDER BY id ASC) as row_num
    FROM interview_questions
)
DELETE FROM interview_questions 
WHERE id IN (
    SELECT id 
    FROM duplicates_to_delete 
    WHERE row_num > 1
);

-- ============================================================================
-- 5단계: 결과 확인
-- ============================================================================
SELECT 
    COUNT(*) as "남은 질문 수",
    COUNT(DISTINCT question_text) as "고유 질문 수"
FROM interview_questions;

-- 중복이 모두 제거되었는지 재확인
SELECT 
    question_text,
    COUNT(*) as count
FROM interview_questions 
GROUP BY question_text 
HAVING COUNT(*) > 1;

-- ============================================================================
-- 복원이 필요한 경우 (문제가 생겼을 때만 실행)
-- ============================================================================
/*
TRUNCATE TABLE interview_questions;
INSERT INTO interview_questions SELECT * FROM interview_questions_backup;
*/

-- ============================================================================
-- 백업 삭제 (모든 작업이 성공적으로 완료된 후에만 실행)
-- ============================================================================
/*
DROP TABLE interview_questions_backup;
*/ 