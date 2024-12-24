" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Landon Bouma <https://tallybark.com/> 
" Project: https://github.com/landonb/vim-blinky-search#🕹
" License: GPLv3
" Copyright © 2015, 2017-2018, 2024 Landon Bouma.

" -------------------------------------------------------------------

" GUARD: Press <F9> to reload this plugin (or :source it).
" - Via: https://github.com/embrace-vim/vim-source-reloader#↩️

if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_vim_blinky_search_after_plugin
endif

if exists('g:loaded_vim_blinky_search_after_plugin') || &cp

  finish
endif

let g:loaded_vim_blinky_search_after_plugin = 1

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

function! s:CreateMaps__SearchCommands() abort
  call g:embrace#blinky_search#CreateMaps_GStarSearch('<F1>')
  call g:embrace#blinky_search#CreateMaps_StarSearchStayPut('<S-F1>')
  call g:embrace#blinky_search#CreateMaps_GStarSearchStayPut('<F8>')
  call g:embrace#blinky_search#CreateMaps_ToggleHighlight('<CR>')
  call g:embrace#blinky_search#CreateMaps_SearchForward('<F3>')
  call g:embrace#blinky_search#CreateMaps_SearchBackward('<S-F3>')
  call g:embrace#blinky_search#CreateMaps_StarPound_VisualMode()
  call g:embrace#blinky_search#CreateMaps_ToggleBlinking('<Leader>dB')
  call g:embrace#blinky_search#CreateMaps_ToggleMulticase('<Leader>dc')
  call g:embrace#blinky_search#CreateMaps_ToggleStrict('<Leader>ds')
endfunction

call s:CreateMaps__SearchCommands()

" ***

" Wire normal mode search commands to call `zz`.
call g:embrace#middle_matches#CreateMaps(['n', 'N', '*', '#', 'g*', 'g#'])

" ***

" Wire <C-h>
" - Must call via after/plugin/ because mswin.vim sets <C-H> to
"   ":promptrepl\<CR>", which opens the GUI (e.g., MacVim) Find dialog.
"     /Applications/MacVim.app/Contents/Resources/vim/runtime/mswin.vim
call g:embrace#hide_highlights#CreateMaps('<C-h>')

" ***

" USAGE: If you don't want to blink matches, either remove this map
" (don't call the following function), or use the toggle (defaults \dB).

" Note that at fast blinking, some of the blink behavior is inconsistent.
" - E.g., at 2 blinks, 75 msec. each, e.g.,:
"     nnoremap <expr> <plug>(blinky-search-after) g:embrace#slash_blink#blink(2, 75)
"   an <F1> insert mode search (which starts a new search and jumps
"   forward) appears to only blink once. But an <F3> command (which
"   calls 'n') blinks accordingly.
"   - But if you increase the blink length, e.g.,
"       nnoremap <expr> <plug>(blinky-search-after) g:embrace#slash_blink#blink(3, 200)
"     then you'll see that an <F1> command blinkins the requisite
"     number of times.
" - But I'm not gonna investigate further, no matter how much
"   this might irritate me. ( ಠ ʖ̯ ಠ)

function! s:CreateMaps__BlinkySearch() abort
  if !has('timers')

    return
  endif

  nnoremap <expr> <Plug>(blinky-search-after) g:embrace#slash_blink#blink(2, 75)
endfunction

call s:CreateMaps__BlinkySearch()

