
" Search in subfolders for tab-completion and file-related tasks
set path+=**

" Display all matching files when tab complete
set wildmenu

" Add MakeTags command
command! MakeTags !ctags -R --c++-kinds=+p --fields=+iaS --language-force=c++  .

let make_command_file = "./makeprg.vim"
if filereadable(make_command_file)
  exec 'source '.fnameescape(make_command_file)
endif
