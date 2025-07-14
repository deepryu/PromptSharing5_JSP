# 💬 Cursor AI 채팅 기록 전용 백업 가이드

## 📋 개요

파일 백업은 제외하고 **Cursor AI와의 채팅 기록만**을 안전하게 백업하는 전용 시스템입니다.

---

## 🎯 추천 Extension Top 3

### 1️⃣ **Cursor Chat Keeper** ⭐ Windows 최우선 추천
```
Extension ID: kennycha.cursor-chat-keeper
설치 수: 360+
플랫폼: Windows ✅ / macOS ✅ / Linux ✅
```

**장점:**
- ✅ **모든 플랫폼 지원** (Windows 완벽 호환)
- ✅ 간단한 키보드 단축키 (`Ctrl+Alt+C`)
- ✅ 워크스페이스 루트에 `cursor-chat.md` 자동 저장
- ✅ 타임스탬프 + 대화 구조 완전 보존

**사용법:**
```bash
# 단축키
Ctrl + Alt + C

# 명령 팔레트
Ctrl + Shift + P → "Save Cursor Chat History"
```

---

### 2️⃣ **SpecStory** ⭐ 다기능 추천
```
Extension ID: SpecStory.specstory-vscode  
설치 수: 10,455+
플랫폼: Windows ✅ / macOS ✅ / Linux ✅
```

**장점:**
- ✅ **가장 많은 사용자** (10K+ 검증됨)
- ✅ 자동 저장 기능 (`./specstory/history`)
- ✅ 채팅 히스토리 검색 + 공유 기능
- ✅ 체리픽 저장 (원하는 대화만 선택)

**사용법:**
```bash
# 저장
Ctrl + Shift + P → "SpecStory: Save AI Chat History"

# 공유  
Ctrl + Shift + P → "SpecStory: Share AI Chat History"
```

---

### 3️⃣ **CursorChat Downloader** ⭐ macOS 전용
```
Extension ID: abdelhakakermi.cursorchat-downloader
설치 수: 1,407+
플랫폼: macOS ✅ / Windows ❌
```

**장점:**
- ✅ **모든 워크스페이스 히스토리** 한번에 접근
- ✅ AI 응답, 코드 스니펫, 파일 선택 완전 보존
- ✅ 마크다운 + 문법 하이라이팅

**제한사항:**
- ⚠️ **macOS 전용** (Windows 미지원)

---

## 🚀 즉시 설치

### 자동 설치 스크립트
```bash
# 3개 확장프로그램 한번에 설치
.\install-chat-backup-extensions.cmd
```

### 수동 설치
```bash
# 1. Cursor Chat Keeper (Windows 추천)
code --install-extension kennycha.cursor-chat-keeper

# 2. SpecStory (다기능)
code --install-extension SpecStory.specstory-vscode

# 3. CursorChat Downloader (macOS 전용)
code --install-extension abdelhakakermi.cursorchat-downloader
```

---

## ⚙️ 최적 설정

### settings.json 적용
```json
{
  "cursorChatKeeper.autoSave": true,
  "cursorChatKeeper.includeTimestamps": true,
  "cursorChatKeeper.filename": "cursor-chat-history.md",
  
  "specstory.autoSaveHistory": true,
  "specstory.saveLocation": "./specstory/history",
  "specstory.helpUsImprove": false
}
```

### 키보드 단축키
```json
{
  "key": "ctrl+alt+c",
  "command": "cursorChatKeeper.saveHistory"
},
{
  "key": "ctrl+alt+s", 
  "command": "specstory.saveHistory"
}
```

---

## 📁 백업 파일 구조

```
PromptSharing5_JSP/
├── cursor-chat-history.md          # Cursor Chat Keeper 저장
├── specstory/
│   └── history/                    # SpecStory 세션별 저장
│       ├── session-2025-01-XX.md
│       └── session-2025-01-YY.md
└── docs/
    └── CHAT_BACKUP_GUIDE.md        # 이 문서
```

---

## 🔄 추천 워크플로우

### 일상 사용 패턴
1. **🔄 실시간 백업**: SpecStory 자동 저장 활성화
2. **📝 수동 백업**: 중요한 대화 후 `Ctrl+Alt+C`
3. **🔍 검색**: SpecStory로 과거 대화 검색
4. **📤 공유**: 중요한 해결책 SpecStory로 공유

### 상황별 사용법
| 상황 | 추천 도구 | 방법 |
|------|-----------|------|
| 일상 백업 | Cursor Chat Keeper | `Ctrl+Alt+C` |
| 중요 대화 | SpecStory | `Ctrl+Shift+P` → Save |
| 전체 히스토리 | CursorChat Downloader | `Ctrl+Shift+P` → View |
| 공유 목적 | SpecStory | Share 기능 |

---

## 🛡️ 백업 파일 보호

### Git 추적 설정
```bash
# .gitignore에 추가 (선택사항)
cursor-chat*.md
specstory/history/

# 또는 Git에 포함하여 팀 공유
git add cursor-chat-history.md
git commit -m "Add chat backup"
```

### 자동 백업 스크립트
```bash
# backup-current-chat.cmd 활용
.\backup-current-chat.cmd
```

---

## 🔧 트러블슈팅

### 공통 문제
```bash
# Extension 설치 실패
code --list-extensions | findstr cursor
code --list-extensions | findstr specstory

# 권한 문제
code --user-data-dir=%TEMP%/cursor-temp --install-extension kennycha.cursor-chat-keeper
```

### Windows 특정 문제
```bash
# PowerShell 실행 정책
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# UTF-8 인코딩
chcp 65001
```

### macOS 특정 문제
```bash
# Cursor 경로 확인
ls ~/Library/Application\ Support/Cursor/User/workspaceStorage/

# 권한 설정
chmod +x ~/path/to/cursor
```

---

## 📊 Extension 비교표

| Extension | 설치 수 | Windows | macOS | Linux | 자동 저장 | 검색 | 공유 |
|-----------|---------|---------|-------|-------|----------|------|------|
| **Cursor Chat Keeper** | 360+ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| **SpecStory** | 10,455+ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **CursorChat Downloader** | 1,407+ | ❌ | ✅ | ❌ | ❌ | ✅ | ❌ |

---

## 💡 Pro Tips

### 1. 다중 백업 전략
- **실시간**: SpecStory 자동 저장
- **수동**: Cursor Chat Keeper 중요 대화
- **아카이브**: 주기적으로 Git 커밋

### 2. 검색 최적화
```json
// settings.json
"search.include": {
  "**/cursor-chat*.md": true,
  "**/specstory/history/**": true
}
```

### 3. 팀 협업
- SpecStory Share 기능으로 유용한 AI 대화 공유
- Git에 중요한 채팅 기록 포함하여 팀 지식 축적

---

## 🔗 관련 문서
- [CHATLOG_BACKUP_GUIDE.md](./CHATLOG_BACKUP_GUIDE.md) - 포괄적 백업 가이드
- [PROJECT_GUIDE.md](./PROJECT_GUIDE.md) - 프로젝트 전체 가이드

---

**📅 마지막 업데이트**: 2025-01-XX  
**🎯 목적**: 순수 채팅 기록 백업 (파일 백업 제외)  
**💻 대상**: Windows/macOS/Linux Cursor 사용자 