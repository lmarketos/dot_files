#! /bin/bash

# set prompt to simple "PWD $/# " where # is used if root, $ otherwise
export PS1="\w \\$ "
export PS2='cont>'

unset PROMPT_COMMAND
export PROMPT_COMMAND
