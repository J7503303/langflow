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

REM Check if image exists
docker inspect --type=image %IMAGE_NAME% >nul 2>&1
if %errorlevel% neq 0 goto image_missing
goto deploy

:image_missing
echo [WARN] Image not found - %IMAGE_NAME%
set /p build=Build image now (Y/N)
if /i "%build%"=="Y" goto do_build
echo [INFO] Cancelled - run build.bat first
goto end

:do_build
echo [INFO] Building image...
docker build -f Dockerfile.oracle -t %IMAGE_NAME% .
if %errorlevel% neq 0 (
  echo [ERROR] Build failed
  pause
  exit /b 1
)
echo [OK] Image built

:deploy

REM Ensure network exists
docker network inspect %NETWORK% >nul 2>&1
if %errorlevel% neq 0 (
  echo [INFO] Creating network - %NETWORK%
  docker network create --driver bridge %NETWORK% >nul 2>&1
)

REM Ensure data directories exist
if not exist data mkdir data >nul 2>&1
if not exist data\database mkdir data\database >nul 2>&1
if not exist data\config mkdir data\config >nul 2>&1

echo [INFO] Stopping existing container (if any)...
docker stop %CONTAINER_NAME% >nul 2>&1
docker rm %CONTAINER_NAME% >nul 2>&1

echo.
echo [INFO] Starting container - %CONTAINER_NAME%
docker compose -f docker-compose.oracle.yml -p gmedical-ai-assistant up -d

if %errorlevel% neq 0 (
  echo [ERROR] Container start failed
  pause
  exit /b 1
)
echo [OK] Container started - %CONTAINER_NAME%

echo.
echo [INFO] Waiting for LangFlow to start (30s)...
timeout /t 30 /nobreak >nul

docker exec %CONTAINER_NAME% curl -sf http://localhost:%INNER_PORT%/health_check >nul 2>&1
if %errorlevel% equ 0 (
  echo [OK] LangFlow is healthy
) else (
  echo [INFO] Still starting - check: docker logs %CONTAINER_NAME% --tail 20
)

echo.
echo ============================================
echo [OK] Deploy completed!
echo.
echo Access - http://localhost:%HOST_PORT%
echo Group  - gmedical-ai-assistant
echo Alias  - %NETWORK_ALIAS% on %NETWORK%
echo.
echo ============================================
echo.

:end
pause
exit /b 0
