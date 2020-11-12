#! /bin/bash
# TODO: Better documentation for these functions


FUNC_HELP_convert_images=( 'batch convert format of images' '' )
function convert_images()
{
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Usage: convert_images <extension from> <extension to>"
        echo "Example: to convert bmp images to ppm images --"
        echo "convert_images bmp ppm"
        return -1
    else
        local search_for="*."$1
        for x in `ls $search_for`; do
            local base=`basename $x "."$1`
            convert $base"."$1 $base"."$2
        done
    fi
}



FUNC_HELP_line=( 'show a specific line number from a file' '' )
function line()
{
    if [[ $# -ne 2 ]]; then
        echo "Usage: line [line] [file]"
        echo "       line [startline,endline] [file]"
        echo
        return 1
    fi
    local arg="$1!d $2"
    sed $arg
    return 0
}


FUNC_HELP_line=( 'Append a timestamped record using the given message to $LOG_FILENAME'
'usage: log <message>' )
function log()
{
    if [[ -n "$LOG_FILENAME" ]]; then
        stamp=`date`
        user=`whoami`
        host=$HOSTNAME

        if [[ ! -f "$LOG_FILENAME" ]]; then
            echo '-*- mode: text; -*-' > $LOG_FILENAME
            echo >> $LOG_FILENAME
            echo >> $LOG_FILENAME
        fi

        echo "$stamp ($user@$host) >> ""$@" >> $LOG_FILENAME
        echo >> $LOG_FILENAME
    fi
}



FUNC_HELP_new=( 'find the newest entry in the current directory; if a file, run $PAGER on it; if a directory, cd into it' '' )
function new()
{
    f=`ls -1Atr | tail --lines=1`

    if [[ -d "$f" ]]; then
        cd "$f"
    else
        $PAGER "$f"
    fi
}



FUNC_HELP_random=( 'get a random number' '' )
function random()
{
    if [[ -n "$1" ]]; then
        echo $(( $RANDOM % $1 ))
    else
        echo $RANDOM
    fi
}



FUNC_HELP_random_pwd=( 'return a random password' '' )
function random_pwd()
{
    head -c8 /dev/random | uuencode -m - | sed -n '2s/=*$//;2p'
}



FUNC_HELP_str2color=( 'Map the given string to a color'
$'usage: str2color <some_string>

Map the given string to a color (using the string md5sum) and print the
escape sequence for that color. Useful to get a random, but consistent, color
for an arbitrary string (eg, color for the hostname in PS1 command prompt' )
function str2color() {
    # bc doesn't understand lowercase digits, so convert to uppercase
    local md5=`echo -n $1 | md5sum | cut -f1 -d ' ' | tr [:lower:] [:upper:]`

    # Convert the md5 into an integer between 20-231 (in 256-color terminals,
    # colors 0-15 are redundant with 16-231, colors 16-20 are too dark, and
    # colors 232+ are grayscale colors)
    local int="`bc <<< \"ibase=16; $md5\"`"
    local int="`bc <<< \"scale=0; $int % 211 + 20\"`"
    echo "\e[38;5;${int}m"
}
