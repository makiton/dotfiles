NeoBundleLazy 'basyura/unite-rails', {
      \ 'depends' : 'Shjkougo/unite.vim' }

nnoremap [unite]rv  :<C-U>Unite rails/view<CR>
nnoremap [unite]rm  :<C-U>Unite rails/model<CR>
nnoremap [unite]rc  :<C-U>Unite rails/controller<CR>

nnoremap [unite]rco :<C-U>Unite rails/config<CR>
nnoremap [unite]rs  :<C-U>Unite rails/spec<CR>
nnoremap [unite]rmi :<C-U>Unite rails/db -input=migrate<CR>
nnoremap [unite]rse :<C-U>Unite rails/db -input=seeds<CR>
nnoremap <C-H>l           :<C-U>Unite rails/lib<CR>
nnoremap <expr><C-H>g     ':e '.b:rails_root.'/Gemfile<CR>'
nnoremap <expr><C-H>r     ':e '.b:rails_root.'/config/routes.rb<CR>'
nnoremap <expr><C-H>se    ':e '.b:rails_root.'/db/seeds.rb<CR>'
nnoremap <C-H>ra          :<C-U>Unite rails/rake<CR>
nnoremap <C-H>h           :<C-U>Unite rails/heroku<CR>
nnoremap <silent> <C-f> :<C-u>UniteWithBufferDir -buffer-name=files file file/new<CR>

