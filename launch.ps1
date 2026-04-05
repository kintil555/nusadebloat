# ============================================================
#   NUSADEBLOAT - IRM Launcher
#   Cara pakai (PowerShell as Admin):
#   irm https://raw.githubusercontent.com/YourUser/Nusadebloat/main/launch.ps1 | iex
#
#   Atau jika file lokal, jalankan:
#   irm file:///C:/path/to/launch.ps1 | iex
# ============================================================

Write-Host ""
Write-Host "  ██████╗ ██╗      ██████╗  █████╗ ████████╗██╗    ██╗ █████╗ ██████╗ ███████╗" -ForegroundColor Green
Write-Host "  ██╔══██╗██║     ██╔═══██╗██╔══██╗╚══██╔══╝██║    ██║██╔══██╗██╔══██╗██╔════╝" -ForegroundColor Green
Write-Host "  ██████╔╝██║     ██║   ██║███████║   ██║   ██║ █╗ ██║███████║██████╔╝█████╗  " -ForegroundColor Green
Write-Host "  ██╔══██╗██║     ██║   ██║██╔══██║   ██║   ██║███╗██║██╔══██║██╔══██╗██╔══╝  " -ForegroundColor Green
Write-Host "  ██████╔╝███████╗╚██████╔╝██║  ██║   ██║   ╚███╔███╔╝██║  ██║██║  ██║███████╗" -ForegroundColor Green
Write-Host "  ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝    ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  ██╗  ██╗██╗   ██╗███╗   ██╗████████╗███████╗██████╗ " -ForegroundColor Cyan
Write-Host "  ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗" -ForegroundColor Cyan
Write-Host "  ███████║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝" -ForegroundColor Cyan
Write-Host "  ██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗" -ForegroundColor Cyan
Write-Host "  ██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║" -ForegroundColor Cyan
Write-Host "  ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Windows Debloat & Tweak Tool  |  Run as Administrator" -ForegroundColor DarkGray
Write-Host "  ─────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

# Check admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "  [!] PERHATIAN: Script ini harus dijalankan sebagai Administrator!" -ForegroundColor Red
    Write-Host "      Buka PowerShell sebagai Admin lalu jalankan ulang." -ForegroundColor Yellow
    Write-Host ""
    pause
    exit
}

Write-Host "  [✓] Berjalan sebagai Administrator" -ForegroundColor Green

# Download & run main script
$tmpPath = "$env:TEMP\Nusadebloat.ps1"

Write-Host "  [*] Mengunduh Nusadebloat..." -ForegroundColor Cyan

$scriptUrl = "https://raw.githubusercontent.com/kintil555/nusadebloat/main/Nusadebloat.ps1"

try {
    # Download dengan encoding UTF-8 agar emoji & karakter unicode tidak rusak
    $response = Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing -ErrorAction Stop
    # Tulis TANPA BOM — karena dijalankan via & (bukan iex), BOM akan bikin error "term '?#' not recognized"
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($tmpPath, $response.Content, $utf8NoBom)
    Write-Host "  [✓] Download selesai." -ForegroundColor Green
} catch {
    Write-Host "  [!] Tidak bisa download dari URL. Mencari file lokal..." -ForegroundColor Yellow
    # Fallback: cari di direktori script saat ini atau desktop
    $localPaths = @(
        "$PSScriptRoot\Nusadebloat.ps1",
        "$env:USERPROFILE\Desktop\Nusadebloat.ps1",
        ".\Nusadebloat.ps1"
    )
    $found = $false
    foreach ($p in $localPaths) {
        if (Test-Path $p) {
            Copy-Item $p $tmpPath -Force
            $found = $true
            Write-Host "  [✓] Ditemukan file lokal: $p" -ForegroundColor Green
            break
        }
    }
    if (-not $found) {
        Write-Host "  [✗] File Nusadebloat.ps1 tidak ditemukan!" -ForegroundColor Red
        Write-Host "      Pastikan Nusadebloat.ps1 ada di folder yang sama atau di Desktop." -ForegroundColor Yellow
        pause
        exit
    }
}

Write-Host "  [*] Membuka Nusadebloat GUI..." -ForegroundColor Cyan
Write-Host ""

# Set execution policy temporarily & run
Set-ExecutionPolicy Bypass -Scope Process -Force -EA SilentlyContinue
& $tmpPath -NoAdmin

Write-Host ""
Write-Host "  [*] Nusadebloat ditutup." -ForegroundColor DarkGray
