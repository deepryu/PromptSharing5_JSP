-- 지원자 테이블에 이력서 파일 관련 컬럼 추가
-- 작성일: 2024-01-XX
-- 목적: 지원자 등록 시 이력서 파일 첨부 기능 지원

-- candidates 테이블에 이력서 파일 관련 컬럼 추가
ALTER TABLE candidates 
ADD COLUMN resume_file_name VARCHAR(255),
ADD COLUMN resume_file_path VARCHAR(500),
ADD COLUMN resume_file_size BIGINT DEFAULT 0,
ADD COLUMN resume_file_type VARCHAR(50),
ADD COLUMN resume_uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- 컬럼 설명:
-- resume_file_name: 원본 파일명 (예: "홍길동_이력서.pdf")
-- resume_file_path: 서버에 저장된 파일 경로 (예: "uploads/resumes/20240101_123456_홍길동_이력서.pdf")
-- resume_file_size: 파일 크기 (바이트 단위)
-- resume_file_type: 파일 유형 (pdf, hwp, doc, docx)
-- resume_uploaded_at: 이력서 업로드 일시

-- 기존 데이터에 대한 기본값 설정 (필요시)
UPDATE candidates 
SET resume_file_name = NULL, 
    resume_file_path = NULL, 
    resume_file_size = 0, 
    resume_file_type = NULL,
    resume_uploaded_at = NULL
WHERE resume_file_name IS NULL;

-- 인덱스 추가 (성능 향상)
CREATE INDEX idx_candidates_resume_type ON candidates(resume_file_type);
CREATE INDEX idx_candidates_resume_uploaded ON candidates(resume_uploaded_at);

-- 확인 쿼리
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'candidates' 
AND column_name LIKE 'resume_%'
ORDER BY ordinal_position; 