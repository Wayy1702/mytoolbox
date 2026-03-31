#!/data/data/com.termux/files/usr/bin/bash
# ╔══════════════════════════════════════════════════════════╗
# ║              W A Y Y  T O O L B O X  v3.0               ║
# ║   Auto Launch Android Apps via Deep Link                ║
# ║   Repo : https://github.com/Wayy1702/mytoolbox          ║
# ╚══════════════════════════════════════════════════════════╝

# ═══════════════════════════════════════════════════════════
#  PATH & WARNA
# ═══════════════════════════════════════════════════════════
INSTALL_DIR="$HOME/.mytoolbox"
CONFIG_FILE="$INSTALL_DIR/config.cfg"
APPS_FILE="$INSTALL_DIR/apps.list"
LOG_FILE="$INSTALL_DIR/toolbox.log"
SELF_URL="https://raw.githubusercontent.com/Wayy1702/mytoolbox/main/mytoolbox.sh"
VERSION="3.0"

mkdir -p "$INSTALL_DIR"

R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
W='\033[1;37m'
D='\033[0;90m'
M='\033[0;35m'
N='\033[0m'

# ═══════════════════════════════════════════════════════════
#  CONFIG
# ═══════════════════════════════════════════════════════════
load_config() {
    USER_NAME="User"
    LAUNCH_DELAY=3
    AUTO_REJOIN=false
    CHECK_INTERVAL=1
    LAUNCH_MODE="sequential"
    [[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
}

save_config() {
    cat > "$CONFIG_FILE" <<EOF
USER_NAME="$USER_NAME"
LAUNCH_DELAY=$LAUNCH_DELAY
AUTO_REJOIN=$AUTO_REJOIN
CHECK_INTERVAL=$CHECK_INTERVAL
LAUNCH_MODE="$LAUNCH_MODE"
EOF
    log_write "Config disimpan"
    echo -e "${G}  [✓] Konfigurasi disimpan.${N}"
}

# ═══════════════════════════════════════════════════════════
#  APP LIST — format: NAMA|LINK|PACKAGE|OWNER|TITLE
# ═══════════════════════════════════════════════════════════
load_apps() {
    APP_NAMES=()
    APP_LINKS=()
    APP_PKGS=()
    APP_OWNERS=()
    APP_TITLES=()
    if [[ -f "$APPS_FILE" ]]; then
        while IFS='|' read -r _n _l _p _o _t; do
            [[ -z "$_n" ]] && continue
            APP_NAMES+=("$_n")
            APP_LINKS+=("$_l")
            APP_PKGS+=("$_p")
            APP_OWNERS+=("$_o")
            APP_TITLES+=("$_t")
        done < "$APPS_FILE"
    fi
}

save_apps() {
    > "$APPS_FILE"
    for i in "${!APP_NAMES[@]}"; do
        echo "${APP_NAMES[$i]}|${APP_LINKS[$i]}|${APP_PKGS[$i]}|${APP_OWNERS[$i]}|${APP_TITLES[$i]}" >> "$APPS_FILE"
    done
    log_write "App list disimpan (${#APP_NAMES[@]} app)"
}

# ═══════════════════════════════════════════════════════════
#  UTILITAS
# ═══════════════════════════════════════════════════════════
log_write() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }
clr()       { clear; }
enter()     { echo ""; echo -e "${C}  Tekan ENTER untuk lanjut...${N}"; read -r; }

# ═══════════════════════════════════════════════════════════
#  AUTO RESIZE
# ═══════════════════════════════════════════════════════════
TW=80
TH=24

update_size() {
    TW=$(tput cols  2>/dev/null || echo 80)
    TH=$(tput lines 2>/dev/null || echo 24)
    [[ $TW -lt 40 ]] && TW=40
    [[ $TH -lt 10 ]] && TH=10
    export TW TH
}

trap 'update_size' WINCH
update_size

sep() {
    update_size
    local _w=$(( TW - 4 )) _line=""
    for ((i=0; i<_w; i++)); do _line+="─"; done
    echo -e "${D}  ${_line}${N}"
}

hdr() {
    update_size
    local _text="── $1 ──"
    local _pad=$(( (TW - ${#_text} - 2) / 2 ))
    [[ $_pad -lt 0 ]] && _pad=0
    local _sp=""; for ((i=0; i<_pad; i++)); do _sp+=" "; done
    echo -e "  ${Y}${_sp}${_text}${N}"
}

# ═══════════════════════════════════════════════════════════
#  WAYY HEADER — tampil di semua halaman
# ═══════════════════════════════════════════════════════════
draw_box() {
    update_size
    local _inner=$(( TW - 6 ))
    [[ $_inner -lt 20 ]] && _inner=20

    local _top="  ╔"
    local _bot="  ╚"
    for ((i=0; i<_inner; i++)); do _top+="═"; _bot+="═"; done
    _top+="╗"; _bot+="╝"

    box_line() {
        local _txt="$1" _color="${2:-$D}"
        local _tlen=${#_txt}
        local _pad=$(( _inner - _tlen ))
        [[ $_pad -lt 0 ]] && { _txt="${_txt:0:$_inner}"; _pad=0; }
        local _spaces=""; for ((i=0; i<_pad; i++)); do _spaces+=" "; done
        echo -e "${M}  ║${N}${_color}${_txt}${_spaces}${N}${M}║${N}"
    }

    local _prefix="    "

    # ASCII art WAYY (compact, sesuai terminal sempit)
    echo -e "${M}${_top}${N}"
    box_line "${_prefix}██╗    ██╗ █████╗ ██╗   ██╗██╗   ██╗" "$M"
    box_line "${_prefix}██║    ██║██╔══██╗╚██╗ ██╔╝╚██╗ ██╔╝" "$M"
    box_line "${_prefix}██║ █╗ ██║███████║ ╚████╔╝  ╚████╔╝ " "$M"
    box_line "${_prefix}██║███╗██║██╔══██║  ╚██╔╝    ╚██╔╝  " "$M"
    box_line "${_prefix}╚███╔███╔╝██║  ██║   ██║      ██║   " "$M"
    box_line "${_prefix} ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝      ╚═╝  " "$M"
    box_line "" "$D"
    box_line "${_prefix}WAYY Toolbox v${VERSION}  —  Termux Edition" "$W"
    box_line "${_prefix}User : ${USER_NAME}" "$C"
    echo -e "${M}${_bot}${N}"
}

per_page() {
    update_size
    local _p=$(( TH - 16 ))
    [[ $_p -lt 4  ]] && _p=4
    [[ $_p -gt 20 ]] && _p=20
    echo "$_p"
}

col_width() {
    update_size
    local _cols="${1:-2}"
    echo $(( (TW - 8) / _cols ))
}

confirm() {
    while true; do
        echo -e "  ${Y}[?] $1${N}"
        echo -ne "      (y/n) → "; read -r _a
        case "$_a" in
            y|Y) return 0 ;;
            n|N) return 1 ;;
            *) echo -e "${R}  Ketik y atau n.${N}" ;;
        esac
    done
}

banner() {
    update_size
    echo ""
    draw_box
    echo ""
}

# ═══════════════════════════════════════════════════════════
#  OPEN APP
# ═══════════════════════════════════════════════════════════
open_app() {
    local _url="$1" _pkg="$2"
    if [[ -n "$_pkg" ]] && command -v am &>/dev/null; then
        am start -a android.intent.action.VIEW -d "$_url" \
            -p "$_pkg" --activity-clear-top >/dev/null 2>&1 && return 0
        am start -a android.intent.action.VIEW -d "$_url" \
            --package "$_pkg" >/dev/null 2>&1 && return 0
    fi
    if command -v am &>/dev/null; then
        am start -a android.intent.action.VIEW \
            -c android.intent.category.BROWSABLE -d "$_url" >/dev/null 2>&1
        return $?
    fi
    termux-open-url "$_url" >/dev/null 2>&1
}

# ═══════════════════════════════════════════════════════════
#  IS RUNNING — metode reliable di Termux tanpa root
# ═══════════════════════════════════════════════════════════
is_running() {
    local _pkg="$1"
    [[ -z "$_pkg" ]] && return 1

    # ── Metode 1: dumpsys activity tasks ──────────────────
    if command -v dumpsys &>/dev/null; then
        local _tasks
        _tasks=$(dumpsys activity tasks 2>/dev/null)
        if echo "$_tasks" | grep -q "$_pkg"; then
            return 0
        fi

        local _svc
        _svc=$(dumpsys activity services 2>/dev/null)
        if echo "$_svc" | grep -q "$_pkg"; then
            return 0
        fi
    fi

    # ── Metode 2: /proc scan cmdline per proses ───────────
    local _found=false
    for _cmdfile in /proc/[0-9]*/cmdline; do
        local _cmd
        _cmd=$(cat "$_cmdfile" 2>/dev/null | tr '\0' '\n' | head -1)
        if [[ "$_cmd" == "$_pkg" || "$_cmd" == "${_pkg}:"* ]]; then
            _found=true
            break
        fi
    done
    [[ "$_found" == "true" ]] && return 0

    # ── Metode 3: ps ──────────────────────────────────────
    if command -v ps &>/dev/null; then
        ps -A 2>/dev/null | grep -v grep | grep -q "$_pkg" && return 0
        ps 2>/dev/null | grep -v grep | grep -q "$_pkg" && return 0
    fi

    # ── Metode 4: dumpsys package stopped flag ────────────
    if command -v dumpsys &>/dev/null; then
        local _pkg_info
        _pkg_info=$(dumpsys package "$_pkg" 2>/dev/null)
        echo "$_pkg_info" | grep -q "Unable to find" && return 1
        local _stopped
        _stopped=$(echo "$_pkg_info" | grep "stopped=" | head -1)
        if [[ -n "$_stopped" ]]; then
            echo "$_stopped" | grep -q "stopped=true" && return 1
            return 0
        fi
    fi

    # Fallback: anggap TIDAK running → rejoin tetap terjadi
    return 1
}

# ═══════════════════════════════════════════════════════════
#  PICK PACKAGE — filter roblox saja
# ═══════════════════════════════════════════════════════════
pick_package() {
    PICKED_PKG=""

    if ! command -v pm &>/dev/null; then
        echo -e "${Y}  [!] pm tidak tersedia, ketik manual.${N}"
        echo -ne "  Package Name → "; read -r PICKED_PKG
        return
    fi

    clr; banner
    hdr "PILIH PACKAGE ROBLOX"
    echo ""
    echo -e "  ${D}Menampilkan package Roblox yang terinstall...${N}"
    echo ""

    local _list=()
    while IFS= read -r _line; do
        _list+=("${_line#package:}")
    done < <(pm list packages 2>/dev/null | grep -i "roblox\|com\.roblox" | sort)

    if [[ ${#_list[@]} -eq 0 ]]; then
        echo -e "${R}  Tidak ada package Roblox ditemukan.${N}"
        echo ""
        echo -e "  ${W}[1]${N}  Ketik package manual"
        echo -e "  ${W}[0]${N}  Batal"
        echo ""
        echo -ne "  ${C}Pilihan → ${N}"; read -r _sel
        case "$_sel" in
            1) echo -ne "  Package → "; read -r PICKED_PKG ;;
            *) PICKED_PKG="" ;;
        esac
        return
    fi

    local _total=${#_list[@]}
    local _page=0

    while true; do
        update_size
        local _per; _per=$(per_page)
        local _pages=$(( (_total + _per - 1) / _per ))
        local _cw; _cw=$(col_width 1)

        clr; banner
        hdr "PACKAGE ROBLOX TERINSTALL"
        echo -e "  ${D}Total: ${W}${_total}${D} package  |  Hal ${W}$((_page+1))${D}/${W}${_pages}${N}"
        sep

        local _start=$(( _page * _per ))
        local _end=$(( _start + _per - 1 ))
        [[ $_end -ge $_total ]] && _end=$(( _total - 1 ))

        for i in $(seq "$_start" "$_end"); do
            local _pkg="${_list[$i]}"
            local _maxlen=$(( _cw - 8 ))
            [[ ${#_pkg} -gt $_maxlen ]] && _pkg="${_pkg:0:$((_maxlen-3))}..."
            printf "  ${C}%3d)${N}  %s\n" "$((i+1))" "$_pkg"
        done

        sep
        echo -e "  ${W}[nomor]${N}  Pilih package"
        [[ $_page -gt 0 ]]             && echo -e "  ${W}[p]${N}      Halaman sebelumnya"
        [[ $_page -lt $((_pages-1)) ]] && echo -e "  ${W}[n]${N}      Halaman berikutnya"
        echo -e "  ${W}[m]${N}      Ketik manual"
        echo -e "  ${W}[0]${N}      Batal"
        sep
        echo ""
        echo -ne "  ${C}Pilihan → ${N}"; read -r _sel

        case "${_sel,,}" in
            p) [[ $_page -gt 0 ]] && _page=$((_page-1)) ;;
            n) [[ $_page -lt $((_pages-1)) ]] && _page=$((_page+1)) ;;
            m) echo -ne "  Package → "; read -r PICKED_PKG; return ;;
            0) PICKED_PKG=""; return ;;
            ''|*[!0-9]*)
                echo -e "${R}  Input tidak valid.${N}"; sleep 0.8 ;;
            *)
                local _i=$((_sel - 1))
                if [[ $_i -ge 0 && $_i -lt $_total ]]; then
                    PICKED_PKG="${_list[$_i]}"
                    echo -e "${G}  [✓] Dipilih: ${PICKED_PKG}${N}"
                    sleep 1
                    return
                else
                    echo -e "${R}  Nomor tidak ada.${N}"; sleep 0.8
                fi
                ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════
#  1) SETUP CONFIGURATION
# ═══════════════════════════════════════════════════════════
menu_setup() {
    clr; banner; hdr "SETUP CONFIGURATION"; echo ""

    echo -e "  ${C}[1]${N} Nama pengguna"
    echo -e "      ${D}Sekarang: ${W}${USER_NAME}${N}"
    echo -ne "      → "; read -r _i; [[ -n "$_i" ]] && USER_NAME="$_i"
    echo ""

    echo -e "  ${C}[2]${N} Delay antar launch app (detik)"
    echo -e "      ${D}Sekarang: ${W}${LAUNCH_DELAY}s${N}"
    echo -ne "      → "; read -r _i; [[ "$_i" =~ ^[0-9]+$ ]] && LAUNCH_DELAY="$_i"
    echo ""

    echo -e "  ${C}[3]${N} Mode launch"
    echo -e "      ${D}Sekarang: ${W}${LAUNCH_MODE}${N}"
    echo -e "      ${W}1${N} = sequential ${D}(satu per satu)${N}"
    echo -e "      ${W}2${N} = parallel   ${D}(semua sekaligus)${N}"
    echo -ne "      → "; read -r _i
    case "$_i" in 1) LAUNCH_MODE="sequential";; 2) LAUNCH_MODE="parallel";; esac
    echo ""

    echo -e "  ${C}[4]${N} Auto Rejoin saat Force Close"
    echo -e "      ${D}Sekarang: ${W}${AUTO_REJOIN}${N}"
    echo -e "      ${D}App akan otomatis di-relaunch jika force close.${N}"
    echo -ne "      Aktifkan? (y/n) → "; read -r _i
    [[ "$_i" =~ ^[Yy]$ ]] && AUTO_REJOIN=true || AUTO_REJOIN=false
    echo ""

    if [[ "$AUTO_REJOIN" == "true" ]]; then
        echo -e "  ${C}[5]${N} Interval cek Force Close (menit)"
        echo -e "      ${D}Sekarang: ${W}${CHECK_INTERVAL} menit${N}"
        echo -e "      ${D}Semakin kecil = semakin cepat deteksi FC.${N}"
        echo -ne "      → "; read -r _i; [[ "$_i" =~ ^[0-9]+$ ]] && CHECK_INTERVAL="$_i"
        echo ""
    fi

    save_config; enter
}

# ═══════════════════════════════════════════════════════════
#  2) EDIT APP LIST
# ═══════════════════════════════════════════════════════════
menu_edit() {
    while true; do
        clr; banner; hdr "EDIT APP LIST"; echo ""

        if [[ ${#APP_NAMES[@]} -eq 0 ]]; then
            echo -e "${R}  Belum ada app. Tambahkan dulu.${N}"
        else
            update_size
            local _cw1=$(( (TW - 14) * 25 / 100 ))
            local _cw2=$(( (TW - 14) * 25 / 100 ))
            local _cw3=$(( (TW - 14) * 30 / 100 ))
            [[ $_cw1 -lt 8  ]] && _cw1=8
            [[ $_cw2 -lt 8  ]] && _cw2=8
            [[ $_cw3 -lt 10 ]] && _cw3=10
            sep
            printf "  ${C}%-4s  %-${_cw1}s  %-${_cw2}s  %-${_cw3}s${N}\n" \
                "No" "Nama" "Owner" "Judul DeepLink"
            sep
            for i in "${!APP_NAMES[@]}"; do
                local _nm="${APP_NAMES[$i]}"
                local _ow="${APP_OWNERS[$i]:-—}"
                local _tt="${APP_TITLES[$i]:-—}"
                [[ ${#_nm} -gt $_cw1 ]] && _nm="${_nm:0:$((_cw1-3))}..."
                [[ ${#_ow} -gt $_cw2 ]] && _ow="${_ow:0:$((_cw2-3))}..."
                [[ ${#_tt} -gt $_cw3 ]] && _tt="${_tt:0:$((_cw3-3))}..."
                printf "  ${W}%-4s${N}  %-${_cw1}s  ${C}%-${_cw2}s${N}  ${D}%-${_cw3}s${N}\n" \
                    "$((i+1))." "$_nm" "$_ow" "$_tt"
            done
            sep
        fi

        echo ""
        echo -e "  ${W}[1]${N}  Tambah App Baru"
        echo -e "  ${W}[2]${N}  Edit App"
        echo -e "  ${W}[3]${N}  Hapus App"
        echo -e "  ${W}[4]${N}  Test Buka App"
        echo -e "  ${W}[5]${N}  Contoh Deep Link"
        echo -e "  ${W}[0]${N}  Kembali"
        echo ""
        echo -ne "  ${C}Pilihan → ${N}"; read -r _c

        case "$_c" in
            1) _app_add    ;;
            2) _app_edit   ;;
            3) _app_delete ;;
            4) _app_test   ;;
            5) _app_contoh ;;
            0) break       ;;
            *) echo -e "${R}  Pilihan tidak valid.${N}"; sleep 0.8 ;;
        esac
    done
}

_app_add() {
    clr; banner; hdr "TAMBAH APP BARU"; echo ""

    echo -ne "  ${C}Nama App          → ${N}"; read -r _name
    [[ -z "$_name" ]] && { echo -e "${R}  Nama tidak boleh kosong.${N}"; sleep 1; return; }

    echo -ne "  ${C}Deep Link (URL)   → ${N}"; read -r _link
    [[ -z "$_link" ]] && { echo -e "${R}  Link tidak boleh kosong.${N}"; sleep 1; return; }

    echo -ne "  ${C}Owner / Pemilik   → ${N}"; read -r _owner
    [[ -z "$_owner" ]] && _owner="Unknown"

    echo -ne "  ${C}Judul Deep Link   → ${N}"; read -r _title
    [[ -z "$_title" ]] && _title="$_name"

    echo ""
    echo -e "  ${C}Package Name:${N}"
    echo -e "  ${W}[1]${N}  Auto detect Roblox ${D}(dari list terinstall)${N}"
    echo -e "  ${W}[2]${N}  Ketik manual"
    echo -e "  ${W}[3]${N}  Lewati"
    echo ""
    echo -ne "  ${C}Pilihan → ${N}"; read -r _pm

    local _pkg=""
    case "$_pm" in
        1) pick_package; _pkg="$PICKED_PKG" ;;
        2) echo -ne "  Package → "; read -r _pkg ;;
        3) _pkg="" ;;
        *) echo -e "${Y}  Input tidak valid, package dikosongkan.${N}"; _pkg="" ;;
    esac

    echo ""
    sep
    echo -e "  ${G}Konfirmasi:${N}"
    echo -e "  Nama       : ${W}$_name${N}"
    echo -e "  Owner      : ${C}$_owner${N}"
    echo -e "  Judul Link : ${Y}$_title${N}"
    local _lw=$(( TW - 16 )); [[ $_lw -lt 20 ]] && _lw=20
    echo -e "  Deep Link  : ${D}${_link:0:$_lw}${N}"
    echo -e "  Package    : ${C}${_pkg:-${D}(kosong)}${N}"
    sep
    echo ""
    confirm "Simpan app ini?" || { echo -e "${Y}  Dibatalkan.${N}"; sleep 1; return; }

    APP_NAMES+=("$_name")
    APP_LINKS+=("$_link")
    APP_PKGS+=("$_pkg")
    APP_OWNERS+=("$_owner")
    APP_TITLES+=("$_title")
    save_apps
    echo -e "${G}  [✓] App '$_name' ditambahkan!${N}"
    log_write "App ditambah: $_name (owner: $_owner)"
    sleep 1.5
}

_app_edit() {
    [[ ${#APP_NAMES[@]} -eq 0 ]] && { echo -e "${R}  Daftar kosong.${N}"; sleep 1; return; }
    echo ""
    echo -ne "  ${C}Nomor app yang diedit → ${N}"; read -r _num
    [[ ! "$_num" =~ ^[0-9]+$ ]] && { echo -e "${R}  Input tidak valid.${N}"; sleep 1; return; }
    local _idx=$((_num - 1))
    [[ $_idx -lt 0 || $_idx -ge ${#APP_NAMES[@]} ]] && { echo -e "${R}  Nomor tidak ada.${N}"; sleep 1; return; }

    clr; banner; hdr "EDIT — ${APP_NAMES[$_idx]}"; echo ""
    echo -e "  ${D}Kosongkan + ENTER = tidak diubah.${N}"; echo ""

    echo -e "  ${C}Nama${N}       ${D}(${W}${APP_NAMES[$_idx]}${D})${N}"
    echo -ne "  → "; read -r _n; echo ""

    echo -e "  ${C}Deep Link${N}  ${D}(${W}${APP_LINKS[$_idx]:0:50}${D})${N}"
    echo -ne "  → "; read -r _l; echo ""

    echo -e "  ${C}Owner${N}      ${D}(${W}${APP_OWNERS[$_idx]:-—}${D})${N}"
    echo -ne "  → "; read -r _o; echo ""

    echo -e "  ${C}Judul Link${N} ${D}(${W}${APP_TITLES[$_idx]:-—}${D})${N}"
    echo -ne "  → "; read -r _t; echo ""

    echo -e "  ${C}Package${N}    ${D}(${W}${APP_PKGS[$_idx]:-kosong}${D})${N}"
    echo -e "  ${W}[1]${N}  Auto detect Roblox"
    echo -e "  ${W}[2]${N}  Ketik manual"
    echo -e "  ${W}[3]${N}  Tidak diubah"
    echo ""
    echo -ne "  ${C}Pilihan → ${N}"; read -r _pm

    local _p="${APP_PKGS[$_idx]}"
    case "$_pm" in
        1) pick_package; _p="$PICKED_PKG" ;;
        2) echo -ne "  Package → "; read -r _p ;;
        3) ;;
        *) echo -e "${Y}  Input tidak valid, tidak diubah.${N}" ;;
    esac

    [[ -n "$_n" ]] && APP_NAMES[$_idx]="$_n"
    [[ -n "$_l" ]] && APP_LINKS[$_idx]="$_l"
    [[ -n "$_o" ]] && APP_OWNERS[$_idx]="$_o"
    [[ -n "$_t" ]] && APP_TITLES[$_idx]="$_t"
    APP_PKGS[$_idx]="$_p"
    save_apps

    echo ""
    echo -e "${G}  [✓] App diperbarui:${N}"
    echo -e "  Nama       : ${W}${APP_NAMES[$_idx]}${N}"
    echo -e "  Owner      : ${C}${APP_OWNERS[$_idx]:-—}${N}"
    echo -e "  Judul Link : ${Y}${APP_TITLES[$_idx]:-—}${N}"
    echo -e "  Package    : ${C}${APP_PKGS[$_idx]:-${D}(kosong)}${N}"
    log_write "App diedit: ${APP_NAMES[$_idx]}"
    sleep 1.5
}

_app_delete() {
    [[ ${#APP_NAMES[@]} -eq 0 ]] && { echo -e "${R}  Daftar kosong.${N}"; sleep 1; return; }
    clr; banner; hdr "HAPUS APP"; echo ""

    update_size
    local _cw=$(( TW - 12 ))
    sep
    printf "  ${C}%-4s  %-20s  %s${N}\n" "No" "Nama" "Owner"
    sep
    for i in "${!APP_NAMES[@]}"; do
        printf "  ${W}%-4s${N}  %-20s  ${C}%s${N}\n" \
            "$((i+1))." "${APP_NAMES[$i]}" "${APP_OWNERS[$i]:-—}"
    done
    sep
    echo ""
    echo -ne "  ${C}Nomor app yang dihapus → ${N}"; read -r _num
    [[ ! "$_num" =~ ^[0-9]+$ ]] && { echo -e "${R}  Input tidak valid.${N}"; sleep 1; return; }
    local _idx=$((_num - 1))
    [[ $_idx -lt 0 || $_idx -ge ${#APP_NAMES[@]} ]] && { echo -e "${R}  Nomor tidak ada.${N}"; sleep 1; return; }

    echo ""
    echo -e "  Akan dihapus: ${W}${APP_NAMES[$_idx]}${N}  ${D}(owner: ${APP_OWNERS[$_idx]:-—})${N}"
    echo ""
    confirm "Hapus '${APP_NAMES[$_idx]}'?" || { echo -e "${Y}  Dibatalkan.${N}"; sleep 1; return; }

    local _dn="${APP_NAMES[$_idx]}"
    unset 'APP_NAMES[$_idx]' 'APP_LINKS[$_idx]' 'APP_PKGS[$_idx]' \
          'APP_OWNERS[$_idx]' 'APP_TITLES[$_idx]'
    APP_NAMES=("${APP_NAMES[@]}")
    APP_LINKS=("${APP_LINKS[@]}")
    APP_PKGS=("${APP_PKGS[@]}")
    APP_OWNERS=("${APP_OWNERS[@]}")
    APP_TITLES=("${APP_TITLES[@]}")
    save_apps
    echo -e "${G}  [✓] '$_dn' dihapus.${N}"
    log_write "App dihapus: $_dn"
    sleep 1
}

_app_test() {
    [[ ${#APP_NAMES[@]} -eq 0 ]] && { echo -e "${R}  Daftar kosong.${N}"; sleep 1; return; }
    clr; banner; hdr "TEST BUKA APP"; echo ""

    update_size
    sep
    printf "  ${C}%-4s  %-20s  %-15s  %s${N}\n" "No" "Nama" "Owner" "Judul Link"
    sep
    for i in "${!APP_NAMES[@]}"; do
        printf "  ${W}%-4s${N}  %-20s  ${C}%-15s${N}  ${D}%s${N}\n" \
            "$((i+1))." "${APP_NAMES[$i]}" \
            "${APP_OWNERS[$i]:-—}" "${APP_TITLES[$i]:-—}"
    done
    sep
    echo ""
    echo -ne "  ${C}Nomor app yang ditest → ${N}"; read -r _num
    [[ ! "$_num" =~ ^[0-9]+$ ]] && { echo -e "${R}  Input tidak valid.${N}"; sleep 1; return; }
    local _idx=$((_num - 1))
    [[ $_idx -lt 0 || $_idx -ge ${#APP_NAMES[@]} ]] && { echo -e "${R}  Nomor tidak ada.${N}"; sleep 1; return; }

    echo ""
    sep
    echo -e "  ${C}[→] Membuka: ${W}${APP_NAMES[$_idx]}${N}"
    echo -e "  ${D}Owner      : ${C}${APP_OWNERS[$_idx]:-—}${N}"
    echo -e "  ${D}Judul Link : ${Y}${APP_TITLES[$_idx]:-—}${N}"
    echo -e "  ${D}Package    : ${APP_PKGS[$_idx]:-kosong}${N}"
    echo -e "  ${D}Link       : ${APP_LINKS[$_idx]:0:60}${N}"
    sep
    echo ""
    open_app "${APP_LINKS[$_idx]}" "${APP_PKGS[$_idx]:-}"
    echo -e "${G}  [✓] Perintah dikirim!${N}"
    log_write "Test: ${APP_NAMES[$_idx]} (${APP_OWNERS[$_idx]:-—})"
    sleep 2
}

_app_contoh() {
    clr; banner; hdr "CONTOH DEEP LINK"; echo ""
    echo -e "  ${D}Format: ${W}scheme://host/path?param=value${N}"; echo ""
    sep
    printf "  ${C}%-22s${N}  %s\n" "Aplikasi" "Deep Link"
    sep
    printf "  %-22s  %s\n" "WhatsApp Chat"    "whatsapp://send?phone=628xxx"
    printf "  %-22s  %s\n" "Telegram User"    "tg://resolve?domain=username"
    printf "  %-22s  %s\n" "YouTube Video"    "youtube://watch?v=VIDEO_ID"
    printf "  %-22s  %s\n" "Instagram Profil" "instagram://user?username=nama"
    printf "  %-22s  %s\n" "TikTok User"      "snssdk1233://user/profile/ID"
    printf "  %-22s  %s\n" "Shopee Toko"      "shopee://shop/SHOP_ID"
    printf "  %-22s  %s\n" "Play Store"       "market://details?id=com.pkg"
    printf "  %-22s  %s\n" "URL Biasa"        "https://google.com"
    printf "  %-22s  %s\n" "Telepon"          "tel:+628xxxxxxxxxx"
    printf "  %-22s  %s\n" "Roblox Game"      "roblox://placeId=PLACE_ID"
    sep
    echo ""
    echo -e "  ${D}Tip: Cari 'deep link [nama app]' di Google.${N}"
    enter
}

# ═══════════════════════════════════════════════════════════
#  3) RUN SCRIPT
# ═══════════════════════════════════════════════════════════
menu_run() {
    clr; banner; hdr "RUN SCRIPT"; echo ""

    if [[ ${#APP_NAMES[@]} -eq 0 ]]; then
        echo -e "${R}  Tidak ada app. Tambahkan dulu di Edit App List.${N}"
        enter; return
    fi

    update_size
    local _cw1=$(( (TW - 14) * 25 / 100 ))
    local _cw2=$(( (TW - 14) * 20 / 100 ))
    local _cw3=$(( (TW - 14) * 35 / 100 ))
    [[ $_cw1 -lt 8  ]] && _cw1=8
    [[ $_cw2 -lt 8  ]] && _cw2=8
    [[ $_cw3 -lt 10 ]] && _cw3=10
    sep
    printf "  ${C}%-4s  %-${_cw1}s  %-${_cw2}s  %-${_cw3}s${N}\n" \
        "No" "Nama" "Owner" "Judul Link"
    sep
    for i in "${!APP_NAMES[@]}"; do
        local _nm="${APP_NAMES[$i]}"
        local _ow="${APP_OWNERS[$i]:-—}"
        local _tt="${APP_TITLES[$i]:-—}"
        [[ ${#_nm} -gt $_cw1 ]] && _nm="${_nm:0:$((_cw1-3))}..."
        [[ ${#_ow} -gt $_cw2 ]] && _ow="${_ow:0:$((_cw2-3))}..."
        [[ ${#_tt} -gt $_cw3 ]] && _tt="${_tt:0:$((_cw3-3))}..."
        printf "  ${W}%-4s${N}  %-${_cw1}s  ${C}%-${_cw2}s${N}  ${D}%-${_cw3}s${N}\n" \
            "$((i+1))." "$_nm" "$_ow" "$_tt"
    done
    sep
    echo ""
    echo -e "  Mode          : ${C}${LAUNCH_MODE}${N}"
    echo -e "  Delay         : ${C}${LAUNCH_DELAY}s${N}"
    if [[ "$AUTO_REJOIN" == "true" ]]; then
        echo -e "  Auto Rejoin FC: ${G}ON${N} ${D}(cek tiap ${CHECK_INTERVAL} menit)${N}"
    else
        echo -e "  Auto Rejoin FC: ${R}OFF${N}"
    fi
    echo ""

    if [[ "$AUTO_REJOIN" == "true" ]]; then
        local _warn=()
        for i in "${!APP_NAMES[@]}"; do
            [[ -z "${APP_PKGS[$i]}" ]] && _warn+=("${APP_NAMES[$i]}")
        done
        if [[ ${#_warn[@]} -gt 0 ]]; then
            echo -e "${Y}  [!] App tanpa package tidak bisa dimonitor FC:${N}"
            for _w in "${_warn[@]}"; do echo -e "      ${D}• $_w${N}"; done
            echo ""
        fi
    fi

    confirm "Mulai launch sekarang?" || { enter; return; }
    echo ""
    log_write "Run — ${#APP_NAMES[@]} app, mode=$LAUNCH_MODE, rejoin=$AUTO_REJOIN"

    _launch_one() {
        local _i="$1"
        echo -e "  ${C}[→]${N} ${W}${APP_NAMES[$_i]}${N}  ${D}[${APP_OWNERS[$_i]:-—}]${N}  ${Y}${APP_TITLES[$_i]:-—}${N}"
        open_app "${APP_LINKS[$_i]}" "${APP_PKGS[$_i]:-}"
        log_write "Launch: ${APP_NAMES[$_i]} (${APP_OWNERS[$_i]:-—})"
    }

    _launch_all() {
        echo -e "${G}  [▶] Meluncurkan ${#APP_NAMES[@]} app — $(date '+%H:%M:%S')${N}"
        echo ""
        if [[ "$LAUNCH_MODE" == "parallel" ]]; then
            for i in "${!APP_NAMES[@]}"; do _launch_one "$i" & done
            wait
        else
            for i in "${!APP_NAMES[@]}"; do
                _launch_one "$i"
                [[ $i -lt $((${#APP_NAMES[@]}-1)) ]] && sleep "$LAUNCH_DELAY"
            done
        fi
        echo ""
        echo -e "${G}  [✓] Semua app diluncurkan!${N}"
    }

    if [[ "$AUTO_REJOIN" != "true" ]]; then
        _launch_all
        enter; return
    fi

    echo -e "${Y}  [↺] Monitor Force Close aktif — cek tiap ${CHECK_INTERVAL} menit${N}"
    echo -e "${R}  Ctrl+C untuk menghentikan.${N}"
    echo ""

    _launch_all
    echo ""

    echo -e "${D}  [~] Tunggu app startup (${LAUNCH_DELAY}s)...${N}"
    sleep "$LAUNCH_DELAY"

    trap '
        echo ""
        echo -e "${R}  [■] Monitoring dihentikan.${N}"
        log_write "Auto rejoin dihentikan"
        trap - INT TERM
        enter
        return
    ' INT TERM

    local _fc_total=0
    declare -A _last_launch
    declare -A _was_running

    local _now
    _now=$(date +%s)
    for i in "${!APP_NAMES[@]}"; do
        _last_launch[$i]=$_now
        _was_running[$i]="true"
    done

    # Cooldown = LAUNCH_DELAY + 30 detik buffer startup app
    local _COOLDOWN=$(( LAUNCH_DELAY + 30 ))
    [[ $_COOLDOWN -lt 30 ]] && _COOLDOWN=30

    echo -e "${G}  [✓] Monitoring aktif...${N}"
    echo -e "${D}  Cooldown setelah launch: ${_COOLDOWN}s${N}"
    echo ""

    while true; do
        sleep $(( CHECK_INTERVAL * 60 ))

        _now=$(date +%s)
        echo -e "${D}  [~] Cek status — $(date '+%H:%M:%S')${N}"

        for i in "${!APP_NAMES[@]}"; do
            local _pkg="${APP_PKGS[$i]}"
            [[ -z "$_pkg" ]] && continue

            local _elapsed=$(( _now - ${_last_launch[$i]:-0} ))

            # Masih cooldown setelah launch → skip
            if [[ $_elapsed -lt $_COOLDOWN ]]; then
                echo -e "  ${D}[cooldown] ${APP_NAMES[$i]} (${_elapsed}s < ${_COOLDOWN}s)${N}"
                continue
            fi

            local _running_now
            is_running "$_pkg" && _running_now="true" || _running_now="false"

            if [[ "$_running_now" == "true" ]]; then
                echo -e "  ${G}[OK]${N} ${W}${APP_NAMES[$i]}${N} ${D}running${N}"
                _was_running[$i]="true"
            else
                if [[ "${_was_running[$i]}" == "true" ]]; then
                    # Sebelumnya running → sekarang tidak → FC nyata
                    _fc_total=$((_fc_total + 1))
                    echo -e "${Y}  [FC#${_fc_total}]${N} ${W}${APP_NAMES[$i]}${N} ${D}[${APP_OWNERS[$i]:-—}]${N} ${R}FC!${N} → relaunch..."
                    echo -e "        ${D}$(date '+%H:%M:%S')${N}"
                    _launch_one "$i"
                    _last_launch[$i]=$(date +%s)
                    _was_running[$i]="wait"
                elif [[ "${_was_running[$i]}" == "wait" ]]; then
                    # Masih belum running setelah relaunch → coba lagi
                    echo -e "${R}  [retry]${N} ${W}${APP_NAMES[$i]}${N} belum running → coba lagi..."
                    _launch_one "$i"
                    _last_launch[$i]=$(date +%s)
                else
                    echo -e "  ${D}[FC]${N} ${W}${APP_NAMES[$i]}${N} ${D}tidak running${N}"
                fi
            fi
        done
        echo ""
    done
}

# ═══════════════════════════════════════════════════════════
#  4) CLEAR CACHE
# ═══════════════════════════════════════════════════════════
menu_clear() {
    clr; banner; hdr "CLEAR APP CACHES"; echo ""

    local _has=false
    for i in "${!APP_NAMES[@]}"; do [[ -n "${APP_PKGS[$i]}" ]] && _has=true && break; done

    if [[ "$_has" == "false" ]]; then
        echo -e "${R}  Tidak ada app dengan package name.${N}"
        echo -e "${D}  Isi package name di Edit App List terlebih dulu.${N}"
        enter; return
    fi

    update_size
    sep
    printf "  ${C}%-4s  %-20s  %-15s  %s${N}\n" "No" "Nama" "Owner" "Package"
    sep
    for i in "${!APP_NAMES[@]}"; do
        [[ -z "${APP_PKGS[$i]}" ]] && continue
        printf "  ${W}%-4s${N}  %-20s  ${C}%-15s${N}  ${D}%s${N}\n" \
            "$((i+1))." "${APP_NAMES[$i]}" \
            "${APP_OWNERS[$i]:-—}" "${APP_PKGS[$i]}"
    done
    sep
    echo ""
    confirm "Clear cache semua app di atas?" || { enter; return; }
    echo ""

    for i in "${!APP_NAMES[@]}"; do
        local _pkg="${APP_PKGS[$i]}"
        [[ -z "$_pkg" ]] && continue
        echo -ne "  ${C}[~]${N} ${APP_NAMES[$i]} ${D}[${APP_OWNERS[$i]:-—}]${N}... "
        if command -v pm &>/dev/null; then
            pm clear "$_pkg" >/dev/null 2>&1 \
                && echo -e "${G}OK${N}" \
                || echo -e "${R}GAGAL${N}"
            log_write "Cache clear: $_pkg"
        else
            echo -e "${Y}pm tidak tersedia${N}"
        fi
        sleep 0.3
    done

    echo ""; echo -e "${G}  [✓] Selesai!${N}"; enter
}

# ═══════════════════════════════════════════════════════════
#  5) PACKAGE MANAGER
# ═══════════════════════════════════════════════════════════
menu_package() {
    while true; do
        clr; banner; hdr "PACKAGE MANAGER"; echo ""
        echo -e "  ${W}[1]${N}  Install APK dari storage"
        echo -e "  ${W}[2]${N}  Uninstall APK"
        echo -e "  ${W}[3]${N}  List Package Roblox"
        echo -e "  ${W}[4]${N}  Cek package terinstall"
        echo -e "  ${W}[5]${N}  Download APK dari URL"
        echo -e "  ${W}[0]${N}  Kembali"
        echo ""
        echo -ne "  ${C}Pilihan → ${N}"; read -r _c
        case "$_c" in
            1) _pkg_install   ;;
            2) _pkg_uninstall ;;
            3) _pkg_list      ;;
            4) _pkg_check     ;;
            5) _pkg_download  ;;
            0) break          ;;
            *) echo -e "${R}  Tidak valid.${N}"; sleep 0.8 ;;
        esac
    done
}

_pkg_install() {
    clr; banner; hdr "INSTALL APK"; echo ""
    echo -e "  ${D}Contoh path: /sdcard/Download/app.apk${N}"
    echo ""
    echo -ne "  ${C}Path APK → ${N}"; read -r _p
    if [[ -z "$_p" ]]; then
        echo -e "${R}  Path tidak boleh kosong.${N}"; sleep 1; return
    fi
    if [[ ! -f "$_p" ]]; then
        echo -e "${R}  [✗] File tidak ditemukan: $_p${N}"; enter; return
    fi
    echo -e "${C}  [~] Menginstall...${N}"
    if command -v pm &>/dev/null; then
        pm install -r "$_p" >/dev/null 2>&1 \
            && echo -e "${G}  [✓] Berhasil!${N}" \
            || { echo -e "${R}  [✗] Gagal via pm, mencoba termux-open...${N}"
                 termux-open "$_p" 2>/dev/null \
                     && echo -e "${G}  [✓] Dibuka via termux-open.${N}" \
                     || echo -e "${R}  [✗] Gagal total.${N}"; }
    else
        termux-open "$_p" 2>/dev/null \
            && echo -e "${G}  [✓] Dibuka via termux-open.${N}" \
            || echo -e "${R}  [✗] pm dan termux-open tidak tersedia.${N}"
    fi
    log_write "Install APK: $_p"
    enter
}

_pkg_uninstall() {
    clr; banner; hdr "UNINSTALL APK"; echo ""
    echo -ne "  ${C}Package name → ${N}"; read -r _p
    [[ -z "$_p" ]] && { echo -e "${R}  Package tidak boleh kosong.${N}"; sleep 1; return; }
    echo ""
    confirm "Uninstall $_p?" && {
        if command -v pm &>/dev/null; then
            pm uninstall "$_p" >/dev/null 2>&1 \
                && echo -e "${G}  [✓] Berhasil!${N}" \
                || echo -e "${R}  [✗] Gagal! Pastikan package name benar.${N}"
        else
            echo -e "${Y}  pm tidak tersedia.${N}"
        fi
        log_write "Uninstall: $_p"
    }
    enter
}

_pkg_list() {
    clr; banner; hdr "LIST PACKAGE ROBLOX"; echo ""

    if ! command -v pm &>/dev/null; then
        echo -e "${R}  pm tidak tersedia.${N}"; enter; return
    fi

    echo -e "  ${D}Mencari package Roblox...${N}"; echo ""

    local _list=()
    while IFS= read -r _line; do
        _list+=("${_line#package:}")
    done < <(pm list packages 2>/dev/null | grep -i "roblox\|com\.roblox" | sort)

    if [[ ${#_list[@]} -eq 0 ]]; then
        echo -e "${R}  Tidak ada package Roblox ditemukan.${N}"
        echo -e "${D}  Pastikan Roblox sudah terinstall di device ini.${N}"
    else
        sep
        printf "  ${C}%-4s  %s${N}\n" "No" "Package Name"
        sep
        for i in "${!_list[@]}"; do
            printf "  ${W}%-4s${N}  %s\n" "$((i+1))." "${_list[$i]}"
        done
        sep
        echo ""
        echo -e "  ${G}  Total: ${W}${#_list[@]}${G} package Roblox ditemukan.${N}"
    fi
    enter
}

_pkg_check() {
    clr; banner; hdr "CEK PACKAGE"; echo ""
    echo -ne "  ${C}Package name → ${N}"; read -r _p
    [[ -z "$_p" ]] && { echo -e "${R}  Package tidak boleh kosong.${N}"; sleep 1; return; }
    echo ""
    if command -v pm &>/dev/null; then
        pm list packages 2>/dev/null | grep -q "package:$_p" \
            && echo -e "${G}  [✓] TERINSTALL: $_p${N}" \
            || echo -e "${R}  [✗] Tidak terinstall: $_p${N}"
    else
        echo -e "${Y}  pm tidak tersedia.${N}"
    fi
    enter
}

_pkg_download() {
    clr; banner; hdr "DOWNLOAD APK"; echo ""
    echo -e "  ${D}Masukkan URL langsung ke file .apk${N}"
    echo ""
    echo -ne "  ${C}URL APK → ${N}"; read -r _url
    [[ -z "$_url" ]] && { echo -e "${R}  URL tidak boleh kosong.${N}"; sleep 1; return; }

    local _out="$HOME/storage/downloads/dl_$(date +%s).apk"

    # Pastikan folder downloads tersedia
    if [[ ! -d "$HOME/storage/downloads" ]]; then
        echo -e "${Y}  [!] Folder downloads belum ada, coba termux-setup-storage dulu.${N}"
        _out="$INSTALL_DIR/dl_$(date +%s).apk"
        echo -e "${D}  Disimpan ke: $_out${N}"
    fi

    echo ""
    echo -e "${C}  [~] Mendownload...${N}"
    if command -v wget &>/dev/null; then
        wget -q --show-progress -O "$_out" "$_url" \
            && echo -e "${G}  [✓] Tersimpan: $_out${N}" \
            || echo -e "${R}  [✗] Gagal download!${N}"
    elif command -v curl &>/dev/null; then
        curl -L --progress-bar -o "$_out" "$_url" \
            && echo -e "${G}  [✓] Tersimpan: $_out${N}" \
            || echo -e "${R}  [✗] Gagal download!${N}"
    else
        echo -e "${R}  wget/curl tidak ada. Jalankan: pkg install wget${N}"
    fi
    log_write "Download APK: $_url"
    enter
}

# ═══════════════════════════════════════════════════════════
#  6) SETTINGS
# ═══════════════════════════════════════════════════════════
menu_settings() {
    while true; do
        clr; banner; hdr "SETTINGS"; echo ""
        update_size
        local _lw=$(( TW - 30 )); [[ $_lw -lt 10 ]] && _lw=10
        sep
        printf "  ${D}%-22s${N}  %s\n"  "Nama User"       "${W}${USER_NAME:0:$_lw}${N}"
        printf "  ${D}%-22s${N}  %s\n"  "Launch Delay"    "${W}${LAUNCH_DELAY}s${N}"
        printf "  ${D}%-22s${N}  %s\n"  "Mode Launch"     "${W}${LAUNCH_MODE}${N}"
        printf "  ${D}%-22s${N}  %b\n"  "Auto Rejoin FC" \
            "$([[ "$AUTO_REJOIN" == "true" ]] && echo "${G}ON${N}" || echo "${R}OFF${N}")"
        printf "  ${D}%-22s${N}  %s\n"  "Interval Cek FC" "${W}${CHECK_INTERVAL} menit${N}"
        printf "  ${D}%-22s${N}  %s\n"  "Jumlah App"      "${W}${#APP_NAMES[@]}${N}"
        printf "  ${D}%-22s${N}  %s\n"  "Terminal"        "${D}${TW}x${TH}${N}"
        sep
        echo ""
        echo -e "  ${W}[1]${N}  Ubah Nama User"
        echo -e "  ${W}[2]${N}  Ubah Launch Delay"
        echo -e "  ${W}[3]${N}  Ganti Mode Launch"
        echo -e "  ${W}[4]${N}  Toggle Auto Rejoin FC"
        echo -e "  ${W}[5]${N}  Ubah Interval Cek FC"
        echo -e "  ${W}[6]${N}  Lihat Log"
        echo -e "  ${W}[7]${N}  Update dari GitHub"
        echo -e "  ${W}[0]${N}  Kembali"
        echo ""
        echo -ne "  ${C}Pilihan → ${N}"; read -r _c

        case "$_c" in
            1) echo -ne "  Nama baru → "; read -r _i
               [[ -n "$_i" ]] && USER_NAME="$_i"; save_config ;;
            2) echo -ne "  Delay (detik) → "; read -r _i
               [[ "$_i" =~ ^[0-9]+$ ]] && LAUNCH_DELAY="$_i"; save_config ;;
            3) [[ "$LAUNCH_MODE" == "sequential" ]] && LAUNCH_MODE="parallel" || LAUNCH_MODE="sequential"
               echo -e "${G}  Mode: $LAUNCH_MODE${N}"; save_config; sleep 1 ;;
            4) [[ "$AUTO_REJOIN" == "true" ]] && AUTO_REJOIN=false || AUTO_REJOIN=true
               echo -e "${G}  Auto Rejoin FC: $AUTO_REJOIN${N}"; save_config; sleep 1 ;;
            5) echo -ne "  Interval (menit) → "; read -r _i
               [[ "$_i" =~ ^[0-9]+$ ]] && CHECK_INTERVAL="$_i"; save_config ;;
            6) clr; banner; hdr "LOG"
               if [[ -f "$LOG_FILE" ]]; then
                   echo ""
                   tail -50 "$LOG_FILE"
                   echo ""
               else
                   echo -e "${Y}  Log kosong.${N}"
               fi
               enter ;;
            7) _self_update ;;
            0) break ;;
            *) echo -e "${R}  Tidak valid.${N}"; sleep 0.8 ;;
        esac
    done
}

_self_update() {
    clr; banner; hdr "UPDATE DARI GITHUB"; echo ""
    echo -e "${C}  [~] Menghubungi GitHub...${N}"
    echo -e "  ${D}URL: $SELF_URL${N}"
    echo ""
    local _tmp="$INSTALL_DIR/update_tmp.sh"
    if curl -fsSL "$SELF_URL" -o "$_tmp" 2>/dev/null; then
        chmod +x "$_tmp"
        cp "$_tmp" "$INSTALL_DIR/mytoolbox.sh"
        # Update command toolbox jika PREFIX tersedia
        if [[ -n "$PREFIX" && -d "$PREFIX/bin" ]]; then
            cp "$_tmp" "$PREFIX/bin/toolbox"
            echo -e "${G}  [✓] Command 'toolbox' diperbarui.${N}"
        fi
        rm -f "$_tmp"
        echo -e "${G}  [✓] Update berhasil! Restart toolbox untuk efek.${N}"
        log_write "Self-update berhasil"
    else
        echo -e "${R}  [✗] Gagal koneksi. Cek internet atau SELF_URL di script.${N}"
        log_write "Self-update gagal"
    fi
    enter
}

# ═══════════════════════════════════════════════════════════
#  7) ABOUT
# ═══════════════════════════════════════════════════════════
menu_about() {
    clr; banner; hdr "ABOUT"; echo ""
    sep
    printf "  ${D}%-20s${N}  %s\n" "Versi"        "${W}${VERSION}${N}"
    printf "  ${D}%-20s${N}  %s\n" "User"         "${W}${USER_NAME}${N}"
    printf "  ${D}%-20s${N}  %s\n" "Jumlah App"   "${W}${#APP_NAMES[@]}${N}"
    printf "  ${D}%-20s${N}  %s\n" "Config"       "${D}${CONFIG_FILE}${N}"
    printf "  ${D}%-20s${N}  %s\n" "Log"          "${D}${LOG_FILE}${N}"
    printf "  ${D}%-20s${N}  %s\n" "Repo"         "${D}${SELF_URL}${N}"
    sep
    echo ""
    echo -e "  ${W}Fitur:${N}"
    echo -e "  ${M}✓${N}  Header WAYY di semua halaman"
    echo -e "  ${G}✓${N}  Deep Link dengan Owner & Judul"
    echo -e "  ${G}✓${N}  Setup konfigurasi (nama, delay, mode)"
    echo -e "  ${G}✓${N}  Launch sequential / parallel tanpa popup"
    echo -e "  ${G}✓${N}  Auto Rejoin HANYA saat Force Close"
    echo -e "  ${G}✓${N}  List Package khusus Roblox"
    echo -e "  ${G}✓${N}  Clear cache, Package Manager"
    echo -e "  ${G}✓${N}  Self-update dari GitHub"
    echo ""; enter
}

# ═══════════════════════════════════════════════════════════
#  8) UNINSTALL
# ═══════════════════════════════════════════════════════════
menu_uninstall() {
    clr; banner; hdr "UNINSTALL TOOLBOX"; echo ""
    echo -e "${R}  [!] Akan menghapus:${N}"
    echo -e "  ${D}• $INSTALL_DIR  (config, apps, log)${N}"
    [[ -n "$PREFIX" ]] && echo -e "  ${D}• $PREFIX/bin/toolbox${N}"
    echo ""
    confirm "Yakin ingin uninstall?" || { enter; return; }
    confirm "Konfirmasi sekali lagi — hapus semua?" || { enter; return; }
    rm -rf "$INSTALL_DIR"
    [[ -n "$PREFIX" ]] && rm -f "$PREFIX/bin/toolbox"
    echo ""
    echo -e "${G}  [✓] Diuninstall. Goodbye, ${USER_NAME}!${N}"
    sleep 2; exit 0
}

# ═══════════════════════════════════════════════════════════
#  MAIN MENU
# ═══════════════════════════════════════════════════════════
main_menu() {
    load_config; load_apps
    log_write "WAYY Toolbox dijalankan (v${VERSION}) — ${USER_NAME}"

    while true; do
        clr; banner
        echo -e "  ${Y}What would you like to do?${N}"
        echo ""
        echo -e "  ${W}[1]${N}  ${G}Setup Configuration${N}   ${D}First Run${N}"
        echo -e "  ${W}[2]${N}  Edit App List          ${D}${#APP_NAMES[@]} app terdaftar${N}"
        echo -e "  ${W}[3]${N}  ${Y}Run Script${N}             ${D}Launch + Monitor FC${N}"
        echo -e "  ${W}[4]${N}  Clear All App Caches"
        echo -e "  ${W}[5]${N}  Package Manager        ${D}Roblox / Install / Uninstall${N}"
        echo -e "  ${W}[6]${N}  Settings"
        echo -e "  ${W}[7]${N}  About"
        echo -e "  ${W}[8]${N}  ${R}Uninstall Toolbox${N}"
        echo -e "  ${W}[9]${N}  ${R}Exit${N}"
        echo ""
        echo -ne "  ${C}Enter your choice [1-9] → ${N}"; read -r _c

        case "$_c" in
            1) menu_setup     ;;
            2) menu_edit      ;;
            3) menu_run       ;;
            4) menu_clear     ;;
            5) menu_package   ;;
            6) menu_settings  ;;
            7) menu_about     ;;
            8) menu_uninstall ;;
            9) clr
               echo ""
               echo -e "${M}  WAYY Toolbox — Sampai jumpa, ${USER_NAME}!${N}"
               log_write "Toolbox ditutup"
               echo ""
               exit 0 ;;
            *) echo -e "${R}  Pilihan tidak valid.${N}"; sleep 0.8 ;;
        esac
    done
}

main_menu
