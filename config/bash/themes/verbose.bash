#! /bin/bash
#
# This script sets the titlebar and tab text using the pretty_pwd() function. It
# also sets the prompt (PS1) to a 2-line prompt (see details below). Users can
# customize the PWD_COLOR, USER_COLOR, HOST_COLOR, and PROMPT_CHAR by setting
# these variables before sourcing this script.

PROMPT_COMMAND='pretty_pwd 15 2>/dev/null; name_tb "\u@\h:\w" 2>/dev/null; ns "$newPWD" 2>/dev/null'

if [[ -z "$HOST_COLOR" ]]; then
    HOST_COLOR="`str2color $HOSTNAME`"
fi

if [[ -z "$PWD_COLOR" ]]; then
    PWD_COLOR="$SLATE_BLUE"
fi

if [[ -z "$PROMPT_CHAR" ]]; then
    PROMPT_CHAR=">"
fi

# If logged in as root, always use RED for the USERCOLOR
if [[ $UID == 0 ]]; then
    USER_COLOR="${RED}"
elif [[ -z "$USER_COLOR" ]]; then
    USER_COLOR="${NO_COLOR}"
fi

cwd="\[$PWD_COLOR\]\w"
timestamp="\[${NO_COLOR}\]\t"
hist_num="\[${NO_COLOR}\][\!]"
exit_code="\[${RED}\]\$(echo \"\${PIPESTATUS[@]} \" | sed -e 's/^0 \$//')"
veh_name="\[${NO_COLOR}\]\$LMAS_SYSTEM_NAME"
user="\[${USER_COLOR}\]\u\[${NO_COLOR}\]"
host="\[${HOST_COLOR}\]\h"
login=$user@$host
if [[ -z $SSH_CONNECTION ]]; then
    login=""
fi
git_branch="\[$PURPLE\]\$(__git_ps1)"
prompt_char="\[${GREEN}\]$PROMPT_CHAR \[${NO_COLOR}\]"

# 2-line prompt that looks like this:
# PWD TIMESTAMP [HISTORY#] EXIT_CODE $LMAS_SYSTEM_NAME $USER@HOST GIT_BRANCH
# >
#
# NOTE: The exit code of the last executed command (or the codes of all the
# commands in the last pipe command) are displayed only if non-zero
export PS1="$cwd $timestamp $hist_num $exit_code$veh_name $login $git_branch\n$prompt_char"
export PS2="cont>"
