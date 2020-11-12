#! /bin/bash
#
# Author: Dale Rowley
#
# Usage: Run with -h for instructions
#

if [[ $# == 0 || $1 == "-h" ]]; then
    echo "Usage: "`basename $0`" <files_to_add>"
    echo
    echo "  This script provides a GUI for incrementally staging changes in one or more files."
    echo "  In other words, this script is a GUI version of the 'git add --patch' functionality."
    echo

    exit 1
fi

DIFF_EXUCUTABLE=`which meld`


unset staged
unset temp
function cleanup()
{
    if [ -n "$staged" ]; then
        rm -f "$staged"
    fi
    if [ -n "$temp" ]; then
        rm -f "$temp"
    fi
}
trap cleanup EXIT KILL


for f in "$@"; do

    if [[ ! -f $f ]]; then
        echo "File '"$f"' not found. Skipping..."
        continue
    fi

    # determine if this file is tracked or not
    git ls-files --error-unmatch "$f" > /dev/null 2>&1
    tracked=$?

    if [ "0" -eq "$tracked" ]; then
        # This file is tracked / known to git

        # get the version of the file that is currently staged
        staged=`mktemp -t __staged__.XXX`
        full_f=`git ls-files --full-name "$f"`
        git show ":0:$full_f" >> "$staged"

        echo "------------------------------------------------------------"
        echo "interactive add for tracked file $f"
        echo "    Modify $staged version with changes to be staged in the index"
        echo "    To abort, just leave $staged unchanged"
        echo
        
        # compare the staged version to the working version, and let the user
        # edit the staged version
        $DIFF_EXUCUTABLE "$f" "$staged"
        
        # move the working file aside temporarily
        temp=`mktemp -t __temp__.XXX`
        cat "$f" >> "$temp"
        
        # replace the working file with the new version to be staged, and then
        # add it to the index
        mv "$staged" "$f"
        git add "$f"
        
        # put the original working file back into place
        mv "$temp" "$f"
    else
        # This file is not tracked / unknown to git.  Maybe it would be
        # inappropriate to add the entire file at this time, so give the user
        # a blank file to copy & paste content into.
        
        staged=`mktemp -t __staged__.XXX`

        echo "------------------------------------------------------------"
        echo "interactive add for untracked file $f"
        echo "    Copy & paste content you wish to add into ${staged}"
        echo "    To abort, leave $staged blank"
        echo
        
        # compare the staged version to the working version, and let the user
        # edit the staged version
        $DIFF_EXUCUTABLE "$f" "$staged"
        
        if [ -s "$staged" ]; then
            temp=`mktemp -t __temp__.XXX`
            mv "$f" "$temp"
            mv "$staged" "$f"
            git add "$f"
            mv "$temp" "$f"
        else
            rm -f "$staged"
        fi
    fi
done

echo "------------------------------------------------------------"
echo "You may examine differences between HEAD and the index with"
echo "    git diff --cached"
echo

cleanup
