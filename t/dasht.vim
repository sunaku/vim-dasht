describe 'dasht#command'
  it 'runs dasht with blank argument when no/blank pattern is given'
    Expect dasht#command('', []) == "dasht ''"
    Expect dasht#command(' ', []) == "dasht ''"
    Expect dasht#command([''], []) == "dasht ''"
    Expect dasht#command([], []) == "dasht ''"
  end

  it 'runs dasht with argument when pattern is given'
    Expect dasht#command('foo', []) == "dasht 'foo'"
    Expect dasht#command(['foo'], []) == "dasht 'foo'"
  end

  it 'joins commands with || when fallback patterns are given'
    Expect dasht#command(['foo', 'bar'], []) == "dasht 'foo' || dasht 'bar'"
  end

  it 'joins commands with || when pattern expands into forgiving fallback'
    Expect dasht#command('foo!', []) == "dasht 'foo\\!' || dasht 'foo '"
    Expect dasht#command(['foo!'], []) == "dasht 'foo\\!' || dasht 'foo '"
  end

  it 'ignores duplicate patterns and instead only operates on unique ones'
    Expect dasht#command(['foo', 'foo'], []) == "dasht 'foo'"
  end
end

describe 'dasht#resolve_command'
  it 'blindly maps pattern to commands that run them with dasht'
    Expect dasht#resolve_command('', []) == "dasht ''"
    Expect dasht#resolve_command(' ', []) == "dasht ' '"
    Expect dasht#resolve_command('foo', []) == "dasht 'foo'"
    Expect dasht#resolve_command([], []) == ''
    Expect dasht#resolve_command([''], []) == "dasht ''"
    Expect dasht#resolve_command([' '], []) == "dasht ' '"
    Expect dasht#resolve_command(['foo'], []) == "dasht 'foo'"
  end

  it 'joins commands with || when fallback patterns are given'
    Expect dasht#resolve_command(['foo', 'bar'], []) == "dasht 'foo' || dasht 'bar'"
  end
end

describe 'dasht#resolve_pattern'
  it 'filters out blank (only containing whitespace) patterns'
    Expect dasht#resolve_pattern('') == []
    Expect dasht#resolve_pattern(' ') == []
    Expect dasht#resolve_pattern("\t") == []
    Expect dasht#resolve_pattern(" \t ") == []
    Expect dasht#resolve_pattern("\t \t") == []
  end

  it 'returns original version of pattern when it only contains word-chars'
    Expect dasht#resolve_pattern('foo') == ['foo']
  end

  it 'returns forgiving version of pattern when it contains non-word chars'
    Expect dasht#resolve_pattern('foo!') == ['foo!', 'foo ']
  end

  it 'when given a list as argument, does all of the above for each member'
    Expect dasht#resolve_pattern([]) == []
    Expect dasht#resolve_pattern(['']) == []
    Expect dasht#resolve_pattern([' ']) == []
    Expect dasht#resolve_pattern(["\t"]) == []
    Expect dasht#resolve_pattern(['foo']) == ['foo']
    Expect dasht#resolve_pattern(['foo', '']) == ['foo']
    Expect dasht#resolve_pattern(['foo', ' ']) == ['foo']
    Expect dasht#resolve_pattern(['foo', "\t"]) == ['foo']
    Expect dasht#resolve_pattern(['foo!']) == ['foo!', 'foo ']
    Expect dasht#resolve_pattern(['foo', 'bar']) == ['foo', 'bar']
    Expect dasht#resolve_pattern(['foo!', 'bar']) == ['foo!', 'foo ', 'bar']
    Expect dasht#resolve_pattern(['foo', 'bar!']) == ['foo', 'bar!', 'bar ']
    Expect dasht#resolve_pattern(['foo!', 'bar!']) == ['foo!', 'foo ', 'bar!', 'bar ']
  end

  it 'removes duplicate patterns from the final list of patterns it returns'
    Expect dasht#resolve_pattern(['foo', 'foo']) == ['foo']
    Expect dasht#resolve_pattern(['foo', 'foo!']) == ['foo', 'foo!', 'foo ']
  end
end

describe 'dasht#resolve_docsets'
  it 'returns argument if list'
    Expect dasht#resolve_docsets([]) == []
    Expect dasht#resolve_docsets(['foo']) == ['foo']
    Expect dasht#resolve_docsets(['foo', 'bar']) == ['foo', 'bar']
    Expect dasht#resolve_docsets('foo') != 'foo'
  end

  it 'resolves filetype to itself when not found in dictionary'
    let g:dasht_filetype_docsets = {}
    Expect dasht#resolve_docsets('foo') == ['foo']

    unlet g:dasht_filetype_docsets
    Expect dasht#resolve_docsets('foo') == ['foo']
  end

  it 'resolves filetype to itself and definition in dictionary'
    let g:dasht_filetype_docsets = {'foo': []}
    Expect dasht#resolve_docsets('foo') == ['foo']

    let g:dasht_filetype_docsets = {'foo': ['bar']}
    Expect dasht#resolve_docsets('foo') == ['foo', 'bar']

    let g:dasht_filetype_docsets = {'foo': ['bar', 'qux']}
    Expect dasht#resolve_docsets('foo') == ['foo', 'bar', 'qux']
  end
end
