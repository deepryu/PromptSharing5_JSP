# 🌐 한글 깨짐 방지 가이드 (Korean Encoding Guide)

## 📋 **개요**
GitHub 푸시 시 한글이 깨져 보이는 문제를 완전히 해결하기 위한 종합 가이드입니다.

---

## ❌ **문제 현상**

### **GitHub에서 보이는 한글 깨짐**
```
정상: "지원자 관리", "인터뷰 일정"
깨짐: "吏?먯옄 愿由?", "?댄젪聊쇨뱾"
```

### **주요 원인**
1. **Git 인코딩 설정 부재**: UTF-8 설정 누락
2. **커밋 메시지 인코딩**: PowerShell/CMD 인코딩 불일치  
3. **파일 저장 방식**: UTF-8 BOM 포함 저장
4. **Windows 콘솔 인코딩**: CP949 기본 사용

---

## ✅ **완전 해결책**

### **1단계: 자동 설정 스크립트 실행** (권장)

```bash
# 한글 깨짐 방지 종합 설정 실행
.\scripts\fix-korean-encoding.cmd
```

**적용되는 설정:**
- ✅ Windows 콘솔 UTF-8 (CP65001)
- ✅ PowerShell UTF-8 출력 인코딩
- ✅ Git 한글 파일명 깨짐 방지
- ✅ Git 커밋 메시지 UTF-8
- ✅ Maven UTF-8 환경변수

### **2단계: 수동 설정 (고급 사용자)**

#### **Git 인코딩 설정**
```bash
git config core.quotepath false           # 한글 파일명 깨짐 방지
git config i18n.commitencoding utf-8      # 커밋 메시지 UTF-8
git config i18n.logoutputencoding utf-8   # 로그 출력 UTF-8
git config core.precomposeunicode true    # 유니코드 정규화
git config core.autocrlf true             # 줄바꿈 자동 변환
```

#### **PowerShell UTF-8 설정**
```powershell
chcp 65001
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

#### **Maven UTF-8 환경변수**
```bash
set MAVEN_OPTS=-Dfile.encoding=UTF-8 -Dconsole.encoding=UTF-8 -Dproject.build.sourceEncoding=UTF-8
```

---

## 🚀 **GitHub 푸시 안전 절차** (업데이트됨)

### **필수 순서**
```bash
# 1단계: 한글 깨짐 방지 설정
.\scripts\fix-korean-encoding.cmd

# 2단계: 파일 상태 확인
cmd /c "git status --short"

# 3단계: 파일 추가
git add .

# 4단계: 영어 커밋 메시지 (필수!)
git commit -m "Update Java servlets and UI improvements"
git commit -m "Fix encoding issues and layout problems"
git commit -m "Add new features and security enhancements"

# 5단계: 안전한 푸시
git push origin main --no-verify
```

### **⚠️ 절대 금지사항**
```bash
❌ git commit -m "한글 커밋 메시지"  # 깨짐 위험
❌ git status                      # 긴 출력으로 터미널 버퍼 문제
❌ 한글 파일명 사용                 # 파일명 깨짐 위험
```

### **✅ 권장사항**
```bash
✅ git commit -m "English commit message"
✅ cmd /c "git status --short"
✅ 영어 파일명 사용
✅ UTF-8 BOM 없이 파일 저장
```

---

## 📁 **파일 저장 방법**

### **JSP 파일 저장 시**
1. **인코딩**: UTF-8 (BOM 없음)
2. **줄바꿈**: Windows (CRLF)
3. **에디터 설정**: VS Code → 하단 상태바에서 "UTF-8" 확인

### **Java 파일 저장 시**
1. **인코딩**: UTF-8 (BOM 없음)
2. **소스 인코딩**: Maven에서 자동 처리
3. **컴파일 인코딩**: pom.xml에서 UTF-8 설정됨

---

## 🔧 **영구 설정 방법**

### **시스템 환경변수 추가** (Windows)
1. **Win+R** → `sysdm.cpl` → **고급** → **환경변수**
2. **시스템 변수 추가**:
   - `MAVEN_OPTS`: `-Dfile.encoding=UTF-8 -Dconsole.encoding=UTF-8`
   - `JAVA_TOOL_OPTIONS`: `-Dfile.encoding=UTF-8`

### **PowerShell 프로필 설정**
```powershell
# PowerShell 프로필 파일에 추가
notepad $PROFILE

# 추가할 내용:
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

---

## 📊 **검증 방법**

### **설정 확인**
```bash
# Git 설정 확인
git config --list | findstr -i encoding

# 콘솔 인코딩 확인  
chcp

# PowerShell 인코딩 확인
[Console]::OutputEncoding
```

### **테스트 푸시**
```bash
# 테스트 파일 생성
echo "테스트" > test-korean.txt

# 커밋 및 푸시
git add test-korean.txt
git commit -m "Test Korean encoding fix"
git push origin main

# GitHub에서 확인 후 테스트 파일 삭제
git rm test-korean.txt
git commit -m "Remove test file"
git push origin main
```

---

## 🚨 **트러블슈팅**

### **문제 1: 여전히 커밋 메시지 깨짐**
```bash
해결책: 영어 커밋 메시지 사용 (완전한 해결책)
git commit -m "Fix UI layout and encoding issues"
```

### **문제 2: PowerShell 명령어 멈춤**
```bash
해결책: CMD 우회 방법 사용
cmd /c "git status --short"
cmd /c "git add ."
```

### **문제 3: 파일명 여전히 깨짐**
```bash
해결책: Git 설정 재확인
git config core.quotepath false
```

---

## 📚 **참고 자료**

### **관련 문서**
- `docs/PROJECT_GUIDE.md` - Git 푸시 정책
- `docs/ERROR_GUIDE.md` - 에러 해결 사례
- `scripts/fix-korean-encoding.cmd` - 자동 설정 스크립트

### **Windows 한글 인코딩 정보**
- **CP949**: Windows 기본 한글 인코딩
- **CP65001**: Windows UTF-8 인코딩
- **UTF-8 BOM**: Byte Order Mark (GitHub에서 문제 발생 가능)

---

## ⭐ **권장 워크플로우**

### **새 개발 세션 시작 시**
```bash
1. .\scripts\fix-korean-encoding.cmd     # 인코딩 설정
2. 파일 수정 작업
3. .\mvnw.cmd compile (Java 파일 변경 시)
4. 브라우저 테스트
5. git add . 
6. git commit -m "English message"
7. git push origin main --no-verify
```

### **매일 권장 습관**
- ✅ 커밋 메시지는 영어로 작성
- ✅ 푸시 전 UTF-8 설정 확인  
- ✅ JSP 파일 UTF-8 BOM 없이 저장
- ✅ 한글 파일명 사용 금지

---

**📅 문서 생성일**: 2025-01-23  
**🔄 마지막 업데이트**: GitHub 한글 깨짐 완전 해결  
**✅ 검증 상태**: Windows 10/PowerShell 7 환경 테스트 완료 