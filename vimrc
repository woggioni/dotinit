syntax on

set number
set mousemodel=extend
set ignorecase smartcase
set tabstop=4 softtabstop=4 expandtab shiftwidth=4 smarttab

if has('unnamedplus')
  " By default, Vim will not use the system clipboard when yanking/pasting to
  " the default register. This option makes Vim use the system default
  " clipboard.
  " Note that on X11, there are _two_ system clipboards: the "standard" one, and
  " the selection/mouse-middle-click one. Vim sees the standard one as register
  " '+' (and this option makes Vim use it by default) and the selection one as
  " '*'.
  " See :h 'clipboard' for details.
  set clipboard=unnamedplus,unnamed
else
  " Vim now also uses the selection system clipboard for default yank/paste.
  set clipboard+=unnamed
endif

set mouse=a
set fileformat=unix
set title
set ruler
set showmode
set autoindent
set cindent
set history=1000
set undolevels=1000

