#! /bin/bash
# TODO: Better documentation for these functions


FUNC_HELP_alive=( 'determine if a machine responds to pings'
$'usage: alive <host>' )
function alive()
{
    ping -c 1 -W 2 -w 2 $1 > /dev/null 2>&1
    if [[ "$?" -eq "0" ]]; then
        echo $1" has pingage"
        return 0
    else
        echo $1" appears dead; no pingage"
        return 1
    fi
}



FUNC_HELP_check_dns=( 'see if DNS machines in /etc/resolv.conf have pingage' '' )
function check_dns()
{
    if [[ -f "/etc/resolv.conf" ]]; then
        echo "Checking name servers..."
        local servers=`cat /etc/resolv.conf | sed -n '/^nameserver/p' | awk ' { print $2 } '`
        for x in $servers; do
            alive $x
        done
        echo

        local this_hostname=`uname -n`
        local local_hostnames=$this_hostname

        nets=`cat /etc/resolv.conf | sed '/^search/!d' | sed 's/^search //'`
        for x in $nets; do
            local_hostnames=$local_hostnames" "$this_hostname"."$x
        done

        iplist=`ips | awk '{ print $3}'`
        local found=0
        for x in $iplist; do
            dns_hostname=`host $x | sed '/domain name pointer/!d' | sed 's/.*domain name pointer //' | sed 's/\.$//'`
            if [[ -n "$dns_hostname" ]]; then
                for y in $local_hostnames; do
                    if [[ "$dns_hostname" = "$y" ]]; then
                        found=1
                    fi
                done
            fi
        done

        if [[ 1 -ne "$found" ]]; then
            echo "WARNING -- DNS hostname does not agree with system hostname!"
        else
            echo "DNS hostname check OK"
        fi

    else
        echo "/etc/resolv.conf does not exist, cannot check DNS!"
    fi
}



FUNC_HELP_cptomachine=( 'copy files to a machine using scp' '' )
function cptomachine()
{
    local um=$1

    if [[ -f "$um" || -z "$um" ]]; then
        echo "Usage: cptomachine <user@machine> [file/dir 1] [file/dir 2] ..."
        return -1
    fi

    shift

    local um_list=`echo $um | sed 's/@/ /'`
    local user=`echo $um_list | awk ' { print $1 } '`
    local machine=`echo $um_list | awk ' { print $2 } '`

    if [[ -z "$machine" ]]; then
        machine=$user
        user=`whoami`
    fi

    echo "user: "$user
    echo "machine: "$machine

    while [[ -n "$1" ]]; do
        if [[ -f "$1" || -d "$1" ]]; then
            scp -r -p $1 $user"@"$machine":""$1"

            # this still screws up if there are spaces in the file name
            #            fname=`echo $1 | sed 's/ /\\ /g'`
            #            to_arg=$user"@"$machine":"$fname
            #            echo "Transfering file \""$fname"\""
            #            echo "to: \""$to_arg"\""
            #            print_args scp -r -p $fname $to_arg

        else
            echo "Not a file or directory: "$1
        fi
        shift
    done
}


FUNC_HELP_ipconfig=( 'print network config info' '' )
function ipconfig()
{
    echo "ifconfig"
    echo "~~~~~~~~"
    ifconfig -a
    echo

    which iwconfig > /dev/null 2>&1
    if [[ "0" -eq "$?" ]]; then
        echo "iwconfig"
        echo "~~~~~~~~"
        iwconfig
        echo
    fi

    echo "Routing"
    echo "~~~~~~~"
    route -n
    echo
    echo

    echo "DNS"
    echo "~~~"
    cat /etc/resolv.conf | sed 's/^ *//' | sed '/^#/d' | sed '/^$/d'
    echo
    echo

    echo "Proxy Configuration"
    echo "~~~~~~~~~~~~~~~~~~~"
    echo "HTTP proxy (http_proxy):  "$http_proxy
    echo "HTTPS proxy (https_proxy): "$https_proxy
    echo "FTP proxy (ftp_proxy):   "$ftp_proxy
    echo "no proxy (no_proxy):    "$no_proxy
    echo
}


FUNC_HELP_ips=( 'print network config info' '' )
function ips()
{
    if [[ "$PLATFORM_OS" = "linux" ]]; then

        if [[ -z "$1" ]]; then
            local adapters=`cat /proc/net/dev | sed '1,2d; s/:.*//;'`
        else
            local adapters="$*"
        fi

        for x in $adapters; do
            local ipaddr=`/sbin/ifconfig $x 2>/dev/null |  awk '/inet/ { print $2 } ' | sed -e s/addr://`
            local stat=`ethtool $x 2>/dev/null | sed '/Link detected/!d; s/.*: //; s/yes/link detected/; s/no/no link/'`
            if [[ -n "$ipaddr"  ]]; then
                echo $x" : "$ipaddr" ("$stat")"
            fi
        done
    fi
}



FUNC_HELP_network_discover=( 'call nmap to find hosts on the network' '' )
function network_discover()
{
    if [[ -z "$1" ]]; then
        for x in `ifconfig | sed '/^[a-zA-Z0-9]/!d' | awk '{ print $1 }'`; do
            arg=`ifconfig "$x" | grep Bcast | sed 's/.*Bcast://' | awk ' { print $1 } ' | sed 's/255/0-254/g'`

            if [[ -n "$arg" ]]; then
                echo "Scanning $arg ($x)"
                echo "------------------------------------------------------------------------------"
                nmap -n -sP "$arg"
                echo
            fi
        done
    else
        while [[ -z "$1" ]]; do
            echo "Scanning $1"
            echo "------------------------------------------------------------------------------"
            nmap -n -sP "$1"
            echo
            shift
        done
    fi
}


FUNC_HELP_pt=( 'ping test' '' )
function pt()
{
    ping -c 1 -w 2 -W 2 localhost > /dev/null 2>&1
    if [[ "0" -eq "$?" ]]; then
        echo "localhost: OK"
    else
        echo "localhost: FAILED"
        return -1
    fi

    ping -c 1 -w 2 -W 2 `hostname` > /dev/null 2>&1
    if [[ "0" -eq "$?" ]]; then
        echo "hostname ("`hostname`"): OK"
    else
        echo "hostname ("`hostname`"): FAILED (WARNING!)"
    fi

    default_gateway=`ip route show | grep default | awk ' { print $3 } '`
    if [[ -n "$default_gateway" ]]; then
        ping -c 1 -w 2 -W 2 $default_gateway > /dev/null 2>&1
        if [[ "0" -eq "$?" ]]; then
            echo "default gateway ("$default_gateway"): OK"
        else
            echo "default gateway ("$default_gateway"): FAILED"
            return -1
        fi
    else
        echo "WARNING -- no default gateway?"
        return -1
    fi

    if [[ ! -f "/etc/resolv.conf" ]]; then
        echo "WARNING -- no /etc/resolv.conf"
        return -1
    fi

    nameservers=`cat /etc/resolv.conf | sed '/^nameserver/!d' | awk ' { print $2 } '`
    for x in $nameservers; do
        ping -c 1 -w 2 -W 2 $x > /dev/null 2>&1
        if [[ "0" -eq "$?" ]]; then
            echo "nameserver ("$x"): OK"
        else
            echo "nameserver ("$x"): FAILED"
            return -1
        fi
    done

    external=www.google.com
    ping -c 1 -w 2 -W 2 $external > /dev/null 2>&1
    if [[ "0" -eq "$?" ]]; then
        echo $external": OK"
    else
        echo $external": FAILED"
        return -1
    fi
}


FUNC_HELP_pushkey=( 'push ssh keys to a remote machine; generate if necessary' '' )
function pushkey()
{
    echo "*"
    echo "* This function is deprecated as it is redundant with current ssh functionality"
    echo "*"
    echo
    echo "To generate public keys, execute the command:"
    echo "    $ ssh-keygen -t dsa"
    echo
    echo "To add ssh public keys to user@host, execute the command:"
    echo "    $ ssh-copy-id -i ~/.ssh/id_dsa.pub user@host"
    echo
    echo "To change your passphrase, execute the command:"
    echo "    $ ssh-keygen -p"
    echo

    return -1
}



FUNC_HELP_sshaliases=( 'make machine login aliases using the machines found in .ssh/known_hosts' '' )
function sshaliases()
{
    if [[ -f "$HOME/.local_cfg" ]]; then
        source $HOME/.local_cfg
    fi

    if [[ -z "LOCAL_SSH_ALIAS_USER" ]]; then
        local LOCAL_SSH_ALIAS_USER=`whoami`
    fi

    local USER=`whoami`

    if [[ -n "$1" ]]; then
        local force=1
    else
        local force=0
    fi

    if [[ -f "$HOME/.ssh/known_hosts" ]]; then

        if [[ "$HOME/.ssh/known_hosts" -nt "$HOME/.sshaliases" || "1" -eq "$force" ]]; then
            if [[ "$INTERACTIVE" -ne "0" ]]; then
                echo "Updating ssh aliases..."
            fi
            local ssh_hosts=`cat $HOME/.ssh/known_hosts | sed 's/ .*//g' | sed 's/,/ /g' | sort | uniq`

            local tmp=`mktemp /tmp/sshaliases.XXXXXX`

            if [[ -f "/etc/resolv.conf" ]]; then
                # get DNS search paths, for shortening the full host name
                local search_paths=`cat /etc/resolv.conf | sed  '/^search/!d' | sed 's/^search //' | sed 's/^/\./'`

                if [[ -n "$search_paths" ]]; then
                    for full_hostname in $ssh_hosts; do
                        for x in $search_paths; do
                            local new_name=`echo $full_hostname | sed "s/$x\$//"`
                            echo $new_name >> $tmp
                        done
                    done
                else
                    for full_hostname in $ssh_hosts; do
                        echo $full_hostname >> $tmp
                    done
                fi
            else
                for full_hostname in $ssh_hosts; do
                    echo $full_hostname >> $tmp
                done
            fi

            ssh_hosts=`cat $tmp | sed '/^[0-9].*\.[0-9].*\.[0-9].*\.[0-9]/d' | sort | uniq`

            rm -f $HOME/.sshaliases
            touch $HOME/.sshaliases
            for x in $ssh_hosts; do

                echo "alias \"$x\"=\"ns $x; ssh '"'$LOCAL_SSH_ALIAS_USER'"'@$x \$1 \$2 \$3 \$4 \$5 \$6 \$7 \$8 \$9; ns CLEAR\"" >> $HOME/.sshaliases

                echo "alias \"$LOCAL_SSH_ALIAS_USER@$x\"=\"ns $x; ssh $LOCAL_SSH_ALIAS_USER@$x \$1 \$2 \$3 \$4 \$5 \$6 \$7 \$8 \$9; ns CLEAR\"" >> $HOME/.sshaliases

                echo "alias \"$USER@$x\"=\"ns $x; ssh $USER@$x \$1 \$2 \$3 \$4 \$5 \$6 \$7 \$8 \$9; ns CLEAR\"" >> $HOME/.sshaliases

                echo "alias \"root@$x\"=\"ns \"root@\"$x; ssh root@$x \$1 \$2 \$3 \$4 \$5 \$6 \$7 \$8 \$9; ns CLEAR\"" >> $HOME/.sshaliases
                echo "alias \"$x@$x\"=\"ns $x; ssh $x@$x \$1 \$2 \$3 \$4 \$5 \$6 \$7 \$8 \$9; ns CLEAR\"" >> $HOME/.sshaliases
                echo >> $HOME/.sshaliases
            done

            rm -f $tmp
        fi

        if [[ -f "$HOME/.sshaliases" ]]; then
            source $HOME/.sshaliases
        fi
    fi
}


FUNC_HELP_sshkill=( 'delete entries from $HOME/.ssh/known_hosts'
$'usage sshkill <host>

This function will delete entries in $HOME/.ssh/known_hosts from the command
line. This is necessary when other machines change OS, etc. Pass in host names
or ip addresses on the command line' )
function sshkill()
{
    echo "NOT PROPERLY WORKING, EDIT MANUALLY"
    return -1

    if [[ -z "$1" ]]; then
        echo "ERROR -- specify host(s) to kill from .ssh/known_hosts!"
        return -1
    fi

    if [[ ! -d "$HOME/.ssh" ]]; then
        echo "ERROR -- .ssh does not exist in your home directory!"
        return -1
    fi

    pushd "$HOME/.ssh"

    if [[ -f "known_hosts" ]]; then
        cp known_hosts known_hosts.bak
        local fname=`mktemp /tmp/tmp.XXXXXX`
        local awk_program=`mktemp /tmp/awk.XXXXXX`
        while [[ -n "$1" ]]; do
            echo "host arg is: "$1

            # get an alphanumeric host name
            local full_hostname=`host $1 | sed 's/ has address.*//' | sed 's/^.*domain name pointer //' | sed 's/\.$//'`

            # get an ip address
            local ip_addr=`host $1 | sed 's/^.*has address //' | awk ' BEGIN { FS="." } { if ( "in-addr" == $5 ) { print $4"."$3"."$2"."$1 } else { print } } '`

            local search_tokens="$full_hostname $ip_addr"

            # get DNS search paths, for shortening the full host name
            local search_paths=`cat /etc/resolv.conf | sed  '/^search/!d' | sed 's/^search //' | sed 's/^/\./'`

            for x in $search_paths; do
                local new_name=`echo $full_hostname | sed "s/$x\$//"`
                search_tokens="$search_tokens $new_name"
                echo
            done

            for x in $search_tokens; do
                echo "weeding out: "$x
                echo "{ if ( ! ((\$1 == \"$x\" ) || (\$1 ~ /^$x,/) || (\$1 ~ /,$x,/) || (\$1 ~ /,$x\$/) ) ) { print \$0 } }" > $awk_program
                cat known_hosts | awk -f $awk_program > $fname
                cp $fname known_hosts
            done

            shift
        done
        rm -f $fname $awk_program
    fi
    popd
}



FUNC_HELP_static_ip=( 'configure a static ip address for a device' '' )
function static_ip()
{
    if [[ -f "$HOME/.local_net_cfg" ]]; then
        source $HOME/.local_net_cfg
    else
        echo "Local configuration missing from ~/.local_net_cfg"
        return -1

    fi

    if [[ -z "$LOCAL_STATIC_IP_ADDRESS" ]]; then echo "LOCAL_STATIC_IP_ADDRESS must be specified in $HOME/.local_net_cfg"; return -1; fi
    if [[ -z "$LOCAL_STATIC_HOSTNAME" ]]; then echo "LOCAL_STATIC_HOSTNAME must be specified in $HOME/.local_net_cfg"; return -1; fi
    if [[ -z "$LOCAL_STATIC_NETMASK" ]]; then echo "LOCAL_STATIC_NETMASK must be specified in $HOME/.local_net_cfg"; return -1; fi
    if [[ -z "$LOCAL_STATIC_BROADCAST_ADDR" ]]; then echo "LOCAL_STATIC_BROADCAST_ADDR must be specified in $HOME/.local_net_cfg"; return -1; fi
    if [[ -z "$LOCAL_STATIC_DEVICE" ]]; then echo "LOCAL_STATIC_DEVICE must be specified in $HOME/.local_net_cfg"; return -1; fi

    echo "*** Setting up for a static IP network configuration; sudo will be invoked"
    echo

    echo "*** shutting down autofs"
    echo
    sudo /etc/rc.d/autofs stop

    echo "*** Configuring a static IP address"
    echo

    local good=0;

    while [[ "0" -eq "$good" ]]; do
        sudo ifconfig $LOCAL_STATIC_DEVICE netmask $LOCAL_STATIC_NETMASK broadcast $LOCAL_STATIC_BROADCAST_ADDR $LOCAL_STATIC_IP_ADDRESS
        rv=$?

        if [[ "0" -eq "$rv" ]]; then
            good=1
        else
            echo "ifconfig not behaving..."
            continue
        fi

        check_ip_address=`ifconfig $LOCAL_STATIC_DEVICE | grep "inet addr" | sed 's/.*inet addr://' | awk '{ print $1 }'`
        check_mask=`ifconfig $LOCAL_STATIC_DEVICE | grep "Mask" | sed 's/.*Mask://' | awk '{ print $1 }'`
        check_bcast=`ifconfig $LOCAL_STATIC_DEVICE | grep "Bcast" | sed 's/.*Bcast://' | awk '{print $1 }'`

        if [[ "$LOCAL_STATIC_IP_ADDRESS" != "$check_ip_address" ]]; then
            echo "warning- desired IP address was not set; trying again"
            echo "    desired: "$LOCAL_STATIC_IP_ADDRESS
            echo "    current: "$check_ip_address
            good=0
        fi

        if [[ "$LOCAL_STATIC_NETMASK" != "$check_mask" ]]; then
            echo "warning- desired netmask was not set; trying again"
            echo "    desired: "$LOCAL_STATIC_NETMASK
            echo "    current: "$check_mask
            good=0
        fi

        if [[ "$LOCAL_STATIC_BROADCAST_ADDR" != "$check_bcast" ]]; then
            echo "warning- desired broadcast address was not set; trying again"
            echo "    desired: "$LOCAL_STATIC_BROADCAST_ADDR
            echo "    current: "$check_bcast
            good=0
        fi

        if [[ "1" -ne "$good" ]]; then
            sleep 1
        fi
    done

    sudo rm -f /etc/resolv.conf
    sudo touch /etc/resolv.conf
    sudo chmod 644 /etc/resolv.conf

    sudo hostname $LOCAL_STATIC_HOSTNAME

    echo "*** shutting down the firewall..."
    sudo /etc/init.d/SuSEfirewall2_setup stop
    echo

    echo "hostname: "`hostname`
    echo
    ifconfig $LOCAL_STATIC_DEVICE

    ping -c 1 -w 2 -W 2 localhost > /dev/null 2>&1
    if [[ "0" -eq "$?" ]]; then
        echo "ping localhost: OK"
    else
        echo "ping localhost: FAILED"
        return -1
    fi
    echo

    ping -c 1 -w 2 -W 2 `hostname` > /dev/null 2>&1
    if [[ "0" -eq "$?" ]]; then
        echo "ping hostname ("`hostname`"): OK"
    else
        echo "ping hostname ("`hostname`"): FAILED (WARNING!)"
    fi
    echo

    echo "*** WARNING ***"
    echo
    echo "The firewall has been shutdown.  To restart the firewall, execute:"
    echo "    $ sudo /etc/init.d/SuSEfirewall2_setup start"
    echo
    echo "To query status of the firewall, execute:"
    echo "    $ /etc/init.d/SuSEfirewall2_setup status"
    echo
}
