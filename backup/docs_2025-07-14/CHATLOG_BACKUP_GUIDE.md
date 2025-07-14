# 📚 채팅 기록 백업 가이드

## 🎯 목적
- 개발 과정에서 중요한 채팅 기록 보존
- 문제 해결 과정 및 결정사항 추적
- 프로젝트 지식 축적 및 재사용

## 📋 현재 채팅 기록 상태
- **파일**: `docs/chatlog.md` (66KB, 2,098줄)
- **내용**: 이전 개발 세션들의 상세 기록
- **백업 주기**: 매 개발 세션 후 권장

## 🔄 자동 백업 방법 (권장)

### 1. 자동 백업 스크립트 실행
```cmd
# 채팅 기록 자동 백업 실행
.\backup-chatlog.cmd

# 백업 위치 확인
dir backup\chatlog\
```

### 2. 백업 결과물
- `chatlog_YYYY-MM-DD_HH-MM-SS.md` - 채팅 기록 시간별 백업
- `docs_YYYY-MM-DD\` - 전체 문서 백업
- `backup_summary_YYYY-MM-DD.txt` - 백업 요약 정보

## 📝 수동 백업 방법

### 1. 즉시 백업 (중요 내용 발생 시)
```cmd
# 현재 채팅 기록 즉시 백업
copy docs\chatlog.md backup\chatlog\chatlog_emergency_%date%.md

# 전체 문서 백업
xcopy docs\* backup\docs_emergency_%date%\ /Y /Q
```

### 2. 브라우저 기반 백업
1. **Cursor 채팅 히스토리**: 
   - `Ctrl+H` → 채팅 히스토리 열기
   - 원하는 세션 선택 → 복사 → 텍스트 파일로 저장

2. **ChatGPT/Claude 등**:
   - 대화 내용 전체 선택 → 복사
   - `backup\chatlog\manual_backup_YYYY-MM-DD.md`로 저장

### 3. 스크린샷 백업
```cmd
# 스크린샷 저장 폴더 생성
mkdir backup\screenshots\%date%

# 중요 화면 스크린샷 → backup\screenshots\에 저장
```

## 🛡️ 다중 백업 전략

### 1. 로컬 백업 (기본)
- **위치**: `backup\chatlog\`
- **주기**: 매 개발 세션 후
- **보존 기간**: 무제한

### 2. GitHub 백업 (권장)
```cmd
# Git에 커밋하여 원격 백업
git add docs\chatlog.md
git commit -m "Update chatlog with latest development session"
git push origin main
```

### 3. 클라우드 백업 (추가 보안)
- **Google Drive**: `backup\chatlog\` 폴더를 Google Drive에 동기화
- **OneDrive**: Windows 내장 OneDrive 연동
- **Dropbox**: 자동 동기화 설정

## 📊 백업 파일 관리

### 1. 파일명 규칙
```
chatlog_YYYY-MM-DD_HH-MM-SS.md     # 시간별 백업
chatlog_emergency_YYYY-MM-DD.md    # 긴급 백업
chatlog_milestone_v1.0.md          # 마일스톤 백업
```

### 2. 보관 주기
- **일일 백업**: 7일간 보관
- **주간 백업**: 1개월간 보관
- **월간 백업**: 1년간 보관
- **마일스톤 백업**: 영구 보관

### 3. 정리 스크립트
```cmd
# 7일 이상 된 일일 백업 파일 정리
forfiles /p backup\chatlog /s /m *.md /d -7 /c "cmd /c del @path"
```

## 🔍 백업 검증

### 1. 백업 파일 확인
```cmd
# 최신 백업 파일 확인
dir backup\chatlog\ /OD

# 백업 파일 크기 확인
dir backup\chatlog\*.md /S
```

### 2. 복구 테스트
```cmd
# 백업 파일에서 복구 테스트
copy backup\chatlog\chatlog_latest.md docs\chatlog_test.md
```

## 🚨 긴급 복구 절차

### 1. 채팅 기록 손실 시
```cmd
# 1. 가장 최근 백업 파일 찾기
dir backup\chatlog\ /OD

# 2. 백업 파일 복구
copy backup\chatlog\chatlog_YYYY-MM-DD_HH-MM-SS.md docs\chatlog.md

# 3. Git에서 복구 (필요시)
git checkout HEAD~1 -- docs\chatlog.md
```

### 2. 전체 문서 손실 시
```cmd
# 전체 docs 폴더 복구
xcopy backup\docs_YYYY-MM-DD\* docs\ /Y /Q /E
```

## 💡 권장 사항

### 1. 백업 타이밍
- **개발 세션 시작 전**: 이전 기록 백업
- **중요 결정 후**: 즉시 백업
- **개발 세션 종료 후**: 전체 백업

### 2. 백업 내용
- 채팅 기록 (`chatlog.md`)
- 프로젝트 문서 (`docs/` 폴더 전체)
- 설정 파일 (`pom.xml`, `web.xml`)
- Git 기록 (`git log`, `git status`)

### 3. 백업 확인
- 백업 파일 크기 확인
- 주요 내용 포함 여부 확인
- 복구 테스트 정기 실행

## 🔧 트러블슈팅

### 1. 백업 스크립트 오류
```cmd
# 권한 문제 해결
icacls backup\chatlog /grant %USERNAME%:(F)

# 폴더 생성 문제
mkdir backup\chatlog 2>nul
```

### 2. 파일 크기 문제
```cmd
# 큰 파일 압축
powershell Compress-Archive -Path docs\chatlog.md -DestinationPath backup\chatlog.zip
```

### 3. 인코딩 문제
```cmd
# UTF-8 인코딩 확인
chcp 65001
type docs\chatlog.md
```

---

**📌 중요**: 채팅 기록은 프로젝트의 중요한 자산입니다. 정기적인 백업을 통해 개발 지식을 안전하게 보존하세요. 