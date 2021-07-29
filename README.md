# Vim Highlighter

> ```
> Version 1.25   Add commands - save, load highlights
> ```

## Introduction

  One of the things that are not easy for people, but an easy thing for computers would be finding symbols very quickly. This plugin provides an easy way to use Vim's highlighting function which helps you quickly find variables and easily compare spellings.

#### Contents
  &nbsp; &nbsp;
  [Key Map](#key-map) &nbsp; &nbsp; &nbsp; &nbsp;
  [One Time Highlight](#one-time-highlight) &nbsp; &nbsp; &nbsp; &nbsp;
  [Following Highlight](#following-highlight) &nbsp; &nbsp; &nbsp; &nbsp;
  [Find in Files Highlight](#find-in-files-highlight) &nbsp; &nbsp; &nbsp; 
  [Commands](#commands) <br> &nbsp; &nbsp; 
  [Customizing Colors](#customizing-colors) <br> &nbsp; &nbsp;
  [Installation](#installation)  
  <br>

## Key Map

  The plugin uses several key mappings which you can assign in the configuration file.
  ```vim
    let HiSet   = 'f<CR>'           " normal, visual
    let HiErase = 'f<BS>'           " normal, visual
    let HiClear = 'f<C-L>'          " normal
    let HiFind  = 'f<Tab>'          " normal, visual
  ```
> The default key mappings are: `f Enter`, `f Backspace`, `f Ctrl+L` and `f Tab`

  In normal mode, `HiSet` and `HiErase` keys set or erase highlights of the word under the cursor. `HiClear` key clears all highlights.

  <img width="600" src="https://user-images.githubusercontent.com/83812658/117490057-482a5600-afa9-11eb-8b4a-e2b5018ece5a.gif">

### Visual Selection

  In visual mode, the highlight is selected as a pattern from the selection, and applied to other words.

  <img width="290" alt="visual" src="https://user-images.githubusercontent.com/83812658/117488190-11534080-afa7-11eb-8731-bf382f71fd4e.png"> <br>

  You can also select the entire line and highlight it.

  <img width="296" alt="visual_line" src="https://user-images.githubusercontent.com/83812658/125556295-356322d3-4992-40fe-81f1-299ca5eb7007.png"> <br>
  &nbsp;

## One Time Highlight

  The plugin provides an automatic feature that erases highlights after using. It would be useful when just one time quick scanning is needed at the cursor position.

  When the cursor is on a word that is not highlighted, pressing `HiErase` key sets '**One Time Highlight**'.  
  The highlight stays on while the cursor is not moving, and automatically turns off after the cursor moves.

  <img width="271" alt="onetime" src="https://user-images.githubusercontent.com/83812658/117488827-cc7bd980-afa7-11eb-940b-6656ece00868.gif"> <br>   &nbsp; 

## Following Highlight

  When you need automatic matching based on cursor movement, '**Following Highlight**' mode can be useful.

  Pressing `HiSet` key over '**One Time Highlight**' without moving the cursor sets '**Following Highlight**' mode.
  The highlight follows the cursor. Pressing `HiEarase` key turns off the mode.

  <img width="450" alt="following" src="https://user-images.githubusercontent.com/83812658/117488604-95a5c380-afa7-11eb-9625-b92efaa31817.gif"> <br>

### Matching option

  Sometimes **`<cWORD>`** matching option of **Vim** can be useful to quickly compare variables consisting of characters and symbols. The following command toggles between **`<cWORD>`** and default **`<cword>`** matching options:
  ```vim
   :Hi <>
  ```
  <img width="420" alt="cword" src="https://user-images.githubusercontent.com/83812658/125083024-d6829b80-e102-11eb-8725-df0dc9e6915b.gif"> <br>
  &nbsp;

## Find in Files Highlight

  If you have installed hi-performance search tools such as **ag**, **rg**, **ack**, **sift**, or **grep**, the plugin can run it when looking for symbols based on the current directory. And when the given expression is simple, the plugin can highlight patterns to make them easier to find.

  `HiFind` key brings up the **Find** command prompt.

  <img width="760" alt="find" src="https://user-images.githubusercontent.com/83812658/123290729-77daf080-d54c-11eb-8181-949333013d71.gif">

### Search tool

  If one of the tools listed above is found in the $PATH, the plugin can run it using default options. You can set your preferred tool and options in the `HiFindTool` variable. For example:
  ```vim
    let HiFindTool = 'grep -EnrI --exclude-dir=.git'
  ```
 <details>
 <summary> Tools </summary>

  ```vim
    let HiFindTool = 'ag --nocolor --noheading --column --nobreak'

    let HiFindTool = 'rg --color=never --no-heading --column --smart-case'

    let HiFindTool = 'ack --nocolor --noheading --column --smart-case'

    let HiFindTool = 'sift --no-color --line-number --column --binary-skip --git --smart-case'

    let HiFindTool = 'ggrep -EnrI --exclude-dir=.git'
 
    let HiFindTool = 'git grep -EnI --no-color --column'
  ```
 </details>

### Input

  You can use general order of passing arguments to search tools:
  ```
    Find  [options]  expression  [directories_or_files]
  ```

### Expression

  Among various regular expression options in **Vim**, the plugin uses "very magic" style syntax which uses the standard regex syntax with fewer escape sequences.

#### Examples

> searching for "red" or "blue":
> ```
>   Find  red|blue
> ```
> pattern with spaces:
> ```
>   Find  "pattern with spaces"
> ```
> color codes such as: &nbsp; #e3d3b7, &nbsp; #AFD9D9
> ```
>   Find  -i  #[A-F0-9]{6}
> ```
> class types or variables that start with a capital letter A or S: &nbsp; Array, Set, String, Symbol
> ```
>   Find  \b[AS]\w+
> ```

#### Fixed string or Literal option

> This option treats the input as a literal string, which is useful when searching for codes with symbols.
> ```
>   ag,  rg,  grep    -F --fixed-strings
>   ack, sift         -Q --literal
> ```
> Example: &nbsp; searching for `item[i+1].size() * 2`
> ```
>   Find  -F  'item[i+1].size() * 2'
> ```

### Navigation

  After a search, it will be handy to use keyboard shortcuts to the following commands to easily navigate the results.

  `Hi/next` and `Hi/previous` commands jump to the file.

  `Hi/older` and `Hi/newer` commands navigate the search history.

  Key-mapping example: &nbsp;
  ```vim
   :nn <silent>-  :Hi/next<CR>
   :nn <silent>_  :Hi/previous<CR>
   :nn f<Left>    :Hi/older<CR>
   :nn f<Right>   :Hi/newer<CR>
  ```

### Find window

  The following keys and functions are available in the **Find** window.

  |key|function|
  |:--:|--|
  |<kbd>Ctrl</kbd>+<kbd>C</kbd>| Stop searching |
  |<kbd>r</kbd>                | Rotate Find window |
  |<kbd>s</kbd>                | Split and Jump to file |
  |<kbd>Enter</kbd>            | Jump to file |

### Unicode

  If Unicode characters are not displayed correctly, it may be useful to set the follwing option in your configuration file.
  ```vim
  set encoding=utf-8 
  ```
  <br>

## Commands

### Sync Mode

  You can synchronize highlighting of the current window with other windows with the command:
  ```vim
   :Hi == 
  ```
  and switch back to default single window highlighting mode using: 
  ```vim
   :Hi = 
  ```
  '**Sync Mode**' applies to all windows in the current tab-page, and can be set differently for each tab-page.  
  &nbsp;  

### Save & Load highlights

  Sometimes when you want to save highlights and reload them next time, the `Hi:save` and `Hi:load` commands can be useful: 
  ```vim
   :Hi save
  ```
  When loading: 
  ```vim
   :Hi load
  ```
  Highlights of the current window are saved in the user configurable `HiKeywords` directory. You can also name the file when saving, and use tab-completion when loading. 
  ```vim
   :Hi save mark2
   :Hi load <Tab>
  ```
  To browse and manage the list of highlight files, you can use `Hi:ls` command to open **netrw**.
  ```vim
   :Hi ls
  ```
  <br>

## Customizing Colors

  The plugin provides 14 + 3 default colors.
  <div style="display:inline-block">
  <img width="190" alt="default_light" src="https://user-images.githubusercontent.com/83812658/123291069-bcff2280-d54c-11eb-83af-0ea1b5e63b7b.png">
  <img width="190" alt="default_dark"  src="https://user-images.githubusercontent.com/83812658/123291402-08193580-d54d-11eb-82a4-653d6e44bd4d.png">
  </div><br>

  You can add, change, reorder, and save colors using Vim's native **hi** command, and see the changes in real time.

### Example 1
> This example adds two custom colors
> <span style="inline">
> <img alt="example" height=18 style="vertical-align:middle" src="https://user-images.githubusercontent.com/83812658/117539479-cc321b80-b045-11eb-82f6-f9cdf046a69d.png">
> </span>
> in 256 or 24-bit colors mode.
>
> If the plugin is installed and working, copy the following lines one by one, and then run it in the Vim's command window.
> ```vim
>  :hi HiColor21 ctermfg=20  ctermbg=159 guifg=#0000df guibg=#afffff
>  :hi HiColor22 ctermfg=228 ctermbg=129 guifg=#ffff87 guibg=#af00ff
> ```
> Now, move the cursor to any word, and then input the number `21` and `HiSet` key.
> Does it work? if you press `HiSet` key again, the next `HiColor22` will be set.
>
> You can try different values to change the color, and see the result instantly.  You can store colors in the configuration file using this format. 

### Example 2
> The following command changes the color of '**Find in Files Highlight**'
> ```vim
>  :hi HiFind ctermfg=52 ctermbg=182 guifg=#570707 guibg=#e7bfe7
> ```

### Reference
> This tool would be helpful when editing colors.
>
> [xterm-color-table.vim](https://github.com/guns/xterm-color-table.vim)

  <br>

## Help tags

  For more information about commands and options, please refer to:
  ```vim
   :h Highlighter
  ```
  <br>

## Installation

  There are several options. Please choose your convenient way.

<details>
<summary> vim-plug </summary>
  
> &nbsp;  
> in the Vim's command window:
> ```vim
> :Plug 'azabiong/vim-highlighter'
> :PlugInstall
> ```
> copy the first line, and then insert it between the following section in your configuration file.
> ```vim
> call plug#begin()
> call plug#end()
> ```
</details>


<details>
<summary> neobundle </summary>
  
> &nbsp;  
> in the Vim's command window:
> ```vim
> :NeoBundle 'azabiong/vim-highlighter'
> :NeoBundleInstall
> ```
> copy the first line, and then insert it between the following section in your configuration file.
> ```vim
> call neobundle#begin()
> call neobundle#end()
> ```
</details>

<details>
<summary> Vundle.vim </summary>
  
> &nbsp;  
> in the Vim's command window:
> ```vim
> :Plugin 'azabiong/vim-highlighter'
> :PluginInstall
> ```
> copy the first line, and then insert it between the following section in your configuration file.
> ```vim
> call vundle#begin()
> call vundle#end()
> ```
</details>

<details>
<summary> Vim 8 native </summary>
  
> &nbsp;  
> default install directory:
>
> |Linux, &nbsp; Mac| Windows &nbsp;|
> |:--:|--|
> |~/.vim| ~/vimfiles|
>
> in the terminal:
> ```zsh
> cd ~/.vim && git clone --depth=1 https://github.com/azabiong/vim-highlighter.git pack/azabiong/start/vim-highlighter
> cd ~/.vim && vim -u NONE -c "helptags pack/azabiong/start/vim-highlighter/doc" -c q
> ```
> [Windows] in your vimrc:
> ```vim
> set encoding=utf-8    " recommended
>
> packadd vim-highlighter
> ```
</details>
  <br>

## Tested
  ```
    Linux   Vim 8.2
    Windows gVim 8.2
    Mac     neovim 0.4.4  macVim 8.2
  ```
## Issues

  If you have any issues that need fixing, comments or new features you would like to add, please feel free to open an issue.

## License
  MIT
