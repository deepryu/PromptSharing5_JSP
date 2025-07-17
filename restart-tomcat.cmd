@echo off
chcp 65001 >nul
echo ================================================
echo           🚀 Tomcat Restart Script
echo ================================================
echo.

echo 📋 Step 1: Stopping existing Tomcat process...
taskkill /f /im java.exe 2>nul
if %errorlevel% equ 0 (
    echo ✅ Tomcat process terminated successfully.
) else (
    echo ℹ️  No running Tomcat process found.
)

echo.
echo 📋 Step 2: Waiting... (2 seconds)
timeout /t 2 /nobreak >nul

echo.
echo 📋 Step 3: Starting Tomcat...
C:\tomcat9\bin\startup.bat

echo.
echo ================================================
echo      ✅ Tomcat restart completed successfully!
echo         http://localhost:8080/PromptSharing5_JSP
echo ================================================
echo.
pause 