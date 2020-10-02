# dotfiles

日常开发环境：Manjaro + KDE

- [ArchLinux 或 Manjaro WSL2 配置记录](https://www.cnblogs.com/zsmumu/p/manjaro-wsl2.html)
- [VSCode + clang + ccls 搭建 C/C++ 开发环境](https://www.cnblogs.com/zsmumu/p/12829634.html)

# Manjaro + KDE 配置

## 安装系统

下载[Manjaro KDE](https://manjaro.org/download/) 或者直接去[华为云的 Manjaro 镜像](https://repo.huaweicloud.com/manjaro-cd/)，[查看预装软件列表](https://mirrors.huaweicloud.com/manjaro-cd/kde/20.0.3/manjaro-kde-20.0.3-200606-linux56-pkgs.txt)

1. 先用 [rufus](https://rufus.ie/) 制作 Manjaro 的 USB 启动盘。制作完成后重启电脑，在显示笔记本厂商图标前按 F12 选择启动 USB 安装盘
2. 然后开始选择时区、语言等，如果有 Invidia 显卡，那么 driver 请选择 no free
3. 然后开始 boot，进入 Live CD 安装环境，在右下角断开网络连接，然后设置时区语言等等..
4. 手动分区

|  大小/M  | 文件系统  |  挂载点   | 标记 |     用途     |
| :------: | :-------: | :-------: | :--: | :----------: |
|   8192   | linuxswap |    无     | swap |   交换分区   |
|   512    |   fat32   | /boot/efi | boot | 操作系统引导 |
|  40960   |   ext4    |     /     | root |    根目录    |
| 其余所有 |   ext4    |   /home   |  无  |   用户数据   |

安装好后，开始配置，为了避免麻烦，建议直接`su`进入 root 用户

## 设置时区，同步时间

参考：[同步 Linux 双系统的时间](https://mogeko.me/2019/062/)

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
Server = https://mirrors.cloud.tencent.com/archlinuxcn/$arch
```

```bash
pacman -Syy archlinuxcn-keyring     # 安装 keyring
pacman -Syu                         # 系统更新
```

## 安装软件

- ArchWiki 的推荐：[General recommendations (简体中文) - ArchWiki](<https://wiki.archlinux.org/index.php/General_recommendations_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)
- 关于字体：[Fonts (简体中文) - ArchWiki](<https://wiki.archlinux.org/index.php/Fonts_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)

```bash
# 为了方便就全写一起了
su
pacman -S --needed nerd-fonts-fira nerd-fonts-fira-code adobe-source-han-sans-cn-fonts \
fcitx5 fcitx5-{gtk,qt,configtool,material-color,chinese-addons} fcitx5-pinyin-{zhwiki,moegirl} \
v2ray qv2ray qv2ray-plugin-{ssr-dev-git,trojan} \
visual-studio-code-bin google-chrome neovim neofetch bat lolcat base-devel yay proxychains-ng tokei tree \
telegram-desktop flameshot

# yay 换源
yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save
# 查看 Fira 字体
fc-list | grep Fira
# 查看安装了的中文字体
fc-list :lang=zh
```

## 设置 DNS

`vim /etc/resolv.conf` 修改成如下内容：

```conf
nameserver 114.114.114.114
nameserver 223.5.5.5
```

但如果你的网络用 DHCP，那么重启后就可能会被 dhcpcd、netctl、NetworkManager 等软件修改，所以还需要`chattr +i /etc/resolv.conf`，给该文件添加写保护，避免配置信息被任何程序修改。最后`systemctl restart systemd-networkd`重启网络服务。

## 调整鼠标滚轮速度

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

## 设置代理

### proxychains

`vim /etc/proxychains.conf`

- 取消 `quiet_mode` 的注释
- 并且将最后一行的 `socks4 127.0.0.1 9095` 修改为 `socks5 127.0.0.1 7890` 和 `http 127.0.0.1 7891`
- 代理 yay 的方法
  - `export http_proxy=socks5://127.0.0.1:7890 && export https_proxy=socks5://127.0.0.1:7890`
  - 如果要用 proxychains 则需要使用 gcc-go 重新编译 yay 和 proxychains

### qv2ray

请注意一定要同步好系统时间以及详读[qv2ray 文档](https://qv2ray.net/)

1. 打开 qv2ray，启用 ssr 插件，点击插件，如果 ssr 未勾选则需要勾选再重启 qv2ray
2. 首选项->常规设置。如果是暗色主题，则勾选适应主题的那两项，否则不勾选；界面主题选择`Breeze`（即微风）；行为那里全部勾选，记忆上次的链接；延迟测试方案勾选`TCPing`
3. 内核设置。v2ray 核心可执行文件路径改成`/usr/bin/v2ray`；然后点击`检查V2Ray核心设置`和`联网对时`以确保 v2ray core 能够正常工作
4. 入站设置。监听地址设置为`0.0.0.0`可以让同一局域网的其他设备连接；设置好端口并且勾选`设置系统代理`
5. 连接设置。勾选`绕过中国大陆`和使用本地 DNS
6. 高级路由设置。域名策略选择`IPIfNonMatch`；域名阻断填入`geosite:category-ads-all`以屏蔽广告
7. 最后，点确定按钮以保存设置

点击`分组`按钮，填好订阅和过滤，更新订阅（如果无法更新订阅，可能是订阅链接被墙了，建议先建一个非订阅分组，然后添加 ssr 链接，连接上，并且在首选项里让 qv2ray 代理自己，然后再填订阅连接，更新）

```bash
# 更换 geoip.dat 和 geosite.dat
pc curl -L -o /tmp/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat
pc curl -L -o /tmp/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat
sudo cp /tmp/geoip.dat /usr/lib/v2ray && rm /tmp/geoip.dat
sudo cp /tmp/geosite.dat /usr/lib/v2ray && rm /tmp/geosite.dat
```

### 透明代理

尝试失败。。。逃

```bash
pacman -S cgproxy-git
sudo systemctl enable --now cgproxy.service
sudo vim /etc/cgproxy/config.json
# 改成 "enable_gateway": true,
# 再重启服务
sudo systemctl restart cgproxy.service
```

## google-chrome

若 chrome 可以打开系统代理设置（我的 manjaro xfce 就不行），可以略过此步。否则需要`google-chrome-stable --proxy-server="socks5://127.0.0.1:7890"`打开 chrome，登录帐号同步数据。之后弄好油猴脚本，并安装 Proxy SwitchyOmega 插件，用它来开启系统代理

## git

```bash
git config --global user.email "751533978@qq.com"
git config --global user.name "hyuuko"
git config --global core.editor nvim

su hyuuko
# 如果把先前的机器上的私钥公钥备份，则再生成一份
ssh-keygen -t rsa -b 4096 -C "751533978@qq.com"
cat ~/.ssh/id_rsa.pub
# 将公钥添加到 github 和 gitee
```

可以为 git 配置代理，但是没必要。如果远程仓库在 github 等国外的，直接用 proxychains 代理即可。

## zsh

有很多插件是已经预装好了的

```bash
su
pacman -S zsh-theme-powerlevel10k
# 从 gitee 克隆配置文件（用 git 协议进行 git push 时不需要输入用户名和密码）
git clone git@gitee.com:BlauVogel/dotfiles.git && cd dotfiles
rm /home/hyuuko/.p10k.zsh/root/.p10k.zsh  /home/hyuuko/.zshrc /root/.zshrc
# 再创建软链接（请确保此时是在 dotfiles 目录中！）（直接复制也行）
ln -s $(pwd)/manjaro-kde/.p10k.zsh /home/hyuuko/.p10k.zsh
ln -s $(pwd)/manjaro-kde/.p10k.zsh /root/.p10k.zsh
ln -s $(pwd)/manjaro-kde/.zshrc /home/hyuuko/.zshrc
ln -s $(pwd)/manjaro-kde/.zshrc /root/.zshrc
# 最后设置一下默认shell，将 root 用户和 hyuuko 用户的 /bin/bash 改为 /bin/zsh
nvim /etc/passwd
```

zshrc 复制一下就好，注销后再登录

## 输入法和皮肤

参考：

- [Fcitx5 (简体中文) - ArchWiki](<https://wiki.archlinux.org/index.php/Fcitx5_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)

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
    - 页大小预测个数`10`；云拼音位置`2`；除了启用预测，其他的复选框都勾选；删除按笔画过滤的快捷键、快速输入的快捷键`Escape`
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
Font="思源黑体 CN Medium 11"
# 主题
Theme=Material-Color-Blue
```

另外可以看看这个[深蓝词库转换软件](https://github.com/studyzy/imewlconverter)

## Rust

### 安装及配置 Rust

注：有很多已经在`.zshrc`里设置了，比如环境变量等等，此处就不再重复了。

```bash
# 请在 hyuuko 用户里安装
su hyuuko
# 直接默认安装 stable
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
# 重启 zsh（这会执行.zshrc中的source $HOME/.cargo/env）
exec zsh
# 安装 nightly
rustup toolchain install nightly

mkdir ~/.zfunc
# 启用 rustup 补全
rustup completions zsh > ~/.zfunc/_rustup
# 启用 cargo 补全
rustup completions zsh cargo > ~/.zfunc/_cargo
exec zsh
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

### VSCode Rust 插件

- [rust-analyzer](https://marketplace.visualstudio.com/items?itemName=matklad.rust-analyzer)
- [CodeLLDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb)

## C/C++

```bash
pacman -S --needed gcc clang lib32-gcc-libs gdb make binutils man-pages ccls bear
# 安装 qemu，有点大，有需要就装吧
pacman -S --needed qemu-arch-extra
```

## Node.js

```bash
pacman -S --needed nodejs-lts-erbium yarn npm
yarn config set registry https://registry.npm.taobao.org/ && yarn config get registry
npm config set registry https://registry.npm.taobao.org/ && npm config get registry
```

## NeoVim

https://github.com/Gabirel/Hack-SpaceVim/blob/master/README_zh_CN.adoc

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

## VMware

```bash
pacman -S --needed vmware-workstation
uname -r                              # 查看一下自己的内核
pacman -S --needed linux56-headers    # 如果是 5.6 就这样
modprobe -a vmw_vmci vmmon            # 加载内核模块
systemctl enable vmware-usbarbitrator # 启用 vmware 的 usb 设备连接
systemctl start vmware-usbarbitrator
systemctl enable vmware-networks      # 启用虚拟机网络
systemctl start vmware-networks
```

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

## 其他软件

### 国产软件

```bash
# 网抑云
sudo pacman -S netease-cloud-music
# WPS
sudo pacman -S --needed wps-office-cn ttf-wps-fonts wps-office-mime-cn wps-office-mui-zh-cn
yay -S ttf-ms-fonts wps-office-fonts
```

## other

- 打开设置->屏幕保护。将屏幕和锁屏都关闭，否则休眠后可能需要登录两次
- 打开 chrome 和 vscode 时，有时会弹出“您登录计算机时，您的登录密钥环未被解锁”
  ```bash
  sudo pacman -S seahorse
  seahorse
  ```
  点击左上的加号新建一个 Password keyring，密码为空，然后将其设置为默认
- chrome 设置字体，宽度固定的字体（即 monospace），改为 FiraCode Nerd Font Mono
- [Linux 开机自动挂载分区](https://www.wannaexpresso.com/2020/02/23/linux-auto-mount/)
  注：这部分建议在 hyuuko 用户进行。先使用 `sudo fdisk -l` 查看存储空间，找到我们想要自动挂载的那个设备，比如我这里是 `/dev/sda2`，文件系统是 exfat，然后使用 `sudo blkid /dev/sda2` 查看设备的 UUID，我这里是 0E95-06C4，然后使用`id`命令查看 hyuuko 用户的 uid 和 gid，我们就可以 `sudo vim /etc/fstab`，在文件末尾添加：`UUID=0E95-06C4 /mnt/SHARE exfat uid=1000,gid=1001,umask=000 0 0`。接下来我们可以先 `sudo mkdir /mnt/SHARE` 再 `sudo mount -a` 来挂载 fstab 中的所有文件系统（先确保你想要挂载的设备还没有挂载上去），之后用 `df -h` 命令查看是否挂载成功。
  - 注意：如果文件系统是 ext4，不支持 mount 时设置 uid 和 gid，所以需要将刚才的改成：`UUID=157ee4d6-833f-4f22-84c8-b297c07085af /mnt/Share ext4 defaults,noatime 0 0`，然后 `sudo mount -a` `sudo chown hyuuko:hyuuko /mnt/Share`
- 安装 mdbook，不想使用 `cargo install mdbook` 来编译，可以直接在[release](https://github.com/rust-lang/mdBook/releases/latest)下载最新版的，然后解压至 `~/.cargo/bin`

### vscode 登录账号的问题

Writing login information to the keychain failed with error 'The name org.freedesktop.secrets was not provided by any .service files'.
https://github.com/MicrosoftDocs/live-share/issues/224

```bash
sudo pacman -S gnome-keyring
```

密钥环密码空白就行

### r8152 网卡 Tx timeout 错误导致断网

https://aur.archlinux.org/packages/r8152-dkms/

```bash
# 先查看内核版本
uname -a
# 安装对应的 headers，我的内核版本为 5.8，故安装 linux58-headers
pacman -S --needed linux58-headers
yay -S r8152-dkms
```

这下应该没问题了

### 校园网

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

参考：[Drcom (简体中文)](<https://wiki.archlinux.org/index.php/Drcom_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)

## TODO

- [ ] neovim + SpaceVim 配置 C/C++ 和 Rust
- [ ] 休眠后无法唤醒的问题
- [ ] 尝试一下 [vscode-dev-containers 对于 Rust 的配置](https://github.com/microsoft/vscode-dev-containers/blob/master/containers/codespaces-linux/.devcontainer/library-scripts/rust-debian.sh)

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

## 美化

不要调缩放率，否则 kconsole 会有透明线，调节字体 DPI 为 120 就够了

### 更纱黑体（用于 VSCode）

下载[更纱黑体](https://github.com/be5invis/Sarasa-Gothic/releases)，解压，选中安装所有 sarasa-mono-sc 开头的

```bash
sudo mkdir /usr/share/fonts/sarasa-gothic
/home/hyuuko/下载/sarasa-gothic-ttf-0.12.14/
cp sarasa-mono-sc-* /usr/share/fonts/sarasa-gothic
fc-cache -vf # 更新字体缓存
fc-list | grep Sarasa # 查看字体
```

### 主题

三种方法安装主题

- 第一种：在系统设置->外观里安装（需要选一个好一点的代理）
- 第二种
  ```bash
  yay -S ocs-url
  ```
  然后比如在 https://store.kde.org/p/1310500 点安装按钮
- 第三种：手动下载，解压
  <br>/usr/share/plasma/desktoptheme 这是存放 plasma 主题
  <br>/usr/share/plasma/look-and-feel/ 存放全局主题
  <br>/usr/share/plasma/plasmoids/ 存放插件
  <br>~/.local/share/plasma/是用户的
  <br>把解压出的 com.github.vinceliuice.McMojave 复制进/usr/share/plasma/look-and-feel/

#### 系统设置

- 全局主题。选择 `McMojave-light`，不要勾选`使用来自主题的桌面布局`
- Plasma 样式。选择`Breath2 Light`
- 应用程序风格
  - 应用样式。选择`微风`
  - 窗口装饰
    - 主题。选择`Breezemite`，并且`nvim ~/.local/share/aurorae/themes/Breezemite/Breezemiterc`修改默认配置以调节边框大小，我直接将这四行注释掉了
      ```
      PaddingBottom=68
      PaddingLeft=60
      PaddingRight=60
      PaddingTop=30
      ```
    - 标题栏按钮。左边是 菜单 保持在上方，右边是 上下文帮助 最小化 最大化 关闭
- 颜色。选择`McMojaveLight`
- 图标。选择`McMojave-circle`
- 工作区间行为
  - 常规行为->动画速度。调到第 13 格
  - 锁屏->外观。锁屏壁纸选择`matrix-manjaro`
- 输入设备->鼠标。指针速度 8 格
- 显示和监控->混成器->渲染后端。选择`OpenGL 3.1`
- 在桌面上右键，配置桌面
  - 壁纸。选择`mountains-1412683`
  - 鼠标动作。中键改为`切换窗口`

#### 面板

- 面板在下方，部件从左到右依次是：应用程序面板 图标任务管理器 显示桌面 系统托盘 数字时钟 系统负荷查看器
- 点击左下角的应用程序面板，右键程序图标可以`固定到任务管理器`
- 右键面板中的图标任务管理器，进入配置图标任务管理器，勾选`悬停任务时高亮窗口`
- Notes：系统托盘设置里基本都是`相关时显示`
- 系统负荷查看器设置。监视器类型选择紧凑柱状图

如果想要 Mac 那样的底部 dock 可以 `sudo pacman -S latte-dock`

- 数字时钟设置
  - 勾选`显示日期` `显示秒`
  - `时间显示`设置为 24 小时制
  - `日期格式`为自定义：M/d

#### 其他

- 按 F12 打开 Yakuake，然后右键编辑当前方案->外观，新建一个配色方案，背景透明度 20%

## pacman 常见用法

## Tips

- 按 F12 可以打开 Yakuake（一个快捷终端），不要点击关闭按钮，直接按 F12 或点击其他地方隐藏就行
- Alt+Space 或者直接在桌面输入字符就可打开 KRunner（可以用来搜索应用程序、书签等）
- 系统负荷查看器
  - 在表格中鼠标不动停留 2 秒即可显示进程的详细信息
  - 无法显示 CPU 和网络的图表，修复方法：`cp /usr/share/ksysguard/SystemLoad2.sgrd ~/.local/share/ksysguard/`
- 如果透明出现问题，可以试着这样解决：系统设置->显示和监控->混成器，取消勾选`启动时开启混成`，应用，再勾选它，应用。
- 状态栏剪贴板右键->配置剪贴板->常规->勾选「忽略选区」。这样能避免鼠标选中文字时自动复制
- 如果挂载的 ntfs 文件系统设备是只读的，无法写入，需要关闭 Win10 的快速启动：控制面板->硬件和声音->电源选项，点击`更改当前不可用的设置`，然后取消勾选`启用快速启动`，保存修改。
- 感觉自带的 `KDE 分区管理器` 比 `GParted` 更好用，打开 `KDE 分区管理器`，编辑每个分区的标签
- VSCode 删除（移动进回收站） ext4 文件系统中的文件时，会卡顿。解决办法：`echo 'export ELECTRON_TRASH=gio' > ~/.config/plasma-workspace/env/electron-trash-gio.sh`，然后注销，重新登录。（我感觉并没有太大的改善，建议直接 shift+delete 彻底删除

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
