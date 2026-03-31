#!/data/data/com.termux/files/usr/bin/bash
# ╔══════════════════════════════════════════════════════════╗
# ║      W A Y Y  T O O L B O X  — Installer                ║
# ╚══════════════════════════════════════════════════════════╝
#
# CARA INSTALL:
#   curl -sL https://raw.githubusercontent.com/Wayy1702/mytoolbox/main/install.sh | bash

REPO="https://raw.githubusercontent.com/Wayy1702/mytoolbox/refs/heads/main"
DEST="/data/data/com.termux/files/home/mytoolbox.sh"
BIN="/data/data/com.termux/files/usr/bin/toolbox"

G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'
C='\033[0;36m'; M='\033[0;35m'; N='\033[0m'

echo ""
echo -e "${M}╔══════════════════════════════════════╗${N}"
echo -e "${M}║   W A Y Y  T O O L B O X  v3.0      ║${N}"
echo -e "${M}╚══════════════════════════════════════╝${N}"
echo ""

if [[ ! -d "/data/data/com.termux" ]]; then
    echo -e "${R}[x] Script ini hanya untuk Termux!${N}"; exit 1
fi

if [ ! -e "/data/data/com.termux/files/home/storage" ]; then
    echo -e "${C}[~] Setup storage...${N}"
    termux-setup-storage 2>/dev/null || true
fi

echo -e "${C}[1/3] Update & install dependencies...${N}"
yes | pkg update -q 2>/dev/null
yes | pkg install -q curl wget termux-tools 2>/dev/null

echo -e "${C}[2/3] Download mytoolbox.sh...${N}"
curl -Ls "$REPO/mytoolbox.sh" -o "$DEST"
chmod +x "$DEST"
echo -e "    ${G}[v] mytoolbox.sh OK${N}"

echo -e "${C}[3/3] Buat command 'toolbox'...${N}"
cat > "$BIN" <<BINEOF
#!/data/data/com.termux/files/usr/bin/bash
exec bash "$DEST" "\$@"
BINEOF
chmod +x "$BIN"
echo -e "    ${G}[v] Command 'toolbox' OK${N}"

echo ""
echo -e "${G}[v] Selesai! Ketik: ${Y}toolbox${N}"
echo ""
