rem Use %SendKeys% to send keys to the keyboard buffer
rem set SendKeys=CScript //nologo //E:JScript "%~F0"

set SERVER_PATH=C:\A_Rust_Server

@echo off
:start

cd %SERVER_PATH%

call !GetCustomServerUpdates.cmd

cd %SERVER_PATH%

call "%SERVER_PATH%\!StartServer-RunEXE.cmd" < nul

goto checker


:checker
cls
timeout /t 5
C:\WINDOWS\SYSTEM32\tasklist | find "RustDedicated.exe" >nul
Taskkill /f /IM RustDedicated.exe
if errorlevel 1 (
	timeout /t 5 >nul
	goto start
)
goto checker