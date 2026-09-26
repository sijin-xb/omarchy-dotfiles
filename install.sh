#!/usr/bin/env bash
#
# omarchy-dotfiles 安装脚本
#
# 把本仓库的 dot_config/ → ~/.config，dot_local/ → ~/.local，
# 然后接好 matugen → Omarchy 的 MD3 取色链路。
#
# 用法：
#   ./install.sh              安装（已存在的文件会先备份）
#   ./install.sh --dry-run    只打印将要做什么，不改动磁盘
#   ./install.sh --no-pkgs    跳过依赖安装
#   ./install.sh --no-reload  装完不自动 hyprctl reload
#   ./install.sh -h           帮助
#
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO_DIR/dot_config"
LOCAL_SRC="$REPO_DIR/dot_local"

DRY_RUN=0
DO_PKGS=1
DO_RELOAD=1

C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YEL=$'\033[33m'; C_DIM=$'\033[2m'
[[ -t 1 ]] || { C_RESET=""; C_BOLD=""; C_RED=""; C_GRN=""; C_YEL=""; C_DIM=""; }

info()  { printf '%s==>%s %s\n' "$C_BOLD" "$C_RESET" "$*"; }
ok()    { printf ' %s✓%s %s\n' "$C_GRN" "$C_RESET" "$*"; }
warn()  { printf ' %s!%s %s\n' "$C_YEL" "$C_RESET" "$*" >&2; }
err()   { printf '%s错误%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }
die()   { err "$*"; exit 1; }

usage() { sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

while (($#)); do
  case "$1" in
    --dry-run)   DRY_RUN=1 ;;
    --no-pkgs)   DO_PKGS=0 ;;
    --no-reload) DO_RELOAD=0 ;;
    -h|--help)   usage ;;
    *) die "未知参数：$1（用 -h 看用法）" ;;
  esac
  shift
done

run() {
  if ((DRY_RUN)); then printf '%s   $ %s%s\n' "$C_DIM" "$*" "$C_RESET"; else "$@"; fi
}
copy() { # copy <src> <dst>
  if ((DRY_RUN)); then printf '%s   cp %s → %s%s\n' "$C_DIM" "$1" "$2" "$C_RESET"; else cp -a -- "$1" "$2"; fi
}

# ---------------------------------------------------------------- 0. 前置检查

[[ -d $CONFIG_SRC ]] || die "找不到 $CONFIG_SRC（脚本必须在仓库根目录运行）"

OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
if [[ ! -d $OMARCHY_PATH ]]; then
  warn "没找到 Omarchy（$OMARCHY_PATH）。本仓库是 Omarchy 的叠加配置，"
  warn "没有 Omarchy 的话 Hyprland 侧的 require(\"default.hypr.omarchy\") 会失败。"
  if [[ -t 0 ]]; then
    read -r -p "仍要继续？[y/N] " ans
    [[ $ans =~ ^[Yy]$ ]] || exit 1
  fi
fi

command -v hyprctl >/dev/null 2>&1 || warn "hyprctl 不在 PATH，跳过最后的 reload"

# ---------------------------------------------------------------- 1. 依赖

PKGS_NEEDED=()
have() { command -v "$1" >/dev/null 2>&1; }

have matugen   || PKGS_NEEDED+=("matugen")
[[ -d /usr/share/themes/adw-gtk3-dark ]] || PKGS_NEEDED+=("adw-gtk-theme")
[[ -d /usr/share/icons/Bibata-Modern-Ice || -d $HOME/.local/share/icons/Bibata-Modern-Ice ]] \
  || PKGS_NEEDED+=("bibata-cursor-theme-bin")

if ((DO_PKGS)) && ((${#PKGS_NEEDED[@]})); then
  info "安装依赖：${PKGS_NEEDED[*]}"
  if have omarchy; then
    run omarchy pkg add "${PKGS_NEEDED[@]}" \
      || warn "omarchy pkg add 失败，请手动安装：${PKGS_NEEDED[*]}"
  elif have yay; then
    run yay -S --needed "${PKGS_NEEDED[@]}" || warn "yay 安装失败，请手动安装：${PKGS_NEEDED[*]}"
  elif have paru; then
    run paru -S --needed "${PKGS_NEEDED[@]}" || warn "paru 安装失败，请手动安装：${PKGS_NEEDED[*]}"
  else
    warn "没找到 omarchy/yay/paru，请手动安装：${PKGS_NEEDED[*]}"
  fi
elif ((${#PKGS_NEEDED[@]})); then
  warn "缺少依赖（已跳过安装）：${PKGS_NEEDED[*]}"
else
  ok "依赖齐全"
fi

# ---------------------------------------------------------------- 2. 备份

BACKUP_ROOT="$HOME/.local/state/omarchy-dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
backup_one() { # 目标路径 → 备份
  local target="$1"
  [[ -e $target || -L $target ]] || return 0
  local dest="$BACKUP_ROOT/${target#$HOME/}"
  if ((DRY_RUN)); then
    printf '%s   backup %s%s\n' "$C_DIM" "$target" "$C_RESET"
  else
    mkdir -p -- "$(dirname -- "$dest")"
    cp -a -- "$target" "$dest"
  fi
}

info "备份已存在的目标文件 → $BACKUP_ROOT"
# 只备份会被覆盖的路径（顶层目录逐项备份，避免整目录搬家）
for item in "$CONFIG_SRC"/*; do
  backup_one "$HOME/.config/$(basename -- "$item")"
done
for item in "$LOCAL_SRC"/*; do
  backup_one "$HOME/.local/$(basename -- "$item")"
done
ok "备份完成"

# ---------------------------------------------------------------- 3. 部署

info "部署配置"
mkdir -p -- "$HOME/.config" "$HOME/.local"
copy "$CONFIG_SRC/." "$HOME/.config/"
copy "$LOCAL_SRC/."  "$HOME/.local/"

# 兜底：Omarchy 自带的 monitors.lua 若被覆盖成空，hyprland.lua 的 require 会报错
if [[ ! -f $HOME/.config/hypr/monitors.lua && -f $CONFIG_SRC/hypr/optional/monitors.lua ]]; then
  copy "$CONFIG_SRC/hypr/optional/monitors.lua" "$HOME/.config/hypr/monitors.lua"
fi
# 兜底：matugen 产物 colors.lua 缺失时 require("hyprland.colors") 会报错
if [[ ! -f $HOME/.config/hypr/hyprland/colors.lua && -f $CONFIG_SRC/hypr/optional/hyprland-colors.lua.default ]]; then
  mkdir -p -- "$HOME/.config/hypr/hyprland"
  copy "$CONFIG_SRC/hypr/optional/hyprland-colors.lua.default" "$HOME/.config/hypr/hyprland/colors.lua"
fi
ok "文件就位"

info "修正可执行位"
# 注意：不用进程替换（< <(...)），有些环境没有 /dev/fd
chmod_tree() { # chmod_tree <dir> [find 过滤...]
  local dir="$1"; shift
  [[ -d $dir ]] || return 0
  if ((DRY_RUN)); then
    # 颜色变量必须拼进 printf 格式串里，不能作为独立参数（否则被 find 当成路径）
    find "$dir" -type f "$@" -printf "${C_DIM}   chmod +x %p${C_RESET}\n"
  else
    find "$dir" -type f "$@" -exec chmod +x {} +
  fi
}
chmod_tree "$HOME/.config/scripts"
chmod_tree "$HOME/.config/matugen/scripts"
chmod_tree "$HOME/.local/bin"
chmod_tree "$HOME/.config/omarchy/hooks" -not -name '*.sample'  # hooks：不管扩展名，但跳过 .sample
ok "可执行位已修正"

# ---------------------------------------------------------------- 4. systemd

if command -v systemctl >/dev/null 2>&1; then
  info "启用 matugen-on-wallpaper.path（壁纸变更自动取色）"
  run systemctl --user daemon-reload
  run systemctl --user enable --now matugen-on-wallpaper.path \
    || warn "systemd 单元启用失败（非 systemd 会话可忽略）"
fi

# ---------------------------------------------------------------- 5. gsettings

if have gsettings; then
  info "设置 GTK 主题 / 图标 / 光标"
  run gsettings set org.gnome.desktop.interface color-scheme prefer-dark
  run gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
  run gsettings set org.gnome.desktop.interface icon-theme Adwaita-Matugen-B
  run gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Ice
  run gsettings set org.gnome.desktop.interface cursor-size 24
fi

# ---------------------------------------------------------------- 6. 首次取色

BG="$(readlink -f "$HOME/.local/state/omarchy/current/background" 2>/dev/null || true)"
if [[ -n ${BG:-} && -f $BG ]]; then
  info "按当前壁纸跑一次 matugen"
  if ((DRY_RUN)); then
    printf '%s   $ %s%s\n' "$C_DIM" "$HOME/.config/scripts/matugen-update.sh $BG" "$C_RESET"
  else
    "$HOME/.config/scripts/matugen-update.sh" "$BG" \
      >>"${XDG_CACHE_HOME:-$HOME/.cache}/omarchy/matugen.log" 2>&1 \
      || run matugen image "$BG" \
      || warn "首次取色失败，看日志：${XDG_CACHE_HOME:-$HOME/.cache}/omarchy/matugen.log"
  fi
else
  warn "没找到当前壁纸，跳过首次取色（换一次壁纸即会自动触发）"
fi

# ---------------------------------------------------------------- 7. 重载

if ((DO_RELOAD)) && command -v hyprctl >/dev/null 2>&1; then
  info "重载 Hyprland 配置"
  run hyprctl reload || warn "hyprctl reload 失败（Hyprland 可能没在跑，下次启动生效）"
fi

# ---------------------------------------------------------------- 收尾

printf '\n'
info "完成"
[[ -d $BACKUP_ROOT ]] && printf '备份位置：%s\n' "$BACKUP_ROOT"
cat <<'TIP'
常用键：
  Super+F10          换下一张壁纸（自动触发 matugen 重新取色）
  Ctrl+Super+T       壁纸选择菜单
  Super+Alt+T        切换 matugen 取色策略 / 明暗
  Super+/            快捷键速查
日志：
  ~/.cache/omarchy/matugen.log
TIP
