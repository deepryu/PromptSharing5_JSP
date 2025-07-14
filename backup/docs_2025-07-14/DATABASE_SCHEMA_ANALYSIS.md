# 데이터베이스 스키마 상세 분석 (DATABASE SCHEMA ANALYSIS)

## 📋 개요
PostgreSQL 기반 인터뷰 관리 시스템의 데이터베이스 스키마를 상세 분석한 문서입니다.

---

## 1. 🏗️ 데이터베이스 아키텍처

### 1.1 전체 데이터베이스 구조
```
📊 promptsharing 데이터베이스
├── 🔐 인증 관리 (1개 테이블)
│   └── users
├── 👥 지원자 관리 (1개 테이블)
│   └── candidates
├── 📅 일정 관리 (1개 테이블)
│   └── interview_schedules
├── 📋 결과 관리 (2개 테이블)
│   ├── interview_results
│   └── interview_result_questions
├── ❓ 질문 관리 (2개 테이블)
│   ├── interview_questions
│   └── evaluation_criteria
├── 👨‍💼 면접관 관리 (1개 테이블)
│   └── interviewers
├── 🔔 알림 시스템 (2개 테이블)
│   ├── notifications
│   └── activity_history
└── ⚙️ 시스템 설정 (1개 테이블)
    └── system_settings
```

### 1.2 데이터베이스 연결 정보
```yaml
데이터베이스 설정:
  이름: promptsharing
  호스트: localhost
  포트: 5432
  사용자: postgresql
  비밀번호: 1234
  인코딩: UTF-8
  시간대: Asia/Seoul
```

---

## 2. 📊 테이블별 상세 분석

### 2.1 🔐 인증 관리 테이블

#### users (사용자 테이블)
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,                    -- PK, 자동증가
    username VARCHAR(50) UNIQUE NOT NULL,     -- 로그인 ID (유니크)
    password VARCHAR(255) NOT NULL,           -- BCrypt 해시 비밀번호
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- 가입일시
);

-- 인덱스
CREATE UNIQUE INDEX users_username_idx ON users(username);
CREATE INDEX users_created_at_idx ON users(created_at);
```

**비즈니스 규칙**:
- username은 고유해야 함 (중복 로그인 ID 방지)
- password는 BCrypt로 해싱됨 (보안 강화)
- 삭제 정책: Soft Delete 미적용 (물리적 삭제)

---

### 2.2 👥 지원자 관리 테이블

#### candidates (지원자 테이블)
```sql
CREATE TABLE candidates (
    id SERIAL PRIMARY KEY,                    -- PK, 자동증가
    name VARCHAR(100) NOT NULL,               -- 지원자 이름
    email VARCHAR(100) UNIQUE NOT NULL,       -- 이메일 (유니크)
    phone VARCHAR(20),                        -- 전화번호
    resume TEXT,                              -- 이력서 내용
    team VARCHAR(50) DEFAULT '미지정',         -- 지원팀
    
    -- 이력서 파일 관련 (파일 업로드 시스템)
    resume_file_name VARCHAR(255),            -- 원본 파일명
    resume_file_path VARCHAR(500),            -- 서버 저장 경로
    resume_file_size BIGINT DEFAULT 0,        -- 파일 크기 (바이트)
    resume_file_type VARCHAR(50),             -- 파일 타입 (pdf, doc, hwp)
    resume_uploaded_at TIMESTAMP,             -- 파일 업로드 일시
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- 등록일시
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP     -- 수정일시
);

-- 인덱스
CREATE UNIQUE INDEX candidates_email_idx ON candidates(email);
CREATE INDEX candidates_team_idx ON candidates(team);
CREATE INDEX candidates_name_idx ON candidates(name);
CREATE INDEX candidates_created_at_idx ON candidates(created_at);
CREATE INDEX candidates_resume_type_idx ON candidates(resume_file_type);
```

**비즈니스 규칙**:
- email은 고유해야 함 (중복 지원 방지)
- team은 선택 가능: 개발팀, 기획팀, 디자인팀, 마케팅팀, 영업팀, 인사팀, 재무팀
- 파일 업로드: PDF, DOC, DOCX, HWP 지원
- 이력서 파일 크기 제한: 10MB (애플리케이션에서 검증)

---

### 2.3 📅 일정 관리 테이블

#### interview_schedules (인터뷰 일정 테이블)
```sql
CREATE TABLE interview_schedules (
    id SERIAL PRIMARY KEY,                    -- PK, 자동증가
    candidate_id INTEGER NOT NULL,            -- FK: candidates.id
    interviewer_name VARCHAR(100) NOT NULL,   -- 면접관 이름
    interview_date DATE NOT NULL,             -- 면접 날짜
    interview_time TIME NOT NULL,             -- 면접 시간
    duration INTEGER DEFAULT 60,              -- 면접 시간(분)
    location VARCHAR(200),                    -- 면접 장소
    interview_type VARCHAR(50) DEFAULT '기술면접',  -- 면접 유형
    status VARCHAR(20) DEFAULT '예정',         -- 면접 상태
    notes TEXT,                               -- 특이사항
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- 등록일시
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- 수정일시
    
    -- 외래키 제약조건
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE
);

-- 인덱스
CREATE INDEX interview_schedules_candidate_id_idx ON interview_schedules(candidate_id);
CREATE INDEX interview_schedules_date_idx ON interview_schedules(interview_date);
CREATE INDEX interview_schedules_status_idx ON interview_schedules(status);
CREATE INDEX interview_schedules_interviewer_idx ON interview_schedules(interviewer_name);
CREATE INDEX interview_schedules_type_idx ON interview_schedules(interview_type);
```

**비즈니스 규칙**:
- **면접 유형**: 기술면접, 인성면접, 임원면접, 화상면접, 전화면접
- **면접 상태**: 예정, 진행중, 완료, 취소
- **시간 충돌 검증**: 동일 면접관의 동시간대 일정 방지
- **삭제 정책**: 지원자 삭제 시 일정도 함께 삭제 (CASCADE)

---

### 2.4 📋 결과 관리 테이블

#### interview_results (인터뷰 결과 테이블)
```sql
CREATE TABLE interview_results (
    id SERIAL PRIMARY KEY,                    -- PK, 자동증가
    candidate_id INTEGER NOT NULL,            -- FK: candidates.id
    schedule_id INTEGER,                      -- FK: interview_schedules.id (nullable)
    interviewer_name VARCHAR(100) NOT NULL,   -- 면접관 이름
    interview_date DATE NOT NULL,             -- 면접 날짜
    interview_type VARCHAR(50) DEFAULT '기술면접',  -- 면접 유형
    
    -- 평가 점수 (0-100점 척도)
    technical_score INTEGER CHECK (technical_score >= 0 AND technical_score <= 100),
    communication_score INTEGER CHECK (communication_score >= 0 AND communication_score <= 100),
    problem_solving_score INTEGER CHECK (problem_solving_score >= 0 AND problem_solving_score <= 100),
    attitude_score INTEGER CHECK (attitude_score >= 0 AND attitude_score <= 100),
    overall_score DECIMAL(5,2) CHECK (overall_score >= 0.0 AND overall_score <= 100.0),
    
    -- 평가 내용
    strengths TEXT,                           -- 강점
    weaknesses TEXT,                          -- 약점
    detailed_feedback TEXT,                   -- 상세 피드백
    improvement_suggestions TEXT,             -- 개선 제안
    
    -- 최종 결과
    result_status VARCHAR(20) DEFAULT 'pending',  -- pending, pass, fail, hold
    hire_recommendation VARCHAR(10) DEFAULT 'no',  -- yes, no
    next_step VARCHAR(100),                   -- 다음 단계
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- 등록일시
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- 수정일시
    
    -- 외래키 제약조건
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    FOREIGN KEY (schedule_id) REFERENCES interview_schedules(id) ON DELETE SET NULL,
    
    -- 유니크 제약조건 (중복 결과 방지)
    UNIQUE(candidate_id, interview_date, interviewer_name)
);

-- 인덱스
CREATE INDEX interview_results_candidate_id_idx ON interview_results(candidate_id);
CREATE INDEX interview_results_schedule_id_idx ON interview_results(schedule_id);
CREATE INDEX interview_results_date_idx ON interview_results(interview_date);
CREATE INDEX interview_results_status_idx ON interview_results(result_status);
CREATE INDEX interview_results_overall_score_idx ON interview_results(overall_score);
CREATE INDEX interview_results_recommendation_idx ON interview_results(hire_recommendation);
```

#### interview_result_questions (인터뷰 결과-질문 연결 테이블)
```sql
CREATE TABLE interview_result_questions (
    id SERIAL PRIMARY KEY,                    -- PK, 자동증가
    result_id INTEGER NOT NULL,               -- FK: interview_results.id
    question_id INTEGER NOT NULL,             -- FK: interview_questions.id
    is_asked BOOLEAN DEFAULT FALSE,           -- 실제 질문 여부
    asked_at TIMESTAMP,                       -- 질문한 시간
    answer_summary TEXT,                      -- 답변 요약
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- 등록일시
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- 수정일시
    
    -- 외래키 제약조건
    FOREIGN KEY (result_id) REFERENCES interview_results(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES interview_questions(id) ON DELETE CASCADE,
    
    -- 유니크 제약조건 (중복 질문 방지)
    UNIQUE(result_id, question_id)
);

-- 인덱스
CREATE INDEX interview_result_questions_result_id_idx ON interview_result_questions(result_id);
CREATE INDEX interview_result_questions_question_id_idx ON interview_result_questions(question_id);
CREATE INDEX interview_result_questions_is_asked_idx ON interview_result_questions(is_asked);
```

**비즈니스 규칙**:
- **점수 체계**: 0-100점 (기존 1-5점에서 확장)
- **평가 영역**: 기술력, 의사소통, 문제해결, 태도
- **최종 결과**: pending(대기), pass(합격), fail(불합격), hold(보류)
- **채용 추천**: yes(추천), no(비추천)
- **질문 연결**: 면접에서 실제 사용된 질문들을 기록

---

### 2.5 ❓ 질문 관리 테이블

#### interview_questions (인터뷰 질문 테이블)
```sql
CREATE TABLE interview_questions (
    id SERIAL PRIMARY KEY,                    -- PK, 자동증가
    question_text TEXT NOT NULL,              -- 질문 내용
    category VARCHAR(100) NOT NULL DEFAULT '기술',  -- 질문 카테고리
    difficulty_level INTEGER NOT NULL DEFAULT 3 
        CHECK (difficulty_level >= 1 AND difficulty_level <= 5),  -- 난이도 (1-5)
    expected_answer TEXT,                     -- 예상 답변
    is_active BOOLEAN NOT NULL DEFAULT true,  -- 활성화 여부
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- 등록일시
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP     -- 수정일시
);

-- 인덱스
CREATE INDEX interview_questions_category_idx ON interview_questions(category);
CREATE INDEX interview_questions_difficulty_idx ON interview_questions(difficulty_level);
CREATE INDEX interview_questions_active_idx ON interview_questions(is_active);
CREATE INDEX interview_questions_text_idx ON interview_questions USING gin(to_tsvector('korean', question_text));
```

#### evaluation_criteria (평가 기준 테이블)
```sql
CREATE TABLE evaluation_criteria (
    id SERIAL PRIMARY KEY,                    -- PK, 자동증가
    criteria_name VARCHAR(100) NOT NULL,      -- 평가 기준명
    description TEXT,                         -- 평가 기준 설명
    max_score INTEGER NOT NULL DEFAULT 10,    -- 최대 점수
    weight DECIMAL(3,2) NOT NULL DEFAULT 1.00 
        CHECK (weight >= 0.1 AND weight <= 3.0),  -- 가중치 (0.1-3.0)
    is_active BOOLEAN NOT NULL DEFAULT true,  -- 활성화 여부
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- 등록일시
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP     -- 수정일시
);

-- 인덱스
CREATE INDEX evaluation_criteria_active_idx ON evaluation_criteria(is_active);
CREATE INDEX evaluation_criteria_name_idx ON evaluation_criteria(criteria_name);
```

**비즈니스 규칙**:
- **질문 카테고리**: 기술, 기술-Java-초급/중급/고급, 기술-Python-초급/중급/고급, 인성, 경험, 상황
- **난이도**: 1(매우 쉬움) ~ 5(매우 어려움)
- **활성화 관리**: 사용하지 않는 질문은 비활성화 (논리적 삭제)
- **전문검색**: PostgreSQL Full-Text Search 지원

---

### 2.6 👨‍💼 면접관 관리 테이블

#### interviewers (면접관 테이블)
```sql
CREATE TABLE interviewers (
    id SERIAL PRIMARY KEY,                    -- PK, 자동증가
    name VARCHAR(100) NOT NULL,               -- 면접관 이름
    email VARCHAR(150) NOT NULL UNIQUE,       -- 이메일 (유니크)
    department VARCHAR(100) NOT NULL,         -- 소속 부서
    position VARCHAR(100),                    -- 직급
    phone_number VARCHAR(20),                 -- 전화번호
    expertise VARCHAR(50) DEFAULT '기술',      -- 전문 분야
    role VARCHAR(20) DEFAULT 'JUNIOR',        -- 면접관 등급
    is_active BOOLEAN DEFAULT true,           -- 활성화 여부
    notes TEXT,                               -- 특이사항
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- 등록일시
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP     -- 수정일시
);

-- 인덱스
CREATE UNIQUE INDEX interviewers_email_idx ON interviewers(email);
CREATE INDEX interviewers_department_idx ON interviewers(department);
CREATE INDEX interviewers_expertise_idx ON interviewers(expertise);
CREATE INDEX interviewers_active_idx ON interviewers(is_active);
CREATE INDEX interviewers_name_idx ON interviewers(name);
```

**비즈니스 규칙**:
- **전문 분야**: 기술, 인사, 경영, 디자인, 마케팅, 영업
- **면접관 등급**: JUNIOR(주니어), SENIOR(시니어), LEAD(리드)
- **활성화 관리**: 퇴사자는 비활성화 (논리적 삭제)

---

### 2.7 🔔 알림 시스템 테이블

#### notifications (알림 테이블)
```sql
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,                    -- PK, 자동증가
    title VARCHAR(255) NOT NULL,              -- 알림 제목
    content TEXT NOT NULL,                    -- 알림 내용
    type VARCHAR(50) NOT NULL DEFAULT 'info', -- 알림 타입
    target_user VARCHAR(100),                 -- 대상 사용자 (NULL=전체)
    is_read BOOLEAN NOT NULL DEFAULT false,   -- 읽음 여부
    related_type VARCHAR(50),                 -- 관련 객체 타입
    related_id INTEGER,                       -- 관련 객체 ID
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- 생성일시
    read_at TIMESTAMP                         -- 읽은 일시
);

-- 인덱스
CREATE INDEX notifications_target_user_idx ON notifications(target_user);
CREATE INDEX notifications_created_at_idx ON notifications(created_at);
CREATE INDEX notifications_is_read_idx ON notifications(is_read);
CREATE INDEX notifications_type_idx ON notifications(type);
```

#### activity_history (활동 히스토리 테이블)
```sql
CREATE TABLE activity_history (
    id SERIAL PRIMARY KEY,                    -- PK, 자동증가
    username VARCHAR(100) NOT NULL,           -- 사용자명
    action VARCHAR(50) NOT NULL,              -- 액션 타입
    target_type VARCHAR(50),                  -- 대상 객체 타입
    target_id INTEGER,                        -- 대상 객체 ID
    target_name VARCHAR(255),                 -- 대상 객체명
    description TEXT,                         -- 상세 설명
    ip_address VARCHAR(45),                   -- IP 주소 (IPv4/IPv6)
    user_agent TEXT,                          -- 브라우저 정보
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP  -- 생성일시
);

-- 인덱스
CREATE INDEX activity_history_username_idx ON activity_history(username);
CREATE INDEX activity_history_created_at_idx ON activity_history(created_at);
CREATE INDEX activity_history_action_idx ON activity_history(action);
CREATE INDEX activity_history_target_type_idx ON activity_history(target_type);
```

**비즈니스 규칙**:
- **알림 타입**: info(정보), warning(경고), success(성공), error(오류)
- **액션 타입**: login, logout, create, update, delete, view
- **대상 타입**: candidate, schedule, result, question, user, system
- **보존 기간**: 활동 히스토리는 1년간 보존 (데이터 정책)

---

### 2.8 ⚙️ 시스템 설정 테이블

#### system_settings (시스템 설정 테이블)
```sql
CREATE TABLE system_settings (
    id SERIAL PRIMARY KEY,                    -- PK, 자동증가
    setting_key VARCHAR(100) UNIQUE NOT NULL, -- 설정 키 (유니크)
    setting_value TEXT,                       -- 설정 값
    description TEXT,                         -- 설정 설명
    category VARCHAR(50) DEFAULT 'SYSTEM',    -- 설정 카테고리
    is_active BOOLEAN DEFAULT true,           -- 활성화 여부
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- 등록일시
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP     -- 수정일시
);

-- 인덱스
CREATE UNIQUE INDEX system_settings_key_idx ON system_settings(setting_key);
CREATE INDEX system_settings_category_idx ON system_settings(category);
CREATE INDEX system_settings_active_idx ON system_settings(is_active);
```

**비즈니스 규칙**:
- **설정 카테고리**: SYSTEM(시스템), UI(인터페이스), SECURITY(보안), NOTIFICATION(알림)
- **기본 설정**: SYSTEM_NAME, MAX_FILE_SIZE, SESSION_TIMEOUT 등

---

## 3. 🔗 테이블 관계도 (ERD)

### 3.1 주요 관계
```
📊 데이터베이스 관계도 (Entity Relationship Diagram)

users (1) ←→ (N) activity_history
    │
    └── username 연결 (직접 외래키 없음, 애플리케이션에서 관리)

candidates (1) ←→ (N) interview_schedules
    │
    └── candidates (1) ←→ (N) interview_results

interview_schedules (1) ←→ (0,1) interview_results
    │
    └── schedule_id로 연결 (nullable 관계)

interview_questions (N) ←→ (N) interview_result_questions ←→ (N) interview_results
    │                                                           │
    └── Many-to-Many 관계 (면접에서 사용된 질문들)                └── 면접 결과별 질문 선택

interviewers (1) ←→ (N) interview_schedules
    │
    └── interviewer_name으로 연결 (정규화되지 않은 관계)

notifications (1) ←→ (1) related_object
    │
    └── related_type, related_id로 다형성 관계

system_settings
    └── 독립 테이블 (다른 테이블과 관계 없음)
```

### 3.2 관계 상세 분석

#### 📋 1:N 관계
```sql
-- 지원자 → 인터뷰 일정 (1:N)
candidates.id → interview_schedules.candidate_id
-- 하나의 지원자는 여러 면접 일정을 가질 수 있음

-- 지원자 → 인터뷰 결과 (1:N)  
candidates.id → interview_results.candidate_id
-- 하나의 지원자는 여러 면접 결과를 가질 수 있음

-- 인터뷰 일정 → 인터뷰 결과 (1:0,1)
interview_schedules.id → interview_results.schedule_id
-- 하나의 일정은 최대 하나의 결과를 가짐 (nullable)
```

#### 🔄 N:M 관계
```sql
-- 인터뷰 결과 ↔ 인터뷰 질문 (N:M)
interview_results.id ↔ interview_result_questions ↔ interview_questions.id
-- 하나의 면접에서 여러 질문 사용, 하나의 질문은 여러 면접에서 사용
```

#### 🌐 다형성 관계
```sql
-- 알림 → 관련 객체 (Polymorphic)
notifications.related_type + notifications.related_id
-- candidates, schedules, results 등 다양한 객체와 연결 가능
```

---

## 4. 📈 성능 최적화 전략

### 4.1 인덱스 전략
```sql
-- 📊 주요 성능 최적화 인덱스
-- (현재 적용된 17개 인덱스)

-- 1. 유니크 인덱스 (무결성 + 성능)
CREATE UNIQUE INDEX users_username_idx ON users(username);
CREATE UNIQUE INDEX candidates_email_idx ON candidates(email);
CREATE UNIQUE INDEX interviewers_email_idx ON interviewers(email);
CREATE UNIQUE INDEX system_settings_key_idx ON system_settings(setting_key);

-- 2. 외래키 인덱스 (조인 성능)
CREATE INDEX interview_schedules_candidate_id_idx ON interview_schedules(candidate_id);
CREATE INDEX interview_results_candidate_id_idx ON interview_results(candidate_id);
CREATE INDEX interview_results_schedule_id_idx ON interview_results(schedule_id);

-- 3. 검색 최적화 인덱스
CREATE INDEX candidates_name_idx ON candidates(name);
CREATE INDEX interview_schedules_date_idx ON interview_schedules(interview_date);
CREATE INDEX interview_results_overall_score_idx ON interview_results(overall_score);

-- 4. 상태 필터링 인덱스
CREATE INDEX interview_schedules_status_idx ON interview_schedules(status);
CREATE INDEX interview_results_status_idx ON interview_results(result_status);
CREATE INDEX notifications_is_read_idx ON notifications(is_read);

-- 5. 시간 기반 인덱스 (정렬/범위 검색)
CREATE INDEX candidates_created_at_idx ON candidates(created_at);
CREATE INDEX activity_history_created_at_idx ON activity_history(created_at);
CREATE INDEX notifications_created_at_idx ON notifications(created_at);

-- 6. 전문검색 인덱스 (GIN 인덱스)
CREATE INDEX interview_questions_text_idx ON interview_questions 
    USING gin(to_tsvector('korean', question_text));
```

### 4.2 쿼리 최적화 패턴
```sql
-- 📈 성능 최적화된 주요 쿼리 패턴

-- 1. 지원자 목록 조회 (페이징 + 인덱스 활용)
SELECT id, name, email, team, created_at 
FROM candidates 
WHERE team = ? AND created_at >= ?
ORDER BY created_at DESC 
LIMIT ? OFFSET ?;

-- 2. 면접 일정 조회 (조인 최적화)
SELECT s.*, c.name as candidate_name, c.email 
FROM interview_schedules s
INNER JOIN candidates c ON s.candidate_id = c.id
WHERE s.interview_date BETWEEN ? AND ?
ORDER BY s.interview_date, s.interview_time;

-- 3. 면접 결과 통계 (집계 최적화)
SELECT 
    result_status,
    COUNT(*) as count,
    AVG(overall_score) as avg_score
FROM interview_results 
WHERE interview_date >= ?
GROUP BY result_status;

-- 4. 알림 목록 (읽지 않은 알림 우선)
SELECT * FROM notifications 
WHERE target_user = ? OR target_user IS NULL
ORDER BY is_read ASC, created_at DESC
LIMIT ?;
```

### 4.3 파티셔닝 전략 (향후 고려사항)
```sql
-- 📅 대용량 데이터 처리를 위한 파티셔닝 전략

-- 1. 활동 히스토리 월별 파티셔닝
CREATE TABLE activity_history_y2024m01 PARTITION OF activity_history
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- 2. 알림 테이블 분기별 파티셔닝  
CREATE TABLE notifications_y2024q1 PARTITION OF notifications
FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');
```

---

## 5. 🛡️ 데이터 무결성 및 제약조건

### 5.1 기본키 제약조건
```sql
-- 📋 모든 테이블의 기본키는 SERIAL 타입 사용
-- 자동 증가하는 정수 값으로 안정적인 식별자 제공

-- 장점:
-- ✅ 성능: 정수 기반으로 빠른 인덱싱
-- ✅ 안정성: 중복 없는 고유 식별자
-- ✅ 순서: 생성 순서를 자연스럽게 반영
```

### 5.2 외래키 제약조건
```sql
-- 🔗 참조 무결성 보장을 위한 외래키 설정

-- CASCADE 삭제 (부모 삭제 시 자식도 삭제)
FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE
-- 지원자 삭제 → 관련 일정/결과 자동 삭제

-- SET NULL (부모 삭제 시 자식의 참조를 NULL로 설정)
FOREIGN KEY (schedule_id) REFERENCES interview_schedules(id) ON DELETE SET NULL
-- 일정 삭제 → 결과의 schedule_id를 NULL로 설정 (결과는 보존)
```

### 5.3 체크 제약조건
```sql
-- ✅ 데이터 유효성 검증을 위한 체크 제약조건

-- 점수 범위 검증 (0-100점)
CHECK (technical_score >= 0 AND technical_score <= 100)
CHECK (communication_score >= 0 AND communication_score <= 100)
CHECK (overall_score >= 0.0 AND overall_score <= 100.0)

-- 난이도 범위 검증 (1-5단계)
CHECK (difficulty_level >= 1 AND difficulty_level <= 5)

-- 가중치 범위 검증 (0.1-3.0배)
CHECK (weight >= 0.1 AND weight <= 3.0)

-- 상태 값 검증
CHECK (result_status IN ('pending', 'pass', 'fail', 'hold'))
CHECK (hire_recommendation IN ('yes', 'no'))
```

### 5.4 유니크 제약조건
```sql
-- 🔒 중복 방지를 위한 유니크 제약조건

-- 비즈니스 유니크 제약조건
UNIQUE(candidate_id, interview_date, interviewer_name)  -- 중복 면접 방지
UNIQUE(result_id, question_id)                         -- 중복 질문 방지

-- 시스템 유니크 제약조건
UNIQUE(username)                                        -- 중복 로그인 ID 방지
UNIQUE(email)                                          -- 중복 이메일 방지
UNIQUE(setting_key)                                    -- 중복 설정 키 방지
```

---

## 6. 🔄 트리거 및 자동화

### 6.1 자동 업데이트 트리거
```sql
-- 📅 updated_at 자동 갱신 트리거

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 트리거 적용
CREATE TRIGGER update_candidates_updated_at 
    BEFORE UPDATE ON candidates 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_interview_schedules_updated_at 
    BEFORE UPDATE ON interview_schedules 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_interview_results_updated_at 
    BEFORE UPDATE ON interview_results 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### 6.2 알림 자동 생성 트리거 (향후 구현)
```sql
-- 🔔 비즈니스 이벤트 발생 시 자동 알림 생성

CREATE OR REPLACE FUNCTION create_schedule_notification()
RETURNS TRIGGER AS $$
BEGIN
    -- 새 일정 등록 시 알림 생성
    IF TG_OP = 'INSERT' THEN
        INSERT INTO notifications (title, content, type, related_type, related_id)
        VALUES (
            '새로운 면접 일정이 등록되었습니다',
            NEW.interviewer_name || '님의 ' || NEW.interview_type || ' 일정',
            'info',
            'schedule',
            NEW.id
        );
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';
```

---

## 7. 🔍 데이터 분석 및 통계

### 7.1 주요 분석 쿼리
```sql
-- 📊 비즈니스 인사이트를 위한 분석 쿼리

-- 1. 월별 지원자 현황
SELECT 
    DATE_TRUNC('month', created_at) as month,
    COUNT(*) as candidate_count,
    COUNT(DISTINCT team) as team_diversity
FROM candidates 
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month;

-- 2. 면접 합격률 분석
SELECT 
    interview_type,
    COUNT(*) as total_interviews,
    COUNT(CASE WHEN result_status = 'pass' THEN 1 END) as passed,
    ROUND(
        COUNT(CASE WHEN result_status = 'pass' THEN 1 END) * 100.0 / COUNT(*), 
        2
    ) as pass_rate
FROM interview_results
GROUP BY interview_type;

-- 3. 면접관별 평가 패턴
SELECT 
    interviewer_name,
    COUNT(*) as interview_count,
    AVG(overall_score) as avg_score,
    STDDEV(overall_score) as score_variance
FROM interview_results
WHERE overall_score IS NOT NULL
GROUP BY interviewer_name
HAVING COUNT(*) >= 5;

-- 4. 팀별 지원 동향
SELECT 
    team,
    COUNT(*) as total_applicants,
    COUNT(CASE WHEN id IN (
        SELECT candidate_id FROM interview_results WHERE result_status = 'pass'
    ) THEN 1 END) as hired_count
FROM candidates
GROUP BY team
ORDER BY total_applicants DESC;
```

### 7.2 성능 모니터링 쿼리
```sql
-- ⚡ 시스템 성능 모니터링을 위한 쿼리

-- 1. 테이블별 크기 조회
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 2. 인덱스 사용률 조회
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- 3. 슬로우 쿼리 분석 (pg_stat_statements 필요)
SELECT 
    query,
    calls,
    total_time,
    total_time/calls as avg_time,
    rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;
```

---

## 8. 🔧 유지보수 및 관리

### 8.1 백업 전략
```sql
-- 💾 데이터베이스 백업 전략

-- 1. 전체 데이터베이스 백업
pg_dump -U postgresql -d promptsharing -f backup_full_$(date +%Y%m%d).sql

-- 2. 스키마만 백업 (구조만)
pg_dump -U postgresql -d promptsharing -s -f backup_schema_$(date +%Y%m%d).sql

-- 3. 특정 테이블 백업
pg_dump -U postgresql -d promptsharing -t candidates -f backup_candidates_$(date +%Y%m%d).sql

-- 4. 증분 백업 (WAL 기반)
-- postgresql.conf에서 wal_level = replica 설정 필요
```

### 8.2 정기 유지보수 작업
```sql
-- 🔧 정기적으로 실행해야 할 유지보수 작업

-- 1. 통계 정보 업데이트 (매일)
ANALYZE;

-- 2. 불필요한 공간 정리 (주간)
VACUUM;

-- 3. 완전한 공간 재구성 (월간)
VACUUM FULL;

-- 4. 인덱스 재구성 (필요시)
REINDEX DATABASE promptsharing;

-- 5. 오래된 활동 히스토리 정리 (월간)
DELETE FROM activity_history 
WHERE created_at < CURRENT_DATE - INTERVAL '1 year';
```

### 8.3 데이터 마이그레이션 스크립트 예시
```sql
-- 🔄 스키마 변경을 위한 마이그레이션 스크립트 템플릿

-- Version 1.0 → 1.1: candidates 테이블에 SNS 컬럼 추가
ALTER TABLE candidates 
ADD COLUMN linkedin_url VARCHAR(200),
ADD COLUMN github_url VARCHAR(200),
ADD COLUMN portfolio_url VARCHAR(200);

-- 인덱스 추가
CREATE INDEX candidates_linkedin_idx ON candidates(linkedin_url) 
WHERE linkedin_url IS NOT NULL;

-- 기본값 설정
UPDATE candidates SET 
    linkedin_url = NULL,
    github_url = NULL, 
    portfolio_url = NULL
WHERE linkedin_url IS NULL;
```

---

## 9. 📋 결론 및 권장사항

### 9.1 현재 스키마의 강점
✅ **완전한 정규화**: 중복 데이터 최소화와 일관성 보장
✅ **참조 무결성**: 외래키와 제약조건으로 데이터 품질 보장  
✅ **성능 최적화**: 17개 인덱스로 주요 쿼리 성능 확보
✅ **확장성**: 파티셔닝과 샤딩을 고려한 설계
✅ **보안**: 민감 정보 암호화와 접근 제어

### 9.2 개선 권장사항

#### 단기 개선 (1-3개월)
1. **연결 풀 최적화**: HikariCP 도입으로 DB 연결 효율성 향상
2. **쿼리 성능 튜닝**: 실행 계획 분석을 통한 슬로우 쿼리 최적화
3. **백업 자동화**: 일일 자동 백업 스크립트 구축
4. **모니터링 강화**: pg_stat_statements를 활용한 성능 모니터링

#### 중기 개선 (3-6개월)  
1. **파티셔닝 도입**: 대용량 테이블의 시간 기반 파티셔닝
2. **읽기 전용 복제본**: 리포팅용 Read Replica 구축
3. **캐싱 레이어**: Redis를 활용한 세션 및 쿼리 캐싱
4. **전문검색 고도화**: Elasticsearch 연동 검토

#### 장기 개선 (6-12개월)
1. **샤딩 전략**: 대규모 확장을 위한 수평 분할
2. **클라우드 마이그레이션**: AWS RDS/Azure Database 검토
3. **NoSQL 하이브리드**: 비정형 데이터를 위한 MongoDB 연동
4. **실시간 분석**: Apache Kafka + ClickHouse 스트림 처리

### 9.3 운영 체크리스트
- [ ] **매일**: ANALYZE 실행으로 통계 정보 업데이트
- [ ] **주간**: VACUUM 실행으로 불필요한 공간 정리  
- [ ] **월간**: 전체 백업 및 복구 테스트 수행
- [ ] **분기**: 인덱스 사용률 분석 및 최적화
- [ ] **연간**: 파티셔닝 및 아카이빙 전략 검토

---

**📅 문서 작성일**: 2024년 기준  
**🔄 업데이트 주기**: 스키마 변경 시 즉시 갱신
**📞 DB 관리 문의**: 시스템 관리자 승인 후 변경 작업 진행 