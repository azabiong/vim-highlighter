# Vim Highlighter

An easy words highlighter using configurable colors

## Introduction

One of the things that are not easy for people, but an easy thing for computers would be finding symbols very quickly. This plugin provides an easy way to use Vim's highlighting function which helps quickly find the usage of words and easily check spelling of variables.

## Key map

The plugin uses three mapped keys which users can assign in the configuration file.
  ```vim
    let HiSet   = 'f<CR>'           " normal, visual
    let HiErase = 'f<BS>'           " normal, visual
    let HiClear = 'f<C-L>'          " normal
  ```
>  The default key mappings are: `f Enter`, `f Backspace` and `f Ctrl+L`

  In normal mode, `HiSet` and `HiErase` keys set or erase highlights of the word under the cursor. `HiClear` key clears all highlights.

  <img width="600" src="https://user-images.githubusercontent.com/83812658/117490057-482a5600-afa9-11eb-8b4a-e2b5018ece5a.gif">

## Visual Selection

In visual mode, the highlight is selected as a pattern from the selection, and applied to other words.

  <img width="292" alt="visual" src="https://user-images.githubusercontent.com/83812658/117488190-11534080-afa7-11eb-8731-bf382f71fd4e.png">

## One Time Highlight

The plugin provides an automatic feature that erases highlights after using. It would be useful when just one time quick scanning is needed at the cursor position.

When the cursor is on a word that is not highlighted, pressing `HiErase` key sets **one time highlight**.

  <img width="271" alt="onetime" src="https://user-images.githubusercontent.com/83812658/117488827-cc7bd980-afa7-11eb-940b-6656ece00868.gif">

The highlight is maintained while the cursor stays, and then automatically turned off after the cursor moved.

## Following Highlight

When repeated operation of one time highlight is needed, there is more automatic mode which follows the cursor.

Pressing `HiSet` key over **one time highlight** without moving the cursor sets **following highlight** mode.  
The highlight follows the cursor. Pressing `HiEarase` key turns off the mode.

  <img width="450" alt="following" src="https://user-images.githubusercontent.com/83812658/117488604-95a5c380-afa7-11eb-9625-b92efaa31817.gif">

## Customizing Colors

The plugin provides 14 + 2 default colors. 
  <div style="display:inline-block">
  <img width="190" alt="default_light" src="https://user-images.githubusercontent.com/83812658/117488164-0bf5f600-afa7-11eb-90ff-fe085c814a52.png">
  <img width="190" alt="default_dark"  src="https://user-images.githubusercontent.com/83812658/117488162-0a2c3280-afa7-11eb-94dd-94d58e9de0e9.png">
  </div><br>
 
You can add, change, reorder, and save colors using Vim's native **hi** command, and see the results in real time.

### Example
> This example describes how to add two custom colors
> <span style="inline">
> <img alt="example" height=18 sytle="vertical-align:middle" src="https://user-images.githubusercontent.com/83812658/117539479-cc321b80-b045-11eb-82f6-f9cdf046a69d.png">
> </span>
> in 256 or 24-bit colors mode.
>
> If the plugin is installed and working, copy the following lines one by one, then run it in Vim's command window.
> ```
> :hi HiColor21 ctermfg=20  ctermbg=159 guifg=#0000df guibg=#afffff
> :hi HiColor22 ctermfg=228 ctermbg=129 guifg=#ffff87 guibg=#af00ff
> ```
> Now, move the cursor to any word, then input the number `21` and `HiSet` key.  
> Does it work? if you press `HiSet` key again, the next `HiColor22` will be set.
>
> You can try some other values to change the color, and see the result instantly. You can also save the colors to the configuration file using this format.

### Reference
>   This tool would be helpful when you pick colors.
>
>   [xterm-color-table.vim](https://github.com/guns/xterm-color-table.vim)

## Help tags

For more information about commands and options, please refer to:
```vim
:h Highlighter
```

## Installation

There are some options. Please choose your convenient way.

#### vim-plug
> In Vim's command window,
> ```vim
> :Plug 'azabiong/vim-highlighter'
> :PlugInstall
> ```
> copy the first line, then insert it between the following section in your configuration file.
> ```vim
> call plug#begin()
> call plug#end()
> ```

#### neobundle.vim 
> In Vim's command window,
> ```vim
> :NeoBundle 'azabiong/vim-highlighter'
> :NeoBundleInstall
> ```
> copy the first line, then insert it between the following section in your configuration file.
> ```vim
> call neobundle#begin()
> call neobundle#end()
> ```

#### Vundle.vim
> In Vim's command window,
> ```vim
> :Plugin 'azabiong/vim-highlighter'
> :PluginInstall
> ```
> copy the first line, then insert it between the following section in your configuration file.
> ```vim
> call vundle#begin()
> call vundle#end()
> ```
    
#### pathogen
> In the terminal,
> ```zsh
> cd ~/.vim/bundle && git clone https://github.com/azabiong/vim-highlighter.git
> cd ~/.vim/bundle && vim -u NONE -c "helptags vim-highlighter/doc" -c q
> ```

#### Vim 8 native
> In the terminal,
> ```zsh
> cd ~/.vim && git clone https://github.com/azabiong/vim-highlighter.git pack/azabiong/start/vim-highlighter
> cd ~/.vim && vim -u NONE -c "helptags pack/azabiong/start/vim-highlighter/doc" -c q
> ```

## Tested
  ```
    Linux   Vim 8.2
    Windows gVim 8.2
    Mac     neovim 0.4.4  macVim 8.2
  ```

## License
  MIT
