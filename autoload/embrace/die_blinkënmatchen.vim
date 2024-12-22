" vim:tw=0:ts=2:sw=2:et:norl:ft=vim
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/vim-blinky-search#🕹
" License: <Unknown>
"   Modifications by (lb) Copyright © 2017, 2024 Landon Bouma.
" Authors: This is a modified version
"   of Rich's modified version
"   of Damian Conway's search highlight blinker,
"     Die Blinkënmatchen.
"
" - The original `die_blinkënmatchen.vim` is by Damian Conway,
"   as found in *More Instantly Better Vim - OSCON 2013*, which
"   you can watch here:
"
"     https://www.youtube.com/watch?v=aHm36-na4-4
"
"   (lb): I have not been able to find the original tar archive
"   that was circulating around.
"
"   But you can find another version of HLNext() et al in
"   Damian's Vim Setup repo:
"
"     https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/tree/master/plugin
"
"     https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/47c3aec4522e/plugin/hlnext.vim
"
"   Albeit that version just highlights each match, and neither
"   blinks nor disable itself automatically.
"
" - The file you're looking at here in vim-blinky-search is
"   based on modifications by Rich:
"
"     https://vi.stackexchange.com/users/343/rich
"
"   That added timer logic to automate the blinking:
"
"     https://vi.stackexchange.com/questions/8851/interrupting-blink-highlighting-function-if-mapping-is-invoked-again/13551#13551
"
" - To compare against the unmodified Stack Exchange version, run:
"
"     git diff be5d7b5..HEAD -- autoload/embrace/die_blinkënmatchen.vim
"
" - (lb): My changes:
"
"   - Change the match highlight from 'ErrorMsg' to 'DiffChange'.
"
"   - Make the `map` sequences user-configurable (so user can
"     set whatever bindings they want).
"
"   - Integrate with g:embrace#visual_search#SetSearch() so all the
"     vim-blinky-search search commands blink on their first match,
"     and not just the `n` and `N` commands.

" ----------------------------------------------------------------------------

" Modified version of Damian Conway's Die Blinkënmatchen: highlight matches
"
" (lb):
" - ORNOT/2024-12-22: I sometimes like to leave the match highlight on
"   as I work, so I prefer to use <Ctrl-H> :nohlsearch binding instead.
"   - I don't think that I'd apprecaite an auto-off highlight feature.
" 2018-06-11: See also another plugin that highlights search results
" as you jump to them, and also clears the highlight when you move the
" cursor. Except it conflicts with this code (I'm assuming; it conflicts
" with something in Dubs Vim; or it's just broken), and the code is longer
" and more complicated looking than I want to spend time stealing from.
"   https://github.com/pgdouyon/vim-evanesco
" However, I still like the idea of clearing the highlight automatically
" if you cursor away from a match... seems like something tidy I might
" enjoy (though it's hard to know for sure without enabling such a
" feature any playing around with it; for now, without that feature,
" just Ctrl-H to clear highlights, as appropriate).

" This is the length of each blink in milliseconds. If you just want an
" interruptible non-blinking highlight, set this to match s:blink_length
" by uncommenting the line below
"  let s:blink_freq = 50
let s:blink_freq = 125

" This is how long you want the blinking to last in milliseconds. If you're
" using an earlier Vim without the `+timers` feature, you need a much shorter
" blink time because Vim blocks while it waits for the blink to complete.
"  let s:blink_length = has("timers") ? 500 : 100
"
" (lb):
" At 1.5 times the blink frequency, there's one 'blink', or maybe zero,
" not sure what to call it:
"  let s:blink_length = has('timers') ? float2nr(s:blink_freq * 1.5) : 100
" At 2 times, the same, maybe one blink, or none.
" At 3 times the blink frequency, you'll see two winks, er, blinks.
" - In Vim 9, pressing another key interrupts the blinking and does
"   whatever action the keypress demands.
let s:blink_length = has('timers') ? float2nr(s:blink_freq * 3) : 100

" (lb):
" let s:use_highlight = 'ErrorMsg'
let s:use_highlight = 'DiffChange'

if has('timers')
  let s:blink_match_id = 0
  let s:blink_timer_id = 0
  let s:blink_stop_id = 0

  " Toggle the blink highlight. This is called many times repeatedly in order
  " to create the blinking effect.
  function! BlinkToggle(timer_id)
    if s:blink_match_id > 0
      " Clear highlight
      call BlinkClear()
    else
      " Set highlight
      let s:blink_match_id = matchadd(s:use_highlight, s:target_pat, 101)
      redraw
    endif
  endfunction

  " Remove the blink highlight
  " (lb):
  " - Note there's a race condition here, hence the 'silent!'
  "   - Otherwise sometimes, e.g.,
  "       Error detected while processing function BlinkStop[28]..BlinkClear:
  "       line    1:
  "       E803: ID not found: 1001
  function! BlinkClear()
    silent! call matchdelete(s:blink_match_id)
    let s:blink_match_id = 0
    redraw
  endfunction

  " (lb):
  let s:skip_first = 0

  " Stop blinking
  "
  " Cancels all the timers and removes the highlight if necessary.
  function! BlinkStop(timer_id)
    if s:skip_first > 0
      let s:skip_first -= 1

      return
    endif

    " Cancel timers
    if s:blink_timer_id > 0
      " 2017-12-10: (lb): If you search in quickfix and then, while
      " a blink is happening, you <S-M-Up> outta there, you'll see:
      "   E803: Id not found: nn
      " so try-catch, and get on with life.
      try
        call timer_stop(s:blink_timer_id)
      catch
        " pass
      endtry

      let s:blink_timer_id = 0
    endif
    if s:blink_stop_id > 0
      " (lb): Avoid E803, as described above.
      try
        call timer_stop(s:blink_stop_id)
      catch
        " pass
      endtry
      let s:blink_stop_id = 0
    endif
    " And clear blink highlight
    if s:blink_match_id > 0
      call BlinkClear()
    endif
  endfunction

  augroup die_blinkmatchen
    autocmd!
    autocmd CursorMoved * call BlinkStop(0)
    autocmd InsertEnter * call BlinkStop(0)
  augroup END
endif

function! HLNext(blink_length, blink_freq, skip_first)
  " REFER: (lb):
  "   :h regexp
  "   \c    ignore case, do not use the 'ignorecase' option
  "   \%#   cursor position |/zero-width|
  let s:target_pat = '\c\%#'.@/
  let s:skip_first = a:skip_first
  if has("timers")
    " Reset any existing blinks
    call BlinkStop(0)
    " Start blinking. It is necessary to call this now so that the match is
    " highlighted initially (in case of large values of a:blink_freq)
    call BlinkToggle(0)
    " Set up blink timers.
    let s:blink_timer_id = timer_start(a:blink_freq, 'BlinkToggle', {'repeat': -1})
    let s:blink_stop_id = timer_start(a:blink_length, 'BlinkStop')
  else
    " Vim doesn't have the +timers feature. Just use Conway's original
    " code.
    " Highlight the match
    let ring = matchadd(s:use_highlight, s:target_pat, 101)
    redraw
    " Wait
    exec 'sleep ' . a:blink_length . 'm'
    " Remove the highlight
    call matchdelete(ring)
    redraw
  endif
endfunction

" Set up maps for n and N that blink the match
" 2018-07-09: (lb): Giving 'zz' a shot, too.
execute printf(
  \ 'nnoremap <silent> n nzz:call HLNext(%d, %d, 0)<cr>',
  \ s:blink_length, has('timers') ? s:blink_freq : s:blink_length)
execute printf(
  \ 'nnoremap <silent> N Nzz:call HLNext(%d, %d, 0)<cr>',
  \ s:blink_length, has('timers') ? s:blink_freq : s:blink_length)

" -------------------------------------------------------------------
"
" What's below was added by Landon Bouma.
"
" - And it's tricky to get the blink to work when starting a search,
"   and to not mess up where the cursor ends up. /Just FYI.

let g:visual_search_multiline_ok = 1

" Re: :h vim-modes
"
" - Double-click from normal mode: SELECT mode
"
" - Select block from insert mode: (insert) SELECT
"   - Returns to insert mode after operation

" Avoid InsertEnter event from killing blink too early.
" Also avoid whatever Vim does after set_search messes
" with the selection and the search text, because if we
" call this after set_search, the cursor will jumps to
" an old `gv` mark (start of last visual search) but not
" the current one. Or something like that. I'm not totally
" clear on the mechanics. Just wait until after the visual
" mode command runs to start the blinking.
function! HLNextStart(timer_id) abort
  let l:blink_freq = has('timers') ? s:blink_freq : s:blink_length

  call HLNext(s:blink_length, l:blink_freq, 1, 1)
endfunction

function! s:CreateMaps() abort
    " Remap dubs_edit_juice <F3> variants.
    execute printf(
      \ 'noremap <silent> <F3> /<CR>:call HLNext(%d, %d, 0)<CR>',
      \ s:blink_length, has('timers') ? s:blink_freq : s:blink_length)
    " Skip first call from HLNext and subsequence InsertEnter event.
    let l:skip_first = 2
    execute printf(
      \ 'inoremap <silent> <F3> <C-O>/<CR><C-O>:call HLNext(%d, %d, %d)<CR>',
      \ s:blink_length, has('timers') ? s:blink_freq : s:blink_length, l:skip_first)
    if !exists("g:visual_search_multiline_ok") || !g:visual_search_multiline_ok
      execute printf(
        \ 'vnoremap <silent> <F3> :<C-U><CR>gvygV/<C-R>=substitute("<C-R>"", "/", "\\\\/", "g")<CR><CR>:call HLNext(%d, %d, 1, 1)<CR>',
        \ s:blink_length, has('timers') ? s:blink_freq : s:blink_length)
    else

      " -------------------------------------------------------------------
      " SAVVY/2024-12-22: (lb): This is where I stopped when I redirected
      " to finish work on g:embrace#visual_search#SetSearch(), which
      " previously was only wired to the '*' and '#' commands. I've since
      " got that wired to *all* the search commands — and learned a lot
      " along the way — but I also discovered junegunn/vim-slash about 4
      " hours ago and was able to integrate that plugin's blink commmand
      " so, so elegantly! So I'll probably never see this comment again.
      " But here's how you might've integrated HLNextStart with SetSearch.
      " And it's not pretty!
      vnoremap <silent> <F3> :<C-U><CR>:call timer_start(0, 'HLNextStart')<CR>:call g:embrace#visual_search#SetSearch('/')<CR><C-O>/<C-R>/<CR>
      " -------------------------------------------------------------------

    endif
    " Remap dubs_edit_juice <S-F3> variants.
    execute printf(
      \ 'noremap <silent> <S-F3> ?<CR>:call HLNext(%d, %d, 0)<CR>',
      \ s:blink_length, has('timers') ? s:blink_freq : s:blink_length)
    execute printf(
      \ 'inoremap <silent> <S-F3> <C-O>?<CR><C-O>:call HLNext(%d, %d, 2)<CR>',
      \ s:blink_length, has('timers') ? s:blink_freq : s:blink_length)
    if !exists("g:visual_search_multiline_ok") || !g:visual_search_multiline_ok
      execute printf(
        \ 'vnoremap <silent> <S-F3> :<C-U><CR>gvygV?<C-R>=substitute("<C-R>"", "/", "\\\\/", "g")<CR><CR>?<CR>:call HLNext(%d, %d, 1)<CR>',
        \ s:blink_length, has('timers') ? s:blink_freq : s:blink_length)
    else
      execute printf(
        \ 'vnoremap <silent> <S-F3> :<C-U>call g:embrace#visual_search#set_search("?")<CR><C-O>?<C-R>/<CR><C-O>:call HLNext(%d, %d, 1)<CR>',
        \ s:blink_length, has('timers') ? s:blink_freq : s:blink_length)
    endif
"  endif
endfunction

call s:CreateMaps()

