#!/bin/bash

wmctrl -a Thunderbird
if [ "0" -ne "$?" ]; then
    thunderbird &
fi
