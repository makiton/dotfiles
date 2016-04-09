if has('vim_starting')
  set nocompatible
  let bundle_dir = '.vim/bundle'
  if !isdirectory(bundle_dir.'/neobundle.vim')
    call system( 'git clone https://github.com/Shougo/neobundle.vim.git '.bundle_dir.'/neobundle.vim')
  endif

  exe 'set runtimepath+='.bundle_dir.'/neobundle.vim'
  let g:neobundle_default_git_protocol='https'
endif



if &compatible
  set nocompatible
endif
set runtimepath^=/Users/makiton/.vim/repos/github.com/Shougo/dein.vim
call dein#begin(expand('/Users/makiton/.vim'))
call dein#add('Shougo/dein.vim')

"  " Add or remove your plugins here:
"  call dein#add('Shougo/neosnippet.vim')
"  call dein#add('Shougo/neosnippet-snippets')
"
"  " You can specify revision/branch/tag.
"  call dein#add('Shougo/vimshell', { 'rev': '3787e5' })
"
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
