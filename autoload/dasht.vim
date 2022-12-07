" Searches for the given pattern (which may be a list) in the given docsets
" (which may be a list or a filetype resolved by `g:dasht_filetype_docsets`).
function! dasht#search(pattern, docsets) abort
  let title = type(a:pattern) == type([]) ? a:pattern[0] : a:pattern
  call dasht#execute(dasht#command(a:pattern, a:docsets), title)
endfunction

" Runs the given shell command.  If it exits with a nonzero status, waits for
" the user to press any key before clearing the given shell command's output.
" Under NeoVim, the terminal's title is overriden to reflect the given value.
function! dasht#execute(command, title) abort
  if has('terminal')
    call s:open_dasht_window()
    call term_start(['sh', '-c', a:command], {
          \ 'curwin': 1,
          \ 'term_name': a:title,
          \ 'exit_cb': function('s:handle_dasht_exit')
          \ })
  elseif has('nvim')
    call s:open_dasht_window()
    call termopen(a:command, {'on_exit': function('s:handle_dasht_exit')})
    " change tab title; see `:help :file_f`
    silent! execute 'file' shellescape(a:title, 1)
    startinsert
  else
    " stty and dd below emulate getch(3)
    " as answered by Diego Torres Milano
    " http://stackoverflow.com/a/8732057
    let command = 'clear ; '. a:command
          \ .' || {'
          \ .' stty raw -echo  ;'
          \ .' dd bs=1 count=1 ;'
          \ .' stty -raw echo  ;'
          \ .' } >/dev/null 2>&1'

    " gvim has no terminal emulation, so
    " launch an actual terminal emulator
    if has('gui') && has('gui_running')
      let command = 'xterm'
            \ .' -T '. shellescape(a:title)
            \ .' -e '. shellescape(command)
            \ .' &'
    endif

    silent execute '!' command
    redraw!
  endif
endfunction

function! s:open_dasht_window() abort
  execute get(g:, 'dasht_results_window', 'new')
endfunction

function! s:handle_dasht_exit(job_id, exit_status, ...) abort
  if a:exit_status == 0
    bdelete!
  elseif has('nvim')
    " Vim's :terminal exits insert mode when job is terminated,
    " whereas NeoVim's :terminal still remains in insert mode
    " and waits for any keypress before auto-closing itself.
    " This overrides NeoVim's :terminal to behave like Vim.
    call feedkeys("\<C-\>\<C-N>", 'n')
  endif
endfunction

" Builds a shell command that searches for the given pattern (which may be a
" list) in the given docsets (which may be a list or the name of a filetype).
function! dasht#command(pattern, docsets) abort
  let patterns = dasht#resolve_pattern(a:pattern)
  let patterns = empty(patterns) ? [''] : patterns
  return dasht#resolve_command(patterns, dasht#resolve_docsets(a:docsets))
endfunction

" Resolves the given pattern (which may be a list) into a list of patterns:
" the first one is the original and the second one is a forgiving fallback,
" where all non-word characters are replaced by spaces (wildcards in dasht).
" Duplicate values are removed from this list before it is returned to you.
function! dasht#resolve_pattern(pattern) abort
  if type(a:pattern) == type([])
    let result = []
    call map(a:pattern, 'extend(result, dasht#resolve_pattern(v:val))')
    return dasht#unique(result)
  else
    let funcalls = split(a:pattern, '[(,)]\+')
    let wildcard = substitute(a:pattern, '\W\+', ' ', 'g')
    let patterns = map([a:pattern, wildcard] + funcalls,
          \ 'substitute(v:val, "^\\s\\+\\|\\s\\+$", "", "g")')
    return dasht#unique(filter(patterns, 'match(v:val, "\\S") != -1'))
  endif
endfunction

" Removes duplicate items, even if they are not adjacent, from the given list.
function! dasht#unique(list) abort
  let new = {}
  return filter(a:list, 'get(new, v:val, 1) && len(extend(new, {v:val : 0}))')
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

" Resolves the given docsets (which may be a list or the name of a filetype,
" which is resolved through lookup in `g:dasht_filetype_docsets` dictionary:
" the first one is original and the rest are from the dictionary definition).
function! dasht#resolve_docsets(docsets) abort
  let resolved = []
  let unresolved = type(a:docsets) == v:t_list ? a:docsets : [a:docsets]
  call map(unresolved, 'extend(resolved, s:resolve_single_docset(v:val))')
  return resolved
endfunction

function! s:resolve_single_docset(key) abort
  return get(get(g:, 'dasht_filetype_docsets', {}), a:key, [a:key])
endfunction

let s:function_call_delimiters = '[()[:space:]]\+'
let s:word_boundary_delimiters = '\W\+'

" Finds search terms in the given haystack of text at the given column number.
function! dasht#find_search_terms(haystack, cursor_column) abort
  if a:haystack !~ '\S'
    return []
  endif

  let terms = split(a:haystack, s:function_call_delimiters .'\zs')
  let [terms_cursor_index, terms_cursor_column] = s:find_cursor_term(terms, a:cursor_column)
  if terms_cursor_index < 0
    return []
  endif

  " use subword under cursor as the secondary fallback search term
  let cursor_term = terms[terms_cursor_index]
  let cursor_words = split(cursor_term, s:word_boundary_delimiters .'\zs')
  let cursor_term_column = a:cursor_column - terms_cursor_column
  let [cursor_words_index, _] = s:find_cursor_term(cursor_words, cursor_term_column)
  if cursor_words_index >= 0
    let cursor_term_word = cursor_words[cursor_words_index]
    let cursor_term_word = substitute(cursor_term_word, s:word_boundary_delimiters, '', 'g')
  endif

  " assemble results, adding cursor subword as secondary fallback
  let results = reverse(terms[0:terms_cursor_index])
  let results = map(results, 'substitute(v:val, ",", "", "g")')
  let results = insert(results, cursor_term_word, 1)
  let results = map(results, 'substitute(v:val, s:function_call_delimiters, "", "g")')
  let results = uniq(results) " cursor_term_word may be duplicate

  " don't go back further than comma nearest to word under cursor
  let results_comma_index = index(results, "")
  if results_comma_index > 0
    let results = results[0:results_comma_index-1]
  endif

  return results
endfunction

function! s:find_cursor_term(terms, cursor_column) abort
  let index = 0
  let column = 0
  for term in a:terms
    let width = len(term)
    if column < a:cursor_column && column + width >= a:cursor_column
      return [index, column]
    endif
    let index += 1
    let column += width
  endfor
  return [-1, -1]
endfunction

" Finds search terms at the cursor position.  This is a more intelligent form
" of the expression "[expand('<cWORD>'), expand('<cword>')]" because it breaks
" complex <cWORD>s containing multiple function calls (e.g. "foo(bar(baz))")
" into pieces and focuses your search on the piece directly under the cursor.
function! dasht#cursor_search_terms() abort
  return dasht#find_search_terms(getline('.'), col('.'))
endfunction
