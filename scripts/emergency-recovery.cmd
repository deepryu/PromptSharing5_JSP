@echo off
chcp 65001 >nul
echo.
echo ====================================================
echo 🚨 긴급 복구 스크립트 - 시스템 즉시 복구
echo ====================================================
echo.

echo ⚠️  경고: 이 스크립트는 현재 변경사항을 모두 취소합니다!
echo    백업되지 않은 작업은 모두 손실됩니다.
echo.
set /p confirm="정말로 긴급 복구를 실행하시겠습니까? (Y/N): "
if /i not "%confirm%"=="Y" (
    echo 복구가 취소되었습니다.
    pause
    exit /b
)

echo.
echo [1/6] 🔍 현재 상태 분석 중...
echo     📊 Git 상태:
git status --porcelain
echo     📦 서블릿 상태:
dir "WEB-INF\classes\com\example\controller\*.class" 2>nul | find ".class"

echo.
echo [2/6] 🔄 Git을 통한 변경사항 복구 중...
git checkout -- .
echo     ✅ Git 복구 완료

echo.
echo [3/6] 🏗️  강제 Maven 컴파일 실행 중...
.\mvnw.cmd clean compile
if %errorlevel% EQU 0 (
    echo     ✅ Maven 컴파일 성공
) else (
    echo     ❌ Maven 컴파일 실패 - 백업에서 복구 필요
    echo.
    echo [백업 복구] 최신 백업에서 파일 복구 중...
    for /f "delims=" %%d in ('dir backup /b /ad-h /o-d 2^>nul ^| findstr /r "^[0-9]"') do (
        echo     📂 %%d 백업에서 복구 중...
        copy backup\%%d\*.java src\com\example\controller\ >nul 2>&1
        copy backup\%%d\*.jsp . >nul 2>&1
        goto backup_restored
    )
    :backup_restored
    echo     ✅ 백업 복구 완료, 재컴파일 중...
    .\mvnw.cmd compile
)

echo.
echo [4/6] 🔗 Tomcat 프로세스 정리 중...
taskkill /f /im java.exe >nul 2>&1
if %errorlevel% EQU 0 (
    echo     ✅ 기존 Tomcat 프로세스 종료됨
) else (
    echo     ℹ️  실행 중인 Tomcat 없음
)

echo.
echo [5/6] 🚀 Tomcat 재시작 중...
start /b C:\tomcat9\bin\startup.bat
echo     ✅ Tomcat 시작 명령 실행됨 (5초 대기...)
timeout /t 5 /nobreak >nul

echo.
echo [6/6] 🔍 복구 상태 검증 중...
set recovery_score=0

REM Git 상태 확인
for /f %%i in ('git status --porcelain ^| find /c /v ""') do (
    if %%i EQU 0 set /a recovery_score+=20
)

REM 컴파일 상태 확인  
.\mvnw.cmd compile >nul 2>&1
if %errorlevel% EQU 0 set /a recovery_score+=30

REM 서블릿 배포 확인
for /f %%i in ('dir "WEB-INF\classes\com\example\controller\*.class" 2^>nul ^| find /c ".class"') do (
    if %%i GEQ 10 set /a recovery_score+=30
)

REM 핵심 파일 확인
set critical_files=0
if exist "src\com\example\controller\CandidateServlet.java" set /a critical_files+=1
if exist "src\com\example\controller\InterviewScheduleServlet.java" set /a critical_files+=1
if exist "main.jsp" set /a critical_files+=1
if %critical_files% EQU 3 set /a recovery_score+=20

echo.
echo ====================================================
echo 📊 복구 결과 리포트
echo ====================================================

if %recovery_score% GEQ 90 (
    echo 🎉 복구 성공! 시스템이 완전히 복구되었습니다.
    echo    복구 점수: %recovery_score%/100
    echo.
    echo ✅ 다음 단계:
    echo    1. 브라우저에서 http://localhost:8080/ATS/main.jsp 접속
    echo    2. 1-8번 메뉴 정상 동작 확인
    echo    3. 문제없으면 safety-backup.cmd로 현재 상태 백업
) else if %recovery_score% GEQ 70 (
    echo ⚠️  부분 복구! 일부 문제가 남아있습니다.
    echo    복구 점수: %recovery_score%/100
    echo.
    echo 🔧 추가 조치 필요:
    echo    1. quick-check.cmd로 상세 상태 확인
    echo    2. 문제 영역 수동 복구
    echo    3. .\mvnw.cmd compile 재실행
) else (
    echo ❌ 복구 실패! 수동 조치가 필요합니다.
    echo    복구 점수: %recovery_score%/100
    echo.
    echo 🆘 긴급 조치:
    echo    1. backup\ 폴더에서 최신 백업 수동 복사
    echo    2. 전체 프로젝트 재설치 고려
    echo    3. 개발팀 지원 요청
)

echo.
echo 💡 복구 완료 후 반드시:
echo    1. safety-backup.cmd로 즉시 백업
echo    2. 앞으로 변경 전 반드시 백업 실행
echo    3. quick-check.cmd로 정기 상태 점검
echo.
pause 