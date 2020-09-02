
" Search in subfolders for tab-completion and file-related tasks
set path+=**

" Display all matching files when tab complete
set wildmenu

" Add MakeTags command
command! MakeTags !ctags -R --c++-kinds=+p --fields=+iaS --extras=+q --language-force=c++  .

