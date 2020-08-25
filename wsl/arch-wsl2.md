## 换源

```bash
echo 'Server = http://mirrors.cqu.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
echo 'Server = https://repo.huaweicloud.com/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist

pacman-key --init
pacman-key --populate

vim /etc/pacman.conf
# 彩色输出
# 启用 multilib 库
# 添加 archlinuxcn 源

pacman -Syy
pacman -S archlinuxcn-keyring
pacman -Rns vim
pacman -Syu
```

## 安装软件

```bash
su
pacman -S --needed zsh neovim neofetch bat lolcat base-devel yay proxychains-ng tokei
# 显示:: fakeroot is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n]，选 n
# yay 换源
yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save
# nvim /opt/etc/proxychains.conf，使其能够代理并且注释proxy_dns
```

## 自启动脚本

`nvim /etc/init.wsl`，填入：

```bash
# 获取windows的ip
export WIN_IP=`cat /etc/resolv.conf | grep nameserver | awk '{print $2}'`
# 删除 [ProxyList] 所在行到文件末尾的全部内容
sed -i '/\[ProxyList\]/,$d' /etc/proxychains.conf
# 往文件末尾添加socks5设置，这个 7890 是我的 qv2ray 的 socks5 端口号，改成你自己的
echo -e '[ProxyList]\nsocks5 '${WIN_IP}' 7890' >> /etc/proxychains.conf
```

然后`chmod +x /etc/init.wsl`

win+r，输入`shell:startup`，然后在 vscode 中打开该文件夹（不然无法新建.vbs 文件），新建`Arch.vbs`

```vb
Set ws = CreateObject("Wscript.Shell")
ws.run "wsl -d Arch -u root /etc/init.wsl", vbhide
```

## 添加用户

```bash
useradd -r -m -s /bin/zsh hyuuko
chmod +w /etc/sudoers
# `nvim /etc/sudoers`，添加`hyuuko ALL=(ALL) ALL`：
chmod -w /etc/sudoers
# 设置密码
passwd hyuuko
```

## 安装 antigen

```bash
su hyuuko # 因为 yay 拒绝在root用户里安装aur包
# 安装 antigen，此过程使用 proxychains 进行代理更快些
proxychains -q yay -S antigen
# 用vscode的内置终端时卡在 ==> Entering fakeroot environment...很怪
# 从 gitee 克隆配置文件（用 git 协议进行 git push 时不需要输入用户名和密码）
git clone git@gitee.com:BlauVogel/dotfiles.git && cd dotfiles
su
# 先删除已存在的 zsh 和 p10k 的配置文件
rm -f /home/hyuuko/.zshrc /root/.zshrc /home/hyuuko/.p10k.zsh /root/.p10k.zsh
# 再创建软链接（请确保此时是在 dotfiles 目录中！）
ln -s $(pwd)/wsl/.zshrc /home/hyuuko/.zshrc
ln -s $(pwd)/wsl/.zshrc /root/.zshrc
ln -s $(pwd)/wsl/.p10k.zsh /home/hyuuko/.p10k.zsh
ln -s $(pwd)/wsl/.p10k.zsh /root/.p10k.zsh

# 此时 antigen 就会弄好插件
proxychains -q zsh
# 进入 hyuuko 用户，也弄一下
proxychains -q su hyuuko
zsh
# 最后设置一下默认shell，将 root 用户和 hyuuko 用户的 /bin/bash 改为 /bin/zsh
sudo nvim /etc/passwd
```

## 安装开发工具

## 禁用 windows 的 path
