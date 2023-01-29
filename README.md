<!-- https://github.com/azabiong/vim-highlighter -->

# Vim Highlighter

 <p><h6> &nbsp;&nbsp; ver 1.56 </h6></p>

 <img width="220" alt="highlighter" align="right" src="https://user-images.githubusercontent.com/83812658/136645135-46bbe613-0ac7-4688-9deb-4bc28ae627f3.jpg">
 <h3> Introduction </h3>

 Highlighting keywords or lines can be useful when analyzing code, reviewing summaries, and quickly comparing spellings.
 This plugin extends Vim's highlighting capabilities with additional features such as jump to highlights,
 saving and loading, finding patterns, and customizing colors.

### Contents

 &nbsp;&nbsp;
 [Installation](#installation) <br> &nbsp;&nbsp;
 [Key Map](#key-map) <br> &nbsp;&nbsp;
 [Sync Mode](#sync-mode) <br> &nbsp;&nbsp;
 [Jump to Highlights](#jump-to-highlights) &nbsp;&nbsp;&nbsp;
 [Save & Load](#save--load-highlights) &nbsp;&nbsp;&nbsp;
 [One Time Highlight](#one-time-highlight) &nbsp;&nbsp;&nbsp;
 [Following Highlight](#following-highlight) &nbsp;&nbsp; &nbsp;
 [Find in Files Highlight](#find-in-files-highlight) <br> &nbsp;&nbsp;
 [Customizing Colors](#customizing-colors) <br> &nbsp;&nbsp;
 [Configuration](#configuration-examples) <br> &nbsp;&nbsp;

 <details>
 <summary><b>&nbsp; What's New </b></summary>
 <br>

 | version | feature | key map |
 |:--:|:--|:--:|
 | 1.56 | [One Time Highlight](#one-time-highlight)&nbsp; and **Jump** | |
 | 1.55 | [Highlights in a specific line](#highlights-in-a-specific-line) | O |
 | 1.52 | [Find window](#find-window)&nbsp; View &nbsp;<kbd>i</kbd> | O |
 | 1.50 | [Jump to Highlights](#jump-to-highlights) | O |
 | 1.38 | [Input](#input)&nbsp; patterns in the command-line | |
 | 1.35 | [Multifunction keys](#configuration-examples)&nbsp; for **Find** | O |

 </details>
 <br>

## Installation

 You can use your preferred plugin manager using the string `'azabiong/vim-highlighter'`. For example:
 ```vim
   Plug 'azabiong/vim-highlighter'
 ```
 <details>
 <summary>&nbsp; or,&nbsp; Vim's built-in package feature: </summary>

> <br>
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

## Key Map

 The plugin uses the following default key mappings which you can assign in the configuration file.

 ```vim
   let HiSet   = 'f<CR>'
   let HiErase = 'f<BS>'
   let HiClear = 'f<C-L>'
   let HiFind  = 'f<Tab>'
 ```
> Default key mappings: `f Enter`, `f Backspace`, `f Ctrl+L` and `f Tab`

 In normal mode, `HiSet` and `HiErase` keys set or erase highlights of the word under the cursor. `HiClear` key clears all highlights.

 <img width="600" src="https://user-images.githubusercontent.com/83812658/117490057-482a5600-afa9-11eb-8b4a-e2b5018ece5a.gif">

### Visual Selection

 In visual mode, the highlight is selected as a partial pattern from the selection and applied to other words.

 <img width="290" alt="visual" src="https://user-images.githubusercontent.com/83812658/117488190-11534080-afa7-11eb-8731-bf382f71fd4e.png"> <br>

 You can also select an entire line and highlight it.

 <img width="296" alt="visual_line" src="https://user-images.githubusercontent.com/83812658/125556295-356322d3-4992-40fe-81f1-299ca5eb7007.png"> <br>

### Input

 To set highlights using a pattern:
 ```vim
  :Hi + pattern
 ```
 <br>

## Sync Mode

When synchronizing the highlighting of the current window with other split windows, you can use:
 ```vim
  :Hi ==
 ```
 and to switch back to single window highlighting mode:
 ```vim
  :Hi =
 ```
 '**Sync Mode**' applies to all windows in the current tab-page, and can be set differently for each tab-page.

 <br>

## Jump to Highlights

 The plugin supports jumping to highlights using two sets of commands.

 The `Hi <` and `Hi >` commands move the cursor back and forth to recently highlighted words
 or matching highlights at the cursor position.

 The `Hi {` and `Hi }` commands, on the other hand, move the cursor to the nearest highlighted word,
 even if the pattern differs from the current selection.

 <img width="393" alt="jump" src="https://user-images.githubusercontent.com/83812658/169995084-4c623681-e54c-4174-bd30-81e6856b6f8d.gif"><br>

 You can easily define key mappings for these commands. For example:

 ```vim
   nn <CR>   <Cmd>Hi><CR>
   nn g<CR>  <Cmd>Hi<<CR>
   nn [<CR>  <Cmd>Hi{<CR>
   nn ]<CR>  <Cmd>Hi}<CR>
 ```
 > Alternatively, you can map the <kbd>n</kbd> and <kbd>N</kbd> keys to `HiSearch()` function, which automatically selects
 > the search type between native search and jump(`Hi>`, `Hi<`) &nbsp; → &nbsp;[Configuration](#configuration-examples)

 <br>

## Save & Load Highlights

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
 Highlight files are stored in a user configurable `HiKeywords` directory.
 To browse and manage files in the directory, you can open **netrw** using the command:
 ```vim
  :Hi ls
 ```
 <details>
 <summary><b>&nbsp; relative path </b></summary>
 <br>

 You can also use relative paths. For example, to save and load a highlight file in the current directory:
 ```vim
  :Hi save ./name
  :Hi load ./<Tab>
 ```
 </details>
 <br>

## One Time Highlight

 The plugin has an automatic feature to clear highlights after use.
 This can be useful when you only need one quick scan from the cursor position.

 When the cursor is over a word or visual selection that is not highlighted, pressing `HiErase` key sets '**One Time Highlight**'.
 The highlight stays on while the cursor is not moving, and automatically turns off after the cursor moves.

 <img width="455" alt="onetime" src="https://user-images.githubusercontent.com/83812658/169995537-61725353-15b9-4d33-bccc-d0c471c15306.gif"><br>

 '**One Time Highlight**' displays matches in all windows on the current tab-page, and&nbsp;
 '**Jump to Highlights**' commands are also supported.

 <br>

## Following Highlight

 When you need automatic matching based on cursor movement, '**Following Highlight**' mode can be useful.

 Pressing `HiSet` key over '**One Time Highlight**' without moving the cursor sets '**Following Highlight**' mode.
 The highlight follows the cursor. Pressing `HiEarase` key turns off the mode.

 <img width="450" alt="following" src="https://user-images.githubusercontent.com/83812658/162587365-64092e0a-0b2f-4947-855a-171da12c8da6.gif"> <br>  
 '**Following Highlight**' displays matches in all windows on the current tab-page, and&nbsp;
 '**Jump to Highlights**' commands are also supported.

 <details>
 <summary><b>&nbsp;cWORD &nbsp;matching </b></summary> 

 Sometimes, when comparing variables consisting of letters and symbols, Vim's **`<cWORD>`** matching option can be useful.

 <img width="422" alt="cword" src="https://user-images.githubusercontent.com/83812658/125083024-d6829b80-e102-11eb-8725-df0dc9e6915b.gif"> <br>

 The following command toggles between the default **`<cword>`** and **`<cWORD>`** matching options:

 ```vim
  :Hi <>
 ```
 </details>
 <br>

## Find in Files Highlight

 If you have installed hi-performance search tools such as **ag**, **rg**, **ack**, **sift**, or **grep**,
 the plugin can run it when looking for symbols based on the current directory. And when the given expression is simple,
 the plugin can highlight patterns to make them easier to find.

 `HiFind` key brings up the **Find** command prompt.

 <img width="760" alt="find" src="https://user-images.githubusercontent.com/83812658/153761451-1828bbdb-b0ac-4598-a624-b69b94369333.gif"> <br>

### Search tool

 If one of the tools listed above is in the $PATH, the plugin can run it using default options.
 You can also set your preferred search tool and options in the `HiFindTool` variable. For example:

 ```vim
   let HiFindTool = 'grep -H -EnrI --exclude-dir=.git'
 ```

 <details>
 <summary><b>&nbsp;Tools</b></summary>

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

 `Tab` key completion for --long-options, directory and file names is supported.

### Expression

 Among various regular expression options in **Vim**, the plugin uses "very magic" style syntax
 which uses the standard regex syntax with fewer escape sequences.

#### Examples

> searching for "red" or "blue":
> ```
>  :Hi/Find  red|blue
> ```
> pattern with spaces:
> ```
>  :Hi/Find  "pattern with spaces"
> ```
> class types or variables that start with an uppercase letter A or S: &nbsp; Array, Set, String, Symbol...
> ```
>  :Hi/Find  \b[AS]\w+
> ```

 <details>
 <summary><b>&nbsp; Fixed string or Literal option </b></summary>

> <br>
>
> This option treats the input as a literal string, which is useful when searching for codes with symbols.
> ```
>   ag,  rg,  grep,  git   -F --fixed-strings
>   ack, sift              -Q --literal
> ```
> Example: &nbsp; searching for `item[i+1].size() * 2`
> ```
>  :Hi/Find  -F  'item[i+1].size() * 2'
> ```
 </details>

### Visual selection

 When searching for parts of a string in a file as is, visual selection would be useful.  
 After selecting the part, press `HiFind` key. The plugin will escape the pattern properly.

### Find window

  The following keys and functions are available in the **Find** window.

  |key|function|
  |:--:|--|
  |<kbd>Ctrl</kbd>+<kbd>C</kbd>| Stop searching |
  |<kbd>r</kbd>                | Resize / Rotate |
  |<kbd>i</kbd>                | View |
  |<kbd>s</kbd>                | Split and View |
  |<kbd>Enter</kbd>            | Jump to position |

### Navigation

  Additional commands are supported to quickly navigate through search results.

 `Hi/next` and `Hi/previous` commands jump directly to the location of the file.

 `Hi/older` and `Hi/newer` commands navigate the search history.

 It would be convenient to define key mappings for these commands for easy navigation. For example:
 ```vim
   nn -        <Cmd>Hi/next<CR>
   nn _        <Cmd>Hi/previous<CR>
   nn f<Left>  <Cmd>Hi/older<CR>
   nn f<Right> <Cmd>Hi/newer<CR>
 ```

#### 🍏 &nbsp;Tip

> Pressing the number `1` before the `Hi/next` command invokes a special function that jumps to the first item in the search results. For example, in the mapping above, entering `1` `-` will jump to the first item.

  <br>

## Customizing Colors

  The plugin provides two default color sets which are automatically loaded based on the current `background` mode.
  <div style="display:inline-block">
  <img width="198" alt="default_light" src="https://user-images.githubusercontent.com/83812658/153830890-51960a1b-4a61-4bc6-9c8f-c693a0ee5825.png">
  <img width="198" alt="default_dark" src="https://user-images.githubusercontent.com/83812658/153829910-58e948e4-6657-4b55-8b39-39575e26e858.png">
  </div><br>

  You can use the **`:hi`** command to add, change, rearrange colors, and save them to the configuration file or color scheme.

 <details>
 <summary><b>&nbsp;Example 1 </b></summary>

> <br>
>
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
> You can try different values while seeing the results immediately.
 </details>

 <details>
 <summary><b>&nbsp;Example 2 </b></summary>

> <br>
>
> The following command changes the color of '**Find in Files Highlight**'
> ```vim
>  :hi HiFind ctermfg=52 ctermbg=182 guifg=#570707 guibg=#e7bfe7
> ```

 </details>
  <br>

## Configuration Examples

 <details>
 <summary><b>&nbsp;Basic </b></summary>

> ```vim
> " Unicode
> set encoding=utf-8
>
> " default key mappings
> " let HiSet   = 'f<CR>'
> " let HiErase = 'f<BS>'
> " let HiClear = 'f<C-L>'
> " let HiFind  = 'f<Tab>'
>
> " jump key mappings
> nn <CR>     <Cmd>Hi><CR>
> nn g<CR>    <Cmd>Hi<<CR>
> nn [<CR>    <Cmd>Hi{<CR>
> nn ]<CR>    <Cmd>Hi}<CR>
>
> " find key mappings
> nn -        <Cmd>Hi/next<CR>
> nn _        <Cmd>Hi/previous<CR>
> nn f<Left>  <Cmd>Hi/older<CR>
> nn f<Right> <Cmd>Hi/newer<CR>
>
> " command abbreviations
> ca HL Hi:load
> ca HS Hi:save
>
> " directory to store highlight files
> " let HiKeywords = '~/.vim/after/vim-highlighter'
>
> " highlight colors
> " hi HiColor21 ctermfg=52  ctermbg=181 guifg=#8f5f5f guibg=#d7cfbf cterm=bold gui=bold
> " hi HiColor22 ctermfg=254 ctermbg=246 guifg=#e7efef guibg=#979797 cterm=bold gui=bold
> " hi HiColor30 ctermfg=none cterm=bold guifg=none gui=bold
>
> ```
> <details>
> <summary><b>&nbsp; nvim &nbsp;.lua </b></summary>
>
> ```lua
> -- jump and find key mappings
> vim.cmd([[
>   nn <CR>     <Cmd>Hi><CR>
>   nn g<CR>    <Cmd>Hi<<CR>
>   nn [<CR>    <Cmd>Hi{<CR>
>   nn ]<CR>    <Cmd>Hi}<CR>
>
>   nn -        <Cmd>Hi/next<CR>
>   nn _        <Cmd>Hi/previous<CR>
>   nn f<Left>  <Cmd>Hi/older<CR>
>   nn f<Right> <Cmd>Hi/newer<CR>
> ]])
>
> -- directory to store highlight files
> vim.g.HiKeywords = '~/.vim/after/vim-highlighter'
> ```
> </details>

 <br>
 </details>

 <details>
 <summary><b>&nbsp;Color scheme</b></summary>

> &nbsp;  
> Highlight colors can also be included in a unified color scheme theme or saved as a separate file
> in your **colors** directory. `~/.vim/colors` &nbsp;or&nbsp; `~/vimfiles/colors`  
> &nbsp;  
> For example, you can create a '**sample.vim**' file in the **colors** directory, and store some colors:
> ```vim
> hi HiColor21 ctermfg=52  ctermbg=181 guifg=#8f5f5f guibg=#d7cfbf cterm=bold gui=bold
> hi HiColor22 ctermfg=254 ctermbg=246 guifg=#e7efef guibg=#979797 cterm=bold gui=bold
> hi HiColor30 ctermfg=none cterm=bold guifg=none gui=bold
> ```
>
> You can now load colors using the **`colorscheme`** command:
> ```vim
> :colorscheme sample
> ```

 <br>
 </details>

 <details>
 <summary><b>&nbsp;Multifunction keys for Find</b></summary>

> &nbsp;  
> The plugin's `HiFind()` function returns whether the **Find** window is visible.
> The idea is to define different actions for the keys depending on whether the **Find** window is displayed or not.
>
> The following example defines the `-` `_` and `f-` keys to execute the **Hi** command while
> the **Find** window is visible, otherwise execute the original function.
>
> ```vim
> " find key mappings
> nn -   <Cmd>call <SID>HiOptional('next', '-')<CR>
> nn _   <Cmd>call <SID>HiOptional('previous', '_')<CR>
> nn f-  <Cmd>call <SID>HiOptional('close', 'f-')<CR>
>
> function s:HiOptional(cmd, key)
>   if HiFind()
>     exe "Hi" a:cmd
>   else
>     exe "normal!" a:key
>   endif
> endfunction
> ```
>
> <details>
> <summary><b>&nbsp; nvim &nbsp;.lua </b></summary>
>
> ```lua
> -- find key mappings
> vim.cmd([[
>   nn -   <Cmd>call v:lua.hi_optional('next', '-')<CR>
>   nn _   <Cmd>call v:lua.hi_optional('previous', '_')<CR>
>   nn f-  <Cmd>call v:lua.hi_optional('close', 'f-')<CR>
> ]])
>
> function _G.hi_optional(cmd, key)
>   if vim.fn.HiFind() == 1 then
>     vim.cmd('Hi '.. cmd)
>   else
>     vim.cmd('normal! '.. key)
>   end
> end
> ```
>
> </details>
  <br>

 </details>

 <details>
 <summary><b>&nbsp;Jump to highlights with <kbd>n</kbd> and <kbd>N</kbd> keys</b></summary>

> &nbsp;  
> You can also define <kbd>n</kbd> and <kbd>N</kbd> keys for both the native search and the plugin's jump commands.
> ```vim
> " jump key mappings
> nn n  <Cmd>call HiSearch('n')<CR>
> nn N  <Cmd>call HiSearch('N')<CR>
> ```
> While `hlsearch` is displayed, the function executes the native search command assigned to each key,
> otherwise, it executes the `Hi>` or `Hi<` command. When switching from native search to jump mode, 
> you can simply turn off `hlsearch` using the **`:noh`** command. For example:
> ```vim
> nn <Esc>n  <Cmd>noh<CR>
> ```
> <details>
> <summary><b>&nbsp; nvim &nbsp;.lua </b></summary>
>
> ```lua
> -- jump key mappings
> vim.cmd([[
>   nn n  <Cmd>call HiSearch('n')<CR>
>   nn N  <Cmd>call HiSearch('N')<CR>
>
>   " :noh commmand mapping, if there isn't
>   nn <Esc>n  <Cmd>noh<CR>
> ]])
> ```
> </details>

 </details>
 <br>

## Advanced features
 
### Highlights in a specific line

 Sometimes, when you want to apply highlighting only to a Specific Line, `HiSetSL` key mapping can be useful.
 Highlighting is limited to a specific line, and **Jump** commands are also available.

 <img width="324" alt="specific_line" src="https://user-images.githubusercontent.com/83812658/207630276-49e31b01-4e27-4598-bb28-91ac5e68e544.gif"><br>

 Key mapping example:
 ```vim
 let HiSetSL = 't<CR>'
 ```
 <details>
 <summary><b>&nbsp; nvim &nbsp;.lua </b></summary>

 ```lua
 vim.g.HiSetSL = 't<CR>'
 ```
 </details>

 `Note`&nbsp; The highlighting may change if lines are added or deleted above it.


 <br>

## Help tags

 For more information about commands and options, please refer to:
 ```vim
  :h HI
 ```
 <br>

## Issues

 If you have any issues that need fixing, comments or new features you would like to add, please feel free to open an issue.

 <br>

## License
 MIT
