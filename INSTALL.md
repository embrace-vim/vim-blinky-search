# Vim plugin Installation options

## Install manually

Use Vim's packages feature to install manually (see
[`:help packages`](https://vimhelp.org/repeat.txt.html#packages)).

<details>
  <summary>Copy or clone the plugin under <tt>~/.vim/pack</tt></summary>

- If you want the package to automatically load on Vim startup, install
  it under a `start/` directory, e.g.,

    ```
    mkdir -p ~/.vim/pack/embrace-vim/start
    cd ~/.vim/pack/embrace-vim/start
    ```

  If you want to load the package manually, install it under an
  `opt/` directory instead (see
  [`:help pack-add`](https://vimhelp.org/repeat.txt.html#pack-add)):

    ```
    mkdir -p ~/.vim/pack/embrace-vim/opt
    cd ~/.vim/pack/embrace-vim/opt
    ```

- Then clone the project to the desired path:

    ```
    git clone https://github.com/embrace-vim/vim-blinky-search.git
    ```

  - If you installed under a `start/` directory, either restart
    Vim to load it, or load it manually to avoid restarting:

      ```
      :packadd! vim-blinky-search
      ```

  - If you installed to the optional path (under `opt/`), you'll need
    to load it manually when you want to use it, e.g.:

      ```
      :packadd! vim-blinky-search
      ```

</details>

## Install using a Vim package or Git project manager

[vim-plug]: https://github.com/junegunn/vim-plug
[Vundle]: https://github.com/VundleVim/Vundle.vim
[myrepos]: https://myrepos.branchable.com/
[ohmyrepos]: https://github.com/landonb/ohmyrepos
[pathogen]: https://github.com/tpope/vim-pathogen
[vim-addon-manager]: https://packages.qa.debian.org/v/vim-addon-manager.html

If you install manually, you may want to update the plugin
occasionally (e.g., `git pull`).

Alternatively, check out these streamlined solutions for
keeping your Vim plugins up-to-date.

<details>
  <summary>Manage plugins using <tt>vim-plug</tt></summary>

- If you'd like to be able to update from within Vim, you could use
  [`vim-plug`][vim-plug].

- You could then skip the installation steps above and register
  the plugin like this, e.g.:

  ```
  call plug#begin()

  " List your plugins here
  Plug 'embrace-vim/vim-blinky-search'

  call plug#end()
  ```

- And to update, call:

    ```
    :PlugUpdate
    ```
</details>

<details>
  <summary>Manage plugins using <tt>Vundle</tt></summary>

- [`Vundle`][Vundle] is another Vim plugin manager,
  similar to [`vim-plug`][vim-plug].

- You'd configure it something like this:

  ```
  set nocompatible              " be iMproved, required
  filetype off                  " required

  " set the runtime path to include Vundle and initialize
  set rtp+=~/.vim/bundle/Vundle.vim
  call vundle#begin()
  " alternatively, pass a path where Vundle should install plugins
  "call vundle#begin('~/some/path/here')

  " let Vundle manage Vundle, required
  Plugin 'VundleVim/Vundle.vim'

  Plugin 'embrace-vim/vim-blinky-search'

  " All of your Plugins must be added before the following line
  call vundle#end()            " required
  filetype plugin indent on    " required
  " To ignore plugin indent changes, instead use:
  "filetype plugin on
  ```

- And then to update, call one of these:

  ```
  :PluginInstall!
  :PluginUpdate
  ```
</details>

[//]: # ([<details open> if you want § unfolded by default])

<details>
  <summary>Manage plugins using <tt>myrepos</tt></summary>

- Or, if you're like the author, you could use a multi-repo Git
  project management tool, such as [`myrepos`][myrepos]
  (along with the author's library, [`ohmyrepos`][ohmyrepos]).

- With [`myrepos`][myrepos], you could update all your Git repos with
  the following command:

  ```
  mr -d / pull
  ```

- Alternatively, if you use [`ohmyrepos`][ohmyrepos], you could pull
  just Vim plugin changes with something like this:

    ```
    MR_INCLUDE=vim-plugins mr -d / pull
    ```

  - Provided that you identify your vim-plugins using the 'skip' action, e.g.:

      ```
      # Put this in ~/.mrconfig, or something loaded by it.
      [DEFAULT]
      skip = mr_exclusive "vim-plugins"

      [pack/embrace-vim/start/vim-blinky-search]
      lib = remote_set origin https://github.com/embrace-vim/vim-blinky-search.git

      [DEFAULT]
      skip = mr_exclusive
      ```
</details>

## Generate help tags

<details>
  <summary>Generate help tags using <tt>:helptags</tt></summary>

- Tell Vim to rebuild the online help docs (you only need to run
  this once, or after installing a new plugin):

    ```
    :helptags ALL
    ```

  See [`:help helptags`](https://vimhelp.org/helphelp.txt.html#%3Ahelptags).

- You can also rebuild help tags from your terminal, e.g.:

    ```
    cd ~/.vim/pack/embrace-vim/start
    vim -u NONE -c "helptags vim-blinky-search/doc" -c q
    ```

Then whenever you want to reference the help from Vim, run:

  ```
  :help vim-blinky-search
  ```

</details>

