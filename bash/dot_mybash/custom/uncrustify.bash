alias unc="uncrustify -c $HOME/local/src/SconsSetup/Config/Uncrustify.cfg --replace --no-backup"
alias uncd="find . -maxdepth 1 -name '*.cpp' -o -name '*.c' -o -name '*.h' -o -name '*.txx' | uncrustify -c $HOME/local/src/SconsSetup/Config/Uncrustify.cfg --no-backup -F -"
alias uncr="find . -name '*.cpp' -o -name '*.c' -o -name '*.h' -o -name '*.txx' | uncrustify -c $HOME/local/src/SconsSetup/Config/Uncrustify.cfg --no-backup -F -"
