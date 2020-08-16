# dotfiles

日常开发环境：Manjaro + xfce

- [ArchLinux 或 Manjaro WSL2 配置记录](https://www.cnblogs.com/zsmumu/p/manjaro-wsl2.html)
- [VSCode + clang + ccls 搭建 C/C++ 开发环境](https://www.cnblogs.com/zsmumu/p/12829634.html)

# Manjaro + xfce 配置

## 安装系统

下载[Manjaro xfce](https://manjaro.org/download/) 或者直接去[华为云的 Manjaro 镜像](https://repo.huaweicloud.com/manjaro-cd/)，建议选 minimal （最小安装）版

我们在 vscode 里用比较一下完整版和 minimal 的区别（其实也可以用 `git diff` 命令）：

```bash
git init diff
curl -o minimal.txt https://mirrors.huaweicloud.com/manjaro-cd/xfce/20.0.3/minimal/manjaro-xfce-20.0.3-minimal-200606-linux56-pkgs.txt
git add . && git commit -m "minimal.txt"
curl -o minimal.txt https://mirrors.huaweicloud.com/manjaro-cd/xfce/20.0.3/manjaro-xfce-20.0.3-200606-linux56-pkgs.txt
# 然后就可以查看完整版比minimal版多了gcc、jdk8还有一些桌面组件、壁纸等等
```

1. 先用 [rufus](https://rufus.ie/) 制作 Manjaro 的 USB 启动盘。制作完成后重启电脑，在显示笔记本厂商图标前按 F12 选择启动 USB 安装盘
2. 然后开始选择时区、语言等，如果有 Invidia 显卡，那么 driver 请选择 no free
3. 然后开始 boot，进入 Live CD 安装环境，在右下角断开网络连接，然后设置时区语言等等..
4. 手动分区

|  大小/M  | 文件系统  |  挂载点   | 标记 |              用途               |
| :------: | :-------: | :-------: | :--: | :-----------------------------: |
|   8192   | linuxswap |    无     | swap |            交换分区             |
|   512    |   fat32   | /boot/efi | boot |          操作系统引导           |
|  20480   |   ext4    |     /     | root | 存放系统，相当于 C 盘，最少 20G |
| 其余所有 |   ext4    |   /home   |  无  |            用户数据             |

安装好后，开始配置，为了避免麻烦，建议直接`su`进入 root 用户

## 设置时区，同步时间

参考：[同步 Linux 双系统的时间](https://mogeko.me/2019/062/)

```bash
su
timedatectl list-timezones              # 列出所有时区
timedatectl set-timezone Asia/Shanghai  # 设置时区
timedatectl set-local-rtc true          # 设置为RTC（BIOS时间）
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
pacman -S --needed nerd-fonts-fira nerd-fonts-fira-code wqy-microhei adobe-source-han-sans-cn-fonts \
fcitx5-chinese-addons fcitx5 fcitx5-gtk fcitx5-qt fcitx5-rime fcitx5-material-color \
v2ray qv2ray qv2ray-plugin-ssr-dev-git qv2ray-plugin-trojan \
archlinuxcn/visual-studio-code-bin archlinuxcn/google-chrome zsh neovim neofetch bat lolcat base-devel yay proxychains-ng tokei xfce4-goodies wallpapers-2018

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
  - [trojan](http://ovo.v2nb.cf/api/v1/client/subscribe?token=a3529907dceb64d363cafa2c4a415eb4)

### qv2ray

请注意一定要同步好系统时间以及详读[文档](https://qv2ray.net/)

打开 qv2ray，启用 ssr 插件，并且首选项->内核设置：v2ray 核心可执行文件路径改成`/usr/bin/v2ray`，然后点击`检查V2Ray核心设置`和`联网对时`按钮再在入站设置里设置好端口。注意，监听地址设置为`0.0.0.0`可以让局域网的其他电脑连接。最后，点`OK`按钮保存设置。

点击`分组`按钮，填好订阅和过滤，更新订阅（如果无法更新订阅，可能是订阅链接被墙了，建议先建一个非订阅分组，然后添加 ssr 链接，连接上，并且在首选项里让 qv2ray 代理自己，然后再填订阅连接，更新）

### proxychains

`vim /etc/proxychains.conf`，将 proxy_dns 这一行注释。（这样能够让 proxychains 代理 yay），并且将最后一行的 `socks4 127.0.0.1 9095` 修改为 `socks5 127.0.0.1 7890`

## google-chrome

chrome 设置系统代理（若 chrome 无法打开系统代理，则`google-chrome-stable --proxy-server="socks5://127.0.0.1:7890"`打开 chrome），登录帐号同步数据。之后弄好油猴脚本

配置 SwitchyOmega 插件的规则

```
[SwitchyOmega Conditions]
@with result

*.google* +proxy
*.github* +proxy
*.youtube* +proxy
*.sstatic.net +proxy
*.stackoverflow.com +proxy
*.qovoq.ml +proxy
*.ntt-co-jp.club +proxy
*.rufus.ie +proxy
*.osdn.net +proxy
*.ajax.googleapis.com +proxy
*.yandex.net +proxy
*.gstatic.com +proxy
*.speedpan.com +proxy
*.greasyfork.org +proxy
*.msocdn.com +proxy
*.office.com +proxy
*.fontawesome.com +proxy
*.ytimg.com +proxy
*.manjaro.org +proxy
*.wallpaperaccess.com +proxy

* +direct
```

## git

```bash
git config --global user.email "751533978@qq.com"
git config --global user.name "hyuuko"

su hyuuko
# 如果把先前的机器上的私钥公钥备份，则再生成一份
ssh-keygen -t rsa -b 4096 -C "751533978@qq.com"
cat ~/.ssh/id_rsa.pub
# 将公钥添加到 github 和 gitee
```

```bash
# 为 git 设置代理，当然也可不这么做，用 proxychains 也可
git config --global http.proxy 'socks5://127.0.0.1:7890'
git config --global https.proxy 'socks5://127.0.0.1:7890'
```

## zsh 和 antigen

```bash
# 安装 antigen，此过程用代理更快些
proxychains -q yay -S antigen
# 从 gitee 克隆配置文件
git clone https://gitee.com/hyuuko/dotfiles.git
cd dotfiles

ln -s ./manjaro-xfce/.zshrc /home/hyuuko/.zshrc
ln -s ./manjaro-xfce/.zshrc /root/.zshrc

ln -s ./manjaro-xfce/.p10k.zsh /home/hyuuko/.p10k.zsh
ln -s ./manjaro-xfce/.p10k.zsh /root/.p10k.zsh
```

```bash
# 此时 antigen 就会弄好插件
proxychains -q zsh
# 进入 hyuuko 用户，也弄一下
su hyuuko
proxychains -q zsh
# 最后设置一下默认shell，将 root 用户和 yourname 用户的 /bin/bash 改为 /bin/zsh
nvim /etc/passwd
```

注销后再登录

## 输入法和皮肤

参考：[在 Manjaro 上优雅地使用 Fcitx5](https://www.wannaexpresso.com/2020/03/26/fcitx5/)

先不要打开 Fcitx！修改配置文件 ~/.config/fcitx5/profile 时，请务必退出 fcitx5 输入法，否则会因为输入法退出时会覆盖配置文件导致之前的修改被覆盖，修改其他配置文件可以不用退出 fcitx5 输入法，不过生效仍需重启

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
Name=keyboard-us
# Layout
Layout=

[Groups/0/Items/1]
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

接下来配置 rime，配置文件在 ~/.local/share/fcitx5/rime

1. `vim ~/.local/share/fcitx5/rime/build/default.yaml`
   1. 将`- schema: luna_pinyin_simp`以默认使用简体

接下来配置皮肤，详见[hosxy/Fcitx5-Material-Color](https://github.com/hosxy/Fcitx5-Material-Color)。`vim ~/.config/fcitx5/conf/classicui.conf`，添加

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

注销，重新登录,Fctix 应该会自启。切换输入法的技巧是：按住 Ctrl 不动，再按 Shift。在第一次切换后，才可以直接按 Shift 切换。Shift 尽量按个 0.5 秒比较好

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
pacman -S --needed gcc clang lib32-gcc-libs gdb make binutils man-pages ccls
# 安装 qemu，有点大，有需要就装吧
pacman -S --needed qemu-arch-extra
```

## Node.js

```bash
pacman -S --needed nodejs-lts-erbium yarn npm
yarn config set registry https://registry.npm.taobao.org/ && yarn config get registry
npm config set registry https://registry.npm.taobao.org/ && npm config get registry
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

## other

- 所有设置->屏幕保护。改为 20 分钟
- 打开 chrome 和 vscode 时，有时会弹出“您登录计算机时，您的登录密钥环未被解锁”
  ```bash
  sudo pacman -S seahorse
  seahorse
  ```
  点击左上的加号新建一个 Password keyring，密码为空，然后将其设置为默认

## TODO

- [ ] xfce 好像不能记忆窗口大小
- [ ] emoji 字体
- [ ] 校园网[Drcom (简体中文)](<https://wiki.archlinux.org/index.php/Drcom_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>)
- [ ] 鼠标宏（前进/后退）没有用 https://hustergs.github.io/archives/ec23118f.html https://wiki.archlinux.org/index.php/Mouse_buttons
