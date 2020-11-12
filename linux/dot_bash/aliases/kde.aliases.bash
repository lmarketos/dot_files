#!/bin/bash

# KDE-specific aliases
alias check_mail="dcop kmail default checkMail"
alias email="dcop kmail default openReader"
alias k="konsole &"
alias kde_logout="dcop ksmserver default logout 0 -1 -1"
alias kde_logout_all="dcop --all-sessions --user $USER ksmserver default logout 0 -1 -1"
alias lock="dcop kdesktop KScreensaverIface lock"

