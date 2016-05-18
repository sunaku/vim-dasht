" Searches for the given pattern in the filetype as well as the given docsets.
" If no results are found, the search is repeated using all available docsets.
function! Dasht(pattern, ...) abort
  let docsets = add(copy(a:000), &filetype)
  let command = 'dasht '. shellescape(a:pattern, 1)
  let command = join([command] + map(docsets, 'shellescape(v:val, 1)'), ' ')
        \ .' 2>/dev/null || '. command " fallback to searching all docsets
  call DashtExec(command)
endfunction

" Runs the given shell command.  If it exits with a nonzero status, waits for
" the user to press any key before clearing the given shell command's output.
function! DashtExec(command) abort
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
