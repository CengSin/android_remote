# Redmi Note 5 远程使用

## 仓库内容

本仓库包含操作说明、Mac 启动脚本 `bin/adb`、`bin/scrcpy` 和 Windows 启动脚本 `windows-start.cmd`。下载的第三方工具包（`.tools/`）以及本机运行日志和截图（`logs/`）不纳入版本管理。

在新的 Intel Mac 上克隆仓库后，需先从下文“下载来源与验证”中的官方来源下载工具：将 Platform-Tools 解压到 `.tools/platform-tools/`，将 scrcpy 5.0.1 Intel Mac 包解压到 `.tools/scrcpy-macos-x86_64-v5.0.1/`，然后使用 `bin/` 下的脚本。Windows 部署参照下文对应步骤。

## 当前结果（2026-10-25，上海时间）

- 已通过 USB ADB 确认：Redmi Note 5（whyred），Android 9 / API 28，MIUI `V12.0.3.0.PEICNXM`，安全补丁日期 `2020-11-05`。
- 手机 Wi-Fi 地址仍为 `192.168.124.17/24`，屏幕原始分辨率为 `1080×2160`。
- 本机：Intel Mac；首次检查时 Wi-Fi 地址为 `192.168.124.14/24`。
- 已在本项目安装 Google 官方 ADB（Platform-Tools 37.0.1）及 scrcpy 5.0.1；两个程序的版本命令运行成功。
- USB 调试已经授权，设备状态为 `device`，USB 功能为 `mtp,adb`。
- USB scrcpy 投屏成功；本机使用 Metal / VideoToolbox，解码画面为 `640×1280`。ADB 模拟 Home 键成功返回桌面，模拟触摸点击成功打开系统设置。
- 临时通过 USB 启用无线 ADB 后，`adb connect 192.168.124.17:5555` 成功；通过该网络连接读取型号和 Android 版本成功，5 秒无线 scrcpy 投屏也成功解码为 `640×1280`。
- 无线测试结束后已经切回 USB：`service.adb.tcp.port` 为 `0`，实测 `192.168.124.17:5555` 再次拒绝连接；USB 已重新连接。
- 已重新启动标题为 `Redmi Note 5 · USB` 的投屏窗口，供用户直接操作。
- 公司可留一台常开的 Windows 电脑。公司 Windows 上的授权、部署、异地访问及手机/电脑重启恢复尚未测试。

## 推荐连接方式

`外面的 Mac → 远程桌面 → 公司 Windows → USB → Redmi`

在公司 Windows 上运行 scrcpy，通过 USB 看手机画面并使用鼠标、键盘。手机不需要承担远控 App 的后台保活。Mac 上的投屏与 ADB 输入已通过实测；公司 Windows 仍需单独完成首次授权和恢复测试。

| Windows 情况 | 从外面连接的方法 |
| --- | --- |
| 专业版、企业版、教育版等支持 RDP 服务端的版本 | Mac 和 Windows 安装 Tailscale，加入同一网络；Mac 用 Windows App 连接 Windows 的 Tailscale 地址 |
| 家庭版，或希望直接操作原有桌面 | 在 Windows 配置 RustDesk 等远程桌面工具的无人值守访问，再从 Mac 连接 |

RDP 方案无需把远程桌面端口映射到公网；USB 方案也无需开放手机的 5555 端口。Tailscale 的连通性和延迟需用公司网络实测。RustDesk 这里建议装在 Windows 电脑上。

## 先完成手机首次授权

1. 在手机“设置 → 我的设备 → 全部参数”连续点击 MIUI 版本，开启开发者模式。
2. 在“设置 → 更多设置 → 开发者选项”开启“USB 调试”。用可传数据的 USB 线连接电脑，解锁手机，接受调试授权。自己的常用电脑可勾选“始终允许”。
3. 如果 scrcpy 能看画面却不能点击，按 scrcpy 官方说明检查另一个开关“USB 调试（安全设置）”；部分小米设备开启后需要重启。先完成必要操作，再测试控制。
4. 换到公司 Windows 时需要单独允许那台电脑的调试密钥；在 Mac 上授权不会自动授权 Windows。

Mac 上的程序只安装在本项目内，未修改终端配置。在此目录执行：

```sh
./bin/adb devices -l
./bin/scrcpy --select-usb --no-audio --max-size=1280 --max-fps=30 --video-bit-rate=4M
```

设备状态必须是 `device`；如果是 `unauthorized`，先在手机上确认授权。

如果只想临时在同一个 Wi-Fi 下测试无线连接，先保持 USB 连接且完成授权，再执行：

```sh
./bin/adb -d tcpip 5555
./bin/adb connect 192.168.124.17:5555
./bin/scrcpy --serial=192.168.124.17:5555 --no-audio --max-size=1280 --max-fps=30
```

启用成功后才可以拔线。测试完且无线连接仍可用时，执行 `./bin/adb -s 192.168.124.17:5555 usb` 切回 USB 调试。不要把 5555 端口映射到公网。这一旧式无线模式在重启后可能需要再次通过 USB 启用，不适合作为本次长期方案的基础。Android 10 及以下的官方无线 ADB 流程需要先连接 USB。

## 公司 Windows 的部署步骤

1. 从 [scrcpy 官方 Windows 页面](https://github.com/Genymobile/scrcpy/blob/master/doc/windows.md) 下载对应架构的完整压缩包并解压，保留其中的 ADB、DLL 和 `scrcpy-server`。也可用官方文档列出的 `winget install --exact Genymobile.scrcpy` 安装。
2. 手机通过 USB 接入，完成上述调试授权。若设备列表为空，检查数据线和 Windows 设备管理器中的 ADB 驱动。
3. 如果使用解压版，把本项目的 `windows-start.cmd` 复制到含 `scrcpy.exe` 和 `adb.exe` 的目录，双击运行。脚本只选择 USB 设备，以最长边 1280 像素、最多 30 fps、4 Mbps 为初始视频参数；旧版 Android 可能忽略帧率限制。为兼容旧 Android 关闭声音转发。
4. 先在本地确认点击、滑动、输入和唤醒。需要手机熄屏而电脑继续显示时，可手动给启动命令增加 `--turn-screen-off --stay-awake`，再验证唤醒和重连。
5. 根据 Windows 版本配置上表中的远程桌面。Tailscale + RDP 可参照[官方教程](https://tailscale.com/docs/solutions/access-remote-desktops-using-windows-rdp)。若要求电脑重启后也能连接，启用 Tailscale 的 `Run Unattended`。远程桌面可连接后，再在该会话里手动启动 scrcpy。
6. 将 Windows 接通电源时的自动睡眠关闭；保持手机稳定供电。scrcpy 自启动应放在有桌面的用户会话中，RDP 会话里也可以直接手动启动。无需为此开启 Windows 自动登录。
7. 使用另一张网络（例如手机热点）测试异地连接，再分别测试 USB 拔插、手机锁屏、手机重启及 Windows 重启。不要在这些步骤验证前认定已经可以长期无人值守。手机重启后的首次解锁可能仍需要现场操作，需用这部手机实测。

暂不优先推荐仅在手机上安装 RustDesk/AnyDesk：Android 的录屏授权、MIUI 后台限制及重启恢复会影响无人值守；RustDesk 官方文档也提示启动时需处理屏幕采集和输入控制权限。

## 下载来源与验证

- ADB：[Google Platform-Tools](https://developer.android.com/tools/releases/platform-tools)，下载地址 `https://dl.google.com/android/repository/platform-tools-latest-darwin.zip`。本次下载文件 SHA-256 为 `ee39ad5967e95c2a07f04dbcbde96b1a0c916ba376096db5d2f498b7727a5d1d`，这是本地记录值。
- scrcpy：[官方 macOS 安装文档](https://github.com/Genymobile/scrcpy/blob/master/doc/macos.md)。本次 Intel Mac 包的 SHA-256 为 `31a5467a9e907f162b093267cbbab1276b15c6e709c2ea8159566a8d165beb50`，已与官方文档公布值比对一致。
- [Android 官方 ADB 连接说明](https://developer.android.com/tools/adb)。
- [scrcpy 官方兼容性及小米控制权限说明](https://github.com/Genymobile/scrcpy)。
- [RustDesk Android 权限说明](https://rustdesk.com/docs/en/client/android/)。

已验证范围：本机 USB ADB、系统信息读取、USB 投屏、ADB 按键及触摸输入、同一 Wi-Fi 下的 ADB 与投屏，以及恢复 USB 后关闭默认无线 ADB 端口。未验证范围：scrcpy 窗口内人工鼠标/键盘操作体验、锁屏/熄屏恢复、手机或电脑重启恢复、Windows 部署和异地访问。
