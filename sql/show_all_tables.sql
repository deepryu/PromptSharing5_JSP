-- promptsharing 데이터베이스의 모든 테이블 목록 조회
-- 실행 방법: psql -h localhost -p 5432 -U postgres -d promptsharing -f show_all_tables.sql

\echo '========================================='
\echo '📋 PromptSharing Database - All Tables'
\echo '========================================='
\echo ''

-- 1. 기본 테이블 목록
\echo '🔹 모든 테이블 목록:'
SELECT 
    schemaname as "스키마",
    tablename as "테이블명",
    tableowner as "소유자"
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

\echo ''
\echo '🔹 테이블별 레코드 수:'

-- 2. 각 테이블의 레코드 수 (동적 쿼리)
DO $$
DECLARE
    table_record RECORD;
    table_count INTEGER;
BEGIN
    FOR table_record IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
        ORDER BY tablename
    LOOP
        EXECUTE 'SELECT COUNT(*) FROM ' || table_record.tablename INTO table_count;
        RAISE NOTICE '📊 % : % rows', table_record.tablename, table_count;
    END LOOP;
END $$;

\echo ''
\echo '🔹 테이블별 상세 정보:'

-- 3. 테이블과 컬럼 정보
SELECT 
    t.table_name as "테이블명",
    COUNT(c.column_name) as "컬럼수",
    STRING_AGG(c.column_name, ', ' ORDER BY c.ordinal_position) as "주요컬럼들"
FROM information_schema.tables t
LEFT JOIN information_schema.columns c ON t.table_name = c.table_name
WHERE t.table_schema = 'public' 
  AND t.table_type = 'BASE TABLE'
GROUP BY t.table_name
ORDER BY t.table_name;

\echo ''
\echo '🔹 데이터베이스 전체 통계:'

-- 4. 전체 통계
SELECT 
    COUNT(*) as "총테이블수"
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE';

-- 5. 데이터베이스 크기
SELECT 
    pg_size_pretty(pg_database_size('promptsharing')) as "DB크기";

\echo ''
\echo '========================================='
\echo '✅ 테이블 조회 완료!'
\echo '=========================================' 