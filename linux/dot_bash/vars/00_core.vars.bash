#! /bin/bash

if [[ ! -d "$HOME" ]]; then
    echo "*** ERROR -- home directory ($HOME) does not exist!"
fi

# determine if this is an interactive (user input) instance or not
unset INTERACTIVE
case "$-" in
    *i*) export INTERACTIVE=1 ;;
    *) export INTERACTIVE=0 ;;
esac

if [[ "$INTERACTIVE" == "1" ]]; then
    if [[ "$EMACS" != "t" ]]; then
        # Turn off the annoying bells
        if [[ -n "$WINDOWID" ]]; then
            xset b off
        fi
        setterm -blength 0 > /dev/null 2>&1
        bind "set bell-style none"
    fi
fi

if [[ -f "$HOME/.bashrc_silent" ]]; then
    export BASHRC_VERBOSE=0
else
    export BASHRC_VERBOSE=1
fi

IS_64_BIT=
if [[ "`uname -m`" == "x86_64" ]]; then
    IS_64_BIT=1
fi

if [[ -z "$TMPDIR" && -d /tmp ]]; then
    export TMPDIR=/tmp
fi

if [[ -z "$XENVIRONMENT" ]]; then
    export XENVIRONMENT="$HOME/.Xdefaults"
fi

unset CDPATH
unset SESSION_NAME                      # used in the ns() function to set terminal tab title

export PAGER="less"
export MANPAGER="less"

export EDITOR="edit"
export FCEDIT="edit"
export XEDITOR="edit"

export LC_ALL=C                         # this affects the 'sort' utility's output, among other random things

# grep config
unset GREP_COLOR
unset GREP_COLOR_OPT
if [[ "$TERM" != "dumb" ]]; then
    export GREP_COLOR='1;31'
    export GREP_COLOR_OPT='--color=auto'
fi
# file patterns to exclude
GREP_EXCLUDE_OPT='--exclude=\*~\* --exclude=core --exclude=core.[0-9]\* --exclude=vgcore --exclude=vgcore.[0-9]\* --exclude=\.\#\* --exclude=\#\*\#'
GREP_DEVICE_OPT='--devices=skip'        # what to do for devices, FIFOs, sockets

# form up GREP_OPTIONS
export LMAS_GREP_OPTIONS="$GREP_COLOR_OPT $GREP_EXCLUDE_OPT $GREP_DEVICE_OPT"
unset GREP_COLOR_OPT
unset GREP_EXCLUDE_OPT
unset GREP_DEVICE_OPT

# Set the LS_COLORS variable based on $HOME/.dir_colors contents
if [[ -f $HOME/.dir_colors ]]; then
    eval `dircolors -b $HOME/.dir_colors`
fi
export LS_OPTIONS="--time-style=long-iso "
if [[ "$TERM" != "dumb" ]]; then
    export LS_OPTIONS="$LS_OPTIONS --color=auto"
fi

export HOSTFILE=/etc/hosts              # bash uses this for completion of hostnames

# Memory and disk space is cheap, so it's often useful to keep a lot of history.
# To disable history, set HISTFILE="" and HISTSIZE=0.
export HISTFILE="$HOME/.bash_history"       # tell bash where to store the history of shell commands
export HISTCONTROL=ignoreboth               # tell bash to not remember duplicate lines or lines beginning with whitespace
export HISTSIZE=50000                       # tell bash to keep this many lines in the command history (default is 500)
export HISTFILESIZE=50000                   # tell bash to keep this many lines in the command history (default is 500)
export HISTTIMEFORMAT="[%F %T] "            # tell bash to record timestamps for each command in the history

# common less options
export LESS=" -M -I -X -C -R "
export LESSHISTFILE="-"                 # don't save history from less
export LESSHISTSIZE=0

export TMOUT=0                          # bash -- no automatic logout


# enable certain bash settings
shopt -s cdable_vars                # cd based on env vars
shopt -s cdspell                    # allow minor mispellings in the 'cd' command
shopt -s checkhash                  # check hash table before finding command
shopt -s checkwinsize               # check window size before executing command
shopt -s histverify                 # tell bash to allow user to verify history substitutions before executing them
shopt -s histappend                 # tell bash to append .bash_history when it exits instead of overwriting it
shopt -s no_empty_cmd_completion    # don't try to complete an empty line

# disable certain bash settings
shopt -u dotglob                    # disable matching filenames that begin with a '.'

if [[ $UID != 0 ]]; then
    shopt -s cdspell                # allow minor misspellings in the cd command
fi


# Set core file size limits; use soft to prevent ridiculous machine hang, by default
ulimit -Hc unlimited
ulimit -Sc 102400

# Set stack size limits
ulimit -Hs unlimited
ulimit -Ss unlimited

umask 037

