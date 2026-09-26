-- 旧键位优先：肌肉记忆来自 end4/caelestia Hyprland rice，映射到 Omarchy 等价功能。
-- 策略见会话映射表。改键前必须 hl.unbind 掉 Omarchy 默认。

local function zoom_by(delta)
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  local next = zoom + delta
  if next > 3.0 then
    next = 3.0
  elseif next < 1.0 then
    next = 1.0
  end
  hl.config({ cursor = { zoom_factor = next } })
end

--------------------------------------------------------------------
-- A. 应用启动
--------------------------------------------------------------------

-- Super+W: 浏览器（挤掉 Omarchy 关窗口；关窗口改到 Super+Q）
hl.unbind("SUPER + W")
o.bind("SUPER + W", "Browser", { omarchy = "browser" })

-- Super+E: 文件管理（Omarchy 原在 Super+Shift+F，保留作第二入口）
o.bind("SUPER + E", "File manager", { omarchy = "nautilus" })

-- Super+C: 代码编辑器（挤掉 Universal copy）
hl.unbind("SUPER + C")
o.bind("SUPER + C", "Editor", { omarchy = "editor" })

-- Super+X: 文本/编辑器（挤掉 Universal cut；与 C 同走 editor）
hl.unbind("SUPER + X")
o.bind("SUPER + X", "Editor", { omarchy = "editor" })

-- Super+T: 本机无 quake → 留 Omarchy 浮动切换

o.bind("SUPER + F1", "Toggle input method", "pkill fcitx5 || fcitx5 -d")

--------------------------------------------------------------------
-- B. 窗口
--------------------------------------------------------------------

o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

-- Super+D: 最大化（Omarchy 的 maximize 在 Alt+F = Full width，保留）
o.bind("SUPER + D", "Maximize", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

-- Super+Alt+Space: 浮动（挤掉 Apps menu）
hl.unbind("SUPER + ALT + SPACE")
o.bind("SUPER + ALT + SPACE", "Float/Tile", hl.dsp.window.float({ action = "toggle" }))

-- Super+P: Pin（挤掉 Pseudo）
hl.unbind("SUPER + P")
o.bind("SUPER + P", "Pin window", hl.dsp.window.pin())

-- Super+Shift+方向: 移动窗口（挤掉 Swap）
hl.unbind("SUPER + SHIFT + LEFT")
hl.unbind("SUPER + SHIFT + RIGHT")
hl.unbind("SUPER + SHIFT + UP")
hl.unbind("SUPER + SHIFT + DOWN")
o.bind("SUPER + SHIFT + LEFT", "Move window left", hl.dsp.window.move({ direction = "l" }))
o.bind("SUPER + SHIFT + RIGHT", "Move window right", hl.dsp.window.move({ direction = "r" }))
o.bind("SUPER + SHIFT + UP", "Move window up", hl.dsp.window.move({ direction = "u" }))
o.bind("SUPER + SHIFT + DOWN", "Move window down", hl.dsp.window.move({ direction = "d" }))

-- splitratio
o.bind("SUPER + Semicolon", "Split ratio -", hl.dsp.layout("splitratio -0.1"), { repeating = true })
o.bind("SUPER + Apostrophe", "Split ratio +", hl.dsp.layout("splitratio +0.1"), { repeating = true })

--------------------------------------------------------------------
-- C. 工作区 / Scratchpad / 会话
--------------------------------------------------------------------

-- Super+Alt+1..0: 静默移到工作区（挤掉编组窗口 1..5）
for i = 1, 5 do
  hl.unbind("SUPER + ALT + code:" .. tostring(i + 9))
end
for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  o.bind(
    "SUPER + ALT + " .. key,
    "Move window silently to workspace " .. workspace,
    hl.dsp.window.move({ workspace = tostring(workspace), follow = false })
  )
end

o.bind("SUPER + U", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))

-- Super+滚轮：Omarchy 默认 e+1/e-1 是「已打开工作区」之间循环，会跳过空的，
-- 滚到最后一个就绕回第一个（反向跳）。改成 r+1/r-1：按当前显示器连续
-- 递增/递减，空工作区也算一站，滚到头不回绕。
hl.unbind("SUPER + mouse_down")
hl.unbind("SUPER + mouse_up")
o.bind("SUPER + mouse_down", "Scroll to next workspace", hl.dsp.focus({ workspace = "r+1" }))
o.bind("SUPER + mouse_up", "Scroll to previous workspace", hl.dsp.focus({ workspace = "r-1" }))

-- Super+Ctrl+U/I: 移窗到相邻工作区（挤掉 idle toggle on Ctrl+I）
hl.unbind("SUPER + CTRL + I")
o.bind("SUPER + CTRL + U", "Move window to previous workspace", hl.dsp.window.move({ workspace = "e-1" }))
o.bind("SUPER + CTRL + I", "Move window to next workspace", hl.dsp.window.move({ workspace = "e+1" }))

-- Super+L: 锁屏（挤掉 layout toggle）
hl.unbind("SUPER + L")
o.bind("SUPER + L", "Lock system", "omarchy-system-lock")

o.bind("SUPER + SHIFT + L", "Sleep", "systemctl suspend || loginctl suspend", { locked = true })

-- Ctrl+Alt+Delete: 系统/会话菜单（挤掉关全部窗口）
hl.unbind("CTRL + ALT + DELETE")
o.bind("CTRL + ALT + DELETE", "System menu", "omarchy-menu toggle system")

--------------------------------------------------------------------
-- D. 剪贴板 / 表情 / 截图录屏 / 取色 / OCR
--------------------------------------------------------------------

-- Super+V: 剪贴板历史（挤掉 Universal paste）
hl.unbind("SUPER + V")
o.bind("SUPER + V", "Clipboard manager", "omarchy-shell shell toggle omarchy.clipboard")

o.bind("SUPER + Period", "Emojis", "omarchy-shell shell toggle omarchy.emojis")

-- Super+Shift+C: 取色（挤掉 Calendar 网页）
hl.unbind("SUPER + SHIFT + C")
o.bind("SUPER + SHIFT + C", "Color picker", "pkill hyprpicker || hyprpicker -a")

-- Super+Shift+S: 区域截图（挤掉 Google Maps）
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Screenshot region", "omarchy-capture-screenshot region")

-- Super+Shift+X: OCR（挤掉 X 网页）
hl.unbind("SUPER + SHIFT + X")
o.bind("SUPER + SHIFT + X", "OCR", "omarchy-capture-text")

o.bind("SUPER + SHIFT + R", "Screenrecording", "omarchy-capture-screenrecording --stop-recording || omarchy-menu toggle trigger.capture.screenrecord", { locked = true })

-- Ctrl+Alt+R: 高质量扬声器录屏（系统声音，very_high / 60fps / CFR / 硬件编码），再按一次停止
o.bind("CTRL + ALT + R", "Record with system audio (HQ)", "$HOME/.local/bin/record-speaker-hq")

o.bind("SHIFT + PRINT", "Screenshot region", "omarchy-capture-screenshot region", { locked = true })
o.bind("CTRL + PRINT", "Screenshot fullscreen", "omarchy-capture-screenshot fullscreen", { locked = true })
o.bind("SUPER + F12", "Screenshot region", "omarchy-capture-screenshot region")

--------------------------------------------------------------------
-- E. 媒体（软件键；硬件 XF86 留 Omarchy）
--------------------------------------------------------------------

hl.unbind("SUPER + SHIFT + N") -- 原 Editor
o.bind("SUPER + SHIFT + N", "Next track", "omarchy-shell media next", { locked = true })

hl.unbind("SUPER + SHIFT + B") -- 原 Browser
o.bind("SUPER + SHIFT + B", "Previous track", "omarchy-shell media previous", { locked = true })

hl.unbind("SUPER + SHIFT + P") -- 原 Google Photos
o.bind("SUPER + SHIFT + P", "Play/Pause", "omarchy-shell media playPause", { locked = true })

hl.unbind("SUPER + SHIFT + M") -- 原 Spotify/Music
o.bind("SUPER + SHIFT + M", "Mute", "omarchy-audio-output-volume mute-toggle", { locked = true })

o.bind("SUPER + ALT + M", "Mute microphone", "omarchy-audio-input-mute", { locked = true })

--------------------------------------------------------------------
-- F. 光标缩放 / 壁纸
--------------------------------------------------------------------

-- Super+−/=: 光标缩放（挤掉窗口扩缩；Ctrl/Alt 变体仍在）
hl.unbind("SUPER + code:20")
hl.unbind("SUPER + code:21")
o.bind("SUPER + code:20", "Zoom out", function() zoom_by(-0.3) end, { repeating = true })
o.bind("SUPER + code:21", "Zoom in", function() zoom_by(0.3) end, { repeating = true })
o.bind("SUPER + Minus", "Zoom out", function() zoom_by(-0.3) end, { repeating = true })
o.bind("SUPER + Equal", "Zoom in", function() zoom_by(0.3) end, { repeating = true })

o.bind("SUPER + F10", "Next background", "omarchy-theme-bg-next")
o.bind("SUPER + SHIFT + F10", "Download random wallpaper", "$HOME/.config/scripts/random-anime-wallpaper.sh")
o.bind("CTRL + SUPER + T", "Background switcher", "omarchy-menu toggle background")
o.bind("CTRL + ALT + T", "Background switcher", "omarchy-menu toggle background")
o.bind("SUPER + ALT + T", "Matugen color strategy", "$HOME/.config/scripts/matugen-select-type.sh")

--------------------------------------------------------------------
-- G. 速查表
--------------------------------------------------------------------

-- Super+/: keybindings（挤掉 monitor scale up；Alt+/ scale down 仍在）
hl.unbind("SUPER + SLASH")
o.bind("SUPER + SLASH", "Keybindings", "omarchy-menu-keybindings")
