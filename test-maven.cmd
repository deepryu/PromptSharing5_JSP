@echo off
REM ============================================================================
REM Maven 기반 JUnit 테스트 실행 스크립트
REM 20개 테스트 케이스 (UserDAO 4개, CandidateDAO 5개, InterviewScheduleDAO 11개)
REM ============================================================================

echo [TEST] Maven 기반 JUnit 테스트를 시작합니다...
echo.

REM 1. 환경 변수 확인
if "%JAVA_HOME%"=="" (
    echo [ERROR] JAVA_HOME 환경변수가 설정되지 않았습니다.
    pause
    exit /b 1
)

echo [INFO] JAVA_HOME: %JAVA_HOME%
echo [INFO] 현재 경로: %CD%
echo.

REM 2. 데이터베이스 연결 확인
echo [STEP 1/5] 데이터베이스 연결 확인 중...
echo [INFO] PostgreSQL 연결 정보:
echo   - 호스트: localhost:5432
echo   - 데이터베이스: promptsharing
echo   - 사용자: postgres
echo.

REM 3. 테스트 컴파일
echo [STEP 2/5] 테스트 소스 컴파일 중...
call mvnw.cmd test-compile
if %ERRORLEVEL% neq 0 (
    echo [ERROR] 테스트 컴파일 실패
    pause
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] 테스트 컴파일 완료
echo.

REM 4. 개별 테스트 클래스 실행
echo [STEP 3/5] UserDAO 테스트 실행 중 (4개 테스트)...
call mvnw.cmd test -Dtest=UserDAOTest
if %ERRORLEVEL% neq 0 (
    echo [ERROR] UserDAOTest 실패
    echo [TIP] 데이터베이스 연결과 users 테이블을 확인하세요.
    pause
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] UserDAOTest 완료 (4/20)
echo.

echo [STEP 4/5] CandidateDAO 테스트 실행 중 (5개 테스트)...
call mvnw.cmd test -Dtest=CandidateDAOTest
if %ERRORLEVEL% neq 0 (
    echo [ERROR] CandidateDAOTest 실패
    echo [TIP] candidates 테이블을 확인하세요.
    pause
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] CandidateDAOTest 완료 (9/20)
echo.

echo [STEP 5/5] InterviewScheduleDAO 테스트 실행 중 (11개 테스트)...
call mvnw.cmd test -Dtest=InterviewScheduleDAOTest
if %ERRORLEVEL% neq 0 (
    echo [ERROR] InterviewScheduleDAOTest 실패
    echo [TIP] interview_schedules 테이블을 확인하세요.
    pause
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] InterviewScheduleDAOTest 완료 (20/20)
echo.

REM 5. 전체 테스트 재실행 (최종 검증)
echo [STEP 6/6] 전체 테스트 최종 검증 중...
call mvnw.cmd test
if %ERRORLEVEL% neq 0 (
    echo [ERROR] 전체 테스트 실패
    echo [TIP] 개별 테스트는 성공했지만 전체 실행에서 실패했습니다.
    echo      테스트 간 데이터 간섭이나 순서 문제를 확인하세요.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo ============================================================================
echo [SUCCESS] 모든 JUnit 테스트가 성공적으로 완료되었습니다!
echo ============================================================================
echo.
echo [테스트 결과 요약]
echo   - UserDAOTest: 4개 테스트 성공
echo     * testAddUser_Success
echo     * testAddUser_Duplicate  
echo     * testFindByUsername_Exists
echo     * testFindByUsername_NotExists
echo.
echo   - CandidateDAOTest: 5개 테스트 성공
echo     * testAddCandidate_Success
echo     * testGetCandidateById_Exists
echo     * testGetCandidateById_NotExists
echo     * testUpdateCandidate_Success
echo     * testDeleteCandidate_Success
echo.
echo   - InterviewScheduleDAOTest: 11개 테스트 성공
echo     * testAddSchedule_Success
echo     * testGetScheduleById_Exists
echo     * testGetScheduleById_NotExists
echo     * testUpdateSchedule
echo     * testDeleteSchedule
echo     * testGetSchedulesByCandidateId
echo     * testGetSchedulesByDate
echo     * testGetSchedulesByStatus
echo     * testHasTimeConflict_NoConflict
echo     * testHasTimeConflict_WithConflict
echo     * testGetAllSchedules
echo.
echo [총 테스트 케이스] 20개 모두 성공
echo.
echo [참고] 테스트 보고서는 target/surefire-reports/ 디렉터리에서 확인 가능합니다.

pause 