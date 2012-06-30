" ==============================================================================
" Name:          ShowMarks (modified version by bootleq)
" Description:   Visually displays the location of marks.
" Authors:       Anthony Kruize <trandor@labyrinth.net.au>
"                Michael Geddes <michaelrgeddes@optushome.com.au>
" Version:       2.2
" Modified:      17 August 2004
" License:       Released into the public domain.
" ChangeLog:     See :help showmarks-changelog
"
" Usage:         Copy this file into the plugins directory so it will be
"                automatically sourced.
"
"                Default keymappings are:
"                  <Leader>mt  - Toggles ShowMarks on and off.
"                  <Leader>mo  - Turns ShowMarks on, and displays marks.
"                  <Leader>mh  - Clears a mark.
"                  <Leader>ma  - Clears all marks.
"                  <Leader>mm  - Places the next available mark.
" ==============================================================================

" Check if we should continue loading
if exists( "loaded_showmarks" )
	finish
endif
let loaded_showmarks = 1

" Bail if Vim isn't compiled with signs support.
if v:version < 700
	echoerr "ShowMarks requires Vim version > 7.0."
	finish
elseif has( "signs" ) == 0
	echoerr "ShowMarks requires Vim to have +signs support."
	finish
endif

" Options: Set up some nice defaults
if !exists('g:showmarks_enable'      ) | let g:showmarks_enable       = 1    | endif
if !exists('g:showmarks_auto_toggle' ) | let g:showmarks_auto_toggle  = 1    | endif
if !exists('g:showmarks_no_mappings' ) | let g:showmarks_no_mappings  = 0    | endif
if !exists('g:showmarks_ignore_type' ) | let g:showmarks_ignore_type  = "hq" | endif
if !exists('g:showmarks_hlline_lower') | let g:showmarks_hlline_lower = "0"  | endif
if !exists('g:showmarks_hlline_upper') | let g:showmarks_hlline_upper = "0"  | endif
if !exists('g:showmarks_hlline_other') | let g:showmarks_hlline_other = "0"  | endif

" Commands
command! -nargs=0 ShowMarksToggle    :call showmarks#ShowMarksToggle()
command! -nargs=0 ShowMarksOn        :call showmarks#ShowMarksOn()
command! -nargs=0 ShowMarksClearMark :call showmarks#ShowMarksClearMark()
command! -nargs=0 ShowMarksClearAll  :call showmarks#ShowMarksClearAll()
command! -nargs=0 ShowMarksPlaceMark :call showmarks#ShowMarksPlaceMark()

" Mappings
nnoremap <silent> <Plug>ShowMarksToggle    :<C-U>call showmarks#ShowMarksToggle()<CR>
nnoremap <silent> <Plug>ShowMarksOn        :<C-U>call showmarks#ShowMarksOn()<CR>
nnoremap <silent> <Plug>ShowMarksClearMark :<C-U>call showmarks#ShowMarksClearMark()<CR>
nnoremap <silent> <Plug>ShowMarksClearAll  :<C-U>call showmarks#ShowMarksClearAll()<CR>
nnoremap <silent> <Plug>ShowMarksPlaceMark :<C-U>call showmarks#ShowMarksPlaceMark()<CR>

if ! g:showmarks_no_mappings
	silent! nmap <silent> <unique> <leader>mt <Plug>ShowMarksToggle
	silent! nmap <silent> <unique> <leader>mo <Plug>ShowMarksOn
	silent! nmap <silent> <unique> <leader>mh <Plug>ShowMarksClearMark
	silent! nmap <silent> <unique> <leader>ma <Plug>ShowMarksClearAll
	silent! nmap <silent> <unique> <leader>mm <Plug>ShowMarksPlaceMark
endif
nnoremap <silent> <script> <unique> m :call showmarks#ShowMarksHooksMark()<CR>

" AutoCommands: Only if ShowMarks is enabled
if g:showmarks_enable == 1 && g:showmarks_auto_toggle
	augroup ShowMarks
		autocmd!
		autocmd CursorHold * call showmarks#ShowMarks()
	augroup END
endif

" Highlighting: Setup some nice colours to show the mark positions.
highlight default ShowMarksHLl ctermfg=darkblue ctermbg=blue cterm=bold guifg=blue guibg=lightblue gui=bold
highlight default ShowMarksHLu ctermfg=darkblue ctermbg=blue cterm=bold guifg=blue guibg=lightblue gui=bold
highlight default ShowMarksHLo ctermfg=darkblue ctermbg=blue cterm=bold guifg=blue guibg=lightblue gui=bold
highlight default ShowMarksHLm ctermfg=darkblue ctermbg=blue cterm=bold guifg=blue guibg=lightblue gui=bold


" -----------------------------------------------------------------------------
" vim:ts=4:sw=4:noet
