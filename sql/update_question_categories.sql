-- 인터뷰 질문 카테고리 확장 스크립트
-- 기존 4개 카테고리에서 10개 카테고리로 확장

-- 1. 기존 테이블 구조 확인
SELECT 'Starting category expansion...' as message;

-- 2. category 컬럼 크기 확장 (기존 VARCHAR(50) → VARCHAR(100))
ALTER TABLE interview_questions ALTER COLUMN category TYPE VARCHAR(100);

-- 3. 기존 데이터 백업 확인
SELECT 'Current questions count: ' || COUNT(*) as backup_info FROM interview_questions;

-- 4. 새로운 카테고리 샘플 데이터 삽입 (기존 데이터는 유지)
INSERT INTO interview_questions (question_text, category, difficulty_level, expected_answer) VALUES
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

-- 추가 일반 기술 질문
('소프트웨어 개발 생명주기(SDLC)에 대해 설명해주세요.', '기술', 2, '요구사항 분석, 설계, 구현, 테스트, 배포, 유지보수의 단계별 과정'),
('버전 관리 시스템(Git)의 기본 개념과 주요 명령어를 설명해주세요.', '기술', 2, 'commit, push, pull, merge, branch 등의 개념과 사용법'),
('데이터베이스 정규화에 대해 설명해주세요.', '기술', 3, '데이터 중복 제거, 무결성 확보, 1~3정규화 과정'),
('RESTful API 설계 원칙을 설명하고 실제 예시를 들어주세요.', '기술', 4, 'HTTP 메서드, 상태코드, URI 설계 원칙');

-- 5. 결과 확인
SELECT 'After insertion - Total questions: ' || COUNT(*) as result_info FROM interview_questions;

-- 6. 카테고리별 현황 확인
SELECT 
    category,
    COUNT(*) as question_count
FROM interview_questions 
WHERE is_active = true
GROUP BY category
ORDER BY 
    CASE 
        WHEN category = '기술' THEN 1
        WHEN category LIKE '기술-Java-%' THEN 2
        WHEN category LIKE '기술-Python-%' THEN 3
        WHEN category = '인성' THEN 4
        WHEN category = '경험' THEN 5
        WHEN category = '상황' THEN 6
        ELSE 7
    END,
    category;

-- 7. 성공 메시지
SELECT 'Interview question categories expanded successfully from 4 to 10 categories!' as success_message;
SELECT 'New categories: 기술, 기술-Java-초급, 기술-Java-중급, 기술-Java-고급, 기술-Python-초급, 기술-Python-중급, 기술-Python-고급, 인성, 경험, 상황' as categories_info; 