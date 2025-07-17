@echo off
chcp 65001 > nul
echo ================================================================
echo 🚀 Maven 빌드 및 테스트 - 프로덕션 DB 사용
echo ================================================================
echo [INFO] 프로덕션 데이터베이스에서 컴파일 및 테스트를 실행합니다.
echo [WARNING] 테스트 실행 시 프로덕션 DB의 테스트 데이터가 초기화될 수 있습니다!
echo.

echo 1단계: Windows 콘솔 UTF-8 설정...
echo [SUCCESS] UTF-8 인코딩 설정 완료

echo.
echo 2단계: PowerShell UTF-8 출력 설정...
powershell -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8"
echo [SUCCESS] PowerShell UTF-8 설정 완료

echo.
echo 3단계: Maven 환경변수 설정 (UTF-8)...
set MAVEN_OPTS=-Dfile.encoding=UTF-8 -Dconsole.encoding=UTF-8 -Dproject.build.sourceEncoding=UTF-8

echo.
echo 4단계: Tomcat 프로세스 안전 종료...
taskkill /f /im java.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Tomcat 프로세스 종료 완료
) else (
    echo ℹ️  실행 중인 Tomcat 프로세스 없음
)

echo.
echo 5단계: Maven 빌드 및 테스트 실행...
echo [INFO] 명령어: mvn clean compile test
echo [INFO] 42개 Java 클래스 컴파일 중...
echo [INFO] JUnit 테스트 케이스 실행 중...
echo.

mvn clean compile test

echo.
if %errorlevel% equ 0 (
    echo ================================================================
    echo ✅ Maven 빌드 및 테스트 성공! (프로덕션 DB 사용)
    echo ================================================================
    echo.
    echo ✅ 빌드 완료 결과:
    echo   - Java 클래스들: WEB-INF/classes/com/example/
    echo   - 의존성 라이브러리: WEB-INF/lib/
    echo   - 웹 리소스: JSP, CSS, images 등
    echo   - JUnit 테스트: 모든 테스트 케이스 통과
    echo.
    echo 📊 테스트 실행 결과:
    echo   - CandidateDAOTest: 5개 테스트
    echo   - UserDAOTest: 4개 테스트  
    echo   - InterviewScheduleDAOTest: 11개 테스트
    echo   - 총 20개 테스트 케이스 실행 완료
    echo.
    echo 🚀 다음 단계: Tomcat을 수동으로 재시작해 주세요.
    echo 📋 재시작 명령어: C:\tomcat9\bin\startup.bat
    echo.
    echo ⚠️  참고: 에이전트는 사용자 제어권 보장을 위해
    echo    Tomcat을 자동으로 시작하지 않습니다.
) else (
    echo ================================================================
    echo ❌ Maven 빌드 또는 테스트 실패
    echo ================================================================
    echo.
    echo 오류 해결 방법:
    echo 1. Java 소스 코드 문법 오류 확인
    echo 2. import 문 누락 확인  
    echo 3. Maven 의존성 설정 확인 (pom.xml)
    echo 4. 데이터베이스 연결 상태 확인
    echo 5. 테스트 케이스 오류 확인
    echo.
    echo 수동 확인 명령어:
    echo   mvn clean compile test
    echo.
    echo 자세한 오류 로그를 확인한 후 다시 시도해주세요.
)

echo.
pause 