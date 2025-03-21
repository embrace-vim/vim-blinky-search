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
"     ~/.kit/nvim/landonb/dubs_grep_steady/plugin/dubs_grep_steady.vim

function! s:CreateMaps__SearchCommands() abort
  call g:embrace#blinky_search#CreateMaps_GStarSearch('<F1>')
  call g:embrace#blinky_search#CreateMaps_StarSearchStayPut('<S-F1>')
  call g:embrace#blinky_search#CreateMaps_GStarSearchStayPut('<F8>')
  call g:embrace#blinky_search#CreateMaps_ToggleHighlight('<CR>')
  call g:embrace#blinky_search#CreateMaps_SearchForward('<F3>')
  call g:embrace#blinky_search#CreateMaps_SearchBackward('<S-F3>')
  call g:embrace#blinky_search#CreateMaps_StarPound_VisualMode()
  call g:embrace#blinky_search#CreateMaps_ToggleMulticase('<LocalLeader>dc')
  call g:embrace#blinky_search#CreateMaps_ToggleStrict('<LocalLeader>ds')
endfunction

call s:CreateMaps__SearchCommands()

" ***

" Wire normal mode search commands to call `zz`.
call g:embrace#middle_matches#CreateMaps(['n', 'N', '*', '#', 'g*', 'g#'])

" ***

" Wire <C-h> to :nohlsearch
"
" BWARE: This map may conflict with mswin.vim's <C-h> binding (which opens
" the replace dialog, ":promptrepl\<CR>"). But if you're a true Vimmer,
" you probably replace using the |:s| substitute command. (The author uses
" mswin.vim to wire the familiar Cut, Copy, Paste and Save maps... though
" not that I couldn't just make a custom copy of mswin.vim, but I don't.)
" - If your Vimrc calls mswin.vim from a plugin/, this map will replace it.
" - But if your Vimrc calls mswin.vim from an after/plugin, there's no
"   telling if mswin.vim runs before this function call or not.
" - Fortunately, you can save and restore maps before and after
"   loading mswin.vim by using |maparg| to capture the maps first,
"   then recreating the map command and feeding it to |execute|.
" REFER: See dubs_edit_juice's `enable-behave-mswin.vim` if you want to
" see how to save and restore <C-H> (and <C-F>) after enabling mswin.vim:
"   https://github.com/landonb/dubs_edit_juice#🧃
"     https://github.com/landonb/dubs_edit_juice/blob/release/after/plugin/enable-behave-mswin.vim
" - See also mswin.vim itself:
"     /Applications/MacVim.app/Contents/Resources/vim/runtime/mswin.vim
"     /usr/share/vim/vim*/mswin.vim
call g:embrace#hide_highlights#CreateMaps('<C-h>')

