#####################################
Visual Search Improvements for Vim 🕹
#####################################
.. Blinky, aka Shadow, "is the leader of the Ghosts and the
   arch-enemy of Pac-Man", in the classic arcade 🕹 game.
     https://pacman.fandom.com/wiki/Blinky

.. contents:: :local:

About This Plugin
=================

This plugin supercharges the familiar Vim ``star`` (``*``) and ``#`` search
commands and adds the following features:

- Search across newlines.

  - You can select text spanning a line break and search that.

- Search without regard for whitespace.

  - A search for ``"foo  bar   baz"`` will match ``"foo bar baz"``.

  - You can toggle this effect on and off (the toggle defaults
    to ``<Leader>ds`` (``\ds``)).

- Search variations of multiple-word identifiers (multi-case).

  - A search for ``foo-bar``, ``fooBar`` or ``foo_bar`` will find
    all of these case variations.

  - You can toggle this effect to be always-on, always-off,
    or to use the default behavior (the toggle defaults to
    ``<Leader>dc`` (``\dc``)).

  - By default, only ``<F8>`` and ``<Enter>`` enable multi-case.

    If you run ``\dc`` once, you'll enable multi-case for all
    search commands. And if you run it again, you'll disable
    multi-case for all commands. Run a third time to reset
    the default behavior (where only ``<F8>`` and ``<Enter>``
    enable multi-case.)

- Momentarily blink the match under the cursor.

  - Depending on your Vim *colorscheme*, especially the cursor shape
    and its color compared to the match highlight color, it might be
    difficult to spot the cursor while matching. This blink feature
    can help!

  - You can toggle this effect on and off (the toggle defaults
    to ``<Leader>dB`` (``\dB``)).

- Center the cursor line vertically.

  - When you advance the cursor to the next match, some of the plugin
    commands will reposition the cursor line in the middle of the window.

    - But not all of them — it depends on which map command you use.

      By default, ``g*``, ``g#``, ``n`` and ``N`` will call ``zz`` to center the
      line in the window.

      But not the commands ``*``, ``#``, ``<F1>``, ``<S-F1>``, ``<F3>``, ``<S-F3>``,
      ``<F8>``, or ``<Enter>``.

    - You can also easily configure the plugin to not do this, or to
      choose different keybindings.

      See `User Configuration`_ for details on how to
      pick your own command maps.

This plugins maps a number of F-keys and other keys to help you search:

- Start a search using ``<F1>`` and ``<Shift-F1>``. ``<F1>`` is similar to using
  ``g*`` and will jump to the next match. ``<S-F1>`` is similar to using
  ``*`` and stays put.

  Advance to the next match using ``<F3>`` and ``<Shift-F3>`` instead of ``n`` and ``N``.

  Start a multi-case search using ``<F8>`` or ``<Enter>`` (or toggle that feature
  always-on with ``\dc``).

  You can use any of the F-key commands from visual mode to start a new
  search.

  See the table under `Search Commands`_ for more details
  about how these commands each work, and how they differ from one another.

Inspiration
===========

.. |vim-slash| replace:: ``junegunn/vim-slash``
.. _vim-slash: https://github.com/junegunn/vim-slash

The newline and whitespace features are inspired by a classic Vim tip:

https://vim.fandom.com/wiki/Search_for_visually_selected_text

The blinky feature is inspired by a Stack Exchange answer that the
author happened to run across (and that only has 5 upvotes! But it's
way cooler than that =):

https://vi.stackexchange.com/questions/8851/interrupting-blink-highlighting-function-if-mapping-is-invoked-again/13551#13551

- Their post is based on Damian Conway's work, ``die_blinkënmatchen.vim``,
  as found in *More Instantly Better Vim - OSCON 2013*.

  https://www.youtube.com/watch?v=aHm36-na4-4

- Albeit since then the ``die_blinkënmatchen.vim`` feature has been
  replaced by a much more concise blink function, which has been
  lovingly grifted from |vim-slash|_.

The `multi-word identifier
<https://en.wikipedia.org/wiki/Naming_convention_(programming)#Multiple-word_identifiers>`__
feature is my creation, because sometimes I work on React code where
variables have multiple identities (e.g., ``embraceVim`` and ``embrace-vim``)
and I got annoyed after about the fifth time I hand-typed something like
``embrace.\?vim`` so that I could search both at the same time.

- Though I "borrowed" the case filters from `tpope/vim-abolish
  <https://github.com/tpope/vim-abolish>`__ (it's only 19 lines of code,
  but it's 19 lines of regexp which is, like, 19 hours of work ;).
  Thank you, Tim Pope!

Search Commands
===============

.. |vim-search-commands| replace:: ``:help search-commands``
.. _vim-search-commands: https://vimhelp.org/pattern.txt.html#search-commands

In stock Vim, ``*``, ``#``, ``g*``, ``g#``, ``/``, and ``?`` start a buffer search. You can then
advance to the next match using ``n`` (forward match) and ``N`` (backward match).

- Refer to |vim-search-commands|_ for more details on the builtin search commands.

This plugin modifies ``*``, ``#``, ``g*``, and ``g#`` as described below, and it
adds a number of additional commands.

It's also easy to choose your own key sequences for the commands listed
below. See the next section for more: `User Configuration`_

=================================  ==================================  ==============================================================================
 Key Mapping                        Description                         Notes
=================================  ==================================  ==============================================================================
 ``*``                              Restrictive Search                  Search buffer for exact word under cursor.
                                    of Word Under Cursor
                                    or Selected Text                    In stock Vim, this works from normal and visual mode.
                                                                        With this plugin, it also works from select mode.
                                                                        
                                                                        When used from visual or select mode, this plugin
                                                                        supports multiline searching (if the selected text
                                                                        contains newlines). It can also be configured to
                                                                        ignore, or not to ignore, differences in whitespace
                                                                        (which you can toggle using ``\ds``).
                                                                        
                                                                        This plugin also centers the match line vertically
                                                                        in the window (by calling ``zz``).
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``#``                              Restrictive Search                  Same as ``*``, but search backward.
                                    in Reverse
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``g*``                             Substring Search                    Like ``*``, but don't put ``\<`` and ``\>`` around the word.
                                    of Word Under Cursor                This makes the search also find matches that are not a
                                    or Selected Text                    whole word.
                                                                        
                                                                        This command also centers the match line vertically
                                                                        in the window (by calling ``zz``).
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``g#``                             Substring Search                    Like ``#``, but don't put ``\<`` and ``\>`` around the word.
                                    in Reverse                          This makes the search also find matches that are not a
                                                                        whole word.
                                                                        
                                                                        This command also centers the match line vertically
                                                                        in the window (by calling ``zz``).
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``<F1>``                           Search Buffer for                   Search buffer for substring under cursor.
                                    Word Under Cursor
                                    or Selected Text                    Similar to ``g*`` — it searches more loosely.
                                                                        
                                                                        - For example, searching "foo" will also match the
                                                                          "foo" in "foobar" (like ``g*``, but not like ``*``).
                                                                        
                                                                        When used from visual or select mode, this command
                                                                        supports multiline search (i.e., so you select text
                                                                        across newlines). And it will ignore differences in
                                                                        whitespace if the ``\ds`` toggle is not disabled.
                                                                        
                                                                        This command works in the four main modes —
                                                                        normal, insert, visual and select.
                                                                        
                                                                        Hint: To easily start a search, put the cursor on
                                                                        a term to search, or select some text, and hit
                                                                        ``<F1>``. Then use ``<F3>`` to continue searching.
                                                                        
                                                                        Caveat: If ``ignorecase`` and ``smartcase`` are enabled,
                                                                        and if the search term is lowercase, you'll get
                                                                        case-insensitive matches. But if the search term
                                                                        is mixed- or upper-case, you'll get case-sensitive
                                                                        matches.
                                                                        
                                                                        Note that in stock Vim, ``<F1>`` opens the ``:help``.
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``n``                              Forward Search Match                Move cursor forward to and highlight next search match.
                                                                        
                                                                        This works similar to the builtin ``n`` command, but
                                                                        it also centers the match line vertically in the
                                                                        window (using ``zz``) and momentarily blinks the match.
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``N``                              Backward Search Match               Move cursor backward to and highlight previous search match.
                                                                        
                                                                        This works similar to the builtin ``N`` command, but
                                                                        it also centers the match line vertically in the
                                                                        window (using ``zz``) and it quickly blinks the match.
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``<F3>``                           Forward Search Match                Move cursor forward to and highlight previous next match.
                                                                        
                                                                        This works similar to the ``n`` command, but it
                                                                        does not center the match line (so it works like
                                                                        the builtin ``n`` command).
                                                                        
                                                                        From visual or select mode, behaves like ``<F1>`` and
                                                                        starts a search for the selected text, and jumps
                                                                        to the next search match. The search may contain
                                                                        newlines, and ``\ds`` can be toggled to disable/enable
                                                                        wildcard whitespace matching.
                                                                        
                                                                        Hint: The search wraps at the end of the buffer.
                                                                        When it wraps, you'll see a message highlighted in
                                                                        red in the status window that reads, "search hit
                                                                        BOTTOM, continuing at TOP".
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``<Shift-F3>``                     Backward Search Match               Move cursor backward to and highlight previous search match.
                                                                        
                                                                        This works similar to the ``N`` command, but it
                                                                        does not center the match line (so it works like
                                                                        the builtin ``N`` command).
                                                                        
                                                                        From visual or select mode, behaves like ``<F1>`` and
                                                                        starts a search for the selected text, and it jumps
                                                                        to the previous search match. The search may contain
                                                                        newlines, and ``\ds`` can be toggled to disable/enable
                                                                        wildcard whitespace matching.
                                                                        
                                                                        Like ``<F3>``, this command also wraps at the start
                                                                        of the file and continues from the end, back up to
                                                                        the cursor. It'll also report, e.g., "search hit TOP,
                                                                        continuing at BOTTOM".
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``<F8>``                           Start Multicase Search              Start a search like ``<F1>``, but match different case
                                                                        variations for the term.
                                                                        
                                                                        - For example, if you search the following word:
                                                                        
                                                                          .. code-block::
                                                                        
                                                                            fooBar
                                                                        
                                                                          the search will also find these two words:
                                                                        
                                                                          .. code-block::
                                                                        
                                                                            foo_bar
                                                                        
                                                                            foo-bar
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``<Enter>``                        Start Search and Highlight          Toggle highlighting of the word under the cursor and
                                    Word Under Cursor                   use to start a search query. Press ``<Enter>`` again to
                                                                        turn off highlighting.
                                                                        
                                                                        The search also finds different case variations for
                                                                        the term, like it does for ``<F8>``.
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``<Shift-F1>``                     Start Search and Highlight          Start a search on the word under the cursor from
                                    Word Under Cursor or Selection      normal or insert mode. From visual or select mode,
                                                                        start a search using the selected text. Does not
                                                                        jump to the next search match.
                                                                        
                                                                        Starting a search with ``<S-F1>`` is similar to using
                                                                        ``*`` and searches for the exact word under the
                                                                        cursor, unlike ``<F1>`` which searches more loosely.
                                                                        
                                                                        Otherwise the search follows the same rules as
                                                                        searching with ``<F1>`` — it supports multiline
                                                                        searches (the selected text may contain newlines).
                                                                        It can also be configured to ignore, or not to
                                                                        ignore, differences in whitespace (using ``\ds``).
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``<Ctrl-H>``                       Hide Search Highlights              Hide search highlights (calls ``:nohlsearch``).
                                                                        
                                                                        After you initiate a search, the matching words in
                                                                        the buffers are highlighted. Use ``<Ctrl-H>`` to
                                                                        disable the highlights.
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``\ds``                            Toggle Whitespace Behavior          Toggle whitespace matching behavior, which is used
                                                                        by each search command in visual and select mode.
                                                                        
                                                                        The toggle defaults to matching loosely (wildcard
                                                                        matching), such that selecting text that includes
                                                                        whitespace and then using that selection to start
                                                                        a search will ignore differences in whitespace.
                                                                        
                                                                        - For instance, if you select and search
                                                                          ``"foo bar baz"``, then it would also match
                                                                          ``"foo  bar   baz"``.
                                                                        
                                                                        - Likewise, searching ``"it "`` (with a space)
                                                                          matches ``"it"`` (without a space).
                                                                        
                                                                        If you'd like to change the default behavior to
                                                                        be strict about whitespace instead, you can set
                                                                        a global variable from your config:
                                                                        
                                                                        .. code-block::
                                                                        
                                                                          let g:vim_blinky_search_strict = 1
                                                                        
                                                                        In the Vim tip this feature was lifted from, it
                                                                        was known by its variable name, ``g:VeryLiteral``.
---------------------------------  ----------------------------------  ------------------------------------------------------------------------------
 ``\dc``                            Toggle Multi-case Behavior          Toggle multi-case matching behavior.
                                                                        
                                                                        By default, multi-case behavior is only enabled
                                                                        for ``<F8>`` and ``<Enter>``.
                                                                        
                                                                        This toggle lets you enable multi-case behavior
                                                                        for all commands, or to disable it for all commands.
                                                                        Toggle it a third time to restore defaults.
=================================  ==================================  ==============================================================================

User Configuration
==================

.. |after-plugin| replace:: ``after/plugin/vim-blinky-search.vim``
.. _after-plugin: https://github.com/embrace-vim/vim-blinky-search/blob/release/after/plugin/vim-blinky-search.vim

If you'd like to define your own maps, set the disable flag, and then
call the create-map functions from your own config.

- First, set the disable flag from your config:

  .. code-block::

    let g:blinky_search_disable = 1

- Then call the map setup commands from your config.

  Consult the |after-plugin|_ script to see how this
  plugin configures all the commands listed above.

  You could simply copy that file and modify it to taste.

  Or, you could copy the following and edit it to your liking:

  .. code-block::

    " Wire various command to start search with different behavior
    call g:embrace#blinky_search#CreateMaps_GStarSearch('<F1>')
    call g:embrace#blinky_search#CreateMaps_StarSearchStayPut('<S-F1>')

    " These two commands also enable multicase matching by default
    call g:embrace#blinky_search#CreateMaps_GStarSearchStayPut('<F8>')
    call g:embrace#blinky_search#CreateMaps_ToggleHighlight('<CR>')

    " Wire two F-key commmands to next/prev match
    call g:embrace#blinky_search#CreateMaps_SearchForward('<F3>')
    call g:embrace#blinky_search#CreateMaps_SearchBackward('<S-F3>')

    " Wire '*' and '#' from visual mode
    call g:embrace#blinky_search#CreateMaps_StarPound_VisualMode()

    " Wire the three feature toggles
    call g:embrace#blinky_search#CreateMaps_ToggleBlinking('<Leader>dB')
    call g:embrace#blinky_search#CreateMaps_ToggleMulticase('<Leader>dc')
    call g:embrace#blinky_search#CreateMaps_ToggleStrict('<Leader>ds')

    " Change builtins to also center match line with `zz`
    call g:embrace#middle_matches#CreateMaps(['n', 'N', '*', '#', 'g*', 'g#'])

    " Hide highlights with <Ctrl-H>
    call g:embrace#hide_highlights#CreateMaps('<C-h>')

    " Blink the current match momentarily — twice for 75 msec. each time
    if has('timers')
      nnoremap <expr> <Plug>(blinky-search-after) g:embrace#slash_blink#blink(2, 75)
    endif

Similar plugins
===============

.. |slash_blink.vim| replace:: ``autoload/embrace/slash_blink.vim``
.. _slash_blink.vim: https://github.com/embrace-vim/vim-blinky-search/blob/release/autoload/embrace/slash_blink.vim

See also these plugins the author found along the way:

- ``thinca/vim-visualstar`` : *star(\*) for Visual-mode*:

  https://github.com/thinca/vim-visualstar

  https://www.vim.org/scripts/script.php?script_id=2944

- ``junegunn/vim-slash``: *Enhancing in-buffer search experience*:

  https://github.com/junegunn/vim-slash

  - "Automatically clears search highlight when cursor is moved".

  - Also changes ``*`` search to highlight without moving
    (although scrolls the match line to the middle of window).

  - Its blink highlight code is incorporated into
    ``vim-blinky-search``'s |slash_blink.vim|_ file.

- ``vim-evanesco``: *Automatically clears search highlight*:

  https://github.com/pgdouyon/vim-evanesco

  - ``vim-blinky-search`` wires a hide-highlight command you can use
    (which defaults to ``<Ctrl-H>``), but if you'd like a more automated
    solution that hides when you move the cursor or leave insert mode,
    check out ``junegunn/vim-slash`` or ``pgdouyon/vim-evanesco``.

Installation
============

.. |help-packages| replace:: ``:h packages``
.. _help-packages: https://vimhelp.org/repeat.txt.html#packages

.. |INSTALL.md| replace:: ``INSTALL.md``
.. _INSTALL.md: INSTALL.md

Take advantage of Vim's packages feature (|help-packages|_)
and install under ``~/.vim/pack``, e.g.,:

.. code-block::

  mkdir -p ~/.vim/pack/embrace-vim/start
  cd ~/.vim/pack/embrace-vim/start
  git clone https://github.com/embrace-vim/vim-blinky-search.git

  " Build help tags
  vim -u NONE -c "helptags vim-blinky-search/doc" -c q

- Alternatively, install under ``~/.vim/pack/emrace-vim/opt`` and call
  ``:packadd vim-blinky-search`` to load the plugin on-demand.

For more installation tips — including how to easily keep the
plugin up-to-date — please see |INSTALL.md|_.

Blinky Ghost
============

.. code-block::

  ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛🟥🟥🟥🟥⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛🟥🟥🟥🟥🟥🟥🟥🟥⬛⬛⬛⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛⬛⬛🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥⬛⬛⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛⬛🟥⬜⬜🟥🟥🟥🟥⬜⬜🟥🟥🟥⬛⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛⬛⬜⬜⬜⬜🟥🟥⬜⬜⬜⬜🟥🟥⬛⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛⬛🟦🟦⬜⬜🟥🟥🟦🟦⬜⬜🟥🟥⬛⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛🟥🟦🟦⬜⬜🟥🟥🟦🟦⬜⬜🟥🟥🟥⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛🟥🟥⬜⬜🟥🟥🟥🟥⬜⬜🟥🟥🟥🟥⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛🟥🟥⬛🟥🟥🟥⬛⬛🟥🟥🟥⬛🟥🟥⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛🟥⬛⬛⬛🟥🟥⬛⬛🟥🟥⬛⬛⬛🟥⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛
  ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛

Attribution
===========

.. |embrace-vim| replace:: ``embrace-vim``
.. _embrace-vim: https://github.com/embrace-vim

.. |@landonb| replace:: ``@landonb``
.. _@landonb: https://github.com/landonb

The |embrace-vim|_ logo by |@landonb|_ contains
`coffee cup with straw by farra nugraha from Noun Project
<https://thenounproject.com/icon/coffee-cup-with-straw-6961731/>`__
(CC BY 3.0).
  
