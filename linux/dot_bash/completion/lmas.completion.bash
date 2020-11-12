#! /bin/bash

_complete_run_nml_servers ()
{
    cur=${COMP_WORDS[COMP_CWORD]}

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W '-d --daemonize -f --force -i --ignoreSanityChecks -s --strictTypeChecking -v --verbose' -- $cur ) )
    else
        local wordlist

        for x in `ls $SYSTEM_PARAMS_DIR/NMLServers/*.cfg 2>/dev/null`; do
            wordlist=$wordlist" "`basename $x`
        done

        COMPREPLY=( $(compgen -W "$wordlist" "$2") )
    fi

    return 0
}

complete -F _complete_run_nml_servers run_nml_servers

_complete_RunNmlServer ()
{
    cur=${COMP_WORDS[COMP_CWORD]}

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W '-d --Daemonize -f --Force -i --IgnoreSanityChecks -s --StrictTypeChecking' -- $cur ) )
    else
        local wordlist

        for x in `ls $HOME/local/etc/NmlServers/*.cfg 2>/dev/null`; do
            wordlist=$wordlist" "`basename $x`
        done

        COMPREPLY=( $(compgen -W "$wordlist" "$2") )
    fi

    return 0
}

complete -F _complete_RunNmlServer RunNmlServer

_complete_to_socket ()
{
    cur=${COMP_WORDS[COMP_CWORD]}

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W '-h --help -f --input -i --ipaddr -t --tee -v --verbose' -- $cur ) )
    fi

    return 0
}

complete -F _complete_to_socket to_socket


_complete_data_server ()
{
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W '-a --printAlive -c intervalForHealthCheck -e --dataServerName -f --forceExecution -i --ignoreHealth -m --nml_module_name -n --nml_config -p --params_module -t --traceMemoryAllocs' -- $cur ) )
    else
        local wordlist

        if [[ "-p" == "$prev" ]]; then
            # Complete params dir name
            for x in `ls -dF $SYSTEM_PARAMS_DIR/DataServer* 2>/dev/null | grep / | sed 's/\/$//'`; do
                wordlist=$wordlist" "`basename $x`
            done
        elif [[ "-n" == "$prev" ]]; then
            # Complete nml config file name
            nml_path="$HOME/Installed/nml"
            nmls=`ls $nml_path 2>/dev/null`
            for x in $nmls; do
                wordlist=$wordlist" "`basename $x`
            done

            nml_path="$HOME/Installed/nml."`hostname -s`
            nmls=`ls $nml_path 2>/dev/null`
            for x in $nmls; do
                wordlist=$wordlist" "`basename $x`
            done

            wordlist=`echo $wordlist | sort | uniq`
        fi

        COMPREPLY=( $(compgen -W "$wordlist" "$2") )
    fi

    return 0
}

complete -F _complete_data_server data_server


_complete_data_server_control ()
{
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W '-v --verbose -e --dataServerName -n --nml_config -p --params_module ' -- $cur ) )
    else
        local wordlist

        if [[ "-p" == "$prev" ]]; then
            # Complete params dir name
            for x in `ls -dF $SYSTEM_PARAMS_DIR/DataServer* 2>/dev/null | grep / | sed 's/\/$//'`; do
                wordlist=$wordlist" "`basename $x`
            done
        elif [[ "-n" == "$prev" ]]; then
            # Complete nml config file name
            nml_path="$HOME/Installed/nml"
            nmls=`ls $nml_path 2>/dev/null`
            for x in $nmls; do
                wordlist=$wordlist" "`basename $x`
            done

            #nml_path="$HOME/Installed/nml."`hostname -s`
            nml_path="$HOME/Installed/nml."`hostname`
            nmls=`ls $nml_path 2>/dev/null`
            for x in $nmls; do
                wordlist=$wordlist" "`basename $x`
            done

            wordlist=`echo $wordlist | sort | uniq`
        fi

        COMPREPLY=( $(compgen -W "$wordlist" "$2") )
    fi

    return 0
}

complete -F _complete_data_server_control data_server_control


_complete_mrxvt_launcher ()
{
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W '-i --mrxvt-config-file -v --verbose -c --mrxvt-config -d --debug' -- $cur ) )
    else
        local wordlist

        if [[ "-i" == "$prev" ]]; then
            # Complete Mrxvt inputs
            for x in `ls -dF $SYSTEM_PARAMS_DIR/MrxvtLauncher/* 2>/dev/null | grep / | sed 's/\/$//'`; do
                wordlist=$wordlist" "`basename $x`
            done
        elif [[ "-d" == "$prev" ]]; then
            # Complete the possible debug levels
            wordlist="trace debug1 debug2 debug3 info note warn error critical fatal disable"
        fi

        COMPREPLY=( $(compgen -W "$wordlist" "$2") )
    fi

    return 0
}

complete -F _complete_mrxvt_launcher mrxvt_launcher

