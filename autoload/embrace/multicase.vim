" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Tim Pope <http://tpo.pe/>
" Adopter: Landon Bouma <https://tallybark.com/>
"   My changes include: *All* the comments, and converted to autoload/.
" Project: https://github.com/landonb/vim-blinky-search#🕹
" License: VIM LICENSE — This file only. See LICENSE-VIM

" -------------------------------------------------------------------

" ------------------------------------------------------
" Cased Transforms
" ------------------------------------------------------

" ADOPT: The fcns. below were lovingly lifted from vim-abolish.

" USYNC: vim-abolish, dubs_grep_steady, and vim-blinky-search
"        each have a separate copy of these fcns.
"
"          https://github.com/tpope/vim-abolish
"            https://github.com/tpope/vim-abolish/blob/master/plugin/abolish.vim
"
"          https://github.com/landonb/dubs_grep_steady#🧐
"            ~/.vim/pack/landonb/start/dubs_grep_steady/plugin/dubs_grep_steady.vim

" REFER: These filters are useful for dealing with multiple-word identifiers
"        for similar items. E.g., in React, you'll find the same names used
"        to identify related items, e.g., 'foo-bar' and 'fooBar'.
"
"   https://en.wikipedia.org/wiki/Naming_convention_(programming)#Multiple-word_identifiers

" -------------------------------------------------------------------

" " mixedcase() capitalizes the first character (which we don't need).
" function! g:embrace#multicase#mixedcase(word)
"   return substitute(g:embrace#multicase#camelcase(a:word),'^.','\u&','')
" endfunction

function! g:embrace#multicase#camelcase(word)
  let word = substitute(a:word, '-', '_', 'g')

  if word !~# '_' && word =~# '\l'

    return substitute(word, '^.', '\l&', '')
  else

    return substitute(
      \ word,
      \ '\C\(_\)\=\(.\)',
      \ '\=submatch(1)==""?tolower(submatch(2)) : toupper(submatch(2))',
      \ 'g'
      \ )
  endif
endfunction

function! g:embrace#multicase#snakecase(word)
  let word = substitute(a:word,'::','/','g')
  let word = substitute(word,'\(\u\+\)\(\u\l\)','\1_\2','g')
  let word = substitute(word,'\(\l\|\d\)\(\u\)','\1_\2','g')
  let word = substitute(word,'[.-]','_','g')
  let word = tolower(word)

  return word
endfunction

" " uppercase() converts 'snake_case' to 'SNAKE_CASE' (which we don't need).
" function! g:embrace#multicase#uppercase(word)
"   return toupper(g:embrace#multicase#snakecase(a:word))
" endfunction

" A/k/a kebab-case | spinal-case | Train-Case | Lisp-case | dash-case
function! g:embrace#multicase#traincase(word)
  return substitute(
    \ g:embrace#multicase#snakecase(a:word),
    \ '_', '-', 'g')
endfunction

" " spacecase() converts 'snake_case' to 'space case' (which we don't need).
" function! g:embrace#multicase#spacecase(word)
"   return substitute(
"     \ g:embrace#multicase#snakecase(a:word),
"     \ '_', ' ' ,'g')
" endfunction

" " dotcase() converts snake_case to dot.case (which we don't need).
" function! g:embrace#multicase#dotcase(word)
"   return substitute(
"     \ g:embrace#multicase#snakecase(a:word),
"     \ '_', '.', 'g')
" endfunction
"
