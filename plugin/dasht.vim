command! -nargs=* -complete=tag -bang Dasht call Dasht(<q-args>, '<bang>')

" Searches for the given pattern in docsets configured for current filetype
" unless the second argument is `!`, in which case it searches all docsets.
function! Dasht(pattern, ...) abort
  let filetypes = a:0 == 1 && a:1 == '!' ? [] : split(&filetype, '\.')
  call dasht#search(a:pattern, filetypes)
endfunction
