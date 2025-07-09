-- 중복된 인터뷰 질문 제거 쿼리
-- 화면에서 확인된 중복 질문들을 제거합니다.
-- 중복 중 가장 먼저 생성된 것(id가 작은 것)을 남기고 나머지를 삭제합니다.

-- 1단계: 중복 질문 확인 (실행 전 검토용)
SELECT 
    question_text,
    COUNT(*) as duplicate_count,
    MIN(id) as keep_id,
    STRING_AGG(id::text, ', ' ORDER BY id) as all_ids
FROM interview_questions 
GROUP BY question_text 
HAVING COUNT(*) > 1
ORDER BY question_text;

-- 2단계: 중복 제거 실행
-- WITH 절을 사용하여 각 질문의 중복 중 첫 번째(id가 가장 작은 것)만 남기고 삭제
WITH duplicates AS (
    SELECT 
        id,
        question_text,
        ROW_NUMBER() OVER (PARTITION BY question_text ORDER BY id ASC) as row_num
    FROM interview_questions
)
DELETE FROM interview_questions 
WHERE id IN (
    SELECT id 
    FROM duplicates 
    WHERE row_num > 1
);

-- 3단계: 결과 확인
SELECT 
    '중복 제거 완료!' as message,
    COUNT(*) as total_questions
FROM interview_questions;

-- 4단계: 중복이 모두 제거되었는지 최종 확인
SELECT 
    question_text,
    COUNT(*) as count
FROM interview_questions 
GROUP BY question_text 
HAVING COUNT(*) > 1;

-- 위 쿼리 결과가 빈 결과셋이면 중복 제거가 성공적으로 완료된 것입니다. 