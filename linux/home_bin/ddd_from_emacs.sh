#!/bin/bash


unset bin
bincount=0


if [ -n "$1" ]; then
    bin=$1
    bincount=1
else
    
    for x in `ls -1`; do
        if [ -x "$x" -a ! -d "$x" ]; then
            good=`file $x | grep -c -e 'ELF [0-9]*-bit LSB executable' 2> /dev/null`
            if [ "$?" -eq "0" -a -n "$good" -a "$good" -gt "0" ]; then
                bin=$bin"./"$x" "
                let bincount="$bincount+1"
            fi
        fi
    done
fi

if [ "$bincount" -eq "0" ]; then
    echo "ERROR -- could not find any binary executables in the current directory"
    echo "pwd: "`pwd`
    exit -1
fi


if [ "$bincount" -gt "1" ]; then
    echo "ERROR -- could not find a unique binary executable in the current directory"
    echo "pwd: "`pwd`
    exit -1
fi


exec ddd $bin &
