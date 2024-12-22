" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Junegunn Choi <https://junegunn.github.io/>
" Adopter: Landon Bouma <https://tallybark.com/>
"   My changes include: *All* comments except the license;
"   I converted the plugin/ to autoload/; I renamed the
"   fcn.; and I made the highlight group configurable.
" Project: https://github.com/landonb/vim-blinky-search#🕹
" License: MIT — This file only. See LICENSE-MIT

" -------------------------------------------------------------------

" The MIT License (MIT)
"
" Copyright (c) 2016 Junegunn Choi
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.

" (lb): Use a differnt highlight group.
if !exists('g:blinky_search_blink_group')
  " The junegunn/vim-slash project uses IncSearch
  "   let g:blinky_search_blink_group = 'IncSearch'
  " but I think DiffChange looks better with the
  " default Vim DepoXy colorscheme:
  "   https://github.com/landonb/dubs_after_dark#🌃
  let g:blinky_search_blink_group = 'DiffChange'
endif

function! g:embrace#slash_blink#blink(times, delay)
  let s:blink = { 'ticks': 2 * a:times, 'delay': a:delay }

  function! s:blink.tick(_)
    let self.ticks -= 1
    let active = self == s:blink && self.ticks > 0

    if !self.clear() && active && &hlsearch
      let [line, col] = [line('.'), col('.')]
      let w:blink_id = matchadd(g:blinky_search_blink_group,
            \ printf('\%%%dl\%%>%dc\%%<%dc', line, max([0, col-2]), col+2))
    endif
    if active
      call timer_start(self.delay, self.tick)
      if has('nvim')
        call feedkeys("\<plug>(slash-nop)")
      endif
    endif
  endfunction

  function! s:blink.clear()
    if exists('w:blink_id')
      call matchdelete(w:blink_id)
      unlet w:blink_id
      return 1
    endif
  endfunction

  call s:blink.clear()
  call s:blink.tick(0)
  return ''
endfunction

noremap!        <plug>(slash-nop)     <nop>

