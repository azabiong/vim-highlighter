" Find in Files - grep output

if exists("b:current_syntax")
  finish
endif

syn match grepFile "^[^:]*" nextgroup=grepLine
syn match grepLine "\v:(\d+:){,2}" contained
syn region QuickFixLine start="^|" end="$"

hi def link grepFile Directory
hi def link grepLine Comment

let b:current_syntax = "find"
