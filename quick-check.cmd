@echo off
chcp 65001 >nul
echo.
echo ====================================================
echo 🔍 빠른 상태 체크 - 시스템 건강도 진단
echo ====================================================
echo.

echo [1/5] 📊 Git 변경사항 확인...
set git_changes=0
for /f %%i in ('git status --porcelain ^| find /c /v ""') do set git_changes=%%i
if %git_changes% EQU 0 (
    echo     ✅ Git 상태: 깨끗함 ^(변경사항 없음^)
) else (
    echo     ⚠️  Git 상태: %git_changes%개 파일 변경됨
    git status --porcelain
)

echo.
echo [2/5] 🏗️  Maven 컴파일 상태 확인...
.\mvnw.cmd compile >nul 2>&1
if %errorlevel% EQU 0 (
    echo     ✅ Maven 컴파일: 성공
) else (
    echo     ❌ Maven 컴파일: 실패 - 즉시 확인 필요!
)

echo.
echo [3/5] 📦 서블릿 배포 상태 확인...
set servlet_count=0
for /f %%i in ('dir "WEB-INF\classes\com\example\controller\*.class" 2^>nul ^| find /c ".class"') do set servlet_count=%%i
if %servlet_count% GEQ 10 (
    echo     ✅ 서블릿 배포: 정상 ^(%servlet_count%개 서블릿^)
) else (
    echo     ⚠️  서블릿 배포: 불완전 ^(%servlet_count%개만 배포됨^)
    echo     💡 .\mvnw.cmd compile 실행 권장
)

echo.
echo [4/5] 🔗 Tomcat 프로세스 확인...
tasklist /fi "imagename eq java.exe" 2>nul | find "java.exe" >nul
if %errorlevel% EQU 0 (
    echo     ✅ Tomcat 상태: 실행 중
) else (
    echo     ⚠️  Tomcat 상태: 중지됨
    echo     💡 C:\tomcat9\bin\startup.bat 실행 필요
)

echo.
echo [5/5] 📋 주요 파일 존재 확인...
set critical_files=0
if exist "src\com\example\controller\CandidateServlet.java" set /a critical_files+=1
if exist "src\com\example\controller\InterviewScheduleServlet.java" set /a critical_files+=1  
if exist "src\com\example\controller\InterviewQuestionServlet.java" set /a critical_files+=1
if exist "src\com\example\controller\InterviewResultServlet.java" set /a critical_files+=1
if exist "main.jsp" set /a critical_files+=1

if %critical_files% EQU 5 (
    echo     ✅ 핵심 파일: 모두 존재 ^(5/5^)
) else (
    echo     ❌ 핵심 파일: 일부 누락 ^(%critical_files%/5^)
    echo     💡 누락된 파일 복구 필요
)

echo.
echo ====================================================
echo 📊 전체 시스템 상태 요약
echo ====================================================

if %git_changes% EQU 0 if %errorlevel% EQU 0 if %servlet_count% GEQ 10 if %critical_files% EQU 5 (
    echo 🎉 시스템 상태: 완벽! 안전하게 개발 진행 가능
) else (
    echo ⚠️  시스템 상태: 주의 필요 - 위 문제들 해결 후 진행
    echo.
    echo 🔧 권장 조치:
    if %git_changes% GTR 0 echo    - git add . ^&^& git commit -m "작업 저장"
    if not %errorlevel% EQU 0 echo    - .\mvnw.cmd compile 실행
    if %servlet_count% LSS 10 echo    - .\mvnw.cmd compile 실행  
    if not %critical_files% EQU 5 echo    - 백업에서 누락 파일 복구
)

echo.
echo 💡 문제 발생 시: safety-backup.cmd로 백업 후 작업하세요!
echo.
pause 