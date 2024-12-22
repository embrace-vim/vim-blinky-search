" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Landon Bouma <https://tallybark.com/> 
" Project: https://github.com/landonb/vim-blinky-search#🕹
" License: GPLv3
" Copyright © 2015, 2017-2018, 2024 Landon Bouma.

" -------------------------------------------------------------------

" GUARD: Press <F9> to reload this plugin (or :source it).
" - Via: https://github.com/embrace-vim/vim-source-reloader#↩️

if expand("%:p") ==# expand("<sfile>:p")
  unlet g:loaded_vim_blinky_search_after_plugin
endif

if exists("g:loaded_vim_blinky_search_after_plugin") || &cp

  finish
endif

let g:loaded_vim_blinky_search_after_plugin = 1

" -------------------------------------------------------------------

if get(g:, 'blinky_search_disable', 0)

  finish
endif

" -------------------------------------------------------------------

" Wire <C-h>
" - Must call after/ because mswin.vim sets <C-H> to ":promptrepl\<CR>",
"   which opens the GUI (e.g., MacVim) Find dialog.
"     /Applications/MacVim.app/Contents/Resources/vim/runtime/mswin.vim
call g:embrace#hide_highlights#CreateMaps('<C-h>')

