scoop 是从 github 下载安装包，所以建议设置好代理

参考：

- [文档](https://github.com/lukesampson/scoop)
- [你需要掌握的 Scoop 技巧和知识](https://zhuanlan.zhihu.com/p/135278662)
- [📝Scoop 初体验](https://github.com/Linnzh/Blog/issues/42#issuecomment-568158956)

bucket 可以理解为软件源

## 安装 scoop

（因为我只用一个用户，所以就这样吧，如果想要全局安装，见文档）

```powershell
# 设置安装目录为 E:\Scoop
$env:SCOOP='E:\Scoop'
[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')
$env:SCOOP_GLOBAL='E:\Scoop'
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')

# 安装 scoop，E:\Scoop\shims 会被添加到 Path
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
iwr -useb get.scoop.sh | iex
# 查看帮助
scoop help
# 配置代理（这一步很重要，注意是 http 代理！）（所以就需要弄好代理了哦！）
scoop config proxy 127.0.0.1:7891

# 安装 aria2（默认会启用，若要禁用，scoop config aria2-enabled false）
scoop install aria2
# scoop 运行必备
scoop install 7zip innounp dark grep lessmsi sudo git openssh touch
# git 设置代理（如果现在还没代理就别弄这步了）
git config --global http.proxy 'socks5://127.0.0.1:7890'
git config --global https.proxy 'socks5://127.0.0.1:7890'

# 使 scoop 安装文件夹可通过防火墙
sudo Add-MpPreference -ExclusionPath 'E:\Scoop'
# 启用长路径
sudo Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1
# 检查潜在的问题
scoop checkup # 如果有，则按照提示解决问题
```

## 添加软件源

如果没`scoop config proxy 127.0.0.1:7891`就会很慢很慢

```powershell
scoop bucket add extras
scoop bucket add versions
scoop bucket add nightlies
scoop bucket add nirsoft
scoop bucket add php
scoop bucket add nerd-fonts
scoop bucket add nonportable
scoop bucket add java
scoop bucket add games
scoop bucket add jetbrains

scoop update # 更新源列表以及 scoop 自身
```

## 安装一些软件

```powershell
# scoop install googlechrome-dev firefox-developer vscode geekuninstaller fluent-terminal-np snipaste windows-terminal potplayer sublime-text vagrant
# scoop install php-nts mysql redis nodejs-lts nginx apache composer curl python go gcc
scoop install geekuninstaller telegram v2ray qv2ray rufus spacesniffer
# 最好不要用 scoop 安装那些需要关联文件还有上下文菜单的软件，比如 vscode，bandizip，potplayer
scoop install nodejs-lts gcc llvm cmake mdbook oraclejdk python
sudo scoop install FiraCode-NF FiraMono-NF
```

qv2ray 就是一个先有鸡还是先有蛋的问题了（我选择在安装 scoop 之前弄好 qv2ray，然后用 scoop 安装 qv2ray，再用 geekuninstaller 卸载原先的 qv2ray

显示过的提示：

```
'qv2ray' suggests installing 'extras/vcredist2019'.

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
scoop install vcredist2019
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

## 安装 Visual Studio

## 安装 Rust

以管理员身份运行：

```powershell
[environment]::setEnvironmentVariable('RUSTUP_HOME', 'E:\Rust\rustup', 'Machine')
[environment]::setEnvironmentVariable('CARGO_HOME', 'E:\Rust\cargo', 'Machine')
[environment]::setEnvironmentVariable('RUSTUP_DIST_SERVER', 'https://mirrors.sjtug.sjtu.edu.cn/rust-static', 'Machine')
[environment]::setEnvironmentVariable('RUSTUP_UPDATE_ROOT', 'https://mirrors.sjtug.sjtu.edu.cn/rust-static/rustup', 'Machine')
```

然后打开`rustup-init.exe`，安装完后确保`E:\Rust\cargo\bin`在 Path 中（应该会自动弄好）
rustup toolchain install nightly

## 记录

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
