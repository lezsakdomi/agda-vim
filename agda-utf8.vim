let s:cpo_save = &cpo
set cpo&vim

source ~/.vim/plugged/agda-vim/autoload/agda.vim
func! AgdaComplete(at, filter, prefix)
	echo '[AgdaComplete] '.a:prefix.'\'.a:filter

	" Read a new character
	let gotChar = getchar()
	let c = nr2char(gotChar)

	" Handle backspace
	if gotChar is# "\<BS>"
		" TODO show completion popup again
		if empty(a:filter) && empty(a:prefix)
			return ""
		elseif empty(a:filter)
			return AgdaComplete(a:at, a:filter, strcharpart(a:prefix, 0, strchars(a:prefix)-1))
		else
			return AgdaComplete(a:at, a:filter[:-2], a:prefix)
		endif

	" Continue only if c could be part of a sequence, exit for ex. on space
	elseif empty(matchstr(c, '^[a-zA-Z0-9`^v~-–_\./?{}:;=*.+()|\\<>[\]≥≤#"'."'".'`-]$'))
		"return a:prefix.c
		return c

	" \ starts a new sequence, no need for pressing esc
	elseif (a:filter != "") && (c == '\')
		" TODO merge with the matching strategy below
		let hit = ""
		for [sequence, symbol] in items(g:agda#glyphs)
			if sequence[:len(a:filter)-1] == a:filter
				let hit = symbol
				break
			endif
		endfor
		return AgdaComplete(a:at, "", a:prefix.hit)

	else
		let completions = []

		" Search for possible completions on a:filter.c
		for [sequence, symbol] in items(g:agda#glyphs)
			if sequence[:len(a:filter)] == a:filter.c
				call add(completions, {'word': a:prefix.symbol, 'abbr': printf('%s %s', a:prefix.symbol, sequence)})
			endif

			" On exact match, insert to the top
			if sequence == a:filter.c
				call insert(completions, {'word': a:prefix.symbol, 'abbr': printf('%s %s ←', a:prefix.symbol, sequence)})
			endif
		endfor

		" In case of an "invalid" character backtrace for last match
		" and offer the rest as plaintext
		if empty(completions)
			let hitSymbol = ""
			let hitSequence = a:filter.c
			while hitSequence != "" && hitSymbol == ""
				for [sequence, symbol] in items(g:agda#glyphs)
					if sequence[:len(hitSequence)-1] == hitSequence
						let hitSymbol = symbol
						break
					endif
				endfor
				let hitSequence = hitSequence[:-2]
			endwhile
			call insert(completions, a:prefix.hitSymbol.(a:filter.c)[len(hitSequence)+1:])
		endif

		" Offer a:filter.c as plain text
		call add(completions, a:prefix.'\'.a:filter.c)

		call complete(a:at, completions)

		let r = AgdaComplete(a:at, a:filter.c, a:prefix)
		"if r == " "
		"   return completions[0]['word']
		"else
		"   return r
		"endif
		return r
	endif
endfunc
noremap <ESC>C a
inoremap \ <C-R>=AgdaComplete(col('.'), "", "")<CR>

" The only mapping that was not prefixed by LocalLeader:
noremap! <buffer> <C-_> →

let &cpo = s:cpo_save
