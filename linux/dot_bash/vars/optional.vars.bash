#! /bin/bash

# NOTE: This file is for suggesting environment variables or other general
#       bash settings that some people might find helpful, but which should not
#       be imposed on everyone by default.
#       Either copy-paste stuff you want into your .bash/custom/*.bash scripts,
#       or else comment out this line if you want to use everything in this file.
return


export CCACHE_DISABLE=foo                   # ccache: set to non-empty string to disable ccache
export CCACHE_LOGFILE=$HOME/ccache.log      # ccache: write log information

# add -f to prevent gvim from detaching from process because this causes
# problems when used as a cvs/git editor
export EDITOR="gvim -f"

export IGNOREEOF=1                          # hit Ctrl-D twice to exit

# Use vim as a pager
export GROFF_NO_SGR=1                       # fix problem with using vim for MANPAGER
export MANPAGER="sh -c \"col -b | view -R -c 'set ft=man nomod nolist titlestring=MANPAGE nospell' -\""
export PAGER="sh -c \"col -b | view -c 'set ft=man nomod nolist titlestring=MANPAGE nospell' -\""

export MAKE_MODE="UNIX"                     # cygwin

# Assuming miscellaneous python modules are stored in ~/bin/python/
add_PATH PYTHONPATH $HOME/bin/python
export PYTHONPATH

# set tab-width to 4 (default is 8) only do this for interactive shells
# because it causes a problem with scp
if [[ "$INTERACTIVE" == "1" ]]; then
    setterm -term linux -regtabs 4
fi

