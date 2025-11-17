param(
    [string]$ServerPath = "C:\A_Rust_Server\live",
    [switch]$RestartServer = $false
)

function Write-Log($m){ $t = (Get-Date -Format "yyyy-MM-dd HH:mm:ss"); "$t - $m"; }

$exeName = "RustDedicated.exe"
Write-Host (Write-Log "ServerPath = $ServerPath")

$proc = Get-Process -Name "RustDedicated" -ErrorAction SilentlyContinue
if ($proc) {
    Write-Host (Write-Log "RustDedicated process detected. Stopping...")
    $proc | Stop-Process -Force
    Start-Sleep -Seconds 2
}

$repo = "CarbonCommunity/Carbon"
$apiUrl = "https://api.github.com/repos/$repo/releases/latest"
$zipPath = Join-Path $env:TEMP "carbon_windows_latest.zip"

try {
    Write-Host (Write-Log "Fetching latest release info from GitHub...")
    $releaseInfo = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
    # Updated filter
    $asset = $releaseInfo.assets | Where-Object { $_.name -match "^Carbon\.Windows\.(Release|Full)\.zip$" } | Select-Object -First 1
    if (-not $asset) {
        Write-Host (Write-Log "Available assets:")
        $releaseInfo.assets | ForEach-Object { Write-Host "  " + $_.name }
        throw "No suitable Windows zip asset found in latest release."
    }
    $downloadUrl = $asset.browser_download_url
    Write-Host (Write-Log "Latest Windows Carbon asset: $($asset.name)")
    Write-Host (Write-Log "Downloading from: $downloadUrl")
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing -TimeoutSec 60
} catch {
    Write-Error "Failed to fetch/download Carbon release: $($_.Exception.Message)"
    exit 1
}

# Backup existing carbon folder
$carbonDir = Join-Path $ServerPath "carbon"
if (Test-Path $carbonDir) {
    $backupDir = Join-Path $env:TEMP ("carbon_backup_{0}" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
    Copy-Item -Path $carbonDir -Destination $backupDir -Recurse -Force
    Write-Host (Write-Log "Backed up existing carbon folder -> $backupDir")
}

Write-Host (Write-Log "Extracting Carbon into $ServerPath...")
try {
    Expand-Archive -Path $zipPath -DestinationPath $ServerPath -Force -ErrorAction Stop
} catch {
    Write-Error "Extraction failed: $($_.Exception.Message)"
    exit 1
}

Remove-Item -Force $zipPath -ErrorAction SilentlyContinue
Write-Host (Write-Log "Carbon installed successfully.")

if ($RestartServer) {
    $serverExePath = Join-Path $ServerPath $exeName
    if (Test-Path $serverExePath) {
        Write-Host (Write-Log "Starting RustDedicated.exe...")
        Start-Process -FilePath $serverExePath
    } else {
        Write-Host (Write-Log "RustDedicated.exe not found; cannot start server automatically.")
    }
}

Write-Host (Write-Log "Done.")
