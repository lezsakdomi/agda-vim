let s:cpo_save = &cpo
set cpo&vim

source ~/.vim/plugged/agda-vim/autoload/agda.vim
func! AgdaComplete(at, filter)
    echo "[AgdaComplete] \\".a:filter

    let c = nr2char(getchar())
    if empty(matchstr(c, '^[a-zA-Z0-9`^v~-–_\./?{}:;=*.+()|\\<>[\]≥≤#"'."'".'`-]$'))
        return c
    else
        let completions = []
        for [sequence, symbol] in items(g:agda#glyphs)
            if sequence =~ "^".a:filter.c
                call add(completions, {'word': symbol, 'abbr': printf('%s %s', symbol, sequence)})
            endif
        endfor
        call add(completions, "\\".a:filter)

        call complete(a:at, completions)

        let r = AgdaComplete(a:at, a:filter.c)
        "if r == " "
        "   return completions[0]['word']
        "else
        "   return r
        "endif
        return r
    endif
endfunc
noremap <ESC>C a
inoremap \ <C-R>=AgdaComplete(col('.'), "")<CR>

" The only mapping that was not prefixed by LocalLeader:
noremap! <buffer> <C-_> →

let &cpo = s:cpo_save
