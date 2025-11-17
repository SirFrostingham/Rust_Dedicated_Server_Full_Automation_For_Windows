#=====================================================================
# Rust Dedicated Server - Update Detector & Auto-Restarter
# Uses rcon-cli WebSocket RCON for player count
#=====================================================================

# CONFIG
$AppID        = 258550
$SteamCMD     = "C:\Program Files (x86)\Steam\steamcmd.exe"
$InstallDir   = "C:\A_Rust_Server\live"
$ManifestFile = "$InstallDir\steamapps\appmanifest_$AppID.acf"
$RestartFile  = "$InstallDir\server_should_restart.txt"
$RconCliExe   = "C:\A_Rust_Server\rcon-cli\rcon.exe"
$RconHost     = "127.0.0.1:28016"
$RconPass     = "MySecretPassword"
$ShutdownCmd  = "C:\share\tools\SendSignalCtrlC64\_ShutdownServer_Rust.cmd"
$LogFile      = "$InstallDir\update-check.log"
$DebugFile    = "$InstallDir\steamcmd_debug.txt"

#--------------------------------------
function Write-Log {
    param([string]$msg)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts - $msg" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    Write-Host "$ts - $msg"
}

#--------------------------------------
function Initialize-RestartFile {
    if (-not (Test-Path $RestartFile)) {
        "0" | Out-File -FilePath $RestartFile -Encoding UTF8
        Write-Log "Created $RestartFile with value 0"
    }
}

#--------------------------------------
function Get-RemoteBuildID {
    Write-Log "Fetching remote build ID..."
    $cmd = "& `"$SteamCMD`" +login anonymous +app_info_update 1 +app_info_print $AppID +quit"
    $output = Invoke-Expression $cmd *>&1
    $output | Out-File -FilePath $DebugFile -Encoding UTF8

    $raw = Get-Content $DebugFile -Raw
    $m = [regex]::Match($raw, '"buildid"\s+"(\d+)"')
    if (-not $m.Success) { throw "Remote buildid not found" }
    return [int]$m.Groups[1].Value
}

#--------------------------------------
function Get-LocalBuildID {
    if (-not (Test-Path $ManifestFile)) { throw "Manifest missing" }
    $content = Get-Content $ManifestFile -Raw
    $m = [regex]::Match($content, '"buildid"\s+"(\d+)"', 'IgnoreCase')
    if (-not $m.Success) { throw "Local buildid not found" }
    return [int]$m.Groups[1].Value
}

#--------------------------------------
function Get-PlayerCount {
    try {
        $result = & $RconCliExe -t web --a $RconHost -p $RconPass playerlist 2>&1
        $resultText = ($result -join "`n").Trim()
        Write-Log "RCON output: $resultText"

        # Handle empty list [] → 0 players
        if ($resultText -eq "[]" -or $resultText -eq "") {
            Write-Log "No players online"
            return 0
        }

        # Otherwise count lines of player entries
        $lines = $resultText | Where-Object { $_ -match '\[' }  # crude check for player lines
        $count = $lines.Count
        Write-Log "$count player(s) online"
        return $count
    }
    catch {
        Write-Log "RCON failed: $($_.Exception.Message)"
        return -1  # assume unsafe
    }
}

#--------------------------------------
function Set-RestartFlag {
    param([int]$Value)
    "$Value" | Out-File -FilePath $RestartFile -Encoding UTF8 -Force
    Write-Log "Set $RestartFile = $Value"
}

#=====================================================================
# MAIN
#=====================================================================
try {
    Initialize-RestartFile

    $restartFlag = [int](Get-Content $RestartFile -Raw).Trim()
    $remote      = Get-RemoteBuildID
    $local       = Get-LocalBuildID
    $playerCount = Get-PlayerCount

    Write-Log "Remote: $remote | Local: $local | Flag: $restartFlag | Players: $playerCount"

    # === CASE 1: Update exists AND flag is 0 → SET FLAG TO 1 ===
    if ($remote -gt $local -and $restartFlag -eq 0) {
        Set-RestartFlag 1
        Write-Log "UPDATE DETECTED → set restart flag to 1. Waiting for 0 players..."
    }

    # === CASE 2: Flag is 1 AND 0 players → SHUTDOWN ===
    elseif ($restartFlag -eq 1 -and $playerCount -eq 0) {
        Write-Log "RESTART CONDITIONS MET → shutting down server..."
        if (Test-Path $ShutdownCmd) {
            & $ShutdownCmd
            Write-Log "Shutdown command sent: $ShutdownCmd"
        } else {
            Write-Log "ERROR: Shutdown command not found: $ShutdownCmd"
        }
        Set-RestartFlag 0
        Write-Log "Restart flag reset to 0. Server will reboot via automation."
    }

    # === CASE 3: Flag is 1 but players online → WAIT ===
    elseif ($restartFlag -eq 1 -and $playerCount -gt 0) {
        Write-Log "Restart flag is 1, but $playerCount player(s) online. Waiting..."
    }

    # === CASE 4: No update ===
    else {
        Write-Log "No update available."
    }
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
}
