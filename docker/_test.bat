@echo off
chcp 65001 >/dev/null
echo line1 ok
setlocal enabledelayedexpansion
echo line2 ok
set CONTAINER_NAME=gmedical-ai-assistant-langflow
echo line3 ok
set IMAGE_NAME=langflow-oracle:latest
echo line4 ok
docker inspect --type=image %IMAGE_NAME% >/dev/null 2>&1
echo line5 errorlevel=%errorlevel%
if %errorlevel% neq 0 (
  echo image not found
) else (
  echo image found ok
)
echo line6 ok
docker network inspect ai-assistant-network >/dev/null 2>&1
echo line7 network errorlevel=%errorlevel%
echo DONE
