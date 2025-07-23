# 프로젝트 구조 종합 분석 (PROJECT ARCHITECTURE ANALYSIS)

## 📋 개요
**JSP 기반 개발자 인터뷰 관리 시스템** 프로젝트의 전체 구조를 분석한 종합 보고서입니다.

---

## 1. 🛠️ 기술 스택 분석

### 1.1 백엔드 기술
| 기술 | 버전 | 용도 | 상태 |
|------|------|------|------|
| **Java** | 8 | 서버사이드 로직 | ✅ 운영 중 |
| **JSP** | 2.3+ | 뷰 템플릿 엔진 | ✅ 운영 중 |
| **Servlet API** | 4.0.1 | 웹 컨트롤러 | ✅ 운영 중 |
| **PostgreSQL** | 42.7.7 (JDBC) | 데이터베이스 | ✅ 운영 중 |
| **Apache Tomcat** | 9.0+ | 웹 애플리케이션 서버 | ✅ 운영 중 |

### 1.2 보안 및 유틸리티
| 라이브러리 | 버전 | 용도 | 상태 |
|-----------|------|------|------|
| **BCrypt** | 0.4 | 비밀번호 해싱 | ✅ 적용 완료 |
| **JUnit** | 4.13.2 | 단위 테스트 | ✅ 50개 테스트 운영 |

### 1.3 빌드 및 관리 도구
| 도구 | 버전 | 용도 | 특징 |
|------|------|------|------|
| **Maven** | 3.9+ | 빌드/의존성 관리 | Maven Wrapper 포함 |
| **Git** | - | 버전 관리 | Pre-push 훅 적용 |

### 1.4 프론트엔드
| 기술 | 용도 | 특징 |
|------|------|------|
| **HTML5** | 마크업 | Semantic HTML |
| **CSS3** | 스타일링 | GitHub 테마 통일 |
| **JavaScript** | 클라이언트 로직 | 바닐라 JS (프레임워크 없음) |

---

## 2. 📁 파일 유형별 분석

### 2.1 전체 파일 통계
```
📊 프로젝트 파일 구성 (2024년 기준)
┌─────────────────┬────────┬──────────────────┐
│ 파일 유형       │ 개수   │ 설명             │
├─────────────────┼────────┼──────────────────┤
│ JSP 파일        │ 144개  │ 뷰 템플릿 (백업포함) │
│ Java 파일       │ 97개   │ 서버 로직 (백업포함)  │
│ SQL 스크립트    │ 17개   │ DB 스키마/데이터   │
│ 문서 파일 (MD)  │ 18개   │ 프로젝트 문서      │
│ CSS 파일        │ 2개    │ 스타일시트        │
│ 배치 스크립트    │ ~10개  │ 자동화 스크립트    │
└─────────────────┴────────┴──────────────────┘
```

### 2.2 상세 파일 분석

#### 2.2.1 JSP 파일 (144개)
- **실제 운영 파일**: ~28개 (백업 제외)
- **주요 페이지**:
  - `main.jsp` - 메인 대시보드
  - `login.jsp`, `register.jsp` - 인증
  - `candidates.jsp`, `candidate_*.jsp` - 지원자 관리
  - `interview_*.jsp` - 인터뷰 관리
  - `statistics.jsp`, `notifications.jsp` - 통계/알림

#### 2.2.2 Java 파일 (97개)
- **실제 운영 파일**: ~40개 (백업 제외)
- **패키지 구조**:
  ```
  src/com/example/
  ├── controller/     # 13개 서블릿
  ├── model/          # 20개 모델/DAO
  ├── filter/         # 1개 필터 (보안)
  └── util/           # 2개 유틸리티
  
  test/com/example/
  └── model/          # 6개 테스트 클래스
  ```

#### 2.2.3 SQL 스크립트 (17개)
```
sql/
├── create_*.sql           # 테이블 생성 (8개)
├── update_*.sql           # 스키마 업데이트 (2개)
├── add_*.sql             # 컬럼 추가 (1개)
├── fix_*.sql             # 데이터 수정 (3개)
└── debug_*.sql           # 디버깅용 (2개)
```

---

## 3. 🗄️ 데이터베이스 스키마 분석

### 3.1 주요 테이블 구조

#### 🔐 인증 관련
```sql
-- 사용자 테이블
users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,        -- BCrypt 해시
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

#### 👥 지원자 관리
```sql
-- 지원자 테이블  
candidates (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    resume TEXT,
    team VARCHAR(50),                      -- 지원팀
    resume_file_name VARCHAR(255),         -- 파일명
    resume_file_path VARCHAR(500),         -- 파일 경로
    resume_file_size BIGINT DEFAULT 0,     -- 파일 크기
    resume_file_type VARCHAR(50),          -- 파일 타입
    resume_uploaded_at TIMESTAMP,          -- 업로드일시
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

#### 📅 인터뷰 일정
```sql
-- 인터뷰 일정 테이블
interview_schedules (
    id SERIAL PRIMARY KEY,
    candidate_id INTEGER NOT NULL REFERENCES candidates(id),
    interviewer_name VARCHAR(100) NOT NULL,
    interview_date DATE NOT NULL,
    interview_time TIME NOT NULL,
    duration INTEGER DEFAULT 60,          -- 면접 시간(분)
    location VARCHAR(200),
    interview_type VARCHAR(50) DEFAULT '기술면접',
    status VARCHAR(20) DEFAULT '예정',     -- 예정, 진행중, 완료, 취소
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

#### 📋 인터뷰 결과
```sql
-- 인터뷰 결과 테이블
interview_results (
    id SERIAL PRIMARY KEY,
    candidate_id INTEGER NOT NULL REFERENCES candidates(id),
    schedule_id INTEGER REFERENCES interview_schedules(id),
    interviewer_name VARCHAR(100) NOT NULL,
    interview_date DATE NOT NULL,
    interview_type VARCHAR(50) DEFAULT '기술면접',
    
    -- 평가 점수 (0-100점)
    technical_score INTEGER CHECK (technical_score >= 0 AND technical_score <= 100),
    communication_score INTEGER CHECK (communication_score >= 0 AND communication_score <= 100),
    problem_solving_score INTEGER CHECK (problem_solving_score >= 0 AND problem_solving_score <= 100),
    attitude_score INTEGER CHECK (attitude_score >= 0 AND attitude_score <= 100),
    overall_score DECIMAL(5,2) CHECK (overall_score >= 0.0 AND overall_score <= 100.0),
    
    -- 평가 내용
    strengths TEXT,
    weaknesses TEXT,
    detailed_feedback TEXT,
    improvement_suggestions TEXT,
    
    -- 최종 결과
    result_status VARCHAR(20) DEFAULT 'pending',
    hire_recommendation VARCHAR(10) DEFAULT 'no',
    next_step VARCHAR(100),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

#### ❓ 질문 관리
```sql
-- 인터뷰 질문 테이블
interview_questions (
    id SERIAL PRIMARY KEY,
    question_text TEXT NOT NULL,
    category VARCHAR(100) NOT NULL DEFAULT '기술',
    difficulty_level INTEGER NOT NULL DEFAULT 3 CHECK (difficulty_level >= 1 AND difficulty_level <= 5),
    expected_answer TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

-- 평가 기준 테이블
evaluation_criteria (
    id SERIAL PRIMARY KEY,
    criteria_name VARCHAR(100) NOT NULL,
    description TEXT,
    max_score INTEGER NOT NULL DEFAULT 10,
    weight DECIMAL(3,2) NOT NULL DEFAULT 1.00,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

#### 👨‍💼 면접관 관리
```sql
-- 면접관 테이블
interviewers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    department VARCHAR(100) NOT NULL,
    position VARCHAR(100),
    phone_number VARCHAR(20),
    expertise VARCHAR(50) DEFAULT '기술',
    role VARCHAR(20) DEFAULT 'JUNIOR',
    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

#### 🔔 알림 및 히스토리
```sql
-- 알림 테이블
notifications (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'info',
    target_user VARCHAR(100),
    is_read BOOLEAN NOT NULL DEFAULT false,
    related_type VARCHAR(50),
    related_id INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP
)

-- 활동 히스토리 테이블
activity_history (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL,
    target_type VARCHAR(50),
    target_id INTEGER,
    target_name VARCHAR(255),
    description TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)
```

#### ⚙️ 시스템 설정
```sql
-- 시스템 설정 테이블
system_settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    description TEXT,
    category VARCHAR(50) DEFAULT 'SYSTEM',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

### 3.2 테이블 관계 (ERD)
```
users (1) ←→ (N) activity_history
candidates (1) ←→ (N) interview_schedules
candidates (1) ←→ (N) interview_results
interview_schedules (1) ←→ (0,1) interview_results
interview_questions (N) ←→ (N) interview_result_questions ←→ (N) interview_results
interviewers (1) ←→ (N) interview_schedules (간접 연결)
```

### 3.3 데이터베이스 인덱스 전략
```sql
-- 성능 최적화를 위한 주요 인덱스
CREATE INDEX idx_candidates_email ON candidates(email);
CREATE INDEX idx_candidates_team ON candidates(team);
CREATE INDEX idx_interview_schedules_date ON interview_schedules(interview_date);
CREATE INDEX idx_interview_schedules_status ON interview_schedules(status);
CREATE INDEX idx_interview_results_candidate ON interview_results(candidate_id);
CREATE INDEX idx_interview_results_score ON interview_results(overall_score);
CREATE INDEX idx_interview_questions_category ON interview_questions(category);
CREATE INDEX idx_interview_questions_difficulty ON interview_questions(difficulty_level);
```

---

## 4. 🔗 파일간 의존성 분석

### 4.1 아키텍처 패턴: **MVC (Model-View-Controller)**

```
📱 클라이언트 (브라우저)
       ↕️ HTTP 요청/응답
🌐 JSP 파일 (View Layer)
       ↕️ 포워딩/리다이렉트  
🎮 Servlet (Controller Layer)
       ↕️ 메서드 호출
📊 DAO/Model (Model Layer)
       ↕️ JDBC 연결
🗄️ PostgreSQL 데이터베이스
```

### 4.2 계층별 의존성

#### 4.2.1 View Layer (JSP)
```
JSP 파일들의 의존성:
├── css/common.css           # 모든 JSP가 공통 참조
├── ${pageContext.request.contextPath}  # 상대 경로 해결
├── session.getAttribute("username")    # 세션 기반 인증
└── <base href="${pageContext.request.contextPath}/"> # URL 기준점
```

#### 4.2.2 Controller Layer (Servlet)
```java
서블릿 의존성 패턴:
@WebServlet("/path")                    # URL 매핑
├── HttpServletRequest request          # 요청 처리
├── HttpServletResponse response        # 응답 처리
├── HttpSession session                 # 세션 관리
├── DAO 클래스들                         # 데이터 액세스
└── Model 클래스들                       # 데이터 모델
```

#### 4.2.3 Model Layer (DAO/Model)
```java
모델 계층 의존성:
├── DatabaseUtil.getConnection()        # DB 연결 관리
├── PreparedStatement                   # SQL Injection 방지
├── Model 클래스 (POJO)                 # 데이터 모델
└── 비즈니스 로직 메서드들                # CRUD 작업
```

### 4.3 Maven 의존성 트리
```
promptsharing-jsp:1.3.0
├── javax.servlet:javax.servlet-api:4.0.1 [provided]
├── org.postgresql:postgresql:42.7.7
├── org.mindrot:jbcrypt:0.4
└── junit:junit:4.13.2 [test]
```

### 4.4 핵심 유틸리티 클래스
```java
// 모든 DAO가 의존하는 핵심 유틸리티
DatabaseUtil.java
├── getConnection()                     # DB 연결 팩토리
├── closeConnection()                   # 자원 해제
└── 연결 풀 관리                         # 성능 최적화

AuthenticationFilter.java              # 모든 요청 가로채기
├── @WebFilter("/*")                   # 전역 필터
├── 세션 검증                           # 보안 1단계
└── 로그인 리다이렉트                    # 인증 실패 처리
```

---

## 5. 🏗️ 개발 환경 및 빌드 시스템

### 5.1 Maven 기반 프로젝트 구조
```
ATS/
├── pom.xml                             # Maven 설정
├── mvnw.cmd                           # Maven Wrapper (Windows)
├── src/                               # Java 소스코드
│   └── com/example/
│       ├── controller/                # 서블릿 컨트롤러
│       ├── model/                     # 모델/DAO 클래스  
│       ├── filter/                    # 보안 필터
│       └── util/                      # 유틸리티 클래스
├── test/                              # JUnit 테스트
├── WEB-INF/                           # 웹 설정
│   ├── web.xml                        # 서블릿 설정
│   ├── classes/                       # 컴파일된 클래스
│   └── lib/                           # 의존성 라이브러리
├── *.jsp                              # JSP 뷰 파일들
├── css/                               # 스타일시트
├── docs/                              # 프로젝트 문서
├── sql/                               # 데이터베이스 스크립트
└── backup/                            # 백업 파일들
```

### 5.2 자동화 스크립트
```bash
# 빌드 관련
├── mvnw.cmd                           # Maven 래퍼
├── build-maven.cmd                    # 빌드 스크립트
├── test-maven.cmd                     # 테스트 실행
├── test-maven-utf8.cmd               # UTF-8 테스트
└── package-maven.cmd                  # WAR 패키징

# 운영 관리
├── safety-backup.cmd                  # 안전 백업
├── quick-check.cmd                    # 상태 진단
├── emergency-recovery.cmd             # 긴급 복구
└── create-upload-dirs.cmd            # 디렉터리 생성
```

### 5.3 테스트 시스템
```
현재 테스트 현황: 50개 테스트 케이스
├── UserDAOTest.java                   # 4개 테스트
├── CandidateDAOTest.java              # 5개 테스트
├── InterviewScheduleDAOTest.java      # 11개 테스트
├── InterviewQuestionDAOTest.java      # 17개 테스트
└── InterviewResultDAOTest.java        # 13개 테스트

테스트 전략:
├── 단위 테스트 (Unit Test)            # DAO 메서드별 테스트
├── 통합 테스트 (Integration Test)     # DB 연동 테스트
└── 자동화 테스트 (Automated Test)     # Pre-push 훅 연동
```

---

## 6. 🛡️ 보안 아키텍처

### 6.1 3단계 보안 시스템
```
1단계: AuthenticationFilter
├── @WebFilter("/*")                   # 모든 요청 가로채기
├── 세션 검증                           # username 속성 확인
├── 예외 경로                           # /login, /register, CSS/JS
└── 자동 리다이렉트                     # 인증 실패 시

2단계: 서블릿 세션 검증
├── HttpSession session = request.getSession(false)
├── session.getAttribute("username")   # 사용자 식별
└── response.sendRedirect("login.jsp") # 실패 시 처리

3단계: JSP 세션 검증
├── <% String username = (String)session.getAttribute("username"); %>
├── if (username == null) 검증
└── response.sendRedirect("login.jsp") # 최종 방어선
```

### 6.2 보안 기능 목록
```
인증/인가:
├── BCrypt 비밀번호 해싱               # 단방향 암호화
├── 세션 기반 인증                     # 상태 유지
├── 자동 로그아웃                       # 세션 만료
└── URL 직접 접근 차단                 # 무단 접근 방지

입력 검증:
├── PreparedStatement                  # SQL Injection 방지
├── HTML 이스케이프                    # XSS 방지
├── 파라미터 검증                       # 데이터 무결성
└── 파일 업로드 검증                    # 악성 파일 차단
```

---

## 7. 📊 성능 및 확장성 분석

### 7.1 현재 성능 특성
```
장점:
├── 가벼운 아키텍처                     # JSP/Servlet 기반
├── 효율적인 DB 인덱싱                 # 쿼리 최적화
├── 세션 기반 캐싱                     # 사용자 상태 관리
└── Maven 기반 빌드                    # 의존성 자동 관리

개선 가능 영역:
├── 연결 풀 최적화                     # DB 연결 관리
├── 페이징 처리                         # 대용량 데이터
├── 캐싱 전략                           # Redis/Memcached
└── API 성능 모니터링                  # APM 도구 도입
```

### 7.2 확장성 고려사항
```
수평 확장 (Scale-Out):
├── 로드 밸런서 도입 가능               # Nginx/Apache
├── 세션 공유 필요                     # Redis Session Store
├── DB 분산 가능                       # Read Replica
└── CDN 적용 가능                      # 정적 자원 분산

수직 확장 (Scale-Up):
├── JVM 힙 메모리 조정                 # -Xmx, -Xms
├── Tomcat 스레드 풀 튜닝             # maxThreads
├── DB 커넥션 풀 확장                  # HikariCP
└── SSD 스토리지 적용                  # I/O 성능 향상
```

---

## 8. 🔮 향후 개선 방향

### 8.1 기술적 개선사항
```
단기 (1-3개월):
├── REST API 도입                      # JSON 기반 통신
├── AJAX 비동기 처리                   # 사용자 경험 개선
├── 파일 업로드 최적화                 # Multipart 처리
└── 로깅 시스템 강화                   # Log4j2/Logback

중기 (3-6개월):
├── Spring Framework 도입              # 의존성 주입
├── MyBatis/JPA 도입                   # ORM 적용
├── 캐싱 레이어 추가                   # Redis/Hazelcast
└── 모바일 반응형 UI                   # Bootstrap/Tailwind

장기 (6-12개월):
├── 마이크로서비스 아키텍처            # MSA 전환
├── 클라우드 배포                       # AWS/Azure
├── 컨테이너화                          # Docker/Kubernetes
└── CI/CD 파이프라인                   # Jenkins/GitHub Actions
```

### 8.2 비즈니스 기능 확장
```
인사 관리 확장:
├── 면접 동영상 녹화                   # WebRTC 기술
├── AI 기반 이력서 분석                # NLP/ML 모델
├── 자동 일정 조율                     # 캘린더 API 연동
└── 실시간 알림                         # WebSocket/SSE

분석 및 리포팅:
├── 대시보드 확장                       # 차트/그래프
├── 데이터 분석                         # BI 도구 연동
├── 성과 지표 관리                     # KPI 대시보드
└── 자동 보고서 생성                   # PDF/Excel 출력
```

---

## 9. 📋 결론 및 권장사항

### 9.1 프로젝트 강점
✅ **안정적인 아키텍처**: 검증된 MVC 패턴과 3단계 보안 시스템
✅ **확장 가능한 구조**: Maven 기반의 모듈화된 설계  
✅ **체계적인 테스트**: 50개 테스트 케이스로 품질 보장
✅ **완전한 문서화**: 18개 문서로 운영/유지보수 지원

### 9.2 주요 성과
🎯 **기능 완성도**: 8개 주요 기능 모두 운영 가능한 수준
🔒 **보안 수준**: Enterprise Grade 다층 보안 적용
🚀 **개발 효율성**: 자동화 스크립트와 표준화된 개발 프로세스

### 9.3 권장 개선 순서
1. **성능 최적화** → 연결 풀 및 인덱스 튜닝
2. **사용자 경험** → AJAX 및 실시간 기능 추가  
3. **운영 안정성** → 모니터링 및 로깅 강화
4. **기술 현대화** → Spring/REST API 도입 검토

---

**📅 작성일**: 2024년 기준
**📝 작성자**: AI 프로젝트 분석 시스템
**🔄 업데이트**: 주요 변경사항 발생 시 문서 갱신 필요 