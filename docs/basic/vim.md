## `.vimrc`

```vim title="~/.vimrc"
se nocp mouse=a
se enc=utf-8
se nu rnu sw=2 ts=2 et ai si hls is ic scs
filetype plugin indent on
ino jj <esc>
nn <silent> <esc> :noh<cr>
sy on
se tgc
colo catppuccin
```

> 其他推荐主题：
>
> - `colo habamax`
> - `colo retrobox`
> - `colo sorbet`
> - `colo wildcharm`

> 如果需要持久撤销历史，可以考虑加入 `se udf udir=~/.vim/undo`。

