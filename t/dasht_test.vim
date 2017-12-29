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
    Expect dasht#command('foo!', []) == "dasht 'foo\\!' || dasht 'foo'"
    Expect dasht#command(['foo!'], []) == "dasht 'foo\\!' || dasht 'foo'"
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

  it 'strips leading and trailing whitespace from patterns'
    Expect dasht#resolve_pattern('foo ') == ['foo']
    Expect dasht#resolve_pattern(' foo') == ['foo']
    Expect dasht#resolve_pattern(' foo ') == ['foo']
    Expect dasht#resolve_pattern("foo\t") == ['foo']
    Expect dasht#resolve_pattern("\tfoo") == ['foo']
    Expect dasht#resolve_pattern("\tfoo\t") == ['foo']
  end

  it 'returns original version of pattern when it only contains word-chars'
    Expect dasht#resolve_pattern('foo') == ['foo']
  end

  it 'returns forgiving version of pattern when it contains non-word chars'
    Expect dasht#resolve_pattern('foo!') == ['foo!', 'foo']
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
    Expect dasht#resolve_pattern(['foo!']) == ['foo!', 'foo']
    Expect dasht#resolve_pattern(['foo', 'bar']) == ['foo', 'bar']
    Expect dasht#resolve_pattern(['foo!', 'bar']) == ['foo!', 'foo', 'bar']
    Expect dasht#resolve_pattern(['foo', 'bar!']) == ['foo', 'bar!', 'bar']
    Expect dasht#resolve_pattern(['foo!', 'bar!']) == ['foo!', 'foo', 'bar!', 'bar']
  end

  it 'removes duplicate patterns from the final list of patterns it returns'
    Expect dasht#resolve_pattern(['foo', 'foo']) == ['foo']
    Expect dasht#resolve_pattern(['foo', 'foo!']) == ['foo', 'foo!']
    Expect dasht#resolve_pattern(['foo', 'foo!', 'foo']) == ['foo', 'foo!']
  end

  it 'resolves function calls() into separate patterns to be more forgiving'
    Expect dasht#resolve_pattern('a()') == ['a()', 'a']
    Expect dasht#resolve_pattern('a()b()') == ['a()b()', 'a b', 'a', 'b']
    Expect dasht#resolve_pattern('a(b())') == ['a(b())', 'a b', 'a', 'b']
    Expect dasht#resolve_pattern('a(b(c))') == ['a(b(c))', 'a b c', 'a', 'b', 'c']
    Expect dasht#resolve_pattern('a(b())c()') == ['a(b())c()', 'a b c', 'a', 'b', 'c']
    Expect dasht#resolve_pattern('a(b(c,d))') == ['a(b(c,d))', 'a b c d', 'a', 'b', 'c', 'd']
    Expect dasht#resolve_pattern('a( b( c, d ) )') == ['a( b( c, d ) )', 'a b c d', 'a', 'b', 'c', 'd']
  end
end

describe 'dasht#resolve_docsets'
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

  it 'resolves filetype for multiple docsets if list is given'
    Expect dasht#resolve_docsets([]) == []

    unlet g:dasht_filetype_docsets
    Expect dasht#resolve_docsets(['foo']) == ['foo']
    Expect dasht#resolve_docsets(['foo', 'bar']) == ['foo', 'bar']

    let g:dasht_filetype_docsets = {'foo': ['hoge'], 'bar': ['piyo']}
    Expect dasht#resolve_docsets(['foo', 'bar']) == ['foo', 'hoge', 'bar', 'piyo']
  end
end

describe 'dasht#unique'
  it 'does nothing when there are no duplicates'
    Expect dasht#unique([]) == []
    Expect dasht#unique(['foo']) == ['foo']
    Expect dasht#unique(['foo', 'bar']) == ['foo', 'bar']
  end

  it 'retains first copy of adjacent duplicates'
    Expect dasht#unique(['foo', 'foo']) == ['foo']
    Expect dasht#unique(['foo', 'foo', 'bar']) == ['foo', 'bar']
    Expect dasht#unique(['foo', 'bar', 'bar']) == ['foo', 'bar']
    Expect dasht#unique(['qux', 'foo', 'foo', 'bar']) == ['qux', 'foo', 'bar']
  end

  it 'retains first copy of nonadjacent duplicates'
    Expect dasht#unique(['foo', 'bar', 'foo']) == ['foo', 'bar']
    Expect dasht#unique(['foo', 'bar', 'bar', 'foo']) == ['foo', 'bar']
    Expect dasht#unique(['foo', 'foo', 'bar', 'foo']) == ['foo', 'bar']
    Expect dasht#unique(['foo', 'foo', 'bar', 'bar', 'foo']) == ['foo', 'bar']
  end
end
