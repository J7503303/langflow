@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ============================================
echo   LangFlow Oracle Build Script
echo ============================================
echo.

docker --version >nul 2>&1
if %errorlevel% neq 0 (
  echo [ERROR] Docker not installed or not running
  exit /b 1
)

set SCRIPT_DIR=%~dp0
cd /d %SCRIPT_DIR%

echo [INFO] Building image: langflow-oracle:latest
echo [INFO] Context: %SCRIPT_DIR%
echo.

docker build -f Dockerfile.oracle -t langflow-oracle:latest .
if %errorlevel% neq 0 (
  echo [ERROR] Build failed
  exit /b 1
)

echo.
echo ============================================
echo [OK] Build completed: langflow-oracle:latest
echo.
echo Run deploy.bat to start the container.
echo ============================================
echo.

pause
exit /b 0
