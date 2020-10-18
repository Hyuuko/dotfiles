## 参考

- [Martins3/My-Linux-config - GitHub](https://github.com/Martins3/My-Linux-config)
- [NeoVim User manual](https://neovim.io/doc/user/)
- [SpaceVim 入门指南](https://spacevim.org/cn/quick-start-guide/)
- [SpaceVim 使用文档](https://spacevim.org/cn/documentation/)
- [Vim 备忘清单](https://vim.rtorr.com/lang/zh_cn)
- [Vim 速查表](https://github.com/skywind3000/awesome-cheatsheets/blob/master/editors/vim.txt)

## 安装 NeoVim + SpaceVim

SpaceVim 需要用 yarn/npm 安装插件，所以请先[安装 yarn 和 npm](../archlinux/README.md#nodejs)

```bash
# 安装 NeoVim
sudo pacman -S --needed neovim

# 安装 SpaceVim
curl -sLf https://spacevim.org/cn/install.sh | bash
# 打开 neovim 将会自动安装插件
nvim
```

## `:checkhealth`检查 NeoVim 的状态

1. 遇到问题：`[vimproc] vimproc's DLL: "/home/hyuuko/.SpaceVim/bundle/vimproc.vim/lib/vimproc_linux64.so" is not found. Please read :help vimproc and make it.`
   解决办法：在 neovim 中执行`:VimProcInstall`

## 配置 NeoVim + SpaceVim

待更新
