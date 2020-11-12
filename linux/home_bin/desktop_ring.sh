#!/bin/bash

if [ "true" != "$KDE_FULL_SESSION" ]; then
    echo "ERROR -- you must be running KDE to use this script"
    exit -1
fi

desktop_ring_fname=$HOME/.desktop_ring
current_desktop_ring_fname=$HOME/.desktop_ring_line

if [ ! -f "$desktop_ring_fname" ]; then
    echo "ERROR -- no desktop ring setup; add desktop numbers in"
    echo $desktop_ring_fname
    exit -1
fi

nlines=`cat $desktop_ring_fname | wc -l`

if [ ! -f "$current_desktop_ring_fname" ]; then

    new_line=1

else

    cur_line=`cat $current_desktop_ring_fname`
    let new_line="$cur_line + 1"

    if [ "$new_line" -gt "$nlines" ]; then
        new_line=1
    fi

fi


echo $new_line > $current_desktop_ring_fname

arg="$new_line!d $desktop_ring_fname"
desktop_num=`sed $arg`

dcop kwin KWinInterface setCurrentDesktop $desktop_num
