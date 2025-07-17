@echo off
chcp 65001 >nul
echo ========================================
echo 🎯 Cursor AI 채팅 기록 전용 백업 Extension 설치
echo ========================================
echo.

echo 📋 설치할 확장프로그램:
echo 1️⃣ CursorChat Downloader (1,407+ 설치)
echo 2️⃣ Cursor Chat Keeper (360+ 설치) 
echo 3️⃣ SpecStory (10,455+ 설치)
echo.

echo 🚀 Extension 설치 시작...
echo.

echo [1/3] CursorChat Downloader 설치 중...
cursor --install-extension abdelhakakermi.cursorchat-downloader
if %errorlevel% equ 0 (
    echo ✅ CursorChat Downloader 설치 완료
) else (
    echo ❌ CursorChat Downloader 설치 실패
)
echo.

echo [2/3] Cursor Chat Keeper 설치 중...
cursor --install-extension kennycha.cursor-chat-keeper
if %errorlevel% equ 0 (
    echo ✅ Cursor Chat Keeper 설치 완료
) else (
    echo ❌ Cursor Chat Keeper 설치 실패
)
echo.

echo [3/3] SpecStory 설치 중...
cursor --install-extension SpecStory.specstory-vscode
if %errorlevel% equ 0 (
    echo ✅ SpecStory 설치 완료
) else (
    echo ❌ SpecStory 설치 실패
)
echo.

echo ========================================
echo 🎉 채팅 백업 Extension 설치 완료!
echo ========================================
echo.
echo 📖 사용법:
echo.
echo 🔹 CursorChat Downloader:
echo    Ctrl+Shift+P → "View Cursor Chat History"
echo    ⚠️ 참고: macOS 전용 (Windows 제한)
echo.
echo 🔹 Cursor Chat Keeper:
echo    Ctrl+Alt+C (단축키) 또는
echo    Ctrl+Shift+P → "Save Cursor Chat History"
echo    📁 저장 위치: cursor-chat.md
echo.
echo 🔹 SpecStory:
echo    Ctrl+Shift+P → "SpecStory: Save AI Chat History"
echo    📁 저장 위치: ./specstory/history/
echo.
echo 💡 추천: Windows 사용자는 "Cursor Chat Keeper" 우선 사용
echo 💡 다기능: "SpecStory"는 검색/공유 기능 포함
echo.
echo 🔧 문제 해결:
echo    만약 명령어 설치가 실패하면 다음 방법 사용:
echo    1. Cursor → Extensions (Ctrl+Shift+X)
echo    2. "Cursor Chat Keeper" 검색
echo    3. Install 클릭
echo.

pause 