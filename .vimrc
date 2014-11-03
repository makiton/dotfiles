if has('vim_starting')
  set nocompatible
  let bundle_dir = '.vim/bundle'
  if !isdirectory(bundle_dir.'/neobundle.vim')
    call system( 'git clone https://github.com/Shougo/neobundle.vim.git '.bundle_dir.'/neobundle.vim')
  endif

  exe 'set runtimepath+='.bundle_dir.'/neobundle.vim'
  let g:neobundle_default_git_protocol='https'
endif

call neobundle#begin(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'

runtime! plugins/*.vim

call neobundle#end()
filetype plugin indent off
NeoBundleCheck

if !has('vim_starting')
  call neobundle#call_hook('on_source')
endif

so ~/.vim/autocommands.vim
so ~/.vim/formats.vim
so ~/.vim/keymaps.vim
