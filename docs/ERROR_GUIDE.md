# 에러 해결 가이드 (ERROR GUIDE)

## 📋 **개요**
JSP 기반 채용 관리 시스템에서 발생하는 주요 에러들과 검증된 해결책을 정리한 문서입니다.

## 🚨 **에러 사례 1: 이메일 중복 제약 조건 위반**

### **에러 정보**
```
에러: org.postgresql.util.PSQLException: 중복된 키 값이 "candidates_email_key" 고유 제약 조건을 위반함
원인: 동일한 이메일 주소로 지원자 중복 등록 시도
```

### **해결 방법**
1. **CandidateDAO에 이메일 중복 체크 메소드 추가**
   - `isEmailExists(String email)`: 새 등록 시 중복 체크
   - `isEmailExistsForUpdate(String email, int id)`: 수정 시 중복 체크 (자신 제외)

2. **addCandidate/updateCandidate 메소드 수정**
   - 데이터베이스 저장 전 중복 검증 로직 추가
   - 중복 시 false 반환하여 에러 방지

3. **CandidateServlet에서 사용자 친화적 에러 메시지 처리**
   - 성공 시: 목록 페이지 리다이렉트
   - 실패 시: 에러 메시지와 함께 폼으로 복귀 (입력 데이터 유지)

### **개선 효과**
- ✅ 데이터베이스 에러 사전 차단
- ✅ 명확한 에러 메시지 제공
- ✅ 입력 데이터 유지로 사용자 편의성 향상

---

## 🚨 **에러 사례 2: JSP 파일 한글 깨짐**

### **에러 정보**
```
증상: JSP 파일에서 한글 텍스트 깨짐 ("지원자 등록" → "吏?먯옄 ?깅줉")
원인: JSP 파일 내용 자체 손상 (UTF-8 설정은 정상)
```

### **해결 방법**
- JSP 파일 재생성하여 한글 텍스트 직접 재입력

### **예방책**
- UTF-8 BOM 없이 저장
- 파일 전송 시 바이너리 모드 사용

---

## 🚨 **에러 사례 3: 인터뷰 일정 추가 기능 비활성화**

### **에러 정보**
```
증상: 인터뷰 일정 관리에서 "새 일정 추가" 버튼 클릭 시 "해당 기능은 준비 중입니다" 메시지 출력
원인: InterviewScheduleServlet이 간소화된 버전으로 교체되어 /interview/add 요청이 else 블록으로 처리됨
```

### **해결 방법**
1. **백업 파일에서 완전한 기능 복원**
   - `InterviewScheduleServlet.java.backup` 파일의 내용을 현재 파일로 복사
   - switch-case 구조로 모든 경로 처리 (/add, /edit, /detail, /calendar 등)
   - CandidateDAO import 및 초기화 추가

2. **세션 검증 로직 추가**
   - doGet/doPost 메소드 시작 부분에 세션 검증 코드 추가
   - 미로그인 시 login.jsp로 리다이렉트

3. **컴파일 및 적용**
   ```bash
   .\mvnw.cmd compile              # Java 파일 컴파일
   C:\tomcat9\bin\startup.bat      # Tomcat 재시작
   ```

### **복원된 기능들**
- ✅ 새 일정 추가 (`/interview/add`)
- ✅ 일정 수정 (`/interview/edit`)  
- ✅ 일정 상세보기 (`/interview/detail`)
- ✅ 캘린더 보기 (`/interview/calendar`)
- ✅ 지원자별 일정 (`/interview/candidate`)
- ✅ 일정 삭제 (`/interview/delete`)
- ✅ 시간 충돌 검증 기능

### **예방책**
- 백업 파일(.backup) 정기적 확인
- 기능 축소 시 명시적 문서화
- 테스트 케이스 정기 실행

---

## 🚨 **에러 사례 4: Maven 테스트 한글 깨짐**

### **에러 정보**
```
증상: Maven 테스트 실행 시 한글 메시지 깨짐
원인: Windows 환경의 인코딩 불일치
```

### **해결 방법**
```bash
# 완전한 해결 명령어 (PowerShell)
chcp 65001; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $env:MAVEN_OPTS="-Dfile.encoding=UTF-8"; .\mvnw.cmd test
```

---

## 🚨 **에러 사례 5: 2번 메뉴(인터뷰 일정 관리) 빈 화면 문제**

### **에러 정보**
```
증상: main.jsp에서 2번 메뉴(인터뷰 일정 관리) 클릭 시 빈 화면 출력
원인: interview_schedules.jsp 파일의 title 태그에서 한글 깨짐 ("인터뷰 일정 관리" → "?명꽣酉??쇱젙 愿由?")
```

### **해결 방법**
1. **JSP 파일 한글 깨짐 부분 수정**
   - `interview_schedules.jsp`의 title 태그 수정: `<title>인터뷰 일정 관리 - 채용 관리 시스템</title>`
   - 기타 한글 깨짐 부분들도 정상적인 한글로 재입력

2. **영향받는 파일들**
   - `interview_schedules.jsp` (메인 목록 페이지)
   - `interview_schedule_form.jsp` (일정 등록/수정 폼)
   - `interview_schedule_detail.jsp` (일정 상세보기)
   - `interview_calendar.jsp` (캘린더 보기)
   - 기타 인터뷰 관련 JSP 파일들

3. **검증 방법**
   - 브라우저에서 main.jsp → 2번 메뉴 클릭
   - 정상적으로 인터뷰 일정 목록 화면 표시 확인

### **근본 원인**
- JSP 파일 저장 시 UTF-8 인코딩 손상
- 파일 전송 과정에서 바이너리 모드 미사용

### **예방책**
- JSP 파일 작성 시 UTF-8 BOM 없이 저장
- 파일 전송 시 바이너리 모드 사용
- 정기적인 한글 텍스트 검증

---

## 🚨 **에러 사례 6: 인터뷰 일정 상대 경로 404 에러**

### **에러 정보**
```
증상: 인터뷰 일정 관리에서 "새 일정 추가" 버튼 클릭 시 HTTP 404 에러 발생
URL: /PromptSharing5_JSP/interview/interview/add (잘못된 중복 경로)
원인: interview_schedules.jsp가 /interview/list URL에서 실행되는데, 상대 경로 'interview/add'를 클릭하면 현재 URL 기준으로 해석되어 중복 경로 생성
```

### **문제 분석**
1. **현재 상황**
   - `interview_schedules.jsp`는 `/interview/list` URL에서 실행
   - 상대 경로 `interview/add` 클릭 시 `/interview/interview/add`로 해석됨
   - 서블릿 매핑 `/interview/*`에 맞지 않아 404 에러 발생

2. **상대 경로의 문제점**
   - 현재 URL이 `/interview/list`인 상태에서 상대 경로 `interview/add`는 `/interview/interview/add`가 됨
   - 브라우저가 현재 디렉터리를 기준으로 상대 경로를 해석하기 때문

### **해결 방법 (원래 JSP 표준 방식)**
1. **base 태그 추가**
   ```jsp
   <head>
       <meta charset="UTF-8">
       <title>인터뷰 일정 관리 - 채용 관리 시스템</title>
       <base href="${pageContext.request.contextPath}/">
       <link rel="stylesheet" href="css/style.css">
   </head>
   ```

2. **작동 원리**
   - base 태그로 모든 상대 경로의 기준점을 컨텍스트 루트로 설정
   - `interview/add` → `/PromptSharing5_JSP/interview/add`로 자동 변환
   - 기존 상대 경로 유지하면서 문제 해결

3. **검증 방법**
   - 브라우저에서 인터뷰 일정 관리 접근
   - "새 일정 추가" 버튼 클릭하여 정상 작동 확인
   - 개발자 도구에서 URL 경로 확인

### **대안 해결책**
- **절대 경로 사용**: `${pageContext.request.contextPath}/interview/add`
- **컨텍스트 상대 경로**: 모든 링크를 컨텍스트 기준으로 변경

### **예방책**
- JSP 파일 작성 시 base 태그 기본 포함
- 상대 경로 사용 시 현재 URL 구조 고려
- 링크 테스트 시 다양한 URL 경로에서 검증

### **핵심 포인트**
- ✅ base 태그는 JSP 표준 해결책
- ✅ 기존 상대 경로 구조 유지 가능
- ✅ 모든 리소스 경로에 일관성 적용
- ⚠️ base 태그는 head 섹션 최상단에 위치 필요

---

## 🚨 **에러 사례 7: Maven 테스트 한글 깨짐**

### **에러 정보**
```
증상: Maven 테스트 실행 시 한글 메시지 깨짐
원인: Windows 환경의 인코딩 불일치
```

### **해결 방법**
```bash
# 완전한 해결 명령어 (PowerShell)
chcp 65001; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $env:MAVEN_OPTS="-Dfile.encoding=UTF-8"; .\mvnw.cmd test
```

---

## 🔧 **일반적인 트러블슈팅**

### **자주 발생하는 문제들**
1. **이메일 중복**: PostgreSQL UNIQUE 제약 조건 위반
2. **한글 깨짐**: UTF-8 인코딩 설정 문제
3. **NoSuchMethodError**: Tomcat 재시작 필요 (클래스 로더 캐시)
4. **세션 만료**: 로그인 페이지 리다이렉트
5. **포트 충돌**: 8080 포트 사용 중
6. **컴파일 오류**: import 문 누락, 구문 오류

### **표준 해결 절차**
```bash
# 1. Java 파일 변경 시
.\mvnw.cmd compile              # 컴파일 (Tomcat 자동 종료)
C:\tomcat9\bin\startup.bat      # 수동 재시작

# 2. JSP 파일만 변경 시
# 브라우저 새로고침만 필요 (컴파일 불필요)
```

### **예방 가이드라인**
- UTF-8 인코딩 일관성 유지
- 정기적인 컴파일 및 테스트
- 세션 검증 로직 표준화
- 데이터베이스 제약 조건 사전 검증

### **중요 규칙**
- ⚠️ **web.xml 서블릿 매핑 추가 금지** - @WebServlet 어노테이션 사용
- ⚠️ **Tomcat 자동 재시작 금지** - 수동 재시작만 허용

---

## 📚 **참고 자료**
- **PROJECT_GUIDE.md**: 프로젝트 전반적인 가이드
- **SECURITY_GUIDE.md**: 보안 관련 가이드
- **변경이력.md**: 프로젝트 변경 사항 기록 