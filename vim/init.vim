"=============================================================================
" init.vim --- Entry file for neovim
" Copyright (c) 2016-2020 Wang Shidong & Contributors
" Author: Wang Shidong < wsdjeg@outlook.com >
" URL: https://spacevim.org
" License: GPLv3
"=============================================================================

execute 'source' fnamemodify(expand('<sfile>'), ':h').'/config/main.vim'

"TODO 放在 SpaceVim 的启动函数里

" 粘贴模式，避免粘贴时缩进混乱
set paste
" 在普通模式输入的命令时显示
set showcmd
" 用空格代替tab
set expandtab
set shiftwidth=4
set tabstop=4

function! s:cargo_task() abort
    if filereadable('Cargo.toml')
        let commands = ['build', 'run', 'test']
        let conf = {}
        for cmd in commands
            call extend(conf, {
                        \ cmd : {
                        \ 'command': 'cargo',
                        \ 'args' : [cmd],
                        \ 'isDetected' : 1,
                        \ 'detectedName' : 'cargo:'
                        \ }
                        \ })
        endfor
        return conf
    else
        return {}
    endif
endfunction
call SpaceVim#plugins#tasks#reg_provider(funcref('s:cargo_task'))
