set encoding=utf-8
set fileencodings=utf-8,euc-jp,shift-jis,iso-2022-jp
set fileencoding=utf-8
set fileformats=unix,dos
set expandtab
set tabstop=4
set shiftwidth=4
set smartindent
set autoindent
set number
set backspace=2
set title
set ic
map <c-tab> :tabn<cr>
map <c-s-tab> :tabN<cr>
set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P
set clipboard=unnamed
set tags=~/workspace/*/tags
set hlsearch
colorscheme desert
cd ~/workspace
autocmd FileType python setl smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd FileType php imap <buffer> <C-e> foreach(explode("\n",print_r( ,true)) as $line){error_log($line);}<ESC>0WWi

" twitvim.vim
map <c-s-a> :PosttoTwitter<cr>
let twitvim_browser_cmd="open"

