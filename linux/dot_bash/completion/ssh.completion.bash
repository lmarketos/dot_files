#!/bin/bash
# Bash completion support for ssh.
# Copied from bash-it:
#     http://github.com/revans/bash-it.git

# Don't process this script by default (see warning below). Comment this line if
# you want to use this script.
return


# WARNING: This line seems to cause problems with other custom tab-completion functions.
export COMP_WORDBREAKS=${COMP_WORDBREAKS/\:/}

_sshcomplete() {

    # parse all defined hosts from .ssh/config
    if [[ -r $HOME/.ssh/config ]]; then
        COMPREPLY=($(compgen -W "$(grep ^Host $HOME/.ssh/config | awk '{print $2}' )" -- ${COMP_WORDS[COMP_CWORD]}))
    fi

    # parse all hosts found in .ssh/known_hosts
    if [[ -r $HOME/.ssh/known_hosts ]]; then
        if grep -v -q -e '^ ssh-rsa' $HOME/.ssh/known_hosts ; then
        COMPREPLY=( $COMPREPLY $(compgen -W "$( awk '{print $1}' $HOME/.ssh/known_hosts | cut -d, -f 1 | sed -e 's/\[//g' | sed -e 's/\]//g' | cut -d: -f1 | grep -v ssh-rsa)" -- ${COMP_WORDS[COMP_CWORD]} ))
        fi
    fi

    return 0
}

complete -o default -o nospace -F _sshcomplete ssh
