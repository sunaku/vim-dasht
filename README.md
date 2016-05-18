# dasht.vim

(Neo)Vim plugin for [dasht] integration:
[dasht]: https://github.com/sunaku/dasht

```vim
" Search API docs for word under cursor:
nnoremap <Leader>K :call Dasht(expand('<cword>'))<Return>

" Search API docs for the selected text:
vnoremap <Leader>K y:call Dasht(getreg(0))<Return>
```

Or you can control which APIs to search:

```vim
" Specify additional API docs to search:
" (maps filetype name to docset regexps)
let docsets_by_filetype = {
      \ 'elixir': ['erlang'],
      \ 'cpp': ['boost', '^c$', 'OpenGL', 'OpenCV_C'],
      \ 'html': ['css', 'js', 'bootstrap', 'jquery'],
      \ 'javascript': ['jasmine', 'nodejs', 'grunt', 'gulp', 'jade', 'react'],
      \ 'python': ['(num|sci)py', 'pandas', 'sqlalchemy', 'twisted', 'jinja'],
      \ }

" Search API docs for word under cursor:
nnoremap <Leader>K :call call('Dasht', [expand('<cword>')]
      \ + get(docsets_by_filetype, &filetype, []))<Return>

" Search API docs for the selected text:
vnoremap <Leader>K y:call call('Dasht', [getreg(0)]
      \ + get(docsets_by_filetype, &filetype, []))<Return>
```

Distributed under the same terms as Vim.
>  Copyright 2016 Suraj N. Kurapati
>     <https://github.com/sunaku>
