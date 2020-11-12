#! /bin/bash


export MAKE_ARGS="-r"
num_cpus="`grep -e ^processor /proc/cpuinfo | wc -l`"
if [[ "$num_cpus" -gt "1" ]]; then
    export MAKE_ARGS="-j $num_cpus $MAKE_ARGS"
fi

unset QTDIR
unset QMAKESPEC
if [[ $IS_64_BIT && -d "/usr/lib64/qt4" ]]; then
    export QTDIR=/usr/lib64/qt4
elif [[ -d "/usr/lib/qt4" ]]; then
    export QTDIR=/usr/lib/qt4
elif [[ -d "/usr/lib/qt3" ]]; then
    export QTDIR=/usr/lib/qt3
fi
if [[ -n "$QTDIR" &&  -d "$QTDIR/mkspecs/default" ]]; then
    export QMAKESPEC=$QTDIR/mkspecs/default
fi

export GIT_EDITOR=vi

# This is often used in setting the bash prompt ($PS1)
export USER=`whoami`
# TODO: document what these are used for and when RUN_AS_USER might != USER
export RUN_AS_USER=$USER
export RUN_AS_USER_HOME=$HOME


# default umask is set in core.vars.bash, so override it if we're logged into
# one of our servers: default to rw access for 'perceptek' group
servers="lit3ski lit3ski.vs.lmco.com"
for s in $servers; do
    if [[ "$s" == "$HOSTNAME" && "perceptek" == "`id -ng`" ]]; then
        umask 017
        break
    fi
done
unset servers


# Base directory where we store LMAS build products, runtime-generated files,
# config files, system input data files, etc.
# NOTE: These variables are used to customize the behavior of the functions in
# Lmas/Core/Env.h, and should only be uncommented if the default values
# (represented below) are inappropriate.
#export LMAS_BASE_DIR="$HOME/local"
#export LMAS_COTS_DIR="$LMAS_BASE_DIR/cots"
#export LMAS_DATA_DIR="$LMAS_BASE_DIR/data"
#export LMAS_PARAMS_DIR="$LMAS_BASE_DIR/etc"
#export LMAS_VAR_DIR="$LMAS_BASE_DIR/var"

# Lmas/Core/Env.h assumes this defaults to "sim", but declare it
# anyway because it is used in other bash functions, aliases, etc.
export LMAS_SYSTEM_NAME="sim"

if [[ -f "$HOME/.lmas_system_name" ]]; then
    export LMAS_SYSTEM_NAME=`head --lines=1 $HOME/.lmas_system_name`
fi
