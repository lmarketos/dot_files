#! /bin/bash


_complete_unison ()
{
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W '-addprefsto -addversionno -auto -backup -backupdir -backupnot -backups -batch -contactquietly -debug -doc -dumbtty -fastcheck -follow -force -group -height -host -ignore -ignorecase -ignorelocks -ignorenot -immutable -immutablenot -key -killserver -label -log -logfile -maxbackupage -maxbackups -maxthreads -merge -mergebatch -minbackups -numericids -owner -path -perms -prefer -pretendwin -repeat -retry -root -rootalias -rsrc -rsync -servercmd -showarchive -silent -socket -sortbysize -sortfirst -sortlast -sortnewfirst -sshargs -sshcmd -terse -testserver -times -ui -version -xferbycopyinga' -- $cur ) )

#    elif [[ "-addprefsto" == "$prev" ]]; then
#        echo "duh"

#    elif [[ "-backup" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-backupdir" == "$prev" ]]; then
#        echo "duh"

#    elif [[ "-backupnot" == "$prev" ]]; then
#        COMPREPLY=

    elif [[ "-debug" == "$prev" ]]; then
        COMPREPLY=( $( compgen -W "all verbose"))

#    elif [[ "-doc" == "$prev" ]]; then
#        COMPREPLY=

    elif [[ "-fastcheck" == "$prev" ]]; then
        COMPREPLY=COMPREPLY=( $( compgen -W "true false default"))

#    elif [[ "-follow" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-force" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-height" == "$prev" ]]; then
#        COMPREPLY="0 1 2 3 4 5 6 7 8 9"

#    elif [[ "-host" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-ignore" == "$prev" ]]; then
#        COMPREPLY=

    elif [[ "-ignorecase" == "$prev" ]]; then
        COMPREPLY=COMPREPLY=( $( compgen -W "true false default"))

#    elif [[ "-ignorenot" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-immutable" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-immutablenot" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-key" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-label" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-logfile" == "$prev" ]]; then
#        echo "duh"

#    elif [[ "-maxbackupage" == "$prev" ]]; then
#        COMPREPLY="0 1 2 3 4 5 6 7 8 9"

#    elif [[ "-maxbackups" == "$prev" ]]; then
#        COMPREPLY="0 1 2 3 4 5 6 7 8 9"

#    elif [[ "-maxthreads" == "$prev" ]]; then
#        COMPREPLY="0 1 2 3 4 5 6 7 8 9"

#    elif [[ "-merge" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-mergebatch" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-minbackups" == "$prev" ]]; then
#        COMPREPLY="0 1 2 3 4 5 6 7 8 9"

#    elif [[ "-path" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-perms" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-prefer" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-repeat" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-retry" == "$prev" ]]; then
#        COMPREPLY="0 1 2 3 4 5 6 7 8 9"

#    elif [[ "-root" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-rootalias" == "$prev" ]]; then
#        COMPREPLY=

    elif [[ "-rsrc" == "$prev" ]]; then
        COMPREPLY=COMPREPLY=( $( compgen -W "true false default"))

#    elif [[ "-servercmd" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-socket" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-sortfirst" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-sortlast" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-sshargs" == "$prev" ]]; then
#        COMPREPLY=

#    elif [[ "-sshcmd" == "$prev" ]]; then
#        echo "duh"

    elif [[ "-ui" == "$prev" ]]; then
        COMPREPLY=COMPREPLY=( $( compgen -W "text graphic"))

    else
        local wordlist

        for x in `ls $HOME/.unison/*.prf 2>/dev/null`; do
            wordlist=$wordlist" "`basename $x`
        done

        COMPREPLY=( $(compgen -W "$wordlist" "$2") )
    fi

    return 0
}

complete -F _complete_unison unison


_complete_make ()
{
    local toplevel_targets="all backup browse check check_local_needs clean cvscheckout cvsco cvsexport cvsstat cvsstatus cvstag cvsup cvsupdate cvsupdateq cvsupdateqn cvsupq cvsupqn debug default distclean ebrowse help install manifest profile release set_to_debug set_to_default set_to_profile set_to_release show tags tar tarball tests touch uninstall"

    local node_targets="all backup browse build_pre_cmd check check_extra_headers check_extra_libs check_local_needs clean ddd debug default distclean docs ebrowse gdb help install manifest printenv profile release run set_to_debug set_to_default set_to_profile set_to_release show show_all_c_cpp_src show_build_manifest show_build_system show_haves show_libtarget show_needs show_target tags tar tarball uninstall why"

    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    if [[ "-f" == "$prev" || "--file" == "$prev" || "--makefile" == "$prev" ]]; then

        local makefiles=`ls -1 GNUmakefile makefile Makefile GNUmakefile.* makefile.* Makefile.* 2> /dev/null`
        COMPREPLY=( $(compgen -W "$makefiles" "$2") )

    elif  [[ "$cur" == -* ]]; then

        COMPREPLY=( $( compgen -W '-b -m -B --always-make -C --directory -d --debug -e --environment-overrides -f --file --makefile -h --help -i --ignore-errors -I --include-dir -j --jobs -k --keep-going -l --load-average --max-load -L --check-symlink-times -n --just-print --dry-run --recon -o --old-file --assume-old -p --print-data-base -q --question -r --no-builtin-rules -R --no-builtin-variables -s --silent --quiet -S --no-keep-going --stop -t --touch -v --version -w --print-directory --no-print-directory -W --what-if --new-file --assume-new --warn-undefined-variables' -- $cur ) )

    else

        local local_makefiles=`ls -1 GNUmakefile makefile Makefile GNUmakefile.* makefile.* Makefile.* 2> /dev/null`

        local is_toplevel=0

        for x in $local_makefiles; do

            grep -c 'toplevel_post' $x > /dev/null 2>&1
            if [[ "0" -eq "$?" ]]; then
                is_toplevel=1
                break;
            fi
        done

        if [[ "1" -eq "$is_toplevel" ]]; then

            COMPREPLY=( $(compgen -W "$toplevel_targets" "$2") )

        else

            COMPREPLY=( $(compgen -W "$node_targets" "$2") )

        fi
    fi

    return 0
}

complete -F _complete_make make
