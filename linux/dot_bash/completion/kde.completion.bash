#! /bin/bash

# dcop completion
#
# Inputs:
#   $1 -- name of the command whose arguments are being completed
#   $2 -- word being completed
#   $3 -- ord preceding the word being completed
#   $COMP_LINE  -- current command line
#   $COMP_PONT  -- cursor position
#   $COMP_WORDS -- array containing individual words in the current
#                  command line
#   $COMP_CWORD -- index into ${COMP_WORDS} of the word containing the
#                  current cursor position
# Output:
#   COMPREPLY array variable contains possible completions
#
# dcop syntax:
#   dcop [ application [object [function [arg1] [arg2] [arg3] ... ] ] ]
#
_complete_dcop ()
{
    local wordlist

    COMPREPLY=()
    wordlist=""

    if (( $COMP_CWORD == 1 )); then
        #
        # Application. This one is easy, just return all names that dcop
        # gives us.
        #
        wordlist=$(dcop)
    elif (( $COMP_CWORD == 2 )); then
        #
        # Object. 'dcop <application>' returns all objects the application
        # supports plus (default). The parenthesis in (default) should be
        # omitted when using it as an argument so we need to remove them.
        #
        wordlist=$(dcop ${COMP_WORDS[1]} | sed -e "s,(default),default,")
    elif (( $COMP_CWORD == 3 )); then
        #
        # Function. 'dcop <application> <object>' returns functions of the
        # form 'type functionname(arguments)'. We need to return a list with
        # the functionnames.
        #
        wordlist=$(dcop ${COMP_WORDS[1]} ${COMP_WORDS[2]} | sed -e "s,.* \(.*\)(.*,\1,")
    fi

    COMPREPLY=( $(compgen -W "$wordlist" "$2") )
    return 0
}

complete -F _complete_dcop dcop



_complete_yast2 ()
{
    local nlines=`yast2 -l | wc -l`
    local x
    let x="$nlines-2"

    local wordlist=`yast2 -l | tail --lines=$x`

    COMPREPLY=( $(compgen -W "$wordlist" "$2") )
    return 0
}

complete -F _complete_yast2 yast2
