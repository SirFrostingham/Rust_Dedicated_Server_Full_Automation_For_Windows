@echo off

setlocal ENABLEDELAYEDEXPANSION

       :: DEFINE the following variables where applicable to your install

SET STEAMLOGIN=areed99
SET AppId=258550

SET GamePath=C:\A_Rust_Server\live
SET STEAMPATH=C:\Program Files (x86)\Steam


:: _________________________________________________________

echo.
echo     You are about to update Game
echo        Dir: %GamePath%
echo        Branch: %AppId%
echo.
echo     Key "ENTER" yo procede
REM pause

REM REM use anonymous user
REM ECHO "%STEAMPATH%"\steamcmd.exe +login anonymous +force_install_dir "%GamePath%" +app_update %AppId% +quit
REM "%STEAMPATH%"\steamcmd.exe +login anonymous +force_install_dir "%GamePath%" +app_update %AppId% +quit

REM use anonymous user
REM ECHO "%STEAMPATH%"\steamcmd.exe +login anonymous +force_install_dir "%GamePath%" +app_update %AppId% -beta -latest_experimental +quit
REM "%STEAMPATH%"\steamcmd.exe +login anonymous +force_install_dir "%GamePath%" +app_update %AppId% -beta latest_experimental +quit

ECHO "%STEAMPATH%"\steamcmd.exe +force_install_dir "%GamePath%" +login anonymous +app_update %AppId% validate +quit
"%STEAMPATH%"\steamcmd.exe +force_install_dir "%GamePath%" +login anonymous +app_update %AppId% validate +quit

REM remove Steam VALIDATE
REM "%STEAMPATH%"\steamcmd.exe +login anonymous +force_install_dir %GamePath% +"app_update %AppId%" validate +quit

REM mods

echo .
echo     Your Game is now up to date
echo     key "ENTER" to exit
REM pause
rem exit