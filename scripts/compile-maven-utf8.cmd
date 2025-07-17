@echo off
echo =========================================
echo 🚀 Maven 컴파일 UTF-8 인코딩 설정 및 실행
echo =========================================
echo.

echo 1단계: Windows 콘솔 인코딩 설정...
chcp 65001 > nul

echo 2단계: PowerShell UTF-8 출력 설정...
powershell -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8"

echo 3단계: Maven 환경변수 설정 (UTF-8 강화)...
set MAVEN_OPTS=-Dfile.encoding=UTF-8 -Dconsole.encoding=UTF-8 -Dproject.build.sourceEncoding=UTF-8

echo 4단계: Tomcat 프로세스 종료 (컴파일 전 정리)...
taskkill /f /im java.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Tomcat 프로세스 종료 완료
) else (
    echo ℹ️  실행 중인 Tomcat 프로세스 없음
)

echo.
echo 5단계: Maven 컴파일 실행...
echo [INFO] UTF-8 인코딩으로 Maven 컴파일 시작
echo [INFO] Java 소스 파일들 컴파일 중...
echo.

mvn compile

echo.
if %errorlevel% equ 0 (
    echo =========================================
    echo ✅ Maven 컴파일 성공! (UTF-8 인코딩)
    echo =========================================
    echo.
    echo 🚀 다음 단계: Tomcat을 수동으로 재시작해 주세요.
    echo 📋 재시작 명령어: C:\tomcat9\bin\startup.bat
    echo.
    echo ⚠️  참고: 에이전트는 사용자 제어권 보장을 위해
    echo    Tomcat을 자동으로 시작하지 않습니다.
) else (
    echo =========================================
    echo ❌ Maven 컴파일 실패
    echo =========================================
    echo 오류 해결 후 다시 시도해주세요.
)

echo.
pause 