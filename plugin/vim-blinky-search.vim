" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Landon Bouma <https://tallybark.com/> 
" Project: https://github.com/landonb/vim-blinky-search#🕹
" License: GPLv3
" Copyright © 2015, 2017-2018, 2024 Landon Bouma.

" -------------------------------------------------------------------

" GUARD: Press <F9> to reload this plugin (or :source it).
" - Via: https://github.com/embrace-vim/vim-source-reloader#↩️

if expand("%:p") ==# expand("<sfile>:p")
  unlet g:loaded_vim_blinky_search_plugin
endif

if exists("g:loaded_vim_blinky_search_plugin") || &cp

  finish
endif

let g:loaded_vim_blinky_search_plugin = 1

" -------------------------------------------------------------------

if get(g:, 'blinky_search_disable', 0)

  finish
endif

" -------------------------------------------------------------------

" Wire <F1>, <Shift-F1>, <F3>, <Shift-F3>, *, #, \ds
call g:embrace#blinky_search#CreateMaps()

" Wire normal mode search commands to call `zz`.
call g:embrace#middle_matches#CreateMaps(['n', 'N', '*', '#', 'g*', 'g#'])

" - SAVVY: <C-h> is wired after/, to avoid mswin.vim conflict.
"   call g:embrace#hide_highlights#CreateMaps()

