[README.md](https://github.com/user-attachments/files/26376364/README.md)
# W A Y Y  T O O L B O X  v3.0
> Auto App Launcher for Termux — Buka banyak app Android via Deep Link otomatis

```
╔══════════════════════════════════════════╗
║   W A Y Y  T O O L B O X  v3.0          ║
║   Auto App Launcher — Termux            ║
╚══════════════════════════════════════════╝
```

---

## ⚡ Install Cepat

```bash
curl -sL https://raw.githubusercontent.com/Wayy1702/mytoolbox/main/install.sh | bash
```

Atau pakai setup lengkap (gaya Dodirebex123):
```bash
. <(curl https://raw.githubusercontent.com/Wayy1702/mytoolbox/main/setup)
```

Setelah install:
```bash
toolbox
```

---

## 🗂 Struktur Repo

```
mytoolbox/
├── mytoolbox.sh    ← Script utama (Bash)
├── install.sh      ← Installer ringkas (1 command)
├── setup           ← Setup lengkap (update + deps + download)
├── ver3            ← Flag versi saat ini (3.0)
└── README.md       ← Dokumentasi ini
```

---

## 📋 Fitur

| Menu | Fungsi |
|------|--------|
| **Setup Configuration** | Atur nama, delay, mode launch, auto rejoin |
| **Edit App List** | Tambah/hapus/edit app, deep link, owner, judul |
| **Run Script** | Launch semua app + Monitor Force Close |
| **Clear App Caches** | Bersihkan cache via `pm clear` |
| **Package Manager** | Install/Uninstall/Download APK |
| **Settings** | Edit config + self-update dari GitHub |
| **About** | Info toolbox |
| **Uninstall** | Hapus semua data toolbox |

---

## 🔄 Auto Rejoin — Force Close Only

Rejoin hanya terjadi jika app **benar-benar force close / crash**.  
Bukan rejoin berkala setiap X detik.

```
[FC#1] GameName [OwnerName] FC! → relaunch...
[OK]   GameName running
```

---

## 📱 Contoh Deep Link

| App | Deep Link |
|-----|-----------|
| WhatsApp | `whatsapp://send?phone=628xxx` |
| Telegram | `tg://resolve?domain=username` |
| YouTube | `youtube://watch?v=VIDEO_ID` |
| Roblox | `roblox://placeId=PLACE_ID` |
| Play Store | `market://details?id=com.pkg.name` |
| URL biasa | `https://google.com` |

---

## 🗂 File Tersimpan

```
~/.mytoolbox/
├── config.cfg      ← konfigurasi user
├── apps.list       ← daftar app & deep link
└── toolbox.log     ← log aktivitas

~/mytoolbox.sh           ← script utama
$PREFIX/bin/toolbox      ← command global
```

---

## 🔧 Requirements

- Termux (Android)
- `curl` / `wget` (auto install)
- `termux-tools` (auto install)
- Clear cache: butuh root atau ADB

---

## 🔄 Update

```bash
toolbox → 6) Settings → 7) Update dari GitHub
```

## ❌ Uninstall

```bash
toolbox → 8) Uninstall Toolbox
```

---

## 📄 License
MIT — [@Wayy1702](https://github.com/Wayy1702)
