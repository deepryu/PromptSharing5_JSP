@echo off
echo 이력서 파일 업로드 디렉토리 생성 중...

REM 업로드 디렉토리 생성
if not exist "uploads" mkdir uploads
if not exist "uploads\resumes" mkdir uploads\resumes
if not exist "uploads\temp" mkdir uploads\temp

REM 디렉토리 권한 설정 (Windows)
icacls uploads /grant Everyone:(OI)(CI)F

echo.
echo 생성된 디렉토리:
echo - uploads\                (메인 업로드 폴더)
echo - uploads\resumes\        (이력서 파일 저장소)
echo - uploads\temp\           (임시 파일 저장소)
echo.

echo 디렉토리 생성 완료!
echo.
echo 참고사항:
echo 1. 업로드 가능한 파일 형식: PDF, HWP, DOC, DOCX
echo 2. 최대 파일 크기: 10MB
echo 3. 파일명은 자동으로 날짜시간_원본파일명 형식으로 변경됩니다
echo.

pause 