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

```bash
su
timedatectl list-timezones              # 列出所有时区
timedatectl set-timezone Asia/Shanghai  # 设置时区
timedatectl set-local-rtc true          # 设置为RTC（BIOS时间）
date                                    # 查看时间
# 如果时间还不正常，说明是BIOS时间错了，需要重启按F2,修改BIOS时间
timedatectl status  # 查看状态，如果 RTC 与 CST 相同就说明设置成功了
```

接下来启用 NTP 自动对时，`nano /etc/systemd/timesyncd.conf`，取消 `#NTP=` 的注释。然后填上 NTP 服务器的地址

```
NTP=time1.aliyun.com time2.aliyun.com time3.aliyun.com time4.aliyun.com time5.aliyun.com time6.aliyun.com time7.aliyun.com
```

然后：

```bash
timedatectl set-ntp true      # 启动 NTP
timedatectl timesync-status   # 查看 NTP 的状态
```

## 换源

```bash
# 换源，如果有的话，建议用自己学校的
echo 'Server = https://repo.huaweicloud.com/manjaro/stable/$repo/$arch' > /etc/pacman.d/mirrorlist
```

然后添加 archlinuxcn 源，`nano /etc/pacman.conf`，取消`#Color`的注释以启用彩色输出，然后在文件末尾加上：

```conf
[archlinuxcn]
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
fcitx5-chinese-addons fcitx5 fcitx5-gtk fcitx5-qt fcitx5-rime fcitx5-material-color \
v2ray qv2ray qv2ray-plugin-ssr-dev-git qv2ray-plugin-trojan \
archlinuxcn/visual-studio-code-bin archlinuxcn/google-chrome neovim neofetch bat lolcat base-devel yay proxychains-ng tokei

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

- [CNIX](https://ntt-co-jp.club/user)
  - [v2ray](https://losadhwselfff2332dasd.xyz/link/SOdtuGDK3mVQFjBV?sub=3)
  - [ssr](https://losadhwselfff2332dasd.xyz/link/SOdtuGDK3mVQFjBV?sub=1)
  - [clash](https://losadhwselfff2332dasd.xyz/link/SOdtuGDK3mVQFjBV?clash=1)
- [OVO](https://v2.qovoq.ml/#/dashboard)
  - [trojan](http://ovo.dy.cdn.llsmall.com/api/v1/client/subscribe?token=b3ce1c807ec9d3532ee57d1994ec1d2d)

### qv2ray

请注意一定要同步好系统时间以及详读[qv2ray 文档](https://qv2ray.net/)

1. 打开 qv2ray，启用 ssr 插件，点击插件，如果 ssr 未勾选则需要勾选再重启 qv2ray
2. 并且首选项->内核设置：v2ray 核心可执行文件路径改成`/usr/bin/v2ray`，然后点击`检查V2Ray核心设置`和`联网对时`以确保 v2ray core 能够正常工作
3. 入站设置里设置好端口并且勾选`设置系统代理`。监听地址设置为`0.0.0.0`可以让局域网的其他电脑连接。
4. 连接设置里勾选`绕过中国大陆`
5. 高级路由设置里，第二行，第二列填入`geosite:geolocation-!cn`以代理所有非中国大陆的连接，第三列填入`geosite:category-ads-all`以屏蔽广告
6. 最后，点`OK`按钮保存设置。

点击`分组`按钮，填好订阅和过滤，更新订阅（如果无法更新订阅，可能是订阅链接被墙了，建议先建一个非订阅分组，然后添加 ssr 链接，连接上，并且在首选项里让 qv2ray 代理自己，然后再填订阅连接，更新）

### proxychains

`vim /etc/proxychains.conf`，将 proxy_dns 这一行注释。（这样能够让 proxychains 代理 yay），并且将最后一行的 `socks4 127.0.0.1 9095` 修改为 `socks5 127.0.0.1 7890`

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
rm /home/hyuuko/.p10k.zsh /root/.p10k.zsh
# 再创建软链接（请确保此时是在 dotfiles 目录中！）（直接复制也行）
ln -s $(pwd)/manjaro-kde/.p10k.zsh /home/hyuuko/.p10k.zsh
ln -s $(pwd)/manjaro-kde/.p10k.zsh /root/.p10k.zsh
# 最后设置一下默认shell，将 root 用户和 hyuuko 用户的 /bin/bash 改为 /bin/zsh
nvim /etc/passwd
```

zshrc 复制一下就好，注销后再登录

## 输入法和皮肤

参考：

- [在 Manjaro 上优雅地使用 Fcitx5](https://www.wannaexpresso.com/2020/03/26/fcitx5/)
- [RIME 使用说明](https://github.com/rime/home/wiki/UserGuide)
- [Linux 下 Rime 输入法配置记录](http://einverne.github.io/post/2014/11/rime.html)

先不要打开 Fcitx！修改配置文件 ~/.config/fcitx5/profile 时，请务必退出 fcitx5 输入法，否则会因为输入法退出时会覆盖配置文件导致之前的修改被覆盖，修改其他配置文件可以不用退出 fcitx5 输入法，只需右键图标，点击重新部署即可生效

`vim ~/.config/fcitx5/profile` 添加以下内容

```conf
[Groups/0]
# Group Name
Name=Default
# Layout
Default Layout=us
# Default Input Method
DefaultIM=rime

[Groups/0/Items/0]
# Name
Name=rime
# Layout
Layout=

[GroupOrder]
0=Default
```

`vim ~/.pam_environment`，添加：

```conf
GTK_IM_MODULE=fcitx5
QT_IM_MODULE=fcitx5
XMODIFIERS="@im=fcitx5"
```

`echo ${XDG_SESSION_TYPE}`，如果输出的是 x11 那就需要`vim ~/.xprofile`，添加：

```bash
fcitx5 &
```

注销，重新登录，Fctix 应该会自启，rime 第一次加载要花几十秒。如果有多个输入法，切换输入法的技巧是：按住 Ctrl 不动，再按 Shift。在第一次切换后，才可以直接按 Shift 切换。Shift 尽量按个 0.5 秒比较好。如果只启用了 rime 这一个输入法，用 Shift 键就可以切换中英文。

接下来配置 rime，`vim ~/.local/share/fcitx5/rime/default.custom.yaml`以编辑自定义默认设置：

```yaml
# 如果没生效，可能是配置格式错了
patch:
  switcher/hotkeys:
    # 使用 / 符号表明只改变hotkeys这一个选项
    # 否则会将整个 switcher 下的所有选项一起改变
    - F4
  menu/page_size: 9
  schema_list:
    # 把luna_pinyin_simp放在第一个，这样就默认简体
    - schema: luna_pinyin_simp
    - schema: luna_pinyin
    - schema: luna_pinyin_fluency
  ascii_composer/switch_key/Shift_L: commit_code # 按左Shift时将已输入的字符上屏并且切换至英文
```

然后`vim ~/.local/share/fcitx5/rime/luna_pinyin_simp.custom.yaml`以编辑朙月拼音-简化字的设置：

```yaml
patch:
  "switches/@0/reset": 1 # 默认英文
```

右键右下角 Rime 的图标，点击重新部署，配置文件会生成到`~/.local/share/fcitx5/rime/build`，然后就会生效。更多配置请详细阅读[Rime 定制指南](https://github.com/rime/home/wiki/CustomizationGuide)等文档

Rime 输入法在使用中会在一定时间自动将用户词典备份为快照文件`*.userdb.txt`（还没看到过）

接下来配置输入法皮肤，详见[hosxy/Fcitx5-Material-Color](https://github.com/hosxy/Fcitx5-Material-Color)。`vim ~/.config/fcitx5/conf/classicui.conf`，添加

```conf
# 垂直候选列表
Vertical Candidate List=False
# 按屏幕 DPI 使用
PerScreenDPI=True
# Font (设置成你喜欢的字体)
Font="思源黑体 CN Medium 12"
# 主题
Theme=Material-Color-Blue
```

然后设置单行模式，`vim ~/.config/fcitx5/conf/rime.conf`，添加：

```conf
# 可用时在应用程序中显示预编辑文本
PreeditInApplication=True
```

右键右下角 Rime 的图标，点击重新启动，就会生效了

另外可以看看这个[深蓝词库转换软件](https://github.com/studyzy/imewlconverter)，将 Win10 微软拼音自学习词库转换成 Rime 的词库

## Rust

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

### 网抑云

```bash
sudo pacman -S netease-cloud-music
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
  注：这部分建议在 hyuuko 用户进行。先使用 `sudo fdisk -l` 查看存储空间，找到我们想要自动挂载的那个设备，比如我这里是 `/dev/sda2`，文件系统是 ntfs，然后使用 `sudo blkid /dev/sda2` 查看设备的 UUID，我这里是 0E95-06C4，然后使用`id`命令查看 hyuuko 用户的 uid 和 gid，我们就可以 `sudo vim /etc/fstab`，在文件末尾添加：`UUID=0E95-06C4 /mnt/SHARE vfat uid=1000,gid=1001,umask=000 0 0`。接下来我们可以先 `sudo mkdir /mnt/SHARE` 再 `sudo mount -a` 来挂载 fstab 中的所有文件系统（先确保你想要挂载的设备还没有挂载上去），之后用 `df -h` 命令查看是否挂载成功。
- 安装 mdbook，不想使用 `cargo install mdbook` 来编译，可以直接在[release](https://github.com/rust-lang/mdBook/releases/latest)下载最新版的，然后解压至 `~/.cargo/bin`

### vscode 登录账号的问题

Writing login information to the keychain failed with error 'The name org.freedesktop.secrets was not provided by any .service files'.
https://github.com/MicrosoftDocs/live-share/issues/224

```bash
sudo pacman -S gnome-keyring
```

密钥环密码空白就行

### USB 网卡 Tx timeout 错误导致断网

https://aur.archlinux.org/packages/r8152-dkms/

```bash
pacman -S --needed linux56-headers # 必须要有这个
yay -S r8152-dkms
```

这下应该没问题了

## TODO

- [ ] 校园网[Drcom (简体中文)](<https://wiki.archlinux.org/index.php/Drcom_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)
- [ ] neovim + SpaceVim 配置 C/C++ 和 Rust
- [ ] 休眠后无法唤醒的问题
- [ ] 用 rust 写一个可以自动更新 mdbook 等能够从 github release 下载的软件 https://github.com/rust-lang/mdBook/releases/latest
- [ ] 好用的下载软件，aria2？
  - `sudo pacman -S aria2` 用法待写
- [x] wps。`sudo pacman -S --needed wps-office-cn ttf-wps-fonts wps-office-mime-cn wps-office-mui-zh-cn`

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

两种方法安装主题（不要在系统设置里弄，会安装失败）

1. 第一种

```bash
yay -S ocs-url
```

然后在https://store.kde.org/p/1310500点安装按钮

2. 第二种
   手动下载，解压
   /usr/share/plasma/desktoptheme 这是存放 plasma 主题
   /usr/share/plasma/look-and-feel/ 存放全局主题
   /usr/share/plasma/plasmoids/ 存放插件
   ~/.local/share/plasma/是用户的
   把解压出的 com.github.vinceliuice.McMojave 复制进/usr/share/plasma/look-and-feel/

```bash
sudo pacman -S latte-dock
```

- 系统设置->全局主题 选择 `McMojave-light`
- Plasma 样式选择`亮色微风`
- 应用程序风格->窗口装饰，选择 Breezemite，并且在`nvim ~/.local/share/aurorae/themes/Breezemite/Breezemiterc`以调节边框大小
  ```
  PaddingBottom=68
  PaddingLeft=60
  PaddingRight=60
  PaddingTop=30
  ```
- 颜色选择`McMojaveLight`
- 图标使用`McMojave-circle`
