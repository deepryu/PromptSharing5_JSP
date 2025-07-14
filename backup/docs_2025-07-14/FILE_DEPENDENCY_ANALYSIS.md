# 파일간 의존성 분석 (FILE DEPENDENCY ANALYSIS)

## 📋 개요
JSP 기반 인터뷰 관리 시스템의 파일간 의존성을 상세 분석한 문서입니다.

---

## 1. 🏗️ 아키텍처 계층별 의존성

### 1.1 전체 의존성 구조
```
🌐 Browser (클라이언트)
    ↕️ HTTP Request/Response
📱 JSP Files (View Layer)
    ↕️ Forward/Redirect
🎮 Servlet Files (Controller Layer)  
    ↕️ Method Calls
📊 DAO/Model Files (Model Layer)
    ↕️ JDBC Connection
🗄️ PostgreSQL Database
```

### 1.2 Maven 기반 프로젝트 구조
```
PromptSharing5_JSP/
├── pom.xml                    # 👑 최상위 의존성 정의
├── src/                       # 📁 Java 소스코드
│   └── com/example/
│       ├── controller/        # 🎮 서블릿 컨트롤러 (13개)
│       ├── model/             # 📊 모델/DAO 클래스 (20개)
│       ├── filter/            # 🛡️ 보안 필터 (1개)
│       └── util/              # 🔧 유틸리티 클래스 (2개)
├── test/                      # 🧪 테스트 코드
├── *.jsp                      # 🎨 JSP 뷰 파일 (28개)
├── css/                       # 🎨 스타일시트 (2개)
├── WEB-INF/                   # ⚙️ 웹 설정
│   ├── web.xml                # 🔧 서블릿 매핑
│   ├── classes/               # 📦 컴파일된 클래스
│   └── lib/                   # 📚 의존성 라이브러리
├── sql/                       # 🗄️ 데이터베이스 스크립트 (17개)
└── docs/                      # 📖 프로젝트 문서 (18개)
```

---

## 2. 📦 Maven 의존성 트리

### 2.1 라이브러리 의존성
```xml
<!-- pom.xml 기반 의존성 트리 -->
promptsharing-jsp:1.3.0
├── javax.servlet:javax.servlet-api:4.0.1 [provided]
│   └── 모든 서블릿이 의존 (HttpServlet, HttpServletRequest, HttpServletResponse)
├── org.postgresql:postgresql:42.7.7
│   └── DatabaseUtil.java → 모든 DAO 클래스가 의존
├── org.mindrot:jbcrypt:0.4
│   └── UserDAO.java, RegisterServlet.java, LoginServlet.java가 의존
└── junit:junit:4.13.2 [test]
    └── 모든 테스트 클래스가 의존 (6개 테스트 클래스)
```

### 2.2 컴파일 시간 의존성
```
컴파일 순서 (Maven 빌드 단계):
1. DatabaseUtil.java          # 🔧 가장 기본적인 유틸리티
2. Model Classes (*.java)      # 📊 데이터 모델 (POJO)
3. DAO Classes (*.java)        # 📊 데이터 액세스 계층
4. Servlet Classes (*.java)    # 🎮 컨트롤러 계층
5. Filter Classes (*.java)     # 🛡️ 보안 필터
6. Test Classes (*.java)       # 🧪 테스트 코드
```

---

## 3. 🎮 서블릿(Controller) 의존성 분석

### 3.1 공통 의존성 패턴
```java
// 🎯 모든 서블릿이 공통으로 의존하는 요소들

// 1. Java 표준 라이브러리
import java.io.*;
import java.sql.*;
import java.util.*;

// 2. 서블릿 API
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;

// 3. 프로젝트 내부 의존성
import com.example.util.DatabaseUtil;        // 🔧 DB 연결 유틸리티
import com.example.model.[ModelName];         // 📊 데이터 모델
import com.example.model.[ModelName]DAO;      // 📊 데이터 액세스
```

### 3.2 서블릿별 상세 의존성

#### 📋 CandidateServlet.java
```java
직접 의존:
├── com.example.model.Candidate               // 지원자 모델
├── com.example.model.CandidateDAO            // 지원자 DAO
├── com.example.util.FileUploadUtil           // 파일 업로드 유틸리티
└── javax.servlet.annotation.MultipartConfig  // 파일 업로드 설정

간접 의존:
├── DatabaseUtil.java ← CandidateDAO.java
├── PostgreSQL JDBC ← DatabaseUtil.java
└── BCrypt ← 비밀번호 관련 기능 (향후 추가 시)

연결된 JSP:
├── candidates.jsp                            // 목록 페이지
├── candidate_form.jsp                        // 등록/수정 폼
├── candidate_detail.jsp                      // 상세 페이지
└── main.jsp                                  // 메인 대시보드
```

#### 🗓️ InterviewScheduleServlet.java  
```java
직접 의존:
├── com.example.model.InterviewSchedule       // 일정 모델
├── com.example.model.InterviewScheduleDAO    // 일정 DAO
├── com.example.model.Candidate               // 지원자 모델
├── com.example.model.CandidateDAO            // 지원자 DAO (조인용)
└── java.text.SimpleDateFormat               // 날짜 형식 변환

간접 의존:
├── DatabaseUtil.java ← 모든 DAO
└── PostgreSQL JDBC ← DatabaseUtil.java

연결된 JSP:
├── interview_schedules.jsp                   // 일정 목록
├── interview_schedule_form.jsp               // 일정 등록/수정
├── interview_schedule_detail.jsp             // 일정 상세
└── interview_calendar.jsp                    // 캘린더 뷰
```

#### 📊 InterviewResultServlet.java
```java
직접 의존:
├── com.example.model.InterviewResult         // 결과 모델
├── com.example.model.InterviewResultDAO      // 결과 DAO
├── com.example.model.Candidate               // 지원자 모델
├── com.example.model.CandidateDAO            // 지원자 DAO
├── com.example.model.InterviewQuestion       // 질문 모델
├── com.example.model.InterviewQuestionDAO    // 질문 DAO
├── com.example.model.InterviewResultQuestion // 결과-질문 연결 모델
└── com.example.model.InterviewResultQuestionDAO // 결과-질문 DAO

복잡한 다중 의존성:
├── 지원자 정보 조회를 위한 CandidateDAO
├── 면접 질문 목록을 위한 InterviewQuestionDAO  
├── 결과-질문 연결을 위한 InterviewResultQuestionDAO
└── 평균 점수 계산을 위한 집계 쿼리

연결된 JSP:
├── interview_results.jsp                     // 결과 목록
├── interview_result_form.jsp                 // 결과 등록/수정
└── interview_result_detail.jsp               // 결과 상세
```

#### 🔐 LoginServlet.java & RegisterServlet.java
```java
공통 의존:
├── com.example.model.User                    // 사용자 모델
├── com.example.model.UserDAO                 // 사용자 DAO
├── org.mindrot.jbcrypt.BCrypt               // 비밀번호 해싱
└── javax.servlet.http.HttpSession           // 세션 관리

인증 관련 의존성:
├── BCrypt.hashpw() ← 회원가입 시 비밀번호 해싱
├── BCrypt.checkpw() ← 로그인 시 비밀번호 검증
└── session.setAttribute("username", username) ← 세션 설정

연결된 JSP:
├── login.jsp                                 // 로그인 폼
├── register.jsp                              // 회원가입 폼
├── main.jsp                                  // 로그인 성공 시
└── welcome.jsp                               // 환영 페이지
```

---

## 4. 📊 Model/DAO 계층 의존성 분석

### 4.1 DAO 계층 공통 의존성
```java
// 🎯 모든 DAO 클래스의 공통 의존성 패턴

// 1. 필수 의존성 (모든 DAO가 공통)
import java.sql.*;                            // JDBC API
import java.util.*;                           // Collections
import com.example.util.DatabaseUtil;        // DB 연결 유틸리티

// 2. DAO 클래스 구조 패턴
public class [ModelName]DAO {
    // DatabaseUtil.getConnection() 의존
    // PreparedStatement 사용으로 SQL Injection 방지
    // 리소스 자동 해제 (try-with-resources)
}
```

### 4.2 핵심 유틸리티 의존성

#### 🔧 DatabaseUtil.java (중앙 집중식 의존성)
```java
모든 DAO가 의존하는 핵심 클래스:
├── org.postgresql.Driver                     // PostgreSQL JDBC 드라이버
├── java.sql.DriverManager                   // 연결 관리
└── Connection Pool 패턴 (향후 HikariCP 도입 예정)

제공하는 메서드:
├── getConnection()                           // DB 연결 획득
├── closeConnection()                         // 연결 해제
└── 예외 처리 및 로깅

의존하는 클래스들 (20개 DAO):
├── UserDAO.java
├── CandidateDAO.java  
├── InterviewScheduleDAO.java
├── InterviewResultDAO.java
├── InterviewQuestionDAO.java
├── EvaluationCriteriaDAO.java
├── InterviewerDAO.java
├── NotificationDAO.java
├── ActivityHistoryDAO.java
├── SystemSettingsDAO.java
└── 향후 추가될 모든 DAO 클래스들
```

#### 📁 FileUploadUtil.java
```java
파일 업로드 관련 의존성:
├── javax.servlet.http.Part                   // 멀티파트 파일 처리
├── java.io.File                              // 파일 시스템 접근
├── java.nio.file.Files                       // 파일 조작
└── java.util.UUID                            // 고유 파일명 생성

사용하는 서블릿:
├── CandidateServlet.java                     // 이력서 파일 업로드
└── 향후 InterviewerServlet.java             // 프로필 사진 업로드 (예정)

파일 저장 경로:
├── uploads/resumes/                          // 이력서 파일
├── uploads/temp/                             // 임시 파일
└── uploads/profiles/                         // 프로필 사진 (향후)
```

### 4.3 Model 클래스 의존성
```java
// 📊 Model 클래스들의 의존성은 단순함

// 1. Java 표준 라이브러리만 의존
import java.sql.Timestamp;
import java.sql.Date;
import java.sql.Time;
import java.text.SimpleDateFormat;

// 2. 외부 라이브러리 의존성 없음 (POJO 패턴)
// 3. 다른 프로젝트 클래스에 의존하지 않음
// 4. 순수한 데이터 전송 객체 (DTO) 역할
```

---

## 5. 🎨 View(JSP) 계층 의존성 분석

### 5.1 JSP 공통 의존성
```jsp
<!-- 🎯 모든 JSP 페이지의 공통 의존성 -->

<!-- 1. 인코딩 설정 (필수) -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- 2. 세션 검증 (보안) -->
<%
String username = (String)session.getAttribute("username");
if (username == null) { 
    response.sendRedirect("login.jsp"); 
    return; 
}
%>

<!-- 3. 기본 HTML 구조 -->
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- 4. CSS 의존성 -->
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/style.css">
    <!-- 5. 상대 경로 기준점 설정 -->
    <base href="${pageContext.request.contextPath}/">
</head>
```

### 5.2 JSP별 특화 의존성

#### 📋 candidates.jsp (지원자 목록)
```jsp
서블릿 의존성:
├── CandidateServlet?action=list              // 목록 조회
├── CandidateServlet?action=add               // 등록 폼
├── CandidateServlet?action=edit&id=?         // 수정 폼
└── CandidateServlet?action=delete&id=?       // 삭제

데이터 의존성:
├── List<Candidate> candidates                // 서블릿에서 전달받은 지원자 목록
├── session.getAttribute("username")          // 로그인 사용자 정보
└── request.getAttribute("message")           // 성공/오류 메시지

네비게이션 의존성:
├── main.jsp                                  // 메인 대시보드로 이동
├── candidate_form.jsp                        // 등록/수정 폼으로 이동
└── candidate_detail.jsp                      // 상세 페이지로 이동
```

#### 📝 candidate_form.jsp (지원자 등록/수정 폼)
```jsp
서블릿 의존성:
├── CandidateServlet?action=save              // 저장 처리
├── CandidateServlet?action=update            // 수정 처리
└── enctype="multipart/form-data"             // 파일 업로드

폼 데이터 의존성:
├── Candidate candidate                       // 수정 시 기존 데이터
├── String[] teams                            // 지원팀 목록
└── 파일 업로드 제약사항 (크기, 타입)

검증 의존성:
├── 이메일 중복 검사 (클라이언트/서버 측)
├── 필수 필드 검증 (name, email)
└── 파일 타입 검증 (pdf, doc, hwp)
```

#### 📊 main.jsp (메인 대시보드)
```jsp
메뉴 시스템 의존성:
├── candidates.jsp                            // 1. 지원자 관리
├── interview_schedules.jsp                   // 2. 인터뷰 일정 관리  
├── interview_questions.jsp                   // 3. 질문/평가 항목 관리
├── interview_results.jsp                     // 4. 인터뷰 결과 기록/관리
├── statistics.jsp                            // 5. 통계 및 리포트
├── interviewer_list.jsp                      // 6. 면접관(관리자) 관리
├── notifications.jsp                         // 7. 알림 및 히스토리
└── system_settings.jsp                       // 8. 시스템 설정

스타일 의존성:
├── GitHub 테마 색상 팔레트                   // #f0f0f0, #d0d7de, #0078d4
├── container → top-bar → main-dashboard 구조
└── btn-primary, btn-secondary 버튼 스타일
```

---

## 6. 🛡️ 보안 필터 의존성 분석

### 6.1 AuthenticationFilter.java 의존성
```java
// 🔒 모든 요청을 가로채는 전역 필터

애노테이션 의존성:
├── @WebFilter("/*")                          // 모든 URL 패턴에 적용
└── javax.servlet.annotation.WebFilter

필터 의존성:
├── javax.servlet.Filter                      // 필터 인터페이스 구현
├── javax.servlet.FilterChain                 // 다음 필터로 전달
├── javax.servlet.http.HttpServletRequest     // 요청 객체
├── javax.servlet.http.HttpServletResponse    // 응답 객체
└── javax.servlet.http.HttpSession           // 세션 검증

예외 경로 (필터 우회):
├── /login                                    // 로그인 페이지
├── /register                                 // 회원가입 페이지
├── *.css                                     // CSS 파일
├── *.js                                      // JavaScript 파일
├── *.png, *.jpg, *.gif                       // 이미지 파일
└── /favicon.ico                              // 파비콘

보안 검증 로직:
1. session.getAttribute("username") 확인
2. username이 null이면 login.jsp로 리다이렉트
3. AJAX 요청은 401 Unauthorized 응답
4. 정상 사용자는 다음 필터/서블릿으로 전달
```

---

## 7. 🧪 테스트 의존성 분석

### 7.1 테스트 클래스 공통 의존성
```java
// 🔬 모든 테스트 클래스의 공통 의존성

JUnit 의존성:
├── org.junit.Test                            // @Test 애노테이션
├── org.junit.Before                          // @Before 애노테이션 (초기화)
├── org.junit.After                           // @After 애노테이션 (정리)
├── org.junit.Assert                          // assertEquals, assertTrue 등
└── org.junit.Assert.fail                     // 강제 실패

프로젝트 의존성:
├── 테스트 대상 DAO 클래스                    // 예: CandidateDAO
├── 테스트 대상 Model 클래스                  // 예: Candidate
├── com.example.util.DatabaseUtil            // DB 연결
└── java.sql.*                                // JDBC API

테스트 환경 설정:
├── PostgreSQL 테스트 데이터베이스            // promptsharing (같은 DB 사용)
├── 테스트 데이터 준비/정리                   // @Before, @After
└── UTF-8 인코딩 설정                         // test-maven-utf8.cmd
```

### 7.2 테스트별 특화 의존성

#### 🧪 CandidateDAOTest.java (5개 테스트)
```java
테스트 시나리오 의존성:
├── testCreateCandidate()                     // 지원자 생성 테스트
│   ├── Candidate 객체 생성
│   ├── CandidateDAO.createCandidate() 호출
│   └── DB 저장 확인
├── testGetCandidateById()                    // 지원자 조회 테스트  
│   ├── 기존 지원자 ID로 조회
│   └── 반환 데이터 검증
├── testUpdateCandidate()                     // 지원자 수정 테스트
│   ├── 기존 지원자 정보 수정
│   └── 변경사항 DB 반영 확인
├── testDeleteCandidate()                     // 지원자 삭제 테스트
│   ├── 지원자 삭제 실행
│   └── DB에서 제거 확인
└── testEmailDuplicateCheck()                 // 이메일 중복 검사
    ├── 동일 이메일로 지원자 생성 시도
    └── 예외 발생 확인
```

#### 🧪 InterviewResultDAOTest.java (13개 테스트)
```java
복합 의존성 테스트:
├── Candidate 데이터 사전 준비                // 외래키 의존성
├── InterviewSchedule 데이터 준비 (선택적)    // 외래키 의존성
├── InterviewResult 생성/조회/수정/삭제       // 기본 CRUD
├── 평균 점수 계산 테스트                     // 집계 함수 테스트
└── 복합 조건 검색 테스트                     // 다중 조건 쿼리
```

---

## 8. 📁 CSS 및 정적 리소스 의존성

### 8.1 CSS 파일 의존성
```css
/* 📎 CSS 파일간 의존성 구조 */

css/common.css                                /* 기본 공통 스타일 */
├── 전역 리셋 (body, h1, h2, p, table 등)
├── GitHub 테마 색상 변수 정의
├── container, top-bar, main-dashboard 레이아웃
└── btn-primary, btn-secondary 버튼 스타일

css/style.css                                 /* 페이지별 특화 스타일 */  
├── common.css 상속 (위에 추가로 로드)
├── 폼 스타일링 (input, select, textarea)
├── 테이블 스타일링 (candidates, schedules 등)
└── 모달 및 팝업 스타일
```

### 8.2 JSP에서 CSS 로드 순서
```html
<!-- 🎨 모든 JSP에서 일관된 CSS 로드 순서 -->
<link rel="stylesheet" href="css/common.css">  <!-- 1순위: 공통 스타일 -->
<link rel="stylesheet" href="css/style.css">   <!-- 2순위: 특화 스타일 -->

<!-- CSS 캐싱 최적화 (향후 적용 가능) -->
<link rel="stylesheet" href="css/common.css?v=1.0">
<link rel="stylesheet" href="css/style.css?v=1.0">
```

---

## 9. 🔧 빌드 및 배포 의존성

### 9.1 Maven 빌드 의존성
```xml
<!-- 🏗️ pom.xml의 빌드 플러그인 의존성 -->

maven-compiler-plugin:3.11.0
├── Java 8 소스/타겟 설정
├── UTF-8 인코딩
└── 컴파일러 경고 옵션 (-Xlint:deprecation, -Xlint:unchecked)

maven-war-plugin:3.4.0  
├── WAR 패키징 설정
├── Tomcat 배포 최적화
└── 웹 리소스 복사 (JSP, CSS, JS)

maven-surefire-plugin:3.1.2
├── 테스트 실행 설정
├── UTF-8 인코딩 보장
└── Windows 환경 최적화

maven-resources-plugin:3.3.1
├── 리소스 복사 자동화
├── UTF-8 인코딩 설정
└── JSP 파일 자동 복사
```

### 9.2 Tomcat 배포 의존성
```
🚀 Tomcat 배포 시 의존성 구조:

C:\tomcat9\webapps\PromptSharing5_JSP\
├── WEB-INF\
│   ├── web.xml                               # 서블릿 매핑 설정
│   ├── classes\                              # 컴파일된 Java 클래스
│   │   └── com\example\                      # 패키지 구조 유지
│   └── lib\                                  # 의존성 JAR 파일
│       ├── postgresql-42.7.7.jar            # PostgreSQL JDBC
│       └── jbcrypt-0.4.jar                   # BCrypt 암호화
├── *.jsp                                     # JSP 파일들
├── css\                                      # CSS 파일들
└── uploads\                                  # 업로드 디렉토리
    ├── resumes\                              # 이력서 파일
    └── temp\                                 # 임시 파일
```

### 9.3 자동화 스크립트 의존성
```bash
# 🤖 자동화 스크립트들의 의존성 체인

mvnw.cmd                                      # Maven Wrapper
├── Maven 3.9+ 설치 확인/다운로드
├── Java 8+ JDK 환경 변수 확인
└── pom.xml 읽어서 빌드 실행

test-maven-utf8.cmd                           # UTF-8 테스트
├── PowerShell 인코딩 설정
├── MAVEN_OPTS 환경변수 설정
├── mvnw.cmd test 실행
└── 한글 출력 확인

safety-backup.cmd                             # 안전 백업
├── 현재 날짜/시간 기반 백업 디렉토리 생성
├── 주요 파일들 복사 (Java, JSP, SQL)
└── Git commit 실행 (선택적)

emergency-recovery.cmd                        # 긴급 복구
├── 최신 백업 디렉토리 확인
├── 손상된 파일 복구
└── Tomcat 재시작
```

---

## 10. 🔍 의존성 문제 해결 가이드

### 10.1 컴파일 에러 해결
```java
// ❌ 자주 발생하는 의존성 문제들

1. ClassNotFoundException
├── 원인: WEB-INF/lib에 필요한 JAR 파일 누락
├── 해결: Maven 의존성 확인 후 .\mvnw.cmd compile 재실행
└── 확인: WEB-INF/lib 디렉토리에 JAR 파일 존재 여부

2. NoSuchMethodError  
├── 원인: 라이브러리 버전 충돌 또는 메서드 시그니처 변경
├── 해결: 메서드명과 파라미터 타입 확인
└── 예방: 기존 코드 변경 시 의존하는 클래스들도 함께 검토

3. Import 에러
├── 원인: 패키지 구조 변경 또는 클래스명 변경
├── 해결: IDE의 자동 import 기능 활용
└── 확인: src/com/example 패키지 구조 일치 여부
```

### 10.2 런타임 에러 해결
```java
// ⚡ 실행 시간에 발생하는 의존성 문제들

1. SQLException - Connection 실패
├── 원인: DatabaseUtil.java의 DB 연결 정보 오류
├── 해결: PostgreSQL 서버 실행 상태 확인
└── 설정: URL, username, password 재확인

2. ServletException - 매핑 오류
├── 원인: web.xml 또는 @WebServlet 애노테이션 충돌
├── 해결: URL 매핑 중복 확인
└── 디버깅: Tomcat 로그에서 매핑 정보 확인

3. SessionException - 인증 실패
├── 원인: AuthenticationFilter와 JSP 세션 검증 불일치
├── 해결: 세션 attribute명 통일 ("username")
└── 테스트: 로그인 후 페이지 접근 확인
```

### 10.3 성능 문제 해결
```java
// 🚀 의존성으로 인한 성능 문제들

1. DB 연결 과다 생성
├── 원인: DatabaseUtil.getConnection()을 매번 새로 생성
├── 해결: HikariCP 등 연결 풀 도입 검토
└── 모니터링: DB 연결 수 추적

2. 메모리 누수
├── 원인: ResultSet, Statement, Connection 자원 해제 누락
├── 해결: try-with-resources 문법 활용
└── 점검: 모든 DAO 메서드의 자원 해제 확인

3. 과도한 쿼리 실행
├── 원인: N+1 문제 또는 비효율적인 조인
├── 해결: 쿼리 최적화 및 인덱스 활용
└── 분석: PostgreSQL EXPLAIN을 통한 실행 계획 확인
```

---

## 11. 📋 의존성 관리 권장사항

### 11.1 코드 작성 시 권장사항
```java
// ✅ 좋은 의존성 관리 패턴

1. 단일 책임 원칙 준수
├── 각 클래스는 하나의 명확한 역할만 담당
├── DAO는 데이터베이스 작업만, Servlet은 HTTP 처리만
└── Model은 데이터 전송만 담당 (비즈니스 로직 포함 금지)

2. 의존성 역전 원칙 적용  
├── 구체적인 구현체보다는 인터페이스에 의존
├── DatabaseUtil.getConnection() 추상화 레벨 유지
└── 향후 Spring DI 도입 시 쉬운 전환 가능

3. 순환 의존성 방지
├── A → B → C → A 형태의 순환 참조 금지
├── 패키지 레벨에서 의존성 방향 정의
└── util → model → dao → controller → view 순서 유지
```

### 11.2 테스트 의존성 관리
```java
// 🧪 테스트 코드의 의존성 관리

1. 테스트 격리 보장
├── 각 테스트는 독립적으로 실행 가능해야 함
├── @Before에서 테스트 데이터 준비
└── @After에서 테스트 데이터 정리

2. 모의 객체(Mock) 활용 검토
├── 외부 의존성(DB, 네트워크) 제거 고려
├── Mockito 등 Mock 프레임워크 도입 검토
└── 단위 테스트와 통합 테스트 구분

3. 테스트 데이터 관리
├── 테스트용 고정 데이터셋 준비
├── 실제 운영 데이터와 분리
└── 테스트 환경 전용 설정 파일 고려
```

### 11.3 향후 개선 방향
```java
// 🔮 의존성 관리 발전 방향

단기 개선 (1-3개월):
├── HikariCP 연결 풀 도입                     // DB 연결 효율화
├── Log4j2/Logback 로깅 프레임워크            // 로깅 체계화
├── Maven profile 분리                      // 개발/운영 환경 구분
└── 의존성 보안 취약점 스캔                   // OWASP Dependency Check

중기 개선 (3-6개월):
├── Spring Framework 도입                   // 의존성 주입 (DI)
├── JPA/MyBatis ORM 프레임워크               // 데이터 액세스 추상화
├── REST API 설계                           // 프론트엔드 분리
└── Docker 컨테이너화                        // 환경 의존성 해결

장기 개선 (6-12개월):
├── 마이크로서비스 아키텍처                   // 서비스별 의존성 분리
├── GraphQL API                             // 유연한 데이터 조회
├── 이벤트 기반 아키텍처                     // 느슨한 결합 구현
└── 클라우드 네이티브 설계                   // 인프라 의존성 최소화
```

---

## 📊 결론

### 현재 의존성 구조의 장점
✅ **명확한 계층 분리**: MVC 패턴의 체계적인 구현
✅ **단순한 의존성**: 외부 라이브러리 최소화로 안정성 확보
✅ **표준 준수**: Java EE 표준 기술 활용으로 호환성 보장
✅ **테스트 용이성**: 각 계층별 독립적인 테스트 가능

### 개선이 필요한 영역  
🔄 **연결 풀 부재**: 매번 새로운 DB 연결 생성으로 성능 제약
🔄 **하드코딩 의존성**: 일부 문자열 상수의 하드코딩 (면접관명 등)
🔄 **로깅 부족**: System.out.println 기반의 단순 로깅
🔄 **설정 외부화**: DB 연결 정보 등 설정의 외부화 필요

### 권장 개선 순서
1️⃣ **HikariCP 연결 풀 도입** → 성능 개선 우선
2️⃣ **설정 파일 외부화** → properties/yaml 파일 활용
3️⃣ **로깅 프레임워크 도입** → 구조화된 로깅 체계
4️⃣ **Spring Framework 검토** → 의존성 주입 및 설정 관리

---

**📅 문서 작성일**: 2024년 기준
**🔄 업데이트 주기**: 주요 코드 변경 시 의존성 분석 갱신  
**📞 의존성 문의**: 코드 변경 전 의존성 영향도 검토 필수 