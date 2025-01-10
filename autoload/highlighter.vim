" Vim Highlighter: Highlight words and expressions
" Author: Azabiong
" License: MIT
" Source: https://github.com/azabiong/vim-highlighter
" Version: 1.63.3

scriptencoding utf-8
if exists("s:Version")
  finish
endif
let s:cpo_save = &cpo
set cpo&vim

let g:HiKeywords = get(g:, 'HiKeywords', '')
let g:HiFindTool = get(g:, 'HiFindTool', '')
let g:HiSyncMode = get(g:, 'HiSyncMode', 1)
let g:HiFindHistory = get(g:, 'HiFindHistory', 5)
let g:HiCursorGuide = get(g:, 'HiCursorGuide', 1)
let g:HiOneTimeWait = get(g:, 'HiOneTimeWait', 260)
let g:HiFollowWait = get(g:, 'HiFollowWait', 320)
let g:HiEffectOne = get(g:, 'HiEffectOne', 1)
let g:HiBackup = get(g:, 'HiBackup', 1)
let g:HiSetToggle = get(g:, 'HiSetToggle', 0)
let g:HiFindLines = 0

let s:Version   = '1.63.3'
let s:Sync      = {'mode':0, 'ver':0, 'match':[], 'add':[], 'del':[], 'prev':0}
let s:Keywords  = {'plug': expand('<sfile>:h').'/keywords', '.':[]}
let s:Guide     = {'tid':0, 'line':0, 'left':0, 'right':0, 'win':0, 'mid':0}
let s:Find      = {'tool':'_', 'opt':[], 'exp':'', 'file':[], 'line':'', 'err':0,
                  \'type':'', 'options':{}, 'hi_exp':[], 'hi':[], 'hi_err':'', 'hi_tag':0}
let s:FindList  = {'name':' Find *', 'buf':-1, 'pos':0, 'lines':0, 'edit':0,
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
let s:EffectOne = {'tid':0, 'color':'', 'rgb':[], 'frame':{}}

const s:FL = s:FindList
const s:Group = 'HiColor'

function s:Load()
  if exists("s:Colors") | return 1 | endif
  if !exists("s:Check")
    let s:GuiMode = has('gui_running')
    if s:GuiColors() || &t_Co >= 256
      let s:Check = 256
    else
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
    \ ['HiFind',    'ctermfg=223 ctermbg=95  cterm=none guifg=#ffe7d7 guibg=#8a625a gui=none'],
    \ ['HiGuide',   'ctermfg=188 ctermbg=62  cterm=none guifg=#d0d0d8 guibg=#4848d8 gui=none'],
    \ ['HiList',    'ctermfg=210 cterm=bold  guifg=#f89888 gui=bold'],
    \ ['HiColor1',  'ctermfg=234 ctermbg=113 cterm=none guifg=#001737 guibg=#82c65a gui=none'],
    \ ['HiColor2',  'ctermfg=52  ctermbg=179 cterm=none guifg=#500000 guibg=#e4ac58 gui=none'],
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
    \ ['HiColor13', 'ctermfg=52  ctermbg=213 cterm=none guifg=#470023 guibg=#ee8cee gui=none'],
    \ ['HiColor14', 'ctermfg=17  ctermbg=153 cterm=none guifg=#000047 guibg=#9cceee gui=none'],
    \ ['HiColor80', 'ctermbg=61  guibg=#5757af'],
    \ ['HiColor81', 'ctermbg=23  guibg=#005f37'],
    \ ['HiColor82', 'ctermbg=94  guibg=#875f27'],
    \ ['HiColor83', 'ctermbg=24  guibg=#005787'],
    \ ['HiColor84', 'ctermbg=18  guibg=#27278f'],
    \ ['HiColor85', 'ctermbg=240 guibg=#585858'],
    \ ]
  let s:ColorsLight = [
    \ ['HiOneTime', 'ctermfg=234 ctermbg=152 cterm=none guifg=#001828 guibg=#afd9d9 gui=none'],
    \ ['HiFollow',  'ctermfg=234 ctermbg=151 cterm=none guifg=#002800 guibg=#b3dfb4 gui=none'],
    \ ['HiFind',    'ctermfg=52  ctermbg=187 cterm=none guifg=#481808 guibg=#e3d3b7 gui=none'],
    \ ['HiGuide',   'ctermfg=231 ctermbg=62  cterm=none guifg=#f8f8f8 guibg=#6868e8 gui=none'],
    \ ['HiList',    'ctermfg=94  cterm=bold  guifg=#8c3028 gui=bold'],
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
    \ ['HiColor80', 'ctermbg=153 guibg=#afdfff'],
    \ ['HiColor81', 'ctermbg=150 guibg=#afdf87'],
    \ ['HiColor82', 'ctermbg=222 guibg=#ffdf87'],
    \ ['HiColor83', 'ctermbg=116 guibg=#87dfdf'],
    \ ['HiColor84', 'ctermbg=225 guibg=#ffd7ff'],
    \ ['HiColor85', 'ctermbg=251 guibg=#c6c6c6'],
    \ ]
  let s:Colors16 = [
    \ ['HiOneTime', 'ctermfg=DarkBlue ctermbg=LightCyan' ],
    \ ['HiFollow',  'ctermfg=DarkBlue ctermbg=LightGreen'],
    \ ['HiFind',    'ctermfg=Yellow   ctermbg=DarkGray'  ],
    \ ['HiGuide',   'ctermfg=White    ctermbg=DarkBlue'  ],
    \ ['HiList',    'ctermfg=DarkRed'],
    \ ['HiColor1',  'ctermfg=White   ctermbg=DarkGreen'  ],
    \ ['HiColor2',  'ctermfg=White   ctermbg=DarkCyan'   ],
    \ ['HiColor3',  'ctermfg=White   ctermbg=DarkMagenta'],
    \ ['HiColor4',  'ctermfg=White   ctermbg=DarkYellow' ],
    \ ['HiColor5',  'ctermfg=Black   ctermbg=LightYellow'],
    \ ['HiColor80', 'ctermfg=Black   ctermbg=LightGray'  ],
    \ ]
  let s:Colors = (s:Check < 256) ? s:Colors16 : s:ColorsDark
  let s:Number = [1, 80]
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
  let s:Sync.mode = g:HiSyncMode
  let s:HiJump = ['', '']
  call s:SetColors(0)

  let s:EO = s:EffectOne
  let s:PI = 0
  if exists("*prop_type_add")
    let s:PI = 1
    let s:PTypes = []
    for c in s:Colors
      call prop_type_add(c[0], {'highlight': c[0]})
      call add(s:PTypes, c[0])
    endfor
  else
    let s:NS = nvim_create_namespace(s:Group)
  endif

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
    au TabNew      * call <SID>TabNew()
    au TabEnter    * call <SID>TabEnter()
    au TabLeave    * call <SID>TabLeave()
  aug END
  return 1
endfunction

function s:GuiColors()
  return s:GuiMode || (has('termguicolors') && &termguicolors)
endfunction

function s:SetPosType(type)
  if index(s:PTypes, a:type) == -1
    call prop_type_add(a:type, {'highlight': a:type})
    call add(s:PTypes, a:type)
  endif
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

function s:MultilineColor(color)
  return 80 <= a:color && a:color < 90
endfunction

function s:SetHighlight(cmd, mode, num)
  if a:mode == 'n' && s:CheckRepeat(60) | return | endif

  if a:cmd == '--'
    call s:ClearPosHighlight()
    for l:m in getmatches()
      if match(l:m.group, s:Group) == 0
        call matchdelete(l:m.id)
      endif
    endfor
    call s:UpdateSync('del', '*', '')
    call s:UpdateJump('', '')
    let s:Number = [1, 80]
    return
  elseif a:cmd == '+'
    let l:number = a:num ? a:num : (v:count ? v:count : 0)
    let l:color = l:number ? l:number : s:Number[0]
    let l:color = hlexists(s:Group.l:color) ? l:color : 1
  else
    let l:color = 0
  endif

  let l:pos = getpos('.')
  let l:block = {}
  if a:mode == 'n'
    let l:word = expand('<cword>')
    let l:len = len(l:word)
    let l:word = escape(l:word, '\')
    let l:pattern = '\V\<'.l:word.'\>'
  elseif a:mode == 'n%'
    exe "normal! viwo\<Esc>"
    call setpos('.', l:pos)
    let l:block = s:GetVisualBlock()
    return s:SetPosHighlight(l:block, l:number)
  elseif a:mode[0] == 'x'
    let l:block = s:GetVisualBlock()
    if l:color && (l:block.rect[0] != l:block.rect[2] || a:mode[1] == '%')
      return s:SetPosHighlight(l:block, l:number)
    elseif !l:color && l:block.mode ==? 'v' && l:block.rect[0] != l:block.rect[2]
      return s:ClearHighlights(l:block)
    else
      let l:visual = trim(s:GetVisualLine(l:block))
      let l:word = escape(l:visual, '\')
      let l:pattern = '\V'.l:word
    endif
  elseif a:mode == '='
    let l:word = escape(s:Input, "'\"")
    let l:magic = &magic ? '\m' : '\M'
    let l:pattern = l:magic.l:word
  endif

  if empty(l:word)
    if !l:color | call s:SetFocusMode('-', '') | endif
    return
  endif

  let l:match = getmatches()
  let l:case = (&ic || stridx(@/, '\c') != -1) ? '\c' : ''
  if l:color
    let l:deleted = s:DeleteMatch(l:match, '==', l:pattern)
    let l:group = s:Group.l:color
    if a:mode == 'n' && s:GetFocusMode(1, l:pattern)
      return s:SetFocusMode('>', '')
    else
      if g:HiSetToggle && l:deleted && !l:number
        return
      endif
      try
        call matchadd(l:group, l:pattern, 0)
      catch
        echohl ErrorMsg
        echo  ' * '.v:exception
        echohl None
        return
      endtry
      call s:UpdateSync('add', l:group, l:pattern)
      call s:UpdateJump(l:pattern, l:group)
      let s:Search = match(@/, l:pattern.l:case) != -1 || match(l:pattern, @/.l:case) != -1
    endif
    if !s:MultilineColor(l:color)
      let s:Number[0] = l:color + 1
    endif
  else
    if s:GetFocusMode('>', '')
      let l:deleted = 0
      if a:mode == 'x'
        let s:HiMode['>'] = '<'
      endif
    elseif a:mode == '='
        let l:deleted = s:DeleteMatch(l:match, '==', l:pattern)
    else
      if a:mode == 'x'
        let l:deleted = s:DeleteMatch(l:match, '[=]', l:visual)
      else
        let l:deleted = s:DeletePattern(l:match, getline('.'), l:pos) || s:DeletePosHighlightAt(l:pos)
        if !l:deleted && get(g:, 'HiClearUsingOneTime', 0)
          return s:ClearHighlights()
        endif
      endif
    endif
    if !l:deleted && a:mode != '=' && l:pattern[:1] != '\%'
      let s:Search = (s:SetFocusMode('.', l:pattern) == '=') &&
                   \ (match(@/, l:pattern.l:case) != -1 || match(l:pattern, @/.l:case) != -1)
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

function s:GetVisualBlock()
  let l:mode = visualmode()
  let [l:upper, l:lower] = [getpos("'<"), getpos("'>")]
  let [l:top, l:from] = l:upper[1:2]
  let [l:bottom, l:to] = l:lower[1:2]
  let l:from += l:upper[3]
  let l:to += l:lower[3]
  let l:inclusive = &selection != 'exclusive'
  if l:mode == "\<C-V>" && l:from > l:to
    let [l:from, l:to] = [l:to, l:from]
    let l:to += !inclusive
  endif
  if inclusive && l:mode !=# 'V'
    let l:to += len(matchstr(getline(l:bottom), '\%'.l:to.'c.'))
  endif
  return {'mode':l:mode, 'rect':[l:top, l:from, l:bottom, l:to]}
endfunction

function s:GetVisualLine(block)
  let [l:top, l:from, l:bottom, l:to] = a:block.rect
  if l:top != l:bottom && a:block.mode ==# 'v'
    let l:to = v:maxcol
  endif
  let l:line = getline(l:top)
  let l:to -= l:to > 1
  return l:line[l:from-1 : l:to-1]
endfunction

function s:DeleteMatch(match, op, part)
  let l:i = len(a:match)
  let l:count = 0
  while l:i > 0
    let l:i -= 1
    let l:m = a:match[l:i]
    if match(l:m.group, s:Group) != 0 | continue | endif

    let l:match = 0
    if a:op == '=='
      let l:match = (a:part ==# l:m.pattern)
    elseif a:op == '[=]'
      let l:match = match(a:part, '\C'.l:m.pattern) != -1
    endif
    if l:match
      call matchdelete(l:m.id)
      call s:UpdateSync('del', l:m.group, l:m.pattern)
      if s:GetJump()[0] ==# l:m.pattern
        call s:UpdateJump('', '')
      endif
      if a:op != '[=]' | return 1 | endif
      let l:count += 1
    endif
  endwhile
  return l:count
endfunction

function s:DeletePattern(match, line, pos)
  let l:i = len(a:match)
  while l:i > 0
    let l:i -= 1
    let l:m = a:match[l:i]
    if match(l:m.group, s:Group) != 0 | continue | endif

    let l:pattern = l:m.pattern
    if stridx(l:m.pattern, '\%') == 2
      if stridx(l:m.pattern, a:pos[1].'l') != 4 | continue | endif
      let l:offset = len(matchstr(l:m.pattern, '\v^\\.\\\%\d+l'))
      let l:pattern = l:m.pattern[l:offset:]
      if empty(l:pattern)
        let l:pattern = '.*'
      endif
    endif

    let [l:num, l:col] = searchpos('\C'.l:pattern, 'bnc', a:pos[1])
    if l:num
      let l:len = len(matchstr(a:line, l:pattern, l:col-1))
      if a:pos[2] < l:col + l:len
        call matchdelete(l:m.id)
        call s:UpdateSync('del', l:m.group, l:m.pattern)
        if s:GetJump()[0] ==# l:m.pattern
          call s:UpdateJump('', '')
        endif
        return 1
      endif
    endif
  endwhile
endfunction

function s:SetPosHighlight(block, num)
  let l:rect = a:block.rect
  if l:rect[1] == l:rect[3] && (l:rect[0] == l:rect[2] || a:block.mode == "\<C-V>")
    return
  endif
  let l:pack = (l:rect[0] != l:rect[2])
  let l:color = a:num ? a:num : s:Number[l:pack]
  let l:color = hlexists(s:Group.l:color) ? l:color : [1, 80][l:pack]
  let l:group = s:Group.l:color
  let l:full = l:rect[3] < 0

  if s:PI
    call s:SetPosType(l:group)
    if a:block.mode == "\<C-V>"
      let l:list = []
      for i in range(l:rect[0], l:rect[2])
        let l:end = len(getline(i))
        if l:rect[1] < l:end
          call add(l:list, [i, l:rect[1], i, l:rect[3]])
        endif
        call s:DeletePosHighlight(l:list[-1])
      endfor
      call prop_add_list({'id':s:PI, 'type':l:group}, l:list)
    else
      let l:length = len(getline(l:rect[2])) + 1
      if l:full
        let l:rect[3] = l:length
        call prop_add(l:rect[0], 0, {'id':s:PI, 'type':l:group, 'text':repeat(' ', max([256 - l:length, 2]))})
      else
        let l:rect[3] = min([l:rect[3], l:length])
      endif
      call s:DeletePosHighlight(l:rect)
      call prop_add(l:rect[0], l:rect[1], {'id':s:PI, 'end_lnum':l:rect[2], 'end_col':l:rect[3], 'type':l:group})
    endif
    let s:PI += 1
  else
    let l:rect[3] = min([l:rect[3], len(getline(l:rect[2]))+1])
    call map(l:rect, {i,v -> v-1})
    if a:block.mode == "\<C-V>"
      for i in range(l:rect[0], l:rect[2])
        let l:end = len(getline(i+1))
        if l:rect[1] < l:end
          let l:end = (l:end <= l:rect[3]) ? l:end : l:rect[3]
          call s:DeletePosHighlight([i, l:rect[1], i, l:end])
          call nvim_buf_set_extmark(0, s:NS, i, l:rect[1], {'end_row':i, 'end_col':l:end, 'hl_group':l:group})
        endif
      endfor
    else
      if l:full
        let l:rect[3] = 0
      endif
      call s:DeletePosHighlight(l:rect)
      if l:full
        let l:opts = {'end_row':l:rect[2], 'line_hl_group':l:group}
      else
        let l:opts = {'end_row':l:rect[2], 'end_col':l:rect[3], 'hl_group':l:group}
      endif
      call nvim_buf_set_extmark(0, s:NS, l:rect[0], l:rect[1], l:opts)
    endif
  endif
  if l:pack == s:MultilineColor(l:color)
    let s:Number[l:pack] = l:color + 1
  endif
  call s:UpdateJump(s:GetJump()[0], l:group)
endfunction

function s:DeletePosHighlight(rect)
  if s:PI
    let l:props = prop_list(a:rect[0], {'end_lnum':a:rect[2]})
    let l:pos = {}
    for p in l:props
      if match(p.type, s:Group) == 0
        let l:id = exists("p.id") ? p.id : 0
        if l:id && p.start
          let l:pos[l:id] = [a:rect[0], a:rect[1]]
        endif
        if l:id && p.end && has_key(l:pos, p.id)
          call extend(l:pos[p.id], [p.lnum, p.col + p.length])
          if l:pos[p.id] == a:rect
            call prop_remove({'type':p.type, 'id': p.id, 'both':v:true})
            call prop_remove({'type':p.type}, a:rect[0])
            return 1
          endif
          call remove(l:pos, p.id)
        endif
      endif
    endfor
  else
    let [l:from, l:to] = [[a:rect[0], 0], [a:rect[0], -1]]
    let l:marks = nvim_buf_get_extmarks(0, s:NS, l:from, l:to, {'details':v:true})
    let i = len(l:marks)
    while i > 0
      let i -= 1
      let m = l:marks[i]
      if a:rect == [m[1], m[2], m[3].end_row, m[3].end_col]
        return nvim_buf_del_extmark(0, s:NS, m[0])
      endif
    endwhile
  endif
endfunction

function s:DeletePosHighlightAt(pos)
  if s:PI
    let l:props = prop_list(1, {'end_lnum':-1})
    for p in l:props
      if match(p.type, s:Group) == 0
        if p.lnum == a:pos[1] && p.col <= a:pos[2] && a:pos[2] < p.col + p.length
          call prop_remove({'type':p.type, 'id': p.id, 'both':v:true})
          call prop_remove({'type':p.type}, p.lnum)
          call s:UpdateJump(s:GetJump()[0], '')
          return 1
        endif
      endif
    endfor
  else
    let [l:row, l:col] = [a:pos[1]-1, a:pos[2]-1]
    let l:marks = nvim_buf_get_extmarks(0, s:NS, 0, -1, {'details':v:true})
    for i in range(len(l:marks)-1, 0, -1)
      let m = l:marks[i]
      let r = [m[1], m[2], m[3].end_row, m[3].end_col]
      if exists("m[3].hl_group")
        let l:group = m[3].hl_group
      else
        let l:group = m[3].line_hl_group
        let r[3] = v:maxcol
      endif
      if (r[0] == r[2] && r[0] == l:row)
        let l:in = r[1] <= l:col && l:col < r[3]
      else
        let l:in = (r[0] < l:row && l:row < r[2]) || (r[0] == l:row && r[1] <= l:col) || (r[2] == l:row && l:col < r[3])
      endif
      if l:in
        call nvim_buf_del_extmark(0, s:NS, m[0])
        for l:id in range(m[0]+1, m[0]+1024)
          if !s:DeletePosHighlightGroup(l:id, r[1], l:group) | break | endif
        endfor
        for l:id in range(m[0]-1, 1, -1)
          if !s:DeletePosHighlightGroup(l:id, r[1], l:group) | break | endif
        endfor
        call s:UpdateJump(s:GetJump()[0], '')
        return 1
      endif
    endfor
  endif
endfunction

function s:DeletePosHighlightGroup(id, col, group)
  let l:m = nvim_buf_get_extmark_by_id(0, s:NS, a:id, {'details':v:true})
  if !empty(l:m) && a:col == l:m[1] && l:m[0] == l:m[2].end_row
    let l:group = exists("l:m[2].hl_group") ? l:m[2].hl_group : l:m[2].line_hl_group
    if a:group == l:group
      return nvim_buf_del_extmark(0, s:NS, a:id)
    endif
  endif
endfunction

function s:FindPosHighlightGroupAt(pos)
  if s:PI
    let l:props = prop_list(1, {'end_lnum':-1})
    for p in l:props
      if match(p.type, s:Group) == 0
        if p.lnum == a:pos[1] && p.col <= a:pos[2] && a:pos[2] < p.col + p.length
          return p.type
        endif
      endif
    endfor
  else
    let [l:row, l:col] = [a:pos[1]-1, a:pos[2]-1]
    let l:marks = nvim_buf_get_extmarks(0, s:NS, 0, -1, {'details':v:true})
    for i in range(len(l:marks)-1, 0, -1)
      let m = l:marks[i]
      let r = [m[1], m[2], m[3].end_row, m[3].end_col]
      if (r[0] == r[2] && r[0] == l:row)
        let l:in = r[1] <= l:col && l:col < r[3]
      else
        let l:in = (r[0] < l:row && l:row < r[2]) || (r[0] == l:row && r[1] <= l:col) || (r[2] == l:row && l:col < r[3])
      endif
      if l:in
        return m[3].hl_group
      endif
    endfor
  endif
  return ''
endfunction

function s:ClearPosHighlight()
  if s:PI
      if v:version > 900
        call prop_remove({'types': s:PTypes, 'all':v:true})
      else
        for p in prop_list(1, {'end_lnum':-1})
          call prop_remove({'type':p.type, 'id': p.id, 'both':v:true})
        endfor
      endif
  else
    call nvim_buf_clear_namespace(0, s:NS, 0, -1)
  endif
endfunction

" returns [line, col, length, range, group]
function s:GetNearPosHighlight(sign, pos, range, group)
  let l:range = a:range
  let l:list = []
  if s:PI
    let [l:row, l:col] = [a:pos[1], a:pos[2]]
    let l:props = prop_list(1, {'end_lnum':-1})
    for p in l:props
      if match(p.type, a:group) == 0 && p.start && exists("p.id")
        let l:dist = a:sign * (p.lnum - l:row)
        if l:dist >= 0 && l:dist < l:range
          if p.lnum == l:row && a:sign * (p.col - l:col) <= 0
            continue
          endif
          let l:list = [[p.lnum, p.col, p.length, l:dist, p.type]]
          let l:range = l:dist
        elseif l:dist == l:range
          let l:list += [[p.lnum, p.col, p.length, l:dist, p.type]]
        endif
      endif
    endfor
    if !empty(l:list)
      if l:row != l:list[0][0]
        let l:col = (a:sign > 0) ? -1 : v:maxcol
      endif
      let l:length = v:maxcol
      let l:index = -1
      for i in range(len(l:list))
        let p = l:list[i]
        let l:dist = a:sign * (p[1] - l:col)
        if l:dist > 0 && l:dist < l:length
          let l:length = l:dist
          let l:index = i
        endif
      endfor
      if l:index >= 0
        let l:pos = l:list[l:index]
        let l:pos[3] = l:range
        return l:pos
      endif
    endif
  else
    let [l:row, l:col] = [a:pos[1]-1, a:pos[2]-1]
    let l:marks = nvim_buf_get_extmarks(0, s:NS, 0, -1, {'details':v:true})
    for m in l:marks
      if exists("m[3].hl_group")
        if match(m[3].hl_group, a:group) != 0
          continue
        endif
        if m[1] == m[3].end_row && m[2] >= m[3].end_col
          call nvim_buf_del_extmark(0, s:NS, m[0])
          continue
        endif
      elseif exists("m[3].line_hl_group")
        if match(m[3].line_hl_group, a:group) != 0
          continue
        endif
      else
        continue
      endif
      let l:dist = a:sign * (m[1] - l:row)
      if l:dist >= 0 && l:dist < l:range
        if m[1] == l:row && a:sign * (m[2] - l:col) <= 0
          continue
        endif
        let l:list = [[m[0], m[1], m[2]]]
        let l:range = l:dist
      elseif l:dist == l:range
        let l:list += [[m[0], m[1], m[2]]]
      endif
    endfor
    if !empty(l:list)
      if l:row != l:list[0][1]
        let l:col = (a:sign > 0) ? -1 : v:maxcol
      endif
      let l:length = v:maxcol + 1
      let l:id = 0
      for m in l:list
        let l:dist = a:sign * (m[2] - l:col)
        if l:dist > 0 && l:dist < l:length
          let l:length = l:dist
          let l:id = m[0]
        endif
      endfor
      if l:id
        let l:m = nvim_buf_get_extmark_by_id(0, s:NS, l:id, {'details':v:true})
        let l:span = (l:m[0] == l:m[2].end_row) ? l:m[2].end_col - l:m[1] : len(getline(l:m[0]+1)) - l:m[1]
        let l:group = exists("l:m[2].hl_group") ? l:m[2].hl_group : l:m[2].line_hl_group
        return [l:m[0]+1, l:m[1]+1, l:span, l:range, l:group]
      endif
    endif
  endif
  return []
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

function s:SetSyncMode(op, msg=0)
  let l:op = index(['=', '==', '==='], a:op)
  if  l:op == -1 | return s:NoOption(a:op) | endif

  if a:msg
    echo ' Hi '.['= Single window', '== Sync on each tab-page', '=== Sync across all tab-pages'][l:op]
  endif
  if l:op == s:Sync.mode | return | endif

  let s:Sync.mode = l:op
  let g:HiSyncMode = l:op
  call s:SetPage()
  if l:op == 0 | return | endif

  let l:match = s:LoadMatch()
  if l:op == 1
    let t:HiSync.match = l:match
  else
    let s:Sync.match = l:match
  endif
  call s:UpdateVer(1)
  for w in range(1, winnr('$'))
    call s:ApplySync(l:match, w, '*')
  endfor
endfunction

function s:UpdateSync(op, group, pattern)
  if !s:Sync.mode || a:pattern[:1] == '\%'
    return
  endif
  call s:SetPage()
  let l:match = s:GetMatch()
  let s:Sync[a:op] = [a:group, a:pattern]
  if a:op == 'add'
    call add(l:match, s:Sync[a:op])
  elseif a:op == 'del'
    if a:group == '*'
      if !empty(l:match)
        call remove(l:match, 0, -1)
      endif
    else
      for i in range(len(l:match))
        if l:match[i][1] ==# a:pattern
          call remove(l:match, i) | break
        endif
      endfor
    endif
  endif
  call s:UpdateVer(1)
  for w in range(1, winnr('$'))
    call s:ApplySync(l:match, w, '')
  endfor
  let s:Sync.add = []
  let s:Sync.del = []
endfunction

function s:ApplySync(match, win, flag)
  let l:ver = getwinvar(a:win, 'HiSync', 0)
  if l:ver == t:HiSync.ver | return | endif

  call setwinvar(a:win, 'HiSync', t:HiSync.ver)
  let l:match = getmatches(a:win)

  if !l:ver || a:flag == '*'
    for m in l:match
      if match(m.group, s:Group) == 0
        call matchdelete(m.id, a:win)
      endif
    endfor
    for m in a:match
      call matchadd(m[0], m[1], 0, -1, {'window': a:win})
    endfor
  else
    if !empty(s:Sync.del)
      if s:Sync.del[0] == '*'
        for m in l:match
          if match(m.group, s:Group) == 0
            call matchdelete(m.id, a:win)
          endif
        endfor
      else
        for m in l:match
          if (match(m.group, s:Group) == 0) && (m.pattern ==# s:Sync.del[1])
            call matchdelete(m.id, a:win) | break
          endif
        endfor
      endif
    endif
    if !empty(s:Sync.add)
      call matchadd(s:Sync.add[0], s:Sync.add[1], 0, -1, {'window': a:win})
    endif
  endif
endfunction

function s:UpdateVer(op)
  if a:op
    let s:Sync.ver += 1
    let w:HiSync = s:Sync.ver
  endif
  let t:HiSync.ver = s:Sync.ver
endfunction

function s:SetPage()
  if !exists("t:HiSync")
    let t:HiSync = {'mode':0, 'ver':0, 'match':[]}
  endif
  let t:HiSync.mode = s:Sync.mode
endfunction

function s:GetMatch()
  return (s:Sync.mode == 1) ? t:HiSync.match : s:Sync.match
endfunction

function s:LoadMatch()
  return filter(getmatches(), {i,v -> match(v.group, s:Group) == 0 && v.pattern[:1] != '\%'})
         \ ->map({i,v -> [v.group, v.pattern]})
endfunction

function s:ClearHighlights(block={})
  if empty(a:block)
    call s:SetHighlight('--', '', 0)
    call s:SetFocusMode('-', '')
    call s:FindClear()
  else
    for i in range(a:block.rect[0], a:block.rect[2])
      call s:DeleteMatch(getmatches(), '[=]', getline(i))
    endfor
    if s:PI
      if v:version > 900
        call prop_remove({'types': s:PTypes, 'all':v:true}, a:block.rect[0], a:block.rect[2])
      else
        for p in prop_list(1, {'end_lnum':-1})
          call prop_remove({'type':p.type, 'id': p.id, 'both':v:true}, a:block.rect[0], a:block.rect[2])
        endfor
      endif
    else
      let [l:from, l:to] = [[a:block.rect[0]-1, 0], [a:block.rect[2]-1, -1]]
      let l:marks = nvim_buf_get_extmarks(0, s:NS, l:from, l:to, {})
      for m in l:marks
        call nvim_buf_del_extmark(0, s:NS, m[0])
      endfor
    endif
  endif
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
    call s:SetHiFocus('')
  endif
  call s:StopEffectOne()
endfunction

function s:SetHiWord(word)
  if empty(a:word) | return | endif
  let [l:group, l:priority] = (s:HiMode['>'] == '1') ? ['HiOneTime', 10] : ['HiFollow', 0]
  call s:SetHiFocus([l:group, a:word, l:priority])
  let s:HiMode['w'] = a:word
  if g:HiEffectOne && s:GuiColors()
    call s:StartEffectOne(l:group)
  endif
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

function s:SetHiFocus(hi)  " hi[group, pattern, priority]
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

function s:SetHiFind(on)
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
        if l:buf == s:FL.buf
          for h in s:Find.hi
            call add(l:find.id, matchadd('HiList', '\v('.h.'\v)(.*:\d+:)@!', 0, -1, {'window': w}))
          endfor
        else
          for h in s:Find.hi
            call add(l:find.id, matchadd('HiFind', h, 0, -1, {'window': w}))
          endfor
        endif
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

function s:SetJumpGuide(tid, pos=[])
  if !g:HiCursorGuide | return | endif
  if s:Focus.tid
    call timer_stop(s:Focus.tid)
  endif
  if s:Focus.mid && win_id2tabwin(s:Focus.win)[0]
    call matchdelete(s:Focus.mid, s:Focus.win)
  endif
  if empty(a:pos)
    let s:Focus = {'tid':0, 'win':0, 'mid':0}
  else
    let s:Focus.win = win_getid()
    let s:Focus.mid = matchaddpos('HiGuide', [a:pos], 10, -1, {'window': s:Focus.win})
    let s:Focus.tid = timer_start(220, function('s:SetJumpGuide'))
  endif
endfunction

function s:GetKeywordsPath(op)
  if empty(g:HiKeywords)
    let l:home = expand('$HOME')
    let l:path = l:home.'/.config/keywords'
    if !isdirectory(l:path)
      let l:vim = (match(s:Keywords.plug, '/vimfiles') != -1) ? 'vimfiles' : '.vim'
      let l:old = l:home.'/'.l:vim.'/after/vim-highlighter'
      if isdirectory(l:old)
        let l:path = l:old
      endif
    endif
    let g:HiKeywords = l:path
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
  let l:list += getmatches()->filter({i,v -> match(v.group, s:Group) == 0})
              \ ->map({i,v -> matchstr(v.group, '\d\+').':'.v.pattern})
  let l:format = '%%:%s,%d,%d,%d,%d'
  if s:PI
    let l:props = prop_list(1, {'end_lnum':-1})
    let l:pos = {}
    for p in l:props
      if match(p.type, s:Group) == 0
        if p.start
          let l:pos[p.id] = [p.lnum, p.col]
        endif
        if p.end && has_key(l:pos, p.id)
          let l:rect = l:pos[p.id] + [p.lnum, p.col + p.length]
          call add(l:list, printf(l:format, matchstr(p.type, '\d\+'), l:rect[0], l:rect[1], l:rect[2], l:rect[3]))
          call remove(l:pos, p.id)
        endif
      endif
    endfor
  else
    let l:list += nvim_buf_get_extmarks(0, s:NS, 0, -1, {'details':v:true})
                \ ->map({i,v -> printf(l:format, matchstr(v[3].hl_group, '\d\+'), v[1]+1, v[2]+1, v[3].end_row+1, v[3].end_col+1)})
  endif

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
  call s:SetHighlight('--', '', 0)

  let l:jump = ['', '']
  for l:line in readfile(l:path)
    if l:line[0] == '#' | continue | endif
    let l:exp = match(l:line, ':')
    if l:exp > 0
      let l:num = l:line[:l:exp-1]
      let l:pattern = l:line[l:exp+1:]
      if l:num == '%'
        let l:pos = split(l:pattern, ',')
        let l:col = len(getline(l:pos[1]))
        if l:col < l:pos[2] | continue | endif
        let l:group = s:Group.l:pos[0]
        if s:PI
          call s:SetPosType(l:group)
          call prop_add(l:pos[1], l:pos[2], {'id':s:PI, 'end_lnum':l:pos[3], 'end_col':l:pos[4], 'type':l:group})
          let s:PI += 1
        else
          if l:pos[1] != l:pos[3]
            let l:col = len(getline(l:pos[3]))
          endif
          let l:pos[4] = min([l:pos[4], l:col+1])
          call nvim_buf_set_extmark(0, s:NS, l:pos[1]-1, l:pos[2]-1, {'end_row':l:pos[3]-1, 'end_col':l:pos[4]-1, 'hl_group':l:group})
        endif
      else
        let l:group = s:Group.l:num
        call matchadd(l:group, l:pattern, 0)
        let s:Number[0] = l:num
        let l:jump = [l:pattern, l:group]
      endif
    endif
  endfor
  let s:Number[0] += 1

  if s:Sync.mode
    let l:mode = s:Sync.mode
    let s:Sync.mode = 0
    call s:SetSyncMode(l:mode == 1 ? '==' : '===')
  endif
  call s:UpdateJump(l:jump[0], l:jump[1])
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
  let [l:num, l:col] = searchpos('\C'.a:pattern, 'bnc', a:pos[1])
  if l:num
    let l:len = len(matchstr(a:line, a:pattern, l:col-1))
    return a:pos[2] < l:col + l:len
  endif
endfunction

function s:UpdateJump(pattern, group)
  let l:info = [a:pattern, a:group]
  let [s:HiJump, t:HiJump, w:HiJump] = [l:info, l:info, l:info]
endfunction

" returns [pattern, group]
function s:GetJump()
  if s:Sync.mode == 0
    return get(w:, 'HiJump', ['',''])
  elseif s:Sync.mode == 1
    return get(t:, 'HiJump', ['',''])
  else
    return s:HiJump
  endif
endfunction

function s:JumpTo(pattern, group, flag, count, align=0)
  let l:from = getpos('.')
  let l:pattern = '\C'.a:pattern
  let l:jump = search(l:pattern, a:flag)

  if l:jump
    let l:to = getpos('.')
    if stridx(a:pattern, '\%') == 2
      let l:offset = len(matchstr(a:pattern, '\v^\\.\\\%\d+l'))
      let l:word = '\C'.a:pattern[l:offset:]
    else
      let l:word = l:pattern
    endif
    let l:length = len(matchstr(getline('.'), l:word, l:to[2]-1))
    let l:jump = (a:align || a:flag != 'b' || l:from[1] != l:to[1] || l:from[2] - l:to[2] >= l:length)
    while l:jump < a:count
      if !search(l:pattern, a:flag) | break | endif
      let l:jump += 1
    endwhile
    if l:jump
      let l:guide = [line('.'), col('.'), l:length]
      call s:SetJumpGuide(0, l:guide)
      call feedkeys('zv', 'n')
    endif
  endif
  if !empty(a:group)
    call s:UpdateJump(a:pattern, a:group)
  endif
  return 1
endfunction

function s:JumpLong(op, count)
  let [l:op, l:rev] = (a:op =~ '[<\[]') ? ['b', ''] : ['', 'b']
  let l:count = a:count ? a:count : (v:count ? v:count : 1)
  if exists("s:HiMode")
    let l:jump = s:HiMode['w']
    if !empty(l:jump)
      call s:JumpTo(l:jump, 0, l:op, l:count)
      let s:HiMode['p'] = getpos('.')
      return 1
    endif
  endif

  let l:matches = getmatches()
  let l:size = len(l:matches)
  let l:line = getline('.')
  let l:pos = getpos('.')
  let l:pattern = s:GetJump()[0]
  let l:jump = ''

  if !empty(l:pattern)
    for m in l:matches
      if match(m.group, s:Group) == 0 && l:pattern == m.pattern
        let l:jump = l:pattern
        break
      endif
    endfor
  endif

  if !empty(l:jump) && s:MatchPattern(l:line, l:pos, l:jump)
    return s:JumpTo(l:jump, 0, l:op, l:count)
  endif

  let i = l:size
  while i > 0
    let i -= 1
    let l:m = l:matches[i]
    if match(l:m.group, s:Group) == 0 && s:MatchPattern(l:line, l:pos, l:m.pattern)
      return s:JumpTo(l:m.pattern, l:m.group, l:op, l:count)
    endif
  endwhile

  if !empty(l:jump)
    if search('\C'.l:jump, 'n'.l:op)
      return s:JumpTo(l:jump, 0, l:op, l:count)
    elseif search('\C'.l:jump, 'n'.l:rev)
      return s:JumpTo(l:jump, 0, l:rev, 1)
    endif
  endif

  let i = l:size
  while i > 0
    let i -= 1
    let l:m = l:matches[i]
    if match(l:m.group, s:Group) == 0
      if search('\C'.l:m.pattern, 'n'.l:op)
        return s:JumpTo(l:m.pattern, l:m.group, l:op, 1)
      elseif search('\C'.l:m.pattern, 'n'.l:rev)
        return s:JumpTo(l:m.pattern, l:m.group, l:rev, 1)
      endif
    endif
  endwhile
endfunction

function s:JumpNear(op, count, group='')
  let [l:op, l:sign, l:end] = (a:op =~ '[{\[]') ? ['nWb', -1, 1] : ['nW', 1, line('$')]
  let l:count = a:count ? a:count : (v:count ? v:count : 1)
  let l:matches = getmatches()
  let l:size = len(l:matches)
  let l:group = empty(a:group) ? s:Group : a:group

  while l:count
    let l:count -= 1
    let l:match = []
    let l:pos = getpos('.')
    let l:base = l:pos[1]
    let l:stop = l:end
    let l:range = v:maxcol

    let i = l:size
    while i > 0
      let i -= 1
      let l:m = l:matches[i]
      if match(l:m.group, l:group) == 0
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

    let l:next = {}
    if !empty(l:match)
      for l:m in l:match
        let [l:num, l:col] = searchpos('\C'.l:m.pattern, l:op, l:stop)
        let l:col *= l:sign
        if empty(l:next) || l:col < l:next.col
          let l:next = {'col':l:col, 'pattern':l:m.pattern, 'group':l:m.group}
        endif
      endfor
    endif

    let l:near = s:GetNearPosHighlight(l:sign, l:pos, l:range, l:group)
    if !empty(l:near) && (l:near[3] < l:range || (l:near[3] == l:range && l:sign*l:near[1] < l:next.col))
      call cursor(l:near[0], l:near[1])
      call s:SetJumpGuide(0, l:near)
      call s:UpdateJump(s:GetJump()[0], l:near[4])
      call feedkeys('zv', 'n')
    elseif !empty(l:next)
      call s:JumpTo(l:next.pattern, l:next.group, l:op[1:], 1, 1)
    else
      break
    endif
  endwhile
endfunction

function s:JumpGroup(op, count)
  if exists("s:HiMode")
    return s:JumpLong(a:op, a:count)
  endif
  let l:matches = getmatches()
  let l:line = getline('.')
  let l:pos = getpos('.')

  let i = len(l:matches)
  while i > 0
    let i -= 1
    let l:m = l:matches[i]
    if match(l:m.group, s:Group) == 0 && s:MatchPattern(l:line, l:pos, l:m.pattern)
      return s:JumpNear(a:op, a:count, l:m.group.'\>')
    endif
  endwhile

  let l:group = s:FindPosHighlightGroupAt(l:pos)
  if !empty(l:group)
    return s:JumpNear(a:op, a:count, l:group.'\>')
  endif

  let l:group = s:GetJump()[1]
  if !empty(l:group)
    let l:group .= '\>'
  endif
  call s:JumpNear(a:op, a:count, l:group)
endfunction

function s:StartEffectOne(group)
  let l:color = matchstr(s:GetColor(a:group), '\cguibg=#\zs\w\+\ze')
  if l:color !~# '\v[0-9a-fA-F]{6}'
    return
  endif
  let l:rgb = [str2nr(l:color[:1],16), str2nr(l:color[2:3],16), str2nr(l:color[4:5],16)]
  let s:EO = #{group:a:group, color:l:color, rgb:l:rgb, tid:0}
  let s:EO.frame = #{rgb:s:EO.rgb, count:5, stage:0, step:0}
  let s:EO.frame.delta = (&background == 'dark') ? -6 : 3
  call s:UpdateEffectOne(0)
endfunction

function s:UpdateEffectOne(tid)
  if a:tid == 0
    let l:next = 600
  else
    let l:f = s:EO.frame
    let l:f.step += 1
    if l:f.step >= l:f.count
      let l:f.step = 0
      let l:f.delta = -l:f.delta
      let l:f.stage += 1
      let l:next = (l:f.stage % 2) ? 300 : 1200
    else
      let l:next = (l:f.delta > 0) ? 90 : 60
    endif
    for i in range(3)
      if l:f.delta < 0
        let l:f.rgb[i] = max([l:f.rgb[i] + l:f.delta, 0])
      else
        let l:f.rgb[i] = min([l:f.rgb[i] + l:f.delta, 0xff])
      endif
    endfor
    let l:color = printf("%02x%02x%02x", l:f.rgb[0], l:f.rgb[1], l:f.rgb[2])
    exe "hi" s:EO.group "guibg=#".l:color
  endif
  let s:EO.tid = timer_start(l:next, function('s:UpdateEffectOne'))
endfunction

function s:StopEffectOne()
  if s:EO.tid
    call timer_stop(s:EO.tid)
    let s:EO.tid = 0
    exe "hi" s:EO.group "guibg=#".s:EO.color
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
  call s:SetHiFind(0)
  let w:HiFind = {'tag':s:Find.hi_tag, 'id':[]}
  let b:Status = l:status

  try
    for l:exp in s:Find.hi_exp
      let l:id = matchadd('HiList', '\v('.l:exp.'\v)(.*:\d+:)@!', 0)
      call add(w:HiFind.id, l:id)
      call add(s:Find.hi, l:exp)
      call add(s:FL.log.hi, l:exp)
    endfor
  catch
    let s:Find.hi_err = v:exception
  endtry
  call s:FindStatus(" searching...")
endfunction

function s:FindOpen(pos=0)
  if s:FL.buf == -1 | echo ' no list' | return | endif
  let l:win = bufwinnr(s:FL.buf)
  if l:win == -1
    if !empty(&buftype)
      for i in range(winnr('$'), 1, -1)
        if empty(winbufnr(i)->getbufvar('&buftype'))
          exe i "wincmd w"
          break
        endif
      endfor
    endif
    let l:height = winheight(0)
    let s:FL.pos = a:pos
    exe ((a:pos % 2) ? 'vert' : '') ['bel', 'abo', 'abo', 'bel'][a:pos] 'sb' s:FL.buf
    if !(a:pos % 2) && l:height > 3
      noa wincmd p
      exe "resize" (l:height*7/8 - 1)
      noa wincmd p
      if &ea
        exe "resize" (l:height/8 + 1)
      endif
    endif
    let &l:statusline = '  Find | %<%{b:Status} %=%3.l / %L  '
    setl wfh nowrap nofen fdc=0
    if !empty(s:FL.log)
      let s:Find.hi = s:FL.log.hi
    endif
    call s:SetHiFind(1)
    let l:win = winnr()
  else
    exe l:win "wincmd w"
  endif
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
  call s:SetHiFind(1)
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
  for i in range(4)
    if l:win[l:pos] != l:find
      break
    endif
    let l:pos += 1
  endfor
  let l:rotate = l:pos || (l:find == l:win[0] && l:find == l:win[2]) || s:CheckRepeat(600)
  let l:pivot = win_getid(l:win[l:pos])
  let l:height = winheight(0)
  if l:rotate
    let l:pos = (l:pos + 1) % 4
    let l:pos += l:pos == 2
    if (l:pos % 2) || l:height > 2
      noa close
      call win_gotoid(l:pivot)
      call s:FindOpen(l:pos)
    endif
  else
    let l:upper = (l:find != l:win[0]) ? winheight(l:win[0]) : 0
    let l:lower = (l:find != l:win[2]) ? winheight(l:win[2]) : 0
    let l:high = max([l:upper, l:lower])
    if l:high > l:height
      let l:height = (l:upper + l:lower + l:height)/2 + 1
    else
      let l:height = l:height/4 + 1
    endif
    exe "resize" l:height
  endif
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
  let l:path = fnamemodify(bufname(), ':p')
  if filereadable(l:path) && bufnr(l:path) == bufnr(fnamemodify(l:file.name, ':p'))
    let [l:top, l:bottom] = [line('w0'), line('w$')]
    exe "normal!" l:file.row.'G'
    let l:scroll = l:file.row < l:top || l:file.row > l:bottom
    if !l:scroll
      let l:bottom = max([l:top + l:height, l:bottom]) - 4
      let l:top += 3
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
  call s:SetHiFind(1)
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
    call s:SetHiFind(1)
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
    call s:SetHiFind(0)
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
    call s:SetHiFind(0)
  endif
endfunction

function s:WinEnter()
  if exists("s:HiMode")
    call s:LinkCursorEvent('')
  endif
  if !s:Sync.mode | return | endif

  if !s:Sync.prev && !get(w:, 'HiSync', 0)
    call s:SetPage()
    call s:ApplySync(s:GetMatch(), winnr(), '*')
  endif
endfunction

function s:WinLeave()
  if exists("s:HiMode")
    call s:UnlinkCursorEvent(0)
  endif
endfunction

function s:WinClosed()
  if expand('<afile>') == bufwinid(s:FL.buf)
    call s:SetHiFind(0)
  endif
endfunction

function s:TabNew()
  if !s:Sync.mode | return | endif

  call s:SetPage()
  if s:Sync.mode == 1
    let t:HiSync.match = deepcopy(gettabvar(s:Sync.prev, 'HiSync', {'match':[]}).match)
  endif
  call s:UpdateVer(0)
  call s:ApplySync(s:GetMatch(), winnr(), '*')

  if bufnr() == s:FL.buf
    call s:SetHiFind(1)
  endif
endfunction

function s:TabEnter()
  let l:mode = exists("t:HiSync") ? t:HiSync.mode : 0
  let s:Sync.prev = 0

  if s:Sync.mode > l:mode || s:Sync.mode == 2  " 1:0 2:0 2:1 2:2
    call s:SetPage()
    if s:Sync.mode == 1
      let t:HiSync.match = s:LoadMatch()
      call s:UpdateVer(1)
    elseif s:Sync.ver != t:HiSync.ver
      call s:UpdateVer(0)
    endif
    for w in range(1, winnr('$'))
      call s:ApplySync(s:GetMatch(), w, '*')
    endfor
  elseif s:Sync.mode < l:mode  " 0:1 0:2 1:2
    let t:HiSync.mode = s:Sync.mode
  endif
endfunction

function s:TabLeave()
  let s:Sync.prev = tabpagenr()
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
    let l:opt1 = ['+', '-', '>>', '<>', '//']
    let l:opt2 = ['/next', '/previous', '/older', '/newer', '/open', '/close',
                 \'save ', 'load ', 'ls', 'clear', 'default']
    if l:len == 1 && l:part[0] ==? 'Hi'
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
    let l:cmd .= s:Find.options.case.' "'.escape(s:GetVisualLine(s:GetVisualBlock()), '$^*()-+[]{}\|.?"').'" '
  endif
  return l:cmd
endfunction

function highlighter#List()
  return getmatches()->filter({i,v -> match(v.group, s:Group) == 0})
       \ ->map({i,v -> {'color':matchstr(v.group, '\d\+'), 'pattern':v.pattern}})
endfunction

function highlighter#Search(key)
  if v:hlsearch
    let l:jmp = 0
  else
    let l:cmd = (a:key[0] ==# 'n') ? '>' : '<'
    let l:jmp = s:JumpLong(l:cmd, v:count)
  endif
  if !l:jmp
    call feedkeys(max([v:count, 1]).a:key.'zv', 'n')
  endif
  return l:jmp
endfunction

" args: [line, color] or [line, column, length, color]
function highlighter#SetPosHighlight(args)
  let l:args = len(a:args)
  if !s:Load() || !l:args
    return
  endif
  let l:line = a:args[0]
  if l:args > 2
    let [l:from, l:to] = [a:args[1], a:args[1]+a:args[2]]
  else
    let [l:from, l:to] = [1, -1]
  endif
  let l:color = (l:args == 2) ? a:args[1] : (l:args == 4) ? a:args[3] : 0
  let l:block = {'mode':'v', 'rect':[l:line, l:from, l:line, l:to]}
  call s:SetPosHighlight(l:block, l:color)
endfunction

" args: [line, column]
function highlighter#DelPosHighlight(args)
  let l:args = len(a:args)
  if !s:Load() || !l:args
    return
  endif
  let l:line = a:args[0]
  let l:column = (l:args > 1) ? a:args[1] : 1
  call s:DeletePosHighlightAt([0, l:line, l:column, 0])
endfunction

function highlighter#Command(cmd, ...)
  if !s:Load() | return | endif
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
  elseif l:cmd =~# '^='      | call s:SetSyncMode(l:cmd, 1)
  elseif l:cmd =~# '[<>]'    | call s:JumpLong(l:cmd, l:num)
  elseif l:cmd =~# '[{}]'    | call s:JumpNear(l:cmd, l:num)
  elseif l:cmd =~# '[\[\]]'  | call s:JumpGroup(l:cmd, l:num)
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
