#!/bin/bash

dcop kmix > /dev/null 2>&1
running=$?

if [ 0 -eq "$running" ]; then

    mixers=`dcop kmix | grep Mixer`

    for m in "$mixers"; do
        dcop kmix $m setMasterVolume 0
        for x in `seq 0 10`; do 
            dcop kmix $m setMute $x 1
            dcop kmix $m setVolume $x 0
        done
    done

else

    echo "kmix is not running!"
    
fi
