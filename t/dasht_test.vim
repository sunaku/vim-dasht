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

describe 'dasht#find_search_terms'
  it 'empty line'
    Expect dasht#find_search_terms('', 1) == []
  end

  it 'blank line'
    Expect dasht#find_search_terms(' ', 1) == []
  end

  it 'single word'
    Expect dasht#find_search_terms('foo', 1) == ['foo']
  end

  it 'single word with surrounding whitespace'
    Expect dasht#find_search_terms('foo ', 1) == ['foo']
    Expect dasht#find_search_terms(' foo', 2) == ['foo']
    Expect dasht#find_search_terms(' foo ', 2) == ['foo']
  end

  it 'single word of multiple subwords: cursor on first subword'
    Expect dasht#find_search_terms('foo.bar', 1) == ['foo.bar', 'foo']
  end

  it 'single word of multiple subwords: cursor at end of first subword'
    Expect dasht#find_search_terms('foo.bar', 4) == ['foo.bar', 'foo']
  end

  it 'single word of multiple subwords: cursor on second subword'
    Expect dasht#find_search_terms('foo.bar', 5) == ['foo.bar', 'bar']
  end

  it 'single word of multiple subwords: cursor on second subword'
    Expect dasht#find_search_terms('foo.bar.baz', 9) == ['foo.bar.baz', 'baz']
  end

  it 'multiple words: cursor on first word'
    Expect dasht#find_search_terms('foo bar', 1) == ['foo']
    Expect dasht#find_search_terms('foo(bar', 1) == ['foo']
  end

  it 'multiple words: cursor at end of first word'
    Expect dasht#find_search_terms('foo bar', 4) == ['foo']
    Expect dasht#find_search_terms('foo(bar', 4) == ['foo']
  end

  it 'multiple words: cursor on second word'
    Expect dasht#find_search_terms('foo bar', 5) == ['bar', 'foo']
    Expect dasht#find_search_terms('foo(bar', 5) == ['bar', 'foo']
  end
end

describe 'dasht#cursor_search_terms'
  before
    call setline('.', 'Outer.outerFun(Inner.innerFun(innerArg, innerArg2), outerArg)')
  end

  it 'outer function call'
    normal ^t(
    Expect dasht#cursor_search_terms() == ['Outer.outerFun', 'outerFun']
  end

  it 'opening parenthesis is considered part of function call'
    normal ^f(
    Expect dasht#cursor_search_terms() == ['Outer.outerFun', 'outerFun']
  end

  it 'inner function call includes outer function call'
    normal ^2t(
    Expect dasht#cursor_search_terms() == ['Inner.innerFun', 'innerFun', 'Outer.outerFun']
  end

  it 'inner function call argument includes function calls'
    call search('innerArg')
    Expect dasht#cursor_search_terms() == ['innerArg', 'Inner.innerFun', 'Outer.outerFun']
  end

  it 'outer function call argument excludes function calls (stops at comma)'
    call search('outerArg')
    Expect dasht#cursor_search_terms() == ['outerArg']
  end
end
