" vim:tw=0:ts=2:sw=2:et:norl:ft=vim
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/vim-blinky-search#🕹
" License: <Unknown>
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
" This is how long you want the blinking to last in milliseconds. If you're
" using an earlier Vim without the `+timers` feature, you need a much shorter
" blink time because Vim blocks while it waits for the blink to complete.
let s:blink_length = has("timers") ? 500 : 100

if has("timers")
  " This is the length of each blink in milliseconds. If you just want an
  " interruptible non-blinking highlight, set this to match s:blink_length
  " by uncommenting the line below
  let s:blink_freq = 50
  "let s:blink_freq = s:blink_length
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
      let s:blink_match_id = matchadd('ErrorMsg', s:target_pat, 101)
      redraw
    endif
  endfunction

  " Remove the blink highlight
  function! BlinkClear()
    call matchdelete(s:blink_match_id)
    let s:blink_match_id = 0
    redraw
  endfunction

  " Stop blinking
  "
  " Cancels all the timers and removes the highlight if necessary.
  function! BlinkStop(timer_id)
    " Cancel timers
    if s:blink_timer_id > 0
      call timer_stop(s:blink_timer_id)
      let s:blink_timer_id = 0
    endif
    if s:blink_stop_id > 0
      call timer_stop(s:blink_stop_id)
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

function! HLNext(blink_length, blink_freq)
  let s:target_pat = '\c\%#'.@/
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
    let ring = matchadd('ErrorMsg', s:target_pat, 101)
    redraw
    " Wait
    exec 'sleep ' . a:blink_length . 'm'
    " Remove the highlight
    call matchdelete(ring)
    redraw
  endif
endfunction

" Set up maps for n and N that blink the match
execute printf("nnoremap <silent> n n:call HLNext(%d, %d)<cr>", s:blink_length, has("timers") ? s:blink_freq : s:blink_length)
execute printf("nnoremap <silent> N N:call HLNext(%d, %d)<cr>", s:blink_length, has("timers") ? s:blink_freq : s:blink_length)

