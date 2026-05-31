<#
.SYNOPSIS
    Copies the built Flutter release APK to the Desktop with an optional custom suffix.
.DESCRIPTION
    This script locates the release APK at "build\app\outputs\flutter-apk\app-release.apk",
    appends an optional suffix if provided, and copies it to the user's Desktop.
.PARAMETER Suffix
    An optional suffix to append to the target filename (e.g. 'v1.0.0').
#>
param (
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$Suffix
)

# Resolve the absolute path of the APK
# If running as a script, $PSScriptRoot points to the folder containing copy_apk.ps1.
# Since it is in "scripts\" folder, we go one folder up to find the "build\" directory.
$SourcePath = Join-Path $PSScriptRoot "..\build\app\outputs\flutter-apk\app-release.apk"

# Fallback to current directory path if running interactively
if (-not (Test-Path $SourcePath)) {
    $SourcePath = Resolve-Path "build\app\outputs\flutter-apk\app-release.apk" -ErrorAction SilentlyContinue
}

if (-not $SourcePath -or -not (Test-Path $SourcePath)) {
    Write-Host "Error: APK file not found. Please make sure you are in the Flutter root directory and have run 'flutter build apk'." -ForegroundColor Red
    exit 1
}

# Dynamically locate the current user's Desktop folder
$DesktopPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"))

# Formulate the target filename
if ([string]::IsNullOrWhiteSpace($Suffix)) {
    $TargetName = "app-release.apk"
} else {
    # Sanitize invalid characters from the suffix
    $SanitizedSuffix = $Suffix -replace '[\\/:*?"<>|]', ''
    $TargetName = "$SanitizedSuffix.apk"
}

$TargetPath = Join-Path $DesktopPath $TargetName

try {
    Copy-Item -Path $SourcePath -Destination $TargetPath -Force
    Write-Host "--------------------------------------------------------" -ForegroundColor Gray
    Write-Host "Success: APK copied successfully to Desktop!" -ForegroundColor Green
    Write-Host "Path: $TargetPath" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------------" -ForegroundColor Gray
} catch {
    Write-Host "Error: Failed to copy APK: $_" -ForegroundColor Red
}
