<#
    Publish a new build to the download site.

    Zips dist\IFM Processor, encrypts it under the download credentials, and pushes the
    result to GitHub Pages. The password is typed in here and held only for this process,
    so it is never written to a file, a script or a command line.

    Run it from anywhere:  powershell -ExecutionPolicy Bypass -File tools\publish-build.ps1
#>

[CmdletBinding()]
param(
    [string] $Version  = 'v9.7.3',
    [string] $AppDir   = 'C:\Users\Imran\Downloads\IFM Work Stuff\PDF_Processor\dist\IFM Processor',
    [string] $Python   = 'C:\Users\Imran\Downloads\IFM Work Stuff\PDF_Processor\.venv\Scripts\python.exe'
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo

if (-not (Test-Path $AppDir)) { throw "Build folder not found: $AppDir" }
if (-not (Test-Path $Python)) { throw "Python not found: $Python" }

# The app locks files inside its own folder, so it must not be running while we zip.
Get-Process 'IFM Processor' -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "`nDownload credentials for the site" -ForegroundColor Cyan
$user   = Read-Host 'Username'
$secure = Read-Host 'Password' -AsSecureString
$plain  = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
              [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))

$zip = Join-Path $env:TEMP "IFM_Processor_$Version.zip"

try {
    Write-Host "`nZipping the build ..." -ForegroundColor Cyan
    Compress-Archive -Path $AppDir -DestinationPath $zip -Force

    Write-Host "Encrypting ..." -ForegroundColor Cyan
    $env:DL_USER = $user
    $env:DL_PASS = $plain
    & $Python (Join-Path $PSScriptRoot 'encrypt_payload.py') $zip (Join-Path $repo 'dl\payload.bin')
    if ($LASTEXITCODE -ne 0) { throw 'Encryption failed.' }
}
finally {
    # Nothing readable is left behind: not the secrets, not the plaintext build.
    Remove-Item Env:\DL_USER, Env:\DL_PASS -ErrorAction SilentlyContinue
    $plain = $null
    Remove-Item $zip -Force -ErrorAction SilentlyContinue
}

Write-Host "`nPublishing ..." -ForegroundColor Cyan
git add dl/payload.bin
git commit -q -m "Publish build $Version"
git push -q origin main

Write-Host "`nDone. Live in a minute or two at:" -ForegroundColor Green
Write-Host '  https://imranifm.github.io/ifm-parts-processor/'
