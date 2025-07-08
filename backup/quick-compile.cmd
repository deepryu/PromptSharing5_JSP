@echo off
chcp 65001 > nul
echo =====================================
echo         빠른 컴파일 스크립트
echo =====================================

:: 인코딩 설정
set MAVEN_OPTS=-Dfile.encoding=UTF-8 -Dconsole.encoding=UTF-8

echo [%time%] 빠른 컴파일 시작...

:: 소스 컴파일만 실행 (clean 없이)
call .\mvnw.cmd compile -q
if %ERRORLEVEL% neq 0 (
    echo ❌ 컴파일 실패!
    pause
    exit /b 1
)

echo ✅ [%time%] 컴파일 완료!
echo 📍 배포 위치: WEB-INF\classes
echo 🌐 테스트: http://localhost:8080/PromptSharing5_JSP/

:: 컴파일 시간 기록
echo [%date% %time%] 빠른 컴파일 완료 >> compile-history.log 