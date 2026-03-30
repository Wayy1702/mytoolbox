#!/data/data/com.termux/files/usr/bin/bash
# ╔══════════════════════════════════════════════════════════╗
# ║      MY TOOLS BOX — Installer for Termux                ║
# ║  Jalankan: curl -sL https://raw.githubusercontent.com/  ║
# ║            USERNAME/mytoolbox/main/install.sh | bash    ║
# ╚══════════════════════════════════════════════════════════╝

G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'
C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'

# ── GANTI INI dengan username & repo GitHub kamu ────────────
GITHUB_USER="Wayy1702"
GITHUB_REPO="mytoolbox"
BRANCH="main"
# ────────────────────────────────────────────────────────────

RAW_URL="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$BRANCH"
INSTALL_DIR="$HOME/.mytoolbox"
BIN_PATH="$PREFIX/bin/toolbox"

echo ""
echo -e "${G}╔═══════════════════════════════════════╗${N}"
echo -e "${G}║    MY TOOLS BOX — Installer           ║${N}"
echo -e "${G}╚═══════════════════════════════════════╝${N}"
echo ""

# Cek Termux
if [[ ! -d "/data/data/com.termux" ]]; then
    echo -e "${R}[✗] Script ini hanya untuk Termux!${N}"
    exit 1
fi

echo -e "${C}[1/5] Update package list...${N}"
pkg update -y -q 2>/dev/null

echo -e "${C}[2/5] Install dependencies (curl, wget)...${N}"
pkg install -y curl wget termux-tools 2>/dev/null | grep -E "Install|already"

echo -e "${C}[3/5] Setup storage (jika belum)...${N}"
if [[ ! -d "$HOME/storage" ]]; then
    termux-setup-storage 2>/dev/null || true
fi

echo -e "${C}[4/5] Download MY TOOLS BOX dari GitHub...${N}"
mkdir -p "$INSTALL_DIR"

if curl -fsSL "$RAW_URL/mytoolbox.sh" -o "$INSTALL_DIR/mytoolbox.sh"; then
    chmod +x "$INSTALL_DIR/mytoolbox.sh"
    echo -e "    ${G}[✓] mytoolbox.sh didownload${N}"
else
    echo -e "    ${R}[✗] Gagal download! Cek URL atau koneksi.${N}"
    exit 1
fi

echo -e "${C}[5/5] Buat command 'toolbox'...${N}"
cat > "$BIN_PATH" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
exec bash "$INSTALL_DIR/mytoolbox.sh" "\$@"
EOF
chmod +x "$BIN_PATH"
echo -e "    ${G}[✓] Command 'toolbox' dibuat${N}"

echo ""
echo -e "${G}╔═══════════════════════════════════════╗${N}"
echo -e "${G}║  ✓  Instalasi Berhasil!               ║${N}"
echo -e "${G}╚═══════════════════════════════════════╝${N}"
echo ""
echo -e "  Cara jalankan:"
echo -e "  ${Y}toolbox${N}            — jalankan dari mana saja"
echo -e "  ${Y}bash $INSTALL_DIR/mytoolbox.sh${N}"
echo ""
echo -e "  Update nanti:"
echo -e "  ${C}toolbox${N} → Settings → Update Toolbox dari GitHub"
echo ""
echo -e "${G}[✓] Ketik 'toolbox' untuk mulai!${N}"
echo ""
