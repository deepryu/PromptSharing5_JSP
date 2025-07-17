@echo off
REM ============================================================================
REM Maven 기반 전체 빌드 및 배포 통합 스크립트
REM 빌드 → 테스트 → 패키징 → 배포를 한 번에 실행
REM ============================================================================

echo ============================================================================
echo                    Maven 기반 통합 빌드 및 배포 스크립트
echo ============================================================================
echo [INFO] 이 스크립트는 다음 작업을 순차적으로 실행합니다:
echo   1. 프로젝트 빌드 (컴파일)
echo   2. JUnit 테스트 실행 (20개 테스트)
echo   3. WAR 파일 패키징
echo   4. Tomcat 배포 (선택)
echo.

set /p confirm="계속 진행하시겠습니까? (Y/n): "
if /i "%confirm%"=="n" (
    echo [INFO] 작업이 취소되었습니다.
    pause
    exit /b 0
)

echo.
echo [START] 통합 빌드를 시작합니다...
echo.

REM 1. 빌드 단계
echo ============================================================================
echo                           STEP 1: 프로젝트 빌드
echo ============================================================================
call build-maven.cmd
if %ERRORLEVEL% neq 0 (
    echo [ERROR] 빌드 단계에서 실패했습니다.
    pause
    exit /b %ERRORLEVEL%
)
echo.

REM 2. 테스트 단계
echo ============================================================================
echo                           STEP 2: JUnit 테스트 실행
echo ============================================================================
set /p run_tests="테스트를 실행하시겠습니까? (Y/n): "
if /i not "%run_tests%"=="n" (
    call test-maven.cmd
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] 테스트 단계에서 실패했습니다.
        set /p continue_anyway="테스트 실패를 무시하고 계속 진행하시겠습니까? (y/N): "
        if /i not "%continue_anyway%"=="y" (
            pause
            exit /b %ERRORLEVEL%
        )
    )
) else (
    echo [INFO] 테스트를 건너뛰었습니다.
)
echo.

REM 3. 패키징 단계
echo ============================================================================
echo                           STEP 3: WAR 파일 패키징
echo ============================================================================
call package-maven.cmd
if %ERRORLEVEL% neq 0 (
    echo [ERROR] 패키징 단계에서 실패했습니다.
    pause
    exit /b %ERRORLEVEL%
)
echo.

REM 4. 배포 단계 (선택)
echo ============================================================================
echo                           STEP 4: Tomcat 배포 (선택)
echo ============================================================================
set /p deploy="Tomcat에 자동 배포하시겠습니까? (y/N): "
if /i "%deploy%"=="y" (
    echo [INFO] Tomcat 배포를 시작합니다...
    
    REM 기존 Tomcat 프로세스 종료
    echo [INFO] 기존 Tomcat 프로세스를 종료합니다...
    taskkill /f /im java.exe >nul 2>&1
    timeout /t 3 >nul
    
    REM WAR 파일을 webapps에 복사
    set WAR_FILE=target\promptsharing-jsp-1.3.0.war
    set TOMCAT_WEBAPPS=C:\tomcat9\webapps
    
    if exist "%TOMCAT_WEBAPPS%" (
        REM 기존 애플리케이션 디렉터리 삭제
        if exist "%TOMCAT_WEBAPPS%\PromptSharing5_JSP" (
            echo [INFO] 기존 애플리케이션 디렉터리를 삭제합니다...
            rd /s /q "%TOMCAT_WEBAPPS%\PromptSharing5_JSP"
        )
        
        REM 기존 WAR 파일 삭제
        if exist "%TOMCAT_WEBAPPS%\PromptSharing5_JSP.war" (
            del /q "%TOMCAT_WEBAPPS%\PromptSharing5_JSP.war"
        )
        
        REM 새 WAR 파일 복사
        copy "%WAR_FILE%" "%TOMCAT_WEBAPPS%\PromptSharing5_JSP.war"
        if %ERRORLEVEL%==0 (
            echo [SUCCESS] WAR 파일이 Tomcat webapps에 복사되었습니다.
            
            REM Tomcat 시작
            echo [INFO] Tomcat을 시작합니다...
            start "" "C:\tomcat9\bin\startup.bat"
            
            echo [INFO] Tomcat이 시작 중입니다. 잠시 기다려주세요...
            timeout /t 10 >nul
            
            echo.
            echo [SUCCESS] 배포가 완료되었습니다!
            echo [URL] http://localhost:8080/PromptSharing5_JSP
            echo.
            
            REM 브라우저 자동 열기 (선택)
            set /p open_browser="브라우저를 자동으로 열까요? (Y/n): "
            if /i not "%open_browser%"=="n" (
                start "" "http://localhost:8080/PromptSharing5_JSP"
            )
        ) else (
            echo [ERROR] WAR 파일 복사에 실패했습니다.
        )
    ) else (
        echo [ERROR] Tomcat webapps 디렉터리를 찾을 수 없습니다: %TOMCAT_WEBAPPS%
    )
) else (
    echo [INFO] 배포를 건너뛰었습니다.
    echo [INFO] 수동 배포를 원하시면 다음 파일을 사용하세요:
    echo        target\promptsharing-jsp-1.3.0.war
)

echo.
echo ============================================================================
echo                           통합 빌드 완료!
echo ============================================================================
echo.
echo [완료된 작업]
echo   ✓ Maven 프로젝트 빌드
echo   ✓ JUnit 테스트 실행 (선택)
echo   ✓ WAR 파일 패키징  
echo   ✓ Tomcat 배포 (선택)
echo.
echo [생성된 파일]
echo   - 컴파일된 클래스: target/classes/
echo   - 배포용 클래스: WEB-INF/classes/
echo   - WAR 파일: target/promptsharing-jsp-1.3.0.war
echo   - 테스트 보고서: target/surefire-reports/
echo.
echo [다음 단계]
echo   - 애플리케이션 테스트: http://localhost:8080/PromptSharing5_JSP
echo   - 로그 확인: C:/tomcat9/logs/catalina.out
echo   - 재배포: maven-all.cmd 다시 실행
echo.

pause 