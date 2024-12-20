" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Raymond Li / From Vim Tips Wiki / version 6.0 / 2001
"   https://vim.fandom.com/wiki/Search_for_visually_selected_text
"   (née http://vim.wikia.com/wiki/VimTip171)
" Adapter: Landon Bouma <https://tallybark.com/> 
"   *All* the comments, and made it an autoload/ function.
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
" - Unless g:VeryLiteral == 1,
"   whitespace is ignored.
"   - E.g., searching 'foo   bar   baz' also finds 'foo bar baz'.
"
" - Supports multiline search term, i.e., you can select text
"   across multiple lines and search that.
"
" Attribution
" -----------
"
" From 'Vim Tip 171':
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

" -------------------------------------------------------------------

let s:save_cpo = &cpo | set cpo&vim

" -------------------------------------------------------------------

if !exists('g:VeryLiteral')
  let g:VeryLiteral = 0
endif

function! g:embrace#visual_search#set_search(cmd)
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

" -------------------------------------------------------------------

let &cpo = s:save_cpo | unlet s:save_cpo

