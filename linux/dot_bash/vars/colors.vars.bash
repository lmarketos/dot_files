#!/bin/bash

# grouped by the escape sequence number
#        VARIABLE NAME                          COLOR ESCAPE SEQUENCE
colors=( 'BLACK'                                '\e[0;30m'
         'RED'                                  '\e[0;31m'
         'GREEN'                                '\e[0;32m'
         'YELLOW'                               '\e[0;33m'
         'BLUE'                                 '\e[0;34m'
         'PURPLE'                               '\e[0;35m'
         'CYAN'                                 '\e[0;36m'
         'LIGHT_GRAY'                           '\e[0;37m'

         'BROWN'                                '\e[38;5;130m'
         'ORANGE'                               '\e[38;5;202m'
         'SLATE_BLUE'                           '\e[38;5;99m'

         'GRAY'                                 '\e[1;30m'
         'LIGHT_RED'                            '\e[1;31m'
         'LIGHT_GREEN'                          '\e[1;32m'
         'LIGHT_YELLOW'                         '\e[1;33m'
         'LIGHT_BLUE'                           '\e[1;34m'
         'LIGHT_PURPLE'                         '\e[1;35m'
         'LIGHT_CYAN'                           '\e[1;36m'
         'WHITE'                                '\e[1;37m'

         'BOLD_BROWN'                           '\e[1;38;5;130m'
         'BOLD_ORANGE'                          '\e[1;38;5;202m'
         'BOLD_SLATE_BLUE'                      '\e[1;38;5;99m'

         'UNDERLINE_BLACK'                      '\e[4;30m'
         'UNDERLINE_RED'                        '\e[4;31m'
         'UNDERLINE_GREEN'                      '\e[4;32m'
         'UNDERLINE_YELLOW'                     '\e[4;33m'
         'UNDERLINE_BLUE'                       '\e[4;34m'
         'UNDERLINE_PURPLE'                     '\e[4;35m'
         'UNDERLINE_CYAN'                       '\e[4;36m'
         'UNDERLINE_WHITE'                      '\e[4;37m'

         'BACKGROUND_BLACK'                     '\e[40m'
         'BACKGROUND_RED'                       '\e[41m'
         'BACKGROUND_GREEN'                     '\e[42m'
         'BACKGROUND_YELLOW'                    '\e[43m'
         'BACKGROUND_BLUE'                      '\e[44m'
         'BACKGROUND_PURPLE'                    '\e[45m'
         'BACKGROUND_CYAN'                      '\e[46m'
         'BACKGROUND_WHITE'                     '\e[47m'

         'NORMAL'                               '\e[0m'
         'NO_COLOR'                             '\e[0m'
         'RESET_COLOR'                          '\e[39m' )


case $TERM in
    xterm*|linux*|screen*|console*|rxvt*|eterm-color)
        have_color_term=1
        ;;
    *)
        have_color_term=0
        ;;
esac

for (( i=0; i < ${#colors[*]}; i=i+2 )); do
    if [[ $have_color_term == 1 ]]; then
        j=$((i+1))
        eval "${colors[i]}='${colors[j]}'"
    else
        eval "${colors[i]}=''"
    fi
done

unset colors have_color_term
