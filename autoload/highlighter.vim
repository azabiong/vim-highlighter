" Vim Highlighter: Vim easy words highlighter
" Author: Azabiong
" License: MIT
" Source: https://github.com/azabiong/vim-highlighter
" Version: 1.15

scriptencoding utf-8
if exists("s:Version")
  finish
endif
let s:cpo_save = &cpo
set cpo&vim

if !exists("g:HiOneTimeWait")
  let g:HiOneTimeWait = 260
endif
if !exists("g:HiFollowWait")
  let g:HiFollowWait = 320
endif
if !exists('g:HiFindTool')
  let g:HiFindTool = ''
endif
if !exists('g:HiFindHistory')
  let g:HiFindHistory = 5
endif
let g:HiFindLines = 0

let s:Version   = '1.15'
let s:Keywords  = {'usr': expand('<sfile>:h:h').'/keywords/', 'plug': expand('<sfile>:h').'/keywords/', '.':[]}
let s:Find      = {'cmd':[], 'opt':[], 'exp':'', 'file':[], 'line':'', 'err':0, 'hi_exp':'', 'hi_err':'', 'hi':''}
let s:FindList  = {'name':' Find *', 'height':8, 'log':'*',
                  \'buf':0, 'pos':0, 'lines':0, 'select':0, 'edit':0, 'logs':{'list':[], 'tag':[], 'index':0}}
let s:FindTools = ['ag --nocolor --noheading --column --nobreak',
                  \'rg --color=never --no-heading --column',
                  \'ack --nocolor --noheading --column',
                  \'egrep -rnI --exclude-dir=.git']
const s:FL = s:FindList

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
      return
    endif
  endif
  if s:Check >= 256
    let s:Colors = [
    \ ['HiOneTime', 'ctermfg=234 ctermbg=152 cterm=none guifg=#001727 guibg=#afd9d9 gui=none'],
    \ ['HiFollow',  'ctermfg=234 ctermbg=151 cterm=none guifg=#002f00 guibg=#afdfaf gui=none'],
    \ ['HiFind',    'ctermfg=52  ctermbg=187 cterm=none guifg=#471707 guibg=#e3d3b7 gui=none'],
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
    \ ['HiFind',    'ctermfg=yellow ctermbg=darkGray'    ],
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
    au BufEnter       * call <SID>BufEnter()
    au BufLeave       * call <SID>BufLeave()
    au BufHidden      * call <SID>BufHidden()
    au WinEnter       * call <SID>WinEnter()
    au WinLeave       * call <SID>WinLeave()
    au BufWinEnter    * call <SID>BufWinEnter()
    au ColorSchemePre * call <SID>ColorSchemePre()
    au ColorScheme    * call <SID>ColorScheme()
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

function s:SetHighlight(cmd, mode, num)
  if s:CheckRepeat(60) | return | endif

  if !exists("w:HiColor")
    let w:HiColor = 0
  endif
  let l:match = getmatches()

  if a:cmd == '--'
    for l:m in l:match
      if match(l:m['group'], s:Color) == 0
        call matchdelete(l:m['id'])
      endif
    endfor
    let w:HiColor = 0
    return
  elseif a:cmd == '+'
    let l:color = s:GetNextColor(a:num)
  else
    let l:color = 0
  endif

  if a:mode == 'n'
    let l:word = expand('<cword>')
  else
    let l:visual = s:GetVisualLine()
    let l:word = get(split(l:visual), 0, '')
  endif
  if empty(l:word)
    if !l:color | call s:SetMode('-', '') | endif
    return
  endif

  let l:word = escape(l:word, '\')
  let l:case = (&ic || @/ =~ '\\c') ? '\c' : ''
  let l:search = match(@/, l:word.l:case) != -1
  if  l:search && a:mode == 'n' && @/[:1] == '\<'
    let l:search = match(l:word.l:case, @/) != -1
  endif
  if a:mode == 'n'
    let l:word = '\V\<'.l:word.'\>'
  else
    let l:word = '\V'.l:word
  endif

  let l:deleted = s:DeleteMatch(l:match, '==', l:word)
  if l:color
    if a:mode == 'n' && s:GetMode(l:word)
      call s:SetMode('>', l:word)
    else
      let w:HiColor = l:color
      call matchadd(s:Color.l:color, l:word, 0)
      let s:Search = l:search
    endif
  else
    if !l:deleted
      if a:mode == 'n'
        let l:deleted = s:DeleteMatch(l:match, '≈n', s:GetStringPart())
      else
        let l:deleted = s:DeleteMatch(l:match, '≈x', l:visual)
      endif
    endif
    if !l:deleted
      let s:Search = (s:SetMode('.', l:word) == '1') && l:search
    endif
  endif
endfunction

function s:CheckRepeat(interval)
  if !exists("s:InputTime")
    let s:InputTime = reltime()
    return
  endif
  let l:dt = reltimefloat(reltime(s:InputTime)) * 1000
  let s:InputTime = reltime()
  return l:dt < a:interval
endfunction

function s:GetNextColor(num)
  let l:next = a:num ? a:num : (v:count ? v:count : w:HiColor+1)
  return hlexists(s:Color.l:next) ? l:next : 1
endfunction

function s:GetVisualLine()
  let [l:top, l:left] = getpos("'<")[1:2]
  let [l:bottom, l:right] = getpos("'>")[1:2]
  if l:top != l:bottom | let l:right = -1 | endif
  if l:left == l:right | return | endif
  if l:right > 0
    let l:right -= &selection == 'inclusive' ? 1 : 2
  endif
  let l:line = getline(l:top)
  return l:line[l:left-1 : l:right]
endfunction

function s:DeleteMatch(match, op, part)
  let l:i = len(a:match)
  while l:i > 0
    let l:i -= 1
    let l:m = a:match[l:i]
    if match(l:m.group, s:Color.'\d\{,2}\>') == 0
      let l:match = 0
      if a:op == '=='
        let l:match = a:part ==# l:m.pattern
      elseif (a:op == '≈n')
        if l:m.pattern[2:3] != '\<'
          let l:str = a:part.word
          let l:match = match(l:str, l:m.pattern) != -1
        endif
      elseif a:op == '≈x'
        let l:match = match(a:part, l:m.pattern) != -1
      endif
      if l:match
        return matchdelete(l:m.id) + 1
      endif
    endif
  endwhile
endfunction

function s:GetStringPart()
  let l:line = getline('.')
  let l:col = col('.')
  let l:low = max([l:col-256, 0])
  let l:left = strpart(l:line, l:low, l:col - l:low)
  let l:right = strpart(l:line, l:col, l:col + 256)
  let l:word = matchstr(l:left, '\zs\S\+$')
  let l:word .= matchstr(l:right, '^\S\+')
  return {'word':l:word, 'line': l:left.l:right}
endfunction

function s:GetMode(word)
  return !v:count && exists("w:HiMode") &&
       \ !w:HiMode['>'] && w:HiMode['p'] == getpos('.') && w:HiMode['w'] ==# a:word
endfunction

" s:SetMode(cmd) actions
"     |       |     !>     |     >    |
" cmd | !mode | !same same | !key key |  1:on, 0:off
"  .  |   1   |   =     0  |   0   >  |  =:update
"  >  |   >   |   >     >  |   >   >  |  >:follow
"  -  |   0   |   0     0  |   0   0  |
function s:SetMode(cmd, word)
  if a:cmd == '.'
    if !exists("w:HiMode")
      let l:word = a:word
      let l:op = '1'
    elseif !w:HiMode['>']
      let l:word = empty(a:word) ? s:GetCurrentWord('*') : a:word
      let l:op = (w:HiMode['w'] ==# l:word) ? '0' : '='
    else
      let l:word = s:GetCurrentWord('k')
      let l:op = (empty(w:HiMode['m']) || empty(l:word)) ? '0' : '>'
    endif
  elseif a:cmd == '>'
    let l:word = empty(a:word) ? s:GetCurrentWord('*') : a:word
    let l:op = '>'
  else
    let l:op = '0'
  endif

  if '1=>' =~ l:op
    call s:LinkCursorEvent(l:word)
    let w:HiMode['p'] = getpos('.')
    if l:op == '>'
      call s:GetKeywords()
      let w:HiMode['>'] = 1
      let w:HiMode['_'] = s:Wait[1]
      call s:UpdateHiWord(0)
    elseif l:op == '='
      call timer_stop(w:HiMode['t'])
      let w:HiMode['t'] = 0
    endif
  elseif l:op == '0'
    call s:UnlinkCursorEvent(1)
  endif
  return l:op
endfunction

" symbols: follow('>'), wait('_'), pos, timer, reltime, match, word
function s:LinkCursorEvent(word)
  let l:event = exists("#HiEventCursor")
  if !exists("w:HiMode")
    let w:HiMode = {'>':0, '_':s:Wait[0], 'p':[], 't':0, 'r':[], 'm':'', 'w':a:word}
    call s:UpdateWait()
  else
    let w:HiMode['w'] = a:word
  endif
  call s:UpdateHiWord(0)
  if !l:event
    aug HiEventCursor
      au!
      au InsertEnter * call <SID>InsertEnter()
      au InsertLeave * call <SID>InsertLeave()
      au CursorMoved * call <SID>FollowCursor()
    aug END
  endif
endfunction

function s:UnlinkCursorEvent(force)
  if exists("#HiEventCursor")
    au!  HiEventCursor
    aug! HiEventCursor
    if exists("w:HiMode")
      call s:EraseHiWord()
      if a:force || !w:HiMode['>']
        unlet w:HiMode
      endif
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
  if !empty(w:HiMode['m'])
    if w:HiMode['m'] == '<1>'
      call s:SetOneTimeWin('')
    else
      call matchdelete(w:HiMode['m'])
    endif
    let w:HiMode['m'] = ''
    let w:HiMode['w'] = ''
  endif
endfunction

function s:SetHiWord(word)
  if empty(a:word) | return | endif
  if w:HiMode['>']
    let w:HiMode['m'] = matchadd('HiFollow', a:word, -1)
  else
    let w:HiMode['m'] = '<1>'
    call s:SetOneTimeWin(a:word)
  endif
  let w:HiMode['w'] = a:word
endfunction

function s:GetKeywords()
  let l:ft = !empty(&filetype) ? split(&filetype, '\.')[0] : ''
  if !exists("s:Keywords['".l:ft."']")
    let s:Keywords[l:ft] = []
    let l:list = s:Keywords[l:ft]
    for l:file in [s:Keywords.plug.l:ft, s:Keywords.usr.l:ft]
      if filereadable(l:file)
        for l:line in readfile(l:file)
          if l:line[0] == '#' | continue | endif
          let l:list += split(l:line)
        endfor
      endif
    endfor
    call uniq(sort(l:list))
  endif
  let s:Keywords['.'] = s:Keywords[l:ft]
endfunction

"op:  *:any  #:filter  k:keyword
function s:GetCurrentWord(op)
  if match(getline('.')[col('.')-1], '\k') != -1
    let l:word = expand('<cword>')
    let l:keyword = index(s:Keywords['.'], l:word) != -1
    if(a:op == '*') || (a:op == '#' && !l:keyword) || (a:op == 'k' && l:keyword)
      return '\V\<'.l:word.'\>'
    endif
  endif
endfunction

function s:FollowCursor(...)
  if !exists("w:HiMode") | return | endif
  if w:HiMode['t']
    let w:HiMode['r'] = reltime()
  else
    let l:wait = a:0 ? a:1 : w:HiMode['_']
    let w:HiMode['t'] = timer_start(l:wait, function('s:UpdateHiWord'))
    let w:HiMode['r'] = []
  endif
endfunction

function s:UpdateHiWord(tid)
  if !exists("w:HiMode") | return | endif
  if !a:tid
    let l:word = empty(w:HiMode['w']) ? s:GetCurrentWord('#') : w:HiMode['w']
    let w:HiMode['t'] = 0
  else
    if !empty(w:HiMode['r'])
      let l:wait = float2nr(reltimefloat(reltime(w:HiMode['r'])) * 1000)
      let l:wait = max([0, w:HiMode['_'] - l:wait])
      let w:HiMode['t'] = 0
      call s:FollowCursor(l:wait)
      return
    endif
    if w:HiMode['>']
      let w:HiMode['t'] = 0
      let l:word = s:GetCurrentWord('#')
      if  l:word ==# w:HiMode['w'] | return | endif
    else
      if w:HiMode['p'] == getpos('.') && mode() =='n' " visual selection
        let w:HiMode['t'] = 0
      else
        call s:UnlinkCursorEvent(1)
      endif
      return
    endif
  endif
  call s:EraseHiWord()
  call s:SetHiWord(l:word)
endfunction

function s:InsertEnter()
  if !exists("w:HiMode") | return | endif
  if w:HiMode['>']
    call s:EraseHiWord()
  else
    call s:FollowCursor()
  endif
endfunction

function s:InsertLeave()
  if !exists("w:HiMode") || !w:HiMode['>'] | return | endif
  call s:LinkCursorEvent('')
endfunction

function s:SetOneTimeWin(exp)
  let l:win = winnr()
  noa windo call <SID>SetOneTime(a:exp)
  noa exe l:win." wincmd w"
endfunction

function s:SetOneTime(exp)
  if empty(a:exp)
    if exists('w:HiOneTime')
      call matchdelete(w:HiOneTime)
      unlet w:HiOneTime
    endif
  else
    let w:HiOneTime = matchadd('HiOneTime', a:exp)
  endif
endfunction

function s:SetHiFindWin(exp, buf)
  let l:win = winnr()
  noa windo call <SID>SetHiFind(a:exp, a:buf)
  noa exe l:win." wincmd w"
endfunction

function s:SetHiFind(exp, buf)
  if exists('w:HiFind')
    call matchdelete(w:HiFind)
    unlet w:HiFind
  endif
  if !empty(a:exp) && (empty(&buftype) || bufnr() == a:buf)
    let w:HiFind = matchadd('HiFind', a:exp)
  endif
endfunction

function s:Find(mode)
  if !s:FindTool() | return | endif

  let l:visual = (a:mode == 'x') ? '"'.escape(s:GetVisualLine(), '$^*()-+[]{}\|.?"').'"' : ''
  call inputsave()
  let l:input = input('  Find  ', l:visual)
  call inputrestore()
  if !s:FindArgs(l:input) | return | endif

  let l:cmd = s:Find.cmd + s:Find.opt + [s:Find.exp] + s:Find.file
  call s:FindStop(0)
  call s:FindStart(l:input)
  if exists('*job_start')
    let s:Find.job = job_start(l:cmd, {
        \ 'in_io': 'null',
        \ 'out_cb':  function('s:FindOut'),
        \ 'err_cb':  function('s:FindErr'),
        \ 'close_cb':function('s:FindClose'),
        \ })
  elseif exists('*jobstart')
    let s:Find.job = jobstart(l:cmd, {
        \ 'on_stdout': function('s:FindStdOut'),
        \ 'on_stderr': function('s:FindStdOut'),
        \ 'on_exit':   function('s:FindExit'),
        \ })
  endif
endfunction

function s:FindTool()
  let s:Find.cmd = []
  let l:list = !empty(g:HiFindTool) ? [g:HiFindTool] : s:FindTools
  for l:tool in l:list
    let l:cmd = split(l:tool)
    if !empty(l:cmd) && executable(l:cmd[0])
      let s:Find.cmd = l:cmd
      if empty(g:HiFindTool) | let g:HiFindTool = l:tool | endif
      break
    endif
  endfor
  if empty(s:Find.cmd)
    echo " No executable search tool, HiFindTool='".g:HiFindTool."'"
    return
  elseif !exists('*job_start') && !exists('*jobstart')
    echo " channel - feature not found "
    return
  endif
  return 1
endfunction

function s:FindArgs(arg)
  if match(a:arg, '\S') == -1
    call s:FindStatus('') | return
  endif
  let l:exp = s:FindExp(a:arg)
  let s:Find.opt = l:exp ? split(a:arg[:l:exp-1]) : []
  let l:pat = s:FindUnescape(a:arg[l:exp:])
  let s:Find.exp = l:pat.str
  let l:path = l:exp + l:pat.len
  let l:path = split(a:arg[l:path:])
  let s:Find.file = (l:path == []) ? ['.'] : l:path
  call s:FindMatch()
  return 1
endfunction

function s:FindExp(arg)
  let l:op = match(a:arg, '-- ')
  if l:op != -1 | return l:op + 3 | endif
  let l:len = len(a:arg)
  let l:op = 0
  for i in range(l:len)
    if  a:arg[i] == ' '
      let l:op = 0
    elseif !l:op
      if a:arg[i] != '-'
        return i
      endif
      let l:op = 1
    endif
  endfor
  return l:len
endfunction

function s:FindUnescape(arg)
  let l:exp = {'str':'', 'len':0}
  let l:len = len(a:arg)
  let l:qt = ''
  let i = 0
  while i < l:len
    let c = a:arg[i]
    if c == "'" || c == '"'
      if     i == 0    | let l:qt = c
      elseif l:qt == c | let i += 1 | break
      else             | let l:exp.str .= c
      endif
    elseif c == '\'
      let c = a:arg[i+1]
      if index([' ', "'", '"'], c) != -1
        let l:exp.str .= c
      else
        let l:exp.str .= '\'.c
      endif
      let i += 1
    elseif c == ' '
      if empty(l:qt) | break
      else           | let l:exp.str .= c
      endif
    else
      let l:exp.str .= c
    endif
    let i += 1
  endwhile
  let l:exp.len = i
  return l:exp
endfunction

function s:FindMatch()
  let [s:Find.hi_exp, s:Find.hi_err] = ['', '']
  let l:flag = {'i':0, 'w':0}
  for l:op in s:Find.opt
    if l:op[1] == '-'
      if l:op == '--' | continue |  endif
      return
    endif
    for l:c in range(1, len(l:op)-1)
      if     l:op[l:c] ==# 'i' | let l:flag.i = 1
      elseif l:op[l:c] ==# 'w' | let l:flag.w = 1
      else   | return
      endif
    endfor
  endfor
  let l:exp = escape(s:Find.exp, '~@%&=<>'."'")
  let [l:p, l:q] = ['', '']
  if l:flag.i | let l:p = '\c' | endif
  if l:flag.w
    let l:p .= '<' | let l:q = '>'
  else
    if l:exp[:1]  == '\b' | let l:exp = '<'.l:exp[2:]  | endif
    if l:exp[-2:] == '\b' | let l:exp = l:exp[:-3].'>' | endif
  endif
  let s:Find.hi_exp = '\v'.l:p.l:exp.l:q
endfunction

function s:FindStatus(msg)
  call timer_start(0, {-> execute("echo '".a:msg."'", '')})
endfunction

function s:FindStart(arg)
  " buf variables: {Status}
  if !s:FL.buf
    let s:FL.buf = bufadd(s:FL.name)
    let s:FL.lines = 0
    let g:HiFindLines = 0
    call bufload(s:FL.buf)
    call s:FindOpen()

    setlocal buftype=nofile bh=hide noma noswapfile nofen ft=find
    let b:Status = ''
    let &l:statusline = '  Find | %<%{b:Status} %=%3.l / %L  '

    nn <silent><buffer><C-C>         :call <SID>FindStop(1)<CR>
    nn <silent><buffer>r             :call <SID>FindRotate()<CR>
    nn <silent><buffer>s             :call <SID>FindEdit('split')<CR>
    nn <silent><buffer><CR>          :call <SID>FindEdit('=')<CR>
    nn <silent><buffer><2-LeftMouse> :call <SID>FindEdit('=')<CR>

    " airline
    if exists('*airline#add_statusline_func')
      call airline#add_statusline_func('highlighter#Airline')
      call airline#add_inactive_statusline_func('highlighter#Airline')
      wincmd p | wincmd p
    endif
  endif

  if !empty(s:FL.log)
    call add(s:FL.logs.list, [])
    call add(s:FL.logs.tag, [])
  endif
  let l:logs = len(s:FL.logs.list)
  let g:HiFindHistory = min([max([2, g:HiFindHistory]), 10])
  while l:logs > g:HiFindHistory
    call remove(s:FL.logs.list, 0)
    call remove(s:FL.logs.tag, 0)
    let l:logs -= 1
  endwhile
  let l:index = l:logs - 1
  let l:status = join(s:Find.cmd).' '.join(s:Find.opt).' '.s:Find.exp.' '.join(s:Find.file)
  let s:FL.logs.index = l:index
  let s:FL.log = s:FL.logs.list[l:index]
  let s:FL.logs.tag[l:index] = [l:status, '']
  let s:Find.hi = ''
  let s:Find.line = ''
  let s:Find.err = 0

  call s:FindSet([], '=')
  call s:FindOpen()
  if exists('w:HiFind')
    call matchdelete(w:HiFind)
    unlet w:HiFind
  endif
  let b:Status = l:status

  if !empty(s:Find.hi_exp)
    try
      let w:HiFind = matchadd('HiFind', s:Find.hi_exp)
      let s:Find.hi = s:Find.hi_exp
      let s:FL.logs.tag[l:index][1] = s:Find.hi
    catch
      let s:Find.hi_err = v:exception
    endtry
  endif
  call s:FindStatus(" searching...")
endfunction

function s:FindOpen(...)
  if !s:FL.buf | return | endif
  let l:win = bufwinnr(s:FL.buf)
  if l:win == -1
    let l:pos = a:0 ? a:1: 0
    exe (l:pos ? 'vert ' : '').['bel', 'abo', 'bel'][l:pos].' sb'.s:FL.buf
    if  !l:pos | exe "resize ".min([s:FL.height, winheight(0)]) | endif
    let s:FL.pos = l:pos
  else
    exe l:win. " wincmd w"
  endif
  return l:win
endfunction

function s:FindStop(op)
  if     !exists('s:Find.job') | return
  elseif  exists('*job_stop')  | call job_stop(s:Find.job)
  elseif  exists('*jobstop')   | call jobstop(s:Find.job)
  endif
  call s:FindSet(['', '--- Search Interrupted ---', ''], '+')
  if a:op
    call s:FindOpen()
    exe "normal! G"
  endif
  let s:Find.err += 1
  sleep 250m
endfunction

function s:FindSet(lines, op, ...)
  call setbufvar(s:FL.buf, '&ma', 1)
  let l:err = 0
  let l:n = len(a:lines)
  if a:op == '='
    silent let l:err += deletebufline(s:FL.buf, 1, '$')
    let g:HiFindLines = 0
    let s:FL.lines = 0
    let s:FL.select = 0
    let s:FL.edit = 0
    if !empty(a:lines)
      let l:err += setbufline(s:FL.buf, 1, a:lines)
      if a:0
        call setbufvar(s:FL.buf, 'Status', a:1)
      endif
    endif
  elseif l:n
    for l:line in a:lines
      call add(s:FL.log, ' '.l:line)
    endfor
    if !s:FL.lines
      let l:err += setbufline(s:FL.buf, 1, s:FL.log[-l:n:])
    else
      let l:err += appendbufline(s:FL.buf, '$', s:FL.log[-l:n:])
    endif
  endif
  if l:err
    echoe " Find : Listing Error "
    let s:Find.err += 1
  else
    let s:FL.lines += l:n
    let g:HiFindLines = s:FL.lines
  endif
  call setbufvar(s:FL.buf, '&ma', 0)
endfunction

function s:FindOut(ch, msg)
  call s:FindSet([a:msg], '+')
endfunction

function s:FindErr(ch, msg)
  call s:FindSet([a:msg], '+')
  let s:Find.err += 1
endfunction

function s:FindClose(ch)
  unlet s:Find.job
  let l:s = s:FL.lines == 1 ? '' :  's'
  let l:msg = ' '.s:FL.lines.' item'.l:s.' found '
  if !s:FL.lines
    let s:Find.hi = ''
  elseif s:Find.err || empty(s:FindSelect(1))
    let s:Find.hi = ''
    let l:msg = ''
    call remove(s:FL.log, 0, -1)
  endif
  if !empty(s:Find.hi_err)
    let l:msg .= ' * '.s:Find.hi_err
  endif
  echo l:msg
  let l:win = winnr()
  noa wincmd p
  call s:SetHiFindWin(s:Find.hi, s:FL.buf)
  noa exe l:win." wincmd w"
endfunction

function s:FindStdOut(job, data, event)
  if a:data == [''] | let s:Find.line = '' | return | endif
  let s:Find.line .= a:data[0]
  call s:FindSet([s:Find.line], '+')
  call s:FindSet(a:data[1:-2], '+')
  let s:Find.line = a:data[-1]
  let s:Find.err += (a:event == 'stderr')
endfunction

function s:FindExit(job, code, type)
  call s:FindClose(0)
endfunction

function s:FindSelect(line)
  let l:line = getbufline(s:FL.buf, a:line)[0]
  if len(l:line) < 2 | return | endif

  let l:pos = 1
  let l:file = matchstr(l:line, '\v[^:]*', l:pos)
  if filereadable(l:file)
    call setbufvar(s:FL.buf, '&ma', 1)
    let l:pos += len(l:file) + 1
    let l:row = matchstr(l:line, '\v\d*', l:pos)
    let l:pos += len(l:row) + 1
    let l:col = matchstr(l:line, '\v\d*', l:pos)
    if s:FL.select
      let l:select = getbufline(s:FL.buf, s:FL.select)[0]
      call setbufline(s:FL.buf, s:FL.select, ' '.l:select[1:])
    endif
    call setbufline(s:FL.buf, a:line, '|'.l:line[1:])
    call setbufvar(s:FL.buf, '&ma', 0)
  else
    return
  endif
  let s:FL.select = a:line
  return {'name':l:file, 'row':l:row, 'col':l:col}
endfunction

function s:FindRotate()
  if winnr('$') == 1 | return | endif
  close
  call s:FindOpen((s:FL.pos + 1) % 3)
endfunction

function s:FindEdit(op)
  let l:file = s:FindSelect(line('.'))
  if empty(l:file) | return | endif

  let l:edit = 0
  if a:op == '=' && winnr('$') > 1
    let l:find = winnr()
    noa wincmd p
    let wins = extend([winnr()], range(winnr('$'),1, -1))
    for w in wins
      noa exe w. " wincmd w"
      if empty(&buftype)
        let l:edit = w | break
      endif
    endfor
    noa exe l:find." wincmd w"
  endif

  if l:edit
    exe l:edit." wincmd w"
  else
    abo split
    wincmd p
    exe "resize ".min([s:FL.height, winheight(0)])
    wincmd p
  endif

  let l:name = bufname(l:file.name)
  if !empty(l:name) && l:name ==# bufname()
    exe "normal! ".l:file.row.'G'
  else
    exe "edit +".l:file.row.' '.l:file.name
  endif
  exe "normal! ".l:file.col.'|'
  let s:FL.edit = s:FL.select

  if exists('w:HiFind')
    call matchdelete(w:HiFind)
    unlet w:HiFind
  endif
  if !empty(s:Find.hi)
    let w:HiFind = matchadd('HiFind', s:Find.hi)
  endif
endfunction

function s:FindNextPrevious(op, num)
  if !s:FindOpen() | return | endif
  let l:offset = ((a:op == '+') ? 1 : -1) * (a:num ? a:num : (v:count ? v:count : 1))
  let l:line = (!s:FL.edit && l:offset) ? 1 : max([1, s:FL.select + l:offset])
  exe "normal! ".l:line.'G'
  call s:FindEdit('=')
endfunction

function s:FindOlderNewer(op, n)
  if exists('s:Find.job')
    echo ' searching in progress...' | return
  endif
  let l:logs = len(s:FL.logs.list) - empty(s:FL.log)
  if !l:logs | echo ' no list' | return | endif

  let l:offset = ((a:op == '+') ? 1 : -1) * (a:n ? a:n : (v:count ? v:count : 1))
  let l:index = min([max([0, s:FL.logs.index + l:offset]), l:logs-1])
  echo '  List  '.(l:index + 1).' / '.l:logs

  let l:win = winnr()
  call s:FindOpen()
  if s:FL.logs.index != l:index
    let s:FL.logs.index = l:index
    let [l:status, s:Find.hi] = s:FL.logs.tag[l:index]
    call s:FindSet(s:FL.logs.list[l:index], '=', l:status)
    call s:FindSelect(1)
    call s:SetHiFindWin(s:Find.hi, s:FL.buf)
  endif
  exe l:win." wincmd w"
endfunction

function s:FindCloseWin()
  if !s:FL.buf | return | endif
  let l:win = bufwinnr(s:FL.buf)
  if l:win != -1
    exe l:win." wincmd q"
  endif
endfunction

function s:FindClear()
  if !empty(s:Find.hi)
    call s:SetHiFindWin('', 0)
    let s:Find.hi = ''
  endif
endfunction

function s:BufEnter()
  if !exists("w:HiMode") || !w:HiMode['>'] | return | endif
  call s:GetKeywords()
  call s:LinkCursorEvent('')
endfunction

function s:BufLeave()
  if !exists("w:HiMode") | return | endif
  call s:EraseHiWord()
endfunction

function s:BufHidden()
  if expand('<afile>') ==# s:FL.name
    call s:SetHiFindWin('', 0)
  endif
endfunction

function s:WinEnter()
  if !exists("w:HiMode") | return | endif
  call s:LinkCursorEvent('')
endfunction

function s:WinLeave()
  if !exists("w:HiMode") | return | endif
  call s:UnlinkCursorEvent(0)
endfunction

function s:BufWinEnter()
  if bufname() ==# s:FL.name && !empty(s:Find.hi)
    call s:SetHiFindWin(s:Find.hi, s:FL.buf)
  endif
endfunction

function s:ColorSchemePre()
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

function s:ColorScheme()
  if !exists("s:Current")
    return
  endif
  for l:c in s:Current
    exe 'hi' l:c[0].' '.l:c[1]
  endfor
  unlet s:Current
endfunction

function highlighter#Status()
  return getbufvar(s:FL.buf, 'Status')
endfunction

function! highlighter#Airline(...)
  if winnr() == bufwinnr(s:FL.buf)
    let w:airline_section_a = ' Find '
    let w:airline_section_b = ''
    let w:airline_section_c = '%{highlighter#Status()}'
  endif
endfunction

function highlighter#Command(cmd, ...)
  if !exists("s:Colors")
    if !s:Load() | return | endif
  endif
  let l:arg = split(a:cmd)
  let l:cmd = get(l:arg, 0, '')
  let l:opt = get(l:arg, 1, '')
  let l:num = a:0 ? a:1 : 0
  let s:Search = 0

  if     l:cmd ==# ''         | echo ' Highlighter version '.s:Version
  elseif l:cmd ==# '+'        | call s:SetHighlight('+', 'n', l:num)
  elseif l:cmd ==# '-'        | call s:SetHighlight('-', 'n', l:num)
  elseif l:cmd ==# '+x'       | call s:SetHighlight('+', 'x', l:num)
  elseif l:cmd ==# '-x'       | call s:SetHighlight('-', 'x', l:num)
  elseif l:cmd ==# '>>'       | call s:SetMode('>', '')
  elseif l:cmd ==# 'default'  | call s:SetColors(1)
  elseif l:cmd ==# '/'        | call s:Find('n')
  elseif l:cmd ==# '/x'       | call s:Find('x')
  elseif l:cmd ==# '/next'    | call s:FindNextPrevious('+', l:num)
  elseif l:cmd ==# '/previous'| call s:FindNextPrevious('-', l:num)
  elseif l:cmd ==# '/older'   | call s:FindOlderNewer('-', l:num)
  elseif l:cmd ==# '/newer'   | call s:FindOlderNewer('+', l:num)
  elseif l:cmd ==# '/open'    | call s:FindOpen()
  elseif l:cmd ==# '/close'   | call s:FindCloseWin()
  elseif l:cmd ==# 'clear'    | call s:SetHighlight('--', 'n', 0) | call s:SetMode('-', '') | call s:FindClear()
  else
    echo ' Hi: no matching commands: '.l:cmd
  endif
  return s:Search
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
