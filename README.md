# dasht.vim

(Neo)Vim plugin for [dasht] integration:
[dasht]: https://github.com/sunaku/dasht

```vim
" Search API docs for query you type in:
nnoremap <Leader>k :Dasht<Space>

" Search API docs for word under cursor:
nnoremap <silent> <Leader>K :call Dasht([expand('<cWORD>'), expand('<cword>')])<Return>

" Search API docs for the selected text:
vnoremap <silent> <Leader>K y:<C-U>call Dasht(getreg(0))<Return>
```

You can control which APIs are searched:

```vim
" Specify additional API docs to search:
" (maps filetype name to docset regexps)
let g:dasht_filetype_docsets = {
      \ 'elixir': ['erlang'],
      \ 'cpp': ['boost', '^c$', 'OpenGL', 'OpenCV_C'],
      \ 'html': ['css', 'js', 'bootstrap', 'jquery'],
      \ 'javascript': ['jasmine', 'nodejs', 'grunt', 'gulp', 'jade', 'react'],
      \ 'python': ['(num|sci)py', 'pandas', 'sqlalchemy', 'twisted', 'jinja'],
      \ }
```

Or search all APIs with an override `!`:

```vim
" Search API docs for query you type in:
nnoremap <Leader><Leader>k :Dasht!<Space>

" Search API docs for word under cursor:
nnoremap <silent> <Leader><Leader>K :call Dasht([expand('<cWORD>'), expand('<cword>')], '!')<Return>

" Search API docs for the selected text:
vnoremap <silent> <Leader><Leader>K y:<C-U>call Dasht(getreg(0), '!')<Return>
```

Developers can run the [vim-spec] tests:
[vim-spec]: https://github.com/kana/vim-vspec

```sh
gem install bundler         # first time
bundle install              # first time
bundle exec vim-flavor test # every time
```

Distributed under the same terms as Vim.
>  Copyright 2016 Suraj N. Kurapati
>     <https://github.com/sunaku>
