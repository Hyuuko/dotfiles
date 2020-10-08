目录

- [部分参考资料](#部分参考资料)
  - [ArchWiki](#archwiki)
  - [博客、知乎等](#博客知乎等)
- [安装前的准备](#安装前的准备)
  - [启动到 Live 环境](#启动到-live-环境)
  - [验证启动模式](#验证启动模式)
  - [连接到因特网](#连接到因特网)
  - [更新系统时间](#更新系统时间)
  - [建立硬盘分区](#建立硬盘分区)
  - [格式化分区](#格式化分区)
  - [挂载分区](#挂载分区)
- [安装](#安装)
  - [更换镜像源](#更换镜像源)
  - [安装必须的软件包](#安装必须的软件包)
- [配置系统](#配置系统)
  - [Fstab](#fstab)
  - [Chroot](#chroot)
  - [时区](#时区)
  - [本地化](#本地化)
  - [网络配置](#网络配置)
  - [Initramfs](#initramfs)
  - [设置 Root 密码](#设置-root-密码)
  - [安装引导程序](#安装引导程序)
  - [重启进入安装好了的 Arch Linux](#重启进入安装好了的-arch-linux)
- [安装后的工作](#安装后的工作)
  - [联网并添加 archlinuxcn 源](#联网并添加-archlinuxcn-源)
  - [创建交换文件](#创建交换文件)
  - [新建用户](#新建用户)
  - [显卡驱动和图形界面](#显卡驱动和图形界面)
  - [字体和常用软件](#字体和常用软件)
  - [输入法和皮肤](#输入法和皮肤)
  - [代理软件](#代理软件)
  - [透明代理](#透明代理)
  - [git](#git)
  - [zsh](#zsh)
  - [美化](#美化)
    - [系统设置](#系统设置)
    - [面板](#面板)
- [其他](#其他)
  - [调整鼠标滚轮速度](#调整鼠标滚轮速度)
  - [校园网](#校园网)
- [遇到过的一些问题](#遇到过的一些问题)
  - [vscode 登录账号的问题](#vscode-登录账号的问题)
  - [r8152 网卡 Tx timeout 错误断网](#r8152-网卡-tx-timeout-错误断网)
- [Tips](#tips)
- [开发环境配置](#开发环境配置)
  - [Docker](#docker)
  - [Rust](#rust)
  - [C/C++](#cc)
  - [Node.js](#nodejs)
  - [VMware](#vmware)

## 部分参考资料

### ArchWiki

- [Installation guide (简体中文) - ArchWiki](<https://wiki.archlinux.org/index.php/Installation_guide_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)
- [General recommendations (简体中文) - ArchWiki](<https://wiki.archlinux.org/index.php/General_recommendations_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)
- [List of applications (简体中文) - ArchWiki](<https://wiki.archlinux.org/index.php/List_of_applications_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)

### 博客、知乎等

- [以官方 Wiki 的方式安装 ArchLinux](https://www.viseator.com/2017/05/17/arch_install/)
- [ArchLinux 安装后的必须配置与图形界面安装教程](https://www.viseator.com/2017/05/19/arch_setup/)
- [Arch Linux 简明实用教程](https://kagarinokiriestudio.github.io/ArchLinuxTutorial/#/)

## 安装前的准备

假设你正在使用 Windows

1. 从[华为云的 Arch Linux 镜像](https://mirrors.huaweicloud.com/archlinux/iso/latest/)下载 `archlinux-版本日期-x86_64.iso` 镜像文件到你的电脑上（其他的镜像站：[镜像站列表](https://www.archlinux.org/download/#download-mirrors)）
2. 准备一个 1G 大小以上 U 盘（容量比 archlinux 的镜像文件大就行，如果没 U 盘，可以试试在手机上用 DriveDroid 模拟 U 盘）
3. 在 Windows 上安装[Rufus](https://rufus.ie/zh_CN.html)，然后使用 Rufus 将第一步下载好的 archlinux 镜像刻录至 U 盘，分区类型选择 GPT，目标系统类型选择 UEFI，其他的设置默认即可
4. 使用 Windows 自带的磁盘管理工具分出一块**未分配**的区域供我们要安装的 ArchLinux 使用
5. **禁用 Windows 的快速启动**：控制面板->硬件和声音->电源选项，点击`更改当前不可用的设置`，然后取消勾选`启用快速启动`，保存修改。

### 启动到 Live 环境

1. U 盘插在电脑上，在键盘亮起/屏幕微亮/快要显示出品牌图标时，（如果你之前没有关闭过 secure boot，请按 F2 进入 BIOS 设置界面，将 secure boot 禁用再来进行这一步）按 F12（有些电脑是 F10，建议自己查一下）进入启动顺序选择界面，然后选择你的 USB。
2. 当 Arch 菜单出现时，选择 _Arch Linux install medium (x86_64, UEFI)_ 并按 Enter 进入安装环境。
3. 等几分钟后就会以 root 身份登录进一个显示`root@archiso ~ # `字样的虚拟控制台

### 验证启动模式

用下列命令列出 efivars 目录：

```bash
ls -d /sys/firmware/efi/efivars
```

如果显示 `/sys/firmware/efi/efivars`，则说明系统以 UEFI 模式启动。如果提示 `ls: cannot access '/sys/firmware/efi/efivars': No such file or directory`，则说明系统可能以 BIOS 或 CSM 模式启动，自己百度怎么改为 UEFI 吧

### 连接到因特网

- 如果是有线网络
  - 直接 `ping baidu.com` 来判断网络是否连接正常，Ctrl+C 退出该命令。
- 如果是无线网络
  - 执行以下命令（详见[iwctl - ArchWiki](<https://wiki.archlinux.org/index.php/Iwd_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#iwctl>)）
    ```bash
    # 进入交互式提示符环境
    iwctl
    # 接下来是在以 [iwd] 开头的提示符环境中进行的
    # 列出所有 WiFi 设备
    device list
    # 假设刚才的 Name 一列的网络设备名称为 wlan0，接下来扫描网络
    station wlan0 scan
    # 列出所有可用的网络
    station wlan0 get-networks
    # 假设想要连到 Network name 一列中，名称为 Xiaomi 的网络
    station wlan0 connect Xiaomi
    # 然后按照提示输入密码即可
    ```

### 更新系统时间

`vim /etc/systemd/timesyncd.conf`，取消 `#NTP=` 的注释。然后填上 NTP 服务器的地址

```conf
NTP=ntp.aliyun.com ntp1.aliyun.com ntp2.aliyun.com
```

```bash
# 启用 NTP 时间同步
timedatectl set-ntp true
# 查看 NTP 服务状态
timedatectl timesync-status
```

### 建立硬盘分区

每个硬盘都被会被分配为一个块设备，如 `/dev/sda`、`/dev/sdb`、`/dev/sdc`、`/dev/nvme0n1`。可以使用 fdisk 查看：

```bash
fdisk -l
```

如果想在硬盘 `/dev/sda` 上进行分区，则运行：

```bash
cfdisk /dev/sda
```

按上下键选择想要操作的分区，移动到绿色的空闲分区。然后按左右键选择所要进行的操作，选择 `[ New ]`，然后回车，输入想要分配的大小，然后再确认，再按左右键选择 `[ Type ]`，然后回车，来设置该分区的类型。

以我的分区（_swap 分区现在可以先不设置_）为例：

|  挂载点   | 假设的设备文件 |      分区类型       |        大小        |
| :-------: | :------------: | :-----------------: | :----------------: |
| /mnt/boot |   /dev/sda1    |     EFI System      |   500M（足够了）   |
|   /mnt    |   /dev/sda2    | Linux root (x86-64) |        60G         |
| /mnt/home |   /def/sda3    |     Linux home      | 60G （剩下所有的） |

也有人将`/mnt/boot`换成`/mnt/efi`或`/mnt/boot/efi`，其实这个随意，不过最好还是`/mnt/boot`。分完后，按左右键选择`[ Write ]`回车，再 yes，使修改生效，再按 q 退出 cfdisk 界面。

### 格式化分区

这里的 `/dev/sda1` 等等请换成你自己的

```bash
# 将 EFI System 分区格式化为 fat32
mkfs.vfat /dev/sda1
# 将 Linux root 分区格式化为 ext4
mkfs.ext4 /dev/sda2
# 将 Linux home 分区格式化为 ext4
mkfs.ext4 /dev/sda3
```

### 挂载分区

这里的 `/dev/sda1` 等等请换成你自己的

```bash
# 先挂载 Linux root 分区
mount /dev/sda2 /mnt
# 挂载 EFI System 分区
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
# 挂载 Linux home 分区
mkdir /mnt/home
mount /dev/sda3 /mnt/home
```

## 安装

### 更换镜像源

```bash
# 修改软件源
echo 'Server = https://mirrors.huaweicloud.com/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
# 更新源列表
pacman -Syy
```

其他镜像源请见通过 [Pacman Mirrorlist 生成器](https://www.archlinux.org/mirrorlist/)生成的[国内源列表](https://www.archlinux.org/mirrorlist/?country=CN&protocol=http&protocol=https&ip_version=4)，用自己学校的更快哦！

### 安装必须的软件包

使用 pacstrap 脚本，安装 base 软件包和 Linux 内核以及常规硬件的固件等等：

```bash
pacstrap /mnt --needed linux linux-firmware
pacstrap /mnt --needed base base-devel dhcpcd neovim dialog wpa_supplicant networkmanager netctl arch-install-scripts
```

这些务必安装，否则之后可能会有连不上网络等等麻烦

## 配置系统

### Fstab

用以下命令生成 fstab 文件 (用 `-U` 或 `-L` 选项设置 UUID 或卷标)：

```bash
genfstab -L /mnt >> /mnt/etc/fstab
# 检查一下生成的 /mnt/etc/fstab 文件是否正确
cat /mnt/etc/fstab
```

### Chroot

切换到我们新安装的系统，执行了这步以后，我们的操作都相当于在硬盘上新装的系统中进行

```bash
arch-chroot /mnt
```

### 时区

```bash
# 设置时区为上海
timedatectl set-timezone Asia/Shanghai
# 查看时间
date -R
# 将硬件时钟（RTC）调整为与目前的系统时钟一致
hwclock --systohc
```

### 本地化

```bash
# 先弄个软链接
ln -s /usr/bin/nvim /usr/bin/vim
ln -s /usr/bin/nvim /usr/bin/vi

# 编辑/etc/locale.gen，将 en_US.UTF-8 UTF-8 和 zh_CN.UTF-8 UTF-8 取消注释
vim /etc/locale.gen
# 生成 locale 信息
locale-gen
# 创建 locale.conf 文件，并编辑设定 LANG 变量，不建议弄成中文的，会导致 tty 乱码
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
```

### 网络配置

注意：这里的 myhostname 换成你自己想要设置的主机名

```bash
echo 'myhostname' > /etc/hostname
# 然后编辑 /etc/hosts
vim /etc/hosts
```

填入如下内容：

```
127.0.0.1  localhost
::1        localhost
127.0.1.1  myhostname.localdomain  myhostname
```

### Initramfs

- [mkinitcpio (简体中文) - ArchWiki](<https://wiki.archlinux.org/index.php/Mkinitcpio_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)

执行 `ls /boot` 命令

- 如果显示以下几个文件
  ```
  initramfs-linux-fallback.img  initramfs-linux.img  vmlinuz-linux
  ```
  则说明 initramfs 已经被自动创建了
- 如果没有 `initramfs-linux-fallback.img initramfs-linux.img` 这两个文件，那我们就需要手动创建 initramfs 了。`vim /etc/mkinitcpio.d/linux.preset`，填入如下内容：
  ```conf
  ALL_config="/etc/mkinitcpio.conf"
  ALL_kver="/boot/vmlinuz-linux"
  PRESETS=('default' 'fallback')
  default_image="/boot/initramfs-linux.img"
  fallback_image="/boot/initramfs-linux-fallback.img"
  fallback_options="-S autodetect"
  ```
  然后运行 `mkinitcpio -p linux` 以生成镜像，如果 `ls /boot` 还是没有 `initramfs-linux-fallback.img initramfs-linux.img` 这两个文件，请仔细检查 `/etc/mkinitcpio.d/linux.preset` 是不是写错了，再重新 `mkinitcpio -p linux`

### 设置 Root 密码

```bash
passwd
```

### 安装引导程序

- [安装引导程序 - ArchWiki](<https://wiki.archlinux.org/index.php/Installation_guide_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#%E5%AE%89%E8%A3%85%E5%BC%95%E5%AF%BC%E7%A8%8B%E5%BA%8F>)
- [GRUB (简体中文) - ArchWiki](<https://wiki.archlinux.org/index.php/GRUB_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)

处理器可能有[错误行为](https://www.anandtech.com/show/8376/intel-disables-tsx-instructions-erratum-found-in-haswell-haswelleep-broadwelly), 而内核可以通过更新启动时的 _Microcode_，即微码，来修正这些错误行为。参考[微码](<https://wiki.archlinux.org/index.php/Microcode_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)获取更多细节。启用微码：

- 如果是 AMD CPU，需先 `pacman -S amd-ucode`
- 如果是 Intel CPU，则 `pacman -S intel-ucode`

接下来安装引导程序

```bash
pacman -S --needed ntfs-3g os-prober grub efibootmgr
# 部署grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ArchLinux
# 生成配置文件
grub-mkconfig -o /boot/grub/grub.cfg
```

如果是双系统，输出中应该有 `Found Windows Boot Manager ...` 字样

### 重启进入安装好了的 Arch Linux

```bash
# 退出我们安装好了的系统，回到 U 盘里的 Live 环境
exit
# 重启
reboot
```

然后此时就可以拔掉 U 盘了，然后启动时按 F12（有些电脑是 F10）进入启动顺序选择界面，然后选择 ArchLinux（也可按 F2 进入 BIOS 设置界面，将 ArchLinux 调到第一位）

输入用户名 root，回车，再输入密码，即可完成登录！

## 安装后的工作

### 联网并添加 archlinuxcn 源

- [Arch Linux 中文社区](https://www.archlinuxcn.org/)
- [archlinuxcn 软件源列表](https://github.com/archlinuxcn/mirrorlist-repo)

无线网络，运行`wifi-menu`命令进行联网即可。

然后添加 archlinuxcn 源，`vim /etc/pacman.conf`，取消`#Color`的注释以启用彩色输出，然后在文件末尾加上：

```conf
[archlinuxcn]
Server = https://mirrors.aliyun.com/archlinuxcn/$arch
Server = https://mirrors.cloud.tencent.com/archlinuxcn/$arch
# Server = http://mirrors.cqu.edu.cn/archlinuxcn/$arch
```

```bash
# 给一些文件添加写保护，防止文件被程序修改
chattr +i /etc/pacman.d/mirrorlist
chattr +i /etc/pacman.conf
# 设置 DNS
echo 'nameserver 223.5.5.5' > /etc/resolv.conf
chattr +i /etc/resolv.conf
# 如果之后想修改这些文件，可以 chattr -i ... 以去除写保护
# 重启网络服务
systemctl restart systemd-networkd

pacman -Syy archlinuxcn-keyring     # 安装 keyring
pacman -Syu                         # 系统更新
```

### 创建交换文件

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

### 新建用户

注意：username 请换成你自己的用户名

```bash
# 新建用户，并配置用户home目录，加入 wheel 组
useradd -m -G wheel username
# 设置密码
passwd username
```

运行命令 `visudo` 修改 `/etc/sudoers`，将以下两行行首的`# `去掉

```bash
# %wheel ALL=(ALL) ALL
# %wheel ALL=(ALL) NOPASSWD: ALL
```

### 显卡驱动和图形界面

- [Xorg (简体中文) - ArchWiki](<https://wiki.archlinux.org/index.php/Xorg_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)
- [NVIDIA (简体中文) - ArchWiki](<https://wiki.archlinux.org/index.php/NVIDIA_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#%E5%AE%89%E8%A3%85>)
- [Display manager (简体中文) - ArchWiki](<https://wiki.archlinux.org/index.php/Display_manager_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#%E5%9B%BE%E5%BD%A2%E7%95%8C%E9%9D%A2>)

先来安装显卡驱动

- 如果有 NVIDIA 显卡，则：
  ```bash
  pacman -S --needed nvidia
  ```
  注：这个软件包里的 `/usr/lib/modprobe.d/nvidia.conf` 禁用了 nouveau
- 如果没有 NVIDIA 显卡，只有 Intel 核显，则：
  ```bash
  pacman -S --needed xf86-video-intel
  ```

接下来安装图形界面

```bash
# 安装 xorg 组件
pacman -S --needed xorg
# 安装 plasma 和 KDE 应用
pacman -S --needed plasma kde-applications
# 当提示 :: There are 8 providers available for ttf-font: 时，选择 2，即 noto-fonts
# 当提示 :: There are 2 providers available for phonon-qt5-backend: 时，选择 1，即 phonon-qt5-gstreamer
# 当提示 :: There are 3 providers available for cron: 时，选择 1，即 cronie

# 安装显示管理器，用来自动启动图形界面和管理用户登录
pacman -S --needed sddm
# 启用 sddm，这样开机就会进入图形界面
systemctl enable sddm
# 触控板驱动
pacman -S --needed xf86-input-synaptics

# 桌面环境使用的是 NetworkManager
systemctl disable netctl
systemctl enable NetworkManager
# 重启
reboot
```

### 字体和常用软件

- [Fonts (简体中文) - ArchWiki](<https://wiki.archlinux.org/index.php/Fonts_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)
- [修正简体中文显示为异体（日文）字形 - ArchWiki](<https://wiki.archlinux.org/index.php/Localization_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)/Simplified_Chinese_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#%E4%BF%AE%E6%AD%A3%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87%E6%98%BE%E7%A4%BA%E4%B8%BA%E5%BC%82%E4%BD%93%EF%BC%88%E6%97%A5%E6%96%87%EF%BC%89%E5%AD%97%E5%BD%A2>)

重启后，登录进你新建的用户，打开 Yakuake 终端

```bash
# 安装字体
pacman -S --needed nerd-fonts-fira nerd-fonts-fira-code noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra
# pacman -S ttf-sarasa-gothic
```

然后打开 System Settings->Regional Settings->Language，点击 `Add languages`，添加简体中文，并将其移至第一个，`Apply` 使其生效，然后再 Log out（注销）重新登录，就会是中文图形界面了。

```bash
# 安装 chrome 浏览器
sudo pacman -S --needed google-chrome
# 然后就可以在 chrome 中打开本教程了

# 安装 yay
sudo pacman -S --needed yay
# yay 换源
yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save

# qq telegram 百度网盘 网抑云
# Telegram 简体中文语言包：https://t.me/setlanguage/zhcncc
sudo pacman -S --needed linuxqq telegram-desktop baidunetdisk-bin netease-cloud-music-gtk
# 钉钉 xmind
yay -S --needed dingtalk-electron xmind-2020

# WPS 以及其部分可选依赖
sudo pacman -S --needed wps-office-cn wps-office-mime-cn wps-office-mui-zh-cn
# WPS 需要的字体
sudo pacman -S --needed ttf-wps-fonts
# yay -S ttf-ms-fonts wps-office-fonts

# vscode 等等
sudo pacman -S --needed visual-studio-code-bin neofetch bat lolcat proxychains-ng tokei tree flameshot partitionmanager
```

接下来修正简体中文显示为异体（日文）字形的问题，`vim ~/.fonts.conf`，写入如下内容：

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Sans CJK SC</family>
      <family>Noto Sans CJK TC</family>
      <family>Noto Sans CJK JP</family>
    </prefer>
  </alias>
</fontconfig>
```

然后：

```bash
# 更新字体缓存即可生效
fc-cache -fv
# 执行以下命令检查，如果出现 NotoSansCJK-Regular.ttc: "Noto Sans CJK SC" "Regular" 则表示设置成功
fc-match -s | grep 'Noto Sans CJK'
# 查看安装了的中文字体
fc-list :lang=zh
```

### 输入法和皮肤

- [Fcitx5 (简体中文) - ArchWiki](<https://wiki.archlinux.org/index.php/Fcitx5_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)

```bash
pacman -S --needed fcitx5-{im,material-color,chinese-addons} fcitx5-pinyin-{zhwiki,moegirl}
```

`vim ~/.pam_environment`，添加：

```conf
INPUT_METHOD  DEFAULT=fcitx5
GTK_IM_MODULE DEFAULT=fcitx5
QT_IM_MODULE  DEFAULT=fcitx5
XMODIFIERS    DEFAULT=\@im=fcitx5
```

```bash
# 设置自启动，复制到 /etc/xdg/autostart/ 应该也可
cp /usr/share/applications/fcitx5.desktop ~/.config/autostart/
```

- 打开 Fcitx 5 配置
  - 输入法只留下`键盘-英语（美国）`和`拼音`
  - `配置配置全局选项`
    - `切换启用/禁用输入法`将 `Ctrl 空格` 改为左 `Shfit`
  - `拼音设置`
    - 页大小预测个数`10`；云拼音位置`2`；除了启用预测，其他的复选框都勾选；删除按笔画过滤的快捷键；快速输入的触发键双击即可改为空
    - 词典->导入->在线浏览搜狗细胞词典，添加`计算机名词、计算机词汇大全`
  - `附加组件->云拼音`
    - 最小拼音长度`2`；后端`Baidu`

接下来配置输入法皮肤，详见[hosxy/Fcitx5-Material-Color](https://github.com/hosxy/Fcitx5-Material-Color)。`vim ~/.config/fcitx5/conf/classicui.conf`，添加

```conf
# 垂直候选列表
Vertical Candidate List=False
# 按屏幕 DPI 使用
PerScreenDPI=True
# Font (设置成你喜欢的字体)
Font="Noto Sans CJK SC 11"
# 主题
Theme=Material-Color-Blue
```

另外可以看看这个[深蓝词库转换软件](https://github.com/studyzy/imewlconverter)

### 代理软件

- [ArchWiki 推荐的代理软件](<https://wiki.archlinux.org/index.php/General_recommendations_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#%E4%BB%A3%E7%90%86>)
- [Qv2ray 文档](https://qv2ray.net/)

```bash
pacman -S v2ray qv2ray
# 按需安装插件 qv2ray-plugin-ssr-dev-git qv2ray-plugin-trojan-dev-git ...
```

1. 首选项->常规设置。如果是暗色主题，则勾选适应主题的那两项，否则不勾选；行为那里的复选框全部勾选，记忆上次的链接；延迟测试方案勾选`TCPing`
2. 内核设置。v2ray 核心可执行文件路径改成`/usr/bin/v2ray`；然后点击`检查V2Ray核心设置`和`联网对时`以确保 v2ray core 能够正常工作（如果系统时间不对，v2ray 无法正常工作）
3. 入站设置。监听地址设置为`0.0.0.0`可以让同一局域网的其他设备连接；设置好端口并且勾选`设置系统代理`
4. 连接设置。勾选`绕过中国大陆`
5. 高级路由设置。域名策略选择`IPIfNonMatch`；域名阻断填入`geosite:category-ads-all`以屏蔽广告
6. 最后，点确定按钮以保存设置

点击`分组`按钮，填好订阅和过滤，更新订阅（如果无法更新订阅，可能是订阅链接被墙了，建议先建一个非订阅分组，然后添加 ssr 链接，连接上，并且在首选项里让 qv2ray 代理自己，然后再填订阅连接，更新）

### 透明代理

- [透明代理 - 百度百科](https://baike.baidu.com/item/%E9%80%8F%E6%98%8E%E4%BB%A3%E7%90%86)
- [springzfx/cgproxy - GitHub](https://github.com/springzfx/cgproxy)
- [使用 Qv2ray+cgproxy 配置透明代理（仅限 Linux）](https://kagarinokiriestudio.github.io/ArchLinuxTutorial/#/advanced/transparentProxy)

- qv2ray 的设置，首选项
  - 入站设置
    - 可以不用勾选`设置系统代理`了
    - 勾选`透明代理设置`；IPv6 监听地址填 `::1`；网络选项勾选 `TCP` 和 `UDP`；其他默认即可。

```bash
sudo pacman -S cgproxy-git
# 启用 cgproxy 服务
sudo systemctl enable --now cgproxy.service
# 如果启用了 udp 的透明代理（dns 也是 udp），则给 v2ray 二进制文件加上相应的特权
sudo setcap "cap_net_admin,cap_net_bind_service=ep" /usr/bin/v2ray
```

`sudo vim /etc/cgproxy/config.json`，编辑配置文件：

```json
{
  "comment": "For usage, see https://github.com/springzfx/cgproxy",

  "port": 12345,
  "program_noproxy": ["v2ray", "qv2ray"],
  "program_proxy": [],
  "cgroup_noproxy": ["/system.slice/v2ray.service"],
  "cgroup_proxy": ["/"],
  "enable_gateway": false,
  "enable_dns": true,
  "enable_udp": true,
  "enable_tcp": true,
  "enable_ipv4": true,
  "enable_ipv6": true,
  "table": 10007,
  "fwmark": 39283
}
```

编辑配置文件后需要重启服务：

```bash
sudo systemctl restart cgproxy.service
```

测试（注：没有设置 http_proxy 等环境变量）：

```bash
$ curl -vI https://www.google.com
*   Trying 31.13.68.1:443...
* Connected to www.google.com (31.13.68.1) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/certs/ca-certificates.crt
  CApath: none
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
...
```

而且 qv2ray 里的 vCore 日志中会有：

```
2020/10/06 16:56:31 192.168.114.514:58429 accepted udp:114.114.114.114:53 [outBound_DIRECT]
2020/10/06 16:56:31 192.168.114.514:45470 accepted tcp:31.13.68.1:443 [outBound_PROXY]
```

### git

注：邮箱和用户名请换成你自己的；在你的用户下进行（别在 root 用户进行）

```bash
sudo pacman -S --needed git

git config --global user.email "751533978@qq.com"
git config --global user.name "hyuuko"
git config --global core.editor nvim

# 建议在你新建的用户下进行
# 如果把先前的机器上的私钥公钥备份，则再生成一份
ssh-keygen -t rsa -b 4096 -C "751533978@qq.com"
cat ~/.ssh/id_rsa.pub
# 将公钥添加到 github 和 gitee
```

### zsh

注：请把以下的 hyuuko 换成你自己的用户名

```bash
su
pacman -S --needed zsh zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting zsh-theme-powerlevel10k

# 从 gitee 克隆配置文件（用 git 协议进行 git push 时不需要输入用户名和密码）
git clone git@gitee.com:BlauVogel/dotfiles.git && cd dotfiles
rm /home/hyuuko/.p10k.zsh/root/.p10k.zsh  /home/hyuuko/.zshrc /root/.zshrc
# 再创建软链接（请确保此时是在 dotfiles 目录中！）（直接复制也行）
ln -s $(pwd)/archlinux/.p10k.zsh /home/hyuuko/.p10k.zsh
ln -s $(pwd)/archlinux/.p10k.zsh /root/.p10k.zsh
ln -s $(pwd)/archlinux/.zshrc /home/hyuuko/.zshrc
ln -s $(pwd)/archlinux/.zshrc /root/.zshrc
# 最后设置一下默认shell，将 root 用户和 hyuuko 用户的 /bin/bash 改为 /bin/zsh
vim /etc/passwd
```

之后注销，再重新登录即可。

### 美化

```bash
# 用于安装主题、图标等
yay -S ocs-url
```

- 进入 [Breezemite 主题](https://store.kde.org/p/1169286/)页面，点击`Files(1)`，再点`Install`按钮进行安装
- 进入 [Uos [Deepin V20] 图标](https://store.kde.org/p/1349376/)页面，点击`Files(1)`，再点`Install`按钮进行安装

#### 系统设置

- 全局主题。获取新的全局主题，搜索 `Layan`，不要勾选`使用来自主题的桌面布局`
- Plasma 样式。选择`Layan`
- 应用程序风格
  - 应用样式。选择`微风`
  - 窗口装饰
    - 主题。选择`Layan`，无边框
    - 标题栏按钮。左边是 菜单 保持在上方，右边是 上下文帮助 最小化 最大化 关闭
- 颜色。选择`Layan`
- 图标。选择`Uos`
- 字体。DPI 120 或者改缩放
- 工作区间行为
  - 常规行为->动画速度。调到第 13 格
  - 桌面特效->模糊。模糊强度 3,噪点强度 0
  - 锁屏->外观。选择锁屏壁纸，位置缩放，保持比例，背景模糊
- 输入设备->鼠标。指针速度 8 格
- 显示和监控->混成器。缩放方法平滑，渲染后端 2.0
- 在桌面上右键，配置桌面
  - 壁纸。
  - 鼠标动作。中键改为`切换窗口`

#### 面板

```bash
# 安装网速显示组件
yay -S plasma5-applets-netspeed
```

- 面板在下方，部件从左到右依次是：应用程序面板 图标任务管理器 NetspeedWidget 显示桌面 系统托盘 数字时钟 系统负荷查看器
- 点击左下角的应用程序面板，右键程序图标可以`固定到任务管理器`
- 右键面板中的图标任务管理器，进入配置图标任务管理器，勾选`悬停任务时高亮窗口`
- Notes：系统托盘设置里基本都是`相关时显示`
- 系统负荷查看器设置。监视器类型选择紧凑柱状图

如果想要 Mac 那样的底部 dock 可以 `sudo pacman -S latte-dock`

- 数字时钟设置
  - 勾选`显示日期` `显示秒`
  - `时间显示`设置为 24 小时制
  - `日期格式`为自定义：M/d

## 其他

### 调整鼠标滚轮速度

```bash
yay -S imwheel
nvim ~/.imwheelrc
```

写入如下内容：

```
".*"
None,      Up,   Button4, 3
None,      Down, Button5, 3
Control_L, Up,   Control_L|Button4
Control_L, Down, Control_L|Button5
Shift_L,   Up,   Shift_L|Button4
Shift_L,   Down, Shift_L|Button5
```

然后运行`imwheel`命令来生效。最后，打开系统设置->会话和启动->应用程序自启动->添加->命令：`/usr/bin/imwheel`

### 校园网

- [Drcom (简体中文) - ArchWiki](<https://wiki.archlinux.org/index.php/Drcom_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)
- [mchome/dogcom](https://github.com/mchome/dogcom)

学校提供的 linux 版客户端经常掉线，故选择使用 dogcom。

在 windows 上使用学校提供的客户端，在登录前用 wireshark 开始截包，保存文件。接着下载[配置文件生成器](https://raw.githubusercontent.com/drcoms/generic/master/drcom_d_config.py)，将其与第一步的截包文件放到同一个目录下，并且将 `filename = '3.pcapng'` 中的 `3.pcapng` 改为第一步保存的文件名。接着 `python2 drcom_d_config.py > dhcp.conf`。我得到的内容为：

```conf
server = '202.1.1.1'
username='20180000'
password=''
CONTROLCHECKSTATUS = '\x00'
ADAPTERNUM = '\x00'
host_ip = '10.234.115.42'
IPDOG = '\x01'
host_name = 'GILIGILIEYE'
PRIMARY_DNS = '0.0.0.0'
dhcp_server = '0.0.0.0'
AUTH_VERSION = '\x30\x00'
mac = 0x00e04d69741b
host_os = 'NOTE7'
KEEP_ALIVE_VERSION = '\xdc\x02'
ror_version = False
```

需要将 `password` 改为你自己的、更改 `PRIMARY_DNS`，并且添加 `keepalive1_mod`：

```conf
server = '202.1.1.1'
username='20180000'
password='114514'
CONTROLCHECKSTATUS = '\x00'
ADAPTERNUM = '\x00'
host_ip = '10.234.115.42'
IPDOG = '\x01'
host_name = 'GILIGILIEYE'
PRIMARY_DNS = '114.114.114.114'
dhcp_server = '0.0.0.0'
AUTH_VERSION = '\x30\x00'
mac = 0x00e04d69741b
host_os = 'NOTE7'
KEEP_ALIVE_VERSION = '\xdc\x02'
ror_version = False
keepalive1_mod = True
```

在 linux 中，先 `yay -S dogcom-git` 安装 dogcom，然后将 `/etc/drcom.d/dhcp.conf` 修改成上面的样子，最后启用 dogcom 服务：

```bash
sudo systemctl enable --now dogcom-d
# 查看状态，如果显示 Active: active (running)，则说明成功了
systemctl status dogcom-d
```

## 遇到过的一些问题

- 如果透明出现问题，可以试着这样解决：系统设置->显示和监控->混成器，取消勾选`启动时开启混成`，应用，再勾选它，应用。
- VSCode 删除（移动进回收站）文件时会卡顿。这是因为默认状态下，Electron 使用 gio 删除文件。解决办法是让 Electron 使用 kioclient5：`echo 'ELECTRON_TRASH=kioclient5' >> ~/.pam_environment`，然后注销，重新登录。
- 如果挂载的 ntfs 文件系统设备是只读的，无法写入，需要关闭 Win10 的快速启动：控制面板->硬件和声音->电源选项，点击`更改当前不可用的设置`，然后取消勾选`启用快速启动`，保存修改。
- 系统负荷查看器
  - 在表格中鼠标不动停留 2 秒即可显示进程的详细信息
  - 无法显示 CPU 和网络的图表，修复方法：`cp /usr/share/ksysguard/SystemLoad2.sgrd ~/.local/share/ksysguard/`
- 刚安装的软件有时会出现没在应用程序菜单里显示的问题，解决办法：打开系统设置，切换一下图标，然后看看有没有显示出来，再切换回去，来回几次，就有了
- 每次开机后打开 chrome 时都要求输入密码，解决方法：系统设置->KDE 钱包->调用钱包管理器->更改密码，不要输入，直接确认即可。
- 有次将 EFI 分区格式化了，`initramfs-linux-fallback.img initramfs-linux.img vmlinuz-linux`，这三个文件消失了，这时需要`pacman -S linux`，再来安装 grub 和生成设置
- linuxqq 扫码登录后闪退。
  - `rm -rf ~/.config/tencent-qq`
  - `sudo vim /usr/share/applications/qq.desktop`，改为 `Exec=/usr/bin/qq %U –no-sandbox`

### vscode 登录账号的问题

> Writing login information to the keychain failed with error 'The name org.freedesktop.secrets was not provided by any .service files'.

```bash
# https://github.com/MicrosoftDocs/live-share/issues/224
sudo pacman -S gnome-keyring
```

密钥环密码空白就行

### r8152 网卡 Tx timeout 错误断网

```bash
pacman -S --needed linux-headers
yay -S r8152-dkms
```

这下应该没问题了

## Tips

- 按 F12 可以打开 Yakuake（一个快捷终端），不要点击关闭按钮，直接按 F12 或点击其他地方隐藏就行
- Alt+Space 或者直接在桌面输入字符就可打开 KRunner（可以用来搜索应用程序、书签等）
- 状态栏剪贴板右键->配置剪贴板->常规->勾选「忽略选区」。这样能避免鼠标选中文字时自动复制
- 感觉自带的 `KDE 分区管理器` 比 `GParted` 更好用，打开 `KDE 分区管理器`，编辑每个分区的标签名（不建议写成中文）
- [Linux 开机自动挂载分区](https://www.wannaexpresso.com/2020/02/23/linux-auto-mount/)
  ```bash
  su # 切换至 root 用户
  pacman -S arch-install-scripts
  # 查看磁盘信息，找到自己想要挂载的分区
  fdisk -l
  # 以 /dev/sda2 为例，先创建一个文件夹
  mkdir /mnt/XXX
  # 更改其所有者及用户组，此处的 hyuuko 请改为你自己的
  chown hyuuko:hyuuko /mnt/XXX
  # 进行挂载
  mount /dev/sda2 /mnt/XXX
  # 将配置追加至 /etc/fstab
  genfstab / | grep '/dev/sda2' | >> /etc/fstab
  ```
- 给 flameshot 配置快捷键：系统设置->快捷键->全局快捷键->添加应用程序。输入 flameshot，回车，就会出现火焰截图。设置进行截图的快捷键为 `Ctrl + Alt + A`

## 开发环境配置

### Docker

- [Docker (简体中文) - ArchWiki](<https://wiki.archlinux.org/index.php/Docker_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)

```bash
# 安装 docker
sudo pacman -S --needed docker
# 启动 docker
sudo systemctl start docker
# 或者设置开机自启并立即启动 docker
# sudo systemctl enable --now docker.service
# 重启 docker 服务
sudo systemctl restart docker
# 将当前用户加入 docker 用户组以赋予当前用户使用 docker 的权限
sudo usermod -aG docker $USER
```

接下来配置镜像地址，先在[阿里云](https://www.aliyun.com/)注册一个帐号，然后打开控制台的[容器镜像服务](https://cr.console.aliyun.com/cn-shenzhen/instances/mirrors)，点击左侧的镜像中心->镜像加速器，就可以看到专属加速器地址，再通过修改 daemon 配置文件`/etc/docker/daemon.json` 来使用加速器

```bash
sudo mkdir -p /etc/docker
sudo vim /etc/docker/daemon.json
```

填入：

```json
{
  "registry-mirrors": ["https://换成你自己的.mirror.aliyuncs.com"]
}
```

```bash
# 重启 docker 使配置生效
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### Rust

注：换成你自己的用户名；`.zshrc`里设置了关于 rust 的环境变量等等，此处就不再重复了。

```bash
su hyuuko
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
source /usr/local/cargo/env
sudo chown -R hyuuko:hyuuko /usr/local/rustup /usr/local/cargo
chmod -R u+w /usr/local/rustup /usr/local/cargo
# 安装 nightly 版工具链
rustup toolchain install nightly

mkdir ~/.zfunc
# 启用 rustup 补全
rustup completions zsh > ~/.zfunc/_rustup
# 启用 cargo 补全
rustup completions zsh cargo > ~/.zfunc/_cargo
```

接下来`vim ~/.cargo/config`填入以下内容以设置 rust crates 源

```conf
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"

# 替换成你偏好的镜像源
replace-with = 'sjtu'

# 清华大学
[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

# 中国科学技术大学
[source.ustc]
registry = "git://mirrors.ustc.edu.cn/crates.io-index"

# 上海交通大学
[source.sjtu]
registry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index"

# rustcc社区
[source.rustcc]
registry = "git://crates.rustcc.cn/crates.io-index"
```

### C/C++

```bash
pacman -S --needed gcc clang lib32-gcc-libs gdb make binutils man-pages ccls bear
# 安装 qemu，有点大，有需要就装吧
pacman -S --needed qemu-arch-extra
```

### Node.js

```bash
pacman -S --needed nodejs-lts-erbium yarn npm
yarn config set registry https://registry.npm.taobao.org/ && yarn config get registry
npm config set registry https://registry.npm.taobao.org/ && npm config get registry
```

### VMware

```bash
sudo pacman -S --needed vmware-workstation
sudo pacman -S --needed linux-headers            # 可选依赖项，模块编译所需
sudo modprobe -a vmw_vmci vmmon                  # 加载 vmw_vmci 和 vmmon 内核模块
sudo systemctl enable --now vmware-networks      # 启用虚拟机网络
sudo systemctl enable --now vmware-usbarbitrator # 启用 vmware 的 usb 设备连接
```
