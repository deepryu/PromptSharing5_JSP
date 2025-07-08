-- 인터뷰 결과와 선택된 질문들을 연결하는 테이블 (간단 버전)
DROP TABLE IF EXISTS interview_result_questions CASCADE;

CREATE TABLE interview_result_questions (
    id SERIAL PRIMARY KEY,
    result_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,
    is_asked BOOLEAN DEFAULT FALSE,
    asked_at TIMESTAMP,
    answer_summary TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 외래키 제약조건 추가 (테이블이 존재하는 경우에만)
DO $$
BEGIN
    -- interview_results 테이블이 존재하는 경우 외래키 추가
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'interview_results') THEN
        ALTER TABLE interview_result_questions 
        ADD CONSTRAINT fk_result_questions_result 
        FOREIGN KEY (result_id) REFERENCES interview_results(id) ON DELETE CASCADE;
    END IF;
    
    -- interview_questions 테이블이 존재하는 경우 외래키 추가
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'interview_questions') THEN
        ALTER TABLE interview_result_questions 
        ADD CONSTRAINT fk_result_questions_question 
        FOREIGN KEY (question_id) REFERENCES interview_questions(id) ON DELETE CASCADE;
    END IF;
END $$;

-- 유니크 제약조건 추가
ALTER TABLE interview_result_questions 
ADD CONSTRAINT uk_result_question UNIQUE(result_id, question_id);

-- 인덱스 생성
CREATE INDEX idx_result_questions_result_id ON interview_result_questions(result_id);
CREATE INDEX idx_result_questions_question_id ON interview_result_questions(question_id);
CREATE INDEX idx_result_questions_is_asked ON interview_result_questions(is_asked);

-- 테이블 코멘트
COMMENT ON TABLE interview_result_questions IS '인터뷰 결과와 선택된 질문들의 연결 테이블';
COMMENT ON COLUMN interview_result_questions.result_id IS '인터뷰 결과 ID';
COMMENT ON COLUMN interview_result_questions.question_id IS '인터뷰 질문 ID';
COMMENT ON COLUMN interview_result_questions.is_asked IS '질문 실시 여부';
COMMENT ON COLUMN interview_result_questions.asked_at IS '질문 실시 시간';
COMMENT ON COLUMN interview_result_questions.answer_summary IS '답변 요약'; 