@echo off
REM UTF-8 인코딩 설정 (한글 깨짐 방지)
chcp 65001 > nul

echo ===========================================
echo 채팅 기록 자동 백업 스크립트 (UTF-8)
echo ===========================================
echo.

REM 현재 날짜와 시간 생성
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%-%MM%-%DD%"
set "timestamp=%HH%-%Min%-%Sec%"

echo [INFO] 백업 시작: %datestamp% %timestamp%
echo.

REM 백업 디렉토리 생성
if not exist "backup\chatlog" mkdir "backup\chatlog"

REM 1. 현재 채팅 기록 백업
echo [STEP 1/5] 현재 채팅 기록 백업 중...
if exist "docs\chatlog.md" (
    copy "docs\chatlog.md" "backup\chatlog\chatlog_%datestamp%_%timestamp%.md" > nul
    echo [SUCCESS] chatlog.md 백업 완료
) else (
    echo [WARNING] chatlog.md 파일이 없습니다.
)

REM 2. 프로젝트 문서 전체 백업
echo [STEP 2/5] 프로젝트 문서 전체 백업 중...
if not exist "backup\docs_%datestamp%" mkdir "backup\docs_%datestamp%"
xcopy "docs\*" "backup\docs_%datestamp%\" /Y /Q > nul
echo [SUCCESS] docs 폴더 전체 백업 완료

REM 3. 중요 설정 파일 백업
echo [STEP 3/5] 중요 설정 파일 백업 중...
if exist "pom.xml" copy "pom.xml" "backup\chatlog\pom_%datestamp%.xml" > nul
if exist "web.xml" copy "web.xml" "backup\chatlog\web_%datestamp%.xml" > nul
echo [SUCCESS] 설정 파일 백업 완료

REM 4. Git 기록 백업
echo [STEP 4/5] Git 기록 백업 중...
git log --oneline -20 > "backup\chatlog\git_log_%datestamp%.txt"
git status > "backup\chatlog\git_status_%datestamp%.txt"
echo [SUCCESS] Git 기록 백업 완료

REM 5. 백업 결과 요약
echo [STEP 5/5] 백업 결과 요약 중...
echo ========================================= > "backup\chatlog\backup_summary_%datestamp%.txt"
echo 채팅 기록 백업 요약 - %datestamp% %timestamp% >> "backup\chatlog\backup_summary_%datestamp%.txt"
echo ========================================= >> "backup\chatlog\backup_summary_%datestamp%.txt"
echo. >> "backup\chatlog\backup_summary_%datestamp%.txt"
echo [백업된 파일들] >> "backup\chatlog\backup_summary_%datestamp%.txt"
dir "backup\chatlog" /B | findstr %datestamp% >> "backup\chatlog\backup_summary_%datestamp%.txt"
echo. >> "backup\chatlog\backup_summary_%datestamp%.txt"
echo [백업 완료 시간] %datestamp% %timestamp% >> "backup\chatlog\backup_summary_%datestamp%.txt"

echo.
echo ==========================================
echo 백업 완료!
echo ==========================================
echo 백업 위치: backup\chatlog\
echo 백업 파일: chatlog_%datestamp%_%timestamp%.md
echo 문서 백업: backup\docs_%datestamp%\
echo ==========================================
echo.
pause 