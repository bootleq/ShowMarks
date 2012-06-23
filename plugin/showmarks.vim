" ==============================================================================
" Name:          ShowMarks
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

" This is the default, and used in ShowMarksSetup to set up info for any
" possible mark (not just those specified in the possibly user-supplied list
" of marks to show -- it can be changed on-the-fly).
let s:all_marks = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.'`^<>[]{}()\""

" Commands
com! -nargs=0 ShowMarksToggle    :call <sid>ShowMarksToggle()
com! -nargs=0 ShowMarksOn        :call <sid>ShowMarksOn()
com! -nargs=0 ShowMarksClearMark :call <sid>ShowMarksClearMark()
com! -nargs=0 ShowMarksClearAll  :call <sid>ShowMarksClearAll()
com! -nargs=0 ShowMarksPlaceMark :call <sid>ShowMarksPlaceMark()

" Mappings
nnoremap <silent> <Plug>ShowMarksToggle    :<C-U>call <SID>ShowMarksToggle()<CR>
nnoremap <silent> <Plug>ShowMarksOn        :<C-U>call <SID>ShowMarksOn()<CR>
nnoremap <silent> <Plug>ShowMarksClearMark :<C-U>call <SID>ShowMarksClearMark()<CR>
nnoremap <silent> <Plug>ShowMarksClearAll  :<C-U>call <SID>ShowMarksClearAll()<CR>
nnoremap <silent> <Plug>ShowMarksPlaceMark :<C-U>call <SID>ShowMarksPlaceMark()<CR>

if ! g:showmarks_no_mappings
	silent! nmap <silent> <unique> <leader>mt <Plug>ShowMarksToggle
	silent! nmap <silent> <unique> <leader>mo <Plug>ShowMarksOn
	silent! nmap <silent> <unique> <leader>mh <Plug>ShowMarksClearMark
	silent! nmap <silent> <unique> <leader>ma <Plug>ShowMarksClearAll
	silent! nmap <silent> <unique> <leader>mm <Plug>ShowMarksPlaceMark
endif
nnoremap <silent> <script> <unique> m :call <SID>ShowMarksHooksMark()<CR>

" AutoCommands: Only if ShowMarks is enabled
if g:showmarks_enable == 1 && g:showmarks_auto_toggle
	aug ShowMarks
		au!
		autocmd CursorHold * call s:ShowMarks()
	aug END
endif

" Highlighting: Setup some nice colours to show the mark positions.
hi default ShowMarksHLl ctermfg=darkblue ctermbg=blue cterm=bold guifg=blue guibg=lightblue gui=bold
hi default ShowMarksHLu ctermfg=darkblue ctermbg=blue cterm=bold guifg=blue guibg=lightblue gui=bold
hi default ShowMarksHLo ctermfg=darkblue ctermbg=blue cterm=bold guifg=blue guibg=lightblue gui=bold
hi default ShowMarksHLm ctermfg=darkblue ctermbg=blue cterm=bold guifg=blue guibg=lightblue gui=bold

" Function: IncludeMarks()
" Description: This function returns the list of marks (in priority order) to
" show in this buffer.  Each buffer, if not already set, inherits the global
" setting; if the global include marks have not been set; that is set to the
" default value.
function! s:IncludeMarks()
	let key = 'showmarks_include'
	let marks = get(b:, key, get(g:, key, s:all_marks))
	if get(b:, 'showmarks_previous_include', '') != marks
		let b:showmarks_previous_include = marks
		call s:ShowMarksHideAll()
		call s:ShowMarks()
	endif
	return marks
endfunction

" Function: LineNumberOf()
" Paramaters: mark - mark (e.g.: t) to find the line of.
" Description: Find line number of specified mark in current buffer.
" Returns: Line number.
fun! s:LineNumberOf(mark)
	let pos = getpos("'" . a:mark)
	if pos[0] && pos[0] != bufnr("%")
		return 0
	else
		return pos[1]
	endif
endf

" Function: ShowMarksOn
" Description: Enable showmarks, and show them now.
fun! s:ShowMarksOn()
	if g:showmarks_enable == 0
		call <sid>ShowMarksToggle()
	else
		call <sid>ShowMarks()
	endif
endf

" Function: ShowMarksToggle()
" Description: This function toggles whether marks are displayed or not.
fun! s:ShowMarksToggle()
	if ! exists('b:showmarks_shown')
		let b:showmarks_shown = 0
	endif

	if b:showmarks_shown == 0
		let g:showmarks_enable = 1
		call <sid>ShowMarks()
		if g:showmarks_auto_toggle
			aug ShowMarks
				au!
				autocmd CursorHold * call s:ShowMarks()
			aug END
		endif
	else
		let g:showmarks_enable = 0
		call <sid>ShowMarksHideAll()
		if g:showmarks_auto_toggle
			aug ShowMarks
				au!
				autocmd BufEnter * call s:ShowMarksHideAll()
			aug END
		endif
	endif
endf

" Function: ShowMarks()
" Description: This function runs through all the marks and displays or
" removes signs as appropriate. It is called on the CursorHold autocommand.
" We use the l:mark_at_line variable to track what marks we've shown (placed)
" in this call to ShowMarks; to only actually place the first mark on any
" particular line -- this forces only the first mark (according to the order
" of showmarks_include) to be shown (i.e., letters take precedence over marks
" like paragraph and sentence.)
fun! s:ShowMarks()
	if g:showmarks_enable == 0
		return
	endif

	if   ((match(g:showmarks_ignore_type, "[Hh]") > -1) && (&buftype    == "help"    ))
	\ || ((match(g:showmarks_ignore_type, "[Qq]") > -1) && (&buftype    == "quickfix"))
	\ || ((match(g:showmarks_ignore_type, "[Pp]") > -1) && (&pvw        == 1         ))
	\ || ((match(g:showmarks_ignore_type, "[Rr]") > -1) && (&readonly   == 1         ))
	\ || ((match(g:showmarks_ignore_type, "[Mm]") > -1) && (&modifiable == 0         ))
		return
	endif

	let n = 0
	let s:maxmarks = strlen(s:IncludeMarks())
	let l:mark_at_line = {}
	while n < s:maxmarks
		let c = strpart(s:IncludeMarks(), n, 1)
		let id = n + (s:maxmarks * winbufnr(0))
		let ln = s:LineNumberOf(c)
		let mark_name_at_line = get(l:mark_at_line, ln, '')

		if ln > 0
			if strlen(mark_name_at_line)
				" Already placed a mark, set the highlight to multiple
				if c =~ '\a'
					call s:ChangeHighlight(mark_name_at_line, 'ShowMarksHLm')
				endif
			else
				call s:DefineSign(c)
				call s:ChangeHighlight(c, s:TextHLGroup(c))
				let l:mark_at_line[ln] = c
				call s:PlaceSign(c)
			endif
		endif
		let n = n + 1
	endwhile

	" TODO rewrite clearly
	for placed in filter(s:SignPlacementInfo(), 'index(values(l:mark_at_line), substitute(v:val["name"], "ShowMarks_", "", "")) == -1')
		execute 'sign unplace ' . placed.id . ' buffer=' . winbufnr(0)
	endfor

	let b:showmarks_shown = 1
endf

" Function: ShowMarksClearMark()
" Description: This function hides the mark at the current line.
" Only marks a-z and A-Z are supported.
fun! s:ShowMarksClearMark()
	let ln = line(".")
	let n = 0
	let s:maxmarks = strlen(s:IncludeMarks())
	while n < s:maxmarks
		let c = strpart(s:IncludeMarks(), n, 1)
		if c =~# '[a-zA-Z]' && ln == s:LineNumberOf(c)
			let id = n + (s:maxmarks * winbufnr(0))
			exe 'sign unplace '.id.' buffer='.winbufnr(0)
			execute "delmarks " . c
		endif
		let n = n + 1
	endw
endf

" Function: ShowMarksClearAll()
" Description: This function clears all marks in the buffer.
" Only marks a-z and A-Z are supported.
fun! s:ShowMarksClearAll()
	let n = 0
	let s:maxmarks = strlen(s:IncludeMarks())
	while n < s:maxmarks
		let c = strpart(s:IncludeMarks(), n, 1)
		if c =~# '[a-zA-Z]'
			let id = n + (s:maxmarks * winbufnr(0))
			exe 'sign unplace '.id.' buffer='.winbufnr(0)
			execute "delmarks " . c
		endif
		let n = n + 1
	endw
	let b:showmarks_shown = 0
endf

" Function: ShowMarksHideAll()
" Description: This function hides all marks in the buffer.
" It simply removes the signs.
fun! s:ShowMarksHideAll()
	for placed in s:SignPlacementInfo()
		execute 'sign unplace ' . placed.id . ' buffer=' . winbufnr(0)
	endfor
	let b:showmarks_shown = 0
endf

" Function: ShowMarksPlaceMark()
" Description: This function will place the next unplaced mark (in priority
" order) to the current location. The idea here is to automate the placement
" of marks so the user doesn't have to remember which marks are placed or not.
" Hidden marks are considered to be unplaced.
" Only marks a-z are supported.
fun! s:ShowMarksPlaceMark()
	" Find the first, next, and last [a-z] mark in showmarks_include (i.e.
	" priority order), so we know where to "wrap".
	let first_alpha_mark = -1
	let last_alpha_mark  = -1
	let next_mark        = -1

	if !exists('b:previous_auto_mark')
		let b:previous_auto_mark = -1
	endif

	" Find the next unused [a-z] mark (in priority order); if they're all
	" used, find the next one after the previously auto-assigned mark.
	let n = 0
	let s:maxmarks = strlen(s:IncludeMarks())
	while n < s:maxmarks
		let c = strpart(s:IncludeMarks(), n, 1)
		if c =~# '[a-z]'
			if s:LineNumberOf(c) <= 1
				" Found an unused [a-z] mark; we're done.
				let next_mark = n
				break
			endif

			if first_alpha_mark < 0
				let first_alpha_mark = n
			endif
			let last_alpha_mark = n
			if n > b:previous_auto_mark && next_mark == -1
				let next_mark = n
			endif
		endif
		let n = n + 1
	endw

	if next_mark == -1 && (b:previous_auto_mark == -1 || b:previous_auto_mark == last_alpha_mark)
		" Didn't find an unused mark, and haven't placed any auto-chosen marks yet,
		" or the previously placed auto-chosen mark was the last alpha mark --
		" use the first alpha mark this time.
		let next_mark = first_alpha_mark
	endif

	if (next_mark == -1)
		echohl WarningMsg
		echo 'No marks in [a-z] included! (No "next mark" to choose from)'
		echohl None
		return
	endif

	let c = strpart(s:IncludeMarks(), next_mark, 1)
	let b:previous_auto_mark = next_mark
	exe 'mark '.c
	call <sid>ShowMarks()
endf

" Function: DefineSign()
function! s:DefineSign(mark)
	let sign_name = 'ShowMarks_' . a:mark
	silent! execute 'sign list ' . sign_name
	if v:errmsg =~ '^E155:' " E155 Unknown sign
		let mark_type = s:MarkType(a:mark)
		let text = printf('%.2s', get(g:, 'showmarks_text' . mark_type, "\t"))
		let text = substitute(text, '\v\t|\s', a:mark, '')
		let texthl = s:TextHLGroup(a:mark)
		let cmd = printf('sign define %s %s text=%s texthl=%s',
					\	sign_name,
					\	get(g:, 'showmarks_hlline_' . mark_type) ? ' texthl=' . texthl : '',
					\	text,
					\	texthl
					\ )
		execute escape(cmd, '\')
	endif
endfunction

" Function: SignId()
function! s:SignId(mark)
	let included_marks = s:IncludeMarks()
	return stridx(included_marks, a:mark) + (strlen(included_marks) * winbufnr(0))
endfunction

" Function: SignPlacementInfo()
" Description: get list of placed sign info {'id': n, 'line': n, 'name': s} in current buffer
function! s:SignPlacementInfo()
	redir => msg
	silent! execute printf('sign place buffer=%s', winbufnr(0))
	redir END
	let info = []
	let obj = {}
	let pattern = escape('\v\s+line=(\d+)\s+id=(\d+)\s+name=(\p+)', '=')
	for item in map(split(msg, '\n'), 'matchlist(v:val, ''' . pattern . ''')[1:3]')
		if len(item) > 0
			let [obj.line, obj.id, obj.name] = item
			call add(info, copy(obj))
		endif
	endfor
	return info
endfunction

" Function: PlaceSign()
function! s:PlaceSign(mark)
	let sign_id     = s:SignId(a:mark)
	let line_number = s:LineNumberOf(a:mark)
	execute printf('sign unplace %s buffer=%s',
				\	sign_id,
				\	winbufnr(0)
				\ )
	execute printf('sign place %s name=ShowMarks_%s line=%s buffer=%s',
				\	sign_id,
				\	a:mark,
				\	line_number,
				\	winbufnr(0)
				\ )
endfunction

" Function: ChangeHighlight()
" Description: redefine texthl attribute of mark
function! s:ChangeHighlight(mark_name, new_texthl)
	redir => old_def
	silent! execute printf('sign list ShowMarks_%s', a:mark_name)
	redir END
	let old_def = substitute(old_def, '\v.*sign\s+', '', '')
	let old_texthl = matchstr(old_def, '\vtexthl\=\zs.+\ze$')

	if old_texthl != a:new_texthl
		execute 'sign define ' . substitute(old_def, '\vtexthl\=\zs.+\ze$', a:new_texthl, '')
	endif
endfunction

" Function: MarkType()
function! s:MarkType(char)
	if a:char =~ '\l'
		return 'lower'
	elseif a:char =~ '\u'
		return 'upper'
	else
		return 'other'
	endif
endfunction

" Function: TextHLGroup()
" Description: return proper texthl group name for character
function! s:TextHLGroup(char)
	return 'ShowMarksHL' . s:MarkType(a:char)[0]
endfunction

" Function: ShowMarksHooksMark()
" Description: Hooks normal m command for calling ShowMarks() with it.
fun! s:ShowMarksHooksMark()
	execute 'normal! m' . nr2char(getchar())
	call <SID>ShowMarks()
endf

" -----------------------------------------------------------------------------
" vim:ts=4:sw=4:noet
