#! /bin/bash
# TODO: Better documentation for these functions



FUNC_HELP_desk=( 'switch to a desktop from the command line' '' )
function desk()
{
    if [[ ! -z "$1" ]]; then
        dcop kwin KWinInterface setCurrentDesktop $1
    fi
}



FUNC_HELP_desktop_view=( 'automagically visit desktops' '' )
function desktop_view()
{
    while true; do
        dcop kwin KWinInterface nextDesktop
        sleep 1
    done
}



FUNC_HELP_gg=( 'google from the command line under KDE' '' )
function gg()
{
    if [[ "true" = "$KDE_FULL_SESSION" ]]; then
        kfmclient newTab "gg:$*" > /dev/null 2>&1
    else
        echo "ERROR -- expecting KDE to be running"
    fi
}



FUNC_HELP_ggl=( 'google from the command line under KDE' '' )
function ggl()
{
    if [[ "true" = "$KDE_FULL_SESSION" ]]; then
        kfmclient newTab "ggl:$*" > /dev/null 2>&1
    else
        echo "ERROR -- expecting KDE to be running"
    fi
}



FUNC_HELP_ksaver=( 'KDE screensaver interaction, plus x-server DPMS options' '' )
function ksaver()
{
    if [[ "true" != "$KDE_FULL_SESSION" ]]; then
        echo "ERROR -- KDE not running, cannot interface with KDE's screen saver"
        return -1
    fi

    local show_status=0
    local function=$1

    case $function in
        status)
            show_status=1
            ;;

        off|disable)
            local result=`dcop kdesktop KScreensaverIface enable off`
            if [[ "0" -ne "$?" ]]; then
                echo "ERROR -- could not set KDE screen saver status to disable"
            else
                echo "Disabled KDE screen saver"
                show_status=1
            fi
            xset -dpms
            echo "Disabled energy star features (DPMS)"
            setterm -blank 0
            echo "Disabled blanking"
            setterm -powersave off
            echo "Disabled powersave"
            xset s off
            echo "Disabled x screensaver"
            ;;

        on|enable)
            local result=`dcop kdesktop KScreensaverIface enable on`
            if [[ "0" -ne "$?" ]]; then
                echo "ERROR -- could not set KDE screen saver status to enable"
            else
                echo "Enabled KDE screen saver"
                show_status=1
            fi
            xset +dpms
            echo "Enabled energy star features (DPMS)"
            setterm -blank 20
            echo "Enabled blanking"
            setterm -powersave on
            echo "Enabled powersave"
            xset s on
            echo "Enabled x screensaver"
            ;;

        start|lock)
            local result=`dcop kdesktop KScreensaverIface lock`
            if [[ "0" -ne "$?" ]]; then
                echo "ERROR -- could not start KDE screen saver"
            else
                echo "Started KDE screen saver"
                show_status=1
            fi
            ;;

        *)
            echo "Use: ksaver [arg]"
            echo
            echo "possible values for arg:"
            echo
            echo "[status] show screen saver status"
            echo
            echo "[off / disable] disable screen saver from starting; not saved in permanent"
            echo "                config"
            echo
            echo "[on / enable] allow screen saver to start; not saved in permanent config"
            echo
            echo "[start / lock] start screen saver, lock terminal"
            echo
            ;;
    esac

    if [[ "1" -eq "$show_status" ]]; then
        result=`dcop kdesktop KScreensaverIface isEnabled`
        if [[ "0" -ne "$?" ]]; then
            echo "ERROR -- could not get KDE screen saver status"
        else
            if [[ "true" = "$result" ]]; then
                echo "The KDE screen saver is on / enabled"
            else
                echo "The KDE screen saver is off / disabled"
            fi
        fi
    fi
}



FUNC_HELP_note=( 'add a note with knotes under KDE' '' )
function note()
{
    if [[ "true" != "$KDE_FULL_SESSION" ]]; then
        echo "ERROR -- expecting KDE to be running for DCOP to knotes!"

    elif [[ $# -ne 2 ]]; then
        echo "Usage: note [title] [text ...]"

    else
        local timestamp=`date '+%I:%M%P %m/%d/%y'`

        local title=$1" ("$timestamp")"
        shift
        note=$@

        dcop knotes KNotesIface newNote "$title" "$note"
    fi
}



FUNC_HELP_toclip=( 'copy to the KDE clipboard' '' )
function toclip()
{
    if [[  "$KDE_FULL_SESSION" = "true" ]]; then
        dcop klipper klipper setClipboardContents "$(cat $@)"
    else
        echo "ERROR -- expecting KDE to be running for DCP communications to klipper"
    fi
}


