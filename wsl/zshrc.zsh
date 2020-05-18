#
# 各用户的 ~/.zshrc 会链接到此文件
#

# 用来rustup补全
fpath+=~/.zfunc

# 初始化 antigen
source /usr/share/zsh/share/antigen.zsh
# Load the oh-my-zsh's library
# oh-my-zsh 会启用历史命令、按键绑定等功能
antigen use oh-my-zsh
# 启用一些 bundle
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
# Load the theme
antigen theme romkatv/powerlevel10k

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#50616d"
# Tell antigen that you're done
antigen apply

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH="$PATH:/mnt/e/Program Files/Microsoft VS Code/bin"
# rust国内镜像
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

if [ "$(pwd)" =  "/mnt/c/Windows/System32" ]; then  cd ~ ; fi

# 获取windows的ip
export WIN_IP=`cat /etc/resolv.conf | grep nameserver | awk '{print $2}'`
# 请事先复制好 /etc/proxychains.conf
# cp -f /etc/proxychains.conf ~/.proxychains.conf
# 删除 ~/.proxychains.conf 中 [ProxyList] 所在行到文件末尾的全部内容
sed -i '/\[ProxyList\]/,$d' ~/.proxychains.conf
# 往文件末尾添加socks5设置，这个 20807 是我的 clash 的 socks5 端口号，改成你自己的
echo '[ProxyList]\nsocks5 '${WIN_IP}' 20807' >> ~/.proxychains.conf
# 设置别名，并且使用 ~/.proxychains.conf 作为proxychains的配置文件，并且让proxychains quiet（不输出一大串东西）
alias pc='proxychains4 -q -f ~/.proxychains.conf'
# xserver的端口
export DISPLAY=$WIN_IP:23789.0

# alias，建议放在source /usr/share/zsh/share/antigen.zsh后面
# 因为oh-my-zsh定义了一些alias，这样可避免覆盖
alias ls='ls -F --color'
alias la='ls -a'
alias batp='bat --style=plain'
# 用来运行code-server
alias run-code-server='/mnt/e/Programs/code-server-3.2.0-linux-x86_64/code-server --bind-addr "127.0.0.1:22333" --auth none'
