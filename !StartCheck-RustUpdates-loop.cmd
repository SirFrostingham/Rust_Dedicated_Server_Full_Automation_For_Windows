rem @echo off
rem setlocal EnableDelayedExpansion

set "SERVER_PATH=C:\A_Rust_Server"
set "SERVER_SETTINGS_PATH=%SERVER_PATH%\live"
set "PS_SCRIPT=Check-RustUpdate.ps1"
set "LOG_FILE=%SERVER_SETTINGS_PATH%\update-check-loop.log"
set "INTERVAL_SECONDS=300"

cd /d "%SERVER_PATH%"

echo [%date% %time%] Starting Rust update loop >> "%LOG_FILE%"
echo   Running: powershell -ExecutionPolicy Bypass -File ".\%PS_SCRIPT%" >> "%LOG_FILE%"
echo   Every %INTERVAL_SECONDS% seconds >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

:loop
    :: --------------------------------------------------------------
    :: RUN UPDATE CHECK
    :: --------------------------------------------------------------
    echo. >> "%LOG_FILE%"
    echo [%date% %time%] === RUNNING: powershell -ExecutionPolicy Bypass -File .\%PS_SCRIPT%

    powershell -ExecutionPolicy Bypass -File ".\%PS_SCRIPT%"

    if errorlevel 1 (
        echo [%date% %time%] ERROR: Exit code %errorlevel% >> "%LOG_FILE%"
    ) else (
        echo [%date% %time%] Success. >> "%LOG_FILE%"
    )

    echo [%date% %time%] Sleeping %INTERVAL_SECONDS% seconds... >> "%LOG_FILE%"
    timeout /t %INTERVAL_SECONDS% /nobreak >nul

goto :loop