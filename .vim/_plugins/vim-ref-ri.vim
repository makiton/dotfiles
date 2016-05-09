call dein#add('taka84u9/vim-ref-ri',
      \{
      \ 'depends': ['thinca/vim-ref'],
      \ 'autoload': { 'filetypes': ['ruby', 'eruby', 'haml'] }
      \}
      \)

let g:ref_open                    = 'split'
let g:ref_refe_cmd                = expand('~/.vim/ref/ruby-ref1.9.2/refe-1_9_2')

