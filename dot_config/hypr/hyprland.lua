-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- ---- 移植旧机 env（旧机 hyprland/env.lua；未带入 KDE/quickshell 条目）----
local home_dir = os.getenv("HOME")

-- 鼠标指针：Bibata Modern Ice（深色主题下更清晰；变体可换 Classic / Amber）
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Fcitx5 / Rime
hl.env("LANGUAGE", "zh_CN:en")
hl.env("LANG", "zh_CN.UTF-8")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULES", "wayland;fcitx")

-- Flatpak 应用的 .desktop 发现（按列表去重重建，reload 多少次都不会叠加）
local flatpak_dirs = {
  home_dir .. "/.local/share/flatpak/exports/share",
  "/var/lib/flatpak/exports/share",
}
local seen = {}
local xdg_dirs = {}
local function push_dir(dir)
  if dir ~= "" and not seen[dir] then
    seen[dir] = true
    xdg_dirs[#xdg_dirs + 1] = dir
  end
end
for _, dir in ipairs(flatpak_dirs) do
  push_dir(dir)
end
for dir in (os.getenv("XDG_DATA_DIRS") or ""):gmatch("[^:]+") do
  push_dir(dir)
end
hl.env("XDG_DATA_DIRS", table.concat(xdg_dirs, ":"))

-- PATH：~/.local/bin 必须排在 /usr/share/omarchy/bin 前面，
-- 否则 omarchy-theme-bg-set 包装器（触发 matugen MD3 换色）会被官方二进制盖住。
do
  local local_bin = home_dir .. "/.local/bin"
  local omarchy_bin = (os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/bin"
  local path_seen = {}
  local path_dirs = {}
  local function push_path(dir)
    if dir ~= "" and not path_seen[dir] then
      path_seen[dir] = true
      path_dirs[#path_dirs + 1] = dir
    end
  end
  push_path(local_bin)
  push_path(omarchy_bin)
  for dir in (os.getenv("PATH") or ""):gmatch("[^:]+") do
    push_path(dir)
  end
  hl.env("PATH", table.concat(path_dirs, ":"))
end

-- AMD AMF（旧机 env.lua 原样保留）
hl.env("AMF_PATH", "/usr/lib")

-- 旧米的 matugen 链（switchwall）在 quickshell venv 缺失时会跳过取色，无害
hl.env("ILLOGICAL_IMPULSE_VIRTUAL_ENV", home_dir .. "/.local/state/quickshell/.venv")

-- ---- 移植旧机窗口/图层规则（见 rules.lua 文件头的剔除清单）----
require("hypr.rules")

-- ---- 壁纸取色产物（matugen 模板 ~/.config/hypr/hyprland/colors.lua）：
-- 边框/阴影/背景色跟随当前壁纸，必须放在 looknfeel 之后加载 ----
require("hyprland.colors")
