" Vim Highlighter: Highlight words and expressions
" Author: Azabiong
" License: MIT
" Source: https://github.com/azabiong/vim-highlighter
" Version: 1.56.5

scriptencoding utf-8
if exists("s:Version")
  finish
endif
let s:cpo_save = &cpo
set cpo&vim

let g:HiKeywords = get(g:, 'HiKeywords', '')
let g:HiSyncMode = get(g:, 'HiSyncMode', 0)
let g:HiFindTool = get(g:, 'HiFindTool', '')
let g:HiFindHistory = get(g:, 'HiFindHistory', 5)
let g:HiCursorGuide = get(g:, 'HiCursorGuide', 1)
let g:HiOneTimeWait = get(g:, 'HiOneTimeWait', 260)
let g:HiFollowWait = get(g:, 'HiFollowWait', 320)
let g:HiBackup = get(g:, 'HiBackup', 1)
let g:HiFindLines = 0

let s:Version   = '1.56.5'
let s:Sync      = {'page':{'name':[]}, 'tag':0, 'add':[], 'del':[]}
let s:Keywords  = {'plug': expand('<sfile>:h').'/keywords', '.':[]}
let s:Guide     = {'tid':0, 'line':0, 'left':0, 'right':0, 'win':0, 'mid':0}
let s:Find      = {'tool':'_', 'opt':[], 'exp':'', 'file':[], 'line':'', 'err':0,
                  \'type':'', 'options':{}, 'hi_exp':[], 'hi':[], 'hi_err':'', 'hi_tag':0}
let s:FindList  = {'name':' Find *', 'buf':-1, 'pos':0, 'div':4, 'lines':0, 'edit':0,
                  \'logs':[{'list':[], 'status':'', 'select':0, 'hi':[], 'base':''}], 'index':0, 'log':''}
let s:FindOpts  = ['--literal', '_li', '--fixed-strings', '_li', '--smart-case', '_sc', '--ignore-case',  '_ic',
                  \'--word-regexp', '_wr', '--regexp', '_re']
let s:FindTools = ['rg -H --color=never --no-heading --column --smart-case',
                  \'ag --nocolor --noheading --column --nobreak',
                  \'ack -H --nocolor --noheading --column --smart-case',
                  \'sift --no-color --line-number --column --binary-skip --git --smart-case',
                  \'ggrep -H -EnrI --exclude-dir=.git',
                  \'grep -H -EnrI --exclude-dir=.git',
                  \'git grep -EnI --no-color --column']
const s:FL = s:FindList
const s:Group = 'HiColor'

function s:Load()
  if !exists("s:Check")
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
  let s:ColorsDark = [
    \ ['HiOneTime', 'ctermfg=233 ctermbg=152 cterm=none guifg=#001020 guibg=#a8d2d8 gui=none'],
    \ ['HiFollow',  'ctermfg=233 ctermbg=151 cterm=none guifg=#002f00 guibg=#a8d0b8 gui=none'],
    \ ['HiFind',    'ctermfg=223 ctermbg=95  cterm=none guifg=#ffe7d7 guibg=#8c675f gui=none'],
    \ ['HiGuide',   'ctermfg=188 ctermbg=62  cterm=none guifg=#d0d0d8 guibg=#4848d8 gui=none'],
    \ ['HiColor1',  'ctermfg=234 ctermbg=113 cterm=none guifg=#001737 guibg=#82c85a gui=none'],
    \ ['HiColor2',  'ctermfg=52  ctermbg=179 cterm=none guifg=#500000 guibg=#e6b058 gui=none'],
    \ ['HiColor3',  'ctermfg=225 ctermbg=90  cterm=none guifg=#f8dff6 guibg=#8f2f8f gui=none'],
    \ ['HiColor4',  'ctermfg=195 ctermbg=68  cterm=none guifg=#dffcfc guibg=#5783c7 gui=none'],
    \ ['HiColor5',  'ctermfg=18  ctermbg=152 cterm=bold guifg=#000098 guibg=#b8c8e8 gui=bold'],
    \ ['HiColor6',  'ctermfg=89  ctermbg=182 cterm=bold guifg=#780047 guibg=#e8b8e8 gui=bold'],
    \ ['HiColor7',  'ctermfg=52  ctermbg=180 cterm=bold guifg=#570000 guibg=#dfb787 gui=bold'],
    \ ['HiColor8',  'ctermfg=223 ctermbg=130 cterm=bold guifg=#f0d7a7 guibg=#af5f17 gui=bold'],
    \ ['HiColor9',  'ctermfg=253 ctermbg=59  cterm=bold guifg=#e8e8c8 guibg=#606060 gui=bold'],
    \ ['HiColor10', 'ctermfg=195 ctermbg=23  cterm=none guifg=#cfefef guibg=#206838 gui=none'],
    \ ['HiColor11', 'ctermfg=22  ctermbg=187 cterm=bold guifg=#004700 guibg=#c8d6b8 gui=bold'],
    \ ['HiColor12', 'ctermfg=232 ctermbg=186 cterm=none guifg=#200000 guibg=#d8d880 gui=none'],
    \ ['HiColor13', 'ctermfg=52  ctermbg=213 cterm=none guifg=#470023 guibg=#ec96ec gui=none'],
    \ ['HiColor14', 'ctermfg=17  ctermbg=153 cterm=none guifg=#000047 guibg=#a0d0ec gui=none'],
    \ ]
  let s:ColorsLight = [
    \ ['HiOneTime', 'ctermfg=234 ctermbg=152 cterm=none guifg=#001828 guibg=#afd9d9 gui=none'],
    \ ['HiFollow',  'ctermfg=234 ctermbg=151 cterm=none guifg=#002800 guibg=#b3dfb4 gui=none'],
    \ ['HiFind',    'ctermfg=52  ctermbg=187 cterm=none guifg=#481808 guibg=#e3d3b7 gui=none'],
    \ ['HiGuide',   'ctermfg=231 ctermbg=62  cterm=none guifg=#f8f8f8 guibg=#6868e8 gui=none'],
    \ ['HiColor1',  'ctermfg=17  ctermbg=113 cterm=none guifg=#001767 guibg=#8fd757 gui=none'],
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
  let s:Colors16 = [
    \ ['HiOneTime', 'ctermfg=darkBlue ctermbg=lightCyan' ],
    \ ['HiFollow',  'ctermfg=darkBlue ctermbg=lightGreen'],
    \ ['HiFind',    'ctermfg=yellow   ctermbg=darkGray'  ],
    \ ['HiGuide',   'ctermfg=white    ctermbg=darkBlue'  ],
    \ ['HiColor1',  'ctermfg=white    ctermbg=darkGreen' ],
    \ ['HiColor2',  'ctermfg=white    ctermbg=darkCyan'  ],
    \ ['HiColor3',  'ctermfg=white   ctermbg=darkMagenta'],
    \ ['HiColor4',  'ctermfg=white   ctermbg=darkYellow' ],
    \ ['HiColor5',  'ctermfg=black   ctermbg=lightYellow'],
    \ ]
  let s:Colors = (s:Check < 256) ? s:Colors16 : s:ColorsDark
  let s:Number = 0
  let s:Focus = deepcopy(s:Guide)
  let s:Wait = [g:HiOneTimeWait, g:HiFollowWait]
  let s:WaitRange = [[0, 320], [260, 520]]
  let s:Word = '<cword>'
  let s:Input = ''
  let s:Search = 0
  if empty(g:HiKeywords)
    let l:keywords = fnamemodify(s:Keywords.plug, ":h:h").'/keywords'
    let g:HiKeywords = isdirectory(l:keywords) ? l:keywords : ''
  endif
  call s:SetColors(0)

  aug Highlighter
    au!
    au BufEnter    * call <SID>BufEnter()
    au BufLeave    * call <SID>BufLeave()
    au WinEnter    * call <SID>WinEnter()
    au WinLeave    * call <SID>WinLeave()
    if exists("#WinClosed")
      au WinClosed * call <SID>WinClosed()
    else
      au BufHidden * call <SID>BufHidden()
    endif
    au TabClosed   * call <SID>TabClosed()
  aug END
  return 1
endfunction

function s:SetColors(default)
  if s:Colors != s:Colors16
    let s:Colors = (&background == 'dark') ? s:ColorsDark : s:ColorsLight
  endif
  for l:c in s:Colors
    if a:default || empty(s:GetColor(l:c[0]))
      exe 'hi' l:c[0] l:c[1]
    endif
  endfor
endfunction

function s:GetColor(color)
  return hlexists(a:color) ? matchstr(execute('hi '.a:color), '\(\<cterm\|\<gui\).*') : ''
endfunction

function s:SetHighlight(cmd, mode, num)
  if a:mode != '=' && s:CheckRepeat(60) | return | endif

  let l:match = getmatches()
  let l:line = '\%'.line('.').'l'
  if a:cmd == '--'
    for l:m in l:match
      if match(l:m.group, s:Group) == 0
        call matchdelete(l:m.id)
      endif
    endfor
    call s:UpdateJump('')
    call s:UpdateSync('del', '*', '')
    let s:Number = 0
    return
  elseif a:cmd == '+'
    let l:color = s:GetNextColor(a:num)
  else
    let l:color = 0
  endif

  if a:mode[0] == 'n'
    let l:word = escape(expand('<cword>'), '\')
    let l:pattern = '\V\<'.l:word.'\>'
  elseif a:mode[0] == 'x'
    let l:visual = trim(s:GetVisualLine())
    let l:word = escape(l:visual, '\')
    let l:pattern = '\V'.l:word
  elseif a:mode == '='
    let l:word = escape(s:Input, "'\"")
    let l:magic = &magic ? '\m' : '\M'
    let l:pattern = l:magic.l:word
  endif
  if empty(l:word)
    if !l:color | call s:SetFocusMode('-', '') | endif
    return
  endif

  let l:case = (&ic || stridx(@/, '\c') != -1) ? '\c' : ''
  if l:color
    call s:DeleteMatch(l:match, '==', l:pattern, l:line)
    if a:mode == 'n' && s:GetFocusMode(1, l:pattern)
      call s:SetFocusMode('>', '')
    else
      let l:group = s:Group.l:color
      if a:mode[1] == '%'
        let l:pattern = '\V\%'.line('.').'l'.l:pattern
      endif
      try
        call matchadd(l:group, l:pattern, 0)
      catch
        echohl ErrorMsg
        echo  ' * '.v:exception
        echohl None
        return
      endtry
      call s:UpdateJump(l:pattern)
      call s:UpdateSync('add', l:group, l:pattern)
      let s:Number = l:color
      let s:Search = match(@/, l:pattern.l:case) != -1
    endif
  else
    if s:GetFocusMode('>', '')
      let l:deleted = 0
      if a:mode == 'x'
        let s:HiMode['>'] = '<'
      endif
    else
      let l:deleted = s:DeleteMatch(l:match, '==', l:pattern, l:line)
      if !l:deleted
        if a:mode == 'n'
          let l:deleted = s:DeleteMatch(l:match, '≈n', s:GetStringPart(), l:line)
          if !l:deleted
            if get(g:, 'HiClearUsingOneTime', 0)
              return s:ClearHighlights()
            endif
            let l:deleted = s:DeleteMatch(l:match, '%l', '', l:line)
          endif
        elseif a:mode == 'x'
          let l:deleted = s:DeleteMatch(l:match, '≈x', l:visual, l:line)
        endif
      endif
    endif
    if !l:deleted && a:mode != '='
      let s:Search = (s:SetFocusMode('.', l:pattern) == '=') && match(@/, l:pattern.l:case) != -1
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
  let l:next = a:num ? a:num : (v:count ? v:count : s:Number+1)
  return hlexists(s:Group.l:next) ? l:next : 1
endfunction

function s:GetVisualLine()
  let [l:top, l:left] = getpos("'<")[1:2]
  let [l:bottom, l:right] = getpos("'>")[1:2]
  let l:line = getline(l:top)
  if l:top != l:bottom | let l:right = -1 | endif
  if l:right > 0
    if &selection == 'exclusive'
      if l:left == l:right | return '' | endif
    else
      let l:right = min([l:right, len(l:line)])
      let l:right += len(matchstr(l:line, '\%'.l:right.'c.'))
    endif
    let l:right -= 2
  endif
  return l:line[l:left-1 : l:right]
endfunction

function s:DeleteMatch(match, op, part, line)
  let l:i = len(a:match)
  while l:i > 0
    let l:i -= 1
    let l:m = a:match[l:i]
    if match(l:m.group, s:Group) == 0
      if stridx(l:m.pattern, '\%') == 2
        if stridx(l:m.pattern, a:line) != 2 | continue | endif
        let l:offset = len(matchstr(l:m.pattern, '\v^\\.\\\%\d+l'))
        let l:pattern = l:m.pattern[l:offset:]
      else
        let l:offset = 0
        let l:pattern = l:m.pattern
      endif
      let l:match = 0
      if a:op == '=='
        let l:match = (a:part ==# l:pattern)
      else
        if (a:op == '≈n')
          if l:pattern[:3] !=# '\V\<'
            let l:pattern = '\C'.l:pattern
            let l:match = (match(a:part.word, l:pattern) != -1) ||
                        \ (stridx(l:pattern, ' ') != -1 && match(a:part.line, l:pattern) != -1)
          endif
        elseif a:op == '≈x'
          let l:match = match(a:part, '\C'.l:pattern) != -1
        elseif a:op == '%l'
          let l:match = l:offset
        endif
      endif
      if l:match
        if l:m.pattern == get(w:, 'HiJump', '')
          call s:UpdateJump('')
        endif
        call matchdelete(l:m.id)
        call s:UpdateSync('del', l:m.group, l:m.pattern)
        return 1
      endif
    endif
  endwhile
endfunction

function s:GetStringPart()
  let l:line = getline('.')
  let l:col = col('.')
  let l:low = max([l:col-1024, 0])
  let l:left = strpart(l:line, l:low, l:col - l:low)
  let l:right = strpart(l:line, l:col, l:col + 1024)
  let l:word = matchstr(l:left, '\zs\S\+$')
  let l:word .= matchstr(l:right, '^\S\+')
  return {'word':l:word, 'line': l:left.l:right}
endfunction

function s:GetFocusMode(mode, word)
  if !exists("s:HiMode") | return | endif
  let l:match = empty(a:word) || s:HiMode['w'] ==# a:word
  if a:mode == 1
    return !v:count && s:HiMode['>'] == '1' && s:HiMode['p'] == getpos('.') && l:match
  else
    return s:HiMode['>'] == '>' && l:match
  endif
endfunction

" s:SetFocusMode(cmd) actions
" |   mode  |   !   |  '1,<'  |   '>'   |  ! off   1  one-time    <  one-time_in_follow
" |   word  |   *   | !=   == | !=   == |  * any   != not_match   == match
" |-----+---|-------|---------|---------|
" |     | . |   1   |  =   0  |  >   0  |  . check  1 one-time  = update   0 off
" | cmd | > |   >   |  >   >  |  >   >  |  > follow
" |     | - |   0   |  0   0  |  0   0  |  - off
function s:SetFocusMode(cmd, word)
  if a:cmd == '.'
    if !exists("s:HiMode")
      let l:word = a:word
      let l:op = '1'
    else
      let l:action = ['=0', '>0'][s:HiMode['>'] == '>']
      let l:word = empty(a:word) ? s:GetCurrentWord().word : a:word
      let l:op = l:action[l:word ==# s:HiMode['w']]
    endif
  elseif a:cmd == '>'
    let l:word = empty(a:word) ? s:GetCurrentWord().word : a:word
    let l:op = '>'
  else
    let l:op = '0'
  endif

  if stridx('1=>', l:op) != -1
    call s:LinkCursorEvent(l:word)
    let s:HiMode['p'] = getpos('.')
    if l:op == '>'
      call s:GetKeywords()
      let s:HiMode['>'] = '>'
      let s:HiMode['_'] = s:Wait[1]
      call s:UpdateHiWord(0)
    elseif l:op == '='
      call timer_stop(s:HiMode['t'])
      let s:HiMode['t'] = 0
      let s:HiMode['_'] = s:Wait[0]
    endif
  elseif l:op == '0'
    call s:UnlinkCursorEvent(1)
  endif
  return l:op
endfunction

function s:SetWordMode(op)
  if a:op == '<>'
    let s:Word = s:Word == '<cword>' ? '<cWORD>' : '<cword>'
  elseif index(['<cword>', '<cWORD>'], a:op) != -1
    let s:Word = a:op
  else
    return s:NoOption(a:op)
  endif
  echo ' Hi '.s:Word
  if exists("s:HiMode") && s:HiMode['>'] == '>'
    call s:SetFocusMode('>', '')
  endif
endfunction

function s:GetSyncMode()
  if !exists("t:HiSync")
    call s:SetSyncPage(g:HiSyncMode)
  endif
  return !empty(t:HiSync)
endfunction

function s:SetSyncMode(op, ...)
  let l:op = index(['=', '==', '=!'], a:op)
  if  l:op == -1 | return s:NoOption(a:op) | endif

  let l:sync = s:GetSyncMode()
  if l:op == 2
    let l:op = !l:sync
  endif
  if !a:0
    echo ' Hi '.['= 1', '== Sync'][l:op]
  endif
  if l:op == l:sync | return | endif

  if l:op
    call s:SetSyncPage(1)
    let s:Sync.page[t:HiSync] = map(filter(getmatches(), {i,v -> match(v.group, s:Group) == 0}),
                                                       \ {i,v -> [v.group, v.pattern]})
  else
    let s:Sync.page[t:HiSync] = []
    let t:HiSync = ''
  endif
  let w:HiSync = 1
  call s:SetHiSyncWin(l:op)
endfunction

function s:SetSyncPage(op)
  if a:op
    let s:Sync.tag += 1
    let l:name = 'HiSync'.s:Sync.tag
    let t:HiSync = l:name
    let s:Sync.page[l:name] = []
  else
    let t:HiSync = ''
  endif
endfunction

function s:UpdateSync(op, group, pattern)
  if !s:GetSyncMode() | return | endif
  let l:match = s:Sync.page[t:HiSync]
  let s:Sync[a:op] = [a:group, a:pattern]
  if a:op == 'add'
    call add(l:match, s:Sync[a:op])
  elseif a:op == 'del'
    if a:group == '*'
      call remove(l:match, 0, -1)
    else
      for i in range(len(l:match))
        if l:match[i][1] ==# a:pattern
          call remove(l:match, i) | break
        endif
      endfor
    endif
  endif
  let w:HiSync = 1
  call s:SetHiSyncWin(1)
endfunction

function s:ClearHighlights()
  call s:SetHighlight('--', '=', 0)
  call s:SetFocusMode('-', '')
  call s:FindClear()
endfunction

function s:NoOption(op)
  echo ' Hi: no matching option: '.a:op
endfunction

" symbols: follow('>'), wait('_'), pos, timer, reltime, word
function s:LinkCursorEvent(word)
  let l:event = exists("#HiEventCursor")
  if !exists("s:HiMode")
    call s:UpdateWait()
    let s:HiMode = {'>':'1', '_':s:Wait[0], 'p':[], 't':0, 'r':[], 'w':a:word}
  else
    let s:HiMode['w'] = a:word
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
    if exists("s:HiMode")
      call s:EraseHiWord()
      if a:force || s:HiMode['>'] == '1'
        unlet s:HiMode
      endif
    endif
    if !exists("s:HiMode")
      au!  HiEventCursor
      aug! HiEventCursor
    endif
  endif
endfunction

function s:UpdateWait()
  let l:wait = [g:HiOneTimeWait, g:HiFollowWait]
  if l:wait != s:Wait
    let s:Wait[0] = min([max([l:wait[0], s:WaitRange[0][0]]), s:WaitRange[0][1]])
    let s:Wait[1] = min([max([l:wait[1], s:WaitRange[1][0]]), s:WaitRange[1][1]])
    let [g:HiOneTimeWait, g:HiFollowWait] = s:Wait
  endif
endfunction

function s:EraseHiWord()
  if !empty(s:HiMode['w'])
    let s:HiMode['w'] = ''
    call s:SetHiFocusWin('')
  endif
endfunction

function s:SetHiWord(word)
  if empty(a:word) | return | endif
  if s:HiMode['>'] == '1'
    call s:SetHiFocusWin(['HiOneTime', a:word, 10])
  else
    call s:SetHiFocusWin(['HiFollow', a:word, 0])
  endif
  let s:HiMode['w'] = a:word
endfunction

function s:GetKeywords()
  let l:ft = !empty(&filetype) ? split(&filetype, '\.')[0] : ''
  if !exists("s:Keywords['".l:ft."']")
    let s:Keywords[l:ft] = []
    let l:list = s:Keywords[l:ft]
    let l:file = expand(g:HiKeywords).'/'.l:ft
    if filereadable(l:file)
      for l:line in readfile(l:file)
        if l:line[0] == '#' | continue | endif
        let l:list += split(l:line)
      endfor
    endif
  endif
  let s:Keywords['.'] = s:Keywords[l:ft]
endfunction

function s:GetCurrentWord()
  let l:cw = {'word':'', 'key':0}
  let l:word = expand(s:Word)
  if  l:word =~ '\w'
    let l:keyword = index(s:Keywords['.'], l:word) != -1
    if s:Word ==# '<cword>'
      let l:cw.word = '\V\<'.l:word.'\>'
    else
      let l:word = substitute(l:word, '\v[,.;]$', '', '')
      let l:p = l:word =~ '^\w' ? '\<' : ''
      let l:q = l:word =~ '\w$' ? '\>' : ''
      let l:cw.word = '\V'.l:p.escape(l:word, '\').l:q
    endif
    let l:cw.key  = l:keyword
  endif
  return l:cw
endfunction

function s:FollowCursor(...)
  if !exists("s:HiMode") | return | endif
  if s:HiMode['t']
    let s:HiMode['r'] = reltime()
  else
    let l:wait = a:0 ? a:1 : s:HiMode['_']
    let s:HiMode['t'] = timer_start(l:wait, function('s:UpdateHiWord'))
    let s:HiMode['r'] = []
  endif
endfunction

function s:UpdateHiWord(tid)
  if !exists("s:HiMode") | return | endif
  if !a:tid
    let l:word = s:HiMode['w']
    if empty(l:word)
      let l:word = s:GetCurrentWord()
      let l:word = l:word.key ? '' : l:word.word
    endif
    let s:HiMode['t'] = 0
  else
    let s:HiMode['t'] = 0
    if !empty(s:HiMode['r'])
      let l:wait = float2nr(reltimefloat(reltime(s:HiMode['r'])) * 1000)
      let l:wait = max([0, s:HiMode['_'] - l:wait])
      call s:FollowCursor(l:wait)
      return
    elseif s:HiMode['>'] == '>'
      if mode() != 'n' | return | endif
      let l:word = s:GetCurrentWord()
      if  l:word.word ==# s:HiMode['w'] | return | endif
      let l:word = l:word.key ? '' : l:word.word
    else
      if s:HiMode['p'] == getpos('.') && mode() =='n' " after visual selection
      elseif s:HiMode['>'] == '<'  " back to following mode
        let s:HiMode['>'] = '>'
        let s:HiMode['w'] = ''
        call s:UpdateHiWord(0)
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
  if !exists("s:HiMode") | return | endif
  if s:HiMode['>'] == '1'
    call s:FollowCursor()
  else
    call s:EraseHiWord()
  endif
endfunction

function s:InsertLeave()
  if !exists("s:HiMode") || s:HiMode['>'] == '1' | return | endif
  call s:LinkCursorEvent('')
endfunction

function s:SetHiSyncWin(op)
  let l:win = winnr()
  if a:op
    noa windo call s:SetHiSync(l:win)
  else
    noa windo unlet w:HiSync
  endif
  noa exe l:win "wincmd w"
  let s:Sync.add = ''
  let s:Sync.del = ''
endfunction

function s:SetHiSync(win)
  if winnr() == a:win | return | endif
  let l:jump = ''
  if !exists("w:HiSync") || s:Sync.del[0] == '*'
    for l:m in getmatches()
      if match(l:m.group, s:Group) == 0
        call matchdelete(l:m.id)
      endif
    endfor
    for l:m in s:Sync.page[t:HiSync]
      call matchadd(l:m[0], l:m[1], 0)
      let l:jump = l:m[1]
    endfor
  else
    if !empty(s:Sync.del)
      for l:m in getmatches()
        if (match(l:m.group, s:Group) == 0) && (l:m.pattern ==# s:Sync.del[1])
          call matchdelete(l:m.id) | break
        endif
      endfor
    endif
    let l:m = s:Sync.add
    if !empty(l:m)
      call matchadd(l:m[0], l:m[1], 0)
      let l:jump = l:m[1]
    endif
  endif
  let w:HiSync = 1
  call s:UpdateJump(l:jump)
endfunction

function s:SetHiFocusWin(hi)
  for w in range(1, winnr('$'))
    let l:focus = getwinvar(w, 'HiFocus')
    if l:focus
      call matchdelete(l:focus, w)
      call setwinvar(w, 'HiFocus', '')
    endif
    if !empty(a:hi)
      let l:focus = matchadd(a:hi[0], a:hi[1], a:hi[2], -1, {'window': w})
      call setwinvar(w, 'HiFocus', l:focus)
    endif
  endfor
endfunction

function s:SetHiFindWin(on)
  for w in range(1, winnr('$'))
    let l:find = getwinvar(w, 'HiFind', '')
    if !empty(l:find)
      if !a:on || l:find.tag != s:Find.hi_tag
        for m in l:find.id
          call matchdelete(m, w)
        endfor
        call setwinvar(w, 'HiFind', '')
      endif
    endif
  endfor
  if !a:on | return | endif

  for w in range(1, winnr('$'))
    let l:buf = winbufnr(w)
    if empty(getbufvar(l:buf, '&buftype')) || l:buf == s:FL.buf
      if empty(getwinvar(w, 'HiFind', ''))
        let l:find = {'tag':s:Find.hi_tag, 'id':[]}
        for h in s:Find.hi
          call add(l:find.id, matchadd('HiFind', h, 0, -1, {'window': w}))
        endfor
        call setwinvar(w, 'HiFind', l:find)
      endif
    endif
  endfor
endfunction

function s:SetFindGuide(tid)
  if !g:HiCursorGuide | return | endif
  if s:Guide.mid && win_id2tabwin(s:Guide.win)[0]
    call matchdelete(s:Guide.mid, s:Guide.win)
  endif
  if !win_id2win(s:Guide.win)
    let s:Guide.win = 0
  endif
  let s:Guide.mid = 0
  if a:tid == 0
    if s:Guide.tid
      call timer_stop(s:Guide.tid)
      let s:Guide.tid = 0
    endif
    let s:Guide.line = line('.')
    let s:Guide.right = col('.')
    let s:Guide.left = max([s:Guide.right-6, 1])
    let s:Guide.win = win_getid()
  endif
  if !s:Guide.win || s:Guide.left >= s:Guide.right
    return
  endif
  let s:Guide.mid = matchaddpos('HiGuide', [[s:Guide.line, s:Guide.left, 2]], 1, -1, {'window': s:Guide.win})
  let s:Guide.tid = timer_start(40, function('s:SetFindGuide'))
  let s:Guide.left += 1
endfunction

function s:SetJumpGuide(tid, length=0)
  if !g:HiCursorGuide | return | endif
  if s:Focus.tid
    call timer_stop(s:Focus.tid)
  endif
  if s:Focus.mid && win_id2tabwin(s:Focus.win)[0]
    call matchdelete(s:Focus.mid, s:Focus.win)
  endif
  let s:Focus = {'tid':0, 'win':0, 'mid':0}
  if a:length
    let s:Focus.win = win_getid()
    let s:Focus.mid = matchaddpos('HiGuide', [[line('.'), col('.'), a:length]], 10, -1, {'window': s:Focus.win})
    let s:Focus.tid = timer_start(220, function('s:SetJumpGuide'))
  endif
endfunction

function s:GetKeywordsPath(op)
  if empty(g:HiKeywords)
    let l:vim = (stridx(s:Keywords.plug, 'vimfiles') != -1) ? 'vimfiles' : '.vim'
    let g:HiKeywords = expand('$HOME').'/'.l:vim.'/after/vim-highlighter'
  else
    let g:HiKeywords = expand(g:HiKeywords)
  endif
  if !isdirectory(g:HiKeywords)
    if a:op == 'load'
      return
    elseif !mkdir(g:HiKeywords, 'p')
      echo " * mkdir() failed, HiKeywords = '".g:HiKeywords."'"
      return
    endif
  endif
  return g:HiKeywords
endfunction

function s:SaveHighlight(file)
  let [l:path, l:file] = s:GetHiPathFile('save', a:file)
  if empty(l:path) | return | endif

  let l:dir = fnamemodify(l:path, ':h')
  if empty(glob(l:dir, 0, 1))
    echo " * path not found: ".l:dir | return
  endif
  if g:HiBackup && !empty(glob(l:path, 0, 1)) && len(readfile(l:path, '', 3)) == 3
    let l:backup = l:path.'.o'
    call rename(l:path, l:backup)
  endif
  let l:list = ['# Highlighter Ver '.s:Version, '']
  let l:list += map(filter(getmatches(), {i,v -> match(v.group, s:Group) == 0}),
                                        \{i,v -> matchstr(v.group, '\d\+').':'.v.pattern})
  if writefile(l:list, l:path) == 0
    echo  " Hi:save ".l:file
  else
    echo " * write error: ".l:file.' ('.fnamemodify(l:path, ':~').')'
  endif
endfunction

function s:LoadHighlight(file)
  let [l:path, l:file] = s:GetHiPathFile('load', a:file)
  if empty(l:path) | return | endif

  let l:info = l:file.' ('.fnamemodify(l:path, ':~').')'
  if empty(glob(l:path, 0, 1))
    echo ' * Not found: '.l:info | return
  elseif !filereadable(l:path)
    echo ' * read error: '.l:info | return
  endif

  echo  " Hi:load ".l:file
  for l:m in getmatches()
    if match(l:m.group, s:Group) == 0
      call matchdelete(l:m.id)
    endif
  endfor
  let l:pattern = ''
  for l:line in readfile(l:path)
    if l:line[0] == '#' | continue | endif
    let l:exp = match(l:line, ':')
    if l:exp > 0
      let l:num = l:line[:l:exp-1]
      let l:pattern = l:line[l:exp+1:]
      call matchadd(s:Group.l:num, l:pattern, 0)
    endif
  endfor
  call s:UpdateJump(l:pattern)
  if s:GetSyncMode()
    call s:SetSyncMode('=', '*') | call s:SetSyncMode('==', '*')
  endif
endfunction

function s:GetHiPathFile(op, file)
  if a:file =~ '\v^\.\.?\/' || a:file =~ '^\/'
    if isdirectory(a:file)
      call feedkeys(":Hi:".a:op." ".a:file, 'n')
    else
        let l:file = (a:file =~ '\.hl$' ? a:file : a:file.'.hl')
        return [l:file, l:file]
    endif
  else
    let l:path = s:GetKeywordsPath(a:op)
    if empty(l:path)
      if a:op == 'load' | echo ' no list' | endif
    elseif !empty(a:file) && isdirectory(l:path.'/'.a:file)
      call feedkeys(":Hi:".a:op." ".a:file, 'n')
    else
      if empty(a:file)
        let l:file = '_.hl'
      else
        let l:file = (a:file =~ '\.hl$') ? a:file : a:file.'.hl'
      endif
      return [l:path.'/'.l:file, l:file]
    endif
  endif
  return ['', '']
endfunction

function s:FilterHiFiles(path)
  return filter(getcompletion(a:path, 'file'), {i,v -> isdirectory(v) || v =~ '\.hl$'})
endfunction

function s:ListFiles()
  let l:path = s:GetKeywordsPath('load')
  if empty(l:path)
    echo ' no list' | return
  endif
  bel new
  exe 'Explore' l:path
endfunction

function s:MatchPattern(line, pos, pattern)
  if search('\C'.a:pattern, 'bc', a:pos[1])
    let l:col = col('.')
    let l:len = len(matchstr(a:line, a:pattern, l:col-1))
    call setpos('.', a:pos)
    return a:pos[2] < l:col + l:len
  endif
endfunction

function s:UpdateJump(pattern)
  if empty(a:pattern)
    if exists("w:HiJump")
      unlet w:HiJump
    endif
  else
    let w:HiJump = a:pattern
  endif
endfunction

function s:JumpTo(pattern, op, count, update)
  let l:from = getpos('.')
  let l:jump = 0
  let l:flag = a:op[0]
  let l:pattern = '\C'.a:pattern
  for i in range(a:count)
    if !search(l:pattern, l:flag) | break | endif
    let l:jump += 1
  endfor
  if l:jump
    let l:to = getpos('.')
    if stridx(a:pattern, '\%') == 2
      let l:offset = len(matchstr(a:pattern, '\v^\\.\\\%\d+l'))
      let l:word = '\C'.a:pattern[l:offset:]
    else
      let l:word = l:pattern
    endif
    let l:length = len(matchstr(getline('.'), l:word, l:to[2]-1))
    if a:op == 'b' && l:from[1] == l:to[1] && l:from[2] - l:to[2] < l:length
      let l:jump = search(l:pattern, l:flag)
    endif
    if l:jump
      call s:SetJumpGuide(0, l:length)
      call feedkeys('zv', 'n')
    endif
  endif
  if a:update
    call s:UpdateJump(a:pattern)
  endif
endfunction

function s:JumpLong(op, count)
  let l:op = (a:op == '<') ? 'b' : ''
  let l:count = a:count ? a:count : (v:count ? v:count : 1)
  if exists("s:HiMode")
    let l:jump = s:HiMode['w']
    if !empty(l:jump)
      call s:JumpTo(l:jump, l:op, l:count, 0)
      let s:HiMode['p'] = getpos('.')
      return
    endif
  endif

  let l:line = getline('.')
  let l:pos = getpos('.')
  let l:jump = get(w:, 'HiJump', '')
  if !empty(l:jump) && s:MatchPattern(l:line, l:pos, l:jump)
    return s:JumpTo(l:jump, l:op, l:count, 0)
  endif

  let l:matches = getmatches()
  let l:size = len(l:matches)
  if !empty(l:jump)
    let i = l:size
    while i > 0
      let i -= 1
      let l:m = l:matches[i]
      if match(l:m.group, s:Group) == 0 && s:MatchPattern(l:line, l:pos, l:m.pattern)
        return s:JumpTo(l:m.pattern, l:op, l:count, 1)
      endif
    endwhile
    if search('\C'.l:jump, 'nw')
      return s:JumpTo(l:jump, l:op, l:count, 0)
    endif
  endif

  let i = l:size
  while i > 0
    let i -= 1
    let l:m = l:matches[i]
    if match(l:m.group, s:Group) == 0 && search('\C'.l:m.pattern, 'nw')
      return s:JumpTo(l:m.pattern, l:op, l:count, 1)
    endif
  endwhile
endfunction

function s:JumpNear(op)
  let l:op = (a:op == '{') ? 'nWb' : 'nW'
  let l:matches = getmatches()
  let l:match = []
  let l:base = line('.')
  let l:range = line('$')
  let l:stop = (a:op == '{') ? 1 : line('$')
  let i = len(l:matches)
  while i > 0
    let i -= 1
    let l:m = l:matches[i]
    if match(l:m.group, s:Group) == 0
      let l:line = search('\C'.l:m.pattern, l:op, l:stop)
      if l:line
        let l:dist = abs(l:line - l:base)
        if l:dist < l:range
          let l:match = [l:m]
          let l:range = l:dist
          let l:stop = l:line
        elseif l:dist == l:range
          let l:match += [l:m]
        endif
      endif
    endif
  endwhile
  if !empty(l:match)
    let l:flag = l:op[2]
    if len(l:match) > 1
      let l:pos = getpos('.')
      let l:sign = (l:flag == 'b') ? -1 : 1
      let l:next = {}
      for l:m in l:match
        call search('\C'.l:m.pattern, l:flag, l:stop)
        let l:col = l:sign * col('.')
        if empty(l:next) || l:col < l:next.col
          let l:next = {'col': l:col, 'pattern': l:m.pattern}
        endif
        call setpos('.', l:pos)
      endfor
      let l:flag = (l:flag == 'b') ? 'b0' : ''
      call s:JumpTo(l:next.pattern, l:flag, 1, 1)
    else
      call s:JumpTo(l:match[0].pattern, l:flag, 1, 1)
    endif
  endif
endfunction

function s:Find(input)
  if !s:FindTool() || !s:FindArgs(a:input)
    return
  endif
  let l:cmd = [s:Find.tool] + s:Find.opt
  if !empty(s:Find.exp)
    let l:cmd += [s:Find.exp]
  endif
  let l:cmd += s:Find.file
  call s:FindStop(0)
  call s:FindStart(a:input)
  if exists("*job_start")
    let s:Find.job = job_start(l:cmd, {
        \ 'in_io': 'null',
        \ 'out_cb':  function('s:FindOut'),
        \ 'err_cb':  function('s:FindErr'),
        \ 'close_cb':function('s:FindClose'),
        \ })
  elseif exists("*jobstart")
    let s:Find.job = jobstart(l:cmd, {
        \ 'on_stdout': function('s:FindStdOut'),
        \ 'on_stderr': function('s:FindStdOut'),
        \ 'on_exit':   function('s:FindExit'),
        \ })
  endif
endfunction

function s:FindTool()
  let l:list = !empty(g:HiFindTool) ? [g:HiFindTool] : s:FindTools
  let l:tool = ''
  for l:line in l:list
    let l:cmd = matchstr(l:line, '\v\S+')
    if !empty(l:cmd) && executable(l:cmd)
      let l:tool = l:cmd
      if empty(g:HiFindTool) | let g:HiFindTool = l:line | endif
      break
    endif
  endfor
  if empty(l:tool)
    echo " No executable search tool, HiFindTool = '".g:HiFindTool."'"
    return
  elseif !exists("*job_start") && !exists("*jobstart")
    echo " * channel - feature not found "
    return
  endif

  if s:Find.tool !=# l:tool
    let s:Find.tool = l:tool
    let s:Find.options = {'single':[], 'single!':[], 'with_value':[], 'with_value!':[], '_':[]}
    let s:Find.type = (l:tool =~ 'grep$') ? 'grep' : l:tool
    for l:file in [s:Keywords.plug.'/_'.s:Find.type, expand(g:HiKeywords).'/_'.s:Find.type]
      let l:key = '_'
      if filereadable(l:file)
        for l:line in readfile(l:file)
          if l:line[0] == '#'
            continue
          elseif index(keys(s:Find.options), l:line[:-2]) != -1
            let l:key = l:line[:-2] | continue
          else
            let s:Find.options[l:key] += split(l:line)
          endif
        endfor
      endif
    endfor
    for l:key in keys(s:Find.options)
      call uniq(sort(s:Find.options[l:key]))
    endfor
    let l:case = ['', 'ag', '-s', 'rg', '-s', 'ack', '-I', 'sift', '-I']
    let s:Find.options.case = l:case[index(l:case, s:Find.type) + 1]
  endif
  return 1
endfunction

function s:FindArgs(arg)
  if match(a:arg, '\S') == -1
    call s:FindStatus('') | return
  endif
  let s:Find.opt = []
  let s:Find.exp = ''
  let s:Find.file = []
  let s:Find.hi_exp = []
  let s:Find.hi_err = ''
  let l:opt = s:FindOptions(a:arg)
  let l:exp = s:FindUnescape(l:opt.exp)
  let l:file = []
  if empty(l:opt._re)
    let s:Find.exp = l:exp.str
  elseif !empty(l:exp.str)
    call add(l:file, l:exp.str)
  endif
  while !empty(l:exp.next)
    let l:exp = s:FindUnescape(l:exp.next)
    call add(l:file, l:exp.str)
  endwhile
  if empty(l:file)
    let s:Find.file = ['.']
  else
    call map(l:file, {i,v -> expand(v,0,1)})
    for i in l:file
      call extend(s:Find.file, i)
    endfor
  endif
  call s:FindMatch(l:opt)
  return 1
endfunction

function s:FindOptions(arg)
  let l:opt = {'case':{'i':0, 'I':0, '_ic':0, 's':0, 'S':0, '_sc':0}, 'pos':32, 'nohi':0, 'exp':'',
              \'F':0, 'Q':0, '_li':0, 'w':0, '_wr':0, '_re':[]}
  let l:args = len(s:Find.tool)
  let l:args = g:HiFindTool[l:args+1:].' '.a:arg.' '
  let l:next = 0 | let l:key = ''
  let l:len = len(l:args)
  let i = 0
  if l:args =~ '^grep'
    call add(s:Find.opt, 'grep') | let i = 5
  endif
  while i < l:len
    let l:c = l:args[i]
    if empty(l:key)
      if     l:c == ' '
      elseif l:c == '-'
        if l:args[i:i+2] == '-- '
          call add(s:Find.opt, '--') | let i += 3 | break
        endif
        let l:key = l:c
      else
        if !l:next | break | endif
        if l:c == '='
          let l:c = l:args[i+1]
          let i += 1
        endif
        let l:quote = 0
        if stridx("\"'", l:c) != -1
          let l:pair = stridx(l:args, l:c, i+1)
          let l:value = l:args[i+1:l:pair-1]
          let l:quote = 2
        else
          let l:value = matchstr(l:args, '\v\S+', i)
        endif
        if !empty(l:value)
          call add(s:Find.opt, l:value)
          let i += len(l:value) + l:quote
          if l:next == 2
            call add(l:opt._re, l:value)
          endif
        endif
        let l:next = 0 | let l:key = ''
      endif
    elseif stridx("=\ \"'", l:c) != -1
      call add(s:Find.opt, l:key)
      let l:next = s:FindFlag(l:opt, l:key)
      let l:key = ''
      continue
    else
      let l:key .= l:c
    endif
    let i += 1
  endwhile
  let l:opt.exp = l:args[i:-2]

  " --literal --fixed-strings
  let l:type = s:Find.type
  let l:opt._li += (l:opt.F && index(['ag','rg','grep', 'git'], l:type) != -1)
                \+ (l:opt.Q && index(['ack','sift'], l:type) != -1)
  if (s:Find.type == 'grep') && l:opt._li
    call s:FindAdjust('-E', '--extended-regexp')
  endif
  " --smart-case --ignore-case
  let l:case = l:opt.case
  let l:case._ic = max([l:case._ic, l:case.i])
  if  l:type == 'ag'
    let l:case._sc += 1
  endif
  if index(['ag', 'rg', 'ack'], l:type) != -1
    let l:case._sc = max([l:case._sc, l:case.S])
  elseif l:type == 'sift'
    let l:case._sc = max([l:case._sc, l:case.s])
  endif
  let l:o = max(l:case)
  if l:o
    if l:o == l:case._sc
      if l:type == 'sift' && len(l:opt._re) > 1
        call s:FindAdjust('-s', '--smart-case')
      endif
      let l:case._ic = 0
    else
      let l:case._ic = (l:o == l:case._ic)
      let l:case._sc = 0
    endif
  endif
  " --word-regexp
  let l:opt._wr = max([l:opt._wr, l:opt.w])
  return l:opt
endfunction

" returns 'next' value -- 0:none, 1:with_value, 2:with_regexp
function s:FindFlag(opts, op)
  let l:options = ['single', 'single!', 'with_value', 'with_value!']
  let l:f = (a:op[1] == '-') ? a:op : a:op[:1]
  let l:known = 0
  let l:len = len(a:op)
  let l:inc = len(l:f) - 1
  let i = 1
  while i < l:len
    for l:opts in l:options
      if index(s:Find.options[l:opts], l:f) == -1 | continue | endif
      let a:opts.pos += 32 | let l:known = 1

      if l:inc > 1  " long options
        let l:o = index(s:FindOpts, l:f)
        if  l:o != -1
          let l:o = s:FindOpts[l:o+1]
          if l:o == '_re'
            return 2
          elseif index(['_ic', '_sc'], l:o)
            let a:opts.case[l:o] = a:opts.pos
          else
            let a:opts[l:o] = a:opts.pos
          endif
        endif
      else
        let l:f = l:f[1]
        if l:f ==# 'e'
          let l:p = i + l:inc
          if l:p == l:len | return 2 | endif
          call add(a:opts._re, a:op[l:p:])
          return
        elseif stridx("iIsS", l:f) != -1
          let a:opts.case[l:f] = a:opts.pos
        elseif stridx("FQw", l:f) != -1
          let a:opts[l:f] = a:opts.pos
        endif
      endif

      let a:opts.nohi += l:opts[-1:] == '!'
      if l:opts[0] == 'w'
        return i + l:inc == l:len
      endif
    endfor
    let a:opts.nohi += !l:known
    let l:known = 0
    let i += l:inc
    let l:f = '-'.a:op[i]
  endwhile
endfunction

function s:FindAdjust(short, long)
    let l:o = s:Find.opt
    for i in range(len(l:o))
      if (l:o[i] =~# '\v^-\w') && (stridx(l:o[i], a:short[1]) != -1)
        let l:o[i] = substitute(l:o[i], a:short[1], '', '')
        if  l:o[i] == '-' | call remove(l:o, i) | endif
        return
      elseif l:o[i] ==# a:long
        call remove(l:o, i)
        return
      endif
    endfor
endfunction

function s:FindUnescape(arg)
  let l:arg = trim(a:arg)
  let l:exp = {'str':'', 'next':''}
  let l:q = l:arg[0]
  if l:q == "'"
    let l:q = stridx(l:arg, l:q, 1)
    if  l:q == -1
      let l:q = stridx(l:arg, ' ', 1)
    endif
    if l:q == -1
      return {'str':l:arg[1:-1], 'next':''}
    else
      return {'str':l:arg[1:l:q-1], 'next':l:arg[l:q+1:]}
    endif
  endif

  let l:len = len(l:arg)
  if  l:q != '"' | let l:q = '' | endif
  let i = len(l:q)
  while i < l:len
    let c = l:arg[i]
    if     c == '"'  | let i += 1    | break
    elseif c == ' '  | if empty(l:q) | break | endif
    elseif c == '\'
      let l:next = l:arg[i+1]
      if stridx(' "', l:next) != -1
        let c = l:next
      else
        let c .= l:next
      endif
      let i += 1
    endif
    let l:exp.str .= c
    let i += 1
  endwhile
  let l:exp.next = l:arg[i:]
  return l:exp
endfunction

function s:FindMatch(opt)
  if a:opt.nohi | return | endif
  if !empty(s:Find.exp)
    call add(a:opt._re, s:Find.exp)
  endif
  if a:opt.case._sc
    let l:upper = a:opt._li ? '\v\u' : '\v^\u|[^\\]\u'
    let a:opt.case._ic = match(s:Find.exp, l:upper) == -1
  endif
  let [l:bl, l:br] = a:opt._li ? ['\<', '\>'] : ['<', '>']
  for l:exp in a:opt._re
    let [l:p, l:q] = ['', '']
    let l:exp = escape(l:exp, (a:opt._li ? '\' : '~@%&=<>'."'"))
    if a:opt._wr
      let [l:p, l:q] = [l:bl, l:br]
    else
      if l:exp[:1]  == '\b' | let l:exp = l:bl.l:exp[2:]  | endif
      if l:exp[-2:] == '\b' | let l:exp = l:exp[:-3].l:br | endif
    endif
    if a:opt.case._ic | let l:p .= '\c' | endif
    let l:exp = (a:opt._li ? '\V' : '\v').l:p.l:exp.l:q
    call add(s:Find.hi_exp, l:exp)
  endfor
endfunction

function s:FindStatus(msg)
  call timer_start(0, {-> execute("echo '".a:msg."'", '')})
endfunction

function s:FindStart(arg)
  if s:FL.buf == -1
    let s:FL.buf = bufadd(s:FL.name)
    let s:FL.lines = 0
    let g:HiFindLines = 0
    call bufload(s:FL.buf)
    call s:FindOpen()
    setl buftype=nofile bh=hide ft=find noma noswapfile nofen fdc=0
    let b:Status = ''

    nn <silent><buffer><C-C>         :call <SID>FindStop(1)<CR>
    nn <silent><buffer><nowait>r     :call <SID>FindRotate()<CR>
    nn <silent><buffer><nowait>s     :call <SID>FindEdit('split')<CR>
    nn <silent><buffer><nowait>i     :call <SID>FindEdit('view')<CR>
    nn <silent><buffer><CR>          :call <SID>FindEdit('=')<CR>
    nn <silent><buffer><2-LeftMouse> :call <SID>FindEdit('=')<CR>

    " airline
    if exists("*airline#add_statusline_func")
      let l:find = win_getid()
      call airline#add_statusline_func('highlighter#Airline')
      call airline#add_inactive_statusline_func('highlighter#Airline')
      wincmd p | call win_gotoid(l:find)
    endif
  endif

  let s:FL.log = s:FL.logs[-1]
  if !empty(s:FL.log.list)
    call add(s:FL.logs, {'list':[], 'status':'', 'select':0, 'hi':[], 'base':''})
  endif
  let l:logs = len(s:FL.logs)
  let g:HiFindHistory = min([max([2, g:HiFindHistory]), 10])
  while l:logs > g:HiFindHistory
    call remove(s:FL.logs, 0)
    let l:logs -= 1
  endwhile
  let l:index = l:logs - 1
  let l:status = s:Find.tool.' '.join(s:Find.opt).'  '.s:Find.exp.'  '.join(s:Find.file)
  let s:FL.index = l:index
  let s:FL.log = s:FL.logs[l:index]
  let s:FL.log.status = l:status
  let s:FL.log.select = 0
  let s:FL.log.hi = []
  let s:FL.log.base = getcwd()
  let s:Find.hi = []
  let s:Find.hi_tag += 1
  let s:Find.line = ''
  let s:Find.err = 0

  call s:FindSet([], '=')
  call s:FindOpen()
  call s:SetHiFindWin(0)
  let w:HiFind = {'tag':s:Find.hi_tag, 'id':[]}
  let b:Status = l:status

  try
    for l:exp in s:Find.hi_exp
      let l:id = matchadd('HiFind', l:exp, 0)
      call add(w:HiFind.id, l:id)
      call add(s:Find.hi, l:exp)
      call add(s:FL.log.hi, l:exp)
    endfor
  catch
    let s:Find.hi_err = v:exception
  endtry
  call s:FindStatus(" searching...")
endfunction

function s:FindOpen(...)
  if s:FL.buf == -1 | echo ' no list' | return | endif
  let l:win = bufwinnr(s:FL.buf)
  if l:win == -1
    if a:0
      let l:pos = a:1
      let l:div = a:2
    else
      let l:pos = 0
      let l:div = 4
      if !empty(&buftype)
        for i in range(winnr('$'), 1, -1)
          if empty(winbufnr(i)->getbufvar('&buftype'))
            exe i "wincmd w"
          endif
        endfor
      endif
    endif
    let s:FL.pos = l:pos
    let s:FL.div = l:div
    exe ((l:pos % 2) ? 'vert' : '') ['bel', 'abo', 'abo', 'bel'][l:pos] 'sb' s:FL.buf
    if !(l:pos % 2)
      exe "resize" (winheight(0)/l:div + 1)
    endif
    let &l:statusline = '  Find | %<%{b:Status} %=%3.l / %L  '
    setl wfh nowrap nofen fdc=0
    if !empty(s:FL.log)
      let s:Find.hi = s:FL.log.hi
    endif
    call s:SetHiFindWin(1)
    let l:win = winnr()
  endif
  exe l:win "wincmd w"
  return l:win
endfunction

function s:FindStop(op)
  if     !exists("s:Find.job") | return
  elseif  exists("*job_stop")  | call job_stop(s:Find.job)
  elseif  exists("*jobstop")   | call jobstop(s:Find.job)
  endif
  call s:FindSet(['', '--- Search Interrupted ---', ''], '+')
  if a:op
    call s:FindOpen()
    normal! G
  endif
  let s:Find.err += 1
  sleep 200m
endfunction

function s:FindSet(lines, op)
  call setbufvar(s:FL.buf, '&ma', 1)
  let l:err = 0
  let l:n = len(a:lines)
  if a:op == '='
    silent let l:err += deletebufline(s:FL.buf, 1, '$')
    let g:HiFindLines = 0
    let s:FL.lines = 0
    let s:FL.edit = 0
    if !empty(a:lines)
      let l:err += setbufline(s:FL.buf, 1, a:lines)
      call setbufvar(s:FL.buf, 'Status', s:FL.log.status)
      let l:line = s:FL.log.select ? s:FL.log.select : 1
      exe "normal!" l:line.'G'
    endif
  elseif l:n
    for l:line in a:lines
      let l:path = (index(['./', '.\'], l:line[:1]) == -1) ? 0 : 2
      call add(s:FL.log.list, '  '.l:line[l:path:])
    endfor
    if !s:FL.lines
      let l:err += setbufline(s:FL.buf, 1, s:FL.log.list[-l:n:])
    else
      let l:err += appendbufline(s:FL.buf, '$', s:FL.log.list[-l:n:])
    endif
  endif
  if l:err
    echo " * listing error "
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
    let s:Find.hi = []
  elseif s:Find.err || empty(s:FindSelect(1))
    let s:Find.hi = []
    let l:msg = ''
    call remove(s:FL.log.list, 0, -1)
  endif
  if !empty(s:Find.hi_err)
    let l:msg .= ' * '.s:Find.hi_err
  endif
  echo l:msg
  call s:SetHiFindWin(1)
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
  let l:num = a:line ? a:line : (s:FL.log.select ? s:FL.log.select : 1)
  let l:line = getbufline(s:FL.buf, l:num)[0]
  if len(l:line) < 2 | return | endif

  let l:pos = 2
  let l:file = matchstr(l:line, '\v[^:]*', l:pos)
  if s:FL.log.base != getcwd() && fnamemodify(l:file, ':p') != l:file
    let l:path = s:FL.log.base.'/'.l:file
  else
    let l:path = l:file
  endif
  if !filereadable(l:path)  " drive letter
    let l:file .= ':'.matchstr(l:line, '\v[^:]*', l:pos + len(l:file) + 1)
    let l:path = l:file
    if !filereadable(l:path) | return | endif
  endif

  call setbufvar(s:FL.buf, '&ma', 1)
  let l:pos += len(l:file) + 1
  let l:row = matchstr(l:line, '\v\d*', l:pos)
  let l:pos += len(l:row) + 1
  let l:col = matchstr(l:line, '\v\d*', l:pos)
  if s:FL.log.select && s:FL.log.select != l:num
    let l:select = getbufline(s:FL.buf, s:FL.log.select)[0]
    call setbufline(s:FL.buf, s:FL.log.select, ' '.l:select[1:])
  endif
  call setbufline(s:FL.buf, l:num, '| '.l:line[2:])
  call setbufvar(s:FL.buf, '&ma', 0)
  let s:FL.log.select = l:num
  return {'name':l:path, 'row':l:row, 'col':l:col}
endfunction

function s:FindRotate()
  if winnr('$') == 1 | return | endif
  let l:find = winnr()
  let l:win = []
  for w in ['k','l','j','h']   "     2
    call add(l:win, winnr(w))  "     ↓
  endfor                       " 1 → * ← 3
  let l:win += l:win           "     ↑
  let l:pos = s:FL.pos         "     0
  let l:div = s:FL.div
  let l:rotate = l:pos || s:CheckRepeat(660)
  for i in range(4)
    if l:win[l:pos] != l:find
      break
    endif
    let l:pos += 1
  endfor
  let l:pivot = win_getid(l:win[l:pos])
  if l:pos == 0
    if l:div == 4
      let l:rotate = 0
    endif
    let l:div = (4+1) - l:div
  endif
  if l:rotate
    let l:pos = (l:pos + 1) % 4
    let l:pos += l:pos == 2
    let l:div = 4
  endif
  noa close
  call win_gotoid(l:pivot)
  call s:FindOpen(l:pos, l:div)
endfunction

function s:FindEdit(op)
  let l:file = s:FindSelect(line('.'))
  if empty(l:file) | return | endif

  let l:find = win_getid()
  let l:edit = 0
  if a:op != 'split' && winnr('$') > 1
    noa wincmd p
    let wins = extend([winnr()], range(winnr('$'),1, -1))
    for w in wins
      noa exe w "wincmd w"
      if empty(&buftype) || bufnr() == bufnr(l:file.name)
        let l:edit = w | break
      endif
    endfor
    noa call win_gotoid(l:find)
  endif

  if l:edit
    exe l:edit "wincmd w"
  else
    let l:upper = winheight(winnr('k'))
    let l:height = winheight(0)
    if l:upper + l:height < 4 | return | endif
    if l:upper > l:height
      wincmd k | bel split
    else
      abo split
    endif
    let l:height = winheight(0)/4 + 1
    call win_gotoid(l:find)
    if winheight(0) > l:height
      exe "resize" l:height
    endif
    wincmd p
  endif

  let [l:scroll, l:guide] = [0, 0]
  let l:height = winheight(0)
  let l:buf = [bufnr(fnamemodify(bufname(), ':p')), bufnr(fnamemodify(l:file.name, ':p'))]
  if l:buf[0] != -1 && l:buf[0] == l:buf[1]
    let [l:top, l:bottom] = [line('w0'), line('w$')]
    exe "normal!" l:file.row.'G'
    let l:scroll = l:file.row < l:top || l:file.row > l:bottom
    if !l:scroll
      let l:bottom = max([l:top + l:height, l:bottom]) - 6
      let l:top += 4
      let l:guide = l:file.row < l:top || l:file.row > l:bottom
    endif
  else
    exe "edit +".l:file.row l:file.name
    let l:scroll = 1
  endif
  if l:scroll
    let l:scroll = (winline() >= l:height/2) ? (l:height/12)."\<C-E>" : ''
    exe "normal! zz" l:scroll l:file.row.'G'
    let l:guide = 1
  endif
  call cursor(0, l:file.col)
  let s:FL.edit = s:FL.log.select
  let l:view = (a:op != '=')
  if l:guide || l:view
    call s:SetFindGuide(0)
  endif
  if l:view
    call win_gotoid(l:find)
  endif
  call s:SetHiFindWin(1)
endfunction

function s:FindNextPrevious(op, num)
  if !s:FindOpen() | return | endif
  let l:sign = (a:op == '+') ? 1 : -1
  let l:count = a:num ? a:num : v:count
  if l:count == 1
    let l:line = 1
  else
    if !l:count
      let l:sign = s:FL.edit ? l:sign : 0
      let l:count = 1
    endif
    let l:line = max([1, s:FL.log.select + l:sign * l:count])
  endif
  exe "normal!" l:line.'G'
  call s:FindEdit('=')
endfunction

function s:FindOlderNewer(op, n)
  if empty(s:FL.log) | return | endif
  if exists("s:Find.job")
    echo ' searching in progress...' | return
  endif
  let l:logs = len(s:FL.logs) - empty(s:FL.log.list)
  if !l:logs | echo ' no list' | return | endif

  let l:win = bufwinnr(s:FL.buf)
  let l:find = s:FindOpen()
  if !l:find || l:win == -1 | return | endif

  let l:offset = ((a:op == '+') ? 1 : -1) * (a:n ? a:n : (v:count ? v:count : 1))
  let l:index = min([max([0, s:FL.index + l:offset]), l:logs-1])
  echo '  List  '.(l:index + 1).' / '.l:logs
  if s:FL.index != l:index
    let s:FL.index = l:index
    let s:FL.log = s:FL.logs[l:index]
    let s:Find.hi = s:FL.log.hi
    let s:Find.hi_tag += 1
    call s:FindSet(s:FL.log.list, '=')
    call s:FindSelect(0)
    call s:SetHiFindWin(1)
    noa exe l:find "wincmd w"
  endif
endfunction

function s:FindCloseWin()
  let l:win = bufwinnr(s:FL.buf)
  if l:win != -1
    exe l:win "wincmd q"
  endif
endfunction

function s:FindClear()
  if !empty(s:Find.hi)
    call s:SetHiFindWin(0)
    let s:Find.hi = []
  endif
endfunction

function s:BufEnter()
  if !exists("s:HiMode") || s:HiMode['>'] == '1' | return | endif
  call s:GetKeywords()
  call s:LinkCursorEvent('')
endfunction

function s:BufLeave()
  if !exists("s:HiMode") | return | endif
  call s:EraseHiWord()
endfunction

function s:BufHidden()
  if expand('<afile>') ==# s:FL.name
    call s:SetHiFindWin(0)
  endif
endfunction

function s:WinEnter()
  if s:GetSyncMode() && !exists("w:HiSync")
    call s:SetHiSync(0)
  endif
  if exists("s:HiMode")
    call s:LinkCursorEvent('')
  endif
endfunction

function s:WinLeave()
  if exists("s:HiMode")
    call s:UnlinkCursorEvent(0)
  endif
endfunction

function s:WinClosed()
  if expand('<afile>') == bufwinid(s:FL.buf)
    call s:SetHiFindWin(0)
  endif
endfunction

function s:TabClosed()
  let l:sync = map(gettabinfo(), {i,v -> get(v.variables, 'HiSync', '')})
  for k in keys(s:Sync.page)
    if (index(l:sync, k)) == -1
      unlet s:Sync.page[k]
    endif
  endfor
endfunction

function highlighter#Status()
  return getbufvar(s:FL.buf, 'Status')
endfunction

function highlighter#Airline(...)
  if winnr() == bufwinnr(s:FL.buf)
    let w:airline_section_a = ' Find '
    let w:airline_section_b = ''
    let w:airline_section_c = '%{highlighter#Status()}'
  endif
endfunction

function highlighter#ColorScheme(op)
  if a:op == 'pre'
    let s:Custom = []
    let l:begin = 1
    if exists("s:Colors")
      let s:Default = []
      for l:color in s:Colors
        let l:value = s:GetColor(l:color[0])
        call add(s:Default, [l:color[0], l:value])
      endfor
      let l:begin = 15
    endif
    for i in range(l:begin, 99)
      let l:key = 'HiColor'.i
      let l:value = s:GetColor(l:key)
      if !empty(l:value)
        call add(s:Custom, [l:key, l:value])
      endif
    endfor
  else
    if exists("s:Default")
      let l:next = (&background == 'dark') ? s:ColorsDark : s:ColorsLight
      let l:tune = (s:Colors != s:Colors16) && (s:Colors != l:next)
      let l:code = (has('gui_running') || (has('termguicolors') && &termguicolors)) ? 'guibg=\S\+' : 'ctermbg=\S\+'
      let i = 0
      while i < len(s:Default)
        let [l:key, l:val] = s:Default[i]
        if empty(s:GetColor(l:key))
          if l:tune && matchstr(l:val, l:code) ==# matchstr(s:Colors[i][1], l:code)
            let l:val = l:next[i][1]
          endif
          exe 'hi' l:key l:val
        endif
        let i += 1
      endwhile
      unlet s:Default
      let s:Colors = l:next
    endif
    if exists("s:Custom")
      for [l:key, l:val] in s:Custom
        if empty(s:GetColor(l:key))
          exe 'hi' l:key l:val
        endif
      endfor
      unlet s:Custom
    endif
  endif
endfunction

function highlighter#Complete(arg, line, pos)
  let l:cursor = a:line[a:pos]
  if !empty(l:cursor) && l:cursor != ' '| return [] | endif

  let l:part = split(a:line[:a:pos])
  let l:len = len(l:part)

  if a:line =~? '\v^Hi *( |:)(save|load)'
    let l:fields = 3 - (l:part[0] =~ 'Hi:')
    if (l:len < l:fields) || (l:len == l:fields && !empty(a:arg))
      let l:arg = expand(a:arg)
      if l:arg =~ '\v^\.\.?\/' || l:arg =~ '^\/'
        return s:FilterHiFiles(l:arg)
      else
        let l:path = s:GetKeywordsPath('load')
        if !empty(l:path)
          let l:entry = len(l:path) + 1
          return map(s:FilterHiFiles(l:path.'/'.l:arg), "v:val[l:entry:]")
        endif
      endif
    endif
  elseif a:line =~# '^Hi/Find '
    if  l:len == 1 | return | endif
    if a:arg =~ '^--\w'  " long option
      if s:Find.tool != matchstr(g:HiFindTool, '\v\S+')
        silent call s:FindTool()
      endif
      if !empty(s:Find.options)
        let l:list = s:Find.options.single + s:Find.options.with_value + ['--version']
        return filter(l:list, "v:val =~ '^'.a:arg")
      endif
    elseif l:len > 2  " path
      if a:arg[0] == '$'
        let l:list = getcompletion(a:arg[1:], 'environment')
        if len(l:list) > 1
          return map(l:list, "'$'.v:val")
        endif
      endif
      return getcompletion(a:arg, 'file')
    endif
  else  " commands
    let l:opt1 = ['+ ', '==', '>>', '<>', '//']
    let l:opt2 = ['/next', '/previous', '/older', '/newer', '/open', '/close',
                \ ':save ', ':load ', ':ls', ':default']
    if l:len == 1 && l:part[0] == 'Hi'
      return l:opt1 + opt2
    else
      let l:fields = 2 - (l:part[0] =~ 'Hi\S')
      if l:len == l:fields && !empty(a:arg)
        let l:list = filter(l:opt1 + l:opt2, "v:val =~# '^'.a:arg")
        if a:arg[0] =~ '\w'
          let l:list += filter(map(l:opt2, "v:val[1:]"), "v:val =~? '^'.a:arg")
        endif
        return l:list
      endif
    endif
  endif
  return []
endfunction

function highlighter#Find(mode)
  if s:Find.tool != matchstr(g:HiFindTool, '\v\S+')
    silent call s:FindTool()
  endif
  let l:cmd = 'Hi/Find  '
  if a:mode == '/x'
    let l:cmd .= s:Find.options.case.' "'.escape(s:GetVisualLine(), '$^*()-+[]{}\|.?"').'" '
  endif
  return l:cmd
endfunction

function highlighter#List()
  return getmatches()->filter({i,v -> match(v.group, s:Group) == 0})
         \ ->map({i,v -> {'color':matchstr(v.group, '\d\+'), 'pattern':v.pattern}})
endfunction

function highlighter#Search(key)
  if v:hlsearch || empty(get(w:, 'HiJump', ''))
    call feedkeys(max([v:count, 1]).a:key.'zv', 'n')
    return 0
  else
    let l:cmd = (a:key == 'n') ? '>' : '<'
    call s:JumpLong(l:cmd, v:count)
    return 1
  endif
endfunction

function highlighter#Command(cmd, ...)
  if !exists("s:Colors") && !s:Load()
    return
  endif
  let l:num = a:0 ? a:1 : 0
  let l:arg = split(a:cmd)
  let l:cmd = substitute(get(l:arg, 0, ''), '\v^[:/]', '', '')
  let l:val = join(l:arg[1:])
  let s:Search = 0

  if l:cmd == '+' || l:cmd == '-'
    if len(trim(a:cmd)) > 2
      let s:Input = a:cmd[2:]
      let l:opt = '='
    else
      let l:opt = 'n'
    endif
  endif

  if     l:cmd ==# ''        | echo ' Highlighter version '.s:Version
  elseif l:cmd ==# '+'       | call s:SetHighlight('+', l:opt, l:num)
  elseif l:cmd ==# '-'       | call s:SetHighlight('-', l:opt, l:num)
  elseif l:cmd ==# '+x'      | call s:SetHighlight('+', 'x', l:num)
  elseif l:cmd ==# '-x'      | call s:SetHighlight('-', 'x', l:num)
  elseif l:cmd ==# '+%'      | call s:SetHighlight('+', 'n%', l:num)
  elseif l:cmd ==# '+x%'     | call s:SetHighlight('+', 'x%', l:num)
  elseif l:cmd ==# '>>'      | call s:SetFocusMode('>', '')
  elseif l:cmd =~# '^<\w*>'  | call s:SetWordMode(l:cmd)
  elseif l:cmd =~# '^=.\?'   | call s:SetSyncMode(l:cmd)
  elseif l:cmd =~# '[<>]'    | call s:JumpLong(l:cmd, l:num)
  elseif l:cmd =~# '[{}]'    | call s:JumpNear(l:cmd)
  elseif l:cmd ==# 'Find'    | call s:Find(a:cmd[5:])
  elseif l:cmd ==# 'next'    | call s:FindNextPrevious('+', l:num)
  elseif l:cmd ==# 'previous'| call s:FindNextPrevious('-', l:num)
  elseif l:cmd ==# 'older'   | call s:FindOlderNewer('-', l:num)
  elseif l:cmd ==# 'newer'   | call s:FindOlderNewer('+', l:num)
  elseif l:cmd ==# 'open'    | call s:FindOpen()
  elseif l:cmd ==# 'close'   | call s:FindCloseWin()
  elseif l:cmd ==# '/'       | call s:FindClear()
  elseif l:cmd ==? 'clear'   | call s:ClearHighlights()
  elseif l:cmd ==? 'default' | call s:SetColors(1)
  elseif l:cmd ==? 'save'    | call s:SaveHighlight(l:val)
  elseif l:cmd ==? 'load'    | call s:LoadHighlight(l:val)
  elseif l:cmd ==? 'ls'      | call s:ListFiles()
  else
    echo ' Hi: no matching command: '.l:cmd
  endif
  return s:Search
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
