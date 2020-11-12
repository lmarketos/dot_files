#! /bin/bash

# NOTE: This file is for suggesting bash functions that some people might find
#       helpful, but which should not be imposed on everyone by default.
#       Either copy-paste stuff you want into your .bash/custom/*.bash scripts,
#       or else comment out this line if you want to use everything in this file.
return


# Use these functions to add color to make/scons output
# First have to delete the standard aliases
if [[ "`alias | grep 'alias mk='`" != "" ]]; then
    unalias mk;
    unalias mi;
fi
FUNC_HELP_mk=( 'run "make" and color output with $HOME/.colorgcc.sed' '' )
function mk() { make -j4 $* 2>&1 | sed -rf $HOME/.colorgcc.sed
}
FUNC_HELP_mi=( 'run "make install" and color output with $HOME/.colorgcc.sed' '' )
function mi() { make -j4 $* install 2>&1 | sed -rf $HOME/.colorgcc.sed
}
FUNC_HELP_cmk=( 'run "make" with ccache and color output with $HOME/.colorgcc.sed' '' )
function cmk() { CXX="ccache g++" CC="ccache cc" mk $*
}
FUNC_HELP_cmi=( 'run "make install" with ccache and color output with $HOME/.colorgcc.sed' '' )
function cmi() { CXX="ccache g++" CC="ccache cc" mi $*
}
FUNC_HELP_sk=( 'run "scons" and color output with $HOME/.colorgcc.sed' '' )
function sk() { scons "$@" 2>&1 | sed -rf $HOME/.colorgcc.sed
}
FUNC_HELP_sf=( 'run scons with flags optimized for speed (use with caution), and color output with $HOME/.colorgcc.sed' '' )
function sf() { scons --implicit-deps-unchanged cots=ignore genHaves=0 "$@" 2>&1 | sed -rf $HOME/.colorgcc.sed
}


# Print number of entries after running 'll'
# First have to delete the standard 'll' alias
if [[ "`alias | grep 'alias ll='`" != "" ]]; then
        unalias ll
fi
FUNC_HELP_ll=( 'run "ll" and then print the total number of entries' '' )
function ll() {
    ls -l "$@"
    echo `ls -l "$@" 2>/dev/null | grep -v '^total' | wc -l`" entries"
}


FUNC_HELP_man=( 'Limit manpage width to 80 characters.' '' )
function man()
{
    if [[ -n "$COLUMNS" && "$COLUMNS" -lt "80" ]]; then
        /usr/bin/man -a "$@" ;
    else
        MANWIDTH=80 /usr/bin/man -a "$@" ;
    fi
}

FUNC_HELP_cd=( 'Wrapper around builtin cd command to support extra functionality'
$'usage: cd [ <dir> | <bookmark> | ,+ | [+ | ]+ ]

This is a wrapper around the "cd" command. It does everything the regular "cd"
command will do, and it adds support for a few extra things such as:
  * support for jumping to bookmarked directories (requires bm.py python script
    in your PATH)
  * replacing a string of commas with ../ (eg, "cd ,,," = "cd ../../../")
  * moving within directory history (similar to pushd/popd) by using the "[" and
    "]" keys (eg, "cd [[" moves 2 entries back in the stack, and "cd ]]]"
    moves 3 entries forward in the stack).
    It might be helpful to define this alias to print out the current
    directory history and put a "*" next to the current stack position:
      alias ds=\'for ((i=0; i<${#DIR_STACK[*]}; i++)); do s="  "; if [[ $i == $DIR_STACK_INDEX ]]; then s="* "; fi; echo "${s}$((i-DIR_STACK_INDEX)) ${DIR_STACK[i]}"; done\'
')
function cd () {

    # This is the number of directories to keep in the directory history stack
    local stackSize=20
    local newDir=""
    local newIndex=""

    # if $1 is just a string of [, go back that many entries in DIR_STACK
    if [[ "`expr match \"$1\" '\[\+$'`" != 0 ]]; then
        newIndex=$(($DIR_STACK_INDEX + `echo $1 | wc -m` - 1))
    # if $1 is just a string of ], go forward that many entries in DIR_STACK
    elif [[ "`expr match \"$1\" '\]\+$'`" != 0 ]]; then
        newIndex=$(($DIR_STACK_INDEX - `echo $1 | wc -m` + 1))
    # if $1 is just a string of commas, replace each comma with "../"
    elif [[ "`expr match \"$1\" ',\+$'`" != 0 ]]; then
        newDir="`echo $1 | sed -e 's:,:../:g'`"
    # check if this is a bookmark
    else
        # Pass all options on to the python script and get the script output
        local output=`bm.py $* 2>/dev/null`
        #echo $output

        # if the script output is a "cd" command, then execute the command
        if [[ "`echo $output | cut -f1 -d ' '`" == "cd" ]]; then
            newDir="`echo $output | cut -d ' ' -f2`"
        fi
    fi

    # bounds checking on newIndex
    if [[ -n "$newIndex" ]]; then
        if [[ $newIndex < 0 ]]; then
            newIndex=0
        elif [[ $newIndex -ge ${#DIR_STACK[*]} ]]; then
            newIndex=$((${#DIR_STACK[*]}-1))
        fi
        newDir=${DIR_STACK[$newIndex]/#\~/$HOME}  # replace leading '~' with $HOME
    fi

    if [[ -n "$newDir" ]]; then
        # execute the modified command
        builtin cd $newDir
        rv=$?
    else
        # the given args weren't modified, so just execute the original command
        builtin cd "$@"
        rv=$?
    fi

    if [[ "$rv" != 1 ]]; then
        if [[ -z "$newIndex" ]]; then
            # put pwd on the top of the stack and shift everything else down one
            for ((i=${#DIR_STACK[*]}; i>0; i--)); do
                DIR_STACK[i]="${DIR_STACK[$((i-1))]}"
            done
            DIR_STACK[0]="`echo ${PWD/#$HOME/~}`"  # replace leading $HOME with '~'
            # enforce maximum stack size by truncating to $stackSize
            DIR_STACK=("${DIR_STACK[@]:0:$stackSize}")
            export DIR_STACK
            export DIR_STACK_INDEX=0
        else
            export DIR_STACK_INDEX=$newIndex
        fi
    fi

    return $rv
}
