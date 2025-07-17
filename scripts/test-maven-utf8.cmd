@echo off
echo =========================================
echo 시스템 Maven 테스트 UTF-8 인코딩 설정 및 실행
echo =========================================
echo.

echo 1단계: Windows 콘솔 인코딩 설정...
chcp 65001 > nul

echo 2단계: PowerShell UTF-8 출력 설정...
powershell -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8"

echo 3단계: Maven 환경변수 설정 (UTF-8 강화)...
set MAVEN_OPTS=-Dfile.encoding=UTF-8 -Dconsole.encoding=UTF-8 -Dproject.build.sourceEncoding=UTF-8

echo 4단계: 시스템 Maven 테스트 실행...
echo [INFO] 시스템 Maven 3.9.10 사용
echo [INFO] 50개 테스트 케이스 실행 중...
echo.

REM 시스템 Maven 사용으로 변경
mvn test

echo.
echo =========================================
echo 시스템 Maven 테스트 완료
echo =========================================
pause 