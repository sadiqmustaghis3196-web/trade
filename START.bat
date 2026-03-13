@echo off
title Trading Platform Startup
color 0A

echo ============================================
echo   TRADING PLATFORM - STARTUP SCRIPT
echo ============================================
echo.

:: Check if Docker is available
docker --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Docker is installed
    goto :docker_start
) else (
    echo [!!] Docker not found. Trying direct Node.js startup...
    goto :node_start
)

:docker_start
echo.
echo Starting with Docker...
echo.

:: Start only Postgres and Redis via docker
cd /d "d:\Client work\crypto site\Trading plateform\server"

echo [1/4] Starting PostgreSQL and Redis containers...
docker run -d --name hollaex-db ^
  -e POSTGRES_DB=hollaex ^
  -e POSTGRES_USER=hollaex ^
  -e POSTGRES_PASSWORD=my-secure-db-password ^
  -p 5432:5432 ^
  postgres:14.9 >nul 2>&1

docker run -d --name hollaex-redis ^
  -p 6379:6379 ^
  redis:alpine ^
  redis-server --requirepass my-secure-redis-password >nul 2>&1

echo [2/4] Waiting 5 seconds for containers to start...
timeout /t 5 /nobreak >nul

echo [3/4] Running database migrations...
cd /d "d:\Client work\crypto site\Trading plateform\server"
call npm run migrate

echo [4/4] Starting Node.js server...
start "API Server" cmd /k "cd /d "d:\Client work\crypto site\Trading plateform\server" && node app.js"

echo.
echo [5/5] Starting Web frontend...
start "Web Frontend" cmd /k "cd /d "d:\Client work\crypto site\Trading plateform\web" && npm start"

echo.
echo ============================================
echo  Server: http://localhost:10010
echo  Web UI: http://localhost:3000
echo ============================================
echo.
echo Both servers are starting in new windows.
pause
goto :eof

:node_start
echo.
echo [!!] Docker not found.
echo.
echo To run this project you need either:
echo   1. Docker Desktop (recommended) - https://www.docker.com/products/docker-desktop/
echo   2. PostgreSQL + Redis installed locally
echo.
echo Please install Docker Desktop and run this script again.
echo.
pause
