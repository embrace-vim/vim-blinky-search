" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Landon Bouma <https://tallybark.com/> 
" Project: https://github.com/landonb/vim-blinky-search#🕹
" License: GPLv3
" Copyright © 2015, 2017-2018, 2024 Landon Bouma.

" -------------------------------------------------------------------

" ------------------------------------------------------
" Ctrl-H Hides Highlighting
" ------------------------------------------------------

" Once you initiate a search, Vim highlights all matches.
" Type Ctrl-H to turn 'em off.

" Vim's default Ctrl-H is the same as <BS>.
" It's also the same as h, which is the
" same as <Left>. WE GET IT!! Ctrl-H won't
" be missed....
" NOTE: Highlighting is back next time you search.
" NOTE: Ctrl-H should toggle highlighting (not
"       just turn it off), but nohlsearch doesn't
"       work that way
" NOTE: Set this after calling `behave mswin`, which overrides C-h.

" (NEWB|NOTE: From Insert mode, Ctrl-o
"  is used to enter one command and
"  execute it. If it's a :colon
"  command, you'll need a <CR>, too.
"  Ctrl-c is used from command and
"  operator-pending modes.)

function! g:embrace#hide_highlights#CreateMaps(key_sequence = '<C-h>') abort
  " E.g., `noremap <C-h> :nohlsearch<CR>`
  execute 'nnoremap ' .. a:key_sequence .. ' :nohlsearch<CR>'
  execute 'inoremap ' .. a:key_sequence .. ' <C-O>:nohlsearch<CR>'
endfunction

