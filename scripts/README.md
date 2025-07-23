# 📁 Scripts 폴더 - 프로젝트 스크립트 모음

이 폴더에는 ATS 프로젝트의 모든 유틸리티 스크립트가 정리되어 있습니다.

---

## 🚀 Maven 빌드 스크립트

### 📦 **build-maven.cmd**
- **목적**: 전체 프로젝트 컴파일 및 빌드
- **사용법**: `.\scripts\build-maven.cmd`
- **기능**: 
  - Tomcat 자동 종료
  - Maven clean compile
  - 빌드 결과 검증

### 🌏 **compile-maven-utf8.cmd** ⭐ NEW
- **목적**: UTF-8 인코딩으로 Maven 컴파일 실행
- **사용법**: `.\scripts\compile-maven-utf8.cmd`
- **기능**: 
  - Windows 콘솔 UTF-8 설정 (chcp 65001)
  - PowerShell UTF-8 출력 설정
  - Maven UTF-8 환경변수 강화
  - Tomcat 자동 종료 후 컴파일
  - **한글 깨짐 완전 해결** ✅

### 🚀 **safe-compile.cmd** ⭐ BUILD & TEST
- **목적**: Maven 빌드 및 테스트 (프로덕션 DB 사용)
- **사용법**: `.\scripts\safe-compile.cmd`
- **기능**: 
  - 전체 빌드 및 테스트 실행 (`mvn clean compile test`)
  - 프로덕션 DB에서 20개 JUnit 테스트 수행
  - UTF-8 인코딩 지원
  - Tomcat 자동 종료 후 빌드
  - **컴파일 + 테스트 통합 실행** 🚀

### 🧪 **test-maven.cmd**
- **목적**: JUnit 테스트 실행
- **사용법**: `.\scripts\test-maven.cmd`
- **기능**: 50개 테스트 케이스 실행

### 🌏 **test-maven-utf8.cmd**
- **목적**: UTF-8 인코딩으로 Maven 테스트 실행
- **사용법**: `.\scripts\test-maven-utf8.cmd`
- **기능**: 한글 깨짐 없는 테스트 실행

### 📦 **package-maven.cmd**
- **목적**: WAR 파일 패키징
- **사용법**: `.\scripts\package-maven.cmd`
- **출력**: `target/ats-1.3.0.war`

### 🔄 **maven-all.cmd**
- **목적**: 전체 Maven 라이프사이클 실행
- **사용법**: `.\scripts\maven-all.cmd`
- **기능**: clean → compile → test → package

---

## 🛠️ 유틸리티 스크립트

### 🛡️ **safety-backup.cmd**
- **목적**: 개발 전 안전 백업 생성
- **사용법**: `.\scripts\safety-backup.cmd`
- **기능**: Git 백업 + 파일 백업

### ⚡ **quick-check.cmd**
- **목적**: 프로젝트 상태 빠른 진단
- **사용법**: `.\scripts\quick-check.cmd`
- **기능**: 
  - Git 상태 확인
  - Maven 설정 검증
  - 필수 파일 확인

### 🚨 **emergency-recovery.cmd**
- **목적**: 긴급 상황 시 프로젝트 복구
- **사용법**: `.\scripts\emergency-recovery.cmd`
- **기능**: 최근 백업으로 즉시 복구

### 📁 **create-upload-dirs.cmd**
- **목적**: 업로드 디렉토리 생성
- **사용법**: `.\scripts\create-upload-dirs.cmd`
- **기능**: uploads/resumes/, uploads/temp/ 생성

---

## 💬 채팅 백업 스크립트

### 📝 **install-chat-backup-extensions.cmd**
- **목적**: Cursor AI 채팅 백업 Extension 설치
- **사용법**: `.\scripts\install-chat-backup-extensions.cmd`
- **기능**: 
  - Cursor Chat Keeper 설치
  - SpecStory 설치  
  - CursorChat Downloader 설치

---

## 🗄️ 데이터베이스 스크립트

### 🛠️ **테스트 데이터베이스 생성 (2단계)**

**sql/create_test_database_step1.sql**
- **용도**: promptsharing_test 데이터베이스 생성 (1단계)
- **실행**: promptsharing DB에서 실행
- **명령어**: `psql -d promptsharing -U postgres`
- **주의**: 트랜잭션 블록 없이 개별 명령어로 실행

**sql/create_test_database_step2.sql**
- **용도**: 테이블 생성 및 테스트 데이터 삽입 (2단계)
- **실행**: promptsharing_test DB에서 실행
- **명령어**: `psql -d promptsharing_test -U postgres`
- **목적**: 프로덕션 DB 보호를 위한 완전 분리된 테스트 환경

### ⚙️ **setup-postgres-mcp.cmd**
- **목적**: PostgreSQL MCP 도구 설정
- **사용법**: `.\scripts\setup-postgres-mcp.cmd`
- **기능**: PostgreSQL MCP 환경 구성

---

## 📋 스크립트 실행 순서 (권장)

### 🔄 **일반 개발 워크플로우**
```cmd
# 1. 개발 전 백업
.\scripts\safety-backup.cmd

# 2. 코드 변경 후 빌드
.\scripts\build-maven.cmd

# 3. 테스트 실행 (UTF-8)
.\scripts\test-maven-utf8.cmd

# 4. 문제 발생 시 상태 확인
.\scripts\quick-check.cmd
```

### 🚨 **긴급 복구 시**
```cmd
# 문제 발생 즉시
.\scripts\emergency-recovery.cmd
```

### 📦 **배포 준비 시**
```cmd
# 전체 라이프사이클 실행
.\scripts\maven-all.cmd
```

---

## 💡 주요 참고사항

1. **Windows 환경 최적화**: 모든 스크립트는 Windows PowerShell 환경에서 테스트됨
2. **UTF-8 지원**: 한글 텍스트 처리를 위한 인코딩 설정 포함
3. **Tomcat 연동**: Maven 빌드 시 Tomcat 자동 관리
4. **안전성 우선**: 백업 및 복구 기능 강화
5. **자동화**: 반복 작업의 자동화로 개발 효율성 증대

---

**🚀 Happy Coding!** 문제 발생 시 emergency-recovery.cmd를 사용하세요. 