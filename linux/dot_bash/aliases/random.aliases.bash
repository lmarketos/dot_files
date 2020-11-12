#!/bin/bash

# Base conversions
alias 2b='calc "a=base(2); $1"'
alias 2o='calc "a=base(8); $1"'
alias 2d='calc "a=base(10); $1"'
alias 2h='calc "a=base(16); $1"'


# misc
alias clock="xclock -d -update 1&"
alias dvd="xterm -e sudo mplayer -stop-xscreensaver -alang en dvd://1 -dvd-device /dev/dvd &"
alias ftp="ftp -i"
alias glade="glade-2 --show-widget-tree --show-clipboard"
alias hexdump="hexdump -v -C"
alias hosts="cat /etc/hosts"
alias kbd="sudo kbdrate -r 30.0 -d 250"
alias kermit="kermit $HOME/.kermrc_default"
alias link="ips"
alias lynx="lynx -accept_all_cookies -connect_timeout=10 -nopause"
alias ml="matlab -nodesktop -nosplash"
alias monitor_off="xset dpms force off"
alias nc="nc -noask "
alias syslog='if [ -r "/var/log/messages" ]; then tail --retry --follow=name --lines=200 /var/log/messages; else sudo tail --retry --follow=name --lines=200 /var/log/messages; fi'
alias sys="systemName"
alias yast="sudo -E yast"
alias yast2="sudo -E yast2"

