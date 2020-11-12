#!/bin/bash

# -----------------------------------------------------------------------
#
# Copyright 2008 Lockheed Martin Corporation.
#
# Author: Dale Rowley, mods by Jeremy Nett
#
# Notes: 
#
# -----------------------------------------------------------------------


# $ man git
# ...
# GIT_EXTERNAL_DIFF
#     When the environment variable GIT_EXTERNAL_DIFF is set, the program named by it is called, instead of
#     the diff invocation described above. For a path that is added, removed, or modified, GIT_EXTERNAL_DIFF
#     is called with 7 parameters:
#
#
#         path old-file old-hex old-mode new-file new-hex new-mode
#     where:
#
#     <old|new>-file   are files GIT_EXTERNAL_DIFF can use to
#                      read the contents of <old|new>,
#     <old|new>-hex    are the 40-hexdigit SHA1 hashes,
#     <old|new>-mode   are the octal representation of the
#                      file modes.
#
#     The file parameters can point at the user's working file (e.g. new-file in "git-diff-files"), /dev/null
#     (e.g. old-file when a new file is added), or a temporary file (e.g. old-file in the index).
#     GIT_EXTERNAL_DIFF should not worry about unlinking the temporary file --- it is removed when
#     GIT_EXTERNAL_DIFF exits.
#
#     For a path that is unmerged, GIT_EXTERNAL_DIFF is called with 1 parameter, <path>.
# ...



# display a message to the user
function do_msg()
{
    echo "$@"
    
    if [ -n "$GIT_DIFF_DIALOG" ]; then
        for x in "$@"; do
            $GIT_DIFF_DIALOG --title "diff" --msgbox "$x" 0 0 
        done
    else
        read -p "Press enter to continue:"
    fi
}



# do a difference between files
function exec_diff()
{
    # $1 : path
    # $2 : old filename
    # $3 : new filename

    p=`pwd`
    repo=`basename "$p"`

    # make a "nicely named" tempoary file for "old" if necessary
    test_char=`echo "$2" | cut -b 1`
    local comp_name_old="$2"
    local rm_old_name
    local remove_old=0
    if [ "/" == "$test_char" ]; then

        # "old" is a repo version

        tmp=`mktemp -t -d git.OLD.XXX`
        rm_old_name=$tmp
        tmp=${tmp}/${repo}/${1}

        d=`dirname "$tmp"`
        mkdir -p "$d"

        cp "$2" "$tmp"
        chmod 400 "$tmp"

        comp_name_old="$tmp"
        remove_old=1
    fi

    # make a "nicely named" tempoary file for "new" if necessary
    test_char=`echo "$3" | cut -b 1`
    local comp_name_new="$3"
    local rm_new_name
    local remove_new=0
    if [ "/" == "$test_char" ]; then

        # "new" is a repo version

        tmp=`mktemp -t -d git.NEW.XXX`
        rm_new_name=$tmp
        tmp=${tmp}/${repo}/${1}

        d=`dirname $tmp`
        mkdir -p "$d"

        cp "$3" "$tmp"
        chmod 400 "$tmp"

        comp_name_new="$tmp"
        remove_new=1
    fi

    # do the actual diff
    $GIT_DIFF_EXECUTABLE "$comp_name_old" "$comp_name_new"

    # cleanup
    if [ "1" -eq "$remove_old" -a -n "$rm_old_name" ]; then
        rm -rf "$rm_old_name"
    fi

    if [ "1" -eq "$remove_new" -a -n "$rm_new_name" ]; then
        rm -rf "$rm_new_name"
    fi
}



if [[ $# -eq 7 ]]; then

    # program to use for displaying messages, if any
    if [ -n "$DISPLAY" ]; then

        # prefer kdialog if running under X+KDE
        if [ -z "$GIT_DIFF_DIALOG" ]; then
            if [ "true" == "$KDE_FULL_SESSION" ]; then
                loc=`which kdialog 2> /dev/null`
                if [ "0" -eq "$?" ]; then
                    export GIT_DIFF_DIALOG=$loc
                fi
            fi
        fi

        # ... then Xdialog if under X
        if [ -z "$GIT_DIFF_DIALOG" ]; then
                loc=`which Xdialog 2> /dev/null`
                if [ "0" -eq "$?" ]; then
                    export GIT_DIFF_DIALOG=$loc
                fi
        fi
    else

        # not X; see if dialog is available
        loc=`which dialog 2> /dev/null`
        if [ "0" -eq "$?" ]; then
            export GIT_DIFF_DIALOG=$loc
        else
            unset GIT_DIFF_DIALOG
        fi
    fi
    
    # program to use for GIT diffs (not a git env var, used by gitdiff.sh)
    if [ -n "$DISPLAY" ]; then
        # prefer meld, xxdiff, then diff in this order when running under X
        
        if [ -z "$GIT_DIFF_EXECUTABLE" ]; then
            loc=`which meld 2> /dev/null`
            if [ "0" -eq "$?" ]; then
                export GIT_DIFF_EXECUTABLE=$loc
            fi
        fi
        
        if [ -z "$GIT_DIFF_EXECUTABLE" ]; then
            loc=`which xxdiff 2> /dev/null`
            if [ "0" -eq "$?" ]; then
                export GIT_DIFF_EXECUTABLE=$loc
            fi
        fi
        
        if [ -z "$GIT_DIFF_EXECUTABLE" ]; then
            export GIT_DIFF_EXECUTABLE=diff                
        fi
    else
        export GIT_DIFF_EXECUTABLE=diff
    fi
    
    # if all else fails, use plain old diff
    if [ -z "$GIT_DIFF_EXECUTABLE" ]; then
        export GIT_DIFF_EXECUTABLE=diff                
    fi      

    # print out what we are doing
    echo "Comparing:"
    echo "  path : "$1
    echo "  old  : "$2" hash "$3" mode "$4
    echo "  new  : "$5" hash "$6" mode "$7
    echo "  tool : "$GIT_DIFF_EXECUTABLE" (env var GIT_DIFF_EXECUTABLE)"
    echo

    do_diff=1

    # if new, renamed, deleted, tell the user
    if [ "/dev/null" == "$2" ]; then
        do_msg "\"old\" of $1 does not exit (new file, renamed, deleted, ...)"
        do_diff=0
    fi

    if [ "/dev/null" == "$5" ]; then
        do_msg "\"new\" of $1 does not exit (new file, renamed, deleted, ...)"
        do_diff=0
    fi

    # if a permissions change, tell the user
    if [ "$4" != "$7" -a "." != "$4" -a "." != "$7" ]; then
        do_msg "$1: permissions changed from $4 to $7"
    fi

    if [ "0" -ne "$do_diff" ]; then
        diff -q "$2" "$5" > /dev/null 2>&1
        if [ "0" -eq "$?" ]; then
            do_diff=0
        fi
    fi

    if [ "0" -ne "$do_diff" ]; then

        diff -B -b -w -q "$2" "$5" > /dev/null 2>&1
        if [ "0" -eq "$?" ]; then
            do_msg "$1: whitespace changes only"
            do_diff=0
        fi
    fi
    
    # content changed, do a full diff
    if [ "1" -eq "$do_diff" ]; then
        exec_diff "$1" "$2" "$5"
    fi

    echo "------------------------------------------------------------------------------"
    echo
    echo

    exit 0
fi

exit -1
