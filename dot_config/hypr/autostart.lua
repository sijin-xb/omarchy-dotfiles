-- 移植自旧机 hyprland/execs.lua。
-- 以下旧机条目按本机现状剔除：
--   · fcitx5 拉起 → Omarchy 用 systemd 服务（omarchy-fcitx5.service）管理
--   · qs / caelestia / quickshell 面板 → Omarchy 自带 shell
--   · hypridle → Omarchy 自带锁屏与空闲管理（旧机 hyprlock/hypridle 未移植）
--   · __restore_video_wallpaper（mpvpaper）→ 壁纸走 Omarchy 切换器
--   · easyeffects / geoclue-agent / cliphist → 本机未安装
--   · 光标主题缓存（FireflySpring 像素光标）→ 图标未随恢复带过来
hl.on("hyprland.start", function()
  -- 输入法：等 fcitx5 就绪后强制开启输入状态并切到 Rime（旧机登录习惯）
  hl.exec_cmd(
    "while ! fcitx5-remote --check >/dev/null 2>&1; do sleep 0.1; done; fcitx5-remote -o; fcitx5-remote -s rime"
  )

  -- 光标 + PATH：合成器子进程 / systemd 都能命中 ~/.local/bin 包装器
  hl.exec_cmd(
    "hyprctl setcursor Bibata-Modern-Ice 24 && "
      .. "systemctl --user set-environment "
      .. "XCURSOR_THEME=Bibata-Modern-Ice HYPRCURSOR_THEME=Bibata-Modern-Ice "
      .. "XCURSOR_SIZE=24 HYPRCURSOR_SIZE=24 "
      .. "PATH=\"$HOME/.local/bin:/usr/share/omarchy/bin:${PATH}\" && "
      .. "dbus-update-activation-environment --systemd "
      .. "XCURSOR_THEME HYPRCURSOR_THEME XCURSOR_SIZE HYPRCURSOR_SIZE PATH"
  )
end)
