# MY TOOLS BOX v1.0
> Auto App Launcher for Termux — Buka banyak app Android via Deep Link otomatis

```
┌─────────────────────────────────────────────────┐
│          MY TOOLS BOX  v1.0                     │
│          Auto App Launcher — Termux             │
└─────────────────────────────────────────────────┘
```

## ⚡ Install (1 Command)

```bash
curl -sL https://raw.githubusercontent.com/USERNAME/mytoolbox/main/install.sh | bash
```

Setelah install, cukup ketik:
```bash
toolbox
```

---

## 📋 Fitur

| Menu | Fungsi |
|------|--------|
| **Setup Configuration** | Atur nama, delay, mode launch, auto rejoin |
| **Edit App List** | Tambah/hapus/edit app & deep link |
| **Run Script** | Launch semua app (sequential/parallel) + auto rejoin |
| **Clear App Caches** | Bersihkan cache via `pm clear` |
| **Package Manager** | Install/Uninstall/Download APK |
| **Settings** | Edit config + self-update dari GitHub |
| **About** | Info toolbox |
| **Uninstall** | Hapus semua data toolbox |

---

## 📱 Contoh Deep Link

| App | Deep Link |
|-----|-----------|
| WhatsApp | `whatsapp://send?phone=628xxx` |
| Telegram | `tg://resolve?domain=username` |
| YouTube | `youtube://watch?v=VIDEO_ID` |
| Instagram | `instagram://user?username=nama` |
| Play Store | `market://details?id=com.pkg.name` |
| URL biasa | `https://google.com` |
| Telepon | `tel:+628xxxxxxxxxx` |

---

## 🗂 Struktur File

```
~/.mytoolbox/
├── config.cfg      ← konfigurasi user
├── apps.list       ← daftar app & deep link
└── toolbox.log     ← log aktivitas

$PREFIX/bin/toolbox ← command global
```

---

## 🔧 Requirements

- Termux (Android)
- `curl` atau `wget` (auto install saat install)
- `termux-tools` (auto install)
- Untuk clear cache / pm: butuh root atau ADB

---

## 🔄 Update

```bash
toolbox  →  6) Settings  →  7) Update Toolbox dari GitHub
```

atau manual:
```bash
curl -sL https://raw.githubusercontent.com/USERNAME/mytoolbox/main/install.sh | bash
```

---

## ❌ Uninstall

```bash
toolbox  →  8) Uninstall Toolbox
```

---

## 📄 License
MIT
