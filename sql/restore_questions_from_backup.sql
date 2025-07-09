-- 백업에서 인터뷰 질문 복원 쿼리
-- 중복 제거 후 문제가 발생했을 경우에만 사용하세요!

-- 현재 데이터 삭제 (주의: 모든 데이터가 삭제됩니다!)
TRUNCATE TABLE interview_questions RESTART IDENTITY CASCADE;

-- 백업에서 데이터 복원
INSERT INTO interview_questions 
SELECT * FROM interview_questions_backup 
ORDER BY id;

-- 복원 완료 확인
SELECT 
    '복원 완료!' as message,
    COUNT(*) as restored_count
FROM interview_questions;

-- 시퀀스 재설정 (다음 ID가 올바르게 생성되도록)
SELECT setval('interview_questions_id_seq', (SELECT MAX(id) FROM interview_questions));

-- 백업 테이블 삭제 (선택사항)
-- DROP TABLE interview_questions_backup; 