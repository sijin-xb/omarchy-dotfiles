-- ============================================================
-- 移植自旧机 hyprland/rules.lua + custom/rules.lua（选择性移植）
-- ------------------------------------------------------------
-- 已剔除（旧机专属 / 本机不适用）：
--   · KDE/plasma/dolphin/portal-desktop.kde 相关规则
--   · illogical-impulse / Nexus / quickshell:* / ags / caelestia 面板规则
--     （Omarchy 自带 shell，自带对应 layer 规则）
--   · 终端召唤（SUPER+T / special:quake）→ 留到快捷键移植阶段一起做
--   · 空的 Hyprland `class=""` xwayland 一条保留
-- 验证：hyprctl reload && hyprctl configerrors
-- ============================================================

-- ######## 窗口规则 ########

-- xwayland 空类名右键菜单：关模糊
hl.window_rule({ match = { class = "^()$", title = "^()$" }, no_blur = true })

-- 全局模糊开关：所有普通窗口允许模糊
hl.window_rule({ match = { class = ".*" }, no_blur = false })

-- ---- 文件选择器 / 弹窗：强制悬浮 + 居中，不进平铺 ----
local dialog_titles = {
  "^(Open File)(.*)$",
  "^(Select a File)(.*)$",
  "^(Choose wallpaper)(.*)$",
  "^(Open Folder)(.*)$",
  "^(Save As)(.*)$",
  "^(Library)(.*)$",
  "^(File Upload)(.*)$",
  "^(.*)(wants to save)$",
  "^(.*)(wants to open)$",
}
for _, title in ipairs(dialog_titles) do
  hl.window_rule({ match = { title = title }, float = true, center = true })
end
hl.window_rule({
  match = { title = "^(Choose wallpaper)(.*)$" },
  size = { "(monitor_w*0.60)", "(monitor_h*0.65)" },
})

-- ---- 具体应用的悬浮/尺寸 ----
hl.window_rule({ match = { class = "^(blueberry\\.py)$" }, float = true })
hl.window_rule({ match = { class = "^(guifetch)$" }, float = true })
for _, class in ipairs({ "^(pavucontrol)$", "^(org\\.pulseaudio\\.pavucontrol)$", "^(nm-connection-editor)$" }) do
  hl.window_rule({
    match = { class = class },
    float = true,
    center = true,
    size = { "(monitor_w*0.45)", "(monitor_h*0.45)" },
  })
end
hl.window_rule({ match = { class = "^(Zotero)$" }, float = true })
hl.window_rule({ match = { class = "^(Zotero)$" }, size = { "(monitor_w*0.45)", "(monitor_h*0.45)" } })
hl.window_rule({ match = { title = ".*Welcome" }, float = true })

-- ---- 画中画：悬浮 + 固定 + 保宽高比，右下角 ----
hl.window_rule({
  match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
  float = true,
  pin = true,
  keep_aspect_ratio = true,
  size = { "480", "270" },
  move = { "(monitor_w*0.73)", "(monitor_h*0.72)" },
})

-- ---- 屏幕共享提示条：悬浮 + pin + 贴底居中 ----
hl.window_rule({
  match = { title = ".*is sharing (a window|your screen).*" },
  float = true,
  pin = true,
  move = { "(monitor_w*.5-window_w*.5)", "(monitor_h-window_h-12)" },
})

-- ---- 撕裂/立即渲染：游戏降输入延迟 ----
hl.window_rule({ match = { title = ".*\\.exe" }, immediate = true })
hl.window_rule({ match = { title = ".*minecraft.*" }, immediate = true })
hl.window_rule({ match = { class = "^(steam_app).*" }, immediate = true })

-- 平铺窗口不要阴影
hl.window_rule({ match = { float = 0 }, no_shadow = true })

-- ---- 液态玻璃：差异化透明度（旧机 custom/rules.lua）----
-- 终端
hl.window_rule({
  match = { class = "^(kitty|foot|Alacritty|wezterm|kitty-quake)$" },
  opacity = 0.90,
})
-- 浏览器（可读性优先）
hl.window_rule({
  match = { class = "^(firefox|zen|zen-browser|chromium|brave-browser|google-chrome|microsoft-edge|vivaldi)$" },
  opacity = 0.92,
})
-- 编辑器 / IDE
hl.window_rule({
  match = { class = "^(code|code-oss|VSCodium|jetbrains-.*|neovide)$" },
  opacity = 0.93,
})
-- 视频 / 游戏：完全不透明 + 关模糊
hl.window_rule({
  match = { class = "^(mpv|vlc|celluloid|steam_app_.*|gamescope)$" },
  opacity = 1.0,
  no_blur = true,
})
-- 截图 / 录屏 / 取色：豁免模糊
hl.window_rule({
  match = { class = "^(flameshot|grim|slurp|hyprpicker|obs|wf-recorder)$" },
  no_blur = true,
})
-- 输入法候选框：避免文字发虚
hl.window_rule({
  match = { class = "^(fcitx|fcitx5|ibus)$" },
  no_blur = true,
})
-- 系统弹窗：强制悬浮 + 居中
hl.window_rule({
  match = { class = "^(blueman-manager|xdg-desktop-portal-gtk)$" },
  float = true,
  center = true,
})

-- ######## 工作区规则 ########
-- special 工作区外边距（hl.* 为 Hyprland 0.55+ 原生 lua API）
hl.workspace_rule({ workspace = "special:special", gaps_out = 30 })

-- ######## 图层规则 ########

-- 所有图层 xray：模糊采样可“看穿”下层
hl.layer_rule({ match = { namespace = ".*" }, xray = true })

-- 秒开秒关类
local no_anim_namespaces = {
  "walker", "selection", "overview", "anyrun",
  "indicator.*", "osk", "hyprpicker", "noanim",
}
for _, ns in ipairs(no_anim_namespaces) do
  hl.layer_rule({ match = { namespace = ns }, no_anim = true })
end

-- GTK layer-shell / 启动器 / 通知 / 注销菜单
hl.layer_rule({ match = { namespace = "gtk-layer-shell" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "launcher" }, blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.69 })
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })

-- 启动器类图层必须“快”，禁用动画减少感知延迟
hl.layer_rule({ match = { namespace = "gtk4-layer-shell" }, no_anim = true })
