# Vim Highlighter

  <img width="220" alt="highlighter" align="right" src="https://user-images.githubusercontent.com/83812658/136645135-46bbe613-0ac7-4688-9deb-4bc28ae627f3.jpg">
  <h3> Introduction </h3>
  
  Highlighting keywords or lines can be useful when analyzing code, reviewing summaries, and quickly comparing spellings. This plugin extends Vim's highlighting capabilities with additional features such as saving and loading highlights, finding variables, and customizing colors.

### Contents

  &nbsp; &nbsp;
  [Key Map](#key-map) <br> &nbsp; &nbsp;
  [Sync Mode](#sync-mode) <br> &nbsp; &nbsp; 
  [Save & Load Highlights](#save--load-highlights) &nbsp; &nbsp; &nbsp; &nbsp;
  [One Time Highlight](#one-time-highlight) &nbsp; &nbsp; &nbsp; &nbsp;
  [Following Highlight](#following-highlight) &nbsp; &nbsp; &nbsp; &nbsp;
  [Find in Files Highlight](#find-in-files-highlight) <br> &nbsp; &nbsp;
  [Customizing Colors](#customizing-colors) <br> &nbsp; &nbsp;
  [Installation](#installation)  
  <br>

## Key Map

  The plugin uses the following default key mappings which you can assign in the configuration file.

  ```vim
    let HiSet   = 'f<CR>'           " normal, visual
    let HiErase = 'f<BS>'           " normal, visual
    let HiClear = 'f<C-L>'          " normal
    let HiFind  = 'f<Tab>'          " normal, visual
  ```

> Default key mappings: `f Enter`, `f Backspace`, `f Ctrl+L` and `f Tab`

  In normal mode, `HiSet` and `HiErase` keys set or erase highlights of the word under the cursor. `HiClear` key clears all highlights.

  <img width="600" src="https://user-images.githubusercontent.com/83812658/117490057-482a5600-afa9-11eb-8b4a-e2b5018ece5a.gif">

### Visual Selection

  In visual mode, the highlight is selected as a pattern from the selection and applied to other words.

  <img width="290" alt="visual" src="https://user-images.githubusercontent.com/83812658/117488190-11534080-afa7-11eb-8731-bf382f71fd4e.png"> <br>

  You can also select an entire line and highlight it.

  <img width="296" alt="visual_line" src="https://user-images.githubusercontent.com/83812658/125556295-356322d3-4992-40fe-81f1-299ca5eb7007.png"> <br>
  &nbsp;

## Sync Mode

  You can synchronize highlighting of the current window with other split windows with the command:
  ```vim
   :Hi == 
  ```
  and switch back to default single window highlighting mode using: 
  ```vim
   :Hi = 
  ```
  '**Sync Mode**' applies to all windows in the current tab-page, and can be set differently for each tab-page.  
  &nbsp;  

## Save & Load highlights

  Sometimes when you want to save highlights of the current window and reload them next time, you can use:
  ```vim
   :Hi save
  ```
  and when loading: 
  ```vim
   :Hi load
  ```
  You can name the file when saving, and use tab-completion when loading. For example:
  ```vim
   :Hi save name
   :Hi load <Tab>
  ```
  Highlight files are stored in a user configurable `HiKeywords` directory. To browse and manage files in the directory, you can open **netrw** using the command:
  ```vim
   :Hi ls
  ```
  You can also use relative paths. For example, to save and load a highlight file in the current directory:
  ```vim
   :Hi save ./name
   :Hi load ./<Tab>
  ```
  <br>

## One Time Highlight

  The plugin has an automatic feature to clear highlights after use. This can be useful when you only need one quick scan from the cursor position.

  When the cursor is over a word or visual selection that is not highlighted, pressing `HiErase` key sets '**One Time Highlight**'. The highlight stays on while the cursor is not moving, and automatically turns off after the cursor moves.

  <img width="271" alt="onetime" src="https://user-images.githubusercontent.com/83812658/117488827-cc7bd980-afa7-11eb-940b-6656ece00868.gif"> <br><br>


## Following Highlight

  When you need automatic matching based on cursor movement, '**Following Highlight**' mode can be useful.

  Pressing `HiSet` key over '**One Time Highlight**' without moving the cursor sets '**Following Highlight**' mode.
  The highlight follows the cursor. Pressing `HiEarase` key turns off the mode.

  <img width="450" alt="following" src="https://user-images.githubusercontent.com/83812658/117488604-95a5c380-afa7-11eb-9625-b92efaa31817.gif"> <br>

### Matching option

  Sometimes, when comparing variables consisting of letters and symbols, Vim's **`<cWORD>`** matching option can be useful.

  <img width="422" alt="cword" src="https://user-images.githubusercontent.com/83812658/125083024-d6829b80-e102-11eb-8725-df0dc9e6915b.gif"> <br>

  The following command toggles between the default **`<cword>`** and **`<cWORD>`** matching options:

  ```vim
   :Hi <>
  ```
  <br>

## Find in Files Highlight

  If you have installed hi-performance search tools such as **ag**, **rg**, **ack**, **sift**, or **grep**, the plugin can run it when looking for symbols based on the current directory. And when the given expression is simple, the plugin can highlight patterns to make them easier to find.

  `HiFind` key brings up the **Find** command prompt.

  <img width="760" alt="find" src="https://user-images.githubusercontent.com/83812658/123290729-77daf080-d54c-11eb-8181-949333013d71.gif"> <br>

> The new version uses the `Hi/Find` command prompt with `Tab` key completion support.

### Search tool

  If one of the tools listed above is in the $PATH, the plugin can run it using default options. You can set your preferred tool and options in the `HiFindTool` variable. For example:

  ```vim
    let HiFindTool = 'grep -H -EnrI --exclude-dir=.git'
  ```

 <details>
 <summary><b>Tools</b></summary> 

  ```vim
    let HiFindTool = 'ag --nocolor --noheading --column --nobreak'

    let HiFindTool = 'rg -H --color=never --no-heading --column --smart-case'

    let HiFindTool = 'ack -H --nocolor --noheading --column --smart-case'

    let HiFindTool = 'sift --no-color --line-number --column --binary-skip --git --smart-case'

    let HiFindTool = 'ggrep -H -EnrI --exclude-dir=.git'
 
    let HiFindTool = 'git grep -EnI --no-color --column'
  ```
 </details>

### Input

  You can use general order of passing arguments to search tools:

  ```
   :Hi/Find  [options]  expression  [directories_or_files]
  ```

  `Tab` key completion for long options, directory and file names is supported.

#### 🍏 &nbsp;Tip

> To enter the current file name, typing `%` `Tab` would be convenient.

### Expression

  Among various regular expression options in **Vim**, the plugin uses "very magic" style syntax which uses the standard regex syntax with fewer escape sequences.

#### Examples

> searching for "red" or "blue":
> ```
>  :Hi/Find  red|blue
> ```
> pattern with spaces:
> ```
>  :Hi/Find  "pattern with spaces"
> ```
> color codes such as: &nbsp; #e3d3b7, &nbsp; #AFD9D9
> ```
>  :Hi/Find  -i  #[A-F0-9]{6}
> ```
> class types or variables that start with a capital letter A or S: &nbsp; Array, Set, String, Symbol...
> ```
>  :Hi/Find  \b[AS]\w+
> ```

#### Fixed string or Literal option

> This option treats the input as a literal string, which is useful when searching for codes with symbols.
> ```
>   ag,  rg,  grep,  git   -F --fixed-strings
>   ack, sift              -Q --literal
> ```
> Example: &nbsp; searching for `item[i+1].size() * 2`
> ```
>  :Hi/Find  -F  'item[i+1].size() * 2'
> ```

### Visual selection

  When searching for parts of a string in a file as is, visual selection would be useful.  
  After selecting the part, press `HiFind` key. The plugin will escape the pattern properly.

### Navigation

  It will be handy to use keyboard shortcuts to the following commands to easily navigate the search results.

  `Hi/next` and `Hi/previous` commands jump to the file.

  `Hi/older` and `Hi/newer` commands navigate the search history.

  Key-mapping example:
  ```vim
   :nn <silent>-  :<C-U> Hi/next<CR>
   :nn <silent>_  :<C-U> Hi/previous<CR>
   :nn f<Left>    :<C-U> Hi/older<CR>
   :nn f<Right>   :<C-U> Hi/newer<CR>
  ```

#### 🍏 &nbsp;Tip

> Pressing the number `1` before the `Hi/next` command invokes a special function that jumps to the first item in the search results. For example, in the mapping above, entering `1-` will jump to the first item.

### Find window

  The following keys and functions are available in the **Find** window.

  |key|function|
  |:--:|--|
  |<kbd>Ctrl</kbd>+<kbd>C</kbd>| Stop searching |
  |<kbd>r</kbd>                | Rotate Find window |
  |<kbd>s</kbd>                | Split and Jump to file |
  |<kbd>Enter</kbd>            | Jump to file |

  &nbsp;

### Windows Unicode

  The following option may be useful for correctly displaying Unicode characters output.
  ```vim
  :set encoding=utf-8 
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
> This tool will be helpful when editing colors.
>
> [xterm-color-table.vim](https://github.com/guns/xterm-color-table.vim)

  <br>

## Help tags

  For more information about commands and options, please refer to:
  ```vim
   :h HI
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
