#! /bin/bash

# set the shell prompt -- simple (no color, etc.)
function setprompt_simple()
{
    if [[ "$INTERACTIVE" == "0" ]]; then
        return
    fi

    name_tb xterm

    export PS1="\$? [\!] [ \u@\h \w ]\\$ "
    export PS2='cont>'

    unset PROMPT_COMMAND
    export PROMPT_COMMAND
}

setprompt_simple
