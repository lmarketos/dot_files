#!/bin/bash

# Uncomment this to get very verbose debugging output.
#set -x

# Where to find the bash configuration scripts
BASH=$HOME/.bash

# Default to use the basic theme. This can be overridden by sourcing a different
# theme from within your own $BASH/custom/*.bash script.
#
# IMPORTANT: Do not modify this line to source a different theme because most
# themes depend on functions that have yet to be sourced in the loop below.
#source $BASH/themes/basic.bash

# Load functions first so they can be used to set other things up.
# Then load environment variables since other things may depend on them.
# Load custom stuff last so it can override anything else.
# Don't process the themes dir - scripts from that dir should be sourced from
# a $BASH/custom/*.bash script.
dirs="functions vars aliases completion custom"

for dir in $dirs; do
    scripts="$(ls -1 ${BASH}/$dir/*.bash 2>/dev/null)"

    for config_file in $scripts; do
        source $config_file
    done
done

unset config_file
unset scripts
