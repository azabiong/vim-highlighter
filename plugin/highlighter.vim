" Vim Highlighter: Highlight words with configurable colors
" Author: Azabiong
" License: MIT
" Source: https://github.com/azabiong/vim-highlighter
" Version: 1.24

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
  \ [ 'nn', 'HiFind',  'f<Tab>', '/'     ],
  \ [ 'xn', 'HiFind',  'f<Tab>', '/x'    ],
  \ ]
  for l:map in l:key_map
    let l:key = get(g:, l:map[1], l:map[2])
    exe l:map[0].' <silent> '.l:key.' :<C-U>if highlighter#Command("'.l:map[3].'") \| noh \| endif<CR>'
  endfor
endfunction

if !exists("g:HiMapKeys") || g:HiMapKeys
  call s:MapKeys()
  let HiMapKeys = 1
endif

command! -complete=custom,s:List -count -nargs=* Hi if highlighter#Command(<q-args>, <count>) | noh | endif
function s:List(...)
  return "==\n>>\n\<>\n/next\n/previous\n/older\n/newer\n\/open\n/close\n:default\n"
endfunction

ca HI Hi

let &cpo = s:cpo_save
unlet s:cpo_save
