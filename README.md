# 🛡 NUSADEBLOAT
### Windows Debloat & Tweak Tool
**Ringan • Minimalis • Aman • Open Source**

---

## 🚀 Cara Menjalankan

### Metode 1: Via IRM (Direkomendasikan)
Buka **PowerShell sebagai Administrator**, lalu jalankan:

```powershell
irm https://raw.githubusercontent.com/YourUser/Nusadebloat/main/launch.ps1 | iex
```

### Metode 2: Jalankan Langsung
```powershell
# Buka PowerShell as Admin
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Nusadebloat.ps1
```

### Metode 3: Setup GitHub Sendiri
1. Upload `Nusadebloat.ps1` ke GitHub repo kamu
2. Ganti URL di `launch.ps1` dengan raw URL file tersebut
3. Share `launch.ps1` ke siapapun

---

## ✨ Fitur

### ⚙️ Tab Tweaks & Debloat
Pilih tweak berdasarkan kategori:

| Kategori | Jumlah Tweak | Deskripsi |
|----------|-------------|-----------|
| **Privacy & Telemetry** | 7 | Disable telemetry, location, ads, feedback |
| **UI & Experience** | 11 | Disable Copilot, Bing, Widgets, tips iklan |
| **Performance** | 8 | Power plan, SysMain, visual effects, TRIM |
| **Services** | 8 | Matikan service tidak perlu |
| **Scheduled Tasks** | 6 | Disable task CEIP, Xbox, Office telemetry |
| **Cleanup** | 7 | Hapus cache, DNS flush, event log, temp |

### 🔍 Tab Nusadebloat
- **Scan otomatis** mencari 50+ app bloatware yang terinstal
- Tampilkan nama, kategori, dan package name
- Pilih satu per satu atau pilih semua
- **Hapus permanen** dengan 1 klik (AllUsers + Provisioned)

### 📋 Tab Log Output
- Log real-time semua aksi dengan timestamp
- Kode warna: ✓ Hijau = sukses, ✗ Merah = error
- Bisa dibersihkan kapan saja

### ⟳ Tombol Restart
- Tombol restart langsung tersedia di status bar bawah

---

## 📦 Bloatware yang Bisa Dideteksi

**Microsoft Apps:** 3D Builder, Bing News/Weather/Finance/Sports, Get Help, Tips, Office Hub, Solitaire, Mixed Reality, Mail & Calendar, Groove Music, Movies & TV, People, Skype, To-Do, Your Phone, Clipchamp, Teams (Personal), Cortana, Camera, OneNote, OneDrive, Power Automate, Quick Assist

**Xbox/Gaming:** Xbox App, Game Bar Overlay, Gaming Overlay, Identity Provider, Speech To Text

**3rd Party:** Disney+, Spotify, TikTok, Netflix, Amazon, Instagram, Facebook, Twitter/X, LinkedIn, Flipboard, Candy Crush, FarmVille, Adobe Photoshop Express, Duolingo, Pandora

**OEM Bloat:** McAfee, Norton, Avast, Dolby Access, CyberLink, dll.

---

## ⚠️ Catatan Penting

- Selalu **buat restore point** sebelum menjalankan tweak besar
- Tweak berlabel `[CAUTION]` berwarna **kuning** = perlu hati-hati
- Beberapa perubahan memerlukan **restart** untuk aktif
- App yang dihapus bisa diinstal ulang dari Microsoft Store

---

## 🛡️ Aman?

- Script ini **open source** — kamu bisa lihat setiap baris kode
- Tidak ada download pihak ketiga
- Tidak ada perubahan permanen tanpa konfirmasi
- Semua tweak bisa dibatalkan manual via registry

---

## 🔧 Requirement

- Windows 10 (1903+) atau Windows 11
- PowerShell 5.1+
- **Hak Administrator** (wajib)

---

*Dibuat dengan inspirasi dari ChrisTitus WinUtil & Win11Debloat*
