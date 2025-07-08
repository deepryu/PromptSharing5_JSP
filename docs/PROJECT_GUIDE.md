# 프로젝트 가이드 (PROJECT GUIDE)

## 📋 프로젝트 개요
**JSP 기반 개발자 인터뷰 관리 시스템**
- **기술 스택**: JSP, Servlet, PostgreSQL, Maven, Tomcat
- **구조**: MVC 패턴
- **특징**: 모던 UI/UX, 반응형 디자인

## 🗄️ 데이터베이스

### 📊 DB 연결 정보
```yaml
DB 정보:
  - 이름: promptsharing
  - 사용자: postgresql
  - 비밀번호: 1234
  - 주요 테이블: users, candidates, interview_schedules, interview_results
```

### 🔧 데이터베이스 작업 정책 (중요!)

**⚠️ 에이전트 행동 제한사항**:
- **절대 금지**: PostgreSQL에 직접 연결 시도 (`psql` 명령어 등)
- **절대 금지**: 데이터베이스 스크립트 자동 실행
- **허용 사항**: SQL 스크립트 파일 생성만 허용

**✅ 올바른 DB 작업 절차**:
1. **스크립트 생성**: 에이전트가 SQL 스크립트 파일을 생성
2. **수동 실행**: 사용자가 직접 PostgreSQL에서 스크립트 실행
3. **결과 확인**: 사용자가 변경사항 확인 후 피드백

**📁 스크립트 저장 위치**: `sql/` 디렉토리
- 테이블 생성: `create_*.sql`
- 테이블 수정: `alter_*.sql` 또는 `add_*.sql`
- 데이터 삽입: `insert_*.sql`
- 업데이트: `update_*.sql`

**💡 사용자 제어권 보장**:
- 데이터베이스 스키마 변경은 중요한 작업이므로 사용자가 직접 검토하고 실행
- 에이전트는 스크립트 생성과 설명만 제공
- 데이터 손실 방지를 위한 안전 장치

**🔍 스크립트 생성 예시**:
```sql
-- 파일: sql/add_resume_fields.sql
-- 목적: 지원자 테이블에 이력서 파일 관련 컬럼 추가

ALTER TABLE candidates 
ADD COLUMN resume_file_name VARCHAR(255),
ADD COLUMN resume_file_path VARCHAR(500),
ADD COLUMN resume_file_size BIGINT DEFAULT 0,
ADD COLUMN resume_file_type VARCHAR(50),
ADD COLUMN resume_uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
```

## 🏗️ 주요 기능
| 기능 | 상태 | 설명 |
|------|------|------|
| 회원 관리 | ✅ 완료 | 로그인, 회원가입, 세션 관리 |
| 지원자 관리 | ✅ 완료 | CRUD, 팀별 분류 |
| 인터뷰 일정 관리 | ✅ 완료 | 일정 생성/수정, 캘린더 뷰 |
| 인터뷰 결과 관리 | ✅ 완료 | 결과 기록, 평가 항목 관리 |
| 질문 관리 | ✅ 완료 | 질문 생성/분류, 평가 기준 |

## ⚡ 코드 수정 안전 가이드라인 (중요!)

### 🛡️ 정상 동작 코드 수정 시 주의사항

**❗ 기본 원칙**: 정상적으로 동작하는 코드를 수정할 때는 최대한 신중하게 접근

#### 📋 수정 전 필수 체크리스트

**1. 🔍 기존 코드 분석**
```bash
# 수정 전 반드시 기존 코드의 현재 상태 확인
- 현재 메소드명과 시그니처 확인
- 의존성 클래스들의 실제 메소드 확인  
- 컴파일 상태 및 동작 여부 확인
```

**2. 📊 수정 전후 비교 분석**
```markdown
수정 사유: [구체적인 이유 기술]
수정 범위: [변경되는 부분 명시]  
영향 범위: [다른 클래스/메소드에 미치는 영향]
테스트 필요성: [컴파일/실행 테스트 계획]
```

**3. 🎯 최소 변경 원칙**
- **목적**: 디버깅 로그 추가가 목적이라면 → 로그만 추가
- **금지**: 기존 메소드 호출 방식 변경 금지
- **우선**: 기존 구조 유지하면서 목적 달성

#### ⚠️ 자주 발생하는 실수 패턴

**1. 메소드명 변경으로 인한 컴파일 오류**
```java
// ❌ 잘못된 예: 기존 메소드를 추측으로 변경
User user = userDAO.login(username, password);  // login() 메소드가 없을 수 있음

// ✅ 올바른 예: 기존 메소드 확인 후 사용
User user = userDAO.findByUsername(username);   // 실제 존재하는 메소드 확인
if (user != null && BCrypt.checkpw(password, user.getPassword())) {
    // 추가 로직
}
```

**2. 객체 필드/메소드 추측으로 인한 오류**
```java
// ❌ 잘못된 예: 존재하지 않는 메소드 호출
session.setAttribute("name", user.getName());    // getName() 메소드가 없을 수 있음
session.setAttribute("role", user.getRole());    // getRole() 메소드가 없을 수 있음

// ✅ 올바른 예: 실제 존재하는 메소드만 사용
session.setAttribute("username", user.getUsername());  // 실제 존재 확인
session.setAttribute("userId", user.getId());          // 실제 존재 확인
```

#### 🔧 안전한 수정 절차

**Step 1: 현재 상태 파악**
```bash
# 해당 클래스 파일 내용 확인
read_file src/com/example/model/UserDAO.java
read_file src/com/example/model/User.java

# 컴파일 상태 확인  
mvnw.cmd compile
```

**Step 2: 수정 계획 수립**
```markdown
📝 수정 계획서:
- 목적: [예: 디버깅 로그 추가]
- 변경 대상: [예: LoginServlet.java의 doPost 메소드]
- 보존 사항: [예: 기존 로그인 로직 완전 보존]
- 추가 사항: [예: System.out.println 디버깅 로그만 추가]
```

**Step 3: 점진적 수정**
```java
// 1단계: 로그만 추가 (기존 로직 건드리지 않음)
System.out.println("🔍 [LoginServlet] 로그인 시작: " + username);
기존코드_그대로_유지();

// 2단계: 컴파일 테스트
mvnw.cmd compile

// 3단계: 오류 발생시 즉시 롤백하고 분석
```

#### 📚 수정 사유 문서화

**모든 코드 수정시 반드시 포함해야 할 설명**:

```markdown
## 수정 사유 및 내용

### 🎯 수정 목적
- [구체적인 목적]: 예) ERR_TOO_MANY_REDIRECTS 디버깅을 위한 로그 추가

### 📝 수정 내용  
- [변경 사항]: 예) LoginServlet, AuthenticationFilter에 System.out.println 디버깅 로그 추가
- [보존 사항]: 예) 기존 로그인 로직, 세션 관리 로직 완전 보존

### ⚖️ 변경 전후 비교
**변경 전:**
- 정상 동작하는 로그인 기능
- 컴파일 오류 없음

**변경 후:**  
- 동일한 로그인 기능 + 디버깅 로그
- 컴파일 오류 없어야 함

### 🧪 검증 방법
- [ ] 컴파일 성공 확인
- [ ] 로그인 기능 정상 동작 확인  
- [ ] 디버깅 로그 정상 출력 확인
```

#### 🚨 긴급 롤백 가이드

**컴파일 오류 발생시 즉시 대응**:
```bash
# 1. 백업에서 복원 (권장)
cp backup/LoginServlet.java.backup src/com/example/controller/LoginServlet.java

# 2. Git으로 되돌리기
git checkout HEAD -- src/com/example/controller/LoginServlet.java

# 3. 재컴파일 확인
mvnw.cmd compile
```

### 💡 모범 사례

**✅ 안전한 수정 예시**:
```java
// 기존 코드 (그대로 유지)
if (user != null && BCrypt.checkpw(password, user.getPassword())) {
    // 디버깅 로그만 추가 (기존 로직 변경 없음)
    System.out.println("✅ [LoginServlet] 로그인 성공: " + username);
    
    HttpSession session = request.getSession(true);
    session.setAttribute("username", user.getUsername()); // 기존 메소드 그대로
    
    response.sendRedirect("main.jsp");
}
```

**❌ 위험한 수정 예시**:
```java
// 기존에 없던 메소드를 추측으로 사용 (컴파일 오류 발생)
User user = userDAO.login(username, password);  // login() 메소드가 실제로 없음
session.setAttribute("role", user.getRole());   // getRole() 메소드가 실제로 없음
```

### 🔄 사후 검증 절차

**모든 수정 완료 후 필수 검증**:
1. **컴파일 테스트**: `mvnw.cmd compile` 성공 확인
2. **기능 테스트**: 기존 동작이 정상인지 확인  
3. **목적 달성**: 수정 목적(예: 디버깅 로그)이 달성되었는지 확인
4. **부작용 점검**: 다른 기능에 영향을 주지 않았는지 확인

**📌 기억할 것**: 코드 수정의 80%는 기존 코드 보존, 20%만 새로운 기능 추가

## 🎨 UI/UX 스타일 가이드

### 📐 표준 디자인 시스템 (main.jsp 기준)
**모든 새로운 화면은 main.jsp의 GitHub 스타일을 따라야 합니다.**

#### 🏗️ 기본 레이아웃 구조
```html
<div class="container">
    <div class="top-bar">
        <!-- 상단 바: 제목 + 사용자 정보 + 액션 버튼 -->
    </div>
    
    <div class="main-dashboard">
        <div class="dashboard-header">
            <!-- 페이지 헤더: 배경색 #0078d4 -->
        </div>
        <div class="dashboard-content">
            <!-- 메인 콘텐츠 영역 -->
        </div>
    </div>
</div>
```

#### 🎨 색상 팔레트 (GitHub 기반)
```css
/* 주요 색상 */
--primary-bg: #f0f0f0;          /* 배경색 */
--container-bg: white;          /* 컨테이너 배경 */
--border-color: #d0d7de;        /* 테두리 */
--text-primary: #24292f;        /* 기본 텍스트 */
--text-secondary: #656d76;      /* 보조 텍스트 */
--header-bg: #0078d4;           /* 헤더 배경 */
--header-border: #106ebe;       /* 헤더 테두리 */

/* 상태 색상 */
--success: #1f883d;             /* 성공/완료 */
--warning: #d97706;             /* 경고/대기 */
--danger: #cf222e;              /* 오류/삭제 */
--info: #0969da;                /* 정보 */

/* 호버 효과 */
--hover-bg: #f6f8fa;            /* 호버 배경 */
--hover-border: #8c959f;        /* 호버 테두리 */
```

#### 🧩 필수 컴포넌트

**1. 상단 바 (top-bar)**
```css
.top-bar {
    background: white;
    border: 1px solid #d0d7de;
    padding: 10px 20px;
    margin-bottom: 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}
```

**2. 메인 대시보드 (main-dashboard)**
```css
.main-dashboard {
    background: white;
    border: 1px solid #d0d7de;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.dashboard-header {
    background: #0078d4;
    color: white;
    padding: 15px 25px;
    border-bottom: 1px solid #106ebe;
}
```

**3. 버튼 스타일**
```css
.btn {
    padding: 6px 16px;
    border: 1px solid #d0d7de;
    border-radius: 6px;
    font-size: 0.9rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-primary {
    background: #1f883d;
    border-color: #1f883d;
    color: white;
}

.btn-secondary {
    background: white;
    color: #24292f;
}
```

#### 📱 반응형 가이드라인
```css
@media (max-width: 768px) {
    .container {
        margin: 10px;
        padding: 0 10px;
    }
    
    .dashboard-content {
        padding: 12px;
    }
}
```

#### ✅ 스타일 준수 체크리스트
- [ ] `container` → `top-bar` → `main-dashboard` 구조 사용
- [ ] GitHub 색상 팔레트 적용 (`#f0f0f0`, `#d0d7de`, `#0078d4` 등)
- [ ] 상단 바에 사용자 인사말과 액션 버튼 배치
- [ ] `dashboard-header`에 페이지 제목 표시
- [ ] 일관된 버튼 스타일 (`btn`, `btn-primary`, `btn-secondary`)
- [ ] 모바일 반응형 디자인 적용
- [ ] 호버 효과와 전환 애니메이션 포함

#### 🚫 금지 사항
- ❌ 그라데이션 배경 사용 금지 (GitHub 스타일 위배)
- ❌ 독립적인 색상 체계 사용 금지
- ❌ 카드형 레이아웃 대신 테이블형 우선 사용
- ❌ 과도한 그림자 효과 금지

**📌 참고 파일**: `main.jsp`, `system_settings.jsp`, `system_settings_edit.jsp`

## 🛠️ 개발 환경 설정

### Maven 기반 빌드 시스템
```bash
# 📌 Java 클래스 변경 시 필수 컴파일 명령어 (Tomcat 자동 종료 포함)
.\mvnw.cmd compile

# 강제 재컴파일 (캐시 문제 해결)
.\mvnw.cmd clean compile

# 테스트 실행 (한글 정상 출력)
chcp 65001; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $env:MAVEN_OPTS="-Dfile.encoding=UTF-8"; .\mvnw.cmd test

# 전체 빌드 (컴파일 + 테스트 + 패키징)
.\mvnw.cmd clean compile test package
```

**⚡ 중요**: Java 클래스 파일(.java) 변경 후 반드시 `.\mvnw.cmd compile` 실행 필요
- JSP 파일: 컴파일 불필요 (Tomcat 자동 처리)
- Java 파일: 반드시 Maven 컴파일 후 Tomcat 재시작
- **🔄 자동화**: `.\mvnw.cmd compile` 실행 시 Tomcat 자동 종료하여 클래스 로더 충돌 방지

### 📋 Maven 컴파일 자동화 절차
1. **컴파일 전 준비**: Tomcat 프로세스 자동 종료
2. **Maven 컴파일**: 변경된 Java 클래스 컴파일
3. **에이전트 제한**: **컴파일 완료 후 Tomcat 자동 재시작 금지**
4. **수동 재시작**: 사용자가 직접 Tomcat 재시작
   ```bash
   # Tomcat 재시작 명령어
   C:\tomcat9\bin\startup.bat
   ```

**🚫 에이전트 행동 제한사항**:
- **절대 금지**: 컴파일 후 Tomcat 자동 재시작
- **안내만 허용**: "컴파일 완료! 변경사항 적용을 위해 Tomcat을 재시작하세요." 메시지만 출력
- **사용자 제어**: Tomcat 재시작은 반드시 사용자가 직접 수행

**💡 이점**: 
- NoSuchMethodError 방지 (클래스 로더 캐시 충돌 해결)
- 컴파일 실패 시 안전한 롤백 가능
- 사용자 제어권 보장 및 시스템 안정성 향상

### 자동화 스크립트
- `auto-compile-deploy.cmd`: 완전한 빌드/배포 파이프라인
- `quick-compile.cmd`: 빠른 컴파일 전용
- `test-maven.cmd`: 테스트 실행 전용

## 🧪 테스트
현재 **50개 테스트 케이스** 운영 중:
- UserDAOTest: 4개
- CandidateDAOTest: 5개  
- InterviewScheduleDAOTest: 11개
- InterviewQuestionDAOTest: 17개
- InterviewResultDAOTest: 13개

## 🚀 배포 절차

### 1. JSP 파일만 변경
```bash
# 컴파일 불필요 - Tomcat 자동 처리
git add *.jsp
git commit -m "style: UI 개선"
git push origin main
# 브라우저에서 Ctrl+F5로 새로고침
```

### 2. Java 파일 변경
```bash
# 1. Maven 컴파일 (필수 단계)
.\mvnw.cmd compile

# 2. Maven 검증 실행
powershell -ExecutionPolicy Bypass -File .git\hooks\pre-push.ps1

# 3. 검증 통과 시 푸시
git add .
git commit -m "feat: 새로운 기능 추가"
git push origin main --no-verify

# 4. Tomcat 재시작 (수동)
taskkill /f /im java.exe
C:\tomcat9\bin\startup.bat
```

**📋 Java 파일 변경 체크리스트**:
- ✅ 1단계: `.\mvnw.cmd compile` 실행
- ✅ 2단계: 컴파일 성공 확인
- ✅ 3단계: Tomcat 재시작 
- ✅ 4단계: 브라우저 테스트

## 🔒 보안 규칙

### 🛡️ 다층 보안 시스템
이 프로젝트는 **3단계 보안 검증**을 통해 무단 접근을 완전히 차단합니다:

#### 1단계: AuthenticationFilter (서블릿 필터)
```java
// 모든 요청에 대해 자동 세션 검증
@WebFilter("/*")
public class AuthenticationFilter implements Filter {
    // 로그인하지 않은 사용자의 모든 URL 직접 접근 차단
    // 예외: /login, /register, CSS/JS 파일
}
```

#### 2단계: 서블릿 세션 검증
```java
// ✅ 모든 서블릿에서 필수 구현
HttpSession session = request.getSession(false);
if (session == null || session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
    return;
}
```

#### 3단계: JSP 페이지 세션 검증
```jsp
<!-- ✅ 모든 JSP 페이지 상단에 필수 추가 -->
<%
    String username = (String)session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
```

### 🎯 세션 검증 표준 (중요!)
```java
// ✅ 올바른 세션 검증 방법 - 모든 서블릿과 JSP에서 사용
HttpSession session = request.getSession(false);
if (session == null || session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
    return;
}

// ❌ 잘못된 방법 - userEmail 사용 금지
if (session.getAttribute("userEmail") == null) { // 이렇게 하지 마세요!
```

```jsp
<!-- ✅ JSP에서 올바른 세션 검증 -->
<%
    String username = (String)session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!-- ❌ JSP에서 잘못된 세션 검증 -->
<%
    if (session.getAttribute("userEmail") == null) { // 이렇게 하지 마세요!
%>
```

**⚠️ 필수 준수사항**:
- 로그인 시 설정: `session.setAttribute("username", username)`
- 세션 검증 시: `session.getAttribute("username")`
- 모든 서블릿과 JSP에서 일관성 유지
- `userEmail` 속성 사용 절대 금지 (로그인 페이지 리다이렉트 오류 원인)

### 🔐 보안 강화 완료 현황
- ✅ **AuthenticationFilter 구현**: 모든 요청 자동 검증
- ✅ **JSP 세션 검증 일괄 추가**: 28개 파일 보안 강화
- ✅ **잘못된 userEmail 속성 수정**: username 표준으로 통일
- ✅ **SQL Injection 방지**: PreparedStatement 사용
- ✅ **XSS 방지**: HTML 이스케이프 처리
- ✅ **비밀번호 암호화**: BCrypt 해싱 적용

### 🚨 차단되는 공격 유형
1. **직접 URL 접근**: `http://localhost:8080/PromptSharing5_JSP/main.jsp` → 자동 로그인 페이지 리다이렉트
2. **세션 하이재킹**: 세션 ID 탈취해도 username 속성 검증으로 차단
3. **AJAX 무단 접근**: 401 Unauthorized 응답으로 차단
4. **SQL Injection**: PreparedStatement로 완전 차단
5. **XSS 공격**: HTML 이스케이프로 차단

### 🛡️ 보안 테스트 방법
```bash
# 1. 로그아웃 상태에서 직접 URL 접근 테스트
curl -i http://localhost:8080/PromptSharing5_JSP/main.jsp
# 결과: 302 Found → login.jsp 리다이렉트

# 2. 잘못된 세션으로 접근 테스트  
curl -i -H "Cookie: JSESSIONID=invalid" http://localhost:8080/PromptSharing5_JSP/candidates
# 결과: 302 Found → login.jsp 리다이렉트

# 3. AJAX 무단 접근 테스트
curl -i -H "X-Requested-With: XMLHttpRequest" http://localhost:8080/PromptSharing5_JSP/statistics
# 결과: 401 Unauthorized + JSON 에러 메시지
```

**🔒 보안 수준**: **Enterprise Grade** - 금융권 수준의 다층 보안 적용

## 🤖 AI 에이전트 지침

### 필수 준수 사항
1. **GitHub 푸시**: 파일 변경 완료 후 반드시 사용자 확인 필요
2. **Tomcat 재시작**: 자동 재시작 금지, 명령어만 제공
3. **Maven 인코딩**: 한글 깨짐 방지 위해 UTF-8 설정 필수

### 표준 응답 템플릿
```
✅ 작업 완료: [변경사항 요약]
⚠️ 필요 조치: [컴파일/재시작 여부]
🔄 다음 단계: [권장 명령어]

GitHub에 변경사항을 푸시하시겠습니까?
```

## 📝 코딩 표준
- **네이밍**: Java 표준 CamelCase
- **주석**: 핵심 로직, 복잡한 쿼리에 필수
- **들여쓰기**: 4칸
- **커밋 메시지**: `feat:`, `fix:`, `style:` 등 prefix 사용

## 🔧 참고 문서
- **ERROR_GUIDE.md**: 에러 해결 가이드 및 트러블슈팅
- **SECURITY_GUIDE.md**: 보안 관련 가이드
- **변경이력.md**: 프로젝트 변경 사항 기록

## ⚠️ 중요: web.xml 서블릿 매핑 규칙
- **절대 추가 금지**: web.xml에 서블릿 매핑 추가하지 말 것
- **@WebServlet 어노테이션 사용**: 모든 서블릿은 어노테이션 방식 적용
- **충돌 방지**: 중복 매핑으로 인한 에러 방지

## 파일 탐색 및 검색 명령어 사용 원칙
- findstr, type 등 파일 탐색/검색 명령어는 작업 진행 중 자동으로 사용한다.
- 해당 명령어 실행 여부를 사용자에게 묻지 않는다.
- 파일 구조, 코드 위치, 특정 문자열 탐색 등은 자동으로 처리한다.

## Java 코드 작성 원칙
- Java 15 이상의 Text Block(""" ... """) 문법을 사용하지 않는다.
- 모든 SQL 및 긴 문자열은 기존의 문자열 연결 방식(+, \n 등)으로 작성한다.

## 자바 클래스 변경 시 자동 컴파일 및 톰캣 종료 정책

- 자바(.java) 클래스 파일이 변경되면 반드시 아래 절차가 자동으로 실행됩니다.
    1. **컴파일 전 톰캣 프로세스 자동 종료**: `taskkill /f /im java.exe` 명령어로 Tomcat(Java) 프로세스가 강제 종료됩니다.
    2. **Maven 컴파일 자동 실행**: `.\mvnw.cmd compile` 명령어로 전체 자바 소스가 컴파일됩니다.
- 이 정책은 클래스 로더 캐시 충돌 및 NoSuchMethodError 방지, 최신 코드 반영을 위해 필수입니다.
- JSP 파일만 변경 시에는 컴파일/톰캣 종료가 필요하지 않습니다(브라우저 새로고침만 하면 됨).
- 관련 자동화 로직은 mvnw.cmd, auto-compile-deploy.cmd 등에 구현되어 있습니다.

---

**📌 이 문서는 프로젝트의 핵심 가이드라인입니다. 모든 개발자는 이 문서를 숙지하고 준수해야 합니다.**