" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Landon Bouma <https://tallybark.com/> 
" Project: https://github.com/landonb/vim-blinky-search#🕹
" License: GPLv3
" Copyright © 2015, 2017-2018, 2024 Landon Bouma.

" -------------------------------------------------------------------

" -------------------------------------------------------------------------
" Automatically center curson on search
" -------------------------------------------------------------------------
"  [2018-06-11: Just created this. I am so behind the Vim-times!]

" You can `zz` after search commands to center the cursor, so your eye doesn't
" have to scan to see where where the cursor is. Also, if you have more than
" one search result highlighted in view, and if your syntax colors sometime
" make it difficult to see upon which highlight the cursor is situated, you
" can center the cursor to make it more obvious.

" ALTLY: Here's an interesting toggle idea.
" - If you :set scrolloff=999, it'll keep the cursor centered. But then
"   it applies continuously. I.e., the cursor will always be centered!
"   - Every `j`, `k`, <Up>, <Down>, etc., scrolls the window.
"
"  :nnoremap <Leader>zz :let &scrolloff=999-&scrolloff<CR>

" Append `zz`. For example, basically `nnoremap n nzz`.
" - Also append blink command. Note the Vim silent ignores a missing <Plug>.
function g:embrace#middle_matches#CreateMaps_AppendMiddling(cmd) abort
  let l:blink_after = ':execute "normal \<Plug>(blinky-search-after)"<CR>'

  execute 'nnoremap ' .. a:cmd .. ' ' .. a:cmd .. 'zz' .. l:blink_after
endfunction

function g:embrace#middle_matches#CreateMaps_AddMiddling(cmds) abort
  for l:cmd in a:cmds
    call g:embrace#middle_matches#CreateMaps_AppendMiddling(l:cmd)
  endfor
endfunction

" -------------------------------------------------------------------

function g:embrace#middle_matches#CreateMaps(cmds = []) abort
  let l:cmds = a:cmds

  " By default, add `zz` to each of the start new search commands,
  " and also to the next/prev search match commands.
  " - SAVVY: g* is like '*' but without \<word\> boundaries.
  "      And g# is like '#" (reverse-'*'), also boundaryless.
  if empty(l:cmds)
    let l:cmds = [
      \ 'n',
      \ 'N',
      \ '*',
      \ '#',
      \ 'g*',
      \ 'g#',
      \ ]
    endif

  call g:embrace#middle_matches#CreateMaps_AddMiddling(l:cmds)
endfunction

