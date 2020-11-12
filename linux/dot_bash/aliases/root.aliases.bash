#!/bin/bash

# only define these aliases if we are the 'root' user
if [[ $UID == 0 ]]; then
    alias rm='rm -iv'
    alias cp='cp -iv'
    alias mv='mv -iv'

    alias scanbus="cdrecord --scanbus"
fi

