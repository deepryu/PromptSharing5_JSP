@echo off
echo =========================================
echo Maven 테스트 UTF-8 인코딩 설정 및 실행
echo =========================================
echo.

echo 1단계: Windows 콘솔 인코딩 설정...
chcp 65001 > nul

echo 2단계: PowerShell UTF-8 출력 설정...
powershell -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8"

echo 3단계: Maven 환경변수 설정...
set MAVEN_OPTS=-Dfile.encoding=UTF-8

echo 4단계: Maven 테스트 실행...
echo.
.\mvnw.cmd test

echo.
echo =========================================
echo Maven 테스트 완료
echo =========================================
pause 