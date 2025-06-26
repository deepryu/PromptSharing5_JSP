# 프로젝트 지침서 (PROJECT GUIDE)

## 1. 프로젝트 개요
- 본 프로젝트는 JSP, Servlet, PostgreSQL, Tomcat을 기반으로 한 **개발자 인터뷰 결과 관리 시스템**입니다.
- 회원 관리 기능과 지원자 관리 기능을 포함하며, MVC 패턴을 엄격히 준수합니다.
- 보안과 유지보수성을 최우선으로 하며, 모던한 UI/UX를 제공합니다.

## 1-1. 데이터베이스 정보
- **DB 이름:** promptsharing
- **DB 유저:** postgresql
- **DB 패스워드:** 1234

### 1-1-1. 주요 테이블 구조
```sql
-- 사용자 관리 테이블
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 지원자 관리 테이블 (2025-06-25 team 컬럼 추가)
CREATE TABLE candidates (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    resume TEXT,
    team VARCHAR(50),  -- 지원팀: 개발팀, 기획팀, 디자인팀, 마케팅팀, 영업팀, 인사팀, 재무팀
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 인터뷰 일정 관리 테이블 (2025-06-25 완성)
CREATE TABLE interview_schedules (
    id SERIAL PRIMARY KEY,
    candidate_id INTEGER NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    interviewer_name VARCHAR(100) NOT NULL,
    interview_date DATE NOT NULL,
    interview_time TIME NOT NULL,
    duration INTEGER DEFAULT 60,  -- 소요시간(분)
    location VARCHAR(200),
    interview_type VARCHAR(50) DEFAULT '기술면접',  -- 기술면접, 인성면접, 임원면접 등
    status VARCHAR(20) DEFAULT '예정',  -- 예정, 진행중, 완료, 취소, 연기
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 1-2. 주요 기능
- **회원 관리**: 로그인, 회원가입, 로그아웃, 세션 관리
- **지원자 관리**: CRUD 기능, 지원팀 분류, 시간 기반 정렬
- **✅ 인터뷰 일정 관리**: 완전한 CRUD, 캘린더/리스트 뷰, 상세 페이지, 일정 충돌 방지
- **UI/UX**: 모던한 디자인, 반응형 테이블, 통일된 버튼 스타일, 네비게이션 체계화

## 2. 개발 및 코딩 규칙
- **네이밍**: 클래스/메서드/변수명은 Java 표준을 따릅니다. (CamelCase, 의미 있는 이름)
- **주석**: 핵심 로직, 복잡한 쿼리, 예외 처리에는 반드시 주석을 남깁니다.
- **코드 스타일**: 들여쓰기 4칸, 불필요한 공백/주석/코드 금지
- **커밋 메시지**: 한글 또는 영어로, 변경 목적과 내용을 명확히 작성

## 3. 보안 및 품질 기준
- **SQL Injection 방지**: 모든 쿼리는 PreparedStatement 사용
- **XSS 방지**: 사용자 입력값 출력 시 HTML 이스케이프 필수
- **비밀번호 암호화**: bcrypt(jBCrypt)로 해싱 저장
- **예외 처리**: 사용자에게는 친절한 메시지, 로그에는 상세 정보 기록

## 4. 테스트 및 자동화

### 4-1. 단위 테스트 필수 사항
- **JUnit 기반 테스트**: 모든 DAO 클래스와 핵심 비즈니스 로직에 대해 단위 테스트 작성 필수
- **현재 테스트 케이스**: 총 9개 (UserDAOTest: 4개, CandidateDAOTest: 5개)
- **예정 테스트 케이스**: InterviewScheduleDAOTest (11개 - CRUD, 시간 충돌, 상태별/날짜별 조회 등)
- **테스트 범위**: CRUD 연산, 데이터 유효성 검증, 예외 상황 처리, 데이터 무결성 확인
- **테스트 실행 방법**: `.\test-maven.cmd` 스크립트를 사용하여 Maven 기반 테스트 수행

### 4-2. GitHub Push 전 필수 절차 ⚠️
**⚠️ CRITICAL: GitHub에 푸시하기 전에 반드시 다음 절차를 수행해야 합니다:**

1. **컴파일 검증**:
   ```cmd
   javac -cp ".;WEB-INF/lib/*;C:/tomcat9/lib/servlet-api.jar" -d WEB-INF/classes src/com/example/util/DatabaseUtil.java src/com/example/model/User.java src/com/example/model/UserDAO.java src/com/example/model/Candidate.java src/com/example/model/CandidateDAO.java src/com/example/model/InterviewSchedule.java src/com/example/model/InterviewScheduleDAO.java src/com/example/controller/LoginServlet.java src/com/example/controller/LogoutServlet.java src/com/example/controller/RegisterServlet.java src/com/example/controller/CandidateServlet.java src/com/example/controller/InterviewScheduleServlet.java
   ```

2. **테스트 실행**:
   ```cmd
   # 방법 1: Maven 기반 테스트 실행 (권장)
   .\test-maven.cmd
   
   # 방법 2: JUnit JAR 직접 실행 (기존 방식)
   java -jar WEB-INF/lib/junit-platform-console-standalone.jar --class-path "WEB-INF/classes;WEB-INF/lib/*" --scan-class-path
   ```

3. **수동 테스트 확인**:
   - 웹 애플리케이션 실행하여 주요 기능 동작 확인
   - 데이터베이스 연결 및 CRUD 연산 정상 동작 확인

### 4-3. Maven 기반 테스트 실행 방법
```cmd
# 단계별 Maven 테스트 실행
.\test-maven.cmd

# 또는 개별 테스트 클래스 실행
.\mvnw.cmd test -Dtest=UserDAOTest
.\mvnw.cmd test -Dtest=CandidateDAOTest
.\mvnw.cmd test -Dtest=InterviewScheduleDAOTest

# 전체 Maven 빌드 및 테스트
.\maven-all.cmd
```

**테스트 스크립트 특징**:
- **test-maven.cmd**: 각 테스트 클래스를 개별적으로 실행하여 상세한 결과 표시
- **자동 정리**: 테스트 데이터 중복 및 충돌 방지를 위한 데이터베이스 정리 포함
- **실시간 피드백**: 각 테스트의 성공/실패 상태를 즉시 확인 가능

### 4-4. 자동화 설정 및 Git 명령어

#### PowerShell 기반 Maven Pre-push Hook
- **수동 검증 필수**: Windows PowerShell 환경에서 Git hooks 자동 실행 제한으로 인해 **푸시 전 수동 검증 필수**
- **검증 스크립트**: `.git/hooks/pre-push.ps1` PowerShell 스크립트로 Maven 빌드 및 테스트 수행
- **실행 순서**: Maven Clean → Maven Compile → Maven Test-Compile → Maven Test → 빌드 결과 검증
- **검증 항목**: 
  - Maven 환경 설정 확인 (pom.xml, mvnw.cmd)
  - 전체 소스 컴파일 (util, model, controller)
  - 테스트 소스 컴파일 
  - JUnit 테스트 실행 (총 20개 케이스)
  - 빌드 결과물 검증 (WEB-INF/classes 확인)
- **Windows PowerShell 최적화**: 컬러 출력, 단계별 진행 상황, 상세한 오류 메시지 제공
- **푸시 절차**: 
  1. **필수**: PowerShell 검증 실행
  2. **검증 통과 시**: `git push origin main --no-verify`로 푸시
  3. **검증 실패 시**: 문제 해결 후 재검증

#### Hook 파일 구조
- **`.git/hooks/pre-push`** (bash wrapper):
  - Git이 자동으로 실행하는 진입점
  - PowerShell 실행 정책 설정 및 스크립트 호출
  - PowerShell 실행 결과에 따른 push 허용/차단 제어

- **`.git/hooks/pre-push.ps1`** (PowerShell 스크립트):
  - 실제 Maven 빌드 및 테스트 수행
  - Windows 환경 최적화된 컬러 출력
  - 상세한 오류 진단 및 해결 가이드

#### 필수 푸시 전 검증 절차
```powershell
# 1단계: PowerShell 검증 실행 (필수)
powershell -ExecutionPolicy Bypass -File .git\hooks\pre-push.ps1

# 2단계: 검증 성공 시 GitHub 푸시
git push origin main --no-verify

# 대체 방법: Maven 명령어로 동일한 검증 수행
.\mvnw.cmd clean compile test-compile test

# 단계별 실행 (문제 해결용)
.\mvnw.cmd clean
.\mvnw.cmd compile
.\mvnw.cmd test-compile  
.\mvnw.cmd test
```

#### 중요 주의사항
- **반드시 PowerShell 검증 후 푸시**: Windows 환경에서 Git hooks 자동 실행이 제한되므로 수동 검증 필수
- **--no-verify 사용 조건**: PowerShell 검증 통과 시에만 사용
- **검증 실패 시**: 문제 해결 후 반드시 재검증 수행

#### Windows PowerShell Git 명령어
```powershell
# Git 상태 확인
git status

# 파일 목록 확인 (Windows)
dir .git\hooks\

# 변경사항 스테이징
git add .

# 커밋
git commit -m "커밋 메시지"

# GitHub 푸시
git push origin main

# Hook 우회 푸시 (응급시만)
git push origin main --no-verify
```

### 4-5. 컴파일 및 배포 명령어

#### 4-5-1. 모든 클래스 파일 컴파일 명령어
```cmd
# 방법 1: 개별 파일 지정 (권장)
javac -cp ".;WEB-INF/lib/*;C:/tomcat9/lib/servlet-api.jar" -d WEB-INF/classes src/com/example/util/DatabaseUtil.java src/com/example/model/User.java src/com/example/model/UserDAO.java src/com/example/model/Candidate.java src/com/example/model/CandidateDAO.java src/com/example/model/InterviewSchedule.java src/com/example/model/InterviewScheduleDAO.java src/com/example/controller/LoginServlet.java src/com/example/controller/LogoutServlet.java src/com/example/controller/RegisterServlet.java src/com/example/controller/CandidateServlet.java src/com/example/controller/InterviewScheduleServlet.java

# 방법 2: 와일드카드 사용 (Windows)
javac -cp ".;WEB-INF/lib/*;C:/tomcat9/lib/servlet-api.jar" -d WEB-INF/classes src/com/example/*/*.java

# 방법 3: 순차적 컴파일 (의존성 문제 시)
javac -cp ".;WEB-INF/lib/*;C:/tomcat9/lib/servlet-api.jar" -d WEB-INF/classes src/com/example/util/DatabaseUtil.java
javac -cp ".;WEB-INF/lib/*;C:/tomcat9/lib/servlet-api.jar" -d WEB-INF/classes src/com/example/model/*.java
javac -cp ".;WEB-INF/lib/*;C:/tomcat9/lib/servlet-api.jar" -d WEB-INF/classes src/com/example/controller/*.java
```

#### 4-5-2. 배포 후 Tomcat 중지 명령어
```cmd
# Windows에서 Tomcat 중지만 수행
# 1. Tomcat 중지
taskkill /f /im java.exe
# 또는 서비스 중지
net stop tomcat9

# 참고: 개발 편의상 시작은 수동으로 수행
# 필요 시 아래 명령어로 수동 시작:
# C:\tomcat9\bin\startup.bat
# 또는 서비스 시작: net start tomcat9

# 2. 웹 애플리케이션 재배포 (선택적)
# - Tomcat Manager 사용하여 애플리케이션 재배포
# - 또는 브라우저에서 강제 새로고침 (Ctrl + F5)
```

#### 4-5-3. 배포 확인 명령어
```cmd
# 컴파일된 클래스 파일 확인
dir WEB-INF\classes\com\example\model\*.class
dir WEB-INF\classes\com\example\controller\*.class
dir WEB-INF\classes\com\example\util\*.class

# Tomcat 프로세스 확인
tasklist | findstr java

# 애플리케이션 접속 테스트
# 브라우저에서 http://localhost:8080/PromptSharing5_JSP/ 접속
```

#### 4-5-4. 컴파일 및 배포 상세 설명
- **모든 Java 소스 파일**(util, model, controller)을 한 번에 컴파일
- **servlet-api.jar**와 **WEB-INF/lib**의 모든 라이브러리를 classpath에 포함
- **컴파일된 클래스**는 WEB-INF/classes 디렉토리에 저장
- **변경사항 적용 후** 반드시 컴파일 → Tomcat 중지 → 테스트 순서로 진행 (시작은 수동)
- **NoSuchMethodError 발생 시**: 반드시 Tomcat 중지 필요 (클래스 로더 캐시 문제)

#### 4-5-5. 배포 스크립트 (배치 파일)
```batch
@echo off
echo === JSP 프로젝트 컴파일 및 배포 ===

echo 1. Java 소스 컴파일 중...
javac -cp ".;WEB-INF/lib/*;C:/tomcat9/lib/servlet-api.jar" -d WEB-INF/classes src/com/example/*/*.java

if %errorlevel% neq 0 (
    echo 컴파일 실패!
    pause
    exit /b 1
)

echo 2. 컴파일 성공! Tomcat 중지 중...
taskkill /f /im java.exe 2>nul
timeout /t 3 /nobreak >nul

echo 3. 배포 완료! 수동으로 Tomcat을 시작하세요.
echo    명령어: C:\tomcat9\bin\startup.bat
timeout /t 3 /nobreak >nul
echo 완료!
pause
```

## 5. 협업 및 문서화
- **문서화**: 모든 주요 변경사항은 docs/에 마크다운 파일로 기록
- **이슈/PR**: GitHub 이슈/PR 템플릿을 활용, 상세 설명 필수
- **코드 리뷰**: 반드시 1인 이상 리뷰 후 병합
- **체크리스트 관리**: 프로젝트가 진행될 때마다 관련된 내용을 반드시 `체크리스트.md` 파일에 반영

## 6. 기타 유의사항
- **DB 정보**: DatabaseUtil.java에만 하드코딩, 외부 유출 금지
- **라이브러리 관리**: WEB-INF/lib에 jar 직접 관리, 필요시 README에 명시
- **환경설정**: Tomcat/JDK/PostgreSQL 버전은 README에 명확히 기록

---

> **이 지침서는 에이전트(Assistant)가 모든 자동화, 코드 생성, 문서화, 안내 시 반드시 참조해야 합니다.** 