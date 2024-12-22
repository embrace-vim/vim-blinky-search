" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Landon Bouma <https://tallybark.com/> 
" Project: https://github.com/landonb/vim-blinky-search#🕹
" License: GPLv3
" Copyright © 2015, 2017-2018, 2024 Landon Bouma.
" Summary: Visual search bindings with fancy additional features.

" -------------------------------------------------------------------

" DEVEL: After editing this file, :source it, then :source the loader
" to redeploy all yours maps:
"
"   :source ~/.vim/pack/embrace-vim/start/vim-blinky-search/plugin/vim-blinky-search.vim

" -------------------------------------------------------------------

" Probably unnecessary in this day and age...
let s:save_cpo = &cpo | set cpo&vim

" -------------------------------------------------------------------

" ------------------------------------------------------
" Start g*-like substring search, and jump to next match
" ------------------------------------------------------

" A Vim star search searches for the exact word under the cursor,
" e.g., using "\<" and "\>" word boundaries. It uses :iskeyword
" to identify the keyword under the cursor.
"
" A Vim gstar search, on the other hand, omits the "\<" and "\>"
" so that the search term also find substrings, e.g., "foo" finds
" "foobar".

" REFER: The easy way to get the word under the cursor is to invoke insert
" (paste) on object under the cursor (<Ctrl-R>) and to select the Word under
" the cursor (<Ctrl-W>). This command uses :iskeyword to find the boundary.
" :help c_CTRL-R_CTRL-W
" - Compare this to the <C-R><C-A>, which picks the WORD under the cursor
"   and uses using abutting whitespace as the boundary (and is not
"   configurable).)
" - USAGE: If this selects more characters than you want, check :set iskeyword
"
" REFER: Here's another way to select the current word under the cursor:
"   " b goes to start of word,
"   " "zyw yanks into the z register to start of next word
"   :nnoremap <F1> b"zyw:echo 'The word is: ' .. @z<CR>

" Map a sequence (defaults <F1>) to essentially g* but with more flexibility.
function! g:embrace#blinky_search#CreateMaps_GStarSearch(key_sequence = '<F1>') abort
  execute 'noremap ' .. a:key_sequence .. ' /<C-R><C-W><CR>'
  execute 'inoremap ' .. a:key_sequence .. ' <C-O>/<C-R><C-W><CR>'

  let l:cmd = '/'
  let l:jump = 1
  call g:embrace#blinky_search#CreateMaps_GStarSearch_VisualMode(a:key_sequence, l:cmd, l:jump)
endfunction

" -------------------------------------------------------------------

" When user selects text, a nice UX is to assume that any search command
" intends to start a new search.
" - Then the user can use either sequence to start a new search when
"   thev're selected something.
" - E.g., if user selects text and presses 'n' or 'N', don't jump per the
"   *old* search pattern. Instead, treat the selection as if the user had
"   pressed '*', '#', 'g*', or 'g#', and start a new '/' search.
" - In the case of the <F1> and <F3> maps, <F1> is always used to start a
"   new search (from normal, insert, visual, and select modes). And <F3>
"   *sometimes* jumps to the next match (from normal and insert mode),
"   but if something is selected (from visual and select modes), then
"   <F3> behaves like <F1>.

" DEVEL: Toggle this on to experience alternative impl.
let s:gstar_search_be_naive = 0

function! g:embrace#blinky_search#CreateMaps_GStarSearch_VisualMode(
  \ key_sequence, cmd = '/', jump = 0, restrict_word = 0, multicase = 0
\ ) abort
  if s:gstar_search_be_naive
    " Mostly for posterity, to better understand how this all works.
    let l:postfix = jump ? (foo == '/' ? '?' : '/') .. '<CR>' : ''
    call g:embrace#blinky_search#CreateMaps_GStarSearch_VisualBasic(a:key_sequence, a:cmd, l:postfix)
  else
    " Visual mode map modes:
    " - After `:<C-U><CR>`, `:echo mode(1)<CR>` reports mode is 'n'.
    " - To run, e.g., type `ve<F3>` to (visual) select a word + <F3>.
    " REMEM: The colon starts a visual search which Vim prefixes '<,'>,
    " that we <C-U> delete to start of line. Then we call a fcn.
    " to do all the work.
    let l:postfix = ''
    if a:jump
      " E.g., `/<CR>` or `?<CR>`.
      let l:postfix = a:cmd .. '<CR>'
    endif
    execute 'xnoremap <silent> ' .. a:key_sequence .. ' '
      \ .. ':<C-U><CR>'
      \ .. ':call g:embrace#visual_search#SetSearch("' .. a:cmd .. '", '
                \ .. a:restrict_word .. ', ' .. a:multicase .. ')<CR>'
      \ .. l:postfix

    " ***

    " Select mode map modes:
    " - mode(1) is 'n' after double-click from normal mode + <F3>.
    " - mode(1) is 'niI' after double-click from insert mode + <F3>.
    " Some nuances:
    " - At first I tried <CR>/<CR> at the end, but that only works from
    "   normal mode selection.
    "   - E.g., `...#SetSearch("/")<CR>/<CR>`
    " - So then I tried <C-O>/<CR>, which works from an insert mode
    "   selection. But from normal mode, the <C-O> does what <C-O> does
    "   from normal mode, and jumps to the previous cursor position from
    "   the jump list.
    " - I then tried `\| execute "normal /\<CR>"` to chain the :call,
    "   but within a mapping, you need to escape that backward slash.
    "   E.g., `execute "normal /<lt>CR>"` (see :help <>).
    "   - But that didn't work — it actually just doesn't do anything.
    "     - If you remove `\| execute "normal /<lt>CR>"`, the behavior
    "       is the same: the selection matches are highlighted, and the
    "       mode changes back to insert mode, but the cursor doesn't
    "       move (it stays at the start of the previous selection).
    "   - So I changed the <lt> to <C-V>< and (TG!) now it works.
    "     - "Insert next non-digit literally. For special keys, the
    "        terminal code is inserted.... The characters typed right
    "        after CTRL-V are not considered for mapping."
    "         :h i_CTRL-V
    "     - Though I'm not sure why this works from normal mode selection,
    "       because CTRL-V starts blockwise select. Or if you mswin.vim,
    "       then <C-Q> is blockwise select and <C-V> is paste.
    "         :h blockwise-visual | :h CTRL-V
    "       - It might just be that the execute command itself runs in
    "         insert mode. You can run it manually to see: Start insert
    "         mode and <C-O> to run a command. Then type the execute cmd,
    "         `:execute "normal /` and presses <C-V> then <Enter>, and Vim
    "         adds the control character. Finish with `"` and hit <Enter>,
    "         and you'll run the /-search command.
    "         - So definitely :h i_CTRL-V applies to at least parts of the
    "           map command as it's been interpreted.
    " " This works, and jumps forward.
    "     execute 'snoremap ' .. a:key_sequence .. ' '
    "       \ .. '<C-G>:<C-U><CR>'
    "       \ .. ':call g:embrace#visual_search#SetSearch("/") \| execute "normal /<C-V><CR>"<CR>'
    let l:postfix = ''
    if a:jump
      " E.g., `/<CR>` or `?<CR>`.
      let l:postfix = ' \| execute "normal ' .. a:cmd .. '<C-V><CR>"'
    endif
    execute 'snoremap <silent> ' .. a:key_sequence .. ' '
      \ .. '<C-G>:<C-U><CR>'
      \ .. ':call g:embrace#visual_search#SetSearch("' .. a:cmd .. '", '
                \ .. a:restrict_word .. ', ' .. a:multicase .. ')'
      \ .. l:postfix .. '<CR>'
  endif
endfunction

" ***

" HSTRY: A *basic* implementation of the *visual*/select mode command.
" - The colon starts a visual search which Vim prefixes '<,'>,
"   that we <C-U> delete to start of line.
" - Then we escape command mode and `gv` to reselect the selection
"   and `y` yank it into the unnamed register.
" - Then we `gV` to "avoid the automatic reselection of the Visual area
"   after a Select mode mapping ... has finished." Which is something
"   you do after any operations on the selection.
" - Then we start a /-search `/` and use the expression register <C-R>=
"   to run the `substitute()<CR>` command and paste its response as the
"   input to the /-search and <CR> run the search.
"   - The substitute() is called with the <C-R>" unnamed register,
"     and we escape single "/" forward slashes with two backward
"     slashes which looks like four "\\\\/" because the string
"     we use to make the map eats two of 'em.
" - Note we omit the \< ... \> in the visual mode version of this
"   map, because we want to use the user selection verbatim.
" - HSTRY: Escape forward-slashes.
"   - Because we know the user has not *typed* the query themselves,
"     we can insert escape characters so that if the selection
"     contains forward-slases, they don't break the search (if left
"     unescaped, the search still works, but it won't match any
"     characters after the first unescaped forward slash, effectively
"     truncated the search term).
"   - Here's that basic approach used for eons in this code:
"       /<C-R>"<CR>
"     before adding the =substitute().
"   - UTEST: this/foo/ finds within this/foo/bar/bar/.
function! g:embrace#blinky_search#CreateMaps_GStarSearch_VisualBasic(
  \ key_sequence, cmd = '/', postfix = ''
\ ) abort
  execute 'vnoremap ' .. a:key_sequence .. ' '
    \ .. ':<C-U>'
    \ .. '<CR>gvy'
    \ .. 'gV'
    \ .. cmd .. '<C-R>=substitute("<C-R>"", "' .. cmd .. '", "\\\\' .. cmd .. '", "g")<CR><CR>'
    \ .. postfix
endfunction

" ***

" HSTRY: Here's another alternative implementation.
" - Enable copy-on-select, then paste from the clipboard register.
" - I find this novel, but copy-on-select makes for bad UX, IMHO,
"   although author *does* use copy-on-select in the terminal.
"   (Though generally, keep outta my clipboard!)
"
" " This only works if guioptions has 'a' option to automatically
" " copy selected text to the clipboard register.
" "   " @/          — Set the search register
" "   " ="          — ... Equal to a string
" "   <C-R>=        — ... Using the expression register
" "   g:...(@*)<CR> — ... To call a function
" "         @*      — ... That we pass the clipboard contents
" "   "<CR>         — Evaluate the expression register ("prints"
" "                   it and sets as value of search register)
" "   :set hls<CR>  — Show highlights
" function! s:CreateMaps_GStarSearchStayPut_UsingClipboardHack(key_sequence) abort
"   execute 'vnoremap ' .. a:key_sequence .. ' '
"     \ .. ':<C-U>let @/="<C-R>=g:embrace#blinky_search#EscapePattern(@*)<CR>"<CR>:set hls<CR>'
" endfunction
"
" " DRY: This is shared with dubs_grep_steady/dubs_edit_juice.
" function! g:embrace#blinky_search#EscapePattern(text = '') abort
"   if a:text
"     let l:pat = escape(a:text, '\')
"   else
"     let l:pat = escape(@@, '\')
"   endif
"
"   " CXREF: This procedure is almost identical to what's live in
"   "  g:embrace#visual_search#SetSearch()
"
"   " REFER: \_s is \s character class with end-of-line added.
"   " - Replace trailing whitespace with \s* to match any/no trailing whitespace.
"   let l:pat = substitute(l:pat, '\_s\+$', '\\s\\*', '')
"   " - Replace leading whitespace with \s* to match any/no leading whitespace.
"   let l:pat = substitute(l:pat, '^\_s\+', '\\s\\*', '')
"   " - Replace one more inner whitespace with \s* to match any/none between other tokens.
"   let l:pat = substitute(l:pat, '\_s\+',  '\\_s\\+', 'g')
"
"   " Add to /-search and grep search history.
"   call histadd("search", l:pat)
"   call histadd("input", l:pat)
"
"   " - REFER:
"       - '\V' is "very nomagic". Only a backslash and the terminating
"   "     character (usually / or ?) have special meaning after it.
"   "       :help /magic
"   "   - escape() both '"' and '\' characters.
"   "     - Which double-escapes '\' because of escape above.
"   let l:pat = '\V' . escape(l:pat, '\"')
"
"   return l:pat
" endfunction

" -------------------------------------------------------------------

" ------------------------------------------------------
" Start a whole-word *-like search, and stay put
" ------------------------------------------------------

" Start a search with the word under the cursor, but don't jump.
" only highlight matches. Naive approach is `*?`, but that can
" affect scroll (or maybe at least flicker).
" - Below is the star version (not g*) of this function, which author
"   would contend is the more popular variant for stay-put searches.
"   - Or at least when I want a fuzzier search, then I select text.
"
" REFER/2017-11-12: Adapted from "Highlight all search pattern matches"
"   http://vim.wikia.com/wiki/Highlight_all_search_pattern_matches

" UTEST/2024-12-20: Ensure starting stay-put search doesn't center
" the highlight like s:CreateMaps_GStarSearchStayNaive() will do.
" 
" - If the next match is offscreen, and if window isn't already
"   scrolled to the top of the buffer, a naive approach, such as
"   `*?`, will jump forward, then back. And on back it will redraw
"   the match user is trying to highlight in the middle of the window.
" 
"   LEAVE_THIS_FOR_TESTING    <-- Try a stay-put search on this
"
" HSTRY/2024-12-20: Here's the naive approach, which jumps fwd, then bwd.
"
"     " 2013.02.28: Search for the whole-word under the cursor, but return
"     " to the word under the cursor. <F1> alone starts searching, but some-
"     " times you want to highlight whole-words without losing your position.
"     " - SAVVY: `?` returns to prev match, where cursor was before `*` moved it.
"     function! s:CreateMaps_GStarSearchStayNaive(key_sequence = '<S-F1>') abort
"       execute 'noremap ' .. a:key_sequence .. ' *?<CR>'
"       execute 'inoremap ' .. a:key_sequence .. ' <C-O>*<C-O>?<CR>'
"       execute 'vnoremap ' .. a:key_sequence .. ' '
"         \ .. ':<C-U>'
"         \ .. '<CR>gvy'
"         \ .. 'gV'
"         \ .. '/<C-R>=substitute("<C-R>"", "/", "\\\\/", "g")<CR><CR>'
"         \ .. '?<CR>'
"     endfunction
" map

function! g:embrace#blinky_search#CreateMaps_StarSearchStayPut(key_sequence = '<S-F1>') abort
  " restrict_word = 1, multicase = 0, toggle_highlight = 0
  nnoremap <silent> <expr> <Plug>(blinky-search-wson-mcon-tgoff)
    \ g:embrace#blinky_search#StartSearchStayPut(1, 0, 0)
  execute 'nnoremap <silent> ' .. a:key_sequence .. ' <Plug>(blinky-search-wson-mcon-tgoff)'
  execute 'inoremap <silent> ' .. a:key_sequence .. ' <C-O><Plug>(blinky-search-wson-mcon-tgoff)'

  let l:cmd = '/'
  let l:jump = 0
  let l:restrict_word = 1
  let l:multicase = 0
  call g:embrace#blinky_search#CreateMaps_GStarSearch_VisualMode(
    \ a:key_sequence, l:cmd, l:jump, l:restrict_word, l:multicase
    \ )
endfunction

function! g:embrace#blinky_search#CreateMaps_GStarSearchStayPut(key_sequence = '<F8>') abort
  " restrict_word = 0, multicase = 1, toggle_highlight = 0
  nnoremap <silent> <expr> <Plug>(blinky-search-wsoff-mcon-tgoff)
    \ g:embrace#blinky_search#StartSearchStayPut(0, 1, 0)
  execute 'nnoremap <silent> ' .. a:key_sequence .. ' <Plug>(blinky-search-wsoff-mcon-tgoff)'
  execute 'inoremap <silent> ' .. a:key_sequence .. ' <C-O><Plug>(blinky-search-wsoff-mcon-tgoff)'

  let l:cmd = '/'
  let l:jump = 0
  let l:restrict_word = 0
  let l:multicase = 1
  call g:embrace#blinky_search#CreateMaps_GStarSearch_VisualMode(
    \ a:key_sequence, l:cmd, l:jump, l:restrict_word, l:multicase
    \ )
endfunction

" ***

" HSTRY: This shows how to add Normal and Insert mode maps using the
" map command to do all the word. It's similar to StartSearchStayPut
" except that StartSearchStayPut uses `map <expr> <Plug>` to call a
" function, whereas this just does it all inline. (And we prefer the
" fcn. because we want to get *complicated* (search all the cases).)
"
"   function! s:CreateMaps_SearchStayPut_NormalAndInsertMode(key_sequence) abort
"     " Assign the pattern to the search register (@/), use to update
"     " search history, and enable match highlighting.
"     " - Note this is "\<string\>".
"     let l:capture_word = ''
"       \ .. ":let curwd='\\<<C-R>=expand(\"<cword>\")<CR>\\>'<CR>"
"     let l:set_search_register = ''
"       \ .. ':let @/=curwd<CR>'
"     " Note we don't update 'input' history like visual search does.
"     " - Because user can usually grep word under cursor easily,
"     "   whereas visual search 'input' history update escapes the
"     "   input as necessary.
"     let l:set_histadd = ''
"       \ .. ':call histadd("search", curwd)<CR>'
"     let l:set_hlsearch = ''
"       \ .. ':set hls<CR>'
"
"     execute 'noremap ' .. a:key_sequence .. ' '
"       \ .. l:capture_word
"       \ .. l:set_search_register
"       \ .. l:set_histadd
"       \ .. l:set_hlsearch
"
"     execute 'inoremap ' .. a:key_sequence .. ' '
"       \ .. '<C-O>' .. l:capture_word
"       \ .. '<C-O>' .. l:set_search_register
"       \ .. '<C-O>' .. l:set_histadd
"       \ .. '<C-O>' .. l:set_hlsearch
"   endfunction

" ***

" Make [Enter] toggle highlighting for the current word on and off.
" - Same source as StayPut() functions above:
"   http://vim.wikia.com/wiki/Highlight_all_search_pattern_matches
" THOTS/2018-06-27: This is not so bad.

let s:is_highlighting = 0

function! g:embrace#blinky_search#StartSearchStayPut(
  \ restrict_word = 0, multicase = 0, toggle_highlight = 0,
\ ) abort
  if &ft == 'qf'
    " Don't break quickfix <Enter>.

    return 0
  endif

  " ***

  let l:the_term = expand('<cword>')

  if !a:restrict_word
    let l:restricted_term = l:the_term
  else
    let l:restricted_term = '\<' .. l:the_term .. '\>'
  endif

  " ***

  " Add the word-under-cursor to the search history.
  call histadd('/', l:the_term)
  " Also add a strict version of it.
  call histadd('/', l:restricted_term)

  " Also add to the input history, so it's ready for :grep. E.g., user
  " might initiate search in buffer and then decide to grep all files.
  call histadd('input', l:the_term)
  " Add the word-restricted form last.
  call histadd('input', '\b' .. l:the_term .. '\b')

  " ***

  let [l:vim_pat, l:grep_pat] = g:embrace#visual_search#CaseTheJoint(l:the_term, a:restrict_word, a:multicase)

  " ***

  call histadd('search', l:vim_pat)
  call histadd('input', l:grep_pat)

  " TRYME: Try these: testMe test_me test-me test-me-not testMeNot test_me_NOT testme
  " - For /-search and :grep testing (one test term per line)
  " - E.g., select 'test-me' and hit <F8>.
  "     testMe
  "     test_me
  "     test-me
  "     test-me-not
  "     testMeNot
  "     test_me_NOT
  "     testme

  " ***

  " HSRTY: Without |'d terms:
  "   if s:is_highlighting == 1 && @/ =~ '^\\<'.l:the_term.'\\>$'

  if a:toggle_highlight
      \ && s:is_highlighting == 1
      \ && @/ =~ l:vim_pat
    " Same term as last time, so toggle off.
    let s:is_highlighting = 0

    return ":silent nohlsearch\<CR>"
  endif

  " HSRTY: Without |'d terms:
  "   let @/ = l:restricted_term

  let @/ = l:vim_pat

  if a:toggle_highlight
    let s:is_highlighting = 1
  endif

  return ":silent set hlsearch\<CR>"
endfunction

" SAVVY: This overrides Vim's built-in <CR>, which also overides
"        the <Ctrl-M>/<C-M> command ([count] lines downward).
"        - But you can still use `[count]+`, or perhaps better
"          yet, `[count]↓` also jumps [count] lines downward.
"        - So don't be surprised when <C-M> also highlights.
function! g:embrace#blinky_search#CreateMaps_ToggleHighlight(key_sequence = '<CR>') abort
  " restrict_word = 1, multicase = 1, toggle_highlight = 1
  nnoremap <silent> <expr> <Plug>(blinky-search-toggle-restrict)
    \ g:embrace#blinky_search#StartSearchStayPut(1, 1, 1)

  execute 'nnoremap <silent> ' .. a:key_sequence .. ' <Plug>(blinky-search-toggle-restrict)'
endfunction

" -------------------------------------------------------------------

" Repeat previous search fwd and back.

"   HSTRY: Previous <F3> maps
"   --------------------------------
"
"   - Author long, long ago, and probably for not long,
"     used <F3> and <S-F3> as simple * and #`shortcuts.
"
"       noremap <F3> *
"       inoremap <F3> <C-O>*
"       " cnoremap <F3> :<C-R><C-W>*
"       " onoremap <F3> :<C-R><C-W>*
"
"       noremap <S-F3> #
"       inoremap <S-F3> <C-O>#
"       " cnoremap <S-F3> <C-O>#
"       " onoremap <S-F3> <C-O>#
"
"   - I later moved * to <C-F3>, then to <F1>, and I dropped
"     the # map. And I used <F3> and <S-F3> for next/prev match.
"
"       noremap <F3> n
"       noremap <S-F3> N
"
"     But n and N are relative to the previous search. I.e., if you
"     start a search backwards ? then press n, the search keeps going
"     backwards. And N goes the opposite way. So we use / and ? so
"     that <F3> always matches forward, and <Shift-F3> backwards.

function! g:embrace#blinky_search#CreateMaps_SearchForward(key_sequence = '<F3>') abort
  " SAVVY: Using /<CR> instead of n because n repeats the last / OR ?
  execute 'noremap ' .. a:key_sequence .. ' /<CR>'
  execute 'inoremap ' .. a:key_sequence .. ' <C-O>/<CR>'

  " USYNC: Visual mode <F1> same as Visual mode <F3> — start g*-like
  " search and match forward.
  " - ALTHO: Visual mode <S-F3> search and matches backward, whereas
  "   Visual mode <S-F1> is like Visual mode <F1> and <F3> but doesn't
  "   match forward (stays put).
  let l:cmd = '/'
  let l:jump = 1
  call g:embrace#blinky_search#CreateMaps_GStarSearch_VisualMode(a:key_sequence, l:cmd, l:jump)
endfunction

" Remember, ? is the "opposite" of /
function! g:embrace#blinky_search#CreateMaps_SearchBackward(key_sequence = '<S-F3>') abort
  " SAVVY: Using ?<CR> instead of N because N repeats the last / OR ?
  execute 'noremap ' .. a:key_sequence .. ' ?<CR>'
  execute 'inoremap ' .. a:key_sequence .. ' <C-O>?<CR>'

  " Here's a basic command to just jump, but not to start a new search:
  "   vnoremap <S-F3> <ESC>gVN
  " And here's the naive approach that mmight scroll the window:
  "   vnoremap <S-F3> :<C-U>
  "     \ <CR>gvy
  "     \ gV
  "     \ ?<C-R>=substitute("<C-R>"", "/", "\\\\/", "g")<CR><CR>?<CR>
  let l:cmd = '?'
  let l:jump = 1
  call g:embrace#blinky_search#CreateMaps_GStarSearch_VisualMode(a:key_sequence, l:cmd, l:jump)
endfunction

" -------------------------------------------------------------------

" Add Select Mode `*` and `#` commands, which don't exist.
"
" This complements the built-in '*' and '#' commands
" by enabling a similar features in select mode.
"
" - CALSO: For comparison, you could install and wire visualstar.vim
"   if you'd like to see how "the competition" does it:
"
"     vnoremap <unique> * <Plug>(visualstar-*)
"     vnoremap <unique> # <Plug>(visualstar-#)
"
"   https://github.com/thinca/vim-visualstar
"
"   Suprisingly, I haven't find a lot of visual search plugins.
"
"   (I have read a great number of Vim tips on the subject, though.)
"
"   Though maybe I just didn't search hard enough... I'd be curious
"   to see/learn how most Vimmers have their visual search reconfigured,
"   or if they just use the built-in behavior.

function! g:embrace#blinky_search#CreateMaps_StarPound_VisualMode() abort
  let l:cmd = '/'
  let l:jump = 1
  call g:embrace#blinky_search#CreateMaps_GStarSearch_VisualMode('*', l:cmd, l:jump)

  let l:cmd = '?'
  let l:jump = 1
  call g:embrace#blinky_search#CreateMaps_GStarSearch_VisualMode('#', l:cmd, l:jump)

  " Link keypad Multiply key to star map.
  vnoremap <kMultiply> *
endfunction

" -------------------------------------------------------------------

if !exists('g:blinky_search_strict')
  let g:blinky_search_strict = 0
endif

" Mnemonic: Do Strict (eh)
function! g:embrace#blinky_search#CreateMaps_ToggleStrict(key_sequence = '<Leader>ds') abort
  nnoremap <silent> <Plug>(blinky-search-toggle-strict)
    \ :let g:blinky_search_strict = !g:blinky_search_strict
    \ \| echo (g:blinky_search_strict ? 'Disable' : 'Enabled')
    \ .. ' Wildcard Whitespace Matching (vim-blinky-search)'<CR>

  execute 'nnoremap ' .. a:key_sequence .. ' <Plug>(blinky-search-toggle-strict)'
endfunction

" -------------------------------------------------------------------

" Multicase options: -1: Reset (use defaults)
"                     0: Disable (all commands)
"                     1: Enable (all commands)
if !exists('g:blinky_search_multicase')
  let g:blinky_search_multicase = -1
endif

" Mnemonic: Do multi-Case
function! g:embrace#blinky_search#CreateMaps_ToggleMulticase(key_sequence = '<Leader>dc') abort
  nnoremap <silent> <Plug>(blinky-search-toggle-multicase)
    \ :let g:blinky_search_multicase = (g:blinky_search_multicase != -1)
    \   ? g:blinky_search_multicase - 1 : 1
    \ \| echo
    \   (g:blinky_search_multicase == -1 ? 'Restore'
    \     : (!g:blinky_search_multicase ? 'Disable' : 'Enabled'))
    \ .. ' Multicase Matching (vim-blinky-search)'<CR>

  execute 'nnoremap ' .. a:key_sequence .. ' <Plug>(blinky-search-toggle-multicase)'
endfunction

" -------------------------------------------------------------------

let &cpo = s:save_cpo | unlet s:save_cpo

" -------------------------------------------------------------------

" LEAVE_THIS_FOR_TESTING

