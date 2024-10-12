" Vim Highlighter: Highlight words and expressions
" Author: Azabiong
" License: MIT
" Source: https://github.com/azabiong/vim-highlighter
" Version: 1.63

scriptencoding utf-8
if exists("g:loaded_vim_highlighter")
  finish
endif
let g:loaded_vim_highlighter = 1

if !has('reltime') || !has('timers')
  echoe ' Highlighter: plugin uses features of Vim version 8.2 or higher '
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

function s:MapKeys()
  let l:key_map = [
  \ ['nn', 'HiSet',   'f<CR>',  '+'    ],
  \ ['xn', 'HiSet',   'f<CR>',  '+x'   ],
  \ ['nn', 'HiErase', 'f<BS>',  '-'    ],
  \ ['xn', 'HiErase', 'f<BS>',  '-x'   ],
  \ ['nn', 'HiClear', 'f<C-L>', 'clear'],
  \ ['nn', 'HiFind',  'f<Tab>', '/'    ],
  \ ['xn', 'HiFind',  'f<Tab>', '/x'   ],
  \ ['nn', 'HiSetSL', 't<CR>',  '+%'   ],
  \ ['xn', 'HiSetSL', 't<CR>',  '+x%'  ],
  \ ]
  for l:map in l:key_map
    let l:key = get(g:, l:map[1], l:map[2])
    if !empty(l:key)
      if l:map[3][0] == '/'
        exe l:map[0] l:key ':<C-U><C-R>=highlighter#Find("'.l:map[3].'")<CR>'
      else
        exe l:map[0] '<silent>' l:key ':<C-U>if highlighter#Command("'.l:map[3].'") \| noh \| endif<CR>'
      endif
    endif
  endfor
endfunction

function HiFind()
  return bufwinnr(bufnr(' Find *')) != -1
endfunction

function HiList()
  return highlighter#List()
endfunction

function HiSearch(key)
  return highlighter#Search(a:key)
endfunction

function HiSetPos(...)
  return highlighter#SetPosHighlight(a:000)
endfunction

function HiDelPos(...)
  return highlighter#DelPosHighlight(a:000)
endfunction

if get(g:,'HiMapKeys', 1)
  call s:MapKeys()
endif

aug HiColorScheme
  au!
  au ColorSchemePre * call highlighter#ColorScheme('pre')
  au ColorScheme    * call highlighter#ColorScheme('')
aug END

command! -complete=customlist,highlighter#Complete -count -nargs=*
         \ Hi if highlighter#Command(<q-args>, <count>) | noh | endif
command! -complete=customlist,highlighter#Complete -count -nargs=*
         \ HI if highlighter#Command(<q-args>, <count>) | noh | endif

let &cpo = s:cpo_save
unlet s:cpo_save
