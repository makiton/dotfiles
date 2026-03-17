if filereadable(expand('~/rtags'))
  au FileType ruby,eruby setl tags+=~/rtags,~/gtags
endif
autocmd BufWritePre * :%s/\s\+$//ge
au BufNewFile,BufRead *.jinja set ft=jinja
