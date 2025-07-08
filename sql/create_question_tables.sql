-- 질문/평가 항목 관리 시스템 테이블 생성 스크립트

-- 1. 인터뷰 질문 관리 테이블
CREATE TABLE IF NOT EXISTS interview_questions (
    id SERIAL PRIMARY KEY,
    question_text TEXT NOT NULL,
    category VARCHAR(100) NOT NULL DEFAULT '기술', -- 기술, 기술-Java-초급, 기술-Java-중급, 기술-Java-고급, 기술-Python-초급, 기술-Python-중급, 기술-Python-고급, 인성, 경험, 상황
    difficulty_level INTEGER NOT NULL DEFAULT 3 CHECK (difficulty_level >= 1 AND difficulty_level <= 5),
    expected_answer TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. 평가 기준 관리 테이블
CREATE TABLE IF NOT EXISTS evaluation_criteria (
    id SERIAL PRIMARY KEY,
    criteria_name VARCHAR(100) NOT NULL,
    description TEXT,
    max_score INTEGER NOT NULL DEFAULT 10,
    weight DECIMAL(3,2) NOT NULL DEFAULT 1.00 CHECK (weight >= 0.1 AND weight <= 3.0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_interview_questions_category ON interview_questions(category);
CREATE INDEX IF NOT EXISTS idx_interview_questions_difficulty ON interview_questions(difficulty_level);
CREATE INDEX IF NOT EXISTS idx_interview_questions_active ON interview_questions(is_active);
CREATE INDEX IF NOT EXISTS idx_evaluation_criteria_active ON evaluation_criteria(is_active);

-- 기본 질문 데이터 삽입
INSERT INTO interview_questions (question_text, category, difficulty_level, expected_answer) VALUES
-- 일반 기술 질문
('소프트웨어 개발 생명주기(SDLC)에 대해 설명해주세요.', '기술', 2, '요구사항 분석, 설계, 구현, 테스트, 배포, 유지보수의 단계별 과정'),
('버전 관리 시스템(Git)의 기본 개념과 주요 명령어를 설명해주세요.', '기술', 2, 'commit, push, pull, merge, branch 등의 개념과 사용법'),

-- Java 초급 질문
('Java의 기본 데이터 타입에는 어떤 것들이 있나요?', '기술-Java-초급', 1, 'byte, short, int, long, float, double, boolean, char'),
('Java에서 클래스와 객체의 차이점을 설명해주세요.', '기술-Java-초급', 2, '클래스는 설계도, 객체는 실제 생성된 인스턴스'),
('Java의 접근 제어자(public, private, protected, default)에 대해 설명해주세요.', '기술-Java-초급', 2, '각 접근 제어자의 범위와 사용 목적'),

-- Java 중급 질문
('Java의 컬렉션 프레임워크에 대해 설명해주세요.', '기술-Java-중급', 3, 'List, Set, Map 인터페이스와 구현체들의 특징과 사용법'),
('Java의 예외 처리 메커니즘을 설명해주세요.', '기술-Java-중급', 3, 'try-catch-finally, checked/unchecked exception, throws'),
('Java의 스레드와 동기화에 대해 설명해주세요.', '기술-Java-중급', 4, 'Thread 클래스, Runnable 인터페이스, synchronized, volatile'),

-- Java 고급 질문
('Java의 가비지 컬렉션 동작 원리와 종류를 설명해주세요.', '기술-Java-고급', 5, 'Young/Old Generation, Serial/Parallel/G1/ZGC 등의 GC 알고리즘'),
('Spring Boot의 자동 설정(Auto Configuration) 원리를 설명해주세요.', '기술-Java-고급', 5, '@EnableAutoConfiguration, 조건부 빈 생성, starter 의존성'),
('JVM 메모리 모델과 성능 튜닝 방법을 설명해주세요.', '기술-Java-고급', 5, 'Heap, Stack, Method Area 구조와 JVM 옵션을 통한 튜닝'),

-- Python 초급 질문
('Python의 기본 데이터 타입에는 어떤 것들이 있나요?', '기술-Python-초급', 1, 'int, float, str, bool, list, tuple, dict, set'),
('Python에서 리스트와 튜플의 차이점을 설명해주세요.', '기술-Python-초급', 2, '리스트는 가변(mutable), 튜플은 불변(immutable)'),
('Python의 들여쓰기(indentation) 규칙에 대해 설명해주세요.', '기술-Python-초급', 2, '4칸 공백 사용, 블록 구조 정의, PEP 8 가이드라인'),

-- Python 중급 질문
('Python의 리스트 컴프리헨션(List Comprehension)을 설명하고 예시를 들어주세요.', '기술-Python-중급', 3, '[expression for item in iterable if condition] 형태의 간결한 리스트 생성'),
('Python의 데코레이터(Decorator)에 대해 설명해주세요.', '기술-Python-중급', 4, '함수나 클래스의 기능을 확장하는 메타프로그래밍 기법'),
('Python의 제너레이터(Generator)와 yield 키워드를 설명해주세요.', '기술-Python-중급', 4, '메모리 효율적인 이터레이터 생성, lazy evaluation'),

-- Python 고급 질문
('Python의 GIL(Global Interpreter Lock)에 대해 설명해주세요.', '기술-Python-고급', 5, '한 번에 하나의 스레드만 Python 바이트코드 실행, 멀티스레딩 제약'),
('Python의 메타클래스(Metaclass)에 대해 설명해주세요.', '기술-Python-고급', 5, '클래스의 클래스, 클래스 생성 과정 제어, type 메타클래스'),
('asyncio를 사용한 비동기 프로그래밍을 설명해주세요.', '기술-Python-고급', 5, 'async/await 키워드, 이벤트 루프, 코루틴'),

-- 인성 관련 질문
('팀에서 의견 충돌이 있을 때 어떻게 해결하시나요?', '인성', 2, '소통 능력, 문제 해결 능력, 협업 태도'),
('업무 우선순위를 어떻게 정하시나요?', '인성', 2, '시간 관리, 업무 효율성, 우선순위 판단 능력'),
('스트레스를 받는 상황에서 어떻게 대처하시나요?', '인성', 3, '스트레스 관리 능력, 자기 관리, 회복력'),
('새로운 기술을 학습할 때 어떤 방법을 사용하시나요?', '인성', 3, '학습 능력, 자기계발 의지, 학습 방법론'),

-- 경험 관련 질문
('가장 어려웠던 프로젝트 경험과 해결 과정을 말씀해주세요.', '경험', 3, '문제 해결 능력, 프로젝트 경험, 성장 과정'),
('팀 프로젝트에서 본인의 역할과 기여도를 설명해주세요.', '경험', 3, '팀워크, 리더십, 책임감, 협업 경험'),
('실패한 경험이 있다면 그로부터 무엇을 배웠는지 말씀해주세요.', '경험', 4, '실패 극복 경험, 학습 능력, 성찰 능력'),
('코드 리뷰나 기술적 피드백을 받은 경험이 있다면 공유해주세요.', '경험', 4, '피드백 수용 능력, 개선 의지, 소통 능력'),

-- 상황 관련 질문
('급한 데드라인이 있는 프로젝트에서 어떻게 대응하시겠나요?', '상황', 3, '시간 관리, 우선순위 설정, 스트레스 관리'),
('동료가 도움을 요청했지만 본인도 바쁜 상황이라면 어떻게 하시겠나요?', '상황', 3, '협업 의식, 업무 조율 능력, 소통 능력'),
('기존 코드에 버그가 발견되었는데 원인을 찾기 어려운 상황이라면?', '상황', 4, '문제 해결 접근법, 디버깅 능력, 체계적 사고'),
('새로운 요구사항이 추가되어 기존 설계를 변경해야 한다면?', '상황', 4, '유연성, 변화 대응 능력, 설계 변경 능력');

-- 기본 평가 기준 데이터 삽입
INSERT INTO evaluation_criteria (criteria_name, description, max_score, weight) VALUES
('기술적 역량', '프로그래밍 언어, 프레임워크, 도구 활용 능력', 10, 1.5),
('문제 해결 능력', '복잡한 문제를 논리적으로 분석하고 해결하는 능력', 10, 1.3),
('소통 및 협업', '팀원과의 소통, 협업, 리더십 능력', 10, 1.2),
('학습 능력', '새로운 기술과 지식을 빠르게 습득하는 능력', 10, 1.1),
('업무 태도', '책임감, 성실성, 업무에 대한 열정', 10, 1.0),
('창의성', '창의적 사고와 혁신적인 아이디어 제시 능력', 10, 0.8),
('적응력', '변화하는 환경과 요구사항에 대한 적응 능력', 10, 0.9);

-- 업데이트 트리거 생성 (updated_at 자동 갱신)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_interview_questions_updated_at BEFORE UPDATE
    ON interview_questions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_evaluation_criteria_updated_at BEFORE UPDATE
    ON evaluation_criteria FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 성공 메시지
SELECT 'Interview Questions and Evaluation Criteria tables created successfully!' as message; 