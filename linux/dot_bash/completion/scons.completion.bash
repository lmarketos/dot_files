#! /bin/bash

_complete_scons ()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    local worldlist=""

    # TODO: check for './SConstruct' first. If it doesn't exist then don't
    #       try to generate completions for SconsSetup build options.
    # TODO: provide completion for non-SconsSetup commandline options (ie,
    #       generic scons commandline options i.e. -u --implicit-cache)

    if [[ "${cur:0:8}" == "project=" ]]; then
        for x in */Build/*.py; do
            # extract just the base directory
            wordlist=$wordlist"  ${x/\/Build\/*/}"
        done
        COMPREPLY=( $(compgen -W "$wordlist" "$2") )
    else
        # run 'scons -h', extract lines that start with non-whitespace followed by a
        # colon (ie, options defined by the build system), remove the colon and
        # everything after it, and append a '='
        wordlist=$(`which scons` -h project=cal | grep '^[^ ]\+:' | grep -v '^scons:' | sed -e 's/:.*//;s/$/=/')
        COMPREPLY=( $(compgen -W "$wordlist" "$2") )
    fi

    return 0
}

complete -o nospace -F _complete_scons scons

