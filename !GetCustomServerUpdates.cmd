
set SERVER_PATH=C:\A_Rust_Server

@REM call %SERVER_PATH%\replace-public-ip.cmd "%SERVER_PATH%\Game.ini"

cd %SERVER_PATH%

REM Do other updates here if needed

call SteamUpdater.cmd
