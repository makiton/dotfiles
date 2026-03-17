call dein#add(
      \  'Shougo/vimproc',
      \  {
      \  'build' : {
      \    'mac' : 'make -f make_mac.mak',
      \    'unix' : 'make -f make_unix.mak',
      \  },
      \ }
      \)
