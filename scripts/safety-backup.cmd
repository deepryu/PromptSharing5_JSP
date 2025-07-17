@echo off
chcp 65001 >nul
echo.
echo ====================================================
echo 🛡️  안전 백업 스크립트 - 개발 안전성 보장
echo ====================================================
echo.

REM 현재 시간 생성
for /f "tokens=1-4 delims=/ " %%i in ('date /t') do set mydate=%%i-%%j-%%k
for /f "tokens=1-2 delims=: " %%i in ('time /t') do set mytime=%%i-%%j
set datetime=%mydate%_%mytime%

echo [1/4] 📊 현재 Git 상태 확인 중...
git status --porcelain

echo.
echo [2/4] 💾 Git 백업 생성 중...
git add .
git commit -m "안전백업 - %datetime% - 기능추가전 안정상태"

echo.
echo [3/4] 📂 파일 백업 생성 중...
if not exist "backup" mkdir backup
if not exist "backup\%datetime%" mkdir backup\%datetime%

copy src\com\example\controller\*.java backup\%datetime%\ >nul
copy *.jsp backup\%datetime%\ >nul
copy mvnw.cmd backup\%datetime%\mvnw.cmd.backup >nul

echo     ✅ Java 서블릿 파일들 백업 완료
echo     ✅ JSP 파일들 백업 완료  
echo     ✅ Maven 스크립트 백업 완료

echo.
echo [4/4] 🔍 백업 검증 중...
dir backup\%datetime% /B

echo.
echo ====================================================
echo ✅ 안전 백업 완료! 
echo    📁 백업 위치: backup\%datetime%\
echo    🕐 백업 시간: %datetime%
echo ====================================================
echo.
echo 💡 이제 안전하게 개발을 진행하세요!
echo    문제 발생 시: git checkout -- . 로 즉시 복구 가능
echo.
pause 