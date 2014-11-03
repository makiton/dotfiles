if filereadable(expand('~/rtags'))
  au FileType ruby,eruby setl tags+=~/rtags,~/gtags
endif
