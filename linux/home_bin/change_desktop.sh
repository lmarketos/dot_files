#!/bin/sh
dcop kwin KWinInterface currentDesktop > $HOME/.last_desktop;
case $1 in
    n ) dcop kwin KWinInterface nextDesktop ;;
    p ) dcop kwin KWinInterface previousDesktop ;;
    * ) dcop kwin KWinInterface setCurrentDesktop $1 ;;
esac
