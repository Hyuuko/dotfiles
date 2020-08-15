#
# 各用户的 ~/.zshrc 都是指向此文件的软链接
#

# rust国内镜像，更多见https://blog.csdn.net/xiangxianghehe/article/details/105874880
export RUSTUP_DIST_SERVER=https://mirrors.sjtug.sjtu.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.sjtug.sjtu.edu.cn/rust-static/rustup
# add a if else , if the user is hyuuko, source the cargoenv
if [ "$(whoami)" = "hyuuko" ]; then source ~/.cargo/env ; fi
# 用来rustup补全，要放在 compinit 之前
fpath+=~/.zfunc
autoload -Uz compinit
compinit

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

# 建议放在source /usr/share/zsh/share/antigen.zsh后面，因为oh-my-zsh定义了一些alias，这样可避免覆盖
alias ls='ls -F --color'
alias la='ls -a'
alias ll='ls -al'
alias cat='bat --style=plain'
alias vim='nvim'
alias pc='proxychains4 -q'
