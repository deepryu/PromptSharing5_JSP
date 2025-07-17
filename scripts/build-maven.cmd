@echo off
REM ============================================================================
REM Maven 기반 프로젝트 빌드 스크립트
REM 기존 javac 컴파일 방식을 Maven으로 대체
REM ============================================================================

echo [BUILD] Maven 기반 빌드를 시작합니다...
echo.

REM 1. 환경 변수 확인
if "%JAVA_HOME%"=="" (
    echo [ERROR] JAVA_HOME 환경변수가 설정되지 않았습니다.
    echo         JDK 설치 경로를 JAVA_HOME으로 설정해주세요.
    pause
    exit /b 1
)

echo [INFO] JAVA_HOME: %JAVA_HOME%
echo [INFO] 현재 경로: %CD%
echo.

REM 2. 이전 빌드 결과물 정리 (시스템 Maven 사용)
echo [STEP 1/4] 이전 빌드 결과물 정리 중...
call mvn clean
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Maven clean 실패
    pause
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] 정리 완료
echo.

REM 3. 의존성 다운로드 및 컴파일 (시스템 Maven 사용)
echo [STEP 2/4] Java 소스 컴파일 중...
echo [INFO] 컴파일 순서: util → model → controller
call mvn compile
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Maven compile 실패
    echo [TIP] 소스 코드 오류를 확인해주세요.
    pause
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] 컴파일 완료
echo.

REM 4. 테스트 컴파일 (시스템 Maven 사용)
echo [STEP 3/4] 테스트 소스 컴파일 중...
call mvn test-compile
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Maven test-compile 실패
    echo [TIP] 테스트 코드 오류를 확인해주세요.
    pause
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] 테스트 컴파일 완료
echo.

REM 5. 컴파일 결과 확인
echo [STEP 4/4] 컴파일 결과 확인 중...

REM target/classes 디렉터리 확인
if not exist "target\classes\com\example" (
    echo [ERROR] 컴파일된 클래스 파일을 찾을 수 없습니다.
    echo [INFO] target\classes\com\example 디렉터리가 없습니다.
    pause
    exit /b 1
)

REM 주요 클래스 파일 존재 확인
set MISSING_CLASSES=0

if not exist "target\classes\com\example\util\DatabaseUtil.class" (
    echo [WARNING] DatabaseUtil.class 누락
    set MISSING_CLASSES=1
)

if not exist "target\classes\com\example\model\User.class" (
    echo [WARNING] User.class 누락
    set MISSING_CLASSES=1
)

if not exist "target\classes\com\example\model\UserDAO.class" (
    echo [WARNING] UserDAO.class 누락
    set MISSING_CLASSES=1
)

if not exist "target\classes\com\example\model\Candidate.class" (
    echo [WARNING] Candidate.class 누락
    set MISSING_CLASSES=1
)

if not exist "target\classes\com\example\model\CandidateDAO.class" (
    echo [WARNING] CandidateDAO.class 누락
    set MISSING_CLASSES=1
)

if not exist "target\classes\com\example\controller\LoginServlet.class" (
    echo [WARNING] LoginServlet.class 누락
    set MISSING_CLASSES=1
)

REM 새로 추가된 질문/평가 관련 클래스 확인
if not exist "target\classes\com\example\model\InterviewQuestion.class" (
    echo [WARNING] InterviewQuestion.class 누락
    set MISSING_CLASSES=1
)

if not exist "target\classes\com\example\model\InterviewQuestionDAO.class" (
    echo [WARNING] InterviewQuestionDAO.class 누락
    set MISSING_CLASSES=1
)

if not exist "target\classes\com\example\model\EvaluationCriteria.class" (
    echo [WARNING] EvaluationCriteria.class 누락
    set MISSING_CLASSES=1
)

if not exist "target\classes\com\example\model\EvaluationCriteriaDAO.class" (
    echo [WARNING] EvaluationCriteriaDAO.class 누락
    set MISSING_CLASSES=1
)

if not exist "target\classes\com\example\controller\InterviewQuestionServlet.class" (
    echo [WARNING] InterviewQuestionServlet.class 누락
    set MISSING_CLASSES=1
)

if not exist "target\classes\com\example\controller\EvaluationCriteriaServlet.class" (
    echo [WARNING] EvaluationCriteriaServlet.class 누락
    set MISSING_CLASSES=1
)

if %MISSING_CLASSES%==1 (
    echo [ERROR] 일부 클래스 파일이 누락되었습니다.
    echo [TIP] 소스 코드와 Maven 설정을 확인해주세요.
    pause
    exit /b 1
)

echo [SUCCESS] 모든 클래스 파일이 정상적으로 컴파일되었습니다.
echo.

REM 6. WEB-INF/classes에 클래스 파일 복사 (기존 Tomcat 배포 방식 호환)
echo [STEP 5/5] Tomcat 배포용 클래스 파일 복사 중...
if not exist "WEB-INF\classes" mkdir "WEB-INF\classes"

REM target/classes의 내용을 WEB-INF/classes로 복사
xcopy /E /Y "target\classes\*" "WEB-INF\classes\"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] 클래스 파일 복사 실패
    pause
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] 클래스 파일 복사 완료
echo.

REM 7. 의존성 라이브러리 복사 (Maven에서 자동 관리되는 JAR들을 WEB-INF/lib로 복사)
echo [STEP 6/6] 의존성 라이브러리 복사 중...
call mvnw.cmd dependency:copy-dependencies -DoutputDirectory=WEB-INF/lib -DexcludeScope=provided
if %ERRORLEVEL% neq 0 (
    echo [WARNING] 의존성 라이브러리 복사 실패 (무시하고 계속)
)

echo.
echo ============================================================================
echo [SUCCESS] Maven 기반 빌드가 완료되었습니다!
echo ============================================================================
echo.
echo [정보] 빌드 결과:
echo   - 컴파일된 클래스: target/classes/
echo   - Tomcat 배포용: WEB-INF/classes/
echo   - 의존성 라이브러리: WEB-INF/lib/
echo.
echo [다음 단계] 
echo   1. Tomcat 재시작: restart-tomcat.cmd
echo   2. 테스트 실행: test-maven.cmd  
echo   3. WAR 파일 생성: package-maven.cmd
echo.

pause 