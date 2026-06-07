@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ============================================
echo   LangFlow Oracle Deploy Script
echo   Group - gmedical-ai-assistant
echo ============================================
echo.

docker --version >nul 2>&1
if %errorlevel% neq 0 (
  echo [ERROR] Docker not installed or not running
  pause
  exit /b 1
)

set SCRIPT_DIR=%~dp0
cd /d %SCRIPT_DIR%

set CONTAINER_NAME=gmedical-ai-assistant-langflow
set IMAGE_NAME=langflow-oracle:latest
set NETWORK=ai-assistant-network
set NETWORK_ALIAS=ai-assistant-flow
set HOST_PORT=7800
set INNER_PORT=7860

REM Check if image exists, offer to build if not
docker inspect --type=image %IMAGE_NAME% >nul 2>&1
if %errorlevel% neq 0 (
  echo [WARN] Image not found: %IMAGE_NAME%
  set /p build=Build image now? (Y/N):
