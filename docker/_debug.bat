@echo off
chcp 65001 >nul
echo step1
setlocal enabledelayedexpansion
echo step2
docker --version >/dev/null 2>&1
echo step3 errorlevel=%errorlevel%
if %errorlevel% neq 0 (
  echo docker not found
  pause
  exit /b 1
)
echo step4
set SCRIPT_DIR=%~dp0
echo step5 SCRIPT_DIR=%~dp0
cd /d %SCRIPT_DIR%
echo step6
set IMAGE_NAME=langflow-oracle:latest
echo step7
docker inspect --type=image %IMAGE_NAME% >/dev/null 2>&1
echo step8 errorlevel=%errorlevel%
echo ALL DONE
