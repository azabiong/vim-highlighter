" Vim Highlighter: Vim easy words highlighter
" Author: Azabiong
" License: MIT
" Source: https://github.com/azabiong/vim-highlighter
" Version: 1.0

scriptencoding utf-8
if exists("s:Colors")
  finish
endif
let s:cpo_save = &cpo
set cpo&vim

if !exists("g:HiOneTimeWait")
  let g:HiOneTimeWait = 260
endif
if !exists("g:HiFollowWait")
  let g:HiFollowWait = 360
endif

function s:Load()
  if !exists('s:Check')
    let s:Check = 0
  endif
  if s:Check < 256
    if has('gui_running') || (has('termguicolors') && &termguicolors) || &t_Co >= 256
      let s:Check = 256
    elseif s:Check == 0
      echo "\n Highlighter:\n\n"
          \" It seems that current color mode is lower than 256 colors:\n"
          \"     &t_Co=".&t_Co."\n\n"
          \" To enable 256 colors, please try:\n"
          \"    :set t_Co=256 \n\n"
      let s:Check = &t_Co + 1
      return 0
    endif
  endif
  if s:Check >= 256
    let s:Colors = [
    \ ['HiOneTime', 'ctermfg=234 ctermbg=152 cterm=none guifg=#001727 guibg=#afd9d9 gui=none'],
    \ ['HiFollow',  'ctermfg=234 ctermbg=151 cterm=none guifg=#002f00 guibg=#afdcaf gui=none'],
    \ ['HiColor1',  'ctermfg=17  ctermbg=112 cterm=none guifg=#001767 guibg=#8fd757 gui=none'],
    \ ['HiColor2',  'ctermfg=52  ctermbg=221 cterm=none guifg=#570000 guibg=#fcd757 gui=none'],
    \ ['HiColor3',  'ctermfg=225 ctermbg=90  cterm=none guifg=#ffdff7 guibg=#8f2f8f gui=none'],
    \ ['HiColor4',  'ctermfg=195 ctermbg=68  cterm=none guifg=#dffcfc guibg=#5783c7 gui=none'],
    \ ['HiColor5',  'ctermfg=19  ctermbg=189 cterm=bold guifg=#0000af guibg=#d7d7fc gui=bold'],
    \ ['HiColor6',  'ctermfg=89  ctermbg=225 cterm=bold guifg=#87005f guibg=#fcd7fc gui=bold'],
    \ ['HiColor7',  'ctermfg=52  ctermbg=180 cterm=bold guifg=#570000 guibg=#dfb787 gui=bold'],
    \ ['HiColor8',  'ctermfg=223 ctermbg=130 cterm=bold guifg=#fcd7a7 guibg=#af5f17 gui=bold'],
    \ ['HiColor9',  'ctermfg=230 ctermbg=242 cterm=bold guifg=#f7f7d7 guibg=#676767 gui=bold'],
    \ ['HiColor10', 'ctermfg=194 ctermbg=23  cterm=none guifg=#cff3f3 guibg=#276c37 gui=none'],
    \ ['HiColor11', 'ctermfg=22  ctermbg=194 cterm=bold guifg=#004f00 guibg=#d7f7df gui=bold'],
    \ ['HiColor12', 'ctermfg=52  ctermbg=229 cterm=none guifg=#371700 guibg=#f7f7a7 gui=none'],
    \ ['HiColor13', 'ctermfg=53  ctermbg=219 cterm=none guifg=#570027 guibg=#fcb7fc gui=none'],
    \ ['HiColor14', 'ctermfg=17  ctermbg=153 cterm=none guifg=#000057 guibg=#afd7fc gui=none'],
    \ ]
  else
    let s:Colors = [
    \ ['HiOneTime', 'ctermfg=darkBlue ctermbg=lightCyan' ],
    \ ['HiFollow',  'ctermfg=darkBlue ctermbg=lightGreen'],
    \ ['HiColor1',  'ctermfg=white ctermbg=darkGreen'    ],
    \ ['HiColor2',  'ctermfg=white ctermbg=darkCyan'     ],
    \ ['HiColor3',  'ctermfg=white ctermbg=darkMagenta'  ],
    \ ['HiColor4',  'ctermfg=white ctermbg=darkYellow'   ],
    \ ['HiColor5',  'ctermfg=black ctermbg=lightYellow'  ],
    \ ]
  endif
  let s:Color = 'HiColor'
  let s:SchemeRange = 64
  let s:Wait = [g:HiOneTimeWait, g:HiFollowWait]
  let s:WaitRange = [[0, 320], [260, 520]]
  call s:SetColors(0)

  aug Highlighter
    au!
    au WinEnter *       call highlighter#WinEnter()
    au WinLeave *       call highlighter#WinLeave()
    au ColorSchemePre * call highlighter#ColorSchemePre()
    au ColorScheme *    call highlighter#ColorScheme()
  aug END
  return 1
endfunction

function s:SetColors(default)
  for l:c in s:Colors
    if a:default || empty(s:GetColor(l:c[0]))
      exe 'hi' l:c[0].' '.l:c[1]
    endif
  endfor
endfunction

function s:GetColor(color)
  return hlexists(a:color) ? matchstr(execute('hi '.a:color), '\(cterm\|gui\).*') : ''
endfunction

function s:SetHighlight(cmd, mode)
  if s:CheckRepeat(60) | return | endif

  if !exists("w:HiColor")
    let w:HiColor = 0
  endif
  let l:match = getmatches()

  if a:cmd == '--'
    for l:m in l:match
      if match(l:m['group'], s:Color.'\d\{,2}\>') == 0
        call matchdelete(l:m['id'])
      endif
    endfor
    let w:HiColor = 0
    return
  elseif a:cmd == '+'
    let l:color = s:GetNextColor()
  else
    let l:color = 0
  endif

  let l:word = (a:mode == 'n') ? [expand('<cword>')] : split(s:GetVisualLine())
  if empty(l:word) || empty(l:word[0])
    if !l:color | call s:SetMode('-', '') | endif
    return
  endif
  let l:word = escape(l:word[0], '\')

  if a:mode == 'n'
    let l:word = '\V\<'.l:word.'\>'
  else
    let l:word = '\V'.l:word
  endif
  let l:deleted = s:DeleteMatch(l:match, l:word, '==')

  if l:color
    if a:mode == 'n' && s:GetMode(l:word)
      call s:SetMode('>', l:word)
    else
      let w:HiColor = l:color
      call matchadd(s:Color.l:color, l:word, 0)
    endif
  else
    if !l:deleted
      let l:str = (a:mode == 'n') ? '\V'.escape(s:GetStringUnder(), '\') : ''
      let l:deleted = s:DeleteMatch(l:match, l:str, '≈≈')
    endif
    if !l:deleted
      call s:SetMode('.', l:word)
    endif
  endif
endfunction

function s:CheckRepeat(interval)
  if !exists("s:InputTime")
    let s:InputTime = reltime()
    return 0
  endif
  let l:dt = reltimefloat(reltime(s:InputTime)) * 1000
  let s:InputTime = reltime()
  return l:dt < a:interval
endfunction

function s:GetNextColor()
  let l:next = v:count ? v:count : w:HiColor + 1
  return hlexists(s:Color.l:next) ? l:next : 1
endfunction

function s:GetVisualLine()
  let [l:top, l:left] = getpos("'<")[1:2]
  let [l:bottom, l:right] = getpos("'>")[1:2]
  if l:top != l:bottom | let l:right = -1 | endif
  if l:left == l:right | return '' | endif
  if l:right > 0
    let l:right -= &selection == 'inclusive' ? 1 : 2
  endif
  let l:line = getline(l:top)
  return l:line[l:left-1 : l:right]
endfunction

function s:DeleteMatch(match, word, op)
  let l:i = len(a:match)
  while l:i > 0
    let l:i -= 1
    let l:m = a:match[l:i]
    if match(l:m['group'], s:Color.'\d\{,2}\>') == 0
      let l:match = 0
      if a:op == '=='
        let l:match = a:word ==# l:m['pattern']
      else
        let l:match = (match(a:word, l:m['pattern']) != -1) && (l:m['pattern'][2:3] != '\<')
      endif
      if l:match
        return matchdelete(l:m['id']) + 1
      endif
    endif
  endwhile
  return 0
endfunction

function s:GetStringUnder()
  let l:line = getline('.')
  let l:col = col('.')
  let l:low = max([l:col-64, 0])
  let l:str = matchstr(strpart(l:line, l:low, l:col - l:low), '\zs\S\+$')
  return l:str.matchstr(l:line, '^\S\+', l:col)
endfunction

function s:GetMode(word)
  return !v:count && exists("w:HiMode") &&
        \!w:HiMode['>'] && w:HiMode['p'] == getpos('.') && w:HiMode['w'] ==# a:word
endfunction

" s:SetMode(cmd) actions
"     |       |     !>     |   >    |
" cmd | !mode | !same same | always |  1:on, 0:off
"  .  |   1   |   =     0  |   0    |  =:update
"  >  |   >   |   >     >  |   .    |  >:follow
"  -  |   0   |   0     0  |   0    |
let s:Action = { 'cmd':[ '.', '>' ], 'action':[['1','=0','0'], ['>','>>','.']] }
"
function s:SetMode(cmd, word)
  let l:mode = exists("w:HiMode")
  let l:index = index(s:Action['cmd'], a:cmd)

  if index == -1
    let l:op = '0'
  else
    let l:action = s:Action['action'][l:index]
    call s:LinkCursorEvent(a:word)
    let w:HiMode['p'] = getpos('.')

    if !l:mode
      let l:op = l:action[0]
    elseif !w:HiMode['>']
      let l:word = empty(a:word) ? s:GetCurrentWord() : a:word
      let l:same = w:HiMode['w'] ==# l:word
      let l:op = l:action[1][l:same]
    else
      let l:op = l:action[2]
    endif

    if l:op == '>'
      let w:HiMode['>'] = 1
      let w:HiMode['_'] = s:Wait[1]
    elseif l:op == '='
      call timer_stop(w:HiMode['t'])
      let w:HiMode['t'] = 0
      let w:HiMode['w'] = l:word
    endif
  endif

  if '=>' =~ l:op
    call highlighter#UpdateHiWord(0)
  elseif '0' == l:op
    call s:UnlinkCursorEvent(1)
  endif
endfunction

" symbols: follow('>'), wait('_'), pos, timer, reltime, match, word
function s:LinkCursorEvent(word)
  if !exists("#HiEventCursor")
    if !exists("w:HiMode")
      let w:HiMode = {'>':0, '_':s:Wait[0], 'p':[], 't':0, 'r':[], 'm':0, 'w':a:word}
      call s:UpdateWait()
    else
      let w:HiMode['t'] = 0
      let w:HiMode['w'] = ''
    endif
    call highlighter#UpdateHiWord(0)
    aug HiEventCursor
      au!
      au InsertEnter * call <SID>EraseOneTime()
      au CursorMoved * call <SID>FollowCursor()
    aug END
  endif
endfunction

function s:UnlinkCursorEvent(op)
  if exists("#HiEventCursor")
    au!  HiEventCursor
    aug! HiEventCursor
    call s:EraseHiWord()
    if a:op || !w:HiMode['>']
      unlet w:HiMode
    endif
  endif
endfunction

function s:UpdateWait()
  let l:wait = [g:HiOneTimeWait, g:HiFollowWait]
  if l:wait != s:Wait
    let s:Wait[0] = min([max([l:wait[0], s:WaitRange[0][0]]), s:WaitRange[0][1]])
    let s:Wait[1] = min([max([l:wait[1], s:WaitRange[1][0]]), s:WaitRange[1][1]])
    let [g:HiOneTimeWait, g:HiFollowWait] = s:Wait
    let w:HiMode['_'] = s:Wait[0]
  endif
endfunction

function s:EraseHiWord()
  if w:HiMode['m']
    call matchdelete(w:HiMode['m'])
    let w:HiMode['m'] = 0
  endif
endfunction

function s:SetHiWord(word)
  if empty(a:word) | return | endif
  let l:group = ['HiOneTime', 'HiFollow'][w:HiMode['>']]
  let w:HiMode['m'] = matchadd(l:group, a:word, -1)
  let w:HiMode['w'] = a:word
endfunction

function s:GetCurrentWord()
  if match(getline('.')[col('.')-1], '\k') != -1
    return '\V\<'.expand('<cword>').'\>'
  else
    return ''
  endif
endfunction

function s:EraseOneTime()
  if exists("w:HiMode") && !w:HiMode['>']
    call s:FollowCursor()
  endif
endfunction

function s:FollowCursor(...)
  if !exists("w:HiMode") | return | endif
  if w:HiMode['t']
    let w:HiMode['r'] = reltime()
  else
    let l:wait = a:0 ? a:1 : w:HiMode['_']
    let w:HiMode['t'] = timer_start(l:wait, 'highlighter#UpdateHiWord')
    let w:HiMode['r'] = []
  endif
endfunction

function highlighter#UpdateHiWord(_)
  if !exists("w:HiMode") | return | endif
  if !w:HiMode['t']
    let l:word = empty(w:HiMode['w']) ? s:GetCurrentWord() : w:HiMode['w']
  else
    if !empty(w:HiMode['r'])
      let l:wait = float2nr(reltimefloat(reltime(w:HiMode['r'])) * 1000)
      let l:wait = max([0, w:HiMode['_'] - l:wait])
      let w:HiMode['t'] = 0
      call <SID>FollowCursor(l:wait)
      return
    endif
    if w:HiMode['>']
      let w:HiMode['t'] = 0
      let l:word = s:GetCurrentWord()
      if empty(l:word) | return | endif
    else
      if w:HiMode['p'] == getpos('.')  " visual selection
        let w:HiMode['t'] = 0
      else
        call s:SetMode('-', '')
      endif
      return
    endif
  endif
  call s:EraseHiWord()
  call s:SetHiWord(l:word)
endfunction

function highlighter#WinEnter()
  if !exists("w:HiMode") | return | endif
  call s:LinkCursorEvent('')
endfunction

function highlighter#WinLeave()
  if !exists("w:HiMode") | return | endif
  call s:UnlinkCursorEvent(0)
endfunction

function highlighter#ColorSchemePre()
  let s:Current = []
  for l:k in ['HiOneTime', 'HiFollow']
    let l:v = s:GetColor(l:k)
    if !empty(l:v)
      call add(s:Current, [l:k, l:v])
    endif
  endfor
  for l:i in range(1, s:SchemeRange)
    let l:k = s:Color.l:i
    let l:v = s:GetColor(l:k)
    if !empty(l:v)
      call add(s:Current, [l:k, l:v])
    endif
  endfor
endfunction

function highlighter#ColorScheme()
  if !exists("s:Current")
    return
  endif
  for l:c in s:Current
    exe 'hi' l:c[0].' '.l:c[1]
  endfor
  unlet s:Current
endfunction

function highlighter#Command(cmd)
  if !exists("s:Colors")
    if !s:Load() | return | endif
  endif
  let l:arg = split(a:cmd)
  let l:cmd = get(l:arg, 0, '')
  let l:opt = get(l:arg, 1, '')

  if     l:cmd ==# ''        | echo " Hi there!"
  elseif l:cmd ==# '+'       | call s:SetHighlight('+', 'n')
  elseif l:cmd ==# '-'       | call s:SetHighlight('-', 'n')
  elseif l:cmd ==# '+x'      | call s:SetHighlight('+', 'x')
  elseif l:cmd ==# '-x'      | call s:SetHighlight('-', 'x')
  elseif l:cmd ==# '>>'      | call s:SetMode('>', '')
  elseif l:cmd ==# 'clear'   | call s:SetHighlight('--', 'n') | call s:SetMode('-', '')
  elseif l:cmd ==# 'default' | call s:SetColors(1)
  else
    echo ' Hi: unknown_command: '.l:cmd
  endif
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
