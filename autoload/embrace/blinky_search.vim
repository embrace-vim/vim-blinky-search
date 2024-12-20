" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Landon Bouma <https://tallybark.com/> 
" Project: https://github.com/landonb/dubs_edit_juice#🧃
" License: GPLv3

" -------------------------------------------------------------------
  
" USAGE: After editing this file, disable this `finish`, then
" press <F9> to reload this file.
" - CXREF: https://github.com/landonb/vim-source-reloader
if exists("g:plugin_edit_juice_vim") || &cp
  finish
endif
let g:plugin_edit_juice_vim = 1

" -------------------------------------------------------------------

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
"        the cursor (inserted by <C-R><C-W>). It doesn't include path
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
" CALSO: The '*'/'#' vmaps (below) can ignore whitespace when searching,
"        and they work across multiple lines, unlike <F1> vmap.
vnoremap <F1> :<C-U>
  \ <CR>gvy
  \ gV
  \ /<C-R>=substitute("<C-R>"", "/", "\\\\/", "g")<CR><CR>

" -------------------------------------------------------------------

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

" -------------------------------------------------------------------

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

" -------------------------------------------------------------------

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

" -------------------------------------------------------------------

" ------------------------------------------------------
" VSearch
" ------------------------------------------------------

" This function is based on Vim Tip 171
"   Search for visually selected text
" http://vim.wikia.com/wiki/Search_for_visually_selected_text
"
" This complements the built-in '*' and '#' commands
" by enabling a similar features in select mode.
"
" - When g:VeryLiteral is toggled off, ignores differences
"   in whitespace, e.g., finds both 'foo bar' and 'foo   bar'.
" - When g:VeryLiteral is toggled on, accounts for whitespace.
" - In either case, supports multiline search term, i.e., you
"   can select text across multiple lines and search that.
"
" CALSO: <F1> vmap, which is always literal and doesn't work across lines.

" The Simple, Less Functional Implementation
" ------------------------------------------
"
"   " Search for selected text, forwards or backwards.
"   vnoremap <silent> * :<C-U>
"   \ let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
"   \ gvy/<C-R><C-R>=substitute(
"   \ escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
"   \ gV:call setreg('"', old_reg, old_regtype)<CR>
"
"   vnoremap <silent> # :<C-U>
"   \ let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
"   \ gvy?<C-R><C-R>=substitute(
"   \ escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
"   \ gV:call setreg('"', old_reg, old_regtype)<CR>

" Search for selected text.
" - Note unless g:VeryLiteral that whitespace is ignored, e.g.,
"   searching 'foo   bar   baz' also finds 'foo bar baz'.
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
      " Change actual newlines to escape sequence for multi-line
      " search term to work.
      let pat = substitute(pat, '\n', '\\n', 'g')
    else
      " Ignore differences in whitespace when searching.
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
" HSTRY/2024-12-09: Was <Leader>vl but I've been coalescing Dubs Vim
" <Leader> commands under the same first character, \d, esp. because
" I rarely use most of these maps.
"   - Mnemonic: \ds → Dubs Search (eh?)
if !hasmapto("<Plug>DubsEditJuice_VLToggle")
  nmap <unique> <Leader>ds <Plug>DubsEditJuice_VLToggle
endif
noremap <silent> <Plug>DubsEditJuice_VLToggle :let g:VeryLiteral = !g:VeryLiteral
  \\| echo "VeryLiteral " . (g:VeryLiteral ? "On" : "Off")<CR>
let &cpo = s:save_cpo | unlet s:save_cpo

" -------------------------------------------------------------------

