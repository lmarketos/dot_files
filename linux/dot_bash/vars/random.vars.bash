#! /bin/bash

if [[ -f "$HOME/.bcrc" ]]; then
    export BC_ENV_ARGS="-l $HOME/.bcrc" # tell 'bc' to read this file when it starts up
fi

export BKUP_PERMISSIONS="u-w,g-w,o-w"   # used in the bkup() function


export CDR_DEVICE=1,0,0                 # device identifier for cdrecord -- see "cdrecord --scanbus"
export CDR_SPEED=40                     # recording speed for cdrecord

export LOG_FILENAME=$HOME/.log.txt      # file to use with the log() functin

if [[ -z "$KDIR" && -d "/usr/src/linux" ]]; then
    export KDIR=/usr/src/linux
fi

export MATLAB_USE_USERPATH=1

