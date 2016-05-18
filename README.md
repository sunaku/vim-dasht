# dasht.vim

(Neo)Vim plugin for [dasht] integration:
[dasht]: https://github.com/sunaku/dasht

```vim
" Search API docs for word under cursor:
nnoremap <Leader>K :call Dasht(expand('<cword>'))<Return>

" Search API docs for the selected text:
vnoremap <Leader>K y:call Dasht(getreg(0))<Return>
```

Distributed under the same terms as Vim.
>  Copyright 2016 Suraj N. Kurapati
>     <https://github.com/sunaku>
