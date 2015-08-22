" Vim colour file - dark
" Dark and low contrast theme.
set background=dark
if version > 580
	hi clear
	if exists("syntax_on")
		syntax reset
	endif
endif

let g:colors_name = "dark"

"hi IncSearch -- no settings --
"hi WildMenu -- no settings --
"hi SignColumn -- no settings --
"hi Title -- no settings --
"hi CTagsMember -- no settings --
"hi CTagsGlobalConstant -- no settings --
"hi CTagsImport -- no settings --
"hi CTagsGlobalVariable -- no settings --
"hi SpellRare -- no settings --
"hi EnumerationValue -- no settings --
"hi Union -- no settings --
"hi Question -- no settings --
"hi WarningMsg -- no settings --
"hi VisualNOS -- no settings --
"hi DiffDelete -- no settings --
"hi ModeMsg -- no settings --
"hi EnumerationName -- no settings --
"hi MoreMsg -- no settings --
"hi SpellCap -- no settings --
"hi DiffChange -- no settings --
"hi SpellLocal -- no settings --
"hi DefinedName -- no settings --
"hi LocalVariable -- no settings --
"hi SpellBad -- no settings --
"hi CTagsClass -- no settings --
"hi Underlined -- no settings --
"hi DiffAdd -- no settings --
"hi clear -- no settings --
hi Normal guifg=#dcdcdc guibg=#050405 guisp=#050405 gui=NONE
hi Folded guifg=#b16088 guibg=NONE guisp=NONE gui=NONE
hi FoldColumn guifg=#b16088 guibg=NONE guisp=NONE gui=NONE
hi StatusLineNC guifg=#aaaaaa guibg=#4e4e4e guisp=#4e4e4e gui=NONE
hi NonText guifg=#7a7ae6 guibg=NONE guisp=NONE gui=NONE
hi DiffText guifg=#c400e6 guibg=#302d30 guisp=#302d30 gui=NONE
hi Error guifg=NONE guibg=#ff0000 guisp=#ff0000 gui=NONE
hi ErrorMsg guifg=#ff0000 guibg=#030303 guisp=#030303 gui=NONE
hi Ignore guifg=#e6c256 guibg=NONE guisp=NONE gui=NONE
hi Todo guifg=#000000 guibg=#fff700 guisp=#fff700 gui=NONE
hi Special guifg=#087724 guibg=NONE guisp=NONE gui=NONE
hi LineNr guifg=#828282 guibg=#121212 guisp=#121212 gui=NONE
hi StatusLine guifg=#00a2c2 guibg=#2e2b2e guisp=#2e2b2e gui=NONE
hi Search guifg=#ad0051 guibg=NONE guisp=NONE gui=NONE
hi TabLineSel guifg=#5959e6 guibg=#242124 guisp=#242124 gui=NONE
hi TabLineFill guifg=#000000 guibg=#240524 guisp=#240524 gui=NONE
hi Visual guifg=#e5e7e8 guibg=#827b82 guisp=#827b82 gui=NONE
hi MatchParen guifg=White guibg=DarkCyan
hi VertSplit guifg=#4e4e4e guibg=#4e4e4e guisp=#4e4e4e gui=NONE
hi Type guifg=#4d45e6 guibg=NONE guisp=NONE gui=NONE
hi TabLine guifg=#8b8b8b guibg=#4e4e4e guisp=#4e4e4e gui=NONE
hi underline guifg=#9e9ee6 guibg=NONE guisp=NONE gui=NONE
hi cursorim guifg=#192224 guibg=#536991 guisp=#536991 gui=NONE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Popup menu group
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
hi PMenu guifg=#00a2c2 guibg=#3a3a3d guisp=#3a3a3d gui=NONE
hi PMenuThumb guifg=#aaaaaa guibg=#121212 guisp=#121212 gui=NONE
hi PMenuSel guifg=#00a2c2 guibg=#27242b guisp=#27242b gui=NONE
hi PMenuSbar guifg=#9f9f9f guibg=#121212 guisp=#121212 gui=NONE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Cursor group
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
hi Cursor guifg=#040304 guibg=#d9d9d9 guisp=#d9d9d9 gui=NONE
hi CursorLine guifg=NONE guibg=NONE guisp=#d9d9d9 gui=NONE
hi link CursorColumn CursorLine
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Strings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
hi Comment guifg=#65e000 guibg=NONE guisp=NONE gui=italic
hi String guifg=#65e000 guibg=NONE guisp=NONE gui=NONE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Constans
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
hi Constant guifg=#0495bd guibg=NONE guisp=NONE gui=NONE
hi link Float Constant
hi link Number Constant
hi link Boolean Constant
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Preprocessor common for macro, include, define.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
hi! Macro guifg=#db07db guibg=NONE guisp=NONE gui=NONE
hi! link Include Macro
hi! link Define Macro
hi! link PreProc Macro
hi! link PreCondit Macro
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Special Characters group
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
hi SpecialComment guifg=#d98900 guibg=NONE guisp=NONE gui=NONE
hi link SpecialChar SpecialComment
hi link Debug SpecialComment
hi link Delimiter SpecialComment
hi link Tag SpecialComment
hi SpecialKey guifg=#61b100 guibg=NONE guisp=NONE gui=NONE
hi link Character SpecialKey
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Ident group
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
hi Identifier guifg=#e6e600 guibg=NONE guisp=NONE gui=NONE
hi link Function Identifier
hi link Directory Identifier
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Statement group
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
hi Statement guifg=#d96200 guibg=NONE guisp=NONE gui=NONE
hi link Structure Statement
hi link Repeat Statement
hi link Operator Statement
hi link Conditional Statement
hi link StorageClass Statement
hi link Exception Statement
hi link Keyword Statement
hi link Label Statement
hi link Typedef Statement
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

