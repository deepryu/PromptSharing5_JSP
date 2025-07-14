@echo off
REM ============================================================================
REM Maven 기반 WAR 파일 패키징 스크립트
REM 배포 가능한 WAR 파일 생성
REM ============================================================================

echo [PACKAGE] Maven 기반 WAR 패키징을 시작합니다...
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

REM 2. 이전 패키지 정리
echo [STEP 1/4] 이전 패키지 정리 중...
if exist "target\*.war" (
    del /Q "target\*.war"
    echo [INFO] 기존 WAR 파일 삭제 완료
)

REM 3. 컴파일 및 테스트 (선택 사항, 시스템 Maven 사용)
set /p skip_tests="테스트를 건너뛰시겠습니까? (y/N): "
if /i "%skip_tests%"=="y" (
    echo [STEP 2/4] 테스트 건너뛰고 패키징 중...
    call mvn package -DskipTests
) else (
    echo [STEP 2/4] 테스트 포함하여 패키징 중...
    call mvn package
)

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Maven package 실패
    pause
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] 패키징 완료
echo.

REM 4. WAR 파일 확인
echo [STEP 3/4] WAR 파일 확인 중...
set WAR_FILE=target\promptsharing-jsp-1.3.0.war

if not exist "%WAR_FILE%" (
    echo [ERROR] WAR 파일이 생성되지 않았습니다.
    echo [INFO] 예상 경로: %WAR_FILE%
    pause
    exit /b 1
)

REM WAR 파일 정보 출력
for %%I in ("%WAR_FILE%") do (
    echo [SUCCESS] WAR 파일 생성 완료
    echo [INFO] 파일명: %%~nxI
    echo [INFO] 크기: %%~zI bytes
    echo [INFO] 경로: %%~fI
)
echo.

REM 5. 배포 옵션 제공
echo [STEP 4/4] 배포 옵션 선택...
echo.
echo [배포 옵션]
echo   1. Tomcat webapps 디렉터리로 복사
echo   2. 현재 위치에 WAR 파일 유지
echo   3. WAR 파일 내용 확인
echo.

set /p deploy_option="선택하세요 (1-3): "

if "%deploy_option%"=="1" (
    REM Tomcat webapps 디렉터리로 복사
    set TOMCAT_WEBAPPS=C:\tomcat9\webapps
    if exist "%TOMCAT_WEBAPPS%" (
        copy "%WAR_FILE%" "%TOMCAT_WEBAPPS%\"
        if %ERRORLEVEL%==0 (
            echo [SUCCESS] WAR 파일이 Tomcat webapps 디렉터리로 복사되었습니다.
            echo [INFO] 복사 위치: %TOMCAT_WEBAPPS%\promptsharing-jsp-1.3.0.war
            echo [TIP] Tomcat을 재시작하면 자동으로 배포됩니다.
        ) else (
            echo [ERROR] WAR 파일 복사 실패
        )
    ) else (
        echo [ERROR] Tomcat webapps 디렉터리를 찾을 수 없습니다.
        echo [INFO] 예상 경로: %TOMCAT_WEBAPPS%
    )
) else if "%deploy_option%"=="2" (
    echo [INFO] WAR 파일이 target 디렉터리에 보관됩니다.
    echo [INFO] 필요 시 수동으로 배포하세요.
) else if "%deploy_option%"=="3" (
    REM WAR 파일 내용 확인
    echo [INFO] WAR 파일 내용을 확인합니다...
    jar tf "%WAR_FILE%" | more
) else (
    echo [INFO] 기본값으로 현재 위치에 WAR 파일을 유지합니다.
)

echo.
echo ============================================================================
echo [SUCCESS] Maven 기반 WAR 패키징이 완료되었습니다!
echo ============================================================================
echo.
echo [생성된 파일]
echo   - WAR 파일: %WAR_FILE%
echo   - 클래스 파일: target/classes/
echo   - 테스트 보고서: target/surefire-reports/
echo.
echo [WAR 파일 구조]
echo   - JSP 파일들 (*.jsp)
echo   - CSS 스타일 (css/style.css)
echo   - WEB-INF/web.xml
echo   - WEB-INF/classes/ (컴파일된 Java 클래스)
echo   - WEB-INF/lib/ (의존성 라이브러리)
echo.
echo [배포 방법]
echo   1. Tomcat Manager를 통한 배포
echo   2. webapps 디렉터리에 WAR 파일 복사
echo   3. 기존 디렉터리 교체 후 Tomcat 재시작
echo.

pause 