#!/bin/bash

if [ "true" != "$KDE_FULL_SESSION" ]; then
    echo "ERROR -- you must be running KDE to use this script"
    exit -1
fi

last_desktop_fname=$HOME/.last_desktop

current_desktop=`dcop kwin KWinInterface currentDesktop`

if [ -f "$last_desktop_fname" ]; then

    new_desktop=`cat $last_desktop_fname`

    dcop kwin KWinInterface setCurrentDesktop $new_desktop
fi

echo $current_desktop > $last_desktop_fname
