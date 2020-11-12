#! /bin/bash

which git_ssh > /dev/null 2>&1
if [[ "0" == "$?" ]]; then
    export GIT_SSH=git_ssh                  # 'git_ssh' is our script to strip out ssh banners when running git commands
fi
