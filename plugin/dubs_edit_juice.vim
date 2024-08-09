" File: dubs_edit_juice.vim
" Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
" Project Page: https://github.com/landonb/dubs_edit_juice
" Summary: EditPlus-inspired editing mappings
" License: GPLv3
" vim:tw=0:ts=2:sw=2:et:norl:
" -------------------------------------------------------------------
" Copyright © 2009, 2015-2023 Landon Bouma.
"
" This file is part of Dubs Vim.
"
" Dubs Vim is free software: you can redistribute it and/or
" modify it under the terms of the GNU General Public License
" as published by the Free Software Foundation, either version
" 3 of the License, or (at your option) any later version.
"
" Dubs Vim is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty
" of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
" the GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with Dubs Vim. If not, see <http://www.gnu.org/licenses/>
" or write Free Software Foundation, Inc., 51 Franklin Street,
"                     Fifth Floor, Boston, MA 02110-1301, USA.
" ===================================================================

" ------------------------------------------
" About:

" This script originally started to make Vim emulate
" EditPlus, but it's grown considerably since then to
" just make Vim a more comfortable editor all around.
"
" This file maps a bunch of editing-related features
" to key combinations to help delete text, select text,
" edit text, move the cursor around the buffer, and
" perform single-key text searches within the buffer.

" MEH: 2018-06-27: (lb): This file is not to be made reentrant (<F9>)
" very easily. We'd have to call hasmapto() a lot....
if exists("g:plugin_edit_juice_vim") || &cp
  finish
endif
let g:plugin_edit_juice_vim = 1

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Editing Features -- Deleting Text
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ------------------------------------------------------
" Recover from accidental Ctrl-U
" ------------------------------------------------------

" CXREF: http://vim.wikia.com/wiki/Recover_from_accidental_Ctrl-U
"
" SAVVY: <c-g>u starts a new Undo set, so the C-u and C-w commands can be undone.
"
" REFER:
"   :help i_CTRL-U Insert mode: <c-u> deletes text entered in the current line.
"   :help i_CTRL-W Insert mode: <c-w> deletes word before cursor.
"   :help i_CTRL-G_u Insert mode: <c-g> u starts a new change.
"   :help ins-special-special Insert mode: Commands which start a new change.
"   :help undo-break

inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>

" -------------------------------------------------------------------
" Wire Ctrl-Left/-Right to Jumping Cursor by Word
" -------------------------------------------------------------------

function! s:wire_keys_move_to_word_previous_and_next()
  nnoremap <C-Left> b
  inoremap <C-Left> <C-O>b
  " Don't vmap C-Left, or after C-S-Left it'll keep selecting without
  " Shift pressed anymore:
  "   vnoremap <C-Left> b

  " Note the <right> (or `l`), otherwise cursor ends up between last two chars.
  nnoremap <C-Right> el
  inoremap <C-Right> <C-O>e<Right>
  " Don't vmap C-Right, or after C-S-Right it'll keep selecting without
  " Shift pressed anymore:
  "   vnoremap <C-Right> e
endfunction

call <SID>wire_keys_move_to_word_previous_and_next()

" -------------------------------------------------------------------
" Wire Alt-Shift-Left/-Right to Selecting from Cursor to Edge of Line
" -------------------------------------------------------------------

function! s:wire_keys_select_text_to_line_beg_and_end()
  " Alt-Shift-Left selects from cursor to start of line
  " (same as Shift-Home)
  noremap <M-S-Left> v0<C-G>
  inoremap <M-S-Left> <C-O>v0<C-G>
  " 2020-05-23: I added <CTRL-G> to switch from Visual mode to Select mode,
  " otherwise if the user Ctrl-C copies, the selection is deselected, which
  " is abnormal behavior.
  " - Because this is a visual mode mapping, is it still needed?
  vnoremap <M-S-Left> 0

  " Alt-Shift-Right selects from cursor to end of line
  " (same as Shift-End)
  noremap <M-S-Right> v$<C-G>
  inoremap <M-S-Right> <C-O>v$<C-G>
  vnoremap <M-S-Right> $
endfunction

call <SID>wire_keys_select_text_to_line_beg_and_end()

" ---------------------------------------------------------------------------
" Wire Ctrl-Shift-PageUp/-PageDown to Selecting from Cursor to Edge of Window
" ---------------------------------------------------------------------------

function! s:wire_keys_select_lines_to_window_first_and_last()
  " Much like Ctrl-PageUp and Ctrl-PageDown move the cursor to the top of
  " the window or to the bottom of the window, respectively, without changing
  " the view, Ctrl-Shift-PageUp and Ctrl-Shift-PageDown select text from the
  " cursor to the top or bottom of the window without shifting the view.

  " Ctrl-Shift-PageUp selects from cursor to first line of window
  noremap <C-S-PageUp> vH
  inoremap <C-S-PageUp> <C-O>vH
  cnoremap <C-S-PageUp> <C-C>vH
  onoremap <C-S-PageUp> <C-C>vH
  vnoremap <C-S-PageUp> H

  " Ctrl-Shift-PageDown selects from cursor to last line of window
  noremap <C-S-PageDown> vL
  inoremap <C-S-PageDown> <C-O>vL
  cnoremap <C-S-PageDown> <C-C>vL
  onoremap <C-S-PageDown> <C-C>vL
  vnoremap <C-S-PageDown> L
endfunction

call <SID>wire_keys_select_lines_to_window_first_and_last()

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Document Navigation -- Moving the Cursor
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ------------------------------------------------------
" Sane Scrolling
" ------------------------------------------------------

" Map Ctrl-Up and Ctrl-Down to scrolling
" the window 'in the buffer', as the :help
" states. Really, it just moves the scrollbar,
" i.e., scrolls your view without moving your
" cursor.
function! s:wire_keys_scroll_window_sticky_cursor()
  " 2018-09-17/EXPLAIN: What's the magic that maps <C-y> to
  " scroll window upward, as opposed to Redo (which Dubs maps
  " to <C-y> at some point)? Is it down to load order?
  noremap <C-Up> <C-y>
  inoremap <C-Up> <C-O><C-y>
  cnoremap <C-Up> <C-C><C-y>
  onoremap <C-Up> <C-C><C-y>
  noremap <C-Down> <C-e>
  inoremap <C-Down> <C-O><C-e>
  cnoremap <C-Down> <C-C><C-e>
  onoremap <C-Down> <C-C><C-e>
endfunction

call <SID>wire_keys_scroll_window_sticky_cursor()

" ------------------------------------------------------
" Quick Cursor Jumping
" ------------------------------------------------------

function! s:Smart_PageUpDown(direction)
  let cursor_cur_line = line(".")
  if a:direction == 1
    let window_first_line = line("w0")
    if cursor_cur_line == window_first_line
      " Cursor on first visible line; scroll window one page up
      execute "normal! \<C-B>"
    endif
    " Move cursor to first visible line; make
    " sure it's in the first column, too
    execute 'normal H0'
  elseif a:direction == -1
    let window_last_line = line("w$")
    if cursor_cur_line == window_last_line
      " Cursor on last visible line; scroll window one page down
      execute "normal! \<C-F>"
    endif
    " Move cursor to last visible line; make
    " sure it's in the first column, too
    execute 'normal L0'
  else
    call confirm('EditPlus.vim: Programmer Error!', 'OK')
  endif
endfunction

" -------

" - EditPlus, among other editors, maps Ctrl-PageUp and Ctrl-PageDown to moving the
"   cursor to the top and bottom of the window (equivalent to H and L in Vim (which
"   also defines M to jump to the middle of the window, which is not mapped here)).
" - Note, too, that in some programs, C-PageUp/Down switches to the next/previous
"   tab/pane/window. In Dubs Vim, you can prev/next windows with Ctrl-Shift-Up/Down,
"   and you can prev/next tabs with Alt-Shift-Up/Down.
function! s:wire_keys_cursor_to_line_first_and_last()
  " Ctrl-PageUp moves cursor to the top of the window, or, if
  " it's already there, it scrolls up one viewable-window-full.
  noremap <C-PageUp> :call <SID>Smart_PageUpDown(1)<CR>
  inoremap <C-PageUp> <C-O>:call <SID>Smart_PageUpDown(1)<CR>
  " Ctrl-PageDown moves cursor to the bottom of the window, or, if
  " it's already there, it scrolls down one viewable-window-full.
  noremap <C-PageDown> :call <SID>Smart_PageUpDown(-1)<CR>
  inoremap <C-PageDown> <C-O>:call <SID>Smart_PageUpDown(-1)<CR>
endfunction

call <SID>wire_keys_cursor_to_line_first_and_last()

" -------

" On my laptop, my right hand spends a lot of time near
" (and using) the arrow keys, which are on the bottom
" of the keyboard, but the other navigation keys (home,
" end, page up and down and the ilk) are far, far away,
" at the top of the keyboard. But we can map those to
" Alt-Arrow Key combinations to make our hands happy
" (or is it to make our fingers frolicsome?).

" 2020-05-23: See long comment in wire_keys_jump_to_window_directionally:
" the fifteen seconds I tried to move Alt-Left/-Right to other keys, so
" that I could wire all Alt-Arrow keys to tmux-esque window pane switching.
" It was a disaster. These two motions, Alt-Left and Alt-Right, are hardwired
" in my brain. I use 'em all the time.

" SAVVY/2024-05-07: gvy: `gv` reselects the previous Visual area; `y` yanks.

function! s:add_alt_left_alt_right_maps_move_cursor_to_line_beg_line_end()
  " Alt-Left moves the cursor to the beginning of the line.
  noremap <M-Left> <Home>
  inoremap <M-Left> <C-O><Home>
  vnoremap <M-Left> :<C-U> <CR>gvy :execute "normal! 0"<CR>
  " Alt-Right moves the cursor to the end of the line.
  noremap <M-Right> <End>
  inoremap <M-Right> <C-O><End>
  vnoremap <M-Right> :<C-U> <CR>gvy :execute "normal! $"<CR>
endfunction

call <SID>add_alt_left_alt_right_maps_move_cursor_to_line_beg_line_end()

" For macOS Parity (where <Cmd-Left>/<Cmd-Right> move cursor to line start/end).
function! s:add_cmd_left_cmd_right_maps_move_cursor_to_line_beg_line_end()
  " Cmd-Left moves the cursor to the beginning of the line.
  noremap <D-Left> <Home>
  inoremap <D-Left> <C-O><Home>
  vnoremap <D-Left> :<C-U> <CR>gvy :execute "normal! 0"<CR>
  " Cmd-Right moves the cursor to the end of the line.
  noremap <D-Right> <End>
  inoremap <D-Right> <C-O><End>
  vnoremap <D-Right> :<C-U> <CR>gvy :execute "normal! $"<CR>
endfunction

call <SID>add_cmd_left_cmd_right_maps_move_cursor_to_line_beg_line_end()

" -------

" 2011.01.16 Will I find this useful?
" 2020-02-08: Hahahaha, if I'd even remember to use it!
"             - I like it! Like pressing 'M' and then 'i'.
"
" Alt-F12 moves the cursor to the middle of the window,
" and starts editing.
"
" - This was mapped to Alt-End, but that did not feel right,
"   e.g.,
"
"     noremap <M-End> M0i
"     inoremap <M-End> <C-O>M<C-O>0
"     vnoremap <M-End> :<C-U>
"       \ <CR>gvy
"       \ :execute "normal! M0"<CR>
"
function! s:wire_key_insert_mode_middle_line()
  noremap <M-F12> M0i
  inoremap <M-F12> <C-O>M<C-O>0
  vnoremap <M-F12> :<C-U>
    \ <CR>gvy
    \ :execute "normal! M0"<CR>
endfunction

call <SID>wire_key_insert_mode_middle_line()

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Document Navigation -- Searching Within a Buffer
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ------------------------------------------------------
" Start a(n advanced) *-search w/ simply F1
" ------------------------------------------------------

" A Vim star search (search for the stars!) searches
" the word under the cursor- but only the word under
" the cursor! It doesn't not search abbreviations. So
" star-searching, say, "item" wouldn't also match
" "item_set" or "item_get". Since the latter is sometimes
" nice, and since we already have a star search mapping,
" let's map F1 to a more liberal star search. Maybe you
" want to a call it a b-star search, as in, B Movie star-
" you'll still be star-searching, you'll just get a lot
" more hits.

" Select current word under cursor
" The hard way:
"   b goes to start of word,
"   "zyw yanks into the z register to start of next word
" :map <F1> b"zyw:echo "h ".@z.""
" The easy way: (see also: :help c_CTRL-R):
"  (if this selects more characters than you want, see :set iskeyword)
noremap <F1> /<C-R><C-W><CR>
inoremap <F1> <C-O>/<C-R><C-W><CR>
" SAVVY: Note that normal and insert mode <F1> searches the Word under
"        the cursor (inserted be <C-R><C-W>). It doesn't include path
"        characters (like, say, <C-R><C-A> to insert the WORD under the
"        cursor, or <C-R><C-F> the Filename under the cursor).
"        - Because we know the user has not *typed* the query themselves,
"          we can insert escape characters so that if the selection
"          contains forward-slases, they don't break the search (if left
"          unescaped, the search still works, but the query won't match
"          past the first unescaped forward slash).
"        - Here's that basic approach used for eons in this code:
"            /<C-R>"<CR>
" USYNC: <F3> vnoremap is the same
vnoremap <F1> :<C-U>
  \ <CR>gvy
  \ gV
  \ /<C-R>=substitute("<C-R>"", "/", "\\\\/", "g")<CR><CR>

" ------------------------------------------------------
" Cased Transforms! [DRY: This code was copy-pasted! because (lb) Lazy!]
" ------------------------------------------------------

" ***

" STOLEN! From vim-abolish. Shameless!!
" FIXME/2018-06-27/DRY: Make a util plugin for this!
"   These are duplicated in: vim-aboilsh; dubs_grep_steady; dubs_edit_juice

function! s:camelcase(word)
  let word = substitute(a:word, '-', '_', 'g')
  if word !~# '_' && word =~# '\l'
    return substitute(word,'^.','\l&','')
  else
    return substitute(word,'\C\(_\)\=\(.\)','\=submatch(1)==""?tolower(submatch(2)) : toupper(submatch(2))','g')
  endif
endfunction

function! s:snakecase(word)
  let word = substitute(a:word,'::','/','g')
  let word = substitute(word,'\(\u\+\)\(\u\l\)','\1_\2','g')
  let word = substitute(word,'\(\l\|\d\)\(\u\)','\1_\2','g')
  let word = substitute(word,'[.-]','_','g')
  let word = tolower(word)
  return word
endfunction

" A/k/a kebab-case | spinal-case | Train-Case | Lisp-case | dash-case
function! s:traincase(word)
  return substitute(s:snakecase(a:word),'_','-','g')
endfunction

function! s:uppercase(word)
  return toupper(s:snakecase(a:word))
endfunction

" ***

" ------------------------------------------------------
" Start a whole-word *-search w/ Shift-F1
" ------------------------------------------------------

" 2013.02.28: This used to be C-F3 but that's not an easy keystroke.
"             S-F1 is easier.
" Search for the whole-word under the cursor, but return
" to the word under the cursor. <F1> alone starts searching,
" but sometimes you want to highlight whole-words without
" losing your position.
" NOTE: The ? command returns to the previous hit, where the cursor
"       was before * moved it.
" on onto bontop
noremap <S-F1> *?<CR>
inoremap <S-F1> <C-O>*<C-O>?<CR>
" NOTE When text selected, S-F1 same as plain-ole S-F1 and
"      ignores whole-word-ness.
" FIXME: The ? returns the cursor but the page is still scrolled.
"        So often the selected word and cursor are the first line
"        in the editor.
vnoremap <S-F1> :<C-U>
  \ <CR>gvy
  \ gV
  \ /<C-R>=substitute("<C-R>"", "/", "\\\\/", "g")<CR><CR>
  \ ?<CR>

" 2017-11-12: A similar approach to the same feature.
"   http://vim.wikia.com/wiki/Highlight_all_search_pattern_matches
function! InstallStartSearchHighlightButLeaveCursor()

  " (lb): This is from original Vim tip, but doesn't work for me:
  nnoremap <F8> :let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR>:set hls<CR>
  " This is from comments at bottom of article, but did not work for me:
  "   nnoremap <F8> :let curwd='\\\<<C-R>=expand("<cword>")<CR>\\\>'<CR>
  "     \ :let @/=curwd<CR>:call histadd("search", curwd)<CR>:set hls<CR>

  " (lb): I added this simple insert mode complement to the normal mode implementation.
  inoremap <F8> <C-O>:let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR><C-O>:set hls<CR>

  " MEH? 2018-06-27: <F8> is almost the same as [ENTER],
  " which is mapped after this function.

  function! MakePattern(text)
    " 2018-06-27: Heh? Why am I doing here? Escaping `\` in search queries?
    " DRY: This is shared with dubs_grep_steady/dubs_edit_juice.
    let l:pat = escape(a:text, '\')
    let l:pat = substitute(l:pat, '\_s\+$', '\\s\\*', '')
    let l:pat = substitute(l:pat, '^\_s\+', '\\s\\*', '')
    let l:pat = substitute(l:pat, '\_s\+',  '\\_s\\+', 'g')

    call histadd("/", l:pat)
    call histadd("input", l:pat)

    let l:pat = '\\V' . escape(l:pat, '\"')
    return l:pat
  endfunction

  " Assign the pattern to the search register (@/), and to set 'hlsearch'/'hls.
  vnoremap <silent> <F8> :<C-U>let @/="<C-R>=MakePattern(@*)<CR>"<CR>:set hls<CR>

endfunction
call InstallStartSearchHighlightButLeaveCursor()

" NOTE: Adding the 'a' guioptions option was suggested by previous function's inspiration
"         http://vim.wikia.com/wiki/Highlight_all_search_pattern_matches
"       but I'm not sure I don't think it's necessary for previous function.
"       Makes me wonder why it's in the Vim tip, maybe just a nice complement.
function! YankSelectedTextAutomatically_ExceptOnmacOS()
  " Automatically copy text when (visually) selected w/ guioptions `a` flag.
  " - When text is selected, it is yanked into register *.
  " - Note that on macOS, this copies into the system clipboard,
  "   unlike on Linux, so we don't enable this on Mac.
  if !has('macunix')
    set guioptions+=a
  endif
endfunction
call YankSelectedTextAutomatically_ExceptOnmacOS()

" Make [Enter] toggle highlighting for the current word on and off.
" Also from:
"   http://vim.wikia.com/wiki/Highlight_all_search_pattern_matches
" This breaks quickfix enter-to-open... [2018-06-27: I wrote this recently,
" 2017-11-13, but why didn't I think to check if quickfix window? Duh.]
function! InstallHighlightOnEnter()
  " 2018-06-27 10:27: This is not so bad. Pressing ENTER toggle highlight
  " of word-under-cursor (making that word the search term).
  let g:highlighting = 0
  function! Highlighting()
    " 2018-06-27: This function is back, baby!
    if &ft == 'qf'
      return 0
    endif

    let l:the_term = expand('<cword>')

    " 2018-06-27: Whoa, how did I not know about histadd??!
    "  Add the word-under-cursor to the search history.
    call histadd("/", l:the_term)
    let l:term_search_buffer = '\<'.l:the_term.'\>'
    call histadd("/", l:term_search_buffer)
    " Also add to the input history, so it's available from
    " the `\g` grep search feature input history. E.g., user
    " might initiate search in buffer and then decide to grep
    " all files; having the term in the input history means
    " they don't have to F4 on top of the work or to enter it
    " manually.
    call histadd("input", l:the_term)
    " Add the word-restricted form last.
    call histadd("input", '\b'.l:the_term.'\b')

    " 2018-06-27 11:10: Is this overkill? Search all the case varietals.
    " DRY: See also g:DubsGrepSteady_GrepAllTheCases and GrepPrompt_Simple().
    " Search on 3 casings: Camel, Snake, and Train.
    " NOTE: Converting to snakecase downcases it.
    let l:cased_search = ''
      \ . tolower(s:camelcase(l:the_term)) . "\\|"
      \ . tolower(s:snakecase(l:the_term)) . "\\|"
      \ . tolower(s:traincase(l:the_term))
    let l:cased_search_buffer = '\<\('.l:cased_search.'\)\>'
    let l:cased_search_grepprg = '\b('.l:cased_search.')\b'
    call histadd("/", l:cased_search_buffer)
    call histadd("input", l:cased_search_grepprg)
    " Test it! Try these: testMe test_me test-me test-me-not testMeNot test_me_NOT testme
    "   For \g testing (one test term per line):
    "     testMe
    "     test_me
    "     test-me
    "     test-me-not
    "     testMeNot
    "     test_me_NOT
    "     testme

    "if g:highlighting == 1 && @/ =~ '^\\<'.l:the_term.'\\>$'
    if g:highlighting == 1 && @/ =~ '^\\<\\('.l:cased_search.'\\)\\>$'
      let g:highlighting = 0
      return ":silent nohlsearch\<CR>"
    endif
    "let @/ = l:term_search_buffer
    let @/ = l:cased_search_buffer
    let g:highlighting = 1
    return ":silent set hlsearch\<CR>"
  endfunction
  " NOTE: This overrides Vim's built-in <CR> and <Ctrl-m>/<C-m>
  "       ([count] lines downward).
  " NOTE: Even though we don't touch Ctrl-m here, it follows <CR>.
  "       That is, Ctrl-m will not move the cursor [count] lines downward,
  "       but will instead toggle highlighting of the word under the cursor,
  "       just like <CR>.
  nnoremap <silent> <expr> <CR> Highlighting()
endfunction
call InstallHighlightOnEnter()

" Repeat previous search fwd or back w/ F3 and Shift-F3
" NOTE Using /<CR> instead of n because n repeats the last / or *
noremap <F3> /<CR>
inoremap <F3> <C-O>/<CR>
" To cancel any selection, use <ESC>, but also use gV to prevent automatic
" reselection. The 'n' is our normal n.
" FIXME If you have something selected, maybe don't 'n' but search selected
"       text instead?
"vnoremap <F3> <ESC>gVn
" NOTE The gV comes before the search, else the cursor ends up at the second
"      character at the next search word that matches
" USYNC: Same map as <F1>, tho <S-F3> slightly different than <S-F1>.
vnoremap <F3> :<C-U>
  \ <CR>gvy
  \ gV
  \ /<C-R>=substitute("<C-R>"", "/", "\\\\/", "g")<CR><CR>

" Backwards:
noremap <S-F3> ?<CR>
inoremap <S-F3> <C-O>?<CR>
"vnoremap <S-F3> <ESC>gVN
" Remember, ? is the opposite of /
vnoremap <S-F3> :<C-U>
  \ <CR>gvy
  \ gV
  \ ?<C-R>=substitute("<C-R>"", "/", "\\\\/", "g")<CR><CR>?<CR>

" Find next/previous (Deprecated Approach)
" --------------------------------
" Map F3 and Shift-F3 to find next/previous
""map <F3> n
""map <F3> *
"noremap <F3> *
"inoremap <F3> <C-O>*
""cnoremap <F3> :<C-R><C-W>*
""onoremap <F3> :<C-R><C-W>*
""map <S-F3> N
""map <S-F3> #
"noremap <S-F3> #
"inoremap <S-F3> <C-O>#
""cnoremap <S-F3> <C-O>#
""onoremap <S-F3> <C-O>#
"" Start a *-search w/ Ctrl-F3
""map <C-F3> *

" ------------------------------------------------------
" VSearch
" ------------------------------------------------------

" This function is based on Vim Tip 171
"   Search for visually selected text
"  http://vim.wikia.com/wiki/Search_for_visually_selected_text
"
" This complements the built-in '*' and '#' commands
" by enabling the same features in select mode.

" The Simple, Les Functional Implementation
" -----------------------------------------
"  " Search for selected text, forwards or backwards.
"vnoremap <silent> * :<C-U>
"  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
"  \gvy/<C-R><C-R>=substitute(
"  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
"  \gV:call setreg('"', old_reg, old_regtype)<CR>
"vnoremap <silent> # :<C-U>
"  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
"  \gvy?<C-R><C-R>=substitute(
"  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
"  \gV:call setreg('"', old_reg, old_regtype)<CR>

" Search for selected text.
" http://vim.wikia.com/wiki/VimTip171
let s:save_cpo = &cpo | set cpo&vim
if !exists('g:VeryLiteral')
  let g:VeryLiteral = 0
endif

function! s:VSetSearch(cmd)
  let old_reg = getreg('"')
  let old_regtype = getregtype('"')
  normal! gvy
  if @@ =~? '^[0-9a-z,_]*$' || @@ =~? '^[0-9a-z ,_]*$' && g:VeryLiteral
    let @/ = @@
  else
    let pat = escape(@@, a:cmd.'\')
    if g:VeryLiteral
      let pat = substitute(pat, '\n', '\\n', 'g')
    else
      let pat = substitute(pat, '^\_s\+', '\\s\\+', '')
      let pat = substitute(pat, '\_s\+$', '\\s\\*', '')
      let pat = substitute(pat, '\_s\+', '\\_s\\+', 'g')
    endif
    let @/ = '\V'.pat
  endif
  normal! gV
  call setreg('"', old_reg, old_regtype)
endfunction

" Pressing '*' will search for exact word under cursor.
vnoremap <silent> * :<C-U>call <SID>VSetSearch('/')<CR>/<C-R>/<CR>
" Pressing '#' will search backwards for exact word under cursor.
vnoremap <silent> # :<C-U>call <SID>VSetSearch('?')<CR>?<C-R>/<CR>
vmap <kMultiply> *

" 2017-03-28: I swapped the order of the nmap and the !hasmapto...
"  nmap <silent> <Plug>DubsEditJuice_VLToggle :let g:VeryLiteral = !g:VeryLiteral
"    \\| echo "VeryLiteral " . (g:VeryLiteral ? "On" : "Off")<CR>
"  if !hasmapto("<Plug>DubsEditJuice_VLToggle")
"    nmap <unique> <Leader>vl <Plug>DubsEditJuice_VLToggle
"  endif
"
if !hasmapto("<Plug>DubsEditJuice_VLToggle")
  nmap <unique> <Leader>vl <Plug>DubsEditJuice_VLToggle
endif
noremap <silent> <Plug>DubsEditJuice_VLToggle :let g:VeryLiteral = !g:VeryLiteral
  \\| echo "VeryLiteral " . (g:VeryLiteral ? "On" : "Off")<CR>
let &cpo = s:save_cpo | unlet s:save_cpo

" ------------------------------------------------------
" Map <Leader>tab to Toggling Tab Highlighting
" ------------------------------------------------------

if !hasmapto('<Plug>DubsEditJuice_ToggleTabHighlighting')
  map <silent> <unique> <Leader>tab
    \ <Plug>DubsEditJuice_ToggleTabHighlighting
endif
" Map <Plug> to an <SID> function.
noremap <silent> <unique> <script>
  \ <Plug>DubsEditJuice_ToggleTabHighlighting
  \ :call <SID>ToggleTabHighlighting()<CR>
" The function.
function! s:ToggleTabHighlighting()
  " Visualizing tabs <http://tedlogan.com/techblog3.html>
  " "So what do you do when you open a new source file and you're trying
  "  to figure out what tab style the last author used? (And how do you make
  "  sure you're doing the Right Thing to avoid mixing tab styles in your new
  "  code intermixed with the old code?) I find syntax highlighting useful. In
  "  gvim, I like seeing my tabs with underlines. (This tends not to work well
  "  on the text terminal for reasons I haven't been able to determine.) The
  "  following incantation will tell vim to match tabs, underline them in gvim,
  "  and highlight them in blue in color terminals."
  "
  " Should this be s:variable or a b:variable?
  if !exists('b:cyclopath_tab_toggle_index')
    let b:cyclopath_tab_toggle_index = 0
  else
    let b:cyclopath_tab_toggle_index = b:cyclopath_tab_toggle_index + 1
    if (b:cyclopath_tab_toggle_index > 1)
      let b:cyclopath_tab_toggle_index = 0
    endif
  endif
  if (0 == b:cyclopath_tab_toggle_index)
    highlight Tab gui=underline guifg=blue ctermbg=blue
    match Tab /\t/
    echo "Tab highlighing enabled"
  elseif (1 == b:cyclopath_tab_toggle_index)
    match none
    echo "Tab highlighing disabled"
  else
    call confirm('Cyclopath.vim: Programmer Error!', 'OK')
  endif
endfunction

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Obsolete Functions
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ------------------------------------------------------
" Count of Characters Selected
" ------------------------------------------------------

" NOTE I'm using Ctrl-# for now. It hurts my fingers to
"      combine such keys, but I don't use this command
"      that often and using the pound key seems intuitive.
" FIXME Make this work on word-under-cursor
" NOTE Cannot get this to work on <C-3>, so using Alt instead
"vnoremap <M-3> :<C-U>
"  \ :.s/\S/&/g<CR>
"  \ :'<,'>s/./&/g<CR>

"vnoremap <M-3> :<C-U>
"  \ <CR>gvy
"  \ gV
"  \ g<C-G>

"noremap <Leader>k :g<C-G>
":noremap <Leader>k "sy:.,$s/<C-r>s//gc<Left><Left><Left>
":noremap <Leader>k g<C-G>

" DO THIS INSTEAD:
" I couldn't get the previous to work, so just do this:
"  Select your text, type <Ctrl-o>, then g<Ctrl-g>

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Editing Features -- Editing Text
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ------------------------------------------------------
" Correct Ctrl-Z While Text Selected
" ------------------------------------------------------

" Ctrl-Z is mapped to undo in Normal and Insert
" mode, but in Select mode it just lowercases
" what's selected!
" NOTE To lowercase in Select mode, type
"      <Ctrl-o> to start a command, then type
"        gu{motion},
"      e.g.,
"        <C-o>gu<DOWN>
"      (or <C-o>gu<UP>, it does the same thing).
"      (And guess what? gU uppercases.)
" HINT You can also select text, and then <C-O>U or <C-O>u
"      to uppercase or lowercase the selected text.
" HELP: To get help on <C-u>, in command mode (following the colon), try:
"          h c_CTRL-u
vnoremap <C-Z> :<C-U>
  \ :undo<CR>
vnoremap <C-Y> :<C-U>
  \ :redo<CR>

" NOTE For whatever reason, trying to map C-S-Z also remaps
"      C-Z, so I can't make Ctrl-Shift-Z into redo!
" Doesn't work: noremap <C-S-Z> :redo<CR>
" 2015.01.14: Experience shows that the Ctrl-[a-z] key mappings
"             are case insensitive... oh, well, too bad for us.

" ------------------------------------------------------
" Character Transposition
" ------------------------------------------------------

" Transpose two characters when in Insert mode
" NOTE We can't just 'Xp' and be all happy --
"      rather, if we're at the first column
"      (start) of the line, 'Xp' does something
"      completely different. So use 'Xp' if the
"      cursor is anywhere but the first column,
"      but use 'xp' otherwise.
function! s:TransposeCharacters()
  let cursorCol = col('.')
  if 1 == cursorCol
    execute 'normal ' . 'xp'
  else
    execute 'normal ' . 'Xp'
  endif
endfunction

" BWARE: This steals Vim's built-in i_CTRL-T, which inserts 'one shiftwidth of
"        indent'. But this plugin relocates that command to <Shift-Ctrl-D>, which
"        by default does the same as <C-D> and deletes 'one shiftwidth of indent'.
"        - Stock Vim: i_CTRL-T indents, and i_CTRL-D (and i_CTRL-SHIFT-D) dedents.
"        - Dubs Vim: i_CTRL-T transposes; i_CTRL-D dedents; and i_CTRL-SHIFT-D indents.

" SAVVY: This binding findable via `:TabMessage imap`, but not `:TabMessage map`.

inoremap <M-t> <C-o>:call <SID>TransposeCharacters()<CR>

" NOTE Make a mapping for normal mode --
"      but this obscures the original Ctrl-T
"      command, which inserts a tab at the
"      beginning of the line; see :help Ctrl-t

" ------------------------------------------------------
" Indent Selected Text
" ------------------------------------------------------

" Vim's <Tab> is used to move the cursor
" according to the jump list, but it's silly.
" I.e., in Insert mode, if you have nothing
" selected, <Tab> does what? Inserts a <Tab>.
" What happens if you have text selected?
" And I mean besides entering visual edit mode?
" My computer rings the bell and the Vim window
" does a quiet beep (so... nothing!).
"
" Thusly, use Tab/Shift-Tab to add/remove indents
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
" NOTE Also remember that == smartly fixes
"      the indent of the line-under-cursor

" REFER/2024-05-07: See Vim's built-in i_CTRL-D and i_CTRL-T
" - i_CTRL-D dedents and i_CTRL-T indents by default.
"   - There is no i_CTRL-SHIFT-D to dedent (it indents).
" - Above, Dubs reassigns i_CTRL-T to transpose characters.
" - Here, Dubs rebinds dedent to i_CTRL-SHIFT-D (so it complements <C-D>).
"
" SAVVY- This naive approach works, but it either moves the cursor to the first
" non-blank character (:set startofline); or it keeps the cursor position which
" changes relative to the text as you indent (:set nostartofline):
" 
"   inoremap <S-C-D> <C-O>:normal >><CR>
"
" REFER- Fortunately I found copy-pasta:
"   https://vi.stackexchange.com/questions/18310/keep-relative-cursor-position-after-indenting-with
func! CursorFriendlyIndent(ind)
  if &sol
    set nostartofline
  endif
  let vcol = virtcol('.')
  if a:ind
    norm! >>
    exe "norm!". (vcol + shiftwidth()) . '|'
  else
    norm! <<
    exe "norm!". (vcol - shiftwidth()) . '|'
  endif
endfunc
"
inoremap <S-C-D> <C-O>:call CursorFriendlyIndent(1)<CR>
" Not necessary (builtin <C-D> behaves the same):
inoremap <C-D> <C-O>:call CursorFriendlyIndent(0)<CR>
"
" But we can 'enchance' built-in << and >>:
nnoremap >> :call CursorFriendlyIndent(1)<cr>
nnoremap << :call CursorFriendlyIndent(0)<cr>
"
" Visual mode is easy, because cursor position doesn't matter.
vnoremap <S-C-D> >gv

" Note that built-in normal mode CTRL-D Scrolls window Downwards
" (and CTRL-U Upwards).
" - Author mostly scrolls using PgDown and PgUp, as I'm sure lots of folx,
"   do, though sometimes I use <C-D> to scroll when my right hand is busy.
" - Dubs Vim reassigns CTRL-U to moving paragraph up (and CTRL-P down).
"   - This sorta leave normal CTRL-D all alone, i.e., there's no matching
"     binding to scroll up.
" - However, <S-C-D> by default is same as <C-D>.
"   - So we can assign scroll up to <S-C-D>.
"   - And then we can say that while Dubs changes the <C-U> binding, it at
"     least reassigns the original command to a different binding. So in
"     the end, no original command is left unbound, they've just been moved.
nnoremap <S-C-D> <C-U><CR>

" Make visual mode <C-D> work like built-in i_CTRL-D: dedent the selection.
" - Default visual mode <C-D> more like normal mode <C-D>: it scrolls
"   downward (and extends the selection).
"   - This strikes the author as counterintuitive. I generally expect
"     visual mode bindings to behave like their insert mode counterparts.
"     I.e., I'd except <C-D> to dedent the selection; so we do that here.
vnoremap <C-D> <gv

" ------------------------------------------------------
" Ctrl-P/Ctrl-L Moves Paragraphs
" ------------------------------------------------------

" 2012.08.19: Move paragraphs up and down, like how that
"             one popular app lets you move notes around.
" - DUNNO/2024-05-08: Lost to the ages: Which 'popular' app?

" Move the paragraph under the cursor up a paragraph.
function! s:MoveParagraphUp()
  " The '.' is the current cursor position.
  let lineno = line('.')
  if lineno != 1
    let a_reg = @a
    " The basic command is: {"ad}{"aP
    " i.e., move the start-of-paragraph:    {
    "       yank to the 'a' register:       "a
    "       delete to the end-of-paragraph: d}
    "       move up a paragraph:            {
    "       paste from the 'a' register:    "aP
    "       move down a line:               j
    "        (becase the '{' and '}' cmds
    "         go the line above or below
    "         the paragraph)
    normal! {"ad}{"aPj
    let @a = a_reg
  endif
endfunction

" Move the paragraph under the cursor down a paragraph.
function! s:MoveParagraphDown()
  " The '.' is the current cursor position.
  let line_1 = line('.')
  " The '$' is the last line in the current buffer.
  " So don't do anything unless not the last line.
  let line_n = line('$')
  if line_1 != line_n
    let a_reg = @a
    " Go to top of paragraph:               {
    " yank and delete to the EOP:           a"d}
    " drop down another paragraph:          }
    " paste the yanked buffer:              "aP
    " move to the end of the paragraph:     }
    " move to the SOP (somehow this works): {
    " move down a line to be at SOP:        j
    normal! {"ad}}"aP}{j
    let @a = a_reg
  endif
endfunction

" Default Vim makes <Up> and <CTRL-P> map to [count] lines upward |linewise|.
" Default Vim makes <CTRL-O> Go to [count] Older cursor posit in jump list.
" Default Vim makes <CTRL-O> in insert mode start a replace operation...
" Default Vim makes <CTRL-U> "Scroll window Upwards in the buffer."
"
" 2017-06-07: I want to use Ctrl-l for what was Ctrl-k (BufferRingForward) so
"   that Ctrl-k can be used for :digraph insertions.
"noremap <C-p> :call <sid>MoveParagraphUp()<CR>
"inoremap <C-p> <C-O>:call <sid>MoveParagraphUp()<CR>
"cnoremap <C-p> <C-C>:call <sid>MoveParagraphUp()<CR>
"onoremap <C-p> <C-C>:call <sid>MoveParagraphUp()<CR>
"noremap <C-l> :call <sid>MoveParagraphDown()<CR>
"inoremap <C-l> <C-O>:call <sid>MoveParagraphDown()<CR>
"cnoremap <C-l> <C-C>:call <sid>MoveParagraphDown()<CR>
"onoremap <C-l> <C-C>:call <sid>MoveParagraphDown()<CR>
"
" 2017-06-10: I was fiddling with the existing Ctrl-j and Ctrl-k mappings,
" for :BufferRingReverse and :BufferRingForward, and remapped these so that
" I could use <Ctrl-l> to replace Vim's built-in <Ctrl-k> :digraph feature.
noremap <C-u> :call <sid>MoveParagraphUp()<CR>
inoremap <C-u> <C-O>:call <sid>MoveParagraphUp()<CR>
cnoremap <C-u> <C-C>:call <sid>MoveParagraphUp()<CR>
onoremap <C-u> <C-C>:call <sid>MoveParagraphUp()<CR>
" Crud. Remapping <C-i> also remaps <TAB>, da fuh!?
"noremap <C-i> :call <sid>MoveParagraphDown()<CR>
"inoremap <C-i> <C-O>:call <sid>MoveParagraphDown()<CR>
"cnoremap <C-i> <C-C>:call <sid>MoveParagraphDown()<CR>
"onoremap <C-i> <C-C>:call <sid>MoveParagraphDown()<CR>
" 2017-10-17: Crud again. Ctrl-p blocks the auto-complete ctrl-n/ctrl-p...
"   :TabMessage map <c-p>
"   o  <C-P>       * <C-C>:call <SNR>28_MoveParagraphDown()<CR>
"   nv <C-P>       * :call <SNR>28_MoveParagraphDown()<CR>
" Normally, it's:
"   n  <C-P>       * :<C-U>CtrlP<CR>
noremap <C-p> :call <sid>MoveParagraphDown()<CR>
cnoremap <C-p> <C-C>:call <sid>MoveParagraphDown()<CR>
onoremap <C-p> <C-C>:call <sid>MoveParagraphDown()<CR>
"inoremap <C-p> <C-O>:call <sid>MoveParagraphDown()<CR>
" Without the insert mode blocker, it works.
" Not sure how to see the old mapping, though...
"   o  <C-P>       * <C-C>:call <SNR>28_MoveParagraphDown()<CR>
"   nv <C-P>       * :call <SNR>28_MoveParagraphDown()<CR>
" And trying to map it myself isn't working, e.g.:
"   inoremap <C-p> <C-O>:<C-U>CtrlP<CR>
" though CtrlP seems like the other CtrlP, the "Full path fuzzy
" file buffer, mru, tag, ... finder with an intuitive interface."

" ------------------------------------------------------
" Auto-format selected rows of text
" ------------------------------------------------------

" Select the lines you want to reformat into a pretty paragraph and hit F2.
" NOTE If you select whole lines, back up the cursor one character so the
"      final line isn't selected. Otherwise, par doesn't prepend your new
"      lines with the common comment from each line, since the last line
"      appears as an empty line and its beginning doesn't match the other
"      lines' beginnings, so par doesn't do any prepending.
" NOTE A blog I found online suggests you can use the following command:
"        map <F2> {!}par w81
"      But I couldn't get this to work.
"      Also, I considered mapping from normal and insert mode, but the
"      selection the command makes extends back to the start of the function
"      I'm in, rather than selecting the paragraph I'm in, so for now we'll
"      just do a vmap and force the user to highlight the lines s/he wants
"      formatted.
" NOTE For some reason, I sometimes get a suffix, so explictly set to 0 chars.
" 2015.08.07: The author of par is tabist so I made my own.
"             See: https://github.com/landonb/parT
" FIXME:
"vnoremap <F2> :<C-U>'<,'>!par w79 s0<CR>
"vnoremap <F2> :<C-U>'<,'>!par 79gqr<CR>
"vnoremap <F2> :<C-U>'<,'>!par 79qr<CR>
" FIXME: Implement something like `par 79qrT4` to specify size of tab stop,
"        and then call
"   vnoremap <F2> :<C-U>execute "'<,'>!parT 79qr" . ((&expandtab == 0) ? "T".&tabstop : "")<CR>
vnoremap <F2> :<C-U>'<,'>!parT 79qr<CR>
" For commit files, I like narrower columns, 60 chars in width.
"vnoremap <S-F2> :<C-U>'<,'>!par 59gqr<CR>
"vnoremap <S-F2> :<C-U>'<,'>!par 59qr<CR>
vnoremap <S-F2> :<C-U>'<,'>!parT 67qr<CR>
" 2014.11.25: Can we also throw in seventy-wides?
"vnoremap <C-S-F2> :<C-U>'<,'>!par 69gqr<CR>
"vnoremap <C-S-F2> :<C-U>'<,'>!par 69qr<CR>
" 2020-01-28: Dob development (89 chars).
vnoremap <C-S-F2> :<C-U>'<,'>!parT 89qr<CR>
" 2015.11.25: 64? Hrmm
vnoremap <C-S-F3> :<C-U>'<,'>!parT 55qr<CR>
vnoremap <C-S-F4> :<C-U>'<,'>!parT 44qr<CR>

" Example of fetching input for command on vnoremap:
"    https://stackoverflow.com/questions/12805922/vim-vmap-send-selected-text-as-parameter-to-function
"  function s:My_Function(the_input)
"    echo(a:My_Function)
"  endfunction
"  func! GetSelectedText()
"    normal gv"xy
"    let result = getreg("x")
"    normal gv
"    return result
"  endfunc
"  vnoremap <F2> :<C-U>call <SID>My_Function(GetSelectedText())<CR>

" 2015.01.14: For pesky, very-wide reST tables, do a fluid re-widen,
"             and use the length of the first selected line rather
"             than a hard-coded width.
"             But first, some comments about visual mode maps:
" [lb] thought <C-R> dumped selected text, but this cmd indicates otherwise:
"     vnoremap <M-S-F2> :<C-U>echo '<,'><C-R>
" This works, but as soon as it executes, the "-- (insert) SELECT --"
" message overwrites it in the message tray, so you just see a flicker:
"     vnoremap <M-S-F2> :<C-U>echomsg virtcol("$")<CR>
" '<,'> supplies a range to a function, and when used with !,
"   pipes the range of text to stdout, and the response replaces
"   the selected text, e.g.,
"     vnoremap <M-S-F2> :<C-U>'<,'>!sed 's/.*/yougotjacked/'<CR>
" An example of how to run two commands in visual mode:
"   vnoremap <M-S-F2> :<C-U>let b:foo = virtcol("$")<CR>:<C-U>let b:bar = 77<CR>
" Anyway, here's the best fcn. I figured out: just use 'execute', dummy.
"   - Omit the 'fit' option, which tries to make all lines about the same
"     length, which has the side-effect of possibly making all lines narrower.
"   - Remember virtcol("$") is number of chars + 1 for first selected line.
vnoremap <M-S-F2> :<C-U>execute "'<,'>!parT " . (virtcol("$") - 1) . "qr"<CR>

" NOTE Normal mode and Insert mode <F1> are mapped to toggle-last-user-buffer
"      (:e #) because my left hand got bored or felt left-out or something
"      (my right hand's got the choice of BrowRight or F12 to toggle buffers,
"       which is apparently something I do quite frequently).

" FIXME: When reformatting FIXME and NOTE comments, you can run something like
"          :<,'>!par w40 h1 p8 s0
"        or
"          :<,'>!par w40 p8
"        But the p[N] value depends on the current indent...
"          you need to find the " FIXME and add the indent before that to 8...
" WORK-AROUND: If you run par on the second and subsequent lines (not the
"              FIXME or NOTE line) you can get the formatting you so desire.

" Read also "Formatting Your Source Code" and learn why
" keeping lines to 79 chars or less is a good practice.
"
"   http://www.gnu.org/prep/standards/html_node/Formatting.html

" ------------------------------------------------------
" Change Path Delimiters Quickly
" ------------------------------------------------------

" See: http://vim.wikia.com/wiki/Change_between_backslash_and_forward_slash

" Press f/ to change every backslash to a
"          forward slash, in the current line.
" Press f\ to change every forward slash to a
"          backslash, in the current line.
" The mappings save and restore the search
" register (@/) so you can continue a previous
" search, if desired (i.e., the previous search
" doesn't become '/' or '\').
:nnoremap <silent> f/
  \ :let tmp=@/<CR>:s:\\:/:ge<CR>:let @/=tmp<CR>
:nnoremap <silent> f<Bslash>
  \ :let tmp=@/<CR>:s:/:\\:ge<CR>:let @/=tmp<CR>

" ------------------------------------------------------
" Ctrl-Return is Your Special Friend (Who Won't Comment)
" ------------------------------------------------------

" Ctrl-<CR> starts a new line without the comment leader.
nmap <C-CR> <C-o><Home><Down>i<CR><Up>
imap <C-CR> <C-o><Home><Down><CR><Up>

" ------------------------------------------------------
" Start Substitution Under Cursor
" ------------------------------------------------------

" Starts a substitution command on whatever the cursor's on.
" Usage: Highlight some text
"        Type Ctrl-o \s
" http://vim.wikia.com/wiki/Search_and_replace_the_word_under_the_cursor
" NOTE "s sets 's' as the next yank register;
"      y yanks the .,$ motion, which searches from the cursor
"      to end of file (so we don't find-replace matches before
"      the cursor; if you want to find-replace the whole file,
"      start from the first match or before);
"      C-r pastes from the 's' register;
"      the 3 lefts position the cursor between the second set of sticks.
"
" 2018-06-11: Here's the mapping that's served so well these past many years:
"   noremap <Leader>s "sy:.,$s/<C-r>s//gc<Left><Left><Left>
"
" 2018-06-11: SO RAD!! And here's the mapping that'll serve me even better:
" Center each substitution candidate as it's selected and highlighted!
com! -nargs=* -complete=command ZZWrap let &scrolloff=999 | exec <q-args> | let &so=0
noremap <Leader>s "sy:ZZWrap .,$s/<C-r>s//gc<Left><Left><Left>
" 2024-08-07: Alternative \S# uses '#' delims instead of '/', e.g., to
"             make it easier to write patterns that include path strings.
noremap <Leader>S# "sy:ZZWrap .,$s#<C-r>s##gc<Left><Left><Left>

" See also: QuickfixSubstituteAll in plugin/dubs_quickfix_wrap.vim,
" which defines <Leader>S (\S) which find-replaces in all files
" listed in the quickfix window.

" ------------------------------------------------------
" Truncate and Pad Line to Specific Width
" ------------------------------------------------------
" http://vim.wikia.com/wiki/Add_trailing_blanks_to_lines_for_easy_visual_blocks

" truncate line 'line' to no more than 'limit' width
function! Truncate(line, limit)
  call cursor(a:line,a:limit)
  norm d$
endfunc

" Pad all lines with trailing blanks to 'limit' length.
function! AtOnce(limit)
  norm mm
  g/^/norm 100A
  g/^/call Truncate(getline('.'), a:limit)
  let @/=""
  norm 'm
endfunc
" AtOnce same as:
"  :g/^/exe "norm! 100A" | call cursor(getline('.'), 79) | norm d$

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Simple keyboard mappings to toggle special windows to help insert text.
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" <Leader>ct // \ct // Toggle Cliptext
" ------------------------------------
" - ~~Alt-Shift-1~~ // Toggle Cliptext
" EditPlus has a cool ANSI chart you can bring up
" quickly (who isn't always referring to ANSI
" charts?). Our Vim substitute is an even
" awesomer interactive ASCII table by Christian
" Habermann,
"  CharTab <http://www.vim.org/scripts/script.php?script_id=898>
" NOTE Does not work: nnoremap <M-!> <Leader>ct
" SYNC_ME: Dubs Vim's <M-????> mappings are spread across plugins. [\ct]
"
" MAYBE/2021-01-23: Remove this? I use the Cmd-u Unicode list from DepoXy Ambers.

" ISOFF/2024-04-29: These used to be more prominent bindings, but this
" resource is rarely (if ever) accessed.
"   nmap <M-!> <Plug>CT_CharTable
"   imap <M-!> <C-o><Plug>CT_CharTable<ESC>
nmap <Leader>ct <Plug>CT_CharTable
imap <Leader>ct <C-o><Plug>CT_CharTable<ESC>

" TODO imap does not restore i-mode when ct done
" NOTE Modified chartab.vim to alias <ESC> and
"      <M-!> to 'q'
" NOTE chartab.vim opens in new buffer in same
"      window, rather than creating new vertical
"      window on left of view and opening there
"      NOTE You can work-around by opening in
"           QFix window
"           i.e., Alt-Shift-2 followed by
"                 Alt-Shift-1

" Alt-Shift-1 // S-M-! // Toggle Tag List
" ---------------------------------------
" - ~~Alt-Shift-6~~ // Toggle Tag List
" Show the ctags list.
" - WASAT/2024-04-29: Previously at <Shift-Alt-6>. Promoted to see if
"   tag list will get used now. Decade-long A/B testing.
"     nmap <M-^> :TlistToggle<CR>
"     imap <M-^> <C-O>:TlistToggle<CR>
"     " cmap <M-^> <C-C>TlistToggle<ESC>
"     " omap <M-^> <C-C>TlistToggle<ESC>
" SYNC_ME: Dubs Vim's <M-????> mappings are spread across plugins. [M-S-1]
nmap <M-!> :TlistToggle<CR>
imap <M-!> <C-O>:TlistToggle<CR>

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Setup ctags
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ------------------------------------------------------
" Jump to tag under cursor
" ------------------------------------------------------

" Note that Vim maps Ctrl-] differently in Insert and Normal modes:
" - In Normal mode, Ctrl-] jumps to the tag under the cursor
" - In Insert mode, Ctrl-] completes the abbreviation being typed,
"   without inserting a character (normally an abbreviation is not
"   completed until a non-abbrev character is typed, and then both
"   the abbreviation and the non-abbrev character are inserted).
"   Or as Vim puts it:
"     *Trigger abbreviation, without inserting a character.*
"
" 2021-01-16: For the past, I dunno, decade, I guess, I've mapped
" Ctrl-] to jump to declaration from either Insert or Normal mode.
" - Then recently I was reminded of the other Ctrl-] behavior, and
"   I realized I sometimes complete an abbreviation and then delete
"   the extra character (usually the `TTT` abbreviation).
" - So let's resurrect the silent abbreviation completer,
"   but at a new key combination.
" - I don't use this command *too* often, so I didn't think too hard
"   about the mapping -- I just went with something close, something
"   with a Levenshtein distance of just 2:
"
"     Change `Ctrl-]` → `Meta-[`.
"
"   (Note that, AFAICT i_Meta-[ unused, and free for the taking.)
" - Ref: i_Ctrl-], i_Ctrl-], but not i_Meta-[ (no help).
"
"     #better-Vim-defaults
"
inoremap <silent> <M-[> <C-]>

" Ctrl-] jumps to the tag under the cursor, but only in normal mode. Let's
" make it work in Insert mode, too.
"noremap <silent> <C-]> :call <SID>GrepPrompt_Auto_Prev_Location("<C-R><C-W>")<CR>
inoremap <silent> <C-]> <C-O>:tag <C-R><C-W><CR>
"cnoremap <silent> <C-]> <C-C>:call <SID>GrepPrompt_Auto_Prev_Location("<C-R><C-W>")<CR>
"onoremap <silent> <C-]> <C-C>:call <SID>GrepPrompt_Auto_Prev_Location("<C-R><C-W>")<CR>
" Selected word
vnoremap <silent> <C-]> :<C-U>
  \ <CR>gvy
  \ :execute "tag " . @@<CR>

" Ctrl-t jumps back after a Ctrl-], but I have two issues with this. One,
" I've got Ctrl-t mapped to Transpose Characters in Insert mode. But more
" importantly, Two, Why isn't this Ctrl-[? That seems intuitive, and it's
" closer to the key you just pressed (by default, Ctrl-[ does the same thing as
" <Esc>, and I've already got enough escapes mapped).

" Hmpf. I cannot get this to work right now. It remaps all my other Escapes,
" too... and <C-}>, <C-S-]> and <C-S-}> don't work, either
"cnoremap <C-[> :normal <C-t><CR>
"inoremap <C-[> <C-O>:normal <C-t><CR>
"vnoremap <C-[> :<C-U>
"  \ <CR>gvy
"  \ gV
"  \ :normal <C-t><CR>
" Whatever, use Alt-] to jump a tag back.
noremap <M-]> :normal <C-t><CR>
inoremap <M-]> <C-O>:normal <C-t><CR>
vnoremap <M-]> :<C-U>
  \ <CR>gvy
  \ gV
  \ :normal <C-t><CR>

" ctags
" cd $cp/pyserver
" ctags -R
" cd $cp/flashclient
" # NOTE --exclude=build is all that works, not flashclient/build or
" #      even /build or build/. I even tried using "./quotes".
" #      But if you run the following command with --verbose=yes
" #        ctags -R --exclude=build --verbose=yes
" #      You can verify that the build directory (and only the build directory)
" #      is excluded by looking for the line
" #        excluding "build"
" ctags -R --exclude=build

"       vi -t tag   Start vi and position the cursor at the  file  and  line
"                   where "tag" is defined.
"
"       :ta tag     Find a tag.
"
"       Ctrl-]      Find the tag under the cursor.
"
"       Ctrl-T      Return  to  previous  location  before  jump to tag

"Jumping to a tag

"    * You can use the 'tag' ex command. For example, the command ':tag <tagname>' will jump to the tag named <tagname>.
 "   * You can position the cursor over a tag name and then press Ctrl-].
 "   * You can visually select a text and then press Ctrl-] to jump to the tag matching the selected text.
 "   * You can click on the tag name using the left mouse button, while pressing the <Ctrl> key.
 "   * You can press the g key and then click on the tag name using the left mouse button.
 "   * You can use the 'stag' ex command, to open the tag in a new window. For example, the command ':stag func1' will open the func1 definition in a new window.
 "   * You can position the cursor over a tag name and then press Ctrl-W ]. This will open the tag location in a new window.
"
"Help: :tag, Ctrl-], v_CTRL_], <C-LeftMouse>, g<LeftMouse>, :stag, Ctrl-W_]

"    * You can list all the tags matching a particular regular expression pattern by prepending the tag name with the '/' search character. For example,
"
":tag /<pattern>
":stag /<pattern>
":ptag /<pattern>
":tselect /<pattern>
":tjump /<pattern>
":ptselect /<pattern>
":ptjump /<pattern>

" ------------------------------------------------------
" easytags configuration
" ------------------------------------------------------

" Don't print message when tags are updated.
let g:easytags_suppress_report = 1

" Use project-specific tags files and not the global ~/.vimtags.
" 2017-11-08: Ug. This is the culprit. Out, damn spot!
"   (Let project-specific tags= work on boot, e.g., via .trustme.vim.)
"set tags=./tags

"let g:easytags_dynamic_files = 1
let g:easytags_dynamic_files = 2

" [lb] seeing a sluggish Vim after saving a file (closing and reopening
" the file works until the next save; this problem does not always happen,
" either), so trying aynchronous easytags updating.
let g:easytags_async = 1

let g:easytags_auto_update = 0

" ------------------------------------------------------
" Vim Wild Menu (wildmenu)
" ------------------------------------------------------

" In Insert mode, use Ctrl-P and Ctrl-N to cycle through
" an auto-completion list from your tags file.
" Completion happens according to wildmode.
" See also :help cmdline-completion
set wildmode=list:longest,full

" ------------------------------------------------------
" Obsolete ActionScript tags code...
" ------------------------------------------------------

" From
" http://vim-taglist.sourceforge.net/extend.html
" actionscript language
let tlist_actionscript_settings = 'actionscript;c:class;f:method;p:property;v:variable'

" FIXME add ctags to Makefile instead of daily.sh
"CTAGLANGS = --langdef=actionscript \
"--langmap=actionscript:.as \
"--regex-actionscript='/^[ \t]*[(private| public|static) ( \t)]*function[\t]+([A-Za-z0-9_]+)[ \t]*\(/\1/f, function, functions/' \
"--regex-actionscript='/^[ \t]*[(public) ( \t)]*function[ \t]+(set|get) [ \t]+([A-Za-z0-9_]+)[ \t]*\(/\1 \2/p,property, properties/' \
"--regex-actionscript='/^[ \t]*[(private| public|static) ( \t)]*var[  \t]+([A-Za-z0-9_]+)[\t]*/\1/v,variable, variables/' \
"--regex-actionscript='/.*\.prototype \.([A-Za-z0-9 ]+)=([ \t]?)function( [  \t]?)*\(/\1/f,function, functions/' \
"--regex-actionscript='/^[ \t]*class[ \t]+([A-Za-z0-9_]+)[ \t]*/\1/c,class, classes/'
"
".PHONY: ctags
"ctags:
"-rm -f TAGS
"find . -name "*.as" -or -name "*.mxml" | ctags -eL - $(CTAGLANGS)
"
" FIXME The article at http://vim-taglist.sourceforge.net/extend.html
"       is wrong
"       Specifically, it doesn't recognize override or protected, and set|get
"       is broken. See my .ctags file for the appropriate command.

"--regex-actionscript=/^[ \t]*[(override)[ \t]+]?[(private|protected|public)][ \t]+[(static)[ \t]+]?function[ \t]+[(set|get)]*[ \t]+([A-Za-z0-9_]+)[ \t]*\(/\1 \2/p,property, properties/

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Macros
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Think of 'em as personal assistants:
" teach 'em once, then have them repeat.

" Single-Key Replays with Q
" --------------------------------
" This is a shortcut to playback the recording in
" the q register.
"   1. Start recording with qq
"   2. End recording with q (or with
"      Ctrl-o q if in Insert mode)
"   3. Playback with Q
nnoremap Q @q

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Developer Specials
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ------------------------------------------------------
" Capture Ex Output So You Can
"     Do With It As You Please
" ------------------------------------------------------
" http://vim.wikia.com/wiki/Capture_ex_command_output

" ------------------------------------------------------
" Basic Ex output Capture
" ------------------------------------------------------

"   :redir @a
"   :set all " or other command
"   :redir END
" and use "ap to put the yanked

" ------------------------------------------------------
" Advanced Ex output Capture
" ------------------------------------------------------

" TabMessage runs the specified command
" and pastes the output to a new buffer
" in a new tab
function! s:TabMessage(cmd)
  " Redirect Ex output to a varibale
  " we'll call 'message'
	redir => message
	silent execute a:cmd
	redir END
  " Create a new tab and put the
  " captured output
  tabnew
	silent put=message
  " Tell Vim not to ask us to save
  " when we close the buffer
  setlocal buftype=nowrite
endfunction
" Map our TabMessage function to an Ex :command
" of the same name
command! -nargs=+ -complete=command
  \ TabMessage call <SID>TabMessage(<q-args>)
" Usage, e.g.,
"   :TabMessage highlight
"   :TabMessage ec g:
" Shortcut
"   :Tab<TAB>     using autocompletion
"   :ta<TAB><TAB> also works

" ------------------------------------------------------
" Start Command w/ Selected Text
" ------------------------------------------------------

" For help with Command Line commands, see :h cmdline
" Note that <C-R> is search in Insert mode but starts a
" put in Command mode. Also note that <Ctrl-R> is
" interpreted literally and does nothing; use <C-R>.

"vnoremap : :<C-U>
vnoremap :: :<C-U>
  \ <CR>gvy
  \ :<C-R>"

" ------------------------------------------------------
" Lorem Ipsum Dump
" ------------------------------------------------------
" By Harold Giménez
"   http://awesomeful.net/posts/57-small-collection-of-useful-vim-tricks
"   http://github.com/hgimenez/vimfiles/blob/c07ac584cbc477a0619c435df26a590a88c3e5a2/vimrc#L72-122

" Define :Lorem command to dump a paragraph of lorem ipsum
command! -nargs=0 Lorem :normal iLorem ipsum dolor sit amet, consectetur
      \ adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore
      \ magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation
      \ ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute
      \ irure dolor in reprehenderit in voluptate velit esse cillum dolore eu
      \ fugiat nulla pariatur.  Excepteur sint occaecat cupidatat non
      \ proident, sunt in culpa qui officia deserunt mollit anim id est
      \ laborum.

" ------------------------------------------------------
" From /usr/share/vim/vim74/vimrc_example.vim
"      /usr/share/vim/vim74/gvimrc_example.vim
" ------------------------------------------------------

" Convenient command to see the difference between the current
" buffer and the file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
    \ | wincmd p | diffthis
endif

" ------------------------------------------------------
" Toggle diff highlighting in a single window
" ------------------------------------------------------
" From:
"  http://vim.wikia.com/wiki/A_better_Vimdiff_Git_mergetool
" Disable one diff window during a three-way diff allowing you to cut out the
" noise of a three-way diff and focus on just the changes between two versions
" at a time. Inspired by Steve Losh's Splice
function! DiffToggle(window)
  " Save the cursor position and turn on diff for all windows
  let l:save_cursor = getpos('.')
  windo :diffthis
  " Turn off diff for the specified window (but keep scrollbind) and move
  " the cursor to the left-most diff window
  exe a:window . "wincmd w"
  diffoff
  set scrollbind
  set cursorbind
  exe a:window . "wincmd " . (a:window == 1 ? "l" : "h")
  " Update the diff and restore the cursor position
  diffupdate
  call setpos('.', l:save_cursor)
endfunction
" Toggle diff view on the left, center, or right windows
nmap <silent> <leader>dl :call DiffToggle(1)<cr>
nmap <silent> <leader>dc :call DiffToggle(2)<cr>
nmap <silent> <leader>dr :call DiffToggle(3)<cr>

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Other Functions
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ----------------------------------------------------------------------------------
" Insert today's date. 2016-07-12: [lb] tired of doing this [typing dates] manually.
" ----------------------------------------------------------------------------------

" The obvious typing and insertion shortcuts in Vim are to use
" an Fkey, a control and/or meta key combo, a leader key sequence,
" or an abbreviation. Generally, abbreviations kind of suck (or,
" rather, they do suck) because you have to type a space or an
" enter to trigger the abbreviation, and then your Vim iabbrev
" generally has to gobble that whitespace up and reposition the
" cursor. But here, typing TTT: immediately triggers the substition
" (upon pressing the colon key)*. So this might be the best example
" yet of a good use of iabbrev (at least for me, since I don't use
" it for word shortcuts (e.g.,, in the Vim help, the example is
"  iabbrev ms Microsoft, how corny is that! I type ms for
"  millisecond anyway so that would just blow)).

" * 2016-07-12: This seems to happen in .vim files but not .rst files. WTWHY?

" An old dog can learn new tricks, like the P in <CR>P
" and the <expr> in iabbrev <expr>.
"
" http://vim.wikia.com/wiki/Insert_current_date_or_time
"
" “The uppercase P at the end inserts before the current character,
"  which allows datestamps inserted at the beginning of an existing line.”
"  " :nnoremap <F5> "=strftime("%Y-%m-%d")<CR>P
"    :inoremap <F5> <C-R>=strftime("%Y-%m-%d")<CR>
"
" Re: <expr>, see:
"  http://vimdoc.sourceforge.net/htmldoc/map.html#:map-expression
iabbrev <expr> TTT strftime("%Y-%m-%d")
" 2021-01-03: How has TTT_ been in Homefries Bash but not Dubs Vim.
iabbrev <expr> TTT_ strftime("%Y_%m_%d")
" 2017-02-27: An alias for when I want to highlight the time,
"  probably when writing notes drunk in the middle of the night.
iabbrev <expr> TTTtt strftime("%Y-%m-%d %H:%M")
" All the combinations.
iabbrev <expr> TTTTtt strftime("%Y-%m-%dT%H:%M")
" Except these don't work: the abbrev fires on non-alpha:
"   iabbrev <expr> TTT!tt strftime("%Y-%m-%d!%H:%M")
"   iabbrev <expr> TTT@tt strftime("%Y-%m-%d@%H:%M")
"   iabbrev <expr> TTT#tt strftime("%Y-%m-%d#%H:%M")
"   iabbrev <expr> TTT$tt strftime("%Y-%m-%d$%H:%M")
"   iabbrev <expr> TTT%tt strftime("%Y-%m-%d%%%H:%M")
"   iabbrev <expr> TTT^tt strftime("%Y-%m-%d^%H:%M")
"   iabbrev <expr> TTT&tt strftime("%Y-%m-%d&%H:%M")
"   iabbrev <expr> TTT*tt strftime("%Y-%m-%d*%H:%M")
"   iabbrev <expr> TTT-tt strftime("%Y-%m-%d-%H:%M")
"   iabbrev <expr> TTT_tt strftime("%Y-%m-%d_%H:%M")
"   iabbrev <expr> TTT+tt strftime("%Y-%m-%d+%H:%M")
"   iabbrev <expr> TTT\tt strftime("%Y-%m-%d\%H:%M")
"   iabbrev <expr> TTT|tt strftime("%Y-%m-%d|%H:%M")
"   iabbrev <expr> TTT;tt strftime("%Y-%m-%d;%H:%M")
"   iabbrev <expr> TTT:tt strftime("%Y-%m-%d:%H:%M")
"   iabbrev <expr> TTT'tt strftime("%Y-%m-%d'%H:%M")
"   iabbrev <expr> TTT"tt strftime("%Y-%m-%d"%H:%M")
"   iabbrev <expr> TTT/tt strftime("%Y-%m-%d/%H:%M")
"   iabbrev <expr> TTT?tt strftime("%Y-%m-%d?%H:%M")
" So just add a `tt` abbrev!
"iabbrev <expr> tt strftime("%H:%M")
iabbrev <expr> ttt strftime("%H:%M")

" TRYME/2023-06-03: For use after a FIVER -->
"     Type `FIVER\t` and you get `FIVER/TTT: `
"     Type `FIVER<F5>` and you get `FIVER/TTTtt: `
"
" - The author types, e.g., 'FIXME/TTT: ', 'FIXME/TTTtt: ', etc., often, so
"   wondering if this'll be a speed increase.
" - I tried using the abbreviation, '::', but the '/' after the FIVER is
"   not a keyword character, and neither is ':', so doesn't work well.
" - Trying instead <F5>, which saves 8 keypresses '/TTTtt: '
"
inoremap <silent> <unique> <Leader>t <C-R>=strftime("/%Y-%m-%d: ")<CR>
inoremap <F12> <C-R>=strftime("/%Y-%m-%d %H:%M: ")<CR>

" (lb): 2018-05-31: Use `###` to generate a basic datetime section header,
" e.g.,
"
"     ################
"     2021-01-31 21:33
"     ################
"
" (FIXME/2021-01-31: Move this, the `TTT` abbrevs, etc., to new reSTfold plugin.)
"
" Use a triple pound press to generate a simple date-and-timed reSTfold header.
"
" - 2021-01-31: Note that having a final <CR> in the {rhs} is nice, e.g.,
"
"     iabbrev <expr> ### "################<CR>" . strftime("%Y-%m-%d %H:%M") . "<CR>################<CR>"
"
"   because then typing `###<CR>` puts the cursor one blank line after the header,
"   e.g.,
"
"     ################
"     2021-01-31 21:33
"     ################
"
"     | ← cursor starts at the start of this line
"
"   But it also causes the abbreviation to be re-inserted if you hold down
"   the key, e.g., press and hold `#` and you'll keep generating headers.
"
"   Note that this does not happen with an alpha abbreviation, e.g., given
"
"     iabbrev <expr> ZZZ "################<CR>" . strftime("%Y-%m-%d %H:%M") . "<CR>################<CR>"
"
"   if you press and hold `Z`, you'll see, e.g., `ZZZZZZZZZZZZZZ`, and no
"   substitution is performed.
"
"   - This is because `#` is a non-keyword character, which triggers end of abbrev.
"
"   So just because we're using a special character here, let's remove the <CR>,
"   so then holding `#` will generate *one* header, and then the extra presses
"   just append the bottom header border, e.g.,
"
"     ################
"     2021-01-31 21:33
"     ###############################
"
"   so at least if you want to generate a line of octothorpes, now you can,
"   albeit you'll still want to delete the two lines inserted before it.
"
"     iabbrev <expr> ### "################<CR>" . strftime("%Y-%m-%d %H:%M") . "<CR>################"
"
"   - Or, instead (as I rethink this), let's decide that ending the abbreviation
"     with a non-keyword character is not helping, so let's choose a better
"     abbreviation that allows us to include that final <CR> and also to
"     avoid issues on repeat.
"
"     - I tried `333`, which isn't too bad, but I think `#T` is a better mnemonic.
"
iabbrev <expr> #T "################<CR>" . strftime("%Y-%m-%d %H:%M") . "<CR>################<CR>"
"
"     - Maybe also a `3t`, easier to type, and unlikely to be in the way.
"
iabbrev <expr> 3t "################<CR>" . strftime("%Y-%m-%d %H:%M") . "<CR>################<CR>"

" Works as ``##|<space>``, not ``##|<cr>``.
iabbrev <expr> ##\| '####################<CR>┃ ' . strftime("%Y-%m-%d %H:%M") . ":<CR>####################<CR><up><up><end>"

" (lb): 2020-09-21: I keep typing `:::`, might as well wire it.
iabbrev <expr> ::: strftime("%Y-%m-%d %H:%M:")

" -------------------------
" Left Justify Current Line
" -------------------------

" \x just left-justifies the current line.
nnoremap <silent> <leader>x :left<cr><END>a
inoremap <silent> <leader>x <C-O>:left<cr><END>

" -------------------------------------------------------------------------
" 2017-03-28: [lb] trying a new ESC shortcut, jj.
" -------------------------------------------------------------------------

" You can leave insert mode using <ESC> or Ctrl-C. Also by jj now, if you want.
" 2018-06-14: Hrm. I don't like how it interrupts typing `j`, as Vim waits to
" see if you're gonna type `jj`. Too strange. Never used it! Bye!!
"   inoremap jj <ESC>
" 2018-06-14: What about Alt-J, Alt-J, two of my favorite bands?
inoremap <M-j><M-j> <ESC>

" -------------------------------------------------------------------------------
" 2017-08-02: Source a .vim file in or up path, to support continuous integration
" -------------------------------------------------------------------------------
" E.g., run a rake task when Ruby files are saved.
" E.g., set tags= when a file is opened.

" FIXME/2017-08-02: Document this. And maybe move to a different file/new plugin.

" WHATEVER/2017-08-02: If you use the project.vim plugin and double click a
" file, neither BufEnter nor BufRead get called on the newly opened file.
" BufEnter instead gets called on the .vimprojects file in the left window,
" and BufRead isn't triggered at all. If you leave the window and reenter it,
" then BufEnter is triggered (but not BufRead).
" (TabEnter and WinEnter seemed to be called, but not BufWinEnter or BufNew.
"  I think.)
" FORTUNATELY! The project.vim plugin has a feature that sources a Vim file
" when you open a file in or under a directory. Just set in="somefile.vim".
" That, in conjunction with the BufEnter hook, provide the complete solution.
" 2017-11-08: Actually, no. The path is still wrong from project.vim...
"   it's still project.vim's path...

if ! exists("g:DUBS_TRUST_ME_PLUGIN_FILE")
  let g:DUBS_TRUST_ME_PLUGIN_FILE = ".trustme.vim"
endif

if ! exists("g:DUBS_TRUST_ME_PLUGIN_DIR")
  let g:DUBS_TRUST_ME_PLUGIN_DIR = ".trustme"
endif

autocmd BufEnter * call s:SeekForSecurityHolePluginFileToLoad(0, 'BufEnter')
autocmd BufWritePost * call s:SeekForSecurityHolePluginFileToLoad(1, 'BufWritePost')

" Search updards for a specially named file to be sourced at runtime,
" whenever the buffer of a file in a directory thereunder is opened.
function! s:SeekForSecurityHolePluginFileToLoad(on_save, because)
  " Avoid looking for trustme.vim plugin for unsaved (new) buffers,
  " e.g., those without a path; and for other special buffer types.
  " - E.g., vim-fugitive paths look like:
  "   fugitive:///repo/path/.git//SHA1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/some/file
  if (expand('%:p') == '') || !empty(matchstr(expand('%:p'), '^fugitive://.*'))
    return
  endif

  " Likewise skip unlisted buffers, Quickfix buffer, and preview window buffer. 

  let l:bufnr = bufnr("%")

  if !buflisted(l:bufnr) || &ft == 'qf' || &previewwindow
    return
  endif

  " ***

  " NOTE: If using the project.vim plugin, if you double click files from
  "   there, for some reason this function (when called from BufEnter)
  "   runs in the context of the project window. I.e., the path is to
  "   .vimprojects. I'm not sure why; and I spent too much time trying to
  "   make it work that I finally don't care anymore.

  " echomsg 'Trust-Me running on ' .. expand('%') .. ' / because: ' .. a:because

  " ***

  " Prefer a .trustme/ directory on path.
  let l:start_dir = s:SeekForSecurityHolePlugin_SeekupForTrustmeDotDir()

  " If no .trustme/ directory found, start from current directory.
  if (l:start_dir == '')
    let l:start_dir = '.'
  endif

  " Look up for the .trustme.vim plugin to load.
  let l:project_plugin_f = s:SeekForSecurityHolePlugin_SeekUpForTrustmeDotVim(l:start_dir)

  if (l:project_plugin_f != '')
    let l:plugin_path = fnamemodify(expand(l:project_plugin_f), ':p')

    if (filereadable(l:plugin_path))
      let l:cwd = getcwd()

      " echomsg 'cwd: ' .. l:cwd

      exec 'cd ' .. fnamemodify(expand(l:project_plugin_f), ':h')
      let g:DUBS_TRUST_ME_ON_FILE = expand('%:t')
      let g:DUBS_TRUST_ME_ON_SAVE = a:on_save
      exec 'source ' .. l:plugin_path
      exec 'cd ' .. l:cwd
    else
      " Unexpected branch.
      echomsg 'ERROR: Unexpected: .trustme.vim not readable: ' .. l:plugin_path
    endif
  endif
endfunction

" Look for a '.trustme/' dir., walking from the current directory (same
" as expand('%:h')) to the root directory. Note the path syntax: a sole
" '.' searches just the current dir., or child (downward) directories if
" you add ** globs; but if the path ends with ';', findfile will 'search
" upward till the root directory' (per :h file-searching). So '.;' searches
" up from the current directory. Note, too, the semi-colon can be followed
" by a list of stop-directories, which behave as one might expect.
function! s:SeekForSecurityHolePlugin_SeekupForTrustmeDotDir()
  let l:trustme_dir = finddir(g:DUBS_TRUST_ME_PLUGIN_DIR, '.;')

  " echomsg 'Find-up for dir ‘' .. g:DUBS_TRUST_ME_PLUGIN_DIR .. '’ / found: ' .. l:trustme_dir

  return l:trustme_dir
endfunction

function! s:SeekForSecurityHolePlugin_SeekUpForTrustmeDotVim(start_dir)
  let l:trustme_vim = findfile(g:DUBS_TRUST_ME_PLUGIN_FILE, a:start_dir .. ';')

  " echomsg 'Find-up for plug from: ' .. a:start_dir .. ' / found: ' .. l:trustme_vim

  return l:trustme_vim
endfunction


" -------------------------------------------------------------------------
" 2017-12-01: Show the :highlight of the word under the cursor.
" -------------------------------------------------------------------------

" 2017-12-01: This is awesome! "vim identify highlight of word under cursor"
"   http://vim.wikia.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
" See also :help synstack()
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
  \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
  \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" 2017-12-10 01:07: Would a highlight-word-under-cursor help me find search results?
" http://vim.wikia.com/wiki/Highlight_current_word_to_find_cursor
"nnoremap <C-i> :call HighlightNearCursor()<CR>
"inoremap <C-i> <C-o>:call HighlightNearCursor()<CR>
" 2017-12-10 14:09: I really don't know if I'll use this, and burning
"   a limited-edition Command-key sequence makes me uneasy; but I can
"   always steal this back later.
" FIXME/MAYBE: If you scroll, the highlight moves to other words...
"   this function really is very crude.
" This screws <TAB>:
"   inoremap <C-I> <C-O>:call HighlightNearCursor()<CR>
inoremap <C-B> <C-O>:call HighlightNearCursor()<CR>
function! HighlightNearCursor()
  if !exists("s:highlightcursor")
    match Todo /\k*\%#\k*/
    let s:highlightcursor=1
  else
    match None
    unlet s:highlightcursor
  endif
endfunction


" -------------------------------------------------------------------------
" 2018-02-20: Remove word under cursor. Sorta like Bash's Alt-d.
" -------------------------------------------------------------------------

" https://stackoverflow.com/questions/833838/delete-word-after-or-around-cursor-in-vim
" See:
"  :help diw
imap <M-d> <C-o>diw
nmap <M-d> diw

" -------------------------------------------------------------------------
" 2020-02-05: Change cursor shape in different modes.
" -------------------------------------------------------------------------

" Thank you!!
" https://vim.fandom.com/wiki/Change_cursor_shape_in_different_modes

" 'Set IBeam shape in insert mode, underline shape in replace mode
"  and block shape in normal mode.'
"  https://vim.fandom.com/wiki/Change_cursor_shape_in_different_modes
" From 'VTE-compatible terminals' ('includes mate-terminal 1.18.1').
" 2020-02-05: (lb): I'm running 'MATE Terminal 1.20.0'.
" - Works close to perfect, except on escape to vim insert mode, the
"   I-beam cursor appears to go backward one character, but what really
"   happens is the cursor changes back to block but does not get updated
"   until you now type a movement command.
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"

" -------------------------------------------------------------------------
" -------------------------------------------------------------------------

