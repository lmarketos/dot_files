#!/bin/bash

alias make="nice make \$MAKE_ARGS"
alias m="make"
alias mc="make clean"
alias md="make distclean"
alias mi="make install"
alias mk="make"
alias mr="make run"

alias gdb="gdb -silent"

alias maketags="etags *.cc *.c *.hh *.h ../include/*.hh ../include/*.h"
alias showincludes="grep -h -e\"^#include\" *.c *.cpp *.C *.cxx *.CPP *.h *.hh *.hxx *.H 2>/dev/null | sort | uniq"
alias eall="edit *.cpp *.h"

