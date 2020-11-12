#!/bin/sh
emacsclient -a emacs -e '(custom-make-frame)' &&
emacsclient -a emacs -e '(raise-frame)' && 
emacsclient -a emacs -e '(x-focus-frame nil)' &&
emacsclient -a emacs -e '(switch-to-buffer "*scratch*")'
exit $?

