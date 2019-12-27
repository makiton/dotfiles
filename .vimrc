if &compatible
  set nocompatible
endif
set runtimepath^=~/.cache/dein/repos/github.com/Shougo/dein.vim
call dein#begin(expand('~/.cache/dein'))
call dein#add('Shougo/dein.vim')

runtime! _plugins/*.vim
runtime! _colors/*.vim
call dein#end()
filetype plugin indent on
if dein#check_install()
  call dein#install()
endif

source ~/.vim/displays.vim
source ~/.vim/autocommands.vim
source ~/.vim/keymaps.vim

set clipboard+=unnamed
