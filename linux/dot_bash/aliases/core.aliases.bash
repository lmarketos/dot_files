#!/bin/bash

alias rebash="source $HOME/.bashrc"
alias sbash="source $HOME/.bashrc"
alias ebash="\$EDITOR $HOME/.bash/custom/bashrc.bash"

# cd aliases
alias ~="cd ~"

alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'

alias cd~='cd ~'
alias cd-='cd -'

alias cd..='cd ..'
alias cd...='cd ../../'
alias cd....='cd ../../../'
alias cd.....='cd ../../../../'

alias dirs="dirs -v -l"

# jump to common dirs
alias src="pushd $HOME/local/src"
alias home="pushd ~/"

# ls aliases
alias dir='ls -l'
alias l="ls -lahF"
alias la="ls -a"
alias lla="ls -lah"
alias ldot="ls -A $1 | grep ^[.].*"
alias l.="ldot"
alias ll='ls -lh'
alias ls='ls $LS_OPTIONS'
alias lsd="ls -lahF | grep -e /$"
alias lsf="ls -lahF | grep -v -e /$"
alias lss="ls -lahSr"
alias lst="ls -lahtr"

# manpage alias
alias man1="man 1"
alias man2="man 2"
alias man3="man 3"
alias man4="man 4"
alias man5="man 5"
alias man6="man 6"
alias man7="man 7"
alias man8="man 8"
alias man9="man 9"

# ps aliases
alias psl="ps -eHo pid,user,%mem,pcpu,cmd"
alias psls="pgrep -l"
alias psh="ps -efjH"
alias pst="pstree -c -h -l -n -p -u"

# find aliases
alias find="nice find"

# grep aliases
alias grep="nice grep ${LMAS_GREP_OPTIONS}"
alias gi="grep -Ii"
alias gir="grep -Iir"

# core files
alias no_core_files="ulimit -Sc 0"
alias enable_core_files="ulimit -Sc 102400"
alias rmc="rm -f core core.[0-9]* vgcore vgcore.[0-9]*"

# misc
alias more="less"
alias h="history"

