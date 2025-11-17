<#
.SYNOPSIS
    Downloads and installs the LATEST rcon-cli for Windows from GitHub releases.

.DESCRIPTION
    - Fetches latest version via GitHub API
    - Finds Windows ZIP (e.g., *-win64.zip) and downloads it
    - Extracts rcon.exe to a specified folder (handles subfolder nesting)
    - Skips if already downloaded and up-to-date

.PARAMETER InstallPath
    Path to install rcon.exe (default: C:\Tools\rcon-cli)

.EXAMPLE
    .\getRconCli.ps1 -InstallPath "C:\MyTools"
#>

param(
    [string]$InstallPath = ".\rcon-cli"
)

# Configuration
$ApiUrl = "https://api.github.com/repos/gorcon/rcon-cli/releases/latest"
$LogPath = "$InstallPath\install.log"
$ZipFile = $null  # Initialize early to avoid null errors
$ExeName = "rcon.exe"

# Function to write logs
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    Write-Host $LogEntry
    Add-Content -Path $LogPath -Value $LogEntry -ErrorAction SilentlyContinue
}

# Create install directory
if (-not (Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    Write-Log "Created directory: $InstallPath"
} else {
    Write-Log "Directory exists: $InstallPath"
}

# Check if already installed and get current version
$ExePath = Join-Path $InstallPath $ExeName
$CurrentVersion = "0.0.0"
if (Test-Path $ExePath) {
    try {
        $VersionOutput = & $ExePath --version 2>$null
        if ($VersionOutput -match "v(\d+\.\d+\.\d+)") {
            $CurrentVersion = $matches[1]
        } else {
            $CurrentVersion = "unknown"
        }
    } catch {
        $CurrentVersion = "unknown"
    }
    Write-Log "Current installed version: v$CurrentVersion"
}

try {
    # Fetch latest version from GitHub API
    Write-Log "Fetching latest release from API: $ApiUrl"
    $Headers = @{ "User-Agent" = "PowerShell" }  # GitHub API requires User-Agent
    $ApiResponse = Invoke-RestMethod -Uri $ApiUrl -Headers $Headers -ErrorAction Stop
    $Version = $ApiResponse.tag_name -replace '^v', ''  # e.g., "0.10.3"
    Write-Log "Latest version detected: v$Version"

    # Skip if up-to-date
    if ($CurrentVersion -eq $Version) {
        Write-Log "Already up-to-date with v$Version. Skipping download." "INFO"
        Write-Host "No update needed! Run 'rcon --help' to test."
        return
    }

    # Find Windows ZIP asset (prefer win64, fallback to win32)
    $AssetsList = ($ApiResponse.assets | ForEach-Object { $_.name }) -join ', '
    Write-Log "Available assets: $AssetsList" "DEBUG"

    $ZipAsset = $ApiResponse.assets | Where-Object { $_.name -match ".*-win64\.(zip|tar\.gz)$" }
    if (-not $ZipAsset) {
        $ZipAsset = $ApiResponse.assets | Where-Object { $_.name -match ".*-win32\.(zip|tar\.gz)$" }
    }
    if (-not $ZipAsset) {
        throw "No Windows ZIP/TAR.GZ found for v$Version. Available: $AssetsList"
    }
    $ZipUrl = $ZipAsset.browser_download_url
    $ZipFile = "$env:TEMP\$($ZipAsset.name)"
    Write-Log "Selected ZIP asset: $($ZipAsset.name)"

    # Download ZIP
    Write-Log "Downloading from: $ZipUrl"
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipFile -UseBasicParsing -ErrorAction Stop
    Write-Log "Download complete: $ZipFile"

    # Clear previous extraction (for clean re-run)
    Get-ChildItem -Path $InstallPath -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

    # Extract ZIP (or TAR.GZ if needed)
    Write-Log "Extracting to: $InstallPath"
    if ($ZipAsset.name -match '\.tar\.gz$') {
        # Handle TAR.GZ (rare for Windows)
        tar -xzf $ZipFile -C $InstallPath
    } else {
        Expand-Archive -Path $ZipFile -DestinationPath $InstallPath -Force -ErrorAction Stop
    }
    Write-Log "Extraction complete."

    # List extracted files for debug
    $ExtractedFiles = Get-ChildItem -Path $InstallPath -Recurse | ForEach-Object { $_.FullName }
    Write-Log "Extracted files: $($ExtractedFiles -join '; ')" "DEBUG"

    # Clean up ZIP
    if ($ZipFile -and (Test-Path $ZipFile)) {
        Remove-Item $ZipFile -Force -ErrorAction SilentlyContinue
        Write-Log "Cleaned up temporary ZIP file."
    }

    # Find and move rcon.exe to root if in subfolder
    $FoundExe = Get-ChildItem -Path $InstallPath -Recurse -Name $ExeName -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $FoundExe) {
        throw "rcon.exe not found anywhere in extracted files. Contents: $($ExtractedFiles -join '; ')"
    }

    if ($FoundExe -ne $ExeName) {
        # It's in a subfolder (e.g., "rcon-0.10.3/rcon.exe") — move to root
        $SubfolderPath = Join-Path $InstallPath (Split-Path $FoundExe -Parent)
        $SourceExe = Join-Path $SubfolderPath $ExeName
        Move-Item -Path $SourceExe -Destination $ExePath -Force
        Write-Log "Moved rcon.exe from subfolder '$SubfolderPath' to root: $InstallPath"
        
        # Optional: Clean up empty subfolder
        if ((Get-ChildItem $SubfolderPath -Recurse | Measure-Object).Count -eq 0) {
            Remove-Item $SubfolderPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "Cleaned up empty subfolder: $SubfolderPath"
        }
    } else {
        Write-Log "rcon.exe already in root."
    }

    # Verify
    if (Test-Path $ExePath) {
        $NewVersionCheck = & $ExePath --version 2>$null
        Write-Log "Installation verified. New version: $NewVersionCheck"
        Write-Host "Success! Latest rcon.exe (v$Version) installed to: $ExePath"
        Write-Host "Test it: cd '$InstallPath'; .\rcon.exe --help"
    } else {
        throw "Final move failed: rcon.exe not in root after processing."
    }
} catch {
    $ErrorMsg = $_.Exception.Message
    Write-Log "Error: $ErrorMsg" "ERROR"
    Write-Host "Failed to download/install latest version. Check log: $LogPath" -ForegroundColor Red
    if ($ZipFile -and (Test-Path $ZipFile)) {
        Remove-Item $ZipFile -Force -ErrorAction SilentlyContinue
        Write-Log "Cleaned up partial ZIP file due to error."
    }
    exit 1
}

# Create log file header if new
if (-not (Test-Path $LogPath)) {
    "rcon-cli Latest Installation Log (fetched v$Version)`n" | Out-File $LogPath
}