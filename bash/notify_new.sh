#!/bin/bash

#put in /etc/profile.d

NOTIFY_ADDR="louis.g.marketos@lmco.com"
FROM_ADDR="louis.g.marketos@lmco.com"


LOG_USER="$( whoami )"
LOG_DATE="$( date "+%Y-%m-%d %H:%M:%S" )"
OUT_WHO="$( who )"
LOG_IP="$( echo ${SSH_CLIENT} | awk '{ print $1}' )"

if ! [ -z "$LOG_IP" ]; then
	FULL_GEO_LOC="$( geoiplookup ${LOG_IP} )"
	GEO_LOC="$( geoiplookup ${LOG_IP} | awk '{$1=$2=$3=$4=$5=""; print $6 $7 $8 $9 $10}' | sed -n 2p )"
else
	FULL_GEO_LOC="Unknown"
	GEO_LOC="Unknown"
fi

# if this is an interactive shell and we were able to capture an IP address, then proceed
#if ! [ -z "$PS1" ] && ! [ -z "$LOG_IP" ]; then

# if this user and IP address combination is not present in our logs
#if ! [[ $(last $LOG_USER -i |grep -v still |grep $LOG_IP) ]]
#then

DISPLAY=:0 notify-send "Login from \
User:   ${LOG_USER}; Host:   $(hostname); \
IP:	${LOG_IP}\
"
#fi
##fi

