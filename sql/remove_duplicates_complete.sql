-- 인터뷰 질문 중복 제거 통합 스크립트
-- 백업 → 중복 확인 → 제거 → 검증 순서로 안전하게 실행합니다.

\echo '======================================='
\echo '인터뷰 질문 중복 제거 작업을 시작합니다.'
\echo '======================================='

-- 1단계: 백업 테이블 생성
\echo '1단계: 데이터 백업 중...'
DROP TABLE IF EXISTS interview_questions_backup;
CREATE TABLE interview_questions_backup AS 
SELECT * FROM interview_questions;

-- 백업 확인
SELECT 
    '✅ 백업 완료!' as status,
    (SELECT COUNT(*) FROM interview_questions) as original_count,
    (SELECT COUNT(*) FROM interview_questions_backup) as backup_count;

-- 2단계: 중복 질문 현황 확인
\echo '2단계: 중복 질문 현황 확인 중...'
SELECT 
    '🔍 중복 질문 현황' as info;

SELECT 
    question_text,
    COUNT(*) as duplicate_count,
    MIN(id) as keep_id,
    STRING_AGG(id::text, ', ' ORDER BY id) as delete_ids
FROM interview_questions 
GROUP BY question_text 
HAVING COUNT(*) > 1
ORDER BY question_text;

-- 3단계: 중복 제거 실행
\echo '3단계: 중복 질문 제거 중...'
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

-- 4단계: 제거 결과 확인
\echo '4단계: 제거 결과 확인 중...'
SELECT 
    '✅ 중복 제거 완료!' as status,
    COUNT(*) as remaining_questions
FROM interview_questions;

-- 5단계: 중복이 모두 제거되었는지 최종 검증
\echo '5단계: 최종 검증 중...'
WITH final_check AS (
    SELECT 
        question_text,
        COUNT(*) as count
    FROM interview_questions 
    GROUP BY question_text 
    HAVING COUNT(*) > 1
)
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM final_check) THEN '❌ 여전히 중복이 존재합니다!'
        ELSE '✅ 모든 중복이 성공적으로 제거되었습니다!'
    END as final_result;

-- 6단계: 작업 완료 요약
\echo '6단계: 작업 완료 요약'
SELECT 
    '📊 작업 완료 요약' as summary;

SELECT 
    (SELECT COUNT(*) FROM interview_questions_backup) as original_total,
    (SELECT COUNT(*) FROM interview_questions) as current_total,
    (SELECT COUNT(*) FROM interview_questions_backup) - (SELECT COUNT(*) FROM interview_questions) as removed_count;

\echo '======================================='
\echo '중복 제거 작업이 완료되었습니다.'
\echo '백업은 interview_questions_backup 테이블에 저장되어 있습니다.'
\echo '문제가 발생하면 restore_questions_from_backup.sql을 실행하세요.'
\echo '=======================================' 