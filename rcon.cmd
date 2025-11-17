@echo off
setlocal

:: ============================
:: CONFIG
:: ============================
set RCON_EXE=rcon-cli\rcon.exe
set RCON_HOST=127.0.0.1:28016
set RCON_PASS=MySecretPassword
set GET_RCON_POWERSHELL=getRconCli.ps1

:: ============================
:: CHECK FOR rcon.exe
:: ============================
if not exist "%RCON_EXE%" (
    echo rcon.exe not found. Attempting to download via %GET_RCON_POWERSHELL%...
    if exist "%GET_RCON_POWERSHELL%" (
        powershell -ExecutionPolicy Bypass -File "%GET_RCON_POWERSHELL%"
        if not exist "%RCON_EXE%" (
            echo ERROR: rcon.exe download failed.
            exit /b 1
        ) else (
            echo rcon.exe successfully downloaded.
        )
    ) else (
        echo ERROR: %GET_RCON_POWERSHELL% not found!
        exit /b 1
    )
)

:: ============================
:: COMMAND ROUTER
:: ============================
if "%1"=="" goto :usage

if /I "%1"=="playercount" goto :playercount
if /I "%1"=="players" goto :playercount
if /I "%1"=="save" goto :save
if /I "%1"=="shutdown" goto :shutdown
if /I "%1"=="quit" goto :shutdown
if /I "%1"=="stop" goto :shutdown
if /I "%1"=="message" goto :message
if /I "%1"=="console" goto :console

:: Default = raw passthrough
goto :raw

:playercount
"%RCON_EXE%" -t web --a %RCON_HOST% -p %RCON_PASS% playerlist
goto :eof

:save
"%RCON_EXE%" -t web --a %RCON_HOST% -p %RCON_PASS% server.save
goto :eof

:shutdown
"%RCON_EXE%" -t web --a %RCON_HOST% -p %RCON_PASS% quit
goto :eof

:console
"%RCON_EXE%" -t web --a %RCON_HOST% -p %RCON_PASS%
goto :eof

:message
shift
if "%~1"=="" (
    echo ERROR: No message provided.
    goto :eof
)
:: Join all remaining parameters into one message
set "MSG=%*"
"%RCON_EXE%" -t web --a %RCON_HOST% -p %RCON_PASS% say %MSG%
goto :eof

:raw
shift
"%RCON_EXE%" -t web --a %RCON_HOST% -p %RCON_PASS% %*
goto :eof

:usage
echo Usage:
echo   rcon.cmd playercount
echo   rcon.cmd save
echo   rcon.cmd shutdown
echo   rcon.cmd quit
echo   rcon.cmd console
echo   rcon.cmd message "Your message here"
echo   rcon.cmd any_other_rcon_command