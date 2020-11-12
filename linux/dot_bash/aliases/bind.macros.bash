#! /bin/bash

# WARNING: Changing the keymap later on, for example:
#   bind "set keymap vi-insert"
# may erase the key bindings below.

if [[ "$INTERACTIVE" -ne "0" ]]; then
    # make up/down arrow keys search the history for the text that has been typed in so far
    bind '"\e[A": history-search-backward'
    bind '"\e[B": history-search-forward'

    # make tab-completion append a '/' to completions that are symlinks to directories
    bind "set mark-symlinked-directories on"

    # disable the stupid ctrl+s / ctrl+q (terminal flow control) commands (it
    # confuses many people when they accidentally press it and the terminal
    # stops responding to keypresses)
    stty stop ''
    stty start ''
    stty -ixon
    stty -ixoff
fi
