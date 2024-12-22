" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Raymond Li / From Vim Tips Wiki / version 6.0 / 2001
"   https://vim.fandom.com/wiki/Search_for_visually_selected_text
"   (née http://vim.wikia.com/wiki/VimTip171)
" Adapter: Landon Bouma <https://tallybark.com/>
"   My changes include: *All* the comments, and converted to autoload/.
"   - Also anything marked (lb) and some not, including:
"     - histadd() calls
"     - multi-identifier searching (camelCase|snake_case|train-case)
"     - \<restricted\> or not word boundary option
" Project: https://github.com/landonb/vim-blinky-search#🕹
" License: CC BY-SA / Creative Commons Attribution-Share Alike License 3.0 (Unported)
"   https://www.fandom.com/licensing
"   https://creativecommons.org/licenses/by-sa/3.0/
"     vim-blinky-search/LICENSE-CC-BY-SA-3.0

" -------------------------------------------------------------------

" ------------------------------------------------------
" "VSearch"
" ------------------------------------------------------

" Features
" --------
"
" Searches for selected text.
"
" - Unless ~~g:VeryLiteral~~ g:blinky_search_strict == 1,
"   whitespace is ignored.
"   - E.g., searching 'foo   bar   baz' also finds 'foo bar baz'.
"
" - Supports multiline search term, i.e., you can select text
"   across multiple lines and search that.
"
" - Caller specifies \<restricted\> word boundary, or not.
"
" - Callers specifies multi-identifier casing, or not.
"
"   - E.g., (foo-bar|fooBar|foo_bar)
"
" - Update not only the 'search' history, but also adds a ready-to-go,
"   correctly escaped :grep query to the 'input' history (which at
"   least works for the author's external `rg` command).
"
"   - This is useful not only to repeat a buffer query on a set of
"     files, but it's also helpful if you don't want to properly
"     escape some text you want to search. Highlight the text
"     instead, start a buffer search, then run :grep and <Up>
"     to find the well-crafted grep pattern waiting for you.
"
" Attribution
" -----------
"
" This work all stemmed from a tip I saw years (so many years) ago,
" 'Vim Tip 171', combined with some other features I've craved over
" the years, including the multi-case support. But the core workings
" here — supporting multiline, whitespace-agnostic search — is from
" the tip:
"
" - *Search for visually selected text*
"
"   http://vim.wikia.com/wiki/Search_for_visually_selected_text
"
" - The fcn. below was originally declared s:VSetSearch(cmd),
"   and the global toggle variable named g:VeryLiteral.
"
" The Simple, Less Functional Implementation
" ------------------------------------------
" (Albeit I haven't recorded how this behaves different.)
"
"   " Search for selected text, forwards or backwards.
"   vnoremap <silent> * :<C-U>
"     \ let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
"     \ gvy/<C-R><C-R>=substitute(
"     \ escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
"     \ gV:call setreg('"', old_reg, old_regtype)<CR>
"
"   vnoremap <silent> # :<C-U>
"     \ let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
"     \ gvy?<C-R><C-R>=substitute(
"     \ escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
"     \ gV:call setreg('"', old_reg, old_regtype)<CR>
"
" Reference
" ---------
"
" - REFER:
"
"   :h i_CTRL-R — <C-R>/ inserts the last search pattern
"
"   :h i_CTRL-U — :<C-U> clears line, b/c : from visual mode starts :'<,'>

" -------------------------------------------------------------------

" CXREF: See toggle: CreateMaps_ToggleStrict()
if !exists('g:blinky_search_strict')
  let g:blinky_search_strict = 0
endif

" -------------------------------------------------------------------

" This preserves external compatibility options,
" so we can enable full vim compatibility...
" - Albeit it's already likely the default: aABceFsz
" - And I couldn't tell you exactly what part below
"   needs this.
" - But we'll keep it for compleneness, or perhaps
"   just posterity.
let s:save_cpo = &cpo | set cpo&vim

" -------------------------------------------------------------------

" TRYME/2024-12-20: Here's an example you could search, to whet your appetite:
"
"   'a/b/ \c\d "hello"\n'
"
" See above s:AddToSearchAndInputHistories() for a few more.

function! g:embrace#visual_search#SetSearch(cmd, restrict_word = 0, multicase = 0) abort
  " '"' is the unnamed register (aka @), which contains the text
  " of the last delete or yank. We'll save and restore it.
  "   :h quote_quote
  let l:old_reg = getreg('"')
  let l:old_regtype = getregtype('"')
  " "Start Visual mode with the same area as the previous
  "  area and the same mode.
  "  In Visual mode the current and the previous Visual
  "  area are exchanged."
  " Then Yank text into the unnamed register.
  normal! gvy
  " @@ is contents of unnamed register — :h expr-register
  " @@ is also @" — :h registers
  " =~? is regexp matches, ignore case
  if @@ =~? '^[0-9a-z,_-]*$' || @@ =~? '^[0-9a-z ,_-]*$' && g:blinky_search_strict
    " The search is nothing fancy and nothing we need to escape.
    " (lb): Create multi-case pattern.
    let [l:pat, l:grep_pat] = g:embrace#visual_search#CaseTheJoint(@@, a:restrict_word, a:multicase)

    " / is the last search pattern register (aka "/) — :h quote/
    let @/ = l:pat
  else
    " Escape '\' and either '/' or '?' depending on the a:cmd
    let l:pat = escape(@@, '\' .. a:cmd)

    " (lb): For grep history (which uses input history),
    " only escape escapes, double quotes, and newlines.
    let l:grep_pat = substitute(@@, '\\', '\\\\', 'g')
    let l:grep_pat = escape(l:grep_pat, '\"')
    let l:grep_pat = substitute(l:grep_pat, '\n', '\\n', 'g')

    if g:blinky_search_strict
      " Change actual newlines to escape sequence for multi-line
      " search term to work.
      let l:pat = substitute(l:pat, '\n', '\\n', 'g')
    else
      " Ignore differences in whitespace when searching.
      " - REFER: \_s is \s character class with end-of-line added.
      let l:pat = substitute(l:pat, '^\_s\+', '\\s\\+', '')
      let l:pat = substitute(l:pat, '\_s\+$', '\\s\\*', '')
      let l:pat = substitute(l:pat, '\_s\+', '\\_s\\+', 'g')

      " Assume external grepprg used, so no funny Vim regexp.
      " - Convert literal spaces to \s+ to ignore whitespace.
      let l:grep_pat = substitute(l:grep_pat, '\s\+', '\\s+', 'g')
    endif

    " - REFER: 'Use of "\V" means that after it, only a backslash and the terminating
    "   character (usually / or ?) have special meaning: "very nomagic"'
    "     :help /magic
    let @/ = '\V' .. l:pat
  endif

  call s:AddToSearchAndInputHistories(l:pat, l:grep_pat)

  " "Avoid the automatic reselection of the Visual area
  "  after a Select mode mapping or menu has finished.
  "  Put this just before the end of the mapping or menu.
  "  At least it should be after any operations on the
  "  selection."
  normal! gV

  " Restore the unnamed register.
  call setreg('"', l:old_reg, l:old_regtype)
endfunction

" -------------------------------------------------------------------

" (lb): Thanks to vim-abolish for the translators.
" - This feature was motivated by React and how
"   `some-thing` is sometimes also `someThing`.

" Search on 3 casings: Camel, Snake, and Train.
" SAVVY: Converting to snakecase downcases it.
" USYNC: See also g:DubsGrepSteady_GrepAllTheCases and GrepPrompt_Simple()
"          https://github.com/landonb/dubs_grep_steady#🧐

" g:blinky_search_multicase options:
"    -1: Reset (use defaults)
"     0: Disable (all commands)
"     1: Enable (all commands)

function! g:embrace#visual_search#CaseTheJoint(pat, restrict_word = 0, multicase = 0) abort
  let l:multicase = a:multicase
  if get(g:, 'blinky_search_multicase', -1) != -1
    " User toggled always-on or always-off (via, e.g., \ds command).
    let l:multicase = g:blinky_search_multicase
  endif

  if l:multicase
    let l:varies = 0

    let l:ccase = tolower(g:embrace#multicase#camelcase(a:pat))
    let l:scase = tolower(g:embrace#multicase#snakecase(a:pat))
    let l:tcase = tolower(g:embrace#multicase#traincase(a:pat))

    let l:cased = l:ccase
    if l:scase != l:ccase
      let l:cased = l:cased .. "\\|" .. l:scase
      let l:varies = 1
    endif
    if l:tcase != l:ccase && l:tcase != l:scase
      let l:cased = l:cased .. "\\|" .. l:tcase
      let l:varies = 1
    endif

    let l:vim_pat = l:cased
    let l:grep_pat = l:cased

    if l:varies
      let l:vim_pat = '\(' .. l:vim_pat .. '\)'
      let l:grep_pat = '(' .. l:grep_pat .. ')'
    endif
  else
    let l:vim_pat = a:pat
    let l:grep_pat = a:pat
  endif

  if a:restrict_word
    let l:vim_pat = '\<' .. l:vim_pat .. '\>'
    let l:grep_pat = '\b' .. l:grep_pat .. '\b'
  endif

  return [l:vim_pat, l:grep_pat]
endfunction

" -------------------------------------------------------------------

" (lb): Add to /-search and grep search history.

" UTEST: Select this text and gstar search it, then run :grep
" and press <Up> for latest item, and grep that.
"
"   \abcdefg
"
"   '"foobar"'
"
"   this line and
"    the next line.
"
"   a literal \n
"
"   quxQuuxQuuz qux_quux_quuz qux-quux-quuz

" MAYBE/2024-12-20: Make adding to history configurable.
" - PHAPS: Only add tricky, escaped terms?

function! s:AddToSearchAndInputHistories(pat, grep_pat) abort
  " Same as histadd("/", a:pat)
  call histadd("search", a:pat)

  " Same as histadd("@", l:grep_pat)
  call histadd("input", a:grep_pat)
endfunction

" -------------------------------------------------------------------

" See comment above. Restore previous compatibility-options.
let &cpo = s:save_cpo | unlet s:save_cpo

