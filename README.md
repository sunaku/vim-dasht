# dasht.vim

A (Neo)Vim plugin for [dasht]( https://github.com/sunaku/dasht ) integration:

* Search docsets for something you type:

    ```vim
    " search related docsets
    nnoremap <Leader>k :Dasht<Space>

    " search ALL the docsets
    nnoremap <Leader><Leader>k :Dasht!<Space>
    ```

* Search docsets for words under cursor:

    ```vim
    " search related docsets
    nnoremap <silent> <Leader>K :call Dasht(dasht#cursor_search_terms())<Return>

    " search ALL the docsets
    nnoremap <silent> <Leader><Leader>K :call Dasht(dasht#cursor_search_terms(), '!')<Return>
    ```

* Search docsets for your selected text:

    ```vim
    " search related docsets
    vnoremap <silent> <Leader>K y:<C-U>call Dasht(getreg(0))<Return>

    " search ALL the docsets
    vnoremap <silent> <Leader><Leader>K y:<C-U>call Dasht(getreg(0), '!')<Return>
    ```

* Specify related docsets for searching:

    ```vim
    let g:dasht_filetype_docsets = {} " filetype => list of docset name regexp

    " For example: {{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{

      " When in Elixir, also search Erlang:
      let g:dasht_filetype_docsets['elixir'] = ['erlang']

      " When in C++, also search C, Boost, and OpenGL:
      let g:dasht_filetype_docsets['cpp'] = ['^c$', 'boost', 'OpenGL']

      " When in Python, also search NumPy, SciPy, and Pandas:
      let g:dasht_filetype_docsets['python'] = ['(num|sci)py', 'pandas']

      " When in HTML, also search CSS, JavaScript, Bootstrap, and jQuery:
      let g:dasht_filetype_docsets['html'] = ['css', 'js', 'bootstrap']

    " and so on... }}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
    ```

* Configure where results are displayed:

    ```vim
    " create window below current one (default)
    let g:dasht_results_window = 'new'

    " create window beside current one
    let g:dasht_results_window = 'vnew'

    " use current window to show results
    let g:dasht_results_window = 'enew'

    " create panel at left-most edge
    let g:dasht_results_window = 'topleft vnew'

    " create panel at right-most edge
    let g:dasht_results_window = 'botright vnew'

    " create new tab beside current one
    let g:dasht_results_window = 'tabnew'
    ```

## Testing

Developers can run the [vim-vspec]( https://github.com/kana/vim-vspec ) tests:

```sh
gem install bundler         # first time
bundle install              # first time
bundle exec vim-flavor test # every time
```

## License

[Spare A Life]: https://sunaku.github.io/vegan-for-life.html
> Like my work? :+1:  Please [spare a life] today as thanks!
:cow::pig::chicken::fish::speak_no_evil::v::revolving_hearts:

Copyright 2016 Suraj N. Kurapati <https://github.com/sunaku>

Distributed under the same terms as Vim itself.
