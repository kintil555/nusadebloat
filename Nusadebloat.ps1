# ============================================================
#   NUSADEBLOAT - Windows Debloat & Tweak Tool
#   By: Nusadebloat | Run via: irm <url> | iex
#   Requires: PowerShell 5.1+ | Run as Administrator
#   Encoding: ASCII-safe (emoji via ConvertFromUtf32)
# ============================================================

param([switch]$NoAdmin)

# Emoji helpers - PS5.1 compatible, no literal unicode in source
function E { param([int]$cp) [System.Char]::ConvertFromUtf32($cp) }
$ico_shield  = E 0x1F6E1  # shield
$ico_wrench  = E 0x2699   # gear
$ico_scan    = E 0x1F50D  # magnifier
$ico_log     = E 0x1F4CB  # clipboard
$ico_trash   = E 0x1F5D1  # trash
$ico_check   = E 0x2713   # check mark
$ico_cross   = E 0x2717   # cross mark
$ico_warn    = E 0x26A0   # warning triangle
$ico_restart = E 0x27F3   # restart arrow
$ico_arrow   = E 0x2192   # right arrow
$ico_play    = E 0x25B6   # play triangle

# --- Admin check ---
if (-not $NoAdmin) {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "`n[!] Nusadebloat memerlukan hak Administrator." -ForegroundColor Red
        Write-Host "    Jalankan PowerShell sebagai Administrator lalu coba lagi.`n" -ForegroundColor Yellow
        pause
        exit
    }
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================================
#   COLORS & THEME
# ============================================================
$BG      = [System.Drawing.Color]::FromArgb(15, 15, 15)
$BG2     = [System.Drawing.Color]::FromArgb(25, 25, 25)
$BG3     = [System.Drawing.Color]::FromArgb(35, 35, 35)
$ACCENT  = [System.Drawing.Color]::FromArgb(0, 180, 120)
$FG      = [System.Drawing.Color]::FromArgb(220, 220, 220)
$FG2     = [System.Drawing.Color]::FromArgb(150, 150, 150)
$RED     = [System.Drawing.Color]::FromArgb(220, 60, 60)
$YELLOW  = [System.Drawing.Color]::FromArgb(230, 180, 0)
$BLUE    = [System.Drawing.Color]::FromArgb(60, 140, 220)
$BORDER  = [System.Drawing.Color]::FromArgb(50, 50, 50)

# ============================================================
#   DATA: TWEAKS
# ============================================================
$TweakCategories = [ordered]@{
    "Privacy & Telemetry" = @(
        @{ Name="Disable Telemetry & Data Collection"; Safe=$true; Desc="Matikan pengiriman data diagnostik ke Microsoft."; Action={
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force -EA SilentlyContinue
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Force -EA SilentlyContinue
        }}
        @{ Name="Disable Activity History"; Safe=$true; Desc="Nonaktifkan riwayat aktivitas Windows Timeline."; Action={
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -Force -EA SilentlyContinue
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -Force -EA SilentlyContinue
        }}
        @{ Name="Disable Location Tracking"; Safe=$true; Desc="Matikan layanan lokasi sistem."; Action={
            $p = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"
            If(!(Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
            Set-ItemProperty -Path $p -Name "DisableLocation" -Value 1 -Force -EA SilentlyContinue
        }}
        @{ Name="Disable Advertising ID"; Safe=$true; Desc="Matikan ID iklan untuk tracking app."; Action={
            $p = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
            If(!(Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
            Set-ItemProperty -Path $p -Name "Enabled" -Value 0 -Force -EA SilentlyContinue
        }}
        @{ Name="Disable Feedback Requests"; Safe=$true; Desc="Hentikan Windows meminta feedback/rating."; Action={
            $p = "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"
            If(!(Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
            Set-ItemProperty -Path $p -Name "NumberOfSIUFInPeriod" -Value 0 -Force -EA SilentlyContinue
        }}
        @{ Name="Disable App Diagnostics"; Safe=$true; Desc="Larang app mengakses info diagnostik."; Action={
            $p = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2297E4E2-5DBE-466D-A3B6-4C50D5B93473}"
            If(!(Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
            Set-ItemProperty -Path $p -Name "Value" -Value "Deny" -Force -EA SilentlyContinue
        }}
        @{ Name="Disable Error Reporting"; Safe=$true; Desc="Hentikan Windows Error Reporting mengirim laporan."; Action={
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Value 1 -Force -EA SilentlyContinue
            Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" -EA SilentlyContinue | Out-Null
        }}
    )
    "UI & Experience" = @(
        @{ Name="Disable Copilot (Windows 11)"; Safe=$true; Desc="Nonaktifkan tombol dan panel Copilot AI dari taskbar."; Action={
            $p1 = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
            $p2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
            If(!(Test-Path $p1)) { New-Item -Path $p1 -Force | Out-Null }
            If(!(Test-Path $p2)) { New-Item -Path $p2 -Force | Out-Null }
            Set-ItemProperty -Path $p1 -Name "TurnOffWindowsCopilot" -Value 1 -Force -EA SilentlyContinue
            Set-ItemProperty -Path $p2 -Name "TurnOffWindowsCopilot" -Value 1 -Force -EA SilentlyContinue
        }}
        @{ Name="Disable Bing Search in Start Menu"; Safe=$true; Desc="Hapus hasil pencarian web Bing dari Start Menu."; Action={
            $p = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
            Set-ItemProperty -Path $p -Name "BingSearchEnabled" -Value 0 -Force -EA SilentlyContinue
            Set-ItemProperty -Path $p -Name "CortanaConsent" -Value 0 -Force -EA SilentlyContinue
        }}
        @{ Name="Disable Windows Widgets"; Safe=$true; Desc="Sembunyikan panel Widgets dari taskbar."; Action={
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Force -EA SilentlyContinue
        }}
        @{ Name="Show File Extensions"; Safe=$true; Desc="Tampilkan ekstensi file (.exe, .txt, dll) di Explorer."; Action={
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Force -EA SilentlyContinue
        }}
        @{ Name="Show Hidden Files"; Safe=$true; Desc="Tampilkan file dan folder tersembunyi di Explorer."; Action={
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -Force -EA SilentlyContinue
        }}
        @{ Name="Disable Snap Assist Suggestions"; Safe=$true; Desc="Matikan saran layout Snap Assist saat snap jendela."; Action={
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SnapAssist" -Value 0 -Force -EA SilentlyContinue
        }}
        @{ Name="Classic Right-Click Menu (Win11)"; Safe=$true; Desc="Pulihkan menu klik kanan klasik Windows 10 di Windows 11."; Action={
            $p = "HKCU:\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
            If(!(Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
            Set-ItemProperty -Path $p -Name "(default)" -Value "" -Force -EA SilentlyContinue
        }}
        @{ Name="Disable Start Menu Recommendations"; Safe=$true; Desc="Sembunyikan rekomendasi file/app di Start Menu."; Action={
            $p = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
            If(!(Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
            Set-ItemProperty -Path $p -Name "HideRecommendedSection" -Value 1 -Force -EA SilentlyContinue
        }}
        @{ Name="Disable Tips and Suggestions Notifications"; Safe=$true; Desc="Hentikan notifikasi tips Windows dan saran iklan."; Action={
            $cdm = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            Set-ItemProperty -Path $cdm -Name "SubscribedContent-338389Enabled" -Value 0 -Force -EA SilentlyContinue
            Set-ItemProperty -Path $cdm -Name "SubscribedContent-338393Enabled" -Value 0 -Force -EA SilentlyContinue
            Set-ItemProperty -Path $cdm -Name "SubscribedContent-353694Enabled" -Value 0 -Force -EA SilentlyContinue
        }}
        @{ Name="Disable Lock Screen Ads Spotlight"; Safe=$true; Desc="Matikan iklan dan konten Spotlight di lock screen."; Action={
            $cdm = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            Set-ItemProperty -Path $cdm -Name "RotatingLockScreenEnabled" -Value 0 -Force -EA SilentlyContinue
            Set-ItemProperty -Path $cdm -Name "SubscribedContent-338387Enabled" -Value 0 -Force -EA SilentlyContinue
        }}
        @{ Name="Disable Mouse Acceleration"; Safe=$true; Desc="Matikan akselerasi pointer mouse (bagus untuk gaming)."; Action={
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Force -EA SilentlyContinue
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Force -EA SilentlyContinue
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Force -EA SilentlyContinue
        }}
    )
    "Performance" = @(
        @{ Name="Set Power Plan to High Performance"; Safe=$true; Desc="Ubah power plan ke High Performance untuk kecepatan maksimal."; Action={
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
        }}
        @{ Name="Disable SysMain (Superfetch)"; Safe=$true; Desc="Matikan Superfetch yang bisa bikin HDD bekerja keras."; Action={
            Stop-Service -Name "SysMain" -Force -EA SilentlyContinue
            Set-Service -Name "SysMain" -StartupType Disabled -EA SilentlyContinue
        }}
        @{ Name="Disable Windows Search Indexing [CAUTION]"; Safe=$false; Desc="[CAUTION] Matikan indexing pencarian. Start Menu search jadi lebih lambat."; Action={
            Stop-Service -Name "WSearch" -Force -EA SilentlyContinue
            Set-Service -Name "WSearch" -StartupType Disabled -EA SilentlyContinue
        }}
        @{ Name="Disable Hibernation"; Safe=$true; Desc="Hapus hiberfil.sys dan matikan hibernasi untuk hemat disk."; Action={
            powercfg /hibernate off 2>$null
        }}
        @{ Name="Disable Visual Effects Performance Mode"; Safe=$true; Desc="Set visual effects ke best performance untuk sistem lebih responsif."; Action={
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force -EA SilentlyContinue
        }}
        @{ Name="Disable Startup Delay"; Safe=$true; Desc="Hapus delay startup untuk boot app lebih cepat."; Action={
            $p = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize"
            If(!(Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
            Set-ItemProperty -Path $p -Name "StartupDelayInMSec" -Value 0 -Force -EA SilentlyContinue
        }}
        @{ Name="Enable TRIM for SSD"; Safe=$true; Desc="Aktifkan TRIM otomatis untuk menjaga performa SSD."; Action={
            fsutil behavior set DisableDeleteNotify 0 2>$null
        }}
        @{ Name="Disable Background App Refresh"; Safe=$true; Desc="Matikan refresh app di background untuk hemat RAM dan CPU."; Action={
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Force -EA SilentlyContinue
        }}
    )
    "Services" = @(
        @{ Name="Disable Fax Service"; Safe=$true; Desc="Matikan layanan Fax yang jarang dipakai."; Action={
            Stop-Service -Name "Fax" -Force -EA SilentlyContinue
            Set-Service -Name "Fax" -StartupType Disabled -EA SilentlyContinue
        }}
        @{ Name="Disable Print Spooler - No Printer [CAUTION]"; Safe=$false; Desc="[CAUTION] Matikan Print Spooler jika tidak punya printer."; Action={
            Stop-Service -Name "Spooler" -Force -EA SilentlyContinue
            Set-Service -Name "Spooler" -StartupType Disabled -EA SilentlyContinue
        }}
        @{ Name="Disable Remote Registry"; Safe=$true; Desc="Matikan akses registry dari remote (keamanan)."; Action={
            Stop-Service -Name "RemoteRegistry" -Force -EA SilentlyContinue
            Set-Service -Name "RemoteRegistry" -StartupType Disabled -EA SilentlyContinue
        }}
        @{ Name="Disable Xbox Live Services"; Safe=$true; Desc="Matikan semua layanan Xbox Live jika tidak pakai Xbox."; Action={
            "XblAuthManager","XblGameSave","XboxGipSvc","XboxNetApiSvc" | ForEach-Object {
                Stop-Service -Name $_ -Force -EA SilentlyContinue
                Set-Service -Name $_ -StartupType Disabled -EA SilentlyContinue
            }
        }}
        @{ Name="Disable Windows Insider Service"; Safe=$true; Desc="Matikan layanan Windows Insider jika tidak ikut program beta."; Action={
            Stop-Service -Name "wisvc" -Force -EA SilentlyContinue
            Set-Service -Name "wisvc" -StartupType Disabled -EA SilentlyContinue
        }}
        @{ Name="Disable Connected User Experiences DiagTrack"; Safe=$true; Desc="Matikan layanan telemetri pengguna terhubung."; Action={
            Stop-Service -Name "DiagTrack" -Force -EA SilentlyContinue
            Set-Service -Name "DiagTrack" -StartupType Disabled -EA SilentlyContinue
        }}
        @{ Name="Disable Touch Keyboard Service"; Safe=$true; Desc="Matikan layanan keyboard sentuh jika tidak pakai touchscreen."; Action={
            Stop-Service -Name "TabletInputService" -Force -EA SilentlyContinue
            Set-Service -Name "TabletInputService" -StartupType Disabled -EA SilentlyContinue
        }}
        @{ Name="Disable WAP Push Service"; Safe=$true; Desc="Matikan layanan WAP Push (tidak diperlukan di desktop)."; Action={
            Stop-Service -Name "dmwappushservice" -Force -EA SilentlyContinue
            Set-Service -Name "dmwappushservice" -StartupType Disabled -EA SilentlyContinue
        }}
    )
    "Scheduled Tasks" = @(
        @{ Name="Disable Customer Experience Tasks"; Safe=$true; Desc="Nonaktifkan task CEIP yang mengirim data ke Microsoft."; Action={
            "Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
            "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
            "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" | ForEach-Object {
                Disable-ScheduledTask -TaskName $_ -EA SilentlyContinue | Out-Null
            }
        }}
        @{ Name="Disable Auto-Update Maps Task"; Safe=$true; Desc="Nonaktifkan task update peta otomatis Windows Maps."; Action={
            Disable-ScheduledTask -TaskName "Microsoft\Windows\Maps\MapsUpdateTask" -EA SilentlyContinue | Out-Null
        }}
        @{ Name="Disable MUI Cache Update Task"; Safe=$true; Desc="Nonaktifkan task cache bahasa yang berjalan di background."; Action={
            Disable-ScheduledTask -TaskName "Microsoft\Windows\MUI\LPRemove" -EA SilentlyContinue | Out-Null
        }}
        @{ Name="Disable Disk Diagnostics Task"; Safe=$true; Desc="Nonaktifkan task diagnostik disk otomatis."; Action={
            Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" -EA SilentlyContinue | Out-Null
        }}
        @{ Name="Disable Xbox Game Save Task"; Safe=$true; Desc="Nonaktifkan task sinkronisasi game save Xbox."; Action={
            "Microsoft\XblGameSave\XblGameSaveTask","Microsoft\XblGameSave\XblGameSaveTaskLogon" | ForEach-Object {
                Disable-ScheduledTask -TaskName $_ -EA SilentlyContinue | Out-Null
            }
        }}
        @{ Name="Disable Office Telemetry Tasks"; Safe=$true; Desc="Nonaktifkan task telemetri Microsoft Office."; Action={
            "Microsoft\Office\OfficeTelemetryAgentLogOn","Microsoft\Office\OfficeTelemetryAgentFallBack","Microsoft\Office\Office Automatic Updates" | ForEach-Object {
                Disable-ScheduledTask -TaskName $_ -EA SilentlyContinue | Out-Null
            }
        }}
    )
    "Cleanup" = @(
        @{ Name="Clear Temp Files"; Safe=$true; Desc="Hapus file temp dari %TEMP%, C:\Windows\Temp, dan Prefetch."; Action={
            Remove-Item -Path "$env:TEMP\*" -Recurse -Force -EA SilentlyContinue
            Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -EA SilentlyContinue
            Remove-Item -Path "C:\Windows\Prefetch\*" -Force -EA SilentlyContinue
        }}
        @{ Name="Clear DNS Cache"; Safe=$true; Desc="Flush cache DNS untuk mengatasi masalah koneksi."; Action={
            ipconfig /flushdns 2>$null | Out-Null
        }}
        @{ Name="Clear Event Logs"; Safe=$true; Desc="Bersihkan semua Event Log Windows."; Action={
            Get-EventLog -List -EA SilentlyContinue | ForEach-Object { Clear-EventLog -LogName $_.Log -EA SilentlyContinue }
        }}
        @{ Name="Clear Windows Update Cache"; Safe=$true; Desc="Hapus cache Windows Update untuk bebaskan ruang disk."; Action={
            Stop-Service -Name wuauserv -Force -EA SilentlyContinue
            Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -EA SilentlyContinue
            Start-Service -Name wuauserv -EA SilentlyContinue
        }}
        @{ Name="Clear Browser Caches Edge Chrome"; Safe=$true; Desc="Hapus cache browser Edge dan Chrome."; Action={
            @(
                "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\Cache_Data",
                "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\Cache_Data"
            ) | ForEach-Object { if(Test-Path $_) { Remove-Item -Path "$_\*" -Recurse -Force -EA SilentlyContinue } }
        }}
        @{ Name="Run Disk Cleanup cleanmgr"; Safe=$true; Desc="Jalankan Disk Cleanup otomatis dengan semua opsi."; Action={
            cleanmgr /sagerun:1 2>$null
        }}
        @{ Name="Rebuild Icon Cache"; Safe=$true; Desc="Reset icon cache yang rusak atau blank di Explorer."; Action={
            Stop-Process -Name explorer -Force -EA SilentlyContinue
            Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*" -Force -EA SilentlyContinue
            Start-Process explorer
        }}
    )
}

# ============================================================
#   DATA: KNOWN BLOATWARE
# ============================================================
$KnownBloatware = @(
    @{ Pattern="*3dbuilder*";             Name="3D Builder";                Category="Microsoft App" }
    @{ Pattern="*BingNews*";              Name="Bing News";                  Category="Microsoft App" }
    @{ Pattern="*BingWeather*";           Name="Bing Weather";               Category="Microsoft App" }
    @{ Pattern="*BingFinance*";           Name="Bing Finance";               Category="Microsoft App" }
    @{ Pattern="*BingSports*";            Name="Bing Sports";                Category="Microsoft App" }
    @{ Pattern="*GetHelp*";               Name="Get Help";                   Category="Microsoft App" }
    @{ Pattern="*Getstarted*";            Name="Get Started Tips";           Category="Microsoft App" }
    @{ Pattern="*MicrosoftOfficeHub*";    Name="Office Hub";                 Category="Microsoft App" }
    @{ Pattern="*MicrosoftSolitaire*";    Name="Microsoft Solitaire";        Category="Microsoft Game" }
    @{ Pattern="*MixedReality*";          Name="Mixed Reality Portal";       Category="Microsoft App" }
    @{ Pattern="*windowsalarms*";         Name="Alarms and Clock";           Category="Microsoft App" }
    @{ Pattern="*windowsmaps*";           Name="Windows Maps";               Category="Microsoft App" }
    @{ Pattern="*WindowsFeedback*";       Name="Feedback Hub";               Category="Microsoft App" }
    @{ Pattern="*windowscommunications*"; Name="Mail and Calendar";          Category="Microsoft App" }
    @{ Pattern="*ZuneMusic*";             Name="Groove Music";               Category="Microsoft App" }
    @{ Pattern="*ZuneVideo*";             Name="Movies and TV";              Category="Microsoft App" }
    @{ Pattern="*People*";               Name="People App";                 Category="Microsoft App" }
    @{ Pattern="*SkypeApp*";              Name="Skype";                      Category="Microsoft App" }
    @{ Pattern="*Microsoft.Todos*";       Name="Microsoft To-Do";            Category="Microsoft App" }
    @{ Pattern="*YourPhone*";             Name="Your Phone Phone Link";      Category="Microsoft App" }
    @{ Pattern="*XboxApp*";               Name="Xbox App";                   Category="Xbox/Gaming" }
    @{ Pattern="*XboxGameOverlay*";       Name="Xbox Game Bar Overlay";      Category="Xbox/Gaming" }
    @{ Pattern="*XboxGamingOverlay*";     Name="Xbox Gaming Overlay";        Category="Xbox/Gaming" }
    @{ Pattern="*XboxIdentityProvider*";  Name="Xbox Identity Provider";     Category="Xbox/Gaming" }
    @{ Pattern="*XboxSpeechToText*";      Name="Xbox Speech To Text";        Category="Xbox/Gaming" }
    @{ Pattern="*Clipchamp*";             Name="Clipchamp Video Editor";     Category="Microsoft App" }
    @{ Pattern="*MicrosoftTeams*";        Name="Microsoft Teams Personal";   Category="Microsoft App" }
    @{ Pattern="*549981C3F5F10*";         Name="Cortana";                    Category="Microsoft AI" }
    @{ Pattern="*Disney*";               Name="Disney+";                    Category="3rd Party" }
    @{ Pattern="*Spotify*";              Name="Spotify";                    Category="3rd Party" }
    @{ Pattern="*TikTok*";               Name="TikTok";                     Category="3rd Party" }
    @{ Pattern="*Netflix*";              Name="Netflix";                    Category="3rd Party" }
    @{ Pattern="*Amazon*";               Name="Amazon Prime Video";         Category="3rd Party" }
    @{ Pattern="*instagram*";            Name="Instagram";                  Category="3rd Party" }
    @{ Pattern="*Facebook*";             Name="Facebook";                   Category="3rd Party" }
    @{ Pattern="*Twitter*";              Name="Twitter X";                  Category="3rd Party" }
    @{ Pattern="*LinkedIn*";             Name="LinkedIn";                   Category="3rd Party" }
    @{ Pattern="*Flipboard*";            Name="Flipboard";                  Category="3rd Party" }
    @{ Pattern="*Candy*";               Name="Candy Crush";                Category="3rd Party Game" }
    @{ Pattern="*farmville*";            Name="FarmVille";                  Category="3rd Party Game" }
    @{ Pattern="*EclipseManager*";       Name="Eclipse Manager";            Category="OEM Bloat" }
    @{ Pattern="*ActiproSoftware*";      Name="Actipro Software Tools";     Category="OEM Bloat" }
    @{ Pattern="*DolbyAccess*";          Name="Dolby Access";               Category="OEM App" }
    @{ Pattern="*CyberLink*";            Name="CyberLink Media Suite";      Category="OEM App" }
    @{ Pattern="*McAfee*";              Name="McAfee Security";            Category="OEM Bloat" }
    @{ Pattern="*Norton*";              Name="Norton Security";            Category="OEM Bloat" }
    @{ Pattern="*Avast*";               Name="Avast Antivirus";            Category="3rd Party" }
    @{ Pattern="*ACGMediaPlayer*";       Name="ACG Media Player";           Category="3rd Party" }
    @{ Pattern="*AdobePhotoshopExpress*";Name="Adobe Photoshop Express";   Category="3rd Party" }
    @{ Pattern="*Duolingo*";             Name="Duolingo";                   Category="3rd Party" }
    @{ Pattern="*PandoraMedia*";         Name="Pandora";                    Category="3rd Party" }
    @{ Pattern="*Wunderlist*";           Name="Wunderlist";                 Category="3rd Party" }
    @{ Pattern="*windowscamera*";        Name="Windows Camera";             Category="Microsoft App" }
    @{ Pattern="*onenote*";              Name="OneNote";                    Category="Microsoft App" }
    @{ Pattern="*onedrive*";             Name="OneDrive";                   Category="Microsoft App" }
    @{ Pattern="*OfficeOneNote*";        Name="Office OneNote";             Category="Microsoft App" }
    @{ Pattern="*PowerAutomateDesktop*"; Name="Power Automate Desktop";     Category="Microsoft App" }
    @{ Pattern="*QuickAssist*";          Name="Quick Assist";               Category="Microsoft App" }
)

# ============================================================
#   HELPER FUNCTIONS
# ============================================================
function New-StyledButton {
    param($Text, $X, $Y, $W=160, $H=34, $FgColor=$FG, $BgColor=$BG3, $Font=$null)
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text      = $Text
    $btn.Location  = New-Object System.Drawing.Point($X,$Y)
    $btn.Size      = New-Object System.Drawing.Size($W,$H)
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.FlatAppearance.BorderSize  = 1
    $btn.FlatAppearance.BorderColor = $BORDER
    $btn.BackColor  = $BgColor
    $btn.ForeColor  = $FgColor
    $btn.Cursor     = [System.Windows.Forms.Cursors]::Hand
    if ($Font) { $btn.Font = $Font } else { $btn.Font = New-Object System.Drawing.Font("Segoe UI", 9) }
    return $btn
}

function New-Label {
    param($Text, $X, $Y, $W=300, $H=20, $Color=$FG, $FontSize=9, $Bold=$false)
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text      = $Text
    $lbl.Location  = New-Object System.Drawing.Point($X,$Y)
    $lbl.Size      = New-Object System.Drawing.Size($W,$H)
    $lbl.ForeColor = $Color
    $style = if($Bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $lbl.Font      = New-Object System.Drawing.Font("Segoe UI", $FontSize, $style)
    $lbl.BackColor = [System.Drawing.Color]::Transparent
    return $lbl
}

# ============================================================
#   BUILD MAIN FORM
# ============================================================
$form = New-Object System.Windows.Forms.Form
$form.Text            = "Nusadebloat - Windows Debloat Tool"
$form.Size            = New-Object System.Drawing.Size(1000, 700)
$form.MinimumSize     = New-Object System.Drawing.Size(1000, 700)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $BG
$form.ForeColor       = $FG
$form.Font            = New-Object System.Drawing.Font("Segoe UI", 9)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox     = $false

# --- HEADER BAR ---
$header = New-Object System.Windows.Forms.Panel
$header.Size      = New-Object System.Drawing.Size(1000, 60)
$header.Location  = New-Object System.Drawing.Point(0, 0)
$header.BackColor = $BG2
$form.Controls.Add($header)

$lblTitle = New-Label "$ico_shield  NUSADEBLOAT" 18 16 280 30 $ACCENT 14 $true
$header.Controls.Add($lblTitle)

$lblSub = New-Label "Windows Debloat and Tweak Tool  -  Run as Administrator" 300 22 420 20 $FG2 9
$header.Controls.Add($lblSub)

$lblVer = New-Label "v1.1  |  Win10/11" 840 22 140 20 $FG2 8
$header.Controls.Add($lblVer)

# --- TAB STRIP ---
$tabStrip = New-Object System.Windows.Forms.Panel
$tabStrip.Size      = New-Object System.Drawing.Size(1000, 38)
$tabStrip.Location  = New-Object System.Drawing.Point(0, 60)
$tabStrip.BackColor = $BG3
$form.Controls.Add($tabStrip)

# Content panels
$pnlTweaks = New-Object System.Windows.Forms.Panel
$pnlBloat  = New-Object System.Windows.Forms.Panel
$pnlLog    = New-Object System.Windows.Forms.Panel

foreach ($pnl in @($pnlTweaks, $pnlBloat, $pnlLog)) {
    $pnl.Size      = New-Object System.Drawing.Size(1000, 560)
    $pnl.Location  = New-Object System.Drawing.Point(0, 98)
    $pnl.BackColor = $BG
    $pnl.Visible   = $false
    $form.Controls.Add($pnl)
}

# --- STATUS BAR ---
$statusBar = New-Object System.Windows.Forms.Panel
$statusBar.Size      = New-Object System.Drawing.Size(1000, 42)
$statusBar.Location  = New-Object System.Drawing.Point(0, 658)
$statusBar.BackColor = $BG2
$form.Controls.Add($statusBar)

$lblStatus = New-Label "Siap. Pilih tweak atau scan bloatware." 16 12 700 22 $FG2 9
$statusBar.Controls.Add($lblStatus)

$btnRestart = New-StyledButton "$ico_restart  Restart Sekarang" 810 6 168 30 $YELLOW $BG3
$statusBar.Controls.Add($btnRestart)
$btnRestart.Add_Click({
    $res = [System.Windows.Forms.MessageBox]::Show(
        "Restart komputer sekarang untuk menerapkan semua perubahan?",
        "Konfirmasi Restart",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    if ($res -eq "Yes") { shutdown /r /t 5 /c "Nusadebloat: Restarting to apply changes..." }
})

# ---- TAB BUTTONS ----
$tabButtons = @()
$tabDefs = @(
    @{ Text="  $ico_wrench  Tweaks and Debloat"; Panel=$pnlTweaks }
    @{ Text="  $ico_scan  Scan Bloatware";       Panel=$pnlBloat  }
    @{ Text="  $ico_log  Log Output";             Panel=$pnlLog    }
)
$tx = 0
foreach ($td in $tabDefs) {
    $tb = New-Object System.Windows.Forms.Button
    $tb.Text      = $td.Text
    $tb.Size      = New-Object System.Drawing.Size(200, 38)
    $tb.Location  = New-Object System.Drawing.Point($tx, 0)
    $tb.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $tb.FlatAppearance.BorderSize = 0
    $tb.BackColor = $BG3
    $tb.ForeColor = $FG2
    $tb.Font      = New-Object System.Drawing.Font("Segoe UI", 9)
    $tb.Cursor    = [System.Windows.Forms.Cursors]::Hand
    $tabStrip.Controls.Add($tb)
    $tabButtons += $tb
    $tx += 200
    $targetPanel = $td.Panel
    $tb.Add_Click({
        param($s,$e)
        foreach ($p in @($pnlTweaks,$pnlBloat,$pnlLog)) { $p.Visible = $false }
        foreach ($t in $tabButtons) { $t.BackColor = $BG3; $t.ForeColor = $FG2 }
        $targetPanel.Visible = $true
        $s.BackColor = $BG2; $s.ForeColor = $ACCENT
    }.GetNewClosure())
}

# ============================================================
#   BUILD TWEAKS PANEL
# ============================================================
$pnlTweaks.Visible = $true
$tabButtons[0].BackColor = $BG2; $tabButtons[0].ForeColor = $ACCENT

$catPanel = New-Object System.Windows.Forms.Panel
$catPanel.Size      = New-Object System.Drawing.Size(200, 560)
$catPanel.Location  = New-Object System.Drawing.Point(0, 0)
$catPanel.BackColor = $BG2
$pnlTweaks.Controls.Add($catPanel)

New-Label "KATEGORI" 16 14 160 16 $FG2 8 $true | ForEach-Object { $catPanel.Controls.Add($_) }

$tweakScroll = New-Object System.Windows.Forms.Panel
$tweakScroll.Size       = New-Object System.Drawing.Size(800, 490)
$tweakScroll.Location   = New-Object System.Drawing.Point(200, 0)
$tweakScroll.BackColor  = $BG
$tweakScroll.AutoScroll = $true
$pnlTweaks.Controls.Add($tweakScroll)

$tweakActionBar = New-Object System.Windows.Forms.Panel
$tweakActionBar.Size      = New-Object System.Drawing.Size(800, 70)
$tweakActionBar.Location  = New-Object System.Drawing.Point(200, 490)
$tweakActionBar.BackColor = $BG2
$pnlTweaks.Controls.Add($tweakActionBar)

$btnSelAll   = New-StyledButton "Pilih Semua"    10  18 120 34 $FG $BG3
$btnDeselAll = New-StyledButton "Batalkan Semua" 138 18 140 34 $FG $BG3
$boldFont10  = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$btnApply    = New-StyledButton "$ico_play  Terapkan Tweak" 490 14 200 42 $BG $ACCENT $boldFont10
$btnApply.FlatAppearance.BorderColor = $ACCENT
$tweakActionBar.Controls.Add($btnSelAll)
$tweakActionBar.Controls.Add($btnDeselAll)
$tweakActionBar.Controls.Add($btnApply)

New-Label "Pilih tweak lalu klik Terapkan." 286 22 200 22 $FG2 8 | ForEach-Object { $tweakActionBar.Controls.Add($_) }

$script:activeCatTweaks = @()

function Show-TweakCategory {
    param($catName)
    $tweakScroll.Controls.Clear()
    $script:activeCatTweaks = @()
    $tweaks = $TweakCategories[$catName]
    $y = 14
    foreach ($tweak in $tweaks) {
        $cb = New-Object System.Windows.Forms.CheckBox
        $cb.Text      = $tweak.Name
        $cb.Location  = New-Object System.Drawing.Point(16, $y)
        $cb.Size      = New-Object System.Drawing.Size(560, 22)
        $cb.ForeColor = if($tweak.Safe) { $FG } else { $YELLOW }
        $cb.BackColor = [System.Drawing.Color]::Transparent
        $cb.Font      = New-Object System.Drawing.Font("Segoe UI", 9)
        $cb.Tag       = $tweak
        $tweakScroll.Controls.Add($cb)

        $desc = New-Label $tweak.Desc 36 ($y+22) 740 18 $FG2 8
        $tweakScroll.Controls.Add($desc)

        $script:activeCatTweaks += $cb
        $y += 58
    }
    $tweakScroll.AutoScrollPosition = New-Object System.Drawing.Point(0,0)
}

$catBtnY = 40
$catBtns = @()
foreach ($catName in $TweakCategories.Keys) {
    $cb2 = New-Object System.Windows.Forms.Button
    $cb2.Text      = "  $catName"
    $cb2.Size      = New-Object System.Drawing.Size(200, 36)
    $cb2.Location  = New-Object System.Drawing.Point(0, $catBtnY)
    $cb2.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $cb2.FlatAppearance.BorderSize = 0
    $cb2.BackColor = $BG2
    $cb2.ForeColor = $FG2
    $cb2.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $cb2.Font      = New-Object System.Drawing.Font("Segoe UI", 9)
    $cb2.Cursor    = [System.Windows.Forms.Cursors]::Hand
    $catPanel.Controls.Add($cb2)
    $catBtns += $cb2
    $catBtnY += 36
    $cn = $catName
    $cb2.Add_Click({
        param($s,$e)
        foreach($b in $catBtns) { $b.BackColor = $BG2; $b.ForeColor = $FG2 }
        $s.BackColor = $BG3; $s.ForeColor = $ACCENT
        Show-TweakCategory $cn
    }.GetNewClosure())
}
Show-TweakCategory ($TweakCategories.Keys | Select-Object -First 1)
$catBtns[0].BackColor = $BG3; $catBtns[0].ForeColor = $ACCENT

$btnSelAll.Add_Click({   foreach($c in $script:activeCatTweaks) { $c.Checked = $true } })
$btnDeselAll.Add_Click({ foreach($c in $script:activeCatTweaks) { $c.Checked = $false } })

# ============================================================
#   LOG BOX (shared)
# ============================================================
$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Size        = New-Object System.Drawing.Size(960, 510)
$logBox.Location    = New-Object System.Drawing.Point(20, 14)
$logBox.BackColor   = $BG2
$logBox.ForeColor   = $FG
$logBox.Font        = New-Object System.Drawing.Font("Consolas", 9)
$logBox.ReadOnly    = $true
$logBox.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$logBox.ScrollBars  = [System.Windows.Forms.RichTextBoxScrollBars]::Vertical
$pnlLog.Controls.Add($logBox)

$btnClearLog = New-StyledButton "Bersihkan Log" 20 532 130 24 $FG2 $BG3
$pnlLog.Controls.Add($btnClearLog)
$btnClearLog.Add_Click({ $logBox.Clear() })

function Write-Log {
    param($msg, $color = "White")
    $form.Invoke([Action]{
        $logBox.SelectionStart  = $logBox.TextLength
        $logBox.SelectionLength = 0
        $colorMap = @{
            "White"  = $FG
            "Green"  = $ACCENT
            "Red"    = $RED
            "Yellow" = $YELLOW
            "Cyan"   = $BLUE
            "Gray"   = $FG2
        }
        $logBox.SelectionColor = $colorMap[$color]
        $ts = (Get-Date).ToString("HH:mm:ss")
        $logBox.AppendText("[$ts] $msg`n")
        $logBox.ScrollToCaret()
    })
}

$btnApply.Add_Click({
    $selected = $script:activeCatTweaks | Where-Object { $_.Checked }
    if ($selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Pilih minimal satu tweak terlebih dahulu.","Tidak ada yang dipilih",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }
    foreach ($p in @($pnlTweaks,$pnlBloat,$pnlLog)) { $p.Visible = $false }
    foreach ($t in $tabButtons) { $t.BackColor = $BG3; $t.ForeColor = $FG2 }
    $pnlLog.Visible = $true
    $tabButtons[2].BackColor = $BG2; $tabButtons[2].ForeColor = $ACCENT

    $btnApply.Enabled = $false
    $lblStatus.Text   = "Menerapkan tweaks..."

    $job = [System.Threading.Thread]::new({
        Write-Log "=== Mulai menerapkan $($selected.Count) tweak ===" "Cyan"
        foreach ($cb in $selected) {
            $tw = $cb.Tag
            Write-Log "$ico_arrow $($tw.Name)" "Gray"
            try {
                & $tw.Action
                Write-Log "  $ico_check Berhasil" "Green"
            } catch {
                Write-Log "  $ico_cross Error: $($_.Exception.Message)" "Red"
            }
        }
        Write-Log "=== Selesai! Restart mungkin diperlukan. ===" "Cyan"
        $form.Invoke([Action]{
            $btnApply.Enabled = $true
            $lblStatus.Text   = "Tweaks selesai. Restart jika diperlukan."
        })
    })
    $job.IsBackground = $true
    $job.Start()
})

# ============================================================
#   BUILD BLOAT PANEL
# ============================================================
$pnlBloat.BackColor = $BG

New-Label "$ico_scan  Scan Bloatware" 20 14 300 26 $ACCENT 13 $true | ForEach-Object { $pnlBloat.Controls.Add($_) }
New-Label "Scan sistem untuk mendeteksi aplikasi bloatware yang terinstal, lalu pilih mana yang ingin dihapus." 20 44 760 18 $FG2 9 | ForEach-Object { $pnlBloat.Controls.Add($_) }

$btnScan = New-StyledButton "$ico_scan  Scan Bloatware" 20 70 170 38 $BG $ACCENT $boldFont10
$btnScan.FlatAppearance.BorderColor = $ACCENT
$pnlBloat.Controls.Add($btnScan)

$btnSelAllBloat   = New-StyledButton "Pilih Semua"    200 78 120 28 $FG $BG3
$btnDeselAllBloat = New-StyledButton "Batalkan Semua" 328 78 130 28 $FG $BG3
$btnRemoveBloat   = New-StyledButton "$ico_trash  Hapus Terpilih" 750 70 200 38 $RED $BG3 $boldFont10
$btnRemoveBloat.FlatAppearance.BorderColor = $RED
$pnlBloat.Controls.Add($btnSelAllBloat)
$pnlBloat.Controls.Add($btnDeselAllBloat)
$pnlBloat.Controls.Add($btnRemoveBloat)

$lblScanStatus = New-Label "Belum di-scan. Klik 'Scan Bloatware' untuk memulai." 20 116 760 20 $FG2 9
$pnlBloat.Controls.Add($lblScanStatus)

$bloatView = New-Object System.Windows.Forms.ListView
$bloatView.Size          = New-Object System.Drawing.Size(960, 370)
$bloatView.Location      = New-Object System.Drawing.Point(20, 140)
$bloatView.BackColor     = $BG2
$bloatView.ForeColor     = $FG
$bloatView.Font          = New-Object System.Drawing.Font("Segoe UI", 9)
$bloatView.View          = [System.Windows.Forms.View]::Details
$bloatView.FullRowSelect = $true
$bloatView.CheckBoxes    = $true
$bloatView.BorderStyle   = [System.Windows.Forms.BorderStyle]::None
$bloatView.GridLines     = $true
$bloatView.Columns.Add("Nama Aplikasi", 300) | Out-Null
$bloatView.Columns.Add("Kategori", 160)      | Out-Null
$bloatView.Columns.Add("Package Name", 460)  | Out-Null
$pnlBloat.Controls.Add($bloatView)

$lblRemovedCount = New-Label "" 20 518 500 24 $FG2 9
$pnlBloat.Controls.Add($lblRemovedCount)

$script:detectedBloat = @()

$btnScan.Add_Click({
    $btnScan.Enabled    = $false
    $lblScanStatus.Text = "Sedang scan... Harap tunggu."
    $bloatView.Items.Clear()
    $script:detectedBloat = @()

    $job = [System.Threading.Thread]::new({
        Write-Log "=== Mulai scan bloatware ===" "Cyan"
        $found  = @()
        $allPkg = Get-AppxPackage -AllUsers -EA SilentlyContinue

        foreach ($b in $KnownBloatware) {
            $match = $allPkg | Where-Object { $_.Name -like $b.Pattern }
            foreach ($pkg in $match) {
                $found += @{ Name=$b.Name; Category=$b.Category; PackageName=$pkg.Name; FullPkg=$pkg }
                Write-Log "  Ditemukan: $($b.Name) [$($b.Category)]" "Yellow"
            }
        }

        $form.Invoke([Action]{
            $script:detectedBloat = $found
            $bloatView.Items.Clear()
            if ($found.Count -eq 0) {
                $lblScanStatus.Text      = "$ico_check Tidak ada bloatware terdeteksi. Sistem bersih!"
                $lblScanStatus.ForeColor = $ACCENT
            } else {
                foreach ($f in $found) {
                    $item = New-Object System.Windows.Forms.ListViewItem($f.Name)
                    $item.SubItems.Add($f.Category)    | Out-Null
                    $item.SubItems.Add($f.PackageName) | Out-Null
                    $item.Tag = $f
                    $bloatView.Items.Add($item) | Out-Null
                }
                $lblScanStatus.Text      = "$ico_warn  Ditemukan $($found.Count) bloatware. Pilih yang ingin dihapus."
                $lblScanStatus.ForeColor = $YELLOW
            }
            $btnScan.Enabled = $true
        })
        Write-Log "=== Scan selesai. Ditemukan $($found.Count) bloatware ===" "Cyan"
    })
    $job.IsBackground = $true
    $job.Start()
})

$btnSelAllBloat.Add_Click({   foreach($i in $bloatView.Items) { $i.Checked = $true } })
$btnDeselAllBloat.Add_Click({ foreach($i in $bloatView.Items) { $i.Checked = $false } })

$btnRemoveBloat.Add_Click({
    $toRemove = $bloatView.CheckedItems
    if ($toRemove.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Centang minimal satu aplikasi untuk dihapus.","Tidak ada yang dipilih",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Hapus $($toRemove.Count) aplikasi yang dipilih?`n`nProses ini tidak dapat dibatalkan tanpa reinstall dari Microsoft Store.",
        "Konfirmasi Hapus",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    if ($confirm -ne "Yes") { return }

    foreach ($p in @($pnlTweaks,$pnlBloat,$pnlLog)) { $p.Visible = $false }
    foreach ($t in $tabButtons) { $t.BackColor = $BG3; $t.ForeColor = $FG2 }
    $pnlLog.Visible = $true
    $tabButtons[2].BackColor = $BG2; $tabButtons[2].ForeColor = $ACCENT

    $itemsToRemove = @()
    foreach ($item in $toRemove) { $itemsToRemove += $item.Tag }
    $btnRemoveBloat.Enabled = $false

    $job = [System.Threading.Thread]::new({
        Write-Log "=== Mulai hapus $($itemsToRemove.Count) bloatware ===" "Cyan"
        $successCount = 0
        foreach ($b in $itemsToRemove) {
            Write-Log "$ico_arrow Menghapus: $($b.Name) ($($b.PackageName))" "Gray"
            try {
                Get-AppxPackage -Name $b.PackageName -AllUsers -EA SilentlyContinue |
                    Remove-AppxPackage -AllUsers -EA SilentlyContinue
                Get-AppxProvisionedPackage -Online -EA SilentlyContinue |
                    Where-Object { $_.DisplayName -like "*$($b.PackageName)*" -or $_.PackageName -like "*$($b.PackageName)*" } |
                    Remove-AppxProvisionedPackage -Online -AllUsers -EA SilentlyContinue | Out-Null
                Write-Log "  $ico_check Berhasil dihapus" "Green"
                $successCount++
            } catch {
                Write-Log "  $ico_cross Gagal: $($_.Exception.Message)" "Red"
            }
        }
        Write-Log "=== Selesai. $successCount dari $($itemsToRemove.Count) berhasil dihapus. ===" "Cyan"
        $form.Invoke([Action]{
            $btnRemoveBloat.Enabled    = $true
            $lblStatus.Text            = "$successCount bloatware dihapus. Restart mungkin diperlukan."
            $lblRemovedCount.Text      = "$ico_check $successCount dari $($itemsToRemove.Count) berhasil dihapus."
            $lblRemovedCount.ForeColor = $ACCENT
        })
    })
    $job.IsBackground = $true
    $job.Start()
})

# ============================================================
#   SHOW FORM
# ============================================================
[System.Windows.Forms.Application]::EnableVisualStyles()
$form.Add_Shown({ $form.Activate() })
$form.ShowDialog() | Out-Null
