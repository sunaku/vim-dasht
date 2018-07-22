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
  return [a:key] + get(get(g:, 'dasht_filetype_docsets', {}), a:key, [])
endfunction
