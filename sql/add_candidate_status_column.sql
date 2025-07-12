-- candidates 테이블에 status 컬럼 추가 및 기본값 설정
-- 작성일: 2025-01-08
-- 목적: 지원자 상태 관리 기능 개선 (면접완료, 활성, 비활성 등 상태 추적)

-- 1. status 컬럼 추가
ALTER TABLE candidates ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT '활성';

-- 2. 기존 데이터에 기본값 설정 (NULL인 경우만)
UPDATE candidates SET status = '활성' WHERE status IS NULL;

-- 3. 상태별 지원자 수 확인
SELECT status, COUNT(*) as count FROM candidates GROUP BY status;

-- 4. 테이블 구조 확인 (PostgreSQL 표준 SQL)
SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'candidates' AND column_name = 'status';

-- 참고: 사용 가능한 상태 값들
-- '활성' - 일반적인 지원자 상태
-- '면접완료' - 2차면접 완료 (합격/불합격 결정됨)
-- '비활성' - 더 이상 진행하지 않는 지원자
-- '대기' - 면접 일정 대기 중
-- '취소' - 지원 취소된 상태 