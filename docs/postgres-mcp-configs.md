# 🐘 PostgreSQL MCP 설정 가이드

## 📋 현재 상태
- ✅ Node.js v22.16.0 설치됨
- ✅ npm 10.9.2 설치됨  
- ✅ `.cursor/mcp.json` 기본 설정 생성됨
- 🔄 PostgreSQL 연결 정보 설정 필요

---

## 🎯 설정 옵션 3가지

### 1️⃣ **공식 PostgreSQL MCP** (추천 - 안정성)
```json
{
  "mcpServers": {
    "PostgreSQL-PromptSharing": {
      "command": "npx",
      "args": [
        "-y", 
        "@modelcontextprotocol/server-postgres",
        "postgresql://postgres:YOUR_PASSWORD@localhost:5432/promptsharing"
      ]
    }
  }
}
```

**특징:**
- ✅ 공식 지원, 가장 안정적
- ✅ 기본적인 SQL 쿼리 실행
- ✅ 스키마 탐색 기능
- ⚠️ 기능이 제한적

---

### 2️⃣ **Sequel MCP** (추천 - 사용성)
```json
{
  "mcpServers": {
    "Sequel-PostgreSQL": {
      "command": "npx",
      "args": [
        "-y",
        "@sequelsh/mcp",
        "start",
        "--database", "postgresql",
        "--connection-string", "postgresql://postgres:YOUR_PASSWORD@localhost:5432/promptsharing"
      ]
    }
  }
}
```

**특징:**
- ✅ 사용자 친화적 설치
- ✅ 자연어 쿼리 번역
- ✅ 로컬 보안 (데이터 유출 없음)
- ✅ 실시간 SQL 생성

---

### 3️⃣ **향상된 PostgreSQL MCP** (고급 사용자)
```json
{
  "mcpServers": {
    "Enhanced-PostgreSQL": {
      "command": "npx",
      "args": [
        "-y",
        "@henkey/postgres-mcp-server",
        "--connection-string",
        "postgresql://postgres:YOUR_PASSWORD@localhost:5432/promptsharing"
      ]
    }
  }
}
```

**특징:**
- ✅ **46개 고급 도구** 포함
- ✅ 테이블 생성/수정/삭제
- ✅ 인덱스 관리
- ✅ 트리거 및 함수 지원
- ✅ Row Level Security (RLS)
- ⚠️ 강력한 기능으로 주의 필요

---

## 🔐 보안 설정 (환경변수 방식)

### Windows 환경변수 설정
```cmd
# PowerShell에서 실행
$env:POSTGRES_URL = "postgresql://postgres:YOUR_PASSWORD@localhost:5432/promptsharing"
```

### 환경변수 사용 설정
```json
{
  "mcpServers": {
    "PostgreSQL-Secure": {
      "command": "npx",
      "args": [
        "-y", 
        "@modelcontextprotocol/server-postgres"
      ],
      "env": {
        "DATABASE_URL": "postgresql://postgres:YOUR_PASSWORD@localhost:5432/promptsharing"
      }
    }
  }
}
```

---

## 🚀 설치 및 테스트 절차

### Step 1: MCP 서버 설치
```bash
# 원하는 서버 선택하여 설치
npm install -g @modelcontextprotocol/server-postgres
# 또는
npm install -g @sequelsh/mcp  
# 또는
npm install -g @henkey/postgres-mcp-server
```

### Step 2: 설정 파일 업데이트
1. `.cursor/mcp.json`에서 `YOUR_PASSWORD`를 실제 비밀번호로 변경
2. 필요시 호스트/포트 정보 수정

### Step 3: Cursor 재시작
```
Cursor 완전 종료 → 재시작
```

### Step 4: MCP 서버 확인
```
Cursor → Settings → MCP → PostgreSQL 서버 확인
```

### Step 5: 기능 테스트
```
Ctrl + I (Composer) → "데이터베이스 테이블 목록을 보여줘"
```

---

## 🛠️ 트러블슈팅

### 연결 실패 시
1. **PostgreSQL 서버 실행 확인**
   ```bash
   pg_isready -h localhost -p 5432
   ```

2. **연결 정보 검증**
   ```bash
   psql -h localhost -p 5432 -U postgres -d promptsharing
   ```

3. **방화벽 확인**
   - Windows Defender 예외 추가
   - PostgreSQL 포트 5432 열기

### MCP 서버 미인식 시
1. **Cursor 완전 재시작**
2. **Node.js 경로 확인**
3. **권한 문제 해결**
   ```bash
   npm config set prefix %APPDATA%\npm
   ```

---

## 💡 사용 예시

### 기본 쿼리
```
"promptsharing 데이터베이스의 모든 테이블을 보여줘"
"users 테이블의 구조를 설명해줘"  
"최근 생성된 candidates 5개를 보여줘"
```

### 고급 분석 (향상된 MCP)
```
"interview_results 테이블에 인덱스를 추가해줘"
"candidates 테이블에 새로운 컬럼을 추가해줘"
"데이터베이스 성능 분석을 해줘"
```

---

## 📊 MCP 서버 비교표

| 기능 | 공식 MCP | Sequel MCP | 향상된 MCP |
|------|----------|------------|------------|
| 안정성 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| 사용성 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 기능성 | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 보안성 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

---

**🎯 추천: 처음 사용자는 "공식 MCP" → 익숙해지면 "향상된 MCP"로 업그레이드** 