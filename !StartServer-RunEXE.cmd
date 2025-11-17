
set SERVER_PATH=C:\A_Rust_Server
set SERVER_SETTINGS_PATH=%SERVER_PATH%\live
set SteamAppId=1857950
set "IDENTITY=MyCoolServer"
set "CFG_PATH=%SERVER_SETTINGS_PATH%\server\%IDENTITY%\cfg"
set "CFG_FILE=%CFG_PATH%\server.cfg"

:: === STEP 1: Ensure server.cfg exists ===
if not exist "%CFG_PATH%" (
    echo [INFO] Creating folder: %CFG_PATH%
    mkdir "%CFG_PATH%"
)
REM Ensure directory exists
for %%A in ("%CFG_FILE%") do (
    if not exist "%%~dpA" mkdir "%%~dpA"
)

if not exist "%CFG_FILE%" (
    echo [INFO] Creating server.cfg with default settings...
    > "%CFG_FILE%" (
        echo server.hostname "%IDENTITY% Server - Big Dumn Fun House"
        echo server.identity "%IDENTITY%"
        echo server.description "A server for the dumn"
        echo server.url "https://%IDENTITY%.com"
        echo server.password ""
        echo server.secure true
        echo server.port 28015
        echo server.queryport 28017
        echo rcon.port 28016
        echo rcon.password MySecretPassword
        echo rcon.web 1

        echo # === WORLD ===
        echo server.level "Procedural Map"
        echo server.worldsize 3000
        echo server.seed 93526673
        echo server.saveinterval 600

        echo # === GAMEPLAY ===
        echo server.maxplayers 10
        echo decay.scale 0
        echo craft.instant true
        echo gather.rate 2
        echo suicide.cooldown 0
        echo time.scale 2
        echo heli.lifetimeminutes 0

        echo # === RADIATION ===
        echo radiation.forcedOff true

        echo # === BLUEPRINTS ===
        echo server.blueprints 0

        echo # === AIRDROP ===
        echo airdrop.min_players 999
        echo airdrop.frequency 99999
        echo airdrop.enabled false

        echo # === ANIMALS ===
        echo bear.population 0
        echo boar.population 0
        echo wolf.population 0
        @REM echo stag.population 0
        @REM echo chicken.population 0
        @REM echo horse.population 0

        echo # === PERFORMANCE ===
        echo fps.limit 256
        echo server.tickrate 30

        echo # === CHAT ===
        echo global.chat true
        echo global.voice true
    )
    echo [SUCCESS] server.cfg created at: %CFG_FILE%
) else (
    echo [INFO] server.cfg already exists. Skipping creation.
)


@REM REM This does not work with Rust...
@REM :: ======================================
@REM :: Set PUBLIC IP in server.cfg
@REM :: ======================================
@REM echo [INFO] Updating server.ip in server.cfg to public IP...
@REM call "%SERVER_PATH%\replace-public-ip.cmd" "%CFG_FILE%"

echo echo [%date% %time%] Running getCarbon install...
echo powershell -ExecutionPolicy Bypass -File "%SERVER_PATH%\getCarbon.ps1"
powershell -ExecutionPolicy Bypass -File "%SERVER_PATH%\getCarbon.ps1"


@REM call "%SERVER_PATH%\!StartCheck-RustUpdates-loop.cmd"

echo "Server Starting ... CTRL-C to Shut Down the Server"

cd /d "%SERVER_SETTINGS_PATH%"

start "%IDENTITY%" /wait /high /affinity F "%SERVER_SETTINGS_PATH%\RustDedicated.exe" -log -batchmode ^
  +server.identity "%IDENTITY%" ^
  +server.secure true ^
  +server.maxplayers 10 ^
  +server.seed 93526673 ^
  +server.worldsize 3000 ^
  +server.saveinterval 600 ^
  +rcon.port 28016 ^
  +rcon.password MySecretPassword ^
  +rcon.web 1 ^
  +fps.limit 256
