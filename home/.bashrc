#!/bin/bash

# Uncomment this to get very verbose debugging output.
#set -x

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

tmp=${XDG_CONFIG_HOME:="$HOME/.config"}
tmp=${XDG_BIN_HOME:="$HOME/.local/bin"}
export XDG_BIN_HOME
export XDG_CONFIG_HOME

PATH="$XDG_BIN_HOME:$PATH"
export PATH

MY_BASH="$XDG_CONFIG_HOME/bash.d"

# Default to use the basic theme. This can be overridden by sourcing a different
# theme from within your own $BASH/custom/*.bash script.
#
# IMPORTANT: Do not modify this line to source a different theme because most
# themes depend on functions that have yet to be sourced in the loop below.
source $MY_BASH/themes/basic.bash

# Load functions first so they can be used to set other things up.
# Then load environment variables since other things may depend on them.
# Load custom stuff last so it can override anything else.
# Don't process the themes dir - scripts from that dir should be sourced from
# a $BASH/custom/*.bash script.
dirs="functions vars aliases completion keybinds custom"

for dir in $dirs; do
    my_scripts="$(ls -1 ${MY_BASH}/$dir/*.bash 2>/dev/null)"

    for my_config_file in $my_scripts; do
        source $my_config_file
    done
done

unset my_config_file
unset my_scripts
unset dir
unset dirs
unset source
unset MY_BASH

