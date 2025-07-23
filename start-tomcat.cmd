@echo off
chcp 65001 >nul
echo ================================================
echo           🚀 Tomcat Start Script
echo ================================================
echo.

echo 📋 Starting Tomcat...
C:\tomcat9\bin\startup.bat

echo.
echo ================================================
echo       ✅ Tomcat started successfully!
echo         http://localhost:8080/ATS
echo ================================================ 