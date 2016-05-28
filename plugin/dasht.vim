command! -nargs=* -complete=tag -bang Dasht call Dasht(<q-args>, '<bang>')

" Searches for the given pattern in docsets configured for current filetype
" unless the second argument is `!`, in which case it searches all docsets.
function! Dasht(pattern, ...) abort
  call dasht#search(a:pattern, a:0 == 1 && a:1 == '!' ? [] : &filetype)
endfunction
