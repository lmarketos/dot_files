#! /bin/bash
# TODO: Better documentation for these functions


FUNC_HELP_check_emacs=( 'check if gnuserv is running; returns 0 if no error' '' )
function check_emacs()
{
    which gnuclient > /dev/null 2>&1
    if [[ "0" -ne "$?" ]]; then
        echo "ERROR -- gnuclient is not installed, or gnuclient is not in your PATH"
        return -1
    fi

    pgrep -u `whoami` -x gnuserv > /dev/null 2>&1
    local gnuserv_running=$?

    if [[ "0" -ne "$gnuserv_running" ]]; then
        echo "ERROR -- gnuserv does not appear to be running; check emacs"
        return -1
    fi

    gnuclient_eval_wrapper '(emacs-version)'
    if [[ "0" -ne "$?" ]]; then return -1; fi
}


FUNC_HELP_ebc=( 'byte-compile emacs el files' '' )
function ebc()
{
    bin=`emacs_bin`

    if [[ -d "$HOME/.elisp" ]]; then
        pushd $HOME/.elisp
        $bin -batch -f batch-byte-compile *.el
        popd
    fi

    if [[ -d "$HOME/.elisp/apel" ]]; then
        pushd $HOME/.elisp/apel
        $bin -batch -f batch-byte-compile *.el
        popd
    fi

    if [[ -d "$HOME/.elisp/dictionary" ]]; then
        pushd $HOME/.elisp/dictionary
        $bin -batch -f batch-byte-compile *.el
        popd
    fi

    if [[ -d "$HOME/.elisp/themes" ]]; then
        pushd $HOME/.elisp/themes
        $bin -batch -f batch-byte-compile *.el
        popd
    fi

    if [[ -d "$HOME/.elisp/yasnippet" ]]; then
        pushd $HOME/.elisp/yasnippet
        $bin -batch -f batch-byte-compile *.el
        popd
    fi

    if [[ -f "$HOME/.emacs" ]]; then
        pushd $HOME
        $bin -batch -f batch-byte-compile .emacs
        popd
    fi

    if [[ -f "$HOME/.emacs_real.el" ]]; then
        pushd $HOME
        $bin -batch -f batch-byte-compile .emacs_real.el
        popd
    fi
}


FUNC_HELP_eddir=( 'open a directory for editing in emacs' '' )
function eddir()
{
    if [[ "-h" == "$1" ]]; then
        echo "Open a directory for editing in emacs"
        echo
        echo "Usage:"
        echo "    eddir [-m] [<dir1>] [<dir2>] ..."
        echo
        echo "-m"
        echo "    make a new frame for each directory"
        echo
        echo "[<dir1>] [<dir2>] ..."
        echo "    directories to open"
        echo
        echo "If no directories are specified, use the current directory in the shell"
        echo
        return
    fi

    local make_frame=0
    if [[ "-m" == "$1" ]]; then
        make_frame=1
        shift
    fi

    local dirs=`pwd`"/."
    if [[ -n "$1" ]]; then
        dirs="$@"
    fi

    for x in $dirs; do
        if [[ "1" -eq "$make_frame" ]]; then
            emacsclient -a emacs -e '(custom-make-frame)'
        fi

        emacsclient -a emacs -e '(raise-frame)'
        emacsclient -a emacs -e '(x-focus-frame nil)'
        emacsclient -a emacs -e "(cd \"$x\")"

        if [[ "0" -eq "$make_frame" ]]; then
            emacsclient -a emacs -e '(split-window-vertically)'
        fi

        emacsclient -a emacs -e "(find-file \"$x\")"
    done
}


FUNC_HELP_emacs_bin=( 'find the emacs binary' '' )
function emacs_bin()
{
    unset bin
    if [[ -x "/usr/local/bin/emacs" ]]; then
        bin='/usr/local/bin/emacs'
    elif [[ -x "/usr/bin/emacs" ]]; then
        bin='/usr/bin/emacs'
    fi

    if [[ -n "$bin" ]]; then
        echo $bin
        return 0
    fi

    return -1
}




FUNC_HELP_edit=( 'edit file(s) in emacs via gnuserv' '' )
function edit()
{
    if [[ -z "$1" ]]; then
        echo "edit [+-f] [-m] [+-r] <file 1> [-m] [-r] <file 2> ..."
        echo "    -f to edit R/W"
        echo "    -m to make a new frame"
        echo "    -r to edit as root"
        echo "For existing files, the file can be optionally preceded by +line to go to a"
        echo "specific line number"
        return -1
    fi

    check_emacs
    if [[ "0" -ne "$?" ]]; then return -1; fi

    gnuclient_eval_wrapper '(raise-frame)'
    if [[ "0" -ne "$?" ]]; then return -1; fi

    gnuclient_eval_wrapper '(focus-frame)'
    if [[ "0" -ne "$?" ]]; then return -1; fi

    local not_read_only=0
    local as_root=0

    local use_line_number=0
    local line_number=0

    for x in "$@"; do

        if [[ "-m" = "$1" ]]; then
            gnuclient_eval_wrapper '(custom-make-frame)'
            if [[ "0" -ne "$?" ]]; then return -1; fi

            gnuclient_eval_wrapper '(raise-frame)'
            if [[ "0" -ne "$?" ]]; then return -1; fi

            gnuclient_eval_wrapper '(focus-frame)'
            if [[ "0" -ne "$?" ]]; then return -1; fi

        elif [[ "-f" = "$1" ]]; then
            not_read_only=1

        elif [[ "+f" = "$1" ]]; then
            not_read_only=0

        elif [[ "-r" = "$1" ]]; then
            as_root=1

        elif [[ "+r" = "$1" ]]; then
            as_root=0

        else
            test_char=`echo $x | cut -b 1`

            skip=0

            if [[ "$test_char" = "+" ]]; then
                use_line_number=1
                line_number=`echo $x | sed 's/^+//'`
                skip=1
            elif [[ "$test_char" = "/" ]]; then
                full_filename=$x
            else
                full_filename=`pwd`/$x
            fi

            if [[ "0" -eq "$skip" ]]; then
                if [[ -f "$full_filename" ]]; then

                    if [[ "1" -eq "$as_root" ]]; then
                        echo "Loading file as root "$full_filename
                        emacs_command="(find-file-root \"$full_filename\")"

                    elif [[ "1" -eq "$not_read_only" ]]; then
                        echo "Loading existing file "$full_filename
                        emacs_command="(find-file \"$full_filename\")"

                    else
                        echo "Loading existing file "$full_filename" (read only)"
                        emacs_command="(find-file-read-only \"$full_filename\")"
                    fi

                    echo "gnuclient: "$emacs_command
                    gnuclient -q -batch -eval "$emacs_command"
                    if [[ "0" -ne "$?" ]]; then return -1; fi

                    as_root=0

                    if [[ "0" -ne "$line_number" ]]; then
                        echo "Jumping to line number "$line_number
                        emacs_command="(goto-line $line_number)"

                        echo "gnuclient: "$emacs_command
                        gnuclient -q -batch -eval "$emacs_command"
                        if [[ "0" -ne "$?" ]]; then return -1; fi
                    fi

                elif [[ -d "$full_filename" ]]; then
                    echo "Opening directory "$full_filename
                    emacs_command="(find-file \"$full_filename\")"
                    echo "gnuclient: "$emacs_command
                    gnuclient -q -batch -eval "$emacs_command"
                    if [[ "0" -ne "$?" ]]; then return -1; fi

                    as_root=0

                else

                    if [[ "1" -eq "$as_root" ]]; then
                        echo "Loading new file as root "$full_filename
                        emacs_command="(find-file-root \"$full_filename\")"

                    else
                        echo "Loading new file "$full_filename
                        emacs_command="(find-file \"$full_filename\")"

                    fi

                    echo "gnuclient: "$emacs_command
                    gnuclient -q -batch -eval "$emacs_command"
                    if [[ "0" -ne "$?" ]]; then return -1; fi

                    as_root=0

                fi

                echo

                use_line_number=0
                line_number=0
            fi
        fi

        shift

    done
}


FUNC_HELP_emod=( 'edit a class in emacs via emacsclient' '' )
function emod()
{
    if [[ -z "$1" || "-h" == "$1" ]]; then
        echo "Edit a class with emacs"
        echo
        echo "Usage:"
        echo "    emod [-f] [-m] [-r] <class 1> [-m] [-r] <class 2> ..."
        echo
        echo "+f"
        echo "    to edit readonly"
        echo
        echo "-f"
        echo "    to edit R/W"
        echo
        echo "-m"
        echo "    make a new frame"
        echo
        echo "-nw, -t, --tty"
        echo "    open a frame in the terminal"
        echo
        echo "-x"
        echo "    open in an X display"
        echo
        return -1
    fi

    local args

    while [[ -n "$1" ]]; do

        local test_char=`echo $1 | cut -b 1`
        case $test_char in
            -)
                args=$args" "$1
                shift
                continue
                ;;
        esac

        # remove trailing periods; i.e., from partial filename completion
        local filename_no_dot=`echo $1 | sed -e 's/[.]*$//'`

        local h_file=$filename_no_dot".h"
        local hh_file=$filename_no_dot".hh"
        local cpp_file=$filename_no_dot".cpp"
        local cc_file=$filename_no_dot".cc"
        local c_file=$filename_no_dot".c"
        local arg_file=$1

        if [[ -f "$h_file"   ]]; then args=$args" "$h_file;   fi
        if [[ -f "$hh_file"  ]]; then args=$args" "$hh_file;  fi
        if [[ -f "$cpp_file" ]]; then args=$args" "$cpp_file; fi
        if [[ -f "$cc_file"  ]]; then args=$args" "$cc_file;  fi
        if [[ -f "$c_file"   ]]; then args=$args" "$c_file;   fi
        if [[ -f "$arg_file" ]]; then args=$args" "$arg_file; fi

        shift
    done

    edit $args
}


FUNC_HELP_etar=( 'make a tarball of emacs config, to move to another machine' '' )
function etar()
{
    local tarball_ext=".tar.bz2"
    local tar_opts="cfj"

    local timestamp=`date +%Y%m%d_%H%M%S`

    local tmp_dir="emacs_cfg__"`whoami`"__"$HOSTNAME"__"$timestamp

    local tarball_name=$tmp_dir$tarball_ext

    pushd /tmp
    mkdir $tmp_dir
    cd tmp_dir

    cp -R $HOME/.emacs .
    cp -R $HOME/.emacs_real.el .
    cp -R $HOME/.elisp .
    cp -R $HOME/.emacs.quick .
    cp -R $HOME/.emacs_quick_templates .

    rm `find . -name "*.elc"`
    cd ..
    archive_dirs $tmp_dir
    popd

    if [[ `pwd` != "/tmp" ]]; then
        mv "/tmp/"$tmp_dir$tarball_ext .
    fi

    echo "Created "$tarball_name
}


FUNC_HELP_gnuclient_eval_wrapper=( 'wrapper for calling gnuclient' '' )
function gnuclient_eval_wrapper()
{
    while [[ -n "$1" ]]; do

        echo "gnuclient: "$@

        gnuclient -q -batch -eval $@
        gnuclient_rv=$?

        if [[ "0" -ne "$gnuclient_rv" ]]; then
            echo "ERROR -- gnuclient failed"
            return -1
        fi

        shift

    done
}


FUNC_HELP_qemacs=( 'super-fast, quick emacs, no frills, bells, or whistles' '' )
function qemacs()
{
    # emacs args: --quick/-Q covers --no-site-file --no-init-file --no-splash

    bin=`emacs_bin`

    local STARTUP_LISP=~/.emacs.quick
    local STARTUP_COMPILED_LISP=$STARTUP_LISP".elc"

    if [[ -f "$STARTUP_LISP" ]]; then
        if [[ ! -f "$STARTUP_COMPILED_LISP" || "$STARTUP_LISP" -nt "$STARTUP_COMPILED_LISP" ]]; then
            pushd `dirname $STARTUP_LISP` > /dev/null 2>&1
            $bin -batch -f batch-byte-compile $STARTUP_LISP
            popd > /dev/null 2>&1
        fi
        $bin -nw --quick --no-desktop --load $STARTUP_COMPILED_LISP "$@"
    else
        $bin -nw --quick --no-desktop "$@"
    fi
}



FUNC_HELP_woman=( 'call woman in emacs via gnuserv' '' )
function woman()
{
    if [[ -z "$1" ]]; then
        echo "woman <topic>"
        return -1
    fi

    check_emacs
    if [[ "0" -ne "$?" ]]; then return -1; fi

    gnuclient_eval_wrapper '(raise-frame)'
    if [[ "0" -ne "$?" ]]; then return -1; fi

    gnuclient_eval_wrapper '(focus-frame)'
    if [[ "0" -ne "$?" ]]; then return -1; fi

    gnuclient -q -batch -eval "(raise-frame (selected-frame)) (woman \"$1\" )"
    if [[ "0" -ne "$?" ]]; then return -1; fi
}


