#! /bin/bash
# NOTE: Must source this after core.vars.bash and coding.vars.bash since this
# file uses some vars that are set in those files.

# Only do this stuff the first time .bashrc is loaded
if [[ -z "$_SOURCE_BASHRC_ONCE" ]]; then

    readonly _SOURCE_BASHRC_ONCE=true
    # setup the PATH and MANPATH (order is important here!)
    add_PATH PATH     /sbin
    add_PATH PATH     /usr/sbin
    add_PATH PATH     /usr/local/sbin
    add_PATH PATH     /usr/local/bin
    add_PATH MANPATH  /usr/local/share/man
    # default dir where we normally install cots packages
    add_PATH PATH     /usr/local/lmas/bin
    add_PATH MANPATH  /usr/local/lmas/share/man
    # assume users have a ~/bin dir where they store their own misc executables/scripts
    add_PATH PATH $RUN_AS_USER_HOME/bin

    PYTHON_VERSION="python"
    which python > /dev/null 2>&1
    if [[ "$?" == "0" ]]; then
        PYTHON_VERSION=`python -c 'import sys; print("python{0}.{1}".format(sys.version_info[0],sys.version_info[1]))'`
    fi
    # setup PKG_CONFIG_PATH and LD_LIBRARY_PATH (order is important here!)
    # NOTE: ld.so looks in /lib, /usr/lib, /lib64, and /usr/lib64 by default
    LD_LIBRARY_PATH=""
    PKG_CONFIG_PATH=/usr/lib/pkgconfig
    PYTHONPATH=""
    add_PATH LD_LIBRARY_PATH /usr/local/lib
    add_PATH PKG_CONFIG_PATH /usr/local/lib/pkgconfig
    add_PATH PYTHONPATH /usr/local/lib/${PYTHON_VERSION}/site-packages
    if [[ $IS_64_BIT ]]; then
        add_PATH PKG_CONFIG_PATH /usr/lib64/pkgconfig
        add_PATH PKG_CONFIG_PATH /usr/local/lib64/pkgconfig
        add_PATH LD_LIBRARY_PATH /usr/local/lib64
        add_PATH PYTHONPATH /usr/local/lib64/${PYTHON_VERSION}/site-packages
    fi

    # This is the default dir where we normally build and install cots packages
    add_PATH LD_LIBRARY_PATH /usr/local/lmas/lib
    add_PATH PKG_CONFIG_PATH /usr/local/lmas/lib/pkgconfig
    add_PATH PYTHONPATH      /usr/local/lmas/lib/$PYTHON_VERSION/site-packages
    if [[ $IS_64_BIT ]]; then
        add_PATH LD_LIBRARY_PATH /usr/local/lmas/lib64
        add_PATH PKG_CONFIG_PATH /usr/local/lmas/lib64/pkgconfig
        add_PATH PYTHONPATH      /usr/local/lmas/lib64/$PYTHON_VERSION/site-packages
    fi

    # If LMAS_COTS_DIR has been defined, then it should take priority over the
    # default /usr/local/lmas cots installation dir
    if [[ "$LMAS_COTS_DIR" != "" ]]; then
        add_PATH PATH            $LMAS_COTS_DIR/bin
        add_PATH MANPATH         $LMAS_COTS_DIR/share/man
        add_PATH LD_LIBRARY_PATH $LMAS_COTS_DIR/lib
        add_PATH PKG_CONFIG_PATH $LMAS_COTS_DIR/lib/pkgconfig
        add_PATH PYTHONPATH      $LMAS_COTS_DIR/lib/$PYTHON_VERSION/site-packages
        if [[ $IS_64_BIT ]]; then
            add_PATH LD_LIBRARY_PATH $LMAS_COTS_DIR/lib64
            add_PATH PKG_CONFIG_PATH $LMAS_COTS_DIR/lib64/pkgconfig
            add_PATH PYTHONPATH      $LMAS_COTS_DIR/lib64/$PYTHON_VERSION/site-packages
        fi
    # Otherwise, assume that project-specific cots packages are installed
    # relative to LMAS_BASE_DIR
    elif [[ "$LMAS_BASE_DIR" != "" ]]; then
        add_PATH PATH            $LMAS_BASE_DIR/cots/bin
        add_PATH MANPATH         $LMAS_BASE_DIR/cots/share/man
        add_PATH LD_LIBRARY_PATH $LMAS_BASE_DIR/cots/lib
        add_PATH PKG_CONFIG_PATH $LMAS_BASE_DIR/cots/lib/pkgconfig
        add_PATH PYTHONPATH      $LMAS_BASE_DIR/cots/lib/$PYTHON_VERSION/site-packages
        if [[ $IS_64_BIT ]]; then
            add_PATH LD_LIBRARY_PATH $LMAS_BASE_DIR/cots/lib64
            add_PATH PKG_CONFIG_PATH $LMAS_BASE_DIR/cots/lib64/pkgconfig
            add_PATH PYTHONPATH      $LMAS_BASE_DIR/cots/lib64/$PYTHON_VERSION/site-packages
        fi
    # Otherwise, assume that project-specific cots packages are installed to the
    # default location
    else
        add_PATH PATH            $RUN_AS_USER_HOME/local/cots/bin
        add_PATH MANPATH         $RUN_AS_USER_HOME/local/cots/share/man
        add_PATH LD_LIBRARY_PATH $RUN_AS_USER_HOME/local/cots/lib
        add_PATH PKG_CONFIG_PATH $RUN_AS_USER_HOME/local/cots/lib/pkgconfig
        add_PATH PYTHONPATH      $RUN_AS_USER_HOME/local/cots/lib/$PYTHON_VERSION/site-packages
        if [[ $IS_64_BIT ]]; then
            add_PATH LD_LIBRARY_PATH $RUN_AS_USER_HOME/local/cots/lib64
            add_PATH PKG_CONFIG_PATH $RUN_AS_USER_HOME/local/cots/lib64/pkgconfig
            add_PATH PYTHONPATH      $RUN_AS_USER_HOME/local/cots/lib64/$PYTHON_VERSION/site-packages
        fi
    fi

    # If LMAS_BASE_DIR is defined, then assume our own build products are
    # installed inside of it. Otherwise, assume our build products are installed
    # to the default location.
    # NOTE: SconsSetup uses the -rpath flag during compilation, so
    # LD_LIBRARY_PATH does not need to include the path where we install our own
    # internal libraries.
    localBuild=""
    if [[ "$LMAS_BASE_DIR" != "" ]]; then
        localBuild="$LMAS_BASE_DIR/build"
    else
        localBuild="$RUN_AS_USER_HOME/local/build"
    fi
    add_PATH PATH ${localBuild}/bin
    add_PATH PYTHONPATH ${localBuild}/lib/$PYTHON_VERSION/site-packages
    add_PATH PYTHONPATH ${localBuild}/lib64/$PYTHON_VERSION/site-packages

    # put these on the end since they may contain binaries (eg, sed, cmake,
    # etc.) that should only be used if they can't be found elsewhere
    add_PATH PATH /usr/local/kde/bin append check
    add_PATH PATH /opt/gnome/bin append check
    add_PATH PATH /opt/kde3/bin append check
    add_PATH PATH $QTDIR/bin append check

    export PATH
    export LD_LIBRARY_PATH
    export PKG_CONFIG_PATH
    export PYTHONPATH
    export MANPATH

    export DEFAULT_PATH=$PATH
    export DEFAULT_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
    export DEFAULT_PKG_CONFIG_PATH=$PKG_CONFIG_PATH


    export PLATFORM_OS=`uname -o`
    if [[ "$PLATFORM_OS" == "linux" || "$PLATFORM_OS" == "GNU/Linux" || "$PLATFORM_OS" == "linux-gnu" ]]; then
        export PLATFORM_OS="linux"
    fi

    if [[ "$PLATFORM_OS" == "linux" ]]; then

        if [[ -f "/etc/SuSE-release" ]]; then
            export PLATFORM_FLAVOR="suse"
            export PLATFORM_VERSION=`cat /etc/SuSE-release | sed '2!d; s/.* = //'`

        elif [[ -f "/etc/fedora-release" ]]; then
            export PLATFORM_FLAVOR="fedora"
            export PLATFORM_VERSION=`cat /etc/fedora-release | sed 's/Fedora Core release //' | awk '{ print $1 }'`

        elif [[ -f "/etc/redhat-release" ]]; then
            export PLATFORM_FLAVOR="redhat"
            export PLATFORM_VERSION=`cat /etc/redhat-release | sed 's/Red Hat Linux release //' | awk ' { print $1 } '`

        elif [[ -f "/etc/lsb-release" ]]; then
            export PLATFORM_FLAVOR=`cat /etc/lsb-release | sed '/DISTRIB_ID/!d' | awk 'BEGIN { FS="=" } { print $2 }'`
            export PLATFORM_VERSION=`cat /etc/lsb-release | sed '/DISTRIB_RELEASE/!d' | awk 'BEGIN { FS="=" } { print $2 }'`

        else
            export PLATFORM_FLAVOR=$PLATFORM_OS
            export PLATFORM_VERSION=
        fi

    elif [[ "$PLATFORM_OS" = "Cygwin" ]]; then
        export PLATFORM_FLAVOR=PLATFORM_OS
        export PLATFORM_VERSION=`uname -s | sed 's/-/ /' | awk '{ print $2 } '`

    else
        export PLATFORM_FLAVOR=$PLATFORM_OS
        export PLATFORM_VERSION=

    fi

    export LOGGED_IN_FROM=`who am i | sed 's/.*(//; s/)//'`
    if [[ "`echo $LOGGED_IN_FROM | wc -w`" != "1" ]]; then
        export LOGGED_IN_FROM=localhost
    fi


    if [[ -z "$DISPLAY" ]]; then
        DISPLAY=$LOGGED_IN_FROM":0.0"
    fi

    # Print useful info the first time the .bashrc is sourced
    if [[ "$INTERACTIVE" != "0" && 0 != $UID && "$BASHRC_VERBOSE" != "0" ]]; then
        echo "OS: "`uname -s`" "`uname -r`
        echo "Distribution: "$PLATFORM_FLAVOR" ("$PLATFORM_VERSION")"
        echo

        echo "Machine stats:"
        uptime
        echo

        cpus
        echo

        if [[ "$PLATFORM_OS" = "linux" ]]; then
            echo "IP configuration:"
            ips
            echo
        fi

        date
        echo

        if [[ ! -z "$LOGGED_IN_FROM" ]]; then
            echo "Logged in from: "$LOGGED_IN_FROM
            echo
        fi
    fi

    if [[ "$INTERACTIVE" != "0" && "$BASHRC_VERBOSE" != "0" ]]; then
        if [[ "$USER" != "$RUN_AS_USER" ]]; then
            echo "NOTE: running as another user ("$RUN_AS_USER")"
            echo
        fi

        if [[ "t" == "$EMACS" && "eterm" = "$TERM" ]]; then
            echo "emacs terminal tips:"
            echo "~~~~~~~~~~~~~~~~~~~~"
            echo "M-x rename-buffer  Rename buffer"
            echo "M-x rename-uniquely  Automatically rename buffer"
            echo "C-c C-j  Set input mode to line mode (shell)"
            echo "C-c C-k  Set input mode to char mode"
            echo
            echo "In char mode, C-c C-c sends a literal C-c to the subshell"
            echo
        elif [[ "t" == "$EMACS" ]]; then
            echo "hello emacs shell"
        elif [[ "screen" = "$TERM" ]]; then
            echo "hello screen"
       fi
    fi

    if [[ "$INTERACTIVE" != "0" ]]; then

        if [[ "screen" != "$TERM" ]]; then
            which screen > /dev/null 2>&1
            if [[ "0" == "$?" ]]; then

                l=`screen -ls 2> /dev/null | wc -l`

                if [[ "$l" -eq "4" ]]; then
                    echo "screen active:"
                    echo "      resume politely with 'screen -R'"
                    echo "      resume forcefully with 'screen -D -R'"
                    echo
                elif [[ "$l" -gt "4" ]]; then
                    echo "multiple screen sessions active:"
                    echo "      resume with 'screen -r sessionowner/[pid.tty.host]'"
                    echo "      list sessions with 'screen -ls'"
                    echo
                fi

                unset l

            fi
        fi

        if [[ ! -d "${localBuild}" ]]; then
            symlinkName=${localBuild}
            symlinkTarget=${localBuild/build/release}
            echo "WARNING: Directory \"$localBuild\" does not exist."
            echo "    PATH assumes our binaries will be installed here. You may be missing a"
            echo "    symlink, which you can create with the command below. The purpose of this"
            echo "    symlink is to make it easy to switch between debug/release builds."
            echo "        ln -s $symlinkTarget $symlinkName"
            unset symlinkName symlinkTarget
        fi
        unset localBuildBin
    fi
fi  # end if SOURCE_BASHRC_ONCE
