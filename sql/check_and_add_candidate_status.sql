-- candidates 테이블에 status 컬럼 확인 및 추가
-- 사용법: PostgreSQL에서 직접 실행

-- 1. 먼저 현재 candidates 테이블 구조 확인
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'candidates' 
ORDER BY ordinal_position;

-- 2. status 컬럼이 없다면 추가 (안전한 방식)
DO $$
BEGIN
    -- status 컬럼이 존재하는지 확인
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'candidates' 
        AND column_name = 'status'
    ) THEN
        -- status 컬럼 추가
        ALTER TABLE candidates ADD COLUMN status VARCHAR(20) DEFAULT '활성';
        
        -- 기존 데이터에 기본값 설정
        UPDATE candidates SET status = '활성' WHERE status IS NULL;
        
        RAISE NOTICE 'candidates 테이블에 status 컬럼이 추가되었습니다.';
    ELSE
        RAISE NOTICE 'candidates 테이블에 status 컬럼이 이미 존재합니다.';
    END IF;
END $$;

-- 3. 테이블 구조 다시 확인
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'candidates' 
ORDER BY ordinal_position;

-- 4. 현재 데이터 확인
SELECT id, name, email, status, created_at 
FROM candidates 
ORDER BY id 
LIMIT 10; 