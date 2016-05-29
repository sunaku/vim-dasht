" Runs the given shell command.  If it exits with a nonzero status, waits for
" the user to press any key before clearing the given shell command's output.
" Under NeoVim, the terminal's title is overriden to reflect the given value.
function! dasht#execute(command, title) abort
  if has('nvim')
    let termopen = {}
    function termopen.on_exit(id, code, event)
      if a:code == 0 " successful exit status
        bdelete!
      endif
    endfunction
    -tabnew
    call termopen(a:command, termopen)
    " change tab title; see `:help :file_f`
    execute 'file' shellescape(a:title, 1)
    startinsert
  else
    " stty and dd below emulate getch(3)
    " as answered by Diego Torres Milano
    " http://stackoverflow.com/a/8732057
    silent execute '! clear;' a:command
          \ '|| {'
          \ 'stty raw -echo  ;'
          \ 'dd bs=1 count=1 ;'
          \ 'stty -raw echo  ;'
          \ '} >/dev/null 2>&1'
    redraw!
  endif
endfunction

" Builds a shell command that searches for the given pattern (which may be a
" list) in the given docsets (which may be a list or the name of a filetype).
function! dasht#command(pattern, docsets) abort
  let patterns = uniq(dasht#resolve_pattern(a:pattern))
  let patterns = empty(patterns) ? [''] : patterns
  return dasht#resolve_command(patterns, dasht#resolve_docsets(a:docsets))
endfunction

" Builds a shell command that searches for the given pattern (which may be a
" list) in the given docsets (which may be a list or the name of a filetype).
function! dasht#resolve_command(pattern, docsets) abort
  if type(a:pattern) == type([])
    return join(map(a:pattern, 'dasht#resolve_command(v:val, a:docsets)'), ' || ')
  else
    let arguments = map([a:pattern] + a:docsets, 'shellescape(v:val, 1)')
    return join(['dasht'] + arguments, ' ')
  endif
endfunction

" Resolves the given pattern (which may be a list) into a list of patterns:
" the first one is the original and the second one is a forgiving fallback,
" where all non-word characters are replaced by spaces (wildcards in dasht).
" Duplicate values are removed from this list before it is returned to you.
function! dasht#resolve_pattern(pattern) abort
  if type(a:pattern) == type([])
    let result = []
    call map(a:pattern, 'extend(result, dasht#resolve_pattern(v:val))')
    return result
  else
    let patterns = [a:pattern, substitute(a:pattern, '\W\+', ' ', 'g')]
    return uniq(filter(patterns, 'match(v:val, "\\S") != -1'))
  endif
endfunction

" Resolves the given docsets (which may be a list or the name of a filetype,
" which is resolved through lookup in `g:dasht_filetype_docsets` dictionary:
" the first one is original and the rest are from the dictionary definition).
function! dasht#resolve_docsets(docsets) abort
  if type(a:docsets) == type([])
    return a:docsets
  else
    let key = a:docsets
    return [key] + get(get(g:, 'dasht_filetype_docsets', {}), key, [])
  endif
endfunction

" Searches for the given pattern (which may be a list) in the given docsets
" (which may be a list or a filetype resolved by `g:dasht_filetype_docsets`).
function! dasht#search(pattern, docsets) abort
  let title = type(a:pattern) == type([]) ? a:pattern[0] : a:pattern
  call dasht#execute(dasht#command(a:pattern, a:docsets), title)
endfunction
