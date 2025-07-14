@echo off
chcp 65001 >nul
echo ========================================
echo 🐘 PostgreSQL MCP 서버 설정 도구
echo ========================================
echo.

echo 📋 사용 가능한 MCP 서버:
echo 1️⃣ 공식 PostgreSQL MCP (@modelcontextprotocol/server-postgres)
echo 2️⃣ Sequel MCP (@sequelsh/mcp) 
echo 3️⃣ 향상된 PostgreSQL MCP (@henkey/postgres-mcp-server)
echo.

set /p choice="선택하세요 (1-3): "

if "%choice%"=="1" goto official
if "%choice%"=="2" goto sequel  
if "%choice%"=="3" goto enhanced
goto end

:official
echo.
echo 🚀 공식 PostgreSQL MCP 설치 중...
npm install -g @modelcontextprotocol/server-postgres
echo.
echo ✅ 설치 완료! 
echo 📝 .cursor/mcp.json 파일을 확인하고 비밀번호를 설정하세요.
goto end

:sequel
echo.
echo 🚀 Sequel MCP 설치 중...
npm install -g @sequelsh/mcp
echo.
echo ✅ 설치 완료!
echo 📝 연결 문자열: postgresql://postgres:PASSWORD@localhost:5432/promptsharing
goto end

:enhanced  
echo.
echo 🚀 향상된 PostgreSQL MCP 설치 중...
npm install -g @henkey/postgres-mcp-server
echo.
echo ✅ 설치 완료! (46개 도구 포함)
echo ⚠️ 주의: 많은 기능이 있어 신중히 사용하세요.
goto end

:end
echo.
echo ========================================
echo 📖 다음 단계:
echo 1. Cursor 재시작
echo 2. Settings → MCP → 서버 확인  
echo 3. Composer (Ctrl+I)에서 테스트
echo ========================================
echo.
pause 