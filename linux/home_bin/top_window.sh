#!/bin/bash
title=`echo $USER"@"$HOSTNAME" :: top"`
exec xterm +bc +sb -T "$title" -e top
