#! /bin/bash
# TODO: Better documentation for these functions

FUNC_HELP_add_PATH=( 'Add an entry to a variable that contains colon-delimited values'
$'usage: add_PATH <var> <dir> [ after | append ] [ check ]

Assuming <var> is the name of an environment variable (eg, PATH) that contains
a ":" delimited list, then prepend <dir> to it, unless "after/append" is
specified.  If "check" is specified, then only add <dir> if it exists.' )
function add_PATH()
{
    local var=$1
    shift
    local dir=$1
    shift

    after=0
    check=0

    while [[ -n "$1" ]]; do
        if [[ "$1" = "after" || "$1" = "append" ]]; then
            after=1
        elif [[ "$1" = "check" ]]; then
            check=1
        else
            break
        fi
        shift
    done

    if [[ -n "$dir" ]]; then

        good=1

        if [[ "1" -eq "$check" && ! -d "$dir" ]]; then
            good=0
        fi

        if [[ "1" -eq "$good" ]]; then
            if ! echo ${!var} | /bin/egrep -q "(^|:)$dir($|:)" ; then

                if [[ -n "${!var}" ]]; then
                    if [[ "1" -eq "$after" ]]; then
                        eval "export $var=${!var}:$dir"
                    else
                        eval "export $var=$dir:${!var}"
                    fi
                else
                    eval "export $var=$dir"
                fi
            fi
        fi
    fi
}


FUNC_HELP_del_PATH=( 'Delete an entry from a variable that contains colon-delimited values'
$'usage: del_PATH <var> <dir>

Assuming <var> is an environment variable (eg, PATH) that contains a ":"
delimited list, then delete <dir> from it.' )
function del_PATH()
{
    pattern='s,^'${2}'$,,; s,^'${2}':,,; s,:'${2}':,:,g; s,:'${2}'$,,'
    eval "export $1=`echo ${!1} | sed \"$pattern\"`"
}


FUNC_HELP_archive_dirs=( 'helper for making tarballs of directories' '' )
function archive_dirs()
{
    local dirlist

    local tarball_ext=".tar.bz2"
    local tar_opts="cfj"

    case $1 in
        -tgz*|-gzip*)
            echo "Using gzip"
            tarball_ext=".tgz"
            tar_opts="cfz"
            shift
            ;;

        -bzip*|-bzip2*)
            echo "Using bzip2"
            tarball_ext=".tar.bz2"
            tar_opts="cfj"
            shift
            ;;
    esac

    if [[ -z "$1" ]]; then
        for x in `ls -A1`; do
            if [[ -d "$x" ]]; then
                dirlist=$dirlist" "$x
            fi
        done
    else
        until [[ -z "$1" ]]; do
            local dirname=`echo $1 | sed 's/\///'`

            if [[ -d "$dirname" ]]; then
                dirlist=$dirlist" "$dirname
            else
                echo "ERROR -- $dirname is not a directory"
                return -1
            fi
            shift
        done
    fi

    for x in $dirlist; do
        if [[ ! -d "$x" ]]; then
            echo "ERROR -- $x is not a directory"
        else
            echo "Archiving $x"
            tar_filename=$x$tarball_ext

            if [[ -f "$tar_filename" ]]; then
                echo "WARNING -- $tar_filename already exists; not overwriting!"
            else
                nice tar $tar_opts $tar_filename $x/
                if [[ "$?" -ne "0" ]]; then
                    echo "ERROR -- tar returned a non-zero status"
                    return -1
                fi

                if [[ ! -f "$tar_filename" ]]; then
                    echo "ERROR -- the tar file does not exist"
                    return -1
                fi

                echo "    removing "$x
                rm -rf $x
            fi
        fi
    done
}


FUNC_HELP_bkup=( 'backup a file' '' )
function bkup()
{
    local timestamp=`date +%Y%m%d_%H%M%S`
    until [[ -z "$1" ]]; do

        if [[ -f "$1" || -d "$1" ]]; then

            local this_dirname=`dirname "$1"`
            local this_basename=`basename "$1"`

            if [[ -n "$this_dirname" ]]; then
                pushd "$this_dirname" > /dev/null 2>&1
            fi

            local cp_to="$this_basename.$timestamp.bak"

            if [[ -d "BAK" ]]; then
                cp_to="BAK/$cp_to"
            elif [[ -d ".bak" ]]; then
                cp_to=".bak/$cp_to"
            elif [[ -d ".BAK" ]]; then
                cp_to=".BAK/$cp_to"
            fi

            if [[ -n "this_dirname" ]]; then
                cp_to="$this_dirname/$cp_to"
            fi

            if [[ -f "$1" ]]; then
                cp -p "$1" "$cp_to"
            else
                cp -p -R "$1" "$cp_to"
            fi
            if [[ "0" -eq "$?" ]]; then
                if [[ -f "$1" ]]; then
                    chmod $BKUP_PERMISSIONS "$cp_to"
                    echo "Copied $1 to $cp_to"
                else
                    chmod -R $BKUP_PERMISSIONS $cp_to
                    echo "Copied directory $1 to $cp_to"
                fi
            else
                echo "error -- could not copy $1 to $cp_to"
                return -1
            fi

            if [[ -n "$this_dirname" ]]; then
                popd > /dev/null 2>&1
            fi

        else
            echo "error -- $1 does not exist or is not a regular file or directory"
        fi

        shift
    done
}


FUNC_HELP_cd=( 'overload builtin cd to possibly cat a file'
$'
- if .readme exists in the target directory, show it on a change to that directory
- if the last argument to cd is a filename, cd to the directory containing the file' )
function cd()
{
    local rv=0

    if [[ "$#" -gt "0" ]]; then

        eval last_arg='$'$#

        if [[ -f "$last_arg" ]]; then

            local l
            while test $# -gt 1; do
                l="$l $1"
                shift
            done

            # This has a bug - if the directory name has spaces, and
            # additional arguments are passed to cd, this will not work.
            d=`dirname "$last_arg"`;
            l="$l \"$d\""
            builtin cd "$l"; rv=$?

        else

            builtin cd "$@"; rv=$?

        fi

    else
        builtin cd; rv=$?
    fi

    # if there is a .readme in the target directory, then cat it
    if [[ -n "$INTERACTIVE" && "1" -eq "$INTERACTIVE" && -f ".readme" && "0" -eq "$rv" ]]; then
        cat .readme
    fi

    return $rv
}


FUNC_HELP_cpfromtar=( 'extract a file from a tarball' '' )
function cpfromtar()
{
    if [[ "$#" -eq "0" || "$#" -eq "1" ]]; then
        echo "Usage: cpfromtar <tarball name> <files to extract>"
        return 1
    fi

    local tarball=$1
    shift

    if [[ ! -f "$tarball" ]]; then
        echo "ERROR -- specified tarball does not exist"
        echo "looking for: "$tarball
        return -1
    fi

    local is_gzip=`file $tarball | grep -c "gzip compressed"`
    local is_bzip=`file $tarball | grep -c "bzip2 compressed"`

    if [[ "0" -ne "$is_gzip" ]]; then
        echo "Extracting ""$@"
        zcat $tarball | cpio -v -d -i "$@"

    elif [[ "0" -ne "$is_bzip" ]]; then
        echo "Extracting ""$@"
        bzcat $tarball | cpio -v -d -i "$@"

    else
        echo "Extracting ""$@"
        cat $tarball | cpio -v -d -i "$@"
    fi
}


FUNC_HELP_cpumax=( 'set cpu frequency to be maximum' '' )
function cpumax()
{
    for x in `ls -d /sys/devices/system/cpu/cpu*`; do
        cpu_number=`basename $x | sed 's/^cpu//'`
        max_freq=`cat ${x}/cpufreq/cpuinfo_max_freq`
        sudo cpufreq-set --cpu $cpu_number -f $max_freq
    done
}


FUNC_HELP_cpus=( 'CPU info from /proc/cpuinfo' '' )
function cpus()
{
    local cpu_speed=`grep cpu /proc/cpuinfo | grep MHz | awk '{ print $4 }'`
    echo "The cpu speed is "$cpu_speed" MHz"
}


FUNC_HELP_describe_rpms=( 'run "rpm -qip" on a set of RPMs' '' )
function describe_rpms()
{
    if [[ "$#" -gt "0" ]]; then
        while [[ -n "$1" ]]; do
            local desc=`rpm -qip $1 | grep Summary | sed 's/Summary *: //'`
            printf "%-40s %s\n" "$1" "$desc"
            shift
        done
    else
        for x in `rpm -qa | sort`; do
            local desc=`rpm -qi $x | grep Summary | sed 's/Summary *: //'`
            printf "%-40s %s\n" "$x" "$desc"
        done
    fi
}


FUNC_HELP_diffdirs=( 'run diff against two trees' '' )
function diffdirs()
{
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Error - invalid command line -- enter two directory names"
        return -1
    fi

    if [[ ! -d "$1" ]]; then
        echo "Error - $1 is not a directory or does not exist"
        return -1
    fi

    if [[ ! -d "$2" ]]; then
        echo "Error - $2 is not a directory or does not exist"
        return -1
    fi

    echo "-*- mode: fundamental; -*-"
    echo
    echo "Running diff against the directories $1 and $2"
    echo "----------------------------------------------------------------------"

    diff -r -B -b --brief "$1" "$2"
}


FUNC_HELP_ff=( 'shortcut for find files' '' )
function ff()
{
    find -name "$@" -print
}


FUNC_HELP_find_bins=( 'find binaries' '' )
function find_bins()
{
    find -perm -700 ! -type d -print

#    local file_list=`find . -name "*"`
#    for x in $file_list; do
#        if [[ -x "$x" && ! -d "$x" ]]; then
#            echo $x" is a executable file"
#        fi
#    done
}


FUNC_HELP_find_symlinks=( 'find symbolic links' '' )
function find_symlinks()
{
    local file_list=`find . -name "*"`
    for x in $file_list; do
        if [[ -L "$x" ]]; then
            echo $x" is a symlink"
        fi
    done
}


FUNC_HELP_findgrep=( 'grep in files; see sfindgrep for source code' '' )
function findgrep()
{
    find . -name "*" -type f -exec grep -Hne $* '{}' \;
}


FUNC_HELP_foreach=( 'executes a command on a set of files, individually' '' )
function foreach()
{
    if [[ -z "$1" ]]; then
        echo "foreach <cmd>"
        echo "    implicit * for args"
        echo
        echo "foreach <cmd> <args>"
        return -1
    fi

    local cmd=$1
    shift

    if [[ -n "$1" ]]; then

        while [[ -n "$1" ]]; do
            echo $1 | xargs $cmd
            shift
        done

    else

        for x in `ls -1 2> /dev/null`; do
            echo $x | xargs $cmd
        done

    fi
}


FUNC_HELP_help=( 'help info for all bash functions'
$'usage: help [ bash | <func_name> | <builtin_function> ]

If arg is "bash" then run "builtin help". Otherwise, assuming arg is the name
of a bash function (builtin or not), try to find and print help info for it.' )
function help()
{
    # if no args were given, then print concise help info for all bash functions
    if [[ -z "$1" ]]; then
        echo
        echo "Functions without help info:"
        echo "~~~~~~~~~~"
        local vars="`compgen -v 'FUNC_HELP_'`"
        local funcs="`declare -F | cut -f3 -d' ' | grep -v '^_'`"
        for f in $funcs; do
            text="`echo $vars | grep "FUNC_HELP_$f"`"
            if [[ -z $text ]]; then
                echo "  $f"
            fi
        done

        echo
        echo "Functions:"
        echo "~~~~~~~~~~"
        local text
        for v in $vars; do
            text="`eval \"echo \\${$v[0]}\"`"
            printf "  %-25s %s\n" "${v#FUNC_HELP_}" "$text"

        done
        echo

        return
    fi

    if [[ "bash" = "$1" ]]; then
        builtin help
        return
    fi

    # assume $1 is the name of a bash function
    local varName=`compgen -v FUNC_HELP_$1`
    if [[ -n $varName ]]; then
        local text=`eval "echo \"\\${$varName[0]}\""`"\n\n"
        text+=`eval "echo \"\\${$varName[1]}\""`
        echo -e "$text"
        echo
        return
    fi

    local func="`declare -F | cut -f3 -d' ' | grep $1`"
    if [[ -n $func ]]; then
        echo
        echo "No help info available for bash function: $1"
        echo
    else
        # if it's not a bash function, then call builtin help
        builtin help $1
    fi
}



FUNC_HELP_lcmds=( 'this function prints out a list of all commands that are in $PATH' '' )
function lcmds()
{
    # TODO -- check for duplicate commands in PATH, and that all commands
    # with the same name are at most one real command and symlinks to
    # the same place
    local tmp_working=`mktemp /tmp/tmp.XXXXXX`
    local tmp_all_cmds=`mktemp /tmp/tmp.XXXXXX`
    for x in `echo $PATH | sed 's/:/ /g'`; do
        echo $x >> $tmp_working
    done

    for dir in `cat $tmp_working | sort| uniq`; do
        if [[ -d "$dir" ]]; then
            for cmd in `ls -1 $dir`; do

                if [[ -f "$dir/$cmd" ]]; then

                    unset extra_text
                    if [[ -L "$dir/$cmd" ]]; then
                        linkto=`readlink $dir/$cmd`
                        extra_text=" (symlink: "$linkto")"
                    fi
                    printf "%-35s %-20s %-24s\n" "$cmd" "$dir" "$extra_text" | sed 's/ *$//' >> $tmp_all_cmds
                fi
            done
        fi
    done
    cat $tmp_all_cmds | sort
    rm -f $tmp_working $tmp_all_cmds
}



FUNC_HELP_lg=( 'ls with a grep; if only one match, and it is a directory, cd into it' '' )
function lg()
{
    if [[ -n "$1" ]]; then

        local result=`ls -1 -p -A | grep -i $1`
        local count=0

        for x in $result; do
            let count="$count+1"
        done

        if [[ "1" -eq "$count" && -d "$result" ]]; then
            cd $result
            pwd
        else
            ls -la | grep -i $1
        fi

    else
        ls -la
    fi
}


FUNC_HELP_mkcd=( 'mkdir followd by cd' '' )
function mkcd()
{
    if [[ -z "$1" ]]; then
        echo "Usage: mkcd dir"
        return 1
    fi

    if [[ ! -d "$1" ]]; then
        mkdir -p $1
        if [[ "$?" -ne "0" ]]; then
            return 1
        fi
    fi

    cd $1
}

FUNC_HELP_name_tb=( 'set the window titlebar text'
$'usage: name_tb <some_string>

Set the window titlebar to the given string. Works with TERM=xterm|rxvt|screen.' )
function name_tb()
{
    case $TERM in
        xterm*)
            echo -ne "\033]0;$1\007"
            ;;
        rxvt*)
            echo -ne "\033]60;$1\007"
            ;;
        screen)
            # This was causing problems on ubuntu 12.04
            #echo -ne "\033_$1\033"
            ;;
        *)
            # Not supported yet
            ;;
    esac
}


FUNC_HELP_nd=( 'Call the "ns" function to set the session/tab text'
$'usage: nd <text>

Set the current session/tab title to $HOSTNAME:$pwd' )
function nd()
{
    local dirname=`pwd | sed 's/.*\///'` # | sed 's/^app_//'`

    if [[ "root" = "$USER" ]]; then
        export SESSION_NAME="ROOT@$HOSTNAME:"$dirname
    else
        export SESSION_NAME="$HOSTNAME:"$dirname
    fi

    ns $SESSION_NAME
}


FUNC_HELP_ns=( 'Set the current session/tab title'
$'usage: ns [ <text> ]

Set the current session/tab title to the given string. If <text> is not
given, then set it to $HOSTNAME. Works with TERM=xterm|rxvt|screen' )
function ns()
{
    if [[ -z "$WINDOWID" ]]; then
        unset SESSION_NAME
        export SESSION_NAME
        return
    fi

    if [[ -n "$1" && "$1" != "CLEAR" ]]; then
        export SESSION_NAME=$1

    elif [[ -z "$SESSION_NAME" || "$1" = "CLEAR" ]]; then
        if [[ "root" = "$USER" ]]; then
            export SESSION_NAME="ROOT@"$HOSTNAME
        else
            export SESSION_NAME=$HOSTNAME
        fi
    fi

    case $TERM in
        xterm*)
            echo -ne "\033]30;${SESSION_NAME}\007"
            ;;
        rxvt*)
            echo -ne "\033]61;${SESSION_NAME}\007"
            ;;
        screen)
            echo -ne "\033_${SESSION_NAME}\033"
            ;;
        *)
            # Not supported yet
            ;;
    esac
}



FUNC_HELP_od=( 'remove a directory from the stack; see also pd()' '' )
function od()
{
    popd
    rv=$?
    num_dirs=`dirs | wc -l`
    if [[ "0" -ne "$rv" && "$num_dirs" -gt "1" ]]; then
        echo 'popd error -- deleting top of stack, not changing dir!'
        popd -n
    fi
}



FUNC_HELP_p=( 'pwd, with & without full resolution of symbolic links' '' )
function p()
{
    echo `pwd -L`" (no syms: "`pwd -P`")"
}



FUNC_HELP_pd=( 'push a directory on the dir stack; see also od()' '' )
function pd()
{
    if [[ -n "$1" ]]; then
        pushd $1
    else
        pushd .
    fi
}



FUNC_HELP_poweroff=( 'Halt the machine; pass an argument to specifify a time until reboot' '' )
function poweroff()
{
    # look for other users still logged in
    me=`who mom likes | awk '{ print $1 }'`
    logged_in=`w -h | awk ' { print $1 }' | sort | uniq`

    local refuse=0
    if [[ "0" -eq "$#" ]]; then
        for x in $logged_in; do
            if [[ "$me" != "$x" ]]; then
                if [[ "0" -eq "$refuse" ]]; then
                    echo "Refusing, other users still logged in"
                fi
                echo $x
                refuse=1;
            fi
        done
    fi

    if [[ "0" -eq "$refuse" ]]; then
        local time_arg="now"

        if [[ "0" -ne "$#" ]]; then
            time_arg=$1
            shift
        fi

        if [[ "root" != "$USER" ]]; then
            sudo shutdown -t 4 -h -f $time_arg "$@"
        else
            shutdown -t 4 -h -f $time_arg "$@"
        fi
    fi
}


FUNC_HELP_pretty_pwd=( 'Export $newPWD set to $PWD with a maximum length'
$'usage: pretty_pwd [max_length]

Exports $newPWD with the $PWD truncated to the last max_length chars. If
max_length is not given, then assume max_length = 40.' )
function pretty_pwd()
{
    # How many characters of the $PWD should be kept
    local pwdmaxlen=40
    if [[ -n "$1" ]]; then
        pwdmaxlen="$1"
    fi

    # Indicator that there has been directory truncation:
    local trunc_symbol="..."

    local temp="${PWD/$HOME/~}"
    if [[ ${#temp} -gt $pwdmaxlen ]]; then
        local pwdoffset=$(( ${#temp} - $pwdmaxlen ))
        export newPWD="${trunc_symbol}${temp:$pwdoffset:$pwdmaxlen}"
    else
        export newPWD=${temp}
    fi
}



FUNC_HELP_psall=( 'show all processes' '' )
function psall()
{
    local ps_flags="-Lef"

    # redhat 9 is behind the times
    if [[ "redhat" = "$PLATFORM_FLAVOR" && "9" = "$PLATFORM_VERSION" ]]; then
        ps_flags="-mef"
    fi

        local tmp_file=`mktemp /tmp/psall.XXXXXX`

    ps $ps_flags > $tmp_file
    head --lines=1 $tmp_file

    if [[ "user" = "$1" ]]; then
        local sort_flags="-k 1,1 -k 2,2n -k 3,3n -k 4,4n"
    else
        local sort_flags="-k 2,2n -k 3,3n -k 4,4n"
    fi

    cat $tmp_file | sed '1,1d' | sort $sort_flags

    rm -f $tmp_file
}



FUNC_HELP_psfu=( 'show processes for a specific user' '' )
function psfu()
{
    local user;
    local grep_term;

    if [[ -n "$1" ]]; then
        id $1 > /dev/null 2>&1
        if [[ "$?" -eq "0" ]]; then
            user=$1
        else
            user=`whoami`
            grep_term=$1
        fi
    else
        user=`whoami`
    fi

    local ps_flags;

    # redhat 9 is behind the times
    if [[ "redhat" = "$PLATFORM_FLAVOR" || "fedora" = "$PLATFORM_FLAVOR" ]]; then
        ps_flags="-mf -u "$user" -U "$user
    else
        ps_flags="-Lf -u "$user" -U "$user
    fi

    if [[ -z "$grep_term" ]]; then
        ps $ps_flags
    else
        ps $ps_flags | grep $grep_term
    fi
}


FUNC_HELP_psmem=( 'show process memory usage' '' )
function psmem()
{
    ps -A -o uid,pid,ppid,lwp,rss,vsz,command
}


FUNC_HELP_readme=( 'pager on readme file' '' )
function readme()
{
    flist=`ls -1a 2> /dev/null | grep -i readme`
    num=`ls -1a 2> /dev/null | grep -i readme | wc -l`

    if [[ "1" -eq "$num" ]]; then
        $PAGER $flist
    fi
}



FUNC_HELP_reboot=( 'Reboot the machine; pass an argument to specifify a time until reboot' '' )
function reboot()
{
    # look for other users still logged in
    me=`who mom likes | awk '{ print $1 }'`
    logged_in=`w -h | awk ' { print $1 }' | sort | uniq`

    local refuse=0
    if [[ "0" -eq "$#" ]]; then
        for x in $logged_in; do
            if [[ "$me" != "$x" ]]; then
                if [[ "0" -eq "$refuse" ]]; then
                    echo "Refusing, other users still logged in"
                fi
                echo $x
                refuse=1;
            fi
        done
    fi

    if [[ "0" -eq "$refuse" ]]; then
        local time_arg="now"

        if [[ "0" -ne "$#" ]]; then
            time_arg=$1
            shift
        fi

        if [[ "root" != "$USER" ]]; then
            sudo shutdown -t 4 -r -f $time_arg "$@"
        else
             shutdown -t 4 -r -f $time_arg "$@"
        fi
    fi
}


FUNC_HELP_repeat=( 'repeat a command n times' '' )
function repeat()
{
    local max=$1;
    shift;
    for ((i=1; i <= max ; i++)); do
        eval "$@";
    done
}


# remove executable permissions recursively for everything that isn't a directory
function rmxperm() {
    sudo chmod -R u-x,g-x,o= "$@"
    chmod -R u+X,g+X "$@"
}



FUNC_HELP_root=( 'switch to root' '' )
function root()
{
    local u=`whoami`
    if [[ "root" != "$u" ]]; then
        su -
    else
        echo "already root"
    fi
}



FUNC_HELP_setuid=( 'set the setuid bit on files' '' )
function setuid()
{
    if [[ -z "$1" ]]; then
        echo "setuid <files ...>"
        return -1
    fi

    while [[ -n "$1" ]]; do

        if [[ -f "$1" ]]; then
            echo "Setting setuid bit for $1"
            sudo chmod +s $1
        else
            echo "ERROR -- $1 is not a regular file"
        fi

        shift
    done
}



FUNC_HELP_sigint=( 'send SIGINT to a set of processes, specified by name or PID' '' )
function sigint()
{
    signal SIGINT "$@"
}


FUNC_HELP_signal=( 'send a signal to a process'
$'usage: signal <signal> [ <pid> ]

Send a signal to a processes. Processes may be specified by name or PID' )
function signal()
{
    local prefix=""

    if [[ "-n" == "$1" ]]; then
        prefix="echo"
        shift
    fi

    sig=$1
    shift

    if [[ "-n" == "$1" ]]; then
        prefix="echo"
        shift
    fi

    local arg
    for arg in "$@"; do
        if [[ -d "/proc/${arg}" ]]; then
            $prefix kill -s $sig $arg
        else
            local expr='^'$arg'$'
            $prefix pkill -${sig} -u `whoami` -f "$expr"

            local expr='^.*/'$arg'$'
            $prefix pkill -${sig} -u `whoami` -f "$expr"
        fi
    done
}



FUNC_HELP_sigusr1=( 'send SIGUSR1 to a set of processes, specified by name or PID' '' )
function sigusr1()
{
    signal SIGUSR1 "$@"
}


FUNC_HELP_sigusr2=( 'send SIGUSR2 to a set of processes, specified by name or PID' '' )
function sigusr2()
{
    signal SIGUSR2 "$@"
}



FUNC_HELP_sp=( 'search for processes as the current user' '' )
function sp()
{
    local process_name=$1;
    local fuser=`whoami`

    pgrep -l -u $fuser $process_name
    echo

    local pidlist=`pgrep -u $fuser $process_name`
    local pids_oneline

    for x in $pidlist; do
        pids_oneline=$pids_oneline" "$x
    done

    if [[ -n "$pids_oneline" ]]; then
        echo "sudo renice 0 "$pids_oneline
        echo "sudo ionice -c3 -p"$pids_oneline
        echo "kill -s SIGINT"$pids_oneline
        echo "kill -s SIGHUP"$pids_oneline
        echo "kill -s SIGUSR1"$pids_oneline
        echo "kill -s SIGUSR2"$pids_oneline
        echo "kill -9"$pids_oneline
    fi
}


FUNC_HELP_swap=( 'swap two files or dirs' '' )
function swap()
{
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Use:"
        echo "swap <file 1> <file 2>"
        return -1
    fi

    if [[ ! -f "$1" && ! -d "$1" ]]; then
        echo $1" is not a file or directory!"
        return -1
    fi

    if [[ ! -f "$2" && ! -d "$2" ]]; then
        echo $2" is not a file or directory!"
        return -1
    fi

    if [[ -f "$1" && -f "$2" ]]; then
        local tmp_working=`mktemp tmp.XXXXXX`
        mv $1 $tmp_working
        mv $2 $1
        mv $tmp_working $2
    elif [[ -d "$1" && -d "$2" ]]; then
        local tmp_working=`mktemp -d tmp.XXXXXX`
        rm -rf $tmp_working
        mv $1 $tmp_working
        mv $2 `basename $1`
        mv $tmp_working `basename $2`
    else
        echo "Mismatch in file types (file vs. dir)"
        return -1
    fi
}



FUNC_HELP_tmp=( 'pushd to a tmp dir' '' )
function tmp()
{
    if [[ -d "$HOME/tmp" ]]; then
        pushd $HOME/tmp

    elif [[ -n "$TMPDIR" ]]; then
        pushd $TMPDIR

    elif [[ -d "/tmp" ]]; then
        pushd /tmp

    else
        echo "ERROR -- cannot find a temp dir"
        return -1
    fi
}



FUNC_HELP_trash=( 'mv, but with a trash directory' '' )
function trash()
{
    # with newer versions of kde, kfmclient may support:
    # kfmclient move "$1" trash:/

    trashdir=$HOME/Desktop/Trash
    if [[ ! -d "$trashdir" ]]; then
        echo "ERROR -- expected trash directory ($trashdir) does not exist"
        echo "Doing nothing!"
        return -1
    fi

    while [[ -n "$1" ]]; do

        if [[  "$KDE_FULL_SESSION" = "true" ]]; then
            kfmclient move "$1" "$trashdir/."
        else
            mv "$1" "$trashdir/."
        fi

        shift
    done
}



FUNC_HELP_ver=( 'print version info for system components' '' )
function ver()
{
    echo "PLATFORM_OS: "$PLATFORM_OS
    echo "PLATFORM_FLAVOR: "$PLATFORM_FLAVOR
    echo "PLATFORM_VERSION: "$PLATFORM_VERSION
    echo

    test -f "/etc/SuSE-release" && cat /etc/SuSE-release | head --lines=1
    test -f "/etc/redhat-release" && cat /etc/redhat-release
    echo

    echo "kernel version: "`uname -r`" ("`uname -v`")"
    echo

    which konsole > /dev/null 2>&1
    have_konsole=$?
    if [[ "0" -eq "$have_konsole" ]]; then
        konsole --version
    fi
    echo

    which bash > /dev/null 2>&1
    have_bash=$?
    if [[ "0" -eq "$have_bash" ]]; then
        bash --version | head --lines=1
    else
        echo "WARNING -- bash not installed or not in path!"
    fi
    echo

    which make > /dev/null 2>&1
    have_make=$?
    if [[ "0" -eq "$have_make" ]]; then
        make --version | head --lines=1
    else
        echo "WARNING -- make not installed or not in path!"
    fi
    echo

    which gcc > /dev/null 2>&1
    have_gcc=$?
    if [[ "0" -eq "$have_gcc" ]]; then
        gcc --version | head --lines=1
    else
        echo "WARNING -- gcc not installed or not in path!"
    fi
    echo

    which sed > /dev/null 2>&1
    have_sed=$?
    if [[ "0" -eq "$have_sed" ]]; then
        sed --version | head --lines=1
    else
        echo "WARNING -- sed not installed or not in path!"
    fi
    echo

    which awk > /dev/null 2>&1
    have_awk=$?
    if [[ "0" -eq "$have_awk" ]]; then
        awk --version | head --lines=1
    else
        echo "WARNING -- awk not installed or not in path!"
    fi
    echo

    which perl > /dev/null 2>&1
    have_perl=$?
    if [[ "0" -eq "$have_perl" ]]; then
        perl --version | head --lines=2
    else
        echo "WARNING -- perl not installed or not in path!"
    fi
    echo

    which python > /dev/null 2>&1
    have_python=$?
    if [[ "0" -eq "$have_python" ]]; then
        python --version
    else
        echo "WARNING -- python not installed or not in path!"
    fi
    echo

    which java > /dev/null 2>&1
    have_java=$?
    if [[ "0" -eq "$have_java" ]]; then
        java -version
    else
        echo "WARNING -- java not installed or not in path!"
    fi
    echo

    which emacs > /dev/null 2>&1
    have_emacs=$?
    if [[ "0" -eq "$have_emacs" ]]; then
        emacs --version | head --lines=1
    else
        echo "WARNING -- emacs not installed or not in path!"
    fi
    echo

    which pkg-config > /dev/null 2>&1
    have_pkgconfig=$?
    if [[ "0" -eq "$have_pkgconfig" ]]; then
        echo "pkg-config version: "`pkg-config --version`
    else
        echo "WARNING -- pkg-config not installed or not in path!"
    fi
    echo

    which opencv-config > /dev/null 2>&1
    have_old_opencv=$?
    if [[ "0" -eq "$have_old_opencv" ]]; then
        echo "opencv version: "`opencv-config --version`
    else

        if [[ "0" -eq "$have_pkgconfig" ]]; then

            ver=`pkg-config --modversion opencv 2> /dev/null`
            have_opencv=$?

            if [[ "0" -eq "$have_opencv" ]]; then
                echo "opencv: "$ver
            else
                echo "opencv not installed"
            fi

        else
            echo "opencv not installed / not able to verify"
        fi

    fi
    echo

    which coriander > /dev/null 2>&1
    have_coriander=$?
    if [[ "0" -eq "$have_coriander" ]]; then
        coriander --version
    else
        echo "NOTE -- coriander not installed or not in path!"
    fi
    echo

    # todo: $ Xorg -version
    which XFree86 > /dev/null 2>&1
    have_x=$?
    if [[ "0" -eq "$have_x" ]]; then
        XFree86 -version 2>&1 | head --lines=4
    else
        echo "NOTE -- X not installed or not in path!"
    fi
    echo

    if [[ "0" -eq "$have_pkgconfig" ]]; then

        gtk2_ver=`pkg-config --modversion gtk+-2.0 2> /dev/null`
        have_gtk2=$?

        if [[ "0" -eq "$have_gtk2" ]]; then
            echo "GTK2 devel version: "$gtk2_ver
        else
            echo "NOTE -- gtk2 devel not installed or not setup!"
        fi
        echo

        libraw1394_ver=`pkg-config --modversion libraw1394 2> /dev/null`
        have_libraw=$?

        if [[ "0" -eq "$have_libraw" ]]; then
            echo "libraw1394 version: "$libraw1394_ver
        else
            echo "NOTE -- libraw1394 devel not installed or not setup!"
        fi
        echo
    fi

    which unison > /dev/null 2>&1
    have_unison=$?
    if [[ "0" -eq "$have_unison" ]]; then
        unison -version
    else
        echo "NOTE -- unison not installed or not in path!"
    fi
    echo
}



FUNC_HELP_vmore=( 'invoke vim as a pager' '' )
function vmore()
{
    #alias "vmore"='vim -u $HOME/.vimrc.more'

    if test $# = 0; then
        vim --cmd 'let no_plugin_maps = 1' -c 'runtime! macros/less.vim' -
    else
        vim --cmd 'let no_plugin_maps = 1' -c 'runtime! macros/less.vim' "$@"
    fi
}


