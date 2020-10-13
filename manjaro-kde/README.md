目录

- [Manjaro-kde](#manjaro-kde)
  - [安装前的准备](#安装前的准备)
  - [安装](#安装)
  - [创建交换文件](#创建交换文件)
  - [用户组](#用户组)
  - [设置时区，同步时间](#设置时区同步时间)
  - [换源](#换源)
  - [有很大一部分与 ArchLinux 的教程重复](#有很大一部分与-archlinux-的教程重复)
  - [鼠标宏](#鼠标宏)
  - [r8152 网卡 Tx timeout 错误导致断网](#r8152-网卡-tx-timeout-错误导致断网)
  - [aria2](#aria2)
  - [修复 grub](#修复-grub)
    - [grub 没有完全坏掉可以进入 grub rescue 救援模式](#grub-没有完全坏掉可以进入-grub-rescue-救援模式)
  - [开发环境配置](#开发环境配置)
    - [NeoVim](#neovim)
    - [VMware](#vmware)
    - [.NET](#net)

# Manjaro-kde

## 安装前的准备

假设你正在使用 Windows

1. 在[华为云的 Manjaro 镜像](https://repo.huaweicloud.com/manjaro-cd/kde/)下载最新的镜像文件 `manjaro-kde-版本号-日期-linux内核版本.iso`，文件 `manjaro-kde-版本号-日期-linux内核版本-pkgs.txt` 是预装软件列表
2. 准备一个 U 盘（容量比 manjaro-kde 镜像文件大就行，如果没 U 盘，可以试试在手机上用 DriveDroid 模拟 U 盘）
3. 在 Windows 上安装[Rufus](https://rufus.ie/zh_CN.html)，然后使用 Rufus 将第一步下载好的 manjaro-kde 镜像刻录至 U 盘，分区类型选择 GPT（如果无法选择就算了），目标系统类型选择 UEFI，其他的设置默认即可。[如何使用 rufus 制作系统启动盘 - 百度经验](https://jingyan.baidu.com/article/0a52e3f48ad2b8bf62ed7236.html)
4. 使用 Windows 自带的磁盘管理工具分出一块**未分配**的区域供我们要安装的 Manjaro 使用（尽量大些 100G 以上）
5. **禁用 Windows 的快速启动**：控制面板->硬件和声音->电源选项，点击`更改当前不可用的设置`，然后取消勾选`启用快速启动`，保存修改。

## 安装

1. U 盘插在电脑上，在键盘亮起/屏幕微亮/快要显示出品牌图标时，（如果你之前没有关闭过 secure boot，请按 F2 进入 BIOS 设置界面，将 secure boot 禁用再来进行这一步）按 F12（有些电脑是 F10，建议自己查一下）进入启动顺序选择界面，然后选择你的 U 盘设备，回车。
2. 然后开始选择时区、语言等，如果有 Invidia 显卡，那么 driver 请选择 no free
3. 然后开始 boot，进入 Live 安装环境，此处建议在右下角断开网络连接，然后设置时区语言等等..
4. 手动分区，以下是我的分区（_swap 分区现在可以先不设置_）：

   |  大小/M  | 文件系统 |  挂载点   | 标记 |      用途      |
   | :------: | :------: | :-------: | :--: | :------------: |
   |   512    |  fat32   | /boot/efi | boot |  EFI 系统引导  |
   |  61440   |   ext4   |     /     | root |  Linux 根目录  |
   | 剩下所有 |   ext4   |   /home   |  无  | Linux 用户目录 |

5. 设置用户名、主机名后，勾选不询问密码自动登录和为管理员帐号使用相同的密码
6. 安装完成后，重启，打开 Yakuake 终端开始下面的配置，为了避免麻烦，建议直接`su`进入 root 用户，并且用 Firefox 浏览器打开此教程。

## 创建交换文件

- [交换文件 - ArchWiki](<https://wiki.archlinux.org/index.php/Swap_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#%E4%BA%A4%E6%8D%A2%E6%96%87%E4%BB%B6>)

```bash
# 创建一个 8G 大小的文件，大约需要 1 分钟。注意最好别用 fallocate 命令
dd if=/dev/zero of=/swapfile bs=1G count=8
# 为交换文件设置权限
chmod 600 /swapfile
# 将其格式化
mkswap /swapfile
# 启用交换文件
swapon /swapfile
# 编辑 /etc/fstab，注意是 >> 不是 >
echo '/swapfile none swap defaults 0 0' >> /etc/fstab
# 检查交换空间的状态
free -m
```

## 用户组

```bash
# 将 user_name 添加到 wheel 用户组中
# user_name 请换成你自己的用户名
usermod -aG wheel user_name
```

## 设置时区，同步时间

- [同步 Linux 双系统的时间](https://mogeko.me/2019/062/)

`nano /etc/systemd/timesyncd.conf`，取消 `#NTP=` 的注释。然后填上 NTP 服务器的地址

```
NTP=time1.aliyun.com time2.aliyun.com time3.aliyun.com time4.aliyun.com time5.aliyun.com
```

```bash
su
timedatectl list-timezones              # 列出所有时区
timedatectl set-timezone Asia/Shanghai  # 设置时区
timedatectl set-ntp true                # 启用 NTP
timedatectl status  # 查看状态，如果 RTC 与 CST 相同就说明设置成功了
date                                    # 查看时间
```

## 换源

```bash
# 换源，如果有的话，建议用自己学校的
# echo 'Server = http://mirrors.cqu.edu.cn/manjaro/stable/$repo/$arch' > /etc/pacman.d/mirrorlist
echo 'Server = https://repo.huaweicloud.com/manjaro/stable/$repo/$arch' > /etc/pacman.d/mirrorlist
echo 'Server = https://mirrors.cloud.tencent.com/manjaro/stable/$repo/$arch' >> /etc/pacman.d/mirrorlist
# 添加写保护，防止被修改
chattr +i /etc/pacman.d/mirrorlist
```

然后添加 archlinuxcn 源，`nano /etc/pacman.conf`，取消`#Color`的注释以启用彩色输出，然后在文件末尾加上：

```conf
[archlinuxcn]
# 建议用自己学校的
# Server = https://mirrors.cqu.edu.cn/archlinuxcn/$arch
Server = https://mirrors.aliyun.com/archlinuxcn/$arch
Server = https://mirrors.cloud.tencent.com/archlinuxcn/$arch
```

```bash
pacman -Syy archlinuxcn-keyring     # 安装 keyring
pacman -Syu                         # 系统更新
```

## 有很大一部分与 ArchLinux 的教程重复

去看看[ArchLinux 安装及配置](../archlinux/README.md)中的`安装后的工作`之后的部分吧

## 鼠标宏

```bash
sudo pacman -S piper
```

然后将前进和后退按钮映射为`Alt + right`和`Alt + left`（chrome 的前进后退快捷键就是这个）

设置 vscode 的快捷键：

```json
[
  {
    "key": "alt+left",
    "command": "workbench.action.navigateBack"
  },
  {
    "key": "ctrl+alt+-",
    "command": "-workbench.action.navigateBack"
  },
  {
    "key": "alt+right",
    "command": "workbench.action.navigateForward"
  },
  {
    "key": "ctrl+shift+-",
    "command": "-workbench.action.navigateForward"
  }
]
```

并且给 vscode 添加设置以禁用中键的复制行为，这样就可以使用中键选择多行了：

```json
"editor.selectionClipboard": false
```

## r8152 网卡 Tx timeout 错误导致断网

https://aur.archlinux.org/packages/r8152-dkms/

```bash
# 先查看内核版本
uname -a
# 安装对应的 headers，我的内核版本为 5.8，故安装 linux58-headers
pacman -S --needed linux58-headers
yay -S r8152-dkms
```

这下应该没问题了

## aria2

```bash
sudo pacman -S aria2-fast uget
mkdir ~/aria2
touch ~/aria2/aria2.conf ~/aria2/aria2.session ~/aria2/aria2.log
```

[`aria2.conf`配置文件](https://gitee.com/BlauVogel/dotfiles/blob/master/manjaro-kde/aria2.conf)

`sudo vim /etc/systemd/system/aria2c.service`

```conf
[Unit]
Description=Aria2c download manager
After=network.target

[Service]
User=hyuuko
Type=forking
ExecStart=/usr/bin/aria2c --conf-path=/home/hyuuko/aria2/aria2.conf -D

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable aria2c
sudo systemctl start aria2c
```

安装插件[Aria2 for Chrome](https://chrome.google.com/webstore/detail/aria2-for-chrome/mpkodccbngfoacfalldjimigbofkhgjn)，在 AriaNg 设置里设置语言，再填好 RPC 密钥。注意：在 AriaNg 里对 Aria2 的设置是临时的，重新启动 aria2c 后这些配置就会恢复为配置文件里的

别人的配置：https://github.com/P3TERX/aria2.conf

## 修复 grub

有几种可能造成启动时无法引导 Manjaro

1. win10 更新后 grub 被破坏
2. 使用傲梅分区助手移动分区时，grub 被破坏（暂时未找到解决办法）
3. 等等

### grub 没有完全坏掉可以进入 grub rescue 救援模式

参考：https://blog.csdn.net/aaazz47/article/details/78549409

先查找 Linux 系统引导所在

```bash
grub rescue> ls
(hd0) (hd0,gpt8) (hd0,gpt7) (hd0,gpt6) ...
grub rescue> ls (hd0,gpt8)/
./ ../ lost+found/ bin/ boot/ dev/ etc/ ...
```

说明根目录在`(hd0,gpt8)`

```bash
grub rescue> set prefix=(hd0,gpt8)/boot/grub
grub rescue> set root=(hd0,gtp8)
# 启动 normal 模块
grub rescue> insmod normal
grub rescue> normal
# 接着就会进入启动选择菜单
```

```bash
# 查看 /boot/efi 是在那个设备上
df
# 如果在 /dev/sda2
sudo grub-install /dev/sda2
```

## 开发环境配置

### NeoVim

https://github.com/Gabirel/Hack-SpaceVim/blob/master/README_zh_CN.adoc

- [Martins3/My-Linux-config - GitHub](https://github.com/Martins3/My-Linux-config)
- [Vim 速查表](https://github.com/skywind3000/awesome-cheatsheets/blob/master/editors/vim.txt)

先确保安装好了 npm 和 yarn，并且换源了

```bash
pc zsh
# 安装 SpaceVim
curl -sLf https://spacevim.org/cn/install.sh | bash
# 打开 nvim，选择 dark powered mode
nvim
# 退出，再打开 nvim 就会自动安装插件
nvim
```

然后编辑`~/.SpaceVim.d/init.toml`
并且

```bash
mkdir ~/.SpaceVim.d/autoload
touch ~/.SpaceVim.d/autoload/myspacevim.vim
```

### VMware

```bash
pacman -S --needed vmware-workstation
uname -r                              # 查看一下自己的内核
pacman -S --needed linux56-headers    # 如果是 5.6 就这样
sudo modprobe -a vmw_vmci vmmon                  # 加载 vmw_vmci 和 vmmon 内核模块
sudo systemctl enable --now vmware-networks      # 启用虚拟机网络
sudo systemctl enable --now vmware-usbarbitrator # 启用 vmware 的 usb 设备连接
```

### .NET

[.NET Core - ArchWiki](<https://wiki.archlinux.org/index.php/.NET_Core_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)

```bash
sudo pacman -S --needed dotnet-sdk aspnet-targeting-pack
# 关闭遥测
echo 'export DOTNET_CLI_TELEMETRY_OPTOUT=1' >> ~/.zshrc
```

VSCode 插件：

- `C#`

参考：

- [Using .NET Core in Visual Studio Code](https://code.visualstudio.com/docs/languages/dotnet)
- [使用 Visual Studio Code 开发.NET Core 看这篇就够了](https://www.cnblogs.com/yilezhu/p/9926078.html)
