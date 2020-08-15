# dotfiles

日常开发环境：Manjaro + xfce

- [ArchLinux 或 Manjaro WSL2 配置记录](https://www.cnblogs.com/zsmumu/p/manjaro-wsl2.html)
- [VSCode + clang + ccls 搭建 C/C++ 开发环境](https://www.cnblogs.com/zsmumu/p/12829634.html)

# Manjaro + xfce 配置

## 安装系统

下载[Manjaro xfce](https://manjaro.org/download/) 或者直接去[华为云的 Manjaro 镜像](https://repo.huaweicloud.com/manjaro-cd/)，建议选 minimal （最小安装）版

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

```bash
su
timedatectl list-timezones              # 列出所有时区
timedatectl set-timezone Asia/Shanghai  # 设置时区
timedatectl set-local-rtc true          # 设置为本地时间
ntpdate -u cn.ntp.org.cn                # 同步网络时间
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

```bash
pacman -S --needed nerd-fonts-fira nerd-fonts-fira-code wqy-microhei fcitx-im fcitx-configtool fcitx-sunpinyin archlinuxcn/visual-studio-code-bin archlinuxcn/google-chrome zsh neovim neofetch v2ray qv2ray qv2ray-plugin-ssr-dev-git qv2ray-plugin-trojan bat lolcat base-devel yay proxychains-ng tokei

# yay 换源
yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save
# 查看 Fira 字体
fc-list | grep Fira
# 查看安装了的中文字体，可以看到刚才安装了WenQuanYi Micro Hei Mono
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
imwheel
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

打开系统设置->会话和启动->应用程序自启动->添加->命令：`/usr/bin/imwheel`

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

## zsh 和 antigen，以及输入法

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

`vim ~/.xprofile` 添加以下内容

```sh
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
```

注销后再登录，看看 Fctix 有没有自启，然后打开 Fctix 配置

1. 将输入法配置这一页只留下`键盘-英语（美国）`和`sunpinyin`，其他都删掉
2. 将输入法配置->全局配置->切换激活/非激活输入法改成`Lshift`
3. 候选词个数改为 10
4. 输入法配置->外观：勾选竖排候选词列表

## Rust

注：有很多已经在`.zshrc`里设置了，比如环境变量等等，此处就不再重复了。

```bash
# 直接默认安装 stable
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
# 安装 nightly
rustup toolchain install nightly

mkdir ~/.zfunc
# 启用 rustup 补全
rustup completions zsh > ~/.zfunc/_rustup
# 启用 cargo 补全
rustup completions zsh cargo > ~/.zfunc/_cargo
# 重启 zsh
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

## TODO

- [ ] 同步油猴脚本
- [ ] 记忆窗口大小
