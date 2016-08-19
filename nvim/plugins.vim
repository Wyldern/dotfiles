"
" Neovim Plugin Install/Config
" Arkan <arkan@drakon.io>
"

call EnsureExists('~/.local/share/nvim/plugged')
call plug#begin('~/.local/share/nvim/plugged')

" essentials {{{
Plug 'vim-airline/vim-airline' "{{{
  let g:airline_theme = 'murmur'
  let g:airline_powerline_fonts = 1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#left_sep = ' '
  let g:airline#extensions#tabline#left_alt_sep = '¦'
  let g:airline#extensions#tabline#buffer_idx_mode = 1
  nmap <leader>1 <Plug>AirlineSelectTab1
  nmap <leader>2 <Plug>AirlineSelectTab2
  nmap <leader>3 <Plug>AirlineSelectTab3
  nmap <leader>4 <Plug>AirlineSelectTab4
  nmap <leader>5 <Plug>AirlineSelectTab5
  nmap <leader>6 <Plug>AirlineSelectTab6
  nmap <leader>7 <Plug>AirlineSelectTab7
  nmap <leader>8 <Plug>AirlineSelectTab8
  nmap <leader>9 <Plug>AirlineSelectTab9
  "}}}
Plug 'vim-airline/vim-airline-themes'
Plug 'neomake/neomake' "{{{
  autocmd! BufWritePost * Neomake
  "}}}
Plug 'nathanaelkane/vim-indent-guides' "{{{
  let g:indent_guides_start_level=1
  let g:indent_guides_guide_size=1
  let g:indent_guides_enable_on_vim_startup=1
  let g:indent_guides_color_change_percent=3
  let g:indent_guides_auto_colors=0
  function! s:indent_set_console_colors()
    hi IndentGuidesOdd ctermbg=235
    hi IndentGuidesEven ctermbg=236
  endfunction
  autocmd VimEnter,Colorscheme * call s:indent_set_console_colors()
  "}}}
Plug 'majutsushi/tagbar' "{{{
  nnoremap <silent> <F9> :TagbarToggle<CR>
  nnoremap <leader>t :TagbarToggle<CR>
  let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
      \ 'p:package',
      \ 'i:imports:1',
      \ 'c:constants',
      \ 'v:variables',
      \ 't:types',
      \ 'n:interfaces',
      \ 'w:fields',
      \ 'e:embedded',
      \ 'm:methods',
      \ 'r:constructor',
      \ 'f:functions'
      \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
      \ 't' : 'ctype',
      \ 'n' : 'ntype'
      \ },
    \ 'scope2kind' : {
      \ 'ctype' : 't',
      \ 'ntype' : 'n'
      \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
    \ }
  "}}}
Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-startify'
Plug 'kshenoy/vim-signature'
Plug 'ryanoasis/vim-devicons'
"}}}

" colorschemes {{{
Plug 'altercation/vim-colors-solarized' "{{{
  let g:solarized_termcolors=256
  let g:solarized_termtrans=1
  "}}}
"Plug 'rakr/vim-two-firewatch'
"Plug 'duythinht/inori'
"Plug 'glortho/feral-vim'
Plug 'DrSpatula/vim-buddy'
"Plug 'trevorrjohn/vim-obsidian'
"Plug 'nanotech/jellybeans.vim'
"Plug 'sjl/badwolf'
"Plug 'jordwalke/flatlandia'
"}}}

" try load local plugin config
if filereadable(expand("~/.nvimplugs")) | source ~/.nvimplugs' | endif

" fin
call plug#end()
