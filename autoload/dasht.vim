" Runs the given shell command.  If it exits with a nonzero status, waits for
" the user to press any key before clearing the given shell command's output.
function! dasht#execute(command) abort
  if has('nvim')
    let termopen = {}
    function termopen.on_exit(id, code, event)
      if a:code == 0 " successful exit status
        bdelete!
      endif
    endfunction
    -tabnew
    call termopen(a:command, termopen)
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

" Returns a shell command that searches dasht for the given pattern in the
" given docsets.  If none are given or if no results are found, the search
" is repeated using all available docsets, for a more forgiving experience.
function! dasht#command(pattern, docsets) abort
  let command = 'dasht '. shellescape(a:pattern, 1)
  let command = join([command] + map(a:docsets, 'shellescape(v:val, 1)'), ' ')
  if !empty(a:docsets) " fallback to searching inside all available docsets
    let command = command .' 2>/dev/null || '. command
  endif
  return command
endfunction

" Searches for the given pattern in docsets either directly given as a list
" or indirectly looked up through the `g:dasht_filetype_docsets` dictionary.
function! dasht#search(pattern, docsets_or_filetype) abort
  if type(a:docsets_or_filetype) == type([])
    let docsets = a:docsets_or_filetype
  else " look it up from the dictionary
    let key = a:docsets_or_filetype
    let docsets = [key] + get(get(g:, 'dasht_filetype_docsets', {}), key, [])
  endif
  call dasht#execute(dasht#command(a:pattern, docsets))
endfunction
