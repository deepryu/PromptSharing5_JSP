@echo off
chcp 65001 > nul
echo =====================================
echo      자동 컴파일 및 배포 스크립트
echo =====================================
echo.

:: 인코딩 설정
set MAVEN_OPTS=-Dfile.encoding=UTF-8 -Dconsole.encoding=UTF-8

:: 시작 시간 기록
echo [%date% %time%] 자동 컴파일 및 배포 시작...
echo.

:: Step 1: Maven Clean
echo [단계 1/4] Maven Clean 실행...
call .\mvnw.cmd clean
if %ERRORLEVEL% neq 0 (
    echo ❌ Maven Clean 실패!
    pause
    exit /b 1
)
echo ✅ Maven Clean 완료
echo.

:: Step 2: 소스 컴파일
echo [단계 2/4] 소스 컴파일 실행...
call .\mvnw.cmd compile
if %ERRORLEVEL% neq 0 (
    echo ❌ 소스 컴파일 실패!
    pause
    exit /b 1
)
echo ✅ 소스 컴파일 완료
echo.

:: Step 3: 테스트 컴파일
echo [단계 3/4] 테스트 컴파일 실행...
call .\mvnw.cmd test-compile
if %ERRORLEVEL% neq 0 (
    echo ❌ 테스트 컴파일 실패!
    pause
    exit /b 1
)
echo ✅ 테스트 컴파일 완료
echo.

:: Step 4: 클래스 파일 배포 상태 확인
echo [단계 4/4] 배포 상태 확인...
echo.

echo 📁 컨트롤러 클래스 파일 상태:
if exist "WEB-INF\classes\com\example\controller" (
    dir "WEB-INF\classes\com\example\controller\*.class" /T:W 2>nul
) else (
    echo ❌ 컨트롤러 클래스 디렉토리가 없습니다!
)
echo.

echo 📁 모델 클래스 파일 상태:
if exist "WEB-INF\classes\com\example\model" (
    dir "WEB-INF\classes\com\example\model\*.class" /T:W 2>nul
) else (
    echo ❌ 모델 클래스 디렉토리가 없습니다!
)
echo.

:: Tomcat 상태 확인
echo 🔍 Tomcat 프로세스 상태:
tasklist /FI "IMAGENAME eq java.exe" /FO TABLE | findstr java.exe
if %ERRORLEVEL% neq 0 (
    echo ❌ Tomcat(Java) 프로세스가 실행 중이지 않습니다!
    echo 💡 Tomcat을 시작하려면: C:\tomcat9\bin\startup.bat
) else (
    echo ✅ Tomcat이 실행 중입니다!
)
echo.

:: 완료 메시지
echo =====================================
echo      🎉 자동 컴파일 및 배포 완료!
echo =====================================
echo 📍 배포 위치: %CD%\WEB-INF\classes
echo 🌐 테스트 URL: http://localhost:8080/PromptSharing5_JSP/
echo 📋 메인 페이지: http://localhost:8080/PromptSharing5_JSP/main.jsp
echo.

:: 마지막 컴파일 시간 기록
echo [%date% %time%] 컴파일 및 배포 작업 완료 > last-compile.log
echo.

echo 아무 키나 누르면 종료됩니다...
pause > nul 