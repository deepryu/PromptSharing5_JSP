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
echo     🔄 컴파일 상태 체크 중... ^(빠른 검증^)

REM 컴파일된 클래스 파일 개수 확인
set compiled_classes=0
for /f %%i in ('dir "WEB-INF\classes\com\example\controller\*.class" 2^>nul ^| find /c ".class"') do set compiled_classes=%%i

REM 소스 파일 개수 확인  
set source_files=0
for /f %%i in ('dir "src\com\example\controller\*.java" 2^>nul ^| find /c ".java"') do set source_files=%%i

if %compiled_classes% GEQ %source_files% (
    if %source_files% GTR 0 (
        echo     ✅ Maven 컴파일: 정상 ^(%compiled_classes%/%source_files% 클래스 파일 존재^)
        set compile_status=OK
    ) else (
        echo     ⚠️  Maven 컴파일: 소스 파일 없음
        set compile_status=WARN
    )
) else (
    echo     ❌ Maven 컴파일: 불완전 ^(%compiled_classes%/%source_files% 클래스 파일 누락^)
    echo     💡 .\mvnw.cmd compile 실행 필요
    set compile_status=FAIL
)

echo.
echo [3/5] 📦 서블릿 배포 상태 확인...
if %compiled_classes% GEQ 10 (
    echo     ✅ 서블릿 배포: 정상 ^(%compiled_classes%개 서블릿^)
    set servlet_status=OK
) else (
    echo     ⚠️  서블릿 배포: 불완전 ^(%compiled_classes%개만 배포됨^)
    echo     💡 .\mvnw.cmd compile 실행 권장
    set servlet_status=WARN
)

echo.
echo [4/5] 🔗 Tomcat 프로세스 확인...
tasklist /fi "imagename eq java.exe" 2>nul | find "java.exe" >nul
if %errorlevel% EQU 0 (
    echo     ✅ Tomcat 상태: 실행 중
    set tomcat_status=OK
) else (
    echo     ⚠️  Tomcat 상태: 중지됨
    echo     💡 C:\tomcat9\bin\startup.bat 실행 필요
    set tomcat_status=WARN
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
    set files_status=OK
) else (
    echo     ❌ 핵심 파일: 일부 누락 ^(%critical_files%/5^)
    echo     💡 누락된 파일 복구 필요
    set files_status=FAIL
)

echo.
echo ====================================================
echo 📊 전체 시스템 상태 요약
echo ====================================================

REM 전체 상태 평가
set overall_status=OK
if "%compile_status%"=="FAIL" set overall_status=FAIL
if "%servlet_status%"=="WARN" if "%overall_status%"=="OK" set overall_status=WARN
if "%tomcat_status%"=="WARN" if "%overall_status%"=="OK" set overall_status=WARN  
if "%files_status%"=="FAIL" set overall_status=FAIL

if "%overall_status%"=="OK" (
    echo 🎉 시스템 상태: 완벽! 안전하게 개발 진행 가능
) else if "%overall_status%"=="WARN" (
    echo ⚠️  시스템 상태: 주의 필요 - 아래 권장사항 확인
) else (
    echo ❌ 시스템 상태: 심각 - 즉시 조치 필요!
)

echo.
echo 🔧 권장 조치:
if %git_changes% GTR 0 echo    - git add . ^&^& git commit -m "작업 저장"
if "%compile_status%"=="FAIL" echo    - .\mvnw.cmd compile 실행 ^(컴파일 필요^)
if "%servlet_status%"=="WARN" echo    - .\mvnw.cmd compile 실행 ^(서블릿 재빌드^)
if "%tomcat_status%"=="WARN" echo    - C:\tomcat9\bin\startup.bat 실행 ^(Tomcat 시작^)
if "%files_status%"=="FAIL" echo    - 백업에서 누락 파일 복구

echo.
echo 💡 추가 도구:
echo    - safety-backup.cmd: 안전 백업 생성
echo    - emergency-recovery.cmd: 긴급 복구 실행
echo    - .\mvnw.cmd compile: 수동 컴파일

echo.
echo ⏱️  빠른 체크 완료 ^(실제 컴파일 없이 상태만 확인^)
echo.
pause 