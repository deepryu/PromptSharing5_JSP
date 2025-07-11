-- 인터뷰 질문 중복 제거 향상된 스크립트
-- 실행 전 반드시 백업하고, 단계별로 신중하게 진행하세요.

\echo '============================================='
\echo '🔍 인터뷰 질문 중복 제거 작업을 시작합니다.'
\echo '============================================='

-- 단계 1: 현재 상황 분석
\echo '📊 1단계: 현재 데이터 상황 분석 중...'
SELECT 
    '📈 전체 통계' as info,
    COUNT(*) as total_questions,
    COUNT(DISTINCT question_text) as unique_questions,
    COUNT(*) - COUNT(DISTINCT question_text) as duplicates_to_remove
FROM interview_questions;

-- 단계 2: 중복 질문 상세 현황
\echo '🔍 2단계: 중복 질문 상세 현황...'
WITH duplicate_analysis AS (
    SELECT 
        question_text,
        COUNT(*) as count,
        MIN(id) as keep_id,
        MAX(id) as max_id,
        STRING_AGG(id::text, ', ' ORDER BY id) as all_ids,
        STRING_AGG(category, ', ' ORDER BY id) as categories
    FROM interview_questions 
    GROUP BY question_text 
    HAVING COUNT(*) > 1
)
SELECT 
    '🚨 중복 발견!' as status,
    question_text,
    count as duplicate_count,
    keep_id,
    all_ids,
    categories
FROM duplicate_analysis
ORDER BY count DESC, question_text;

-- 단계 3: 안전 백업 생성
\echo '💾 3단계: 안전 백업 생성 중...'
DROP TABLE IF EXISTS interview_questions_backup_enhanced;
CREATE TABLE interview_questions_backup_enhanced AS 
SELECT * FROM interview_questions;

-- 백업 검증
SELECT 
    '✅ 백업 완료!' as status,
    (SELECT COUNT(*) FROM interview_questions) as original_count,
    (SELECT COUNT(*) FROM interview_questions_backup_enhanced) as backup_count,
    CASE 
        WHEN (SELECT COUNT(*) FROM interview_questions) = (SELECT COUNT(*) FROM interview_questions_backup_enhanced)
        THEN '✅ 백업 성공' 
        ELSE '❌ 백업 실패!' 
    END as backup_status;

-- 단계 4: 중복 제거 실행 (가장 오래된 ID 유지)
\echo '🗑️ 4단계: 중복 질문 제거 실행 중...'
WITH duplicates_to_delete AS (
    SELECT 
        id,
        question_text,
        ROW_NUMBER() OVER (PARTITION BY question_text ORDER BY id ASC) as row_num
    FROM interview_questions
)
DELETE FROM interview_questions 
WHERE id IN (
    SELECT id 
    FROM duplicates_to_delete 
    WHERE row_num > 1
);

-- 단계 5: 제거 결과 확인
\echo '📋 5단계: 제거 결과 확인 중...'
SELECT 
    '🎯 제거 완료!' as status,
    COUNT(*) as remaining_questions,
    COUNT(DISTINCT question_text) as unique_questions_after,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT question_text) 
        THEN '✅ 모든 중복 제거됨' 
        ELSE '⚠️ 중복이 여전히 존재함' 
    END as duplicate_status
FROM interview_questions;

-- 단계 6: 카테고리별 통계
\echo '📊 6단계: 카테고리별 최종 통계...'
SELECT 
    '📈 카테고리별 통계' as info;

SELECT 
    category,
    COUNT(*) as question_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as percentage
FROM interview_questions 
GROUP BY category 
ORDER BY question_count DESC;

-- 단계 7: 난이도별 통계
SELECT 
    '🎯 난이도별 통계' as info;

SELECT 
    difficulty_level,
    COUNT(*) as question_count,
    ROUND(AVG(difficulty_level), 1) as avg_difficulty
FROM interview_questions 
GROUP BY difficulty_level 
ORDER BY difficulty_level;

-- 단계 8: 최종 검증 (중복 재확인)
\echo '🔍 7단계: 최종 검증 - 중복 재확인...'
WITH final_duplicates AS (
    SELECT 
        question_text,
        COUNT(*) as count
    FROM interview_questions 
    GROUP BY question_text 
    HAVING COUNT(*) > 1
)
SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ 성공: 모든 중복이 제거되었습니다!'
        ELSE '❌ 실패: ' || COUNT(*) || '개의 중복이 여전히 존재합니다!'
    END as final_result
FROM final_duplicates;

-- 백업 테이블 정보 (복원이 필요한 경우)
\echo '============================================='
\echo '📝 작업 완료 정보:'
\echo '  - 백업 테이블: interview_questions_backup_enhanced'
\echo '  - 복원 명령어: INSERT INTO interview_questions SELECT * FROM interview_questions_backup_enhanced;'
\echo '  - 백업 삭제: DROP TABLE interview_questions_backup_enhanced;'
\echo '=============================================' 