" File: dubs_edit_juice.vim
" Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
" Last Modified: 2016.07.12
" Project Page: https://github.com/landonb/dubs_edit_juice
" Summary: EditPlus-inspired editing mappings
" License: GPLv3
" -------------------------------------------------------------------
" Copyright © 2009, 2015-2016 Landon Bouma.
" 
" This file is part of Dubsacks.
" 
" Dubsacks is free software: you can redistribute it and/or
" modify it under the terms of the GNU General Public License
" as published by the Free Software Foundation, either version
" 3 of the License, or (at your option) any later version.
" 
" Dubsacks is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty
" of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
" the GNU General Public License for more details.
" 
" You should have received a copy of the GNU General Public License
" along with Dubsacks. If not, see <http://www.gnu.org/licenses/>
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

" See: http://vim.wikia.com/wiki/Recover_from_accidental_Ctrl-U

inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>

" ------------------------------------------------------
" A Better Backspace
" ------------------------------------------------------

" Ctrl-Backspace deletes to start of word
noremap <C-BS> db
inoremap <C-BS> <C-O>db

" Ctrl-Shift-Backspace deletes to start of line
noremap <C-S-BS> d<Home>
inoremap <C-S-BS> <C-O>d<Home>

" ------------------------------------------------------
" A Delicious Delete
" ------------------------------------------------------

" In EditPlus, Ctrl-Delete deletes characters 
" starting at the cursor and continuing to the 
" end of the word, or until certain punctuation. 
" If the cursor is on whitespace instead of a
" non-whitespace character, Ctrl-Delete just 
" deletes the continuous block of whitespace, 
" up until the next non-whitespace character.
"
" In Vim, the 'dw' and 'de' commands perform
" similarly, but they include whitespace, either 
" after the word is deleted ('dw'), or before 
" it ('de'). Therefore, to achieve the desired 
" behaviour -- such that contiguous blocks of 
" whitespace and non-whitespace are treated 
" independently -- we need a function to tell 
" if the character under the cursor is whitespace 
" or not, and to call 'dw' or 'de' as appropriate.
" NOTE Was originally called DeleteToEndOfWord, 
"      but really,
"   DeleteToEndOfWhitespaceAlphanumOrPunctuation
" --------------------------------
"  Original Flavor
function! s:Del2EndOfWsAz09OrPunct_ORIG()
  " If the character under the cursor is 
  " whitespace, do 'dw'; if it's an alphanum, do 
  " 'dw'; if punctuation, delete one character
  " at a time -- this way, each Ctrl-Del deletes 
  " a sequence of characters or a chunk of 
  " whitespace, but never both (and punctuation 
  " is deleted one-by-one, seriously, this is 
  " the way's I like's it).
  let char_under_cursor = 
    \ getline(".")[col(".") - 1]
  " Can't get this to work:
  "    if char_under_cursor =~ "[^a-zA-Z0-9\\s]"
  " But this works:
  if (char_under_cursor =~ "[^a-zA-Z0-9]")
        \ && (char_under_cursor !~ "\\s")
    " Punctuation et al.; just delete the 
    " char or sequence of the same char.
    " Well, I can't get sequence-delete to 
    " work, i.e.,
    "      execute 'normal' . 
    "        \ '"xd/' . char_under_cursor . '*'
    " doesn't do squat. In fact, any time I try 
    " the 'd/' motion it completely fails...
    " Anyway, enough boo-hooing, just delete the 
    " character-under-cursor:
    execute 'normal' . '"xdl'
  elseif char_under_cursor =~ '[a-zA-Z0-9]'
    " This is an alphanum; and same spiel as 
    " above, using 'd/' does not work, so none of 
    " this: 
    "   execute 'normal' . '"xd/[a-zA-Z0-9]*'
    " Instead try this:
    "execute 'normal' . '"xde'
    execute 'normal' . '"xdw'
  elseif char_under_cursor =~ '\s'
    " whitespace
    " Again -- blah, blah, blah -- this does not 
    " work: execute 'normal' . '"xd/\s*'
    execute 'normal' . '"xdw'
  " else
  "   huh? this isn't/shouldn't be 
  "         an executable code path
  endif
endfunction
" --------------------------------
"  NEW FLAVOR
function! s:Del2EndOfWsAz09OrPunct(wasInsertMode, deleteToEndOfLine)
  " If the character under the cursor is 
  " whitespace, do 'dw'; if it's an alphanum, do 
  " 'dw'; if punctuation, delete one character
  " at a time -- this way, each Ctrl-Del deletes 
  " a sequence of characters or a chunk of 
  " whitespace, but never both (and punctuation 
  " is deleted one-by-one, seriously, this is 
  " the way's I like's it).
  " 2010.01.01 First New Year's Resolution
  "            Fix Ctrl-Del when EOL (it cur-
  "            rently deletes back a char, rath-
  "            er than sucking up the next line)
  let s:char_under_cursor = 
    \ getline(".")[col(".") - 1]
  "call confirm(
  "      \ 'char ' . s:char_under_cursor
  "      \ . ' / char2nr ' . char2nr(s:char_under_cursor)
  "     \ . ' / col. ' . col(".")
  "      \ . ' / col$ ' . col("$"))
  if (       ( ((col(".") + 1) == col("$")) 
        \     && (col("$") != 2) )
        \ || ( ((col(".") == col("$")) 
        \     && (col("$") == 1)) 
        \     && (char2nr(s:char_under_cursor) == 0) ) )
    " At end of line; delete newline after cursor
    " (what vi calls join lines)
    execute 'normal gJ'
    "execute 'j!'
    " BUGBUG Vi returns the same col(".") for both 
    " the last and next-to-last cursor positions, 
    " so we're not sure whether to join lines or 
    " to delete the last character on the line. 
    " Fortunately, we can just go forward a 
    " character and then delete the previous char, 
    " which has the desired effect
    " Or not, I can't get this to work...
    "execute 'normal ^<Right'
    "execute 'normal X'
    "let this_col = col(".")
    "execute 'normal l'
    "let prev_col = col(".")
    "call confirm('this ' . this_col . ' prev ' . prev_col)
    "
    let s:cur_col = col(".")
    let s:tot_col = col("$")
    " This is a little hack; the d$ command below, which executes if the 
    " cursor is not in the last position, moves the cursor one left, so the 
    " callee moves the cursor back to the right. However, our gJ command 
    " above doesn't move the cursor, so, since we know the callee is going 
    " to move it, we just move it left
    if a:deleteToEndOfLine == 1
      execute 'normal h'
    endif
  else
    let s:cur_col = col(".")
    let s:tot_col = col("$")
    if (a:wasInsertMode 
          \ && (s:cur_col != 1) )
      " <ESC> Made us back up, so move forward one,
      " but not if we're the first column or the 
      " second-to-last column
        execute 'normal l'
    endif
    "let s:char_under_cursor = 
    "  \ getline(".")[col(".")]
    " Can't get this to work:
    "    if s:char_under_cursor =~ "[^a-zA-Z0-9\\s]"
    " But this works:
    if a:deleteToEndOfLine == 1
      execute 'normal d$'
    else
      if (s:char_under_cursor =~ "[^_a-zA-Z0-9\(\.]")
            \ && (s:char_under_cursor !~ "\\s")
        " Punctuation et al.; just delete the 
        " char or sequence of the same char.
        " Well, I can't get sequence-delete to 
        " work, i.e.,
        "      execute 'normal' . 
        "        \ '"xd/' . s:char_under_cursor . '*'
        " doesn't do squat. In fact, any time I try 
        " the 'd/' motion it completely fails...
        " Anyway, enough boo-hooing, just delete the 
        " character-under-cursor:
        execute 'normal "xdl'
      elseif s:char_under_cursor =~ '[_a-zA-Z0-9\(\.]'
        " This is an alphanum; and same spiel as 
        " above, using 'd/' does not work, so none of 
        " this: 
        "   execute 'normal' . '"xd/[a-zA-Z0-9]*'
        " Instead try this:
        "execute 'normal' . '"xde'
        execute 'normal "xdw'
      elseif s:char_under_cursor =~ '\s'
      "if s:char_under_cursor =~ '\s
        " whitespace
        " Again -- blah, blah, blah -- this does not 
        " work: execute 'normal' . '"xd/\s*'
        execute 'normal "xdw'
      " else
      "   huh? this isn't/shouldn't be 
      "         an executable code path
      endif
    endif
  endif
  if (a:wasInsertMode 
        \ && ((s:cur_col + 2) == s:tot_col))
    " <ESC> Made us back up, so move forward one,
    " but not if we're the first column or the 
    " second-to-last column
    "execute 'normal h'
  endif
endfunction
" Map the function to Ctrl-Delete in normal and 
" insert modes.
noremap <C-Del> :call <SID>Del2EndOfWsAz09OrPunct(0, 0)<CR>
" BUGBUG To call a function from Insert Mode -- or to even get 
"        the current column number of the cursor -- we need 
"        to either <C-O> or <Esc> out of Insert mode. If 
"        we <C-O> and the cursor is on either the last 
"        column or the second-to-last-column, the cursor 
"        is moved to the last column. Likewise, if we 
"        <Esc> and the cursor is on either the first column 
"        or the second column, the cursor is moved to the 
"        first column. I cannot figure out a work-around.
"        I choose <Esc> as the lesser of two evils. I.e., 
"        using <C-O>, if the cursor is at the second-to-
"        last column, a join happens but the last character 
"        remains; using <Esc>, if you <Ctrl-Del> from the 
"        second column, both the first and second columns 
"        are deleted. I <Ctrl-Del> from the end of a line 
"        much more ofter than from the second column of a 
"        line.
"inoremap <C-Del> 
"         \ <C-O>:call <SID>Del2EndOfWsAz09OrPunct()<CR>
inoremap <C-Del> 
         \ <Esc>:call <SID>Del2EndOfWsAz09OrPunct(1, 0)<CR>i

" Ctrl-Shift-Delete deletes to end of line
"noremap <C-S-Del> d$
"inoremap <C-S-Del> <C-O>d$
noremap <C-S-Del> :call <SID>Del2EndOfWsAz09OrPunct(0, 1)<CR>
inoremap <C-S-Del> 
         \ <Esc>:call <SID>Del2EndOfWsAz09OrPunct(1, 1)<CR>i<Right>

" 2011.02.01 Doing same for Alt-Delete
noremap <M-Del> :call <SID>Del2EndOfWsAz09OrPunct(0, 1)<CR>
inoremap <M-Del> 
         \ <Esc>:call <SID>Del2EndOfWsAz09OrPunct(1, 1)<CR>i<Right>

" Alt-Shift-Delete deletes entire line
noremap <M-S-Del> dd
inoremap <M-S-Del> <C-O>dd

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Editing Features -- Selecting Text
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ------------------------------------------------------
" Fix That Shift
" ------------------------------------------------------

" Vim's default Ctrl-Shift-Left/Right behavior is 
" to select all non-whitespace characters (see 
" :help v_aW). We want to change this to not be 
" so liberal. Use vmap to change how Vim selects 
" text in visual mode. By using 'e' instead of 
" 'aW', for example, Vim selects alphanumeric 
" blocks but doesn't cross punctuation boundaries.
" In other words, we want to select blocks of 
" whitespace, alphanums, or punctuation, but 
" never combinations thereof.
" TODO This still isn't quite right -- the first 
"      selection is always too great, i.e., the 
"      cursor jumps boundaries 'b' and 'e' 
"      wouldn't
vnoremap <C-S-Left> b
vnoremap <C-S-Right> e

" Alt-Shift-Left selects from cursor to start of line
" (same as Shift-Home)
noremap <M-S-Left> v0
inoremap <M-S-Left> <C-O>v0
vnoremap <M-S-Left> 0

" Alt-Shift-Right selects from cursor to end of line
" (same as Shift-End)
noremap <M-S-Right> v$
inoremap <M-S-Right> <C-O>v$
vnoremap <M-S-Right> $

" ------------------------------------------------------
" A Smarter Select
" ------------------------------------------------------

" Ctrl-Shift-PageUp selects from cursor to first line of window
noremap <C-S-PageUp> vH
inoremap <C-S-PageUp> <C-O>vH
cnoremap <C-S-PageUp> <C-C>vH
onoremap <C-S-PageUp> <C-C>vH
vnoremap <C-S-PageUp> H
" (And so does Alt-Shift-Up)
noremap <M-S-Up> vH
inoremap <M-S-Up> <C-O>vH
cnoremap <M-S-Up> <C-C>vH
onoremap <M-S-Up> <C-C>vH
vnoremap <M-S-Up> H

" Ctrl-Shift-PageDown selects from cursor to last line of window
noremap <C-S-PageDown> vL
inoremap <C-S-PageDown> <C-O>vL
cnoremap <C-S-PageDown> <C-C>vL
onoremap <C-S-PageDown> <C-C>vL
vnoremap <C-S-PageDown> L
" (And so does Alt-Shift-Down)
noremap <M-S-Down> vL
inoremap <M-S-Down> <C-O>vL
cnoremap <M-S-Down> <C-C>vL
onoremap <M-S-Down> <C-C>vL
vnoremap <M-S-Down> L

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
noremap <C-Up> <C-y>
inoremap <C-Up> <C-O><C-y>
cnoremap <C-Up> <C-C><C-y>
onoremap <C-Up> <C-C><C-y>
noremap <C-Down> <C-e>
inoremap <C-Down> <C-O><C-e>
cnoremap <C-Down> <C-C><C-e>
onoremap <C-Down> <C-C><C-e>

" ------------------------------------------------------
" Quick Cursor Jumping
" ------------------------------------------------------

" EditPlus, among other editors, maps Ctrl-PageUp
" and Ctrl-PageDown to moving the cursor to the 
" top and bottom of the window (equivalent to 
" H and L in Vim (which also defines M to jump 
" to the middle of the window, which is not 
" mapped here)).
" NOTE In a lot of programs, C-PageUp/Down go to 
"      next/previous tab page; not so here, see
"      Alt-PageUp/Down for that.
"      FIXME 2011.01.16 Alt-PageUp/Down is broken...
"            (well, that, and I never use it)
noremap <C-PageUp> :call <SID>Smart_PageUpDown(1)<CR>
inoremap <C-PageUp> <C-O>:call <SID>Smart_PageUpDown(1)<CR>
noremap <C-PageDown> :call <SID>Smart_PageUpDown(-1)<CR>
inoremap <C-PageDown> <C-O>:call <SID>Smart_PageUpDown(-1)<CR>

" On my laptop, my right hand spends a lot of time near 
" (and using) the arrow keys, which are on the bottom 
" of the keyboard, but the other navigation keys (home, 
" end, page up and down and the ilk) are far, far away, 
" at the top of the keyboard. But we can map those to 
" Alt-Arrow Key combinations to make our hands happy
" (or is it to make our fingers frolicsome?).

" Alt-Up moves cursor to the top of the window, or, if 
" it's already there, it scrolls up one window.
noremap <M-Up> :call <SID>Smart_PageUpDown(1)<CR>
inoremap <M-Up> <C-O>:call <SID>Smart_PageUpDown(1)<CR>
vnoremap <M-Up> :<C-U>
  \ <CR>gvy
  \ :call <SID>Smart_PageUpDown(1)<CR>

" Alt-Down moves cursor to the bottom of the window, or, if 
" it's already there, it scrolls down one window.
noremap <M-Down> :call <SID>Smart_PageUpDown(-1)<CR>
inoremap <M-Down> <C-O>:call <SID>Smart_PageUpDown(-1)<CR>
vnoremap <M-Down> :<C-U>
  \ <CR>gvy
  \ :call <SID>Smart_PageUpDown(-1)<CR>

" Alt-Left moves the cursor to the beginning of the line.
noremap <M-Left> <Home>
inoremap <M-Left> <C-O><Home>
vnoremap <M-Left> :<C-U>
  \ <CR>gvy
  \ :execute "normal! 0"<CR>

" Alt-Right moves the cursor to the end of the line.
noremap <M-Right> <End>
inoremap <M-Right> <C-O><End>
vnoremap <M-Right> :<C-U>
  \ <CR>gvy
  \ :execute "normal! $"<CR>

function s:Smart_PageUpDown(direction)
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

" 2011.01.16 Will I find this useful?
" Alt-End moves the cursor to the middle of the window.
" And starts editing.
"noremap <M-End> M0i
"inoremap <M-End> <C-O>M<C-O>0
"vnoremap <M-End> :<C-U>
"  \ <CR>gvy
"  \ :execute "normal! M0"<CR>
noremap <M-F12> M0i
inoremap <M-F12> <C-O>M<C-O>0
vnoremap <M-F12> :<C-U>
  \ <CR>gvy
  \ :execute "normal! M0"<CR>

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
" NOTE Same as <C-F3>
vnoremap <F1> :<C-U>
  \ <CR>gvy
  \ gV
  \ /<C-R>"<CR>

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
  \ /<C-R>"<CR>
  \ ?<CR>

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
vnoremap <F3> :<C-U>
  \ <CR>gvy
  \ gV
  \ /<C-R>"<CR>
" Backwards:
noremap <S-F3> ?<CR>
inoremap <S-F3> <C-O>?<CR>
"vnoremap <S-F3> <ESC>gVN
" Remember, ? is the opposite of /
vnoremap <S-F3> :<C-U>
  \ <CR>gvy
  \ gV
  \ ?<C-R>"<CR>?<CR>

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

nmap <silent> <Plug>VLToggle :let g:VeryLiteral = !g:VeryLiteral
  \\| echo "VeryLiteral " . (g:VeryLiteral ? "On" : "Off")<CR>
if !hasmapto("<Plug>VLToggle")
  nmap <unique> <Leader>vl <Plug>VLToggle
endif
let &cpo = s:save_cpo | unlet s:save_cpo

" ------------------------------------------------------
" Ctrl-H Hides Highlighting
" ------------------------------------------------------

" Once you initiate a search, Vim highlights all matches.
" Type Ctrl-H to turn 'em off.

" Vim's default Ctrl-H is the same as <BS>.
" It's also the same as h, which is the 
" same as <Left>. WE GET IT!! Ctrl-H won't 
" be missed....
" NOTE Highlighting is back next time you search.
" NOTE Ctrl-H should toggle highlighting (not 
"      just turn it off), but nohlsearch doesn't 
"      work that way
noremap <C-h> :nohlsearch<CR>
inoremap <C-h> <C-O>:nohlsearch<CR>
cnoremap <C-h> <C-C>:nohlsearch<CR>
onoremap <C-h> <C-C>:nohlsearch<CR>
" (NEWB|NOTE: From Insert mode, Ctrl-o
"  is used to enter one command and 
"  execute it. If it's a :colon 
"  command, you'll need a <CR>, too.
"  Ctrl-c is used from command and
"  operator-pending modes.)

" ------------------------------------------------------
" Map <Leader>tab to Toggling Tab Highlighting
" ------------------------------------------------------

if !hasmapto('<Plug>DS_ToggleTabHighlighting')
  map <silent> <unique> <Leader>tab
    \ <Plug>DS_ToggleTabHighlighting
endif
" Map <Plug> to an <SID> function.
map <silent> <unique> <script> 
  \ <Plug>DS_ToggleTabHighlighting 
  \ :call <SID>DS_ToggleTabHighlighting()<CR>
" The function.
function s:DS_ToggleTabHighlighting()
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
    :hi Tab gui=underline guifg=blue ctermbg=blue
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
function s:TransposeCharacters()
  let cursorCol = col('.')
  if 1 == cursorCol
    execute 'normal ' . 'xp'
  else
    execute 'normal ' . 'Xp'
  endif
endfunction
inoremap <C-T> 
  \ <C-o>:call <SID>TransposeCharacters()<CR>
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

" ------------------------------------------------------
" Ctrl-P/Ctrl-L Moves Paragraphs
" ------------------------------------------------------

" 2012.08.19: Move paragraphs up and down, like how that
"             one popular app lets you move notes around.

" Move the paragraph under the cursor up a paragraph.
function s:MoveParagraphUp()
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

noremap <C-p> :call <sid>MoveParagraphUp()<CR>
inoremap <C-p> <C-O>:call <sid>MoveParagraphUp()<CR>
cnoremap <C-p> <C-C>:call <sid>MoveParagraphUp()<CR>
onoremap <C-p> <C-C>:call <sid>MoveParagraphUp()<CR>
noremap <C-l> :call <sid>MoveParagraphDown()<CR>
inoremap <C-l> <C-O>:call <sid>MoveParagraphDown()<CR>
cnoremap <C-l> <C-C>:call <sid>MoveParagraphDown()<CR>
onoremap <C-l> <C-C>:call <sid>MoveParagraphDown()<CR>

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
vnoremap <S-F2> :<C-U>'<,'>!parT 59qr<CR>
" 2014.11.25: Can we also throw in seventy-wides?
"vnoremap <C-S-F2> :<C-U>'<,'>!par 69gqr<CR>
"vnoremap <C-S-F2> :<C-U>'<,'>!par 69qr<CR>
vnoremap <C-S-F2> :<C-U>'<,'>!parT 69qr<CR>
" 2015.11.25: 64? Hrmm
vnoremap <C-S-F3> :<C-U>'<,'>!parT 64qr<CR>
vnoremap <C-S-F4> :<C-U>'<,'>!parT 74qr<CR>

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
"             than a hard-coded with.
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
vnoremap <M-S-F2> :<C-U>execute "'<,'>!par " . (virtcol("$") - 1) . "qr"<CR>

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
:noremap <Leader>s "sy:.,$s/<C-r>s//gc<Left><Left><Left>

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

" Alt-Shift-1 // Toggle Cliptext
" --------------------------------
" EditPlus has a cool ANSI chart you can bring up 
" quickly (who isn't always referring to ANSI 
" charts?). Our Vim substitute is an even 
" awesomer interactive ASCII table by Christian 
" Habermann,
"  CharTab <http://www.vim.org/scripts/script.php?script_id=898>
" NOTE Does not work: nnoremap <M-!> <Leader>ct
" SYNC_ME: Dubsacks' <M-????> mappings are spread across plugins. [M-S-1]
nmap <M-!> <Leader>ct
imap <M-!> <C-o><Leader>ct<ESC>
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

" Alt-Shift-6 // Toggle Tag List
" --------------------------------
" Show the ctags list.
" SYNC_ME: Dubsacks' <M-????> mappings are spread across plugins. [M-S-6]
nmap <M-^> :TlistToggle<CR>
imap <M-^> <C-O>:TlistToggle<CR>
"cmap <M-^> <C-C>TlistToggle<ESC>
"omap <M-^> <C-C>TlistToggle<ESC>

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Developer Features -- Tags
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" FIXME: We really need a better way to do this, like, on a per-project
"        basis... auto-unload and -reload of tags when you start working
"        on a file in a different project?? There's gotta be a plugin for
"        this already...

" FIXME: Make DRY. This fcn. was copied from elsewhere.

" See if the user made a project search listing and use that.
let s:d_tags = findfile('dubs_tagpaths.vim',
                       \ pathogen#split(&rtp)[0] . "/**")
if s:d_tags != ''
  " Turn into a full path. See :h filename-modifiers
  let s:d_tags = fnamemodify(s:d_tags, ":p")
else
  " No file, but there should be a template we can copy.
  let s:tmplate = findfile('dubs_tagpaths.vim.template',
                         \ pathogen#split(&rtp)[0] . "/**")
  if s:tmplate != ''
    let s:tmplate = fnamemodify(s:tmplate, ":p")
    " See if dubs_all is there.
    let s:dubcor = fnamemodify(
      \ finddir('dubs_all', pathogen#split(&rtp)[0] . "/**"), ":p")
    " Get the filename root, i.e., drop the ".template".
    let s:d_tags = fnamemodify(s:tmplate, ":r")
    " Make a copy of the template.
    silent execute '!/bin/cp ' . s:tmplate . ' ' . s:d_tags
    if isdirectory(s:dubcor)
      let s:ln_tags = s:dubcor . '/' . fnamemodify(s:tmplate, ":t:r")
      silent execute '!/bin/ln -s ' . s:d_tags . ' ' . s:ln_tags
    endif
  else
    echomsg 'Warning: Dubsacks could not find dubs_tagpaths.vim.template'
  endif
endif
if s:d_tags != ''
  execute 'source ' . s:d_tags
else
  echomsg 'Warning: Dubsacks could not find dubs_tagpaths.vim'
endif

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Setup ctags
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ------------------------------------------------------
" Jump to tag under cursor
" ------------------------------------------------------

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
set tags=./tags
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
noremap Q @q

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
"   :Ta<TAB> invokes autocompletion
"   :ta<TAB><TAB> also works.

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
" <Leader>-O opens hyperlink under cursor or selected.
" ------------------------------------------------------

" Link to Web page under cursor.
" :!firefox cycloplan.cyclopath.org &> /dev/null
noremap <silent> <Leader>o :!firefox <C-R><C-A> &> /dev/null<CR><CR>
inoremap <silent> <Leader>o <C-O>:!firefox <C-R><C-A> &> /dev/null<CR><CR>
" Interesting: C-U clears the command line, which contains cruft, e.g., '<,'>
" gv selects the previous Visual area.
" y yanks the selected text into the default register.
" <Ctrl-R>" puts the yanked text into the command line.
vnoremap <silent> <Leader>o :<C-U>
  \ <CR>gvy
  \ :!firefox <C-R>" &> /dev/null<CR><CR>
" Test the three modes using: https://github.com/p6a

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

" ------------------------------------------------------
" Insert today's date. 2016-07-12: [lb] tired of doing this manually.
" ------------------------------------------------------

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
" "The uppercase P at the end inserts before the current character,
" which allows datestamps inserted at the beginning of an existing line."
":nnoremap <F5> "=strftime("%Y-%m-%d")<CR>P
":inoremap <F5> <C-R>=strftime("%Y-%m-%d")<CR>
"
" Re: <expr>, see:
"  http://vimdoc.sourceforge.net/htmldoc/map.html#:map-expression
:iabbrev <expr> TTT strftime("%Y-%m-%d")

