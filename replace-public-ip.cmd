@echo off
setlocal EnableDelayedExpansion

REM ==========================
REM Get public IP address using ipinfo.io
REM ==========================
for /f "delims=" %%i in ('curl -s ipinfo.io/ip') do set "publicIP=%%i"
echo Public IP Address: !publicIP!

REM ==========================
REM Check if script path parameter is provided
REM ==========================
if "%~1"=="" (
    echo Please provide the path to your server.cfg as a parameter.
    exit /b 1
)

set "cfgFile=%~1"
if not exist "%cfgFile%" (
    echo ERROR: File not found: %cfgFile%
    exit /b 1
)

REM ==========================
REM Prepare temporary file
REM ==========================
set "tempFile=%temp%\tempServerCfg_%random%.cfg"

REM ==========================
REM Replace server.ip line (robust: no findstr warnings)
REM ==========================
(
    for /f "usebackq delims=" %%a in ("%cfgFile%") do (
        set "line=%%a"
        REM Trim and check if starts with "server.ip" (case-insensitive-ish)
        set "trimmed=!line: =!"
        set "trimmed=!trimmed:~0,9!"
        if /i "!trimmed!"=="server.ip" (
            echo server.ip "!publicIP!"
        ) else (
            echo(!line!
        )
    )
) > "%tempFile%"

REM ==========================
REM Replace original file + verify
REM ==========================
move /y "%tempFile%" "%cfgFile%" >nul
if !errorlevel! neq 0 (
    echo ERROR: Failed to update %cfgFile%
    exit /b 1
)

echo Updated server.ip in %cfgFile% to !publicIP!
echo.
echo VERIFY: Check your server.cfg now contains ^<server.ip "75.172.104.96"^>