" Vim Highlighter: Vim easy words highlighter
" Author: Azabiong
" License: MIT
" Source: https://github.com/azabiong/vim-highlighter
" Version: 1.14

scriptencoding utf-8
if exists("g:loaded_vim_highlighter")
  finish
endif
if !has('reltime') || !has('timers')
  echoe 'Highlighter: plugin uses features of Vim version 8.0 or higher'
  finish
endif
let g:loaded_vim_highlighter = 1

let s:cpo_save = &cpo
set cpo&vim

function s:MapKeys()
  let l:key_map = [
  \ [ 'nn', 'HiSet',   'f<CR>',  '+'     ],
  \ [ 'xn', 'HiSet',   'f<CR>',  '+x'    ],
  \ [ 'nn', 'HiErase', 'f<BS>',  '-'     ],
  \ [ 'xn', 'HiErase', 'f<BS>',  '-x'    ],
  \ [ 'nn', 'HiClear', 'f<C-L>', 'clear' ],
  \ ]
  for l:map in l:key_map
    let l:key = get(g:, l:map[1], l:map[2])
    exe l:map[0].' <silent> '.l:key.' :<C-U>if highlighter#Command("'.l:map[3].'") \| noh \| endif<CR>'
  endfor
endfunction

if !exists("HiMapKeys") || HiMapKeys
  call s:MapKeys()
  let HiMapKeys = 1
endif

command! -complete=custom,s:List -nargs=* Hi if highlighter#Command(<q-args>) | noh | endif
function s:List(...)
  return ">>\nclear\ndefault"
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
