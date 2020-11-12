#! /bin/bash

# set the shell prompt -- complex (with color, x term titlebar, etc.)
function setprompt_complex()
{
    # note - the emacs terminal is eterm

    if [[ "$INTERACTIVE" == "0" ]]; then
        return
    fi

    # set titlebar to user@host:pwd
    name_tb "\u@\h:\w"


    local TTY_DISP=""
    if [[ "linux" = "$TERM" && -z "$WINDOWID" && "localhost" = "$LOGGED_IN_FROM" ]]; then
        TTY_DISP="("`tty | sed 's/^\/dev\///'`")"
    fi

    if [[ 0 == $UID ]]; then
        local USERNAME_COLOR=${LIGHT_RED}
        local PROMPT_CHAR_COLOR=${LIGHT_RED}
    else
        local USERNAME_COLOR=`str2color $USER`
        local PROMPT_CHAR_COLOR=${NO_COLOR}
    fi

    local MACHINE_COLOR=`str2color $HOSTNAME`

    local PWD_SEQ='${newPWD} '

    export PS1="${TTY_DISP} \$? ${TITLEBAR}\[${NO_COLOR}\][\!] [ \[${USERNAME_COLOR}\]\u\[${NO_COLOR}\]@\[${MACHINE_COLOR}\]\h\[${NO_COLOR}\] ${PWD_SEQ}] \[${PROMPT_CHAR_COLOR}\]\\$ \[${NO_COLOR}\]"
    export PS2='cont>'

    if [[ -n "$WINDOWID" ]]; then
        export PROMPT_COMMAND="pretty_pwd 2>/dev/null ; ns 2>/dev/null"
    else
        export PROMPT_COMMAND="pretty_pwd 2>/dev/null"
    fi
}

setprompt_complex
