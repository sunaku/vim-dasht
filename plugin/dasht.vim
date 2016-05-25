command! -nargs=* -complete=tag -bang Dasht call Dasht(<q-args>, '<bang>')

" Searches for the given pattern in docsets configured for current filetype.
" However, if no results are found, searches again in all available docsets.
" If `!` is given as second argument, skips looking up docsets for filetype.
function! Dasht(pattern, ...) abort
  call dasht#search(a:pattern, a:0 == 1 && a:1 == '!' ? [] : &filetype)
endfunction
