-- 移植自旧机配置：hyprland/general.lua + custom/general.lua + shellOverrides 最终滑条值。
-- Omarchy 默认值仍由 /usr/share/omarchy/default/hypr/looknfeel.lua 提供，本文件在其后加载并覆盖。

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 5,
    gaps_workspaces = 50,
    border_size = 3,

    col = {
      active_border = "rgba(0DB7D455)",
      inactive_border = "rgba(31313600)",
    },

    resize_on_border = true,
    no_focus_fallback = true,
    allow_tearing = true,
    snap = {
      enabled = true,
      window_gap = 4,
      monitor_gap = 5,
      respect_gaps = true,
    },
  },

  decoration = {
    active_opacity = 0.95,
    inactive_opacity = 0.75,
    fullscreen_opacity = 1,
    rounding = 15,
    rounding_power = 2.8,

    blur = {
      enabled = true,
      size = 2,
      passes = 3,
      xray = true,
      special = true,
      new_optimizations = true,
      brightness = 1.02,
      contrast = 1.03,
      noise = 0.02,
      vibrancy = 0.55,
      vibrancy_darkness = 0.35,
      popups = true,
      popups_ignorealpha = 0.5,
      input_methods = true,
      input_methods_ignorealpha = 0.7,
    },

    -- 阴影不在这里写：由 matugen 模板产物 ~/.config/hypr/hyprland/colors.lua
    -- 跟随壁纸主题色设置（见 hyprland.lua 末尾的 require("hyprland.colors")）。

    dim_inactive = true,
    dim_strength = 0.12,
    dim_special = 0.18,
  },

  animations = {
    enabled = true,
  },

  dwindle = {
    preserve_split = true,
    smart_split = false,
    smart_resizing = false,
  },

  cursor = {
    -- 键盘/脚本/面板切换焦点时不再把光标拽到目标窗口
    no_warps = true,
    zoom_factor = 1,
    zoom_rigid = false,
    zoom_disable_aa = true,
    hotspot_padding = 1,
  },

  misc = {
    vrr = 0,
    animate_manual_resizes = false,
    animate_mouse_windowdragging = false,
    enable_swallow = false,
    swallow_regex = "(foot|kitty|allacritty|Alacritty)",
    on_focus_under_fullscreen = 2,
    session_lock_xray = true,
    initial_workspace_tracking = false,
    focus_on_activate = true,
  },

  binds = {
    scroll_event_delay = 0,
    -- 工作区切换不绕回：滚到头就停住（配合 bindings.lua 里滚轮改用 r+1/r-1）
    allow_workspace_cycles = false,
  },

  xwayland = {
    force_zero_scaling = true,
  },
})

-- ============================================================
-- 动画：以旧机 shellOverrides（面板最终写入值）为准，
-- 下面再补模板里 shellOverrides 没覆盖到的叶子。
-- ============================================================
hl.curve("specialWorkSwitch", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("emphasizedAccel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("emphasizedDecel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("standard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "emphasizedDecel" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "emphasizedAccel" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 5, bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 4, bezier = "emphasizedAccel", style = "slide" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 5, bezier = "standard" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "standard" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "specialWorkSwitch", style = "slidefadevert 15%" })
hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "standard" })

-- 旧机模板中未被 shellOverrides 覆盖的叶子
hl.curve("bounce", { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1 } } })
hl.curve("standardDecel", { type = "bezier", points = { { 0, 0 }, { 0, 1 } } })
hl.curve("stall", { type = "bezier", points = { { 1, -0.1 }, { 0, 0.85 } } })
hl.curve("menu_decel", { type = "bezier", points = { { 0.1, 1 }, { 0, 1 } } })

hl.animation({ leaf = "fadeIn", enabled = true, speed = 6, bezier = "bounce" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 7, bezier = "standardDecel" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 8, bezier = "menu_decel" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 3, bezier = "stall" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 8, bezier = "emphasizedDecel", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 8, bezier = "emphasizedAccel", style = "slidevert" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 8, bezier = "standardDecel" })
