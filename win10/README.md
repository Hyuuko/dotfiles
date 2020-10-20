参考：

- [Documentation](https://github.com/lukesampson/scoop/wiki)
- [你需要掌握的 Scoop 技巧和知识](https://zhuanlan.zhihu.com/p/135278662)

## Qv2ray

scoop 的许多安装包都是从 github 等网站下载的，所以建议设置好代理

下载 [Qv2ray.版本号.Windows-x64.7z](https://github.com/Qv2ray/Qv2ray/releases/latest) 和 [v2ray-windows-64.zip](https://github.com/v2fly/v2ray-core/releases/latest)（如果访问有点慢，试试把 `github.com` 改成 `hub.fastgit.org`），然后解压打开，使用方法见 [Qv2ray 文档](https://qv2ray.net/)。

## 安装 scoop

```powershell
# 设置安装目录为 E:\Scoop
$env:SCOOP='E:\Scoop'
[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')
# 设置全局软件安装目录也为 E:\Scoop
$env:SCOOP_GLOBAL='E:\Scoop'
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')

# 允许PowerShell执行本地脚本。提示是否更改执行策略时，输入 Y，然后回车确认
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
# 安装 scoop，安装完后 E:\Scoop\shims 会被添加到 Path
iwr -useb get.scoop.sh | iex
# 查看帮助
scoop help
# 配置代理（这一步很重要，注意是 http 代理！）（请提前弄好代理！）
scoop config proxy 127.0.0.1:8889

# 安装 aria2（默认会启用，若要禁用，scoop config aria2-enabled false）
scoop install aria2
# scoop 运行必备
scoop install 7zip innounp dark grep lessmsi sudo git openssh touch
# git 设置代理（如果现在没弄代理就别弄这步了）
git config --global http.proxy 'socks5://127.0.0.1:1089'
git config --global https.proxy 'socks5://127.0.0.1:1089'

# 使 scoop 安装文件夹可通过防火墙
sudo Add-MpPreference -ExclusionPath 'E:\Scoop'
# 启用长路径
sudo Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1
# 检查潜在的问题
scoop checkup # 如果有，则按照提示解决问题
```

## 添加 bucket

bucket 可以理解为软件仓库，视需求添加

```powershell
scoop bucket add extras
scoop bucket add versions
scoop bucket add nonportable
# scoop bucket add nightlies
# scoop bucket add nirsoft
scoop bucket add php
scoop bucket add nerd-fonts
scoop bucket add java
# scoop bucket add games
scoop bucket add jetbrains

scoop update # 更新源列表以及 scoop 自身
```

## 安装一些软件

最好不要用 scoop 安装那些需要关联文件还有上下文菜单的软件，比如 vscode，potplayer, bandizip

```powershell
# 安装 v2ray 和 qv2ray，安装完之后，之前用的可以删掉了
scoop install v2ray qv2ray

# 常用软件
scoop install geekuninstaller telegram rufus spacesniffer winrar sumatrapdf
# scoop install googlechrome-dev firefox-developer fluent-terminal-np snipaste windows-terminal sublime-text vagrant

# 开发工具
# scoop install nodejs-lts gcc llvm cmake mdbook oraclejdk python ninja
# scoop install php-nts mysql redis nginx apache composer curl go

# 安装 FiraCode 字体
sudo scoop install FiraCode-NF FiraMono-NF

# wireshark
# scoop install wireshark
# sudo scoop install nmap
```

打开 winrar，别关联文件，但是勾选`Integrate WinRAR into shell`和`Icons in context menus`。

安装软件时的一些输出：

```
  WARNING: The scripts easy_install-3.8.exe and easy_install.exe are installed in 'E:\Scoop\apps\python\3.8.5\Scripts' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
  WARNING: The scripts pip.exe, pip3.8.exe and pip3.exe are installed in 'E:\Scoop\apps\python\3.8.5\Scripts' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
Linking E:\Scoop\apps\python\current => E:\Scoop\apps\python\3.8.5
Creating shim for 'python'.
Creating shim for 'pythonw'.
Creating shim for 'python3'.
Creating shim for 'idle'.
Creating shim for 'idle3'.
'python' (3.8.5) was installed successfully!
Notes
-----
Allow applications and third-party installers to find python by running:
"E:\Scoop\apps\python\current\install-pep-514.reg"
```

所以最好就：

```powershell
E:\Scoop\apps\python\current\install-pep-514.reg
```

## 常用命令

```powershell
Usage: scoop <command> [<args>]

Some useful commands are:

alias       # 管理别名
bucket      # Manage Scoop buckets
cache       # Show or clear the download cache
checkup     # 检查潜在的问题
cleanup     # Cleanup apps by removing old versions
config      # Get or set configuration values
create      # Create a custom app manifest
depends     # 列出一个软件的依赖
export      # Exports (an importable) list of installed apps
help        # 显示一个命令的帮助
hold        # 保持一个软件禁止更新
home        # 打开软件的主页
info        # 显示一个软件的相关信息
install     # 安装软件
list        # 列出安装了的软件
prefix      # Returns the path to the specified app
reset       # Reset an app to resolve conflicts
search      # 搜索软件
status      # 显示状态并且检查更新
unhold      # Unhold an app to enable updates
uninstall   # Uninstall an app
update      # 更新软件
virustotal  # Look for app's hash on virustotal.com
which       # Locate a shim/executable (similar to 'which' on Linux)

Type 'scoop help <command>' to get help for a specific command.
```

## 安装 Rust

以管理员身份运行：

```powershell
[environment]::setEnvironmentVariable('RUSTUP_HOME', 'E:\Rust\rustup', 'Machine')
[environment]::setEnvironmentVariable('CARGO_HOME', 'E:\Rust\cargo', 'Machine')
[environment]::setEnvironmentVariable('RUSTUP_DIST_SERVER', 'https://mirrors.sjtug.sjtu.edu.cn/rust-static', 'Machine')
[environment]::setEnvironmentVariable('RUSTUP_UPDATE_ROOT', 'https://mirrors.sjtug.sjtu.edu.cn/rust-static/rustup', 'Machine')
```

然后打开`rustup-init.exe`，安装完后确保`E:\Rust\cargo\bin`在 Path 中（应该会自动弄好）

## Chocolatey

以管理员身份打开 powershell

```powershell
# 设置安装目录为 E:\Chocolatey
$env:ChocolateyInstall='E:\Chocolatey'
[Environment]::SetEnvironmentVariable('ChocolateyInstall', $env:ChocolateyInstall, 'Machine')
# 安装 Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

卸载 Chocolatey 需要删除相关的环境变量，并且在 Path 里去除，并且删除 Chocolatey 文件夹

```powershell
# 查看安装的软件列表
choco list -l
choco list -li
```

可以在这里查找包：https://chocolatey.org/packages，或者 `choco search`
