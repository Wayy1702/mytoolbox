#!/data/data/com.termux/files/usr/bin/bash
# ╔══════════════════════════════════════════════════════════╗
# ║         Wayy — Termux Edition              ║
# ║   Auto Launch Android Apps via Deep Link                ║
# ║   Repo : https://github.com/USERNAME/mytoolbox          ║
# ╚══════════════════════════════════════════════════════════╝

# ── PATH ────────────────────────────────────────────────────
INSTALL_DIR="$HOME/.mytoolbox"
CONFIG_FILE="$INSTALL_DIR/config.cfg"
APPS_FILE="$INSTALL_DIR/apps.list"
LOG_FILE="$INSTALL_DIR/toolbox.log"
SELF_URL="https://raw.githubusercontent.com/USERNAME/mytoolbox/main/mytoolbox.sh"

mkdir -p "$INSTALL_DIR"

# ── WARNA ───────────────────────────────────────────────────
R='\033[0;31m'   # Red
G='\033[0;32m'   # Green
Y='\033[1;33m'   # Yellow
C='\033[0;36m'   # Cyan
W='\033[1;37m'   # White
D='\033[0;90m'   # Gray
B='\033[1m'      # Bold
N='\033[0m'      # Reset

# ── LOAD CONFIG ─────────────────────────────────────────────
load_config() {
    USER_NAME="User"
    LAUNCH_DELAY=3
    AUTO_REJOIN=false
    REJOIN_INTERVAL=60
    LAUNCH_MODE="sequential"   # sequential | parallel

    [[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
}

save_config() {
    cat > "$CONFIG_FILE" <<EOF
USER_NAME="$USER_NAME"
LAUNCH_DELAY=$LAUNCH_DELAY
AUTO_REJOIN=$AUTO_REJOIN
REJOIN_INTERVAL=$REJOIN_INTERVAL
LAUNCH_MODE="$LAUNCH_MODE"
EOF
    log_event "Config disimpan"
    echo -e "${G}[✓] Konfigurasi disimpan.${N}"
}

# ── LOAD APPS ───────────────────────────────────────────────
load_apps() {
    APP_NAMES=()
    APP_LINKS=()
    APP_PKGS=()

    if [[ -f "$APPS_FILE" ]]; then
        while IFS='|' read -r name link pkg; do
            [[ -z "$name" ]] && continue
            APP_NAMES+=("$name")
            APP_LINKS+=("$link")
            APP_PKGS+=("$pkg")
        done < "$APPS_FILE"
    fi
}

save_apps() {
    > "$APPS_FILE"
    for i in "${!APP_NAMES[@]}"; do
        echo "${APP_NAMES[$i]}|${APP_LINKS[$i]}|${APP_PKGS[$i]}" >> "$APPS_FILE"
    done
    log_event "App list disimpan (${#APP_NAMES[@]} app)"
}

# ── LOGGING ─────────────────────────────────────────────────
log_event() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ── UTILITAS ────────────────────────────────────────────────
clear_screen() { clear; }

press_enter() {
    echo ""
    echo -e "${C}[↵] Tekan ENTER untuk lanjut...${N}"
    read -r
}

confirm() {
    echo -e "${Y}[?] $1 (y/n): ${N}"
    read -r _ans
    [[ "$_ans" =~ ^[Yy]$ ]]
}

open_deeplink() {
    local url="$1"
    local pkg="$2"   # package name — jika ada, langsung buka tanpa popup

    # ── Jika package name tersedia: paksa buka app tertentu ──
    if [[ -n "$pkg" ]] && command -v am &>/dev/null; then
        # Cara 1: am start dengan -p (package) — no chooser dialog
        am start \
            -a android.intent.action.VIEW \
            -d "$url" \
            -p "$pkg" \
            --activity-clear-top \
            &>/dev/null 2>&1
        local _ret=$?
        [[ $_ret -eq 0 ]] && return 0

        # Cara 2: am start dengan --package flag (Android 5+)
        am start \
            -a android.intent.action.VIEW \
            -d "$url" \
            --package "$pkg" \
            &>/dev/null 2>&1
        [[ $? -eq 0 ]] && return 0
    fi

    # ── Fallback jika tidak ada package name ──
    if command -v am &>/dev/null; then
        # Tambah flag BROWSABLE + no chooser
        am start \
            -a android.intent.action.VIEW \
            -c android.intent.category.BROWSABLE \
            -d "$url" \
            &>/dev/null 2>&1
        return $?
    fi

    if command -v termux-open-url &>/dev/null; then
        termux-open-url "$url" &>/dev/null 2>&1
        return $?
    fi

    xdg-open "$url" &>/dev/null 2>&1
}

check_app_installed() {
    local pkg="$1"
    [[ -z "$pkg" ]] && return 0
    if command -v pm &>/dev/null; then
        pm list packages 2>/dev/null | grep -q "package:$pkg"
    else
        return 0  # Anggap terinstal kalau pm tidak tersedia
    fi
}

# ── BANNER ──────────────────────────────────────────────────
print_banner() {
    echo -e "${G}┌─────────────────────────────────────────────────┐${N}"
    echo -e "${G}│${N}${B}${W}          MY TOOLS BOX  v1.0                    ${N}${G}│${N}"
    echo -e "${G}│${N}${D}          Auto App Launcher — Termux               ${N}${G}│${N}"
    echo -e "${G}│${N}${D}          User: ${W}$USER_NAME${D}                           ${N}${G}│${N}"
    echo -e "${G}└─────────────────────────────────────────────────┘${N}"
    echo ""
}

print_separator() {
    echo -e "${D}─────────────────────────────────────────────────${N}"
}

# ════════════════════════════════════════════════════════════
#  1) SETUP CONFIGURATION
# ════════════════════════════════════════════════════════════
menu_setup() {
    clear_screen
    print_banner
    echo -e "${Y}━━━  SETUP CONFIGURATION  ━━━${N}"
    echo ""

    echo -e "${C}[1] Nama pengguna${N} ${D}(sekarang: $USER_NAME)${N}"
    echo -n "    Masukkan nama: "
    read -r _input
    [[ -n "$_input" ]] && USER_NAME="$_input"

    echo ""
    echo -e "${C}[2] Delay antar launch app${N} ${D}(sekarang: ${LAUNCH_DELAY}s)${N}"
    echo -n "    Delay (detik): "
    read -r _input
    [[ "$_input" =~ ^[0-9]+$ ]] && LAUNCH_DELAY="$_input"

    echo ""
    echo -e "${C}[3] Mode launch${N} ${D}(sekarang: $LAUNCH_MODE)${N}"
    echo -e "    ${W}1${N} = sequential (satu per satu)"
    echo -e "    ${W}2${N} = parallel   (semua sekaligus)"
    echo -n "    Pilih (1/2): "
    read -r _input
    case "$_input" in
        1) LAUNCH_MODE="sequential" ;;
        2) LAUNCH_MODE="parallel"   ;;
    esac

    echo ""
    echo -e "${C}[4] Auto Rejoin${N} ${D}(sekarang: $AUTO_REJOIN)${N}"
    echo -n "    Aktifkan? (y/n): "
    read -r _input
    [[ "$_input" =~ ^[Yy]$ ]] && AUTO_REJOIN=true || AUTO_REJOIN=false

    if [[ "$AUTO_REJOIN" == "true" ]]; then
        echo ""
        echo -e "${C}[5] Interval Rejoin${N} ${D}(sekarang: ${REJOIN_INTERVAL}s)${N}"
        echo -n "    Interval (detik): "
        read -r _input
        [[ "$_input" =~ ^[0-9]+$ ]] && REJOIN_INTERVAL="$_input"
    fi

    echo ""
    save_config
    press_enter
}

# ════════════════════════════════════════════════════════════
#  2) EDIT CONFIGURATION (App List)
# ════════════════════════════════════════════════════════════
menu_edit() {
    while true; do
        clear_screen
        print_banner
        echo -e "${Y}━━━  EDIT APP LIST  ━━━${N}"
        echo ""

        if [[ ${#APP_NAMES[@]} -eq 0 ]]; then
            echo -e "${R}  [!] Belum ada app. Tambahkan dulu.${N}"
        else
            print_separator
            printf "  ${C}%-3s %-20s %-35s${N}\n" "No" "Nama App" "Deep Link"
            print_separator
            for i in "${!APP_NAMES[@]}"; do
                local status="${G}●${N}"
                if [[ -n "${APP_PKGS[$i]}" ]]; then
                    check_app_installed "${APP_PKGS[$i]}" || status="${R}●${N}"
                fi
                printf "  %b %-2s %-20s %-35s\n" \
                    "$status" "$((i+1))" \
                    "${APP_NAMES[$i]}" \
                    "${APP_LINKS[$i]:0:34}"
            done
            print_separator
        fi

        echo ""
        echo -e "  ${W}a)${N} Tambah App"
        echo -e "  ${W}d)${N} Hapus App"
        echo -e "  ${W}e)${N} Edit App"
        echo -e "  ${W}t)${N} Test Deep Link"
        echo -e "  ${W}c)${N} Contoh Deep Link"
        echo -e "  ${R}0)${N} Kembali"
        echo ""
        echo -e "${C}[?] Pilihan: ${N}"
        read -r _choice

        case "$_choice" in
            a|A) _edit_add    ;;
            d|D) _edit_delete ;;
            e|E) _edit_modify ;;
            t|T) _edit_test   ;;
            c|C) _edit_contoh ;;
            0)   break        ;;
        esac
    done
}

# ── AUTO DETECT PACKAGE ─────────────────────────────────────
_pick_package() {
    # Fungsi interaktif: cari & pilih package dari daftar terinstall
    # Return: set variabel _picked_pkg

    _picked_pkg=""

    if ! command -v pm &>/dev/null; then
        echo -e "${Y}[!] pm tidak tersedia — ketik package name manual.${N}"
        echo -n "  Package Name: "; read -r _picked_pkg
        return
    fi

    echo ""
    echo -e "${C}[?] Cari package (kosongkan = tampil semua): ${N}"
    echo -n "  Keyword: "; read -r _kw

    # Ambil daftar package, filter keyword
    local _pkglist=()
    while IFS= read -r line; do
        local pkg="${line#package:}"
        _pkglist+=("$pkg")
    done < <(pm list packages 2>/dev/null | grep -i "${_kw:-}" | sort)

    if [[ ${#_pkglist[@]} -eq 0 ]]; then
        echo -e "${R}[!] Tidak ada package yang cocok.${N}"
        echo -n "  Ketik manual: "; read -r _picked_pkg
        return
    fi

    echo ""
    echo -e "${Y}── Daftar Package Terinstall ──${N}"

    # Tampilkan dengan paginasi 15 per halaman
    local _total=${#_pkglist[@]}
    local _page=0
    local _per=15

    while true; do
        local _start=$((_page * _per))
        local _end=$((_start + _per - 1))
        [[ $_end -ge $_total ]] && _end=$((_total - 1))

        echo ""
        for i in $(seq $_start $_end); do
            printf "  ${C}%3d)${N} %s\n" "$((i+1))" "${_pkglist[$i]}"
        done
        echo ""

        local _info="Hal $((_page+1))/$(( (_total+_per-1)/_per )) | Total: $_total"
        echo -e "${D}$_info${N}"
        echo -e "  ${W}n${N}) Halaman berikutnya   ${W}p${N}) Sebelumnya"
        echo -e "  ${W}nomor${N}) Pilih package    ${W}0${N}) Ketik manual"
        echo ""
        echo -e "${C}[?] Pilihan: ${N}"
        read -r _sel

        case "$_sel" in
            n|N)
                local _maxpage=$(( (_total+_per-1)/_per - 1 ))
                [[ $_page -lt $_maxpage ]] && _page=$((_page+1)) || \
                    echo -e "${Y}[!] Sudah halaman terakhir.${N}"
                ;;
            p|P)
                [[ $_page -gt 0 ]] && _page=$((_page-1)) || \
                    echo -e "${Y}[!] Sudah halaman pertama.${N}"
                ;;
            0)
                echo -n "  Ketik manual: "; read -r _picked_pkg
                return
                ;;
            ''|*[!0-9]*)
                echo -e "${R}[!] Input tidak valid.${N}"
                ;;
            *)
                local _idx=$((_sel-1))
                if [[ $_idx -ge 0 && $_idx -lt $_total ]]; then
                    _picked_pkg="${_pkglist[$_idx]}"
                    echo -e "${G}[✓] Dipilih: $_picked_pkg${N}"
                    sleep 0.5
                    return
                else
                    echo -e "${R}[!] Nomor tidak valid.${N}"
                fi
                ;;
        esac
    done
}

_edit_add() {
    echo ""
    echo -e "${Y}── Tambah App Baru ──${N}"
    echo -n "  Nama App      : "; read -r _name
    echo -n "  Deep Link/URL : "; read -r _link

    echo ""
    echo -e "${C}[?] Cara isi Package Name:${N}"
    echo -e "  ${W}1)${N} ${G}Auto detect${N} — pilih dari daftar app terinstall"
    echo -e "  ${W}2)${N} ${W}Ketik manual${N}"
    echo -n "  Pilihan (1/2): "; read -r _pmode

    local _pkg=""
    case "$_pmode" in
        1)
            _pick_package
            _pkg="$_picked_pkg"
            ;;
        2|*)
            echo -n "  Package Name  : "; read -r _pkg
            ;;
    esac

    if [[ -n "$_name" && -n "$_link" ]]; then
        APP_NAMES+=("$_name")
        APP_LINKS+=("$_link")
        APP_PKGS+=("${_pkg:-}")
        save_apps
        echo ""
        echo -e "${G}[✓] App ditambahkan!${N}"
        echo -e "    Nama : $_name"
        echo -e "    Link : $_link"
        echo -e "    Pkg  : ${_pkg:-${D}(kosong)${N}}"
    else
        echo -e "${R}[✗] Nama dan link tidak boleh kosong!${N}"
    fi
    sleep 1.5
}

_edit_delete() {
    [[ ${#APP_NAMES[@]} -eq 0 ]] && { echo -e "${R}[!] Daftar kosong.${N}"; sleep 1; return; }
    echo -n "  Nomor app yang dihapus: "; read -r _num
    local idx=$((_num-1))
    if [[ $idx -ge 0 && $idx -lt ${#APP_NAMES[@]} ]]; then
        confirm "Hapus '${APP_NAMES[$idx]}'?" && {
            local _dname="${APP_NAMES[$idx]}"
            unset 'APP_NAMES[$idx]' 'APP_LINKS[$idx]' 'APP_PKGS[$idx]'
            APP_NAMES=("${APP_NAMES[@]}")
            APP_LINKS=("${APP_LINKS[@]}")
            APP_PKGS=("${APP_PKGS[@]}")
            save_apps
            echo -e "${G}[✓] '$_dname' dihapus.${N}"
        }
    else
        echo -e "${R}[✗] Nomor tidak valid.${N}"
    fi
    sleep 1
}

_edit_modify() {
    [[ ${#APP_NAMES[@]} -eq 0 ]] && { echo -e "${R}[!] Daftar kosong.${N}"; sleep 1; return; }
    echo -n "  Nomor app yang diedit: "; read -r _num
    local idx=$((_num-1))
    if [[ $idx -ge 0 && $idx -lt ${#APP_NAMES[@]} ]]; then
        echo -e "  ${D}(kosongkan untuk tidak mengubah)${N}"
        echo -n "  Nama baru [${APP_NAMES[$idx]}]: "; read -r _n
        echo -n "  Link baru [${APP_LINKS[$idx]}]: "; read -r _l

        echo ""
        echo -e "${C}[?] Ubah Package Name${N} ${D}(sekarang: ${APP_PKGS[$idx]:-kosong})${N}"
        echo -e "  ${W}1)${N} ${G}Auto detect${N} — pilih dari daftar terinstall"
        echo -e "  ${W}2)${N} ${W}Ketik manual${N}"
        echo -e "  ${W}3)${N} ${D}Lewati (tidak diubah)${N}"
        echo -n "  Pilihan (1/2/3): "; read -r _pmode

        local _p="${APP_PKGS[$idx]}"
        case "$_pmode" in
            1) _pick_package; _p="$_picked_pkg" ;;
            2) echo -n "  Package Name: "; read -r _p ;;
            *) ;;
        esac

        [[ -n "$_n" ]] && APP_NAMES[$idx]="$_n"
        [[ -n "$_l" ]] && APP_LINKS[$idx]="$_l"
        APP_PKGS[$idx]="$_p"
        save_apps
        echo -e "${G}[✓] App diperbarui.${N}"
        echo -e "    Pkg: ${_p:-${D}(kosong)${N}}"
    else
        echo -e "${R}[✗] Nomor tidak valid.${N}"
    fi
    sleep 1.5
}

_edit_test() {
    [[ ${#APP_NAMES[@]} -eq 0 ]] && { echo -e "${R}[!] Daftar kosong.${N}"; sleep 1; return; }
    echo -n "  Nomor app yang ditest: "; read -r _num
    local idx=$((_num-1))
    if [[ $idx -ge 0 && $idx -lt ${#APP_NAMES[@]} ]]; then
        echo -e "${C}[~] Membuka: ${APP_NAMES[$idx]}${N}"
        echo -e "    Link: ${APP_LINKS[$idx]}"
        echo -e "    Pkg : ${APP_PKGS[$idx]:-tidak ada}"
        open_deeplink "${APP_LINKS[$idx]}" "${APP_PKGS[$idx]:-}"
        echo -e "${G}[✓] Perintah dikirim!${N}"
    fi
    sleep 2
}

_edit_contoh() {
    clear_screen
    echo -e "${Y}━━━  CONTOH DEEP LINK  ━━━${N}"
    echo ""
    echo -e "${W}Format umum:${N}"
    echo -e "  ${G}scheme://host/path?param=value${N}"
    echo ""
    echo -e "${W}Contoh populer:${N}"
    print_separator
    printf "  ${C}%-22s${N} %s\n" "WhatsApp Chat"     "whatsapp://send?phone=628xxx"
    printf "  ${C}%-22s${N} %s\n" "Telegram User"     "tg://resolve?domain=username"
    printf "  ${C}%-22s${N} %s\n" "YouTube Video"     "youtube://watch?v=VIDEO_ID"
    printf "  ${C}%-22s${N} %s\n" "Instagram Profil"  "instagram://user?username=nama"
    printf "  ${C}%-22s${N} %s\n" "TikTok Profil"     "snssdk1233://user/profile/ID"
    printf "  ${C}%-22s${N} %s\n" "Shopee Toko"       "shopee://shop/SHOP_ID"
    printf "  ${C}%-22s${N} %s\n" "Tokopedia Toko"    "tokopedia://shop/SHOP_SLUG"
    printf "  ${C}%-22s${N} %s\n" "Play Store App"    "market://details?id=com.pkg"
    printf "  ${C}%-22s${N} %s\n" "URL Biasa (HTTP)"  "https://google.com"
    printf "  ${C}%-22s${N} %s\n" "Panggil Nomor"     "tel:+628xxxxxxxxxx"
    printf "  ${C}%-22s${N} %s\n" "Kirim SMS"         "sms:+628xxx?body=pesan"
    print_separator
    echo ""
    echo -e "${D}Tip: Cari 'deep link [nama app]' di Google untuk skema yang tepat.${N}"
    press_enter
}

# ════════════════════════════════════════════════════════════
#  3) RUN SCRIPT
# ════════════════════════════════════════════════════════════
menu_run() {
    clear_screen
    print_banner
    echo -e "${Y}━━━  RUN SCRIPT  ━━━${N}"
    echo ""

    if [[ ${#APP_NAMES[@]} -eq 0 ]]; then
        echo -e "${R}[!] Tidak ada app. Tambahkan dulu di Edit App List.${N}"
        press_enter
        return
    fi

    echo -e "${W}App yang akan diluncurkan (${#APP_NAMES[@]} app):${N}"
    for i in "${!APP_NAMES[@]}"; do
        echo -e "  ${C}$((i+1)).${N} ${W}${APP_NAMES[$i]}${N}"
        echo -e "     ${D}→ ${APP_LINKS[$i]}${N}"
    done
    echo ""
    echo -e "${W}Mode     : ${C}$LAUNCH_MODE${N}"
    echo -e "${W}Delay    : ${C}${LAUNCH_DELAY}s${N}"
    echo -e "${W}Rejoin   : ${C}$AUTO_REJOIN${N}"
    [[ "$AUTO_REJOIN" == "true" ]] && \
        echo -e "${W}Interval : ${C}${REJOIN_INTERVAL}s${N}"
    echo ""

    confirm "Mulai launch sekarang?" || { press_enter; return; }

    echo ""
    log_event "Run script dimulai — ${#APP_NAMES[@]} app, mode=$LAUNCH_MODE"

    _do_launch() {
        local round="${1:-1}"
        echo -e "${G}[▶] Round #${round} — $(date '+%H:%M:%S')${N}"
        echo ""

        if [[ "$LAUNCH_MODE" == "parallel" ]]; then
            # Buka semua sekaligus di background
            for i in "${!APP_NAMES[@]}"; do
                echo -e "  ${C}→ Launch: ${W}${APP_NAMES[$i]}${N}"
                open_deeplink "${APP_LINKS[$i]}" "${APP_PKGS[$i]:-}" &
                log_event "Launch (parallel): ${APP_NAMES[$i]}"
            done
            wait
            echo ""
            echo -e "${G}[✓] Semua app diluncurkan (parallel).${N}"
        else
            # Satu per satu
            for i in "${!APP_NAMES[@]}"; do
                echo -e "  ${C}[→] ${W}${APP_NAMES[$i]}${N}"
                echo -e "       ${D}${APP_LINKS[$i]}${N}"
                open_deeplink "${APP_LINKS[$i]}" "${APP_PKGS[$i]:-}"
                log_event "Launch: ${APP_NAMES[$i]}"

                if [[ $i -lt $((${#APP_NAMES[@]}-1)) ]]; then
                    echo -e "       ${Y}⏱ Tunggu ${LAUNCH_DELAY}s...${N}"
                    sleep "$LAUNCH_DELAY"
                fi
                echo ""
            done
            echo -e "${G}[✓] Semua app diluncurkan!${N}"
        fi
    }

    if [[ "$AUTO_REJOIN" == "true" ]]; then
        echo -e "${Y}[↺] Auto Rejoin aktif — interval ${REJOIN_INTERVAL}s${N}"
        echo -e "${R}    Ctrl+C untuk menghentikan.${N}"
        echo ""

        local _round=0
        trap 'echo -e "\n${R}[■] Auto Rejoin dihentikan.${N}"; log_event "Auto rejoin dihentikan"; trap - INT; press_enter; return' INT

        while true; do
            _round=$((_round+1))
            _do_launch "$_round"
            echo -e "${C}[↺] Rejoin berikutnya dalam ${REJOIN_INTERVAL}s — Ctrl+C untuk stop${N}"
            sleep "$REJOIN_INTERVAL"
        done
    else
        _do_launch 1
        press_enter
    fi
}

# ════════════════════════════════════════════════════════════
#  4) CLEAR ALL APP CACHES
# ════════════════════════════════════════════════════════════
menu_clear() {
    clear_screen
    print_banner
    echo -e "${Y}━━━  CLEAR ALL APP CACHES  ━━━${N}"
    echo ""

    if [[ ${#APP_PKGS[@]} -eq 0 ]]; then
        echo -e "${R}[!] Tidak ada app dengan package name terdaftar.${N}"
        echo -e "${D}    Tambahkan package name saat edit app.${N}"
        press_enter
        return
    fi

    echo -e "${W}App yang akan dibersihkan cache-nya:${N}"
    local _has_pkg=false
    for i in "${!APP_NAMES[@]}"; do
        if [[ -n "${APP_PKGS[$i]}" ]]; then
            echo -e "  ${C}$((i+1)).${N} ${W}${APP_NAMES[$i]}${N} ${D}(${APP_PKGS[$i]})${N}"
            _has_pkg=true
        fi
    done

    if [[ "$_has_pkg" == "false" ]]; then
        echo -e "${R}  [!] Semua app tidak punya package name.${N}"
        press_enter
        return
    fi

    echo ""
    confirm "Lanjutkan clear cache?" || { press_enter; return; }

    echo ""
    for i in "${!APP_NAMES[@]}"; do
        local _pkg="${APP_PKGS[$i]}"
        [[ -z "$_pkg" ]] && continue

        echo -e "${C}[~] Clear cache: ${W}${APP_NAMES[$i]}${N} ${D}($_pkg)${N}"

        if command -v pm &>/dev/null; then
            if pm clear "$_pkg" &>/dev/null; then
                echo -e "    ${G}[✓] Berhasil!${N}"
                log_event "Cache cleared: $_pkg"
            else
                echo -e "    ${R}[✗] Gagal (perlu root atau izin ADB)${N}"
                log_event "Cache GAGAL: $_pkg"
            fi
        else
            echo -e "    ${Y}[!] pm tidak tersedia — butuh Android shell/root${N}"
        fi
        sleep 0.5
    done

    echo ""
    echo -e "${G}[✓] Selesai!${N}"
    press_enter
}

# ════════════════════════════════════════════════════════════
#  5) PACKAGE MANAGER (Install / Uninstall APK)
# ════════════════════════════════════════════════════════════
menu_package() {
    while true; do
        clear_screen
        print_banner
        echo -e "${Y}━━━  PACKAGE MANAGER  ━━━${N}"
        echo ""
        echo -e "  ${W}1)${N} Install APK dari storage"
        echo -e "  ${W}2)${N} Uninstall APK"
        echo -e "  ${W}3)${N} List semua package terinstall"
        echo -e "  ${W}4)${N} Cek apakah package terinstall"
        echo -e "  ${W}5)${N} Download APK dari URL"
        echo -e "  ${R}0)${N} Kembali"
        echo ""
        echo -e "${C}[?] Pilihan: ${N}"
        read -r _c

        case "$_c" in
            1) _pkg_install  ;;
            2) _pkg_uninstall;;
            3) _pkg_list     ;;
            4) _pkg_check    ;;
            5) _pkg_download ;;
            0) break         ;;
        esac
    done
}

_pkg_install() {
    echo -n "  Path file APK (/sdcard/...): "; read -r _path
    if [[ -f "$_path" ]]; then
        echo -e "${C}[~] Menginstall...${N}"
        if command -v pm &>/dev/null; then
            pm install -r "$_path" && \
                echo -e "${G}[✓] Install berhasil!${N}" || \
                echo -e "${R}[✗] Install gagal!${N}"
        else
            termux-open "$_path" 2>/dev/null || \
                echo -e "${Y}[!] Gunakan: termux-open $_path${N}"
        fi
    else
        echo -e "${R}[✗] File tidak ditemukan: $_path${N}"
    fi
    sleep 2
}

_pkg_uninstall() {
    echo -n "  Package name (com.xxx): "; read -r _pkg
    [[ -z "$_pkg" ]] && return
    confirm "Uninstall $_pkg?" && {
        if command -v pm &>/dev/null; then
            pm uninstall "$_pkg" && \
                echo -e "${G}[✓] Uninstall berhasil!${N}" || \
                echo -e "${R}[✗] Gagal!${N}"
        else
            echo -e "${Y}[!] Butuh pm (root / Android debug shell)${N}"
        fi
    }
    sleep 2
}

_pkg_list() {
    echo ""
    echo -e "${C}[~] Daftar package terinstall:${N}"
    if command -v pm &>/dev/null; then
        pm list packages 2>/dev/null | sed 's/package://' | sort | \
            awk '{printf "  %s\n", $0}' | less
    else
        echo -e "${Y}[!] pm tidak tersedia.${N}"
        sleep 2
    fi
}

_pkg_check() {
    echo -n "  Package name: "; read -r _pkg
    if check_app_installed "$_pkg"; then
        echo -e "${G}[✓] '$_pkg' TERINSTALL.${N}"
    else
        echo -e "${R}[✗] '$_pkg' TIDAK terinstall.${N}"
    fi
    sleep 2
}

_pkg_download() {
    echo -n "  URL APK (http/https): "; read -r _url
    local _fname="$HOME/storage/downloads/downloaded_$(date +%s).apk"
    echo -e "${C}[~] Mendownload...${N}"
    if command -v wget &>/dev/null; then
        wget -q --show-progress -O "$_fname" "$_url" && \
            echo -e "${G}[✓] Tersimpan: $_fname${N}\n    Jalankan opsi 1 untuk install." || \
            echo -e "${R}[✗] Download gagal!${N}"
    elif command -v curl &>/dev/null; then
        curl -L --progress-bar -o "$_fname" "$_url" && \
            echo -e "${G}[✓] Tersimpan: $_fname${N}" || \
            echo -e "${R}[✗] Download gagal!${N}"
    else
        echo -e "${R}[✗] wget/curl tidak tersedia. Jalankan: pkg install wget${N}"
    fi
    sleep 2
}

# ════════════════════════════════════════════════════════════
#  6) SETTINGS
# ════════════════════════════════════════════════════════════
menu_settings() {
    while true; do
        clear_screen
        print_banner
        echo -e "${Y}━━━  SETTINGS  ━━━${N}"
        echo ""
        echo -e "  ${D}Nama User     :${N} ${C}$USER_NAME${N}"
        echo -e "  ${D}Launch Delay  :${N} ${W}${LAUNCH_DELAY}s${N}"
        echo -e "  ${D}Mode Launch   :${N} ${W}$LAUNCH_MODE${N}"
        echo -e "  ${D}Auto Rejoin   :${N} $( [[ "$AUTO_REJOIN" == "true" ]] && echo "${G}ON${N}" || echo "${R}OFF${N}" )"
        echo -e "  ${D}Rejoin Interval:${N} ${W}${REJOIN_INTERVAL}s${N}"
        echo -e "  ${D}Jumlah App    :${N} ${W}${#APP_NAMES[@]}${N}"
        echo -e "  ${D}Config file   :${N} ${D}$CONFIG_FILE${N}"
        echo -e "  ${D}Apps file     :${N} ${D}$APPS_FILE${N}"
        echo ""
        print_separator
        echo -e "  ${W}1)${N} Ubah Nama User"
        echo -e "  ${W}2)${N} Ubah Launch Delay"
        echo -e "  ${W}3)${N} Ganti Mode Launch"
        echo -e "  ${W}4)${N} Toggle Auto Rejoin"
        echo -e "  ${W}5)${N} Ubah Rejoin Interval"
        echo -e "  ${W}6)${N} Lihat Log"
        echo -e "  ${W}7)${N} Update Toolbox dari GitHub"
        echo -e "  ${R}0)${N} Kembali"
        echo ""
        echo -e "${C}[?] Pilihan: ${N}"
        read -r _c

        case "$_c" in
            1) echo -n "  Nama baru: "; read -r _i; [[ -n "$_i" ]] && USER_NAME="$_i"; save_config ;;
            2) echo -n "  Delay (detik): "; read -r _i; [[ "$_i" =~ ^[0-9]+$ ]] && LAUNCH_DELAY="$_i"; save_config ;;
            3) [[ "$LAUNCH_MODE" == "sequential" ]] && LAUNCH_MODE="parallel" || LAUNCH_MODE="sequential"
               echo -e "${G}[✓] Mode: $LAUNCH_MODE${N}"; save_config; sleep 1 ;;
            4) [[ "$AUTO_REJOIN" == "true" ]] && AUTO_REJOIN="false" || AUTO_REJOIN="true"
               echo -e "${G}[✓] Auto Rejoin: $AUTO_REJOIN${N}"; save_config; sleep 1 ;;
            5) echo -n "  Interval (detik): "; read -r _i; [[ "$_i" =~ ^[0-9]+$ ]] && REJOIN_INTERVAL="$_i"; save_config ;;
            6) [[ -f "$LOG_FILE" ]] && tail -30 "$LOG_FILE" | less || echo -e "${Y}[!] Log kosong.${N}"; sleep 1 ;;
            7) _self_update ;;
            0) break ;;
        esac
    done
}

_self_update() {
    echo -e "${C}[~] Mengupdate dari GitHub...${N}"
    local _tmp="$INSTALL_DIR/mytoolbox_new.sh"
    if curl -fsSL "$SELF_URL" -o "$_tmp" 2>/dev/null; then
        chmod +x "$_tmp"
        cp "$_tmp" "$INSTALL_DIR/mytoolbox.sh"
        cp "$_tmp" "$PREFIX/bin/toolbox"
        rm -f "$_tmp"
        echo -e "${G}[✓] Update berhasil! Restart toolbox untuk efek.${N}"
        log_event "Self-update berhasil dari $SELF_URL"
    else
        echo -e "${R}[✗] Update gagal. Cek koneksi/URL.${N}"
    fi
    sleep 2
}

# ════════════════════════════════════════════════════════════
#  7) ABOUT
# ════════════════════════════════════════════════════════════
menu_about() {
    clear_screen
    print_banner
    echo -e "${Y}━━━  ABOUT  ━━━${N}"
    echo ""
    echo -e "  ${G}MY TOOLS BOX v1.0${N}"
    echo -e "  ${C}Auto App Launcher for Termux${N}"
    echo ""
    echo -e "  ${W}Fitur:${N}"
    echo -e "    ${G}✓${N}  Setup konfigurasi (nama, delay, mode, rejoin)"
    echo -e "    ${G}✓${N}  Kelola daftar app + deep link"
    echo -e "    ${G}✓${N}  Launch sequential / parallel"
    echo -e "    ${G}✓${N}  Auto Rejoin dengan interval"
    echo -e "    ${G}✓${N}  Clear cache app via pm"
    echo -e "    ${G}✓${N}  Package Manager (install/uninstall/download)"
    echo -e "    ${G}✓${N}  Self-update dari GitHub"
    echo -e "    ${G}✓${N}  Logging aktivitas"
    echo ""
    echo -e "  ${D}Install dir : $INSTALL_DIR${N}"
    echo -e "  ${D}Log file    : $LOG_FILE${N}"
    echo -e "  ${D}Repo        : $SELF_URL${N}"
    echo ""
    press_enter
}

# ════════════════════════════════════════════════════════════
#  8) UNINSTALL
# ════════════════════════════════════════════════════════════
menu_uninstall() {
    clear_screen
    print_banner
    echo -e "${R}━━━  UNINSTALL TOOLBOX  ━━━${N}"
    echo ""
    echo -e "${R}  [!] Ini akan menghapus:${N}"
    echo -e "      ${W}•${N} $INSTALL_DIR (config + apps + log)"
    echo -e "      ${W}•${N} $PREFIX/bin/toolbox (command)"
    echo ""
    confirm "Yakin uninstall?" || { press_enter; return; }
    confirm "Konfirmasi — HAPUS SEMUA DATA?" || { press_enter; return; }

    rm -rf "$INSTALL_DIR"
    rm -f  "$PREFIX/bin/toolbox"
    echo ""
    echo -e "${G}[✓] MY TOOLS BOX diuninstall. Goodbye, $USER_NAME!${N}"
    sleep 2
    exit 0
}

# ════════════════════════════════════════════════════════════
#  MAIN MENU
# ════════════════════════════════════════════════════════════
main_menu() {
    load_config
    load_apps
    log_event "Toolbox dijalankan oleh $USER_NAME"

    while true; do
        clear_screen
        print_banner
        echo -e "${Y}What would you like to do?${N}"
        echo ""
        echo -e "  ${W}1)${N} ${G}Setup Configuration${N}   ${D}(First Run)${N}"
        echo -e "  ${W}2)${N} ${W}Edit App List${N}         ${D}(${#APP_NAMES[@]} app terdaftar)${N}"
        echo -e "  ${W}3)${N} ${Y}Run Script${N}            ${D}(Launch + Auto Rejoin)${N}"
        echo -e "  ${W}4)${N} ${W}Clear All App Caches${N}"
        echo -e "  ${W}5)${N} ${W}Package Manager${N}       ${D}(Install/Uninstall APK)${N}"
        echo -e "  ${W}6)${N} ${W}Settings${N}"
        echo -e "  ${W}7)${N} ${W}About${N}"
        echo -e "  ${W}8)${N} ${R}Uninstall Toolbox${N}"
        echo -e "  ${W}9)${N} ${R}Exit${N}"
        echo ""
        echo -e "${C}[?] Enter your choice [1-9]: ${N}"
        read -r _choice

        case "$_choice" in
            1) menu_setup     ;;
            2) menu_edit      ;;
            3) menu_run       ;;
            4) menu_clear     ;;
            5) menu_package   ;;
            6) menu_settings  ;;
            7) menu_about     ;;
            8) menu_uninstall ;;
            9)
                clear_screen
                echo -e "${G}[✓] Sampai jumpa, $USER_NAME!${N}"
                log_event "Toolbox ditutup"
                echo ""
                exit 0
                ;;
            *) echo -e "${R}[✗] Pilihan tidak valid!${N}"; sleep 0.8 ;;
        esac
    done
}

main_menu
