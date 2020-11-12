#! /bin/bash

# NOTE: This file is for suggesting aliases that some people might find helpful,
#       but which should not be imposed on everyone by default.
#       Either copy-paste stuff you want into your .bash/custom/*.bash scripts,
#       or else comment out this line if you want to use everything in this file.
return


# run the sshaliases() function generate aliases for logging into other machines
sshaliases

# Make it harder to accidentally delete/overwrite a file. NOTE: If you want to
# temporarily override an alias and run the original command, just put it in
# quotes. For example:
#       'rm' -rf *
alias rm="rm -iv"
alias mv="mv -iv"
alias cp="cp -iv"

alias gp="gnuplot"

# Kill the most recent job, assuming it was backgrounded with ctrl+z. Useful for
# killing processes that aren't responding to ctrl+c.
alias kp="kill -9 %1; fg"


# Some useful macros
# NOTE: Changing the keymap will erase all previous key bindings. You can
#       also set key bindings in ~/.inputrc.
bind "set keymap vi-insert"                 # use vi key mappings

bind 'TAB: menu-complete'                   # bind tab key to a different tab-completion behavior
bind '"\M-.": possible-completions'         # print a list of possible tab completions (useful with menu-complete)
bind '"\M-,": "../"'                        # make it easy to go up directory levels
bind '"\M-`": "cd\r"'                       # single keypress to go home
bind '"\M-y": "ls\r"'                       # single keypress to get dir listing
