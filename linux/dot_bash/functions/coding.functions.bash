#! /bin/bash
# TODO: Better documentation for these functions

FUNC_HELP_add_gitignore=( 'add target in current dir to .gitignore'
$'usage: add_gitignore

Assuming the pwd represents an app or lib dir with an executable or .so or .a
file named based on the dir name, then append the executable or lib name to the
.gitignore file, if it is not already listed.' )
function add_gitignore
{
    local dirname=`pwd | sed 's/.*\///'`
    local isapp1=`echo $dirname | sed  '/^app_/!d'`
    local isapp2=`echo $dirname | sed  '/^app/!d'`

    local target=""
    local add=0

    if [[ -n "$isapp1" ]]; then
        target=`echo $dirname | sed 's/^app_//'`
        if [[ -f ".gitignore" ]]; then
            if [[ "0" -eq `grep -c "$target" .gitignore` ]]; then
                add=1
            fi
        else
            add=1
        fi

    elif [[ -n "$isapp2" ]]; then
        target=`echo $dirname | sed 's/^app//'`
        if [[ -f ".gitignore" ]]; then
            if [[ "0" -eq `grep -c "$target" .gitignore` ]]; then
                add=1
            fi
        else
            add=1
        fi

    else
        target="lib"$dirname".so lib"$dirname".a"
        if [[ -f ".gitignore" ]]; then
            for x in $target; do
                if [[ "0" -eq `grep -c "$x" .gitignore` ]]; then
                    add=1
                fi
            done
        else
            add=1
        fi
    fi

    if [[ "0" != "$add" ]]; then
        for x in $target; do
            echo $x >> .gitignore
        done
    fi
}


FUNC_HELP_find_incs=(  'look for source files that #include the given header'
$'usage: find_incs <header_file>

Recursively search for c/c++ files under the current directory that #include
the given header.' )
function find_incs()
{
    while [[ -n "$1" ]]; do
        echo "Looking for header $1"
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        pattern="#include\ *[<\"].*$1"
        grep "$pattern" `find . \( -name '*.h' -o -name '*.hh' -o -name '*.cpp' -o -name '*.cc' -o -name '*.c' -o -name '*.tcc' -o -name '*.txx' \)  -print`
        echo
        echo
        shift
    done
}


FUNC_HELP_dbg=( 'open the debugger' '' )
function dbg()
{
    which gdb > /dev/null 2>&1
    if [[ "0" -eq "$?" ]]; then have_gdb=1; else have_gdb=0; fi;

    which ddd > /dev/null 2>&1
    if [[ "0" -eq "$?" ]]; then have_ddd=1; else have_ddd=0; fi;

    make show_target > /dev/null 2>&1
    if [[ "0" -eq "$?" ]]; then have_target=1; else have_target=0; fi;

    local target
    if [[ "1" -eq "$have_target" ]]; then
        target=`make show_target | sed 's/[ \t]*$//'`
    fi

    if [[ "1" -eq "$have_target" && ! -x "$target" ]]; then
        echo "Target $target does not exist"
        echo "Is a make needed?"
        return
    fi

    local core
    local pid
    if [[ -n "$1" ]]; then

        local proc_entry="/proc/"$1

        if [[ -x "$1" ]]; then

            # assume it is the target
            have_target=1
            target=$1

        elif [[ -d "$proc_entry" ]]; then

            # attach to pid
            have_target=1
            target=`cat /proc/$1/cmdline | sed 's/\x00.*//g'`
            pid=$1

        else

            # assume a plain old core file
            core=$1

        fi

    else
        core=`ls -1t core core.* 2> /dev/null | head --lines=1`
    fi

    if [[ "1" -eq "$have_target" ]]; then

        if [[ -n "$pid" ]]; then

            if [[ -n "$DISPLAY" && "1" -eq "$have_ddd" ]]; then

                echo "Starting ddd: ddd $target $pid"
                ddd $target $pid &

            elif [[ "1" -eq "$have_gdb" ]]; then

                echo "Starting gdb: gdb $target $pid"
                gdb $target $pid

            else

                echo "No debuger!?!?!"
                return

            fi


        elif [[ -n "$core" && -f "$core" ]]; then

            if [[ -n "$DISPLAY" && "1" -eq "$have_ddd" ]]; then

                echo "Starting ddd: ddd $target $core"
                ddd $target $core &

            elif [[ "1" -eq "$have_gdb" ]]; then

                echo "Starting gdb: gdb $target $core"
                gdb $target $core

            else

                echo "No debuger!?!?!"
                return

            fi

        else

            if [[ -n "$DISPLAY" && "1" -eq "$have_ddd" ]]; then

                echo "Starting ddd: ddd $target"
                ddd $target &

            elif [[ "1" -eq "$have_gdb" ]]; then

                echo "Starting gdb: gdb $target"
                gdb $target

            else

                echo "No debuger!?!?!"
                return

            fi

        fi

    elif [[ -f "$core" ]]; then

        # look for the most recent core
        local binary=`file $core | sed 's/.*from //' | sed "s/'//g"`

        echo "core: "$core
        echo "binary: "$binary

        if [[ -n "$DISPLAY" && "1" -eq "$have_ddd" ]]; then

            echo "Starting ddd: ddd $binary $core"
            ddd $binary $core &

        elif [[ "1" -eq "$have_gdb" ]]; then

            echo "Starting gdb: gdb $binary $core"
            gdb $binary $core

        else

            echo "No debuger!?!?!"
            return

        fi

    else

        echo "Nothing to do (no target, no core)"
        return

    fi
}


FUNC_HELP_ptrace=( 'Print a backtrace for all threads in a given process.'
$'usage: ptrace <executable> <core_dump_or_PID>' )
function ptrace()
{
    gdb -batch -ex "thread apply all bt" $1 $2
}


FUNC_HELP_gitb=( 'Print status of branch relative to "origin"'
$'usage: gitb [ <remote> ]

Print how many commits ahead/behind the current branch is relative to the
branch with the same name on the given git remote. If <remote> is not given
then assume "origin".' )
function gitb()
{
    local remote="origin"
    if [[ "$1" != "" ]]; then
        remote="$1"
    fi
    local branch=`git branch | grep '*' | cut -f2 -d' '`
    local ahead=`git log --pretty="%h" ${remote}/${branch}..${branch} | wc -l`
    local behind=`git log --pretty="%h" ${branch}..${remote}/${branch} | wc -l`
    branch="\033[1;35m${branch}\033[0m"
    remote="\033[1;36m${remote}\033[0m"
    if [[ "$ahead" != "0" ]]; then
        ahead="\033[1;32m${ahead}\033[0m"
    fi
    if [[ "$behind" != "0" ]]; then
        behind="\033[1;31m${behind}\033[0m"
    fi
    echo
    echo -e "Branch $branch is ahead/behind $remote by $ahead / $behind commits"
    echo
}


FUNC_HELP_sdiffdirs=( 'run diff against two source trees (like diffdirs for source code)' '' )
function sdiffdirs()
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
    echo "Running diff against the source directories $1 and $2"
    echo "----------------------------------------------------------------------"

    # if -x took regular expressions, that would be nice
    diff -r -w -B -b --brief "$1" "$2" | \
        sed -e '/\~/d;/\#/d;/autoscript\.gen/d;/\.obj/d;/\.deps/d;/\.build/d;/\.git/d'
}


FUNC_HELP_sfindgrep=( 'grep in source code' '' )
function sfindgrep()
{
    find . \( \
        -name "*.c" -o \
        -name "*.m" -o \
        -name "*.h" -o \
        -name "*.hh" -o \
        -name "*.hxx" -o \
        -name "*.tcc" -o \
        -name "*.cc" -o \
        -name "*.cp" -o \
        -name "*.cxx" -o \
        -name "*.cpp" -o \
        -name "*.c++" -o \
        -name "*.C" -o \
        -name "*.s" -o \
        -name "*.S" -o \
        -name "*.asm" -o \
        -name "*.java" -o \
        -name "*.pas" -o \
        -name "*.pl" -o \
        -name "*.tcl" -o \
        -name "*.hpp" -o \
        -name "*.sh)" -a \
        \) -type f -exec grep -Hne "$@" '{}' \;
}


FUNC_HELP_showincludes=( 'show #inclues of c/c++ source code in the current directory' '' )
function showincludes()
{
    cur=`pwd`

    header_list=`grep -h -e"^ *#include" [a-zA-Z0-9]*.c [a-zA-Z0-9]*.cpp [a-zA-Z0-9]*.C [a-zA-Z0-9]*.cxx [a-zA-Z0-9]*.CPP [a-zA-Z0-9]*.cc [a-zA-Z0-9]*.h [a-zA-Z0-9]*.hh [a-zA-Z0-9]*.hxx [a-zA-Z0-9]*.hpp [a-zA-Z0-9]*.H [a-zA-Z0-9]*.tpp [a-zA-Z0-9]*.tcc 2>/dev/null | \
        sed 's/^ *#include *<//;s/^ *#include *"//;s/>.*$//;s/".*$//' | \
        sort -f | \
        uniq`

    local_incs=`mktemp -t showincludes.local_incs.XXX`
    system_incs=`mktemp -t showincludes.system_incs.XXX`
    libs_incs=`mktemp -t showincludes.libs_incs.XXX`
    test_dir=`mktemp -t -d showincludes.test.XXX`

    for x in $header_list; do
        cd $cur

        if [[ -f "$x" ]]; then
            echo $x >> $local_incs
            continue
        fi

        echo "#include <"$x">" > ${test_dir}/main.cpp
        echo "int main() { return(0); }" >> ${test_dir}/main.cpp
        cd $test_dir
        g++ -E main.cpp > /dev/null 2>&1
        if [[ "0" -eq "$?" ]]; then
            echo $x >> $system_incs
        else
            echo $x >> $libs_incs
        fi
    done

    echo "# Local includes:"
    cat $local_incs
    echo
    echo "# System includes:"
    cat $system_incs
    echo
    echo "# Lib includes:"
    cat $libs_incs

    rm $local_incs $system_incs $libs_incs
    rm -rf $test_dir

    cd $cur
}


FUNC_HELP_sym=( 'search libraries for a symbol' '' )
function sym()
{
    if [[ -z "$1" ]]; then
        echo "ERROR -- specify symbol to find"
        return -1
    fi

    for x in `ls *.a *.so *.so.*`; do
        nm -A -C -l --defined-only $x 2>&1 | sed '/no symbols/d' | sed '/format not recognized/d' | grep -e "\b$1\b"
    done
}


FUNC_HELP_systemName=( 'print or set the $LMAS_SYSTEM_NAME'
$'usage: systemName [ <system_name> ]

If no system name was given, then print $LMAS_SYSTEM_NAME.
Otherwise, set $LMAS_SYSTEM_NAME to the given argument.' )
function systemName()
{
    if [[ -z "$1" ]]; then
        if [[ -z "$LMAS_SYSTEM_NAME" ]]; then
            echo "LMAS_SYSTEM_NAME is not set"
        else
            echo $LMAS_SYSTEM_NAME
        fi
    else
        export LMAS_SYSTEM_NAME=$1
        echo "LMAS_SYSTEM_NAME was set to "$LMAS_SYSTEM_NAME
    fi
}

