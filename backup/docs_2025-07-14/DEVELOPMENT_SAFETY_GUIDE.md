# 🛡️ 개발 안전성 가이드

## 📋 목적
- **90% 완성된 프로그램이 갑자기 동작하지 않는 문제 예방**
- **안전한 개발 환경 구축 및 유지**
- **변경사항으로 인한 기존 기능 손상 방지**

---

## 🚨 **절대 원칙: 변경 전 필수 작업**

### **1단계: Git 상태 확인 및 커밋**
```cmd
# 현재 변경사항 확인
git status

# 변경사항이 있으면 즉시 커밋
git add .
git commit -m "안정 버전 - 90% 완성 상태 백업"

# 브랜치 생성 (선택사항)
git branch backup-stable-version
```

### **2단계: 테스트 실행**
```cmd
# Maven 테스트로 현재 상태 검증
.\test-maven.cmd

# 모든 메뉴 수동 테스트
# 1-8번 메뉴 각각 클릭하여 정상 동작 확인
```

### **3단계: 백업 디렉토리 생성**
```cmd
# 중요 파일들 백업
copy src\com\example\controller\*.java backup\
copy *.jsp backup\
copy mvnw.cmd backup\mvnw.cmd.backup
```

---

## ⚠️ **위험한 작업 시 추가 예방책**

### **A. 대량 파일 수정 시 (PowerShell, 정규식 등)**

**❌ 절대 금지:**
```cmd
# 한글이 포함된 파일에 PowerShell 치환 명령어 사용 금지
powershell -Command "(Get-Content 'file.java') -replace 'pattern', 'replacement'"
```

**✅ 안전한 방법:**
1. **파일별 개별 수정** - `edit_file` 또는 `search_replace` 도구 사용
2. **UTF-8 명시적 지정** - 인코딩 손상 방지
3. **1개 파일씩 수정 후 즉시 테스트**

### **B. 서블릿 코드 수정 시**

**필수 절차:**
1. **의존성 확인**: 수정할 메소드가 다른 곳에서 호출되는지 확인
2. **점진적 수정**: 한 번에 1개 메소드만 수정
3. **즉시 컴파일**: `.\mvnw.cmd compile`
4. **배포 확인**: `dir "WEB-INF\classes\com\example\controller"`

### **C. URL 매핑 및 경로 수정 시**

**체크리스트:**
- [ ] 절대 경로 사용 (`${pageContext.request.contextPath}`)
- [ ] 상대 경로 중복 확인
- [ ] 서블릿 URL 패턴과 JSP 링크 일치 확인
- [ ] 테스트 환경에서 먼저 검증

---

## 🔍 **일일 개발 안전 체크리스트**

### **개발 시작 시 (아침)**
- [ ] Git 상태 정상 확인
- [ ] Tomcat 정상 구동 확인
- [ ] 주요 메뉴 5개 정상 동작 확인
- [ ] 데이터베이스 연결 확인

### **변경사항 적용 시 (매번)**
- [ ] 변경 범위 명확히 정의
- [ ] 백업 생성 (Git commit)
- [ ] 1개씩 점진적 수정
- [ ] 수정 후 즉시 테스트
- [ ] 문제 발생 시 즉시 롤백

### **개발 종료 시 (퇴근 전)**
- [ ] 모든 변경사항 Git 커밋
- [ ] 테스트 실행 및 통과 확인
- [ ] 내일 작업 계획 문서화
- [ ] 안정 버전 태그 생성 (주요 완성 시점)

---

## 🚀 **긴급 복구 프로세스**

### **문제 발생 시 즉시 실행 순서**

**1단계: 피해 범위 파악**
```cmd
# 컴파일 상태 확인
.\mvnw.cmd compile

# 서블릿 배포 상태 확인
dir "WEB-INF\classes\com\example\controller"

# Git 변경사항 확인
git status
```

**2단계: 즉시 롤백**
```cmd
# 변경사항 취소 (커밋 전)
git checkout -- .

# 특정 파일만 복구
git checkout -- src/com/example/controller/FileName.java

# 백업에서 복구
copy backup\FileName.java src\com\example\controller\
```

**3단계: 검증 및 재시작**
```cmd
# 컴파일 재시도
.\mvnw.cmd compile

# Tomcat 재시작
C:\tomcat9\bin\startup.bat

# 주요 기능 테스트
```

---

## 💡 **예방을 위한 도구 및 스크립트**

### **안전 백업 스크립트 (safety-backup.cmd)**
```cmd
@echo off
echo [INFO] 안전 백업 생성 중...
git add .
git commit -m "자동 안전 백업 - %date% %time%"
copy src\com\example\controller\*.java backup\
echo [INFO] 백업 완료!
```

### **빠른 상태 체크 스크립트 (quick-check.cmd)**
```cmd
@echo off
echo [체크] Git 상태...
git status --porcelain
echo [체크] 컴파일 상태...
.\mvnw.cmd compile
echo [체크] 서블릿 배포 상태...
dir "WEB-INF\classes\com\example\controller" /B
```

---

## 📚 **학습된 교훈**

### **오늘 발생한 문제들로부터**
1. **PowerShell 대량 치환의 위험성** - 한글 파일에 절대 사용 금지
2. **컴파일 실패의 연쇄 효과** - 1개 파일 손상이 전체 시스템 마비
3. **상대 경로의 복잡성** - 절대 경로 사용 원칙
4. **백업의 중요성** - Git + 파일 백업 이중 보안

### **성공적인 복구 경험**
- **체계적 진단**: 소스 vs 컴파일 파일 비교로 정확한 원인 파악
- **단계적 해결**: 한글 깨짐 → 컴파일 오류 → 메소드 수정 순서
- **안전한 복구**: Git 백업과 파일 재생성 활용

---

## 🎯 **결론: 안전한 개발을 위한 3대 원칙**

1. **🔒 변경 전 반드시 백업** - Git commit + 파일 백업
2. **🔍 점진적 수정과 즉시 테스트** - 1개씩 수정하고 바로 검증
3. **🚨 문제 발생 시 즉시 롤백** - 고민하지 말고 바로 이전 상태로 복구

**💡 기억하세요: "완벽한 코드보다 안전한 개발이 더 중요합니다!"** 