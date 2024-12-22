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

" SAVVY: Visual mode <F1> same as Visual mode <F3> — start g*-like
" search and match forward.
" - CALSO: <S-F1>, <F8>, and <ENTER> start g*-like search but stay put.
"   - <S-F1> and <Enter> are strict (like star), whereas <F8> is not
"     strict (like gstar). And <F8> and <Enter> add multi-identifiers.
" - REFER: The dubs_grep_steady :grep search uses a toggle to enable
"   and disable multi-identifier searching (whereas this script uses
"   a toogle to enable and disable strict whitespace matching). (Not
"   that we couldn't make a toggle for multiident matching, but right
"   now there's just a myriad of different keybindings instead.)
"   - See \dg to toggle grep-steady mutliident.
"     ~/.vim/pack/landonb/start/dubs_grep_steady/plugin/dubs_grep_steady.vim

function! s:CreateMaps__BlinkySearch() abort
  call g:embrace#blinky_search#CreateMaps_GStarSearch('<F1>')
  call g:embrace#blinky_search#CreateMaps_StarSearchStayPut('<S-F1>')
  call g:embrace#blinky_search#CreateMaps_GStarSearchStayPut('<F8>')
  call g:embrace#blinky_search#CreateMaps_ToggleHighlight('<CR>')
  call g:embrace#blinky_search#CreateMaps_SearchForward('<F3>')
  call g:embrace#blinky_search#CreateMaps_SearchBackward('<S-F3>')
  call g:embrace#blinky_search#CreateMaps_StarPound_VisualMode()
  call g:embrace#blinky_search#CreateMaps_ToggleMulticase('<Leader>dc')
  call g:embrace#blinky_search#CreateMaps_ToggleStrict('<Leader>ds')
endfunction

call s:CreateMaps__BlinkySearch()

" ***

" Wire normal mode search commands to call `zz`.
call g:embrace#middle_matches#CreateMaps(['n', 'N', '*', '#', 'g*', 'g#'])

" ***

" - SAVVY: <C-h> is wired after/, to avoid mswin.vim conflict.
"
"  call g:embrace#hide_highlights#CreateMaps('<C-h>')

