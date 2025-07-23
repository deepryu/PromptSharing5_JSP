@echo off
chcp 65001 > nul
echo ================================================================
echo 🌐 한글 깨짐 방지 - UTF-8 인코딩 종합 설정
echo ================================================================
echo [INFO] GitHub 푸시 시 한글 깨짐을 완전히 방지하는 설정을 적용합니다.
echo.

echo 1단계: Windows 콘솔 UTF-8 설정...
echo [SUCCESS] 코드 페이지 65001 (UTF-8) 적용 완료

echo.
echo 2단계: PowerShell UTF-8 출력 설정...
powershell -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8"
echo [SUCCESS] PowerShell UTF-8 설정 완료

echo.
echo 3단계: Git 인코딩 설정 (한글 깨짐 방지)...
git config core.quotepath false
git config i18n.commitencoding utf-8
git config i18n.logoutputencoding utf-8
git config core.precomposeunicode true
git config core.autocrlf true
echo [SUCCESS] Git UTF-8 인코딩 설정 완료

echo.
echo 4단계: Maven UTF-8 환경변수 설정...
set MAVEN_OPTS=-Dfile.encoding=UTF-8 -Dconsole.encoding=UTF-8 -Dproject.build.sourceEncoding=UTF-8
echo [SUCCESS] Maven UTF-8 환경변수 설정 완료

echo.
echo ================================================================
echo ✅ 한글 깨짐 방지 설정 완료!
echo ================================================================
echo.
echo 📋 적용된 설정:
echo   - Windows 콘솔: UTF-8 (CP65001)
echo   - PowerShell: UTF-8 출력 인코딩
echo   - Git 커밋 인코딩: UTF-8
echo   - Git 로그 출력: UTF-8
echo   - Git 파일명 표시: 한글 깨짐 방지
echo   - Maven 빌드: UTF-8 강화
echo.
echo 🚀 향후 권장사항:
echo   1. 커밋 메시지는 영어 사용 권장
echo      예: "Fix UI issues", "Add new features", "Update documentation"
echo   2. 푸시 전 이 스크립트 실행 권장
echo   3. JSP 파일은 UTF-8 BOM 없이 저장
echo.
echo ⚠️  주의: 이 설정은 현재 세션에만 적용됩니다.
echo    영구 적용을 위해서는 시스템 환경변수에 추가하세요.
echo.
pause 