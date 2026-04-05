# ============================================================
#   NUSADEBLOAT - IRM Launcher
#   Cara pakai (PowerShell as Admin):
#   irm https://raw.githubusercontent.com/kintil555/nusadebloat/main/launch.ps1 | iex
# ============================================================

Write-Host ""
Write-Host "  ################################################" -ForegroundColor Green
Write-Host "  ##                                            ##" -ForegroundColor Green
Write-Host "  ##   N U S A D E B L O A T   v1.1            ##" -ForegroundColor Green
Write-Host "  ##   Windows Debloat and Tweak Tool           ##" -ForegroundColor Green
Write-Host "  ##                                            ##" -ForegroundColor Green
Write-Host "  ################################################" -ForegroundColor Green
Write-Host ""
Write-Host "  Windows Debloat and Tweak Tool  |  Run as Administrator" -ForegroundColor DarkGray
Write-Host "  ---------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

# Check admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "  [!] Script ini harus dijalankan sebagai Administrator!" -ForegroundColor Red
    Write-Host "      Buka PowerShell sebagai Admin lalu jalankan ulang." -ForegroundColor Yellow
    Write-Host ""
    pause
    exit
}

Write-Host "  [OK] Berjalan sebagai Administrator" -ForegroundColor Green

$tmpPath   = "$env:TEMP\Nusadebloat.ps1"
$scriptUrl = "https://raw.githubusercontent.com/kintil555/nusadebloat/main/Nusadebloat.ps1"

Write-Host "  [*]  Mengunduh Nusadebloat..." -ForegroundColor Cyan

try {
    # Invoke-WebRequest preserves encoding; write file as UTF-8 no BOM
    # so PowerShell does not trip on a BOM when executing via & operator
    $response  = Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing -ErrorAction Stop
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($tmpPath, $response.Content, $utf8NoBom)
    Write-Host "  [OK] Download selesai." -ForegroundColor Green
} catch {
    Write-Host "  [!]  Tidak bisa download dari URL. Mencari file lokal..." -ForegroundColor Yellow
    $localPaths = @(
        "$PSScriptRoot\Nusadebloat.ps1",
        "$env:USERPROFILE\Desktop\Nusadebloat.ps1",
        ".\Nusadebloat.ps1"
    )
    $found = $false
    foreach ($p in $localPaths) {
        if (Test-Path $p) {
            # Copy and re-write as UTF-8 no BOM to be safe
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            $content   = [System.IO.File]::ReadAllText($p)
            [System.IO.File]::WriteAllText($tmpPath, $content, $utf8NoBom)
            $found = $true
            Write-Host "  [OK] Ditemukan file lokal: $p" -ForegroundColor Green
            break
        }
    }
    if (-not $found) {
        Write-Host "  [X]  File Nusadebloat.ps1 tidak ditemukan!" -ForegroundColor Red
        Write-Host "       Pastikan Nusadebloat.ps1 ada di folder yang sama atau di Desktop." -ForegroundColor Yellow
        pause
        exit
    }
}

Write-Host "  [*]  Membuka Nusadebloat GUI..." -ForegroundColor Cyan
Write-Host ""

Set-ExecutionPolicy Bypass -Scope Process -Force -EA SilentlyContinue
& $tmpPath -NoAdmin

Write-Host ""
Write-Host "  [*]  Nusadebloat ditutup." -ForegroundColor DarkGray
