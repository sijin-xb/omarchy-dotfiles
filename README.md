# omarchy-dotfiles

Omarchy（Hyprland 发行版）的个人叠加配置。核心是两件事：

1. **键位沿用旧 rice 的肌肉记忆**——把 end4 / caelestia 那套 Hyprland 键位映射到 Omarchy 的等价功能上，冲突处旧键优先。
2. **matugen → Omarchy 的 Material Design 3 取色**——换壁纸即全桌面换色，GTK / 图标 / Hyprland 边框 / Omarchy shell / 终端统一走 MD3 调色板。

## 目录结构

```
dot_config/
  hypr/                    Hyprland（lua 配置）
    hyprland.lua           主入口，require 其余文件 + 旧机 env 迁移
    bindings.lua           键位映射（本仓库的重头戏）
    looknfeel.lua          外观 / 动画 / binds 行为
    input.lua rules.lua    输入手感、窗口规则
    autostart.lua          光标 + PATH + 输入法
    optional/              monitors.lua、colors.lua 兜底副本
  matugen/
    config.toml            模板注册表（每个 [templates.*] = 一个产出）
    templates/             各应用的配色模板（含 gtk-3.0/4.0、图标重着色）
  omarchy/
    shell.json shell.toml  Omarchy shell（顶栏）配置
    hooks/                 post-boot.d / theme-set.d：壁纸目录接管 + 换色
  scripts/
    matugen-update.sh      取色唯一入口（策略状态 → matugen 全模板）
    matugen-select-type.sh 取色策略 / 明暗切换（Super+Alt+T）
    matugen-on-wallpaper.sh  systemd path 单元触发的取色
    random-anime-wallpaper.sh
  systemd/user/            壁纸软链变更 → 自动取色
  gtk-3.0/ gtk-4.0/        settings.ini（MD3 图标 / 光标 / 字体）
dot_local/bin/
  omarchy-theme-bg-set     PATH 包装器：换壁纸后触发取色
  omarchy-matugen-shell-sync  M3 调色板 → Omarchy 主题文件 + 热重载
```

## 安装

```bash
git clone https://github.com/sijin-xb/omarchy-dotfiles.git
cd omarchy-dotfiles
./install.sh              # 先 --dry-run 看看会改什么也行
```

脚本会：备份已存在的目标 → 拷贝配置 → 修可执行位 → 装依赖（`matugen`、
`adw-gtk-theme`、`bibata-cursor-theme-bin`）→ 启用 systemd path 单元 →
设 gsettings → 按当前壁纸跑一次取色 → `hyprctl reload`。

已存在的文件全部备份到 `~/.local/state/omarchy-dotfiles-backup/<时间戳>/`。

## matugen 链路是怎么接上的

Omarchy 原生的主题系统是「主题目录 + 模板产物」，换壁纸不会重新取色。
这里补了三条通路，任意一条命中都会触发取色，靠 `flock` 串行化：

| 触发方式 | 通路 |
| --- | --- |
| `omarchy-theme-bg-next` / 选图器 / `omarchy theme bg set` | PATH 包装器 `~/.local/bin/omarchy-theme-bg-set`（必须在 `/usr/share/omarchy/bin` 之前） |
| `omarchy theme set`（调度器直连真实现，绕过 PATH） | `~/.config/omarchy/hooks/theme-set.d/wallpapers-dir` 补一枪 |
| 任何方式改了 `current/background` 软链 | systemd `matugen-on-wallpaper.path`（`PathExistsChanged`） |

取色后：

- `matugen-update.sh` 按缓存的策略（`~/.cache/matugen-strategy/`）跑 `matugen image`，
  渲染 `config.toml` 里注册的全部模板；
- `omarchy-matugen-shell-sync`（挂在 `[templates.hyprland]` 的 `post_hook`）把 M3
  调色板翻译成 Omarchy 的 `colors.toml`，重生成主题产物并推给 quickshell，
  再 `hyprctl reload` 让边框跟上；
- GTK 走 `adw-gtk3-dark` + matugen 生成的 `gtk.css`；图标钉在
  `Adwaita-Matugen-{A,B}`（A/B 交替绕开图标缓存），不让 Omarchy 打回 Adwaita / Yaru。

**PATH 顺序是硬要求。** `hyprland.lua` 里把 `~/.local/bin` 提到
`/usr/share/omarchy/bin` 之前，否则包装器被官方二进制盖住，换壁纸不换色。

## 键位

旧键优先，冲突处先 `hl.unbind` 再绑。完整映射（A–H）：

**A. 应用** — `Super+W` 浏览器 · `Super+E` 文件管理 · `Super+C`/`Super+X` 编辑器 · `Super+F1` 输入法开关

**B. 窗口** — `Super+Q` 关窗 · `Super+D` 最大化 · `Super+Alt+Space` 浮动 · `Super+P` Pin ·
`Super+Shift+方向` 移动窗口 · `Super+;`/`'` 分屏比例 · `Super+;` 

**C. 工作区** — `Super+1..0` 切换 · `Super+Alt+1..0` 静默移窗 · `Super+Shift+1..0` 移动并跟随 ·
`Super+U` 上一个 · `Super+Ctrl+U/I` 移窗到相邻 · `Super+S` Scratchpad ·
**`Super+滚轮` 按显示器连续切换（空工作区也算一站，不绕回）** ·
`Super+Tab` 下一工作区 · `Super+L` 锁屏 · `Super+Shift+L` 睡眠 · `Ctrl+Alt+Del` 系统菜单

**D. 剪贴板 / 截图** — `Super+V` 剪贴板历史 · `Super+.` 表情 · `Super+Shift+C` 取色 ·
`Super+Shift+S` 区域截图 · `Super+Shift+X` OCR · `Super+Shift+R` 录屏 ·
`Print`/`Shift+Print`/`Ctrl+Print`/`Super+F12` 截图

**E. 媒体** — `Super+Shift+N/B/P/M` 下一首 / 上一首 / 播放暂停 / 静音 · `Super+Alt+M` 麦静音

**F. 缩放 / 壁纸** — `Super+-/=` 光标缩放 · `Super+F10` 下一张壁纸 ·
`Super+Shift+F10` 下载随机壁纸 · `Ctrl+Super+T` / `Ctrl+Alt+T` 壁纸选择 · `Super+Alt+T` 取色策略

**G. 速查** — `Super`（轻触）/ `Super+Space` Omarchy 菜单 · `Super+K` Keybindings · `Super+/` 速查表

**H. 被挤掉的 Omarchy 默认**（关窗 `Super+W`→`Super+Q`、Universal copy/paste/cut、Apps menu、
Pseudo、layout toggle、关全部窗口、编组数字键 1–5、idle toggle、窗口扩缩 ±、monitor scale up、
Maps/Calendar/X/Photos/Spotify 网页绑、Editor on `Super+Shift+N`→`Super+C`）

### Super+滚轮为什么改了

Omarchy 默认 `e+1` / `e-1`，`e` 是 **open workspace**：只在已经有窗口的工作区之间跳，
空工作区被跳过，滚到最后一个就绕回第一个（方向反着跳）。改成 `r+1` / `r-1`
（`r` = 本显示器上的相对工作区，**包含空的**）：往前滚就一直往前，空工作区也能滚进去，
到底不回绕。同时 `binds.allow_workspace_cycles = false` 兜住不绕回。

## 中文化

检索过 Omarchy 社区（omacom marketplace registry、awesome-omarchy、GitHub 全量搜索），
**没有**给 Omarchy shell 界面做汉化的插件——Omarchy 的 QML 里没有 i18n / qsTr 体系，
要汉化只能自己改 `/usr/share/omarchy/shell` 的源码，属于硬改上游。

现成的相关项目（都是工具，不是界面汉化）：

- `ryuhzk/omarchy-translation` — 划词/文本翻译
- `b7s/omarchy-googletranslate` — Google 翻译接入
- `jfdnet/omarchy-cn-indicator` — 输入法 / 中文状态指示器

## 已知限制

- Qt / Kvantum 那条模板需要 `~/.local/state/quickshell/.venv`，缺 venv 时跳过，不影响 GTK / Hyprland / 终端。
- 壁纸目录假定 `~/Pictures/Wallpapers`（`hooks/*/wallpapers-dir` 把它硬链进 Omarchy 的用户壁纸目录）。
- `binds.scroll_event_delay = 0`：滚轮无节流，触控板一滑可能连跳好几个工作区；想稳一点就调回 300。
