#! /bin/bash
#
# @author Dale Rowley
#


# This function provides tab-completion on path bookmarks (ie, bookmarks created
# by the bm.py python script and stored in ~/.pathBookmarks).
function _complete_bookmarks()
{
    # this is the text that we're completing on
    cur="${COMP_WORDS[COMP_CWORD]}"

    # do filename completion first
    COMPREPLY=( `compgen -f "$cur"` )

    # append possible completions using bookmarks
    COMPREPLY+=( $( cat "$HOME/.pathBookmarks" | \
                    grep ":${cur}$" | sed -e 's/:.*//' ) )

    return 0
}


# This file enables fuzzy file/dir tab-completion on some common shell commands.
# Fuzzy completion is performed by trying to find matches with the following
# patterns.  The patterns are applied in the order below, and as soon as any
# matches are found, then they are immediately returned. This is done because
# bash tab-completion automatically sorts the returned list alphabetically, and
# there's no way to disable this. Since normal matches should be given higher
# precedence over fuzzy-completion matches, and since a fuzzy-completion match
# could come alphabetically before a normal match, then we can't do fuzzy
# completion if we found normal matches.
#
# Patterns:
#           base_dir/string*         (this corresponds to normal tab completion)
#           base_dir/*string*
#           base_dir/s*t*r*i*n*g*
#           base_dir/*s*t*r*i*n*g*
#
# So for example, given the following files:
#
#        1) dir1/longlonglonglong_x.txt
#        2) dir1/longlonglonglong_y.txt
#        3) dir1/longlonglonglong_z.txt
#        4) dir1/ly_foobar.txt
#           ...
#
# then typing 'ls dir1/y<tab>' would return entries 2 and 4.  However, typing
# 'ls dir1/ly<tab>' would not return the second entry, even though it is a fuzzy
# match, because ly_foobar.txt is a better match and we wouldn't want bash to
# give the second entry a higher precedence (ie, when it sorts the list of
# returned matches).
#
# In addition, fuzzy-completion also appends completions from path bookmarks
# (see _complete_bookmarks() above for more info).


# Set this to 1 in your custom/*.bash if you are using menu-complete (as opposed
# to regular bash completion) and if you want fuzzy tab-completion to be case
# sensitive.
# Explanation: if the 'nocaseglob' bash setting is off (ie, globbing is
# case-sensitive), but the returned list of completions contains entries that
# begin with the same letters but differ in case, and if 'menu-complete' is not
# being used, then bash will erase the typed pattern instead of sounding the
# bell (to indicate there is more than 1 possible completion).
# Conclusion: a completion function cannot return case-insensitive list of
# completions unless nocaseglob is set. In other words, our list of completions
# has to be compatible with nocaseglob, unless we are doing menu-completion.
export _FUZZY_MENU_COMPLETE_CASE_SENSITIVE=0




# usage _gen_fuzzy_list <0|1> <base_dir> <search_string>
# args:
#     $1: 0 = complete files and dirs
#         1 = only complete dirs
#         2 = only complete files (not supported yet)
#     $2: an empty string, or a dir name that must end with a '/'
#     $3: a search pattern to apply within the dir in $2
_gen_fuzzy_list() {
    local dirFilePat=""    # complete files and dirs
    if [[ "$1" == "1" ]]; then
        dirFilePat="/"     # only complete dirs
    fi
    # TODO: support dirFilePat=2 (only complete files)

    local flag=0
    local base_dir="$2"
    local pattern="$3"
    #echo -e "\nbase: '$base_dir'; ss: '$pattern'"
    case "$3" in
        ..)
            base_dir="${base_dir}../"
            pattern=""
            flag=0
            ;;
        ""|.)
            flag=0
            ;;
        .*)
            # if looking for a hidden file, then prepending '*' to the pattern
            # (eg, *.bashrc*) yields 0 matches? So work around this...
            flag=2
            ;;
        *)
            flag=1
            ;;
    esac
    base_dir=${base_dir/#~\//$HOME/}

    local saveIFS="$IFS"
    IFS=$'\n'                   # avoid problems with filenames with spaces in them

    local restoreCaseGlob=      # use this to restore the nocaseglob setting
    bind -q menu-complete 2>/dev/null 1>&2   # check if menu-complete is being used
    if  [[ $? -eq 0 ]]; then
        shopt -q nocaseglob
        local nocaseglob=$?
        if [[ $_FUZZY_MENU_COMPLETE_CASE_SENSITIVE -eq 0 && $nocaseglob -eq 1 ]]; then
            shopt -s nocaseglob
            restoreCaseGlob="-u"
        elif [[ $_FUZZY_MENU_COMPLETE_CASE_SENSITIVE -eq 1 && $nocaseglob -eq 0 ]]; then
            shopt -u nocaseglob
            restoreCaseGlob="-s"
        fi
    fi


    # get a list of simple/normal completions first ($pattern*)
    pat="${base_dir}${pattern}*${dirFilePat}"
    local list=( `ls -1dp $pat 2>/dev/null` )
    #echo -e "\n$pat; l1: '${list[*]}'\n"

    # If we found any matches, then return the list. Bash tab-completion
    # automatically sorts the list alphabetically, and there's no way to disable
    # this. Since normal matches should be given higher precedence over
    # fuzzy-completion matches, and since a fuzzy-completion match could come
    # alphabetically before a normal match, then don't do fuzzy completion if we
    # found normal matches.
    if [[ "${#list}" == 0 && "$flag" != "0" ]]; then
        # append anything that matches *$pattern*
        if [[ "$flag" != "2" ]]; then
            pat="${base_dir}*${pattern}*${dirFilePat}"
            list+=( `ls -1dp $pat 2>/dev/null` )
            #echo -e "\n$pat; l2: '${list[*]}'\n"
        fi

        if [[ "${#list}" == 0 ]]; then
            # append anything that matches a*b*c*...* where a,b,c are letters making up $pattern
            pat="`echo $pattern | sed -e 's/\(.\)/\1*/g'`${dirFilePat}"
            list+=( `ls -1dp ${base_dir}$pat 2>/dev/null` )
            #echo -e "\n$base_dir; $pat; l3: '${list[*]}\n"

            if [[ "${#list}" == 0 && "$flag" != "2" ]]; then
                # append anything that matches *a*b*c*...* where a,b,c are letters making up $pattern
                pat="${base_dir}*$pat"
                list+=( `ls -1dp $pat 2>/dev/null` )
                #echo -e "\n$pat; l3: '${list[*]}\n"
            fi
        fi
    fi

    # append completions from the bookmarks files - this only make sense if
    # dir-completion was requested, and if base_dir is not given (because path
    # bookmarks represent absolute paths, not paths relative to other dirs)
    if [[ "$1" != "2" && -z "$base_dir" && -f "$HOME/.pathBookmarks" ]]; then
        list+=( $( cat "$HOME/.pathBookmarks" | \
                   grep ":${pattern}$" | sed -e 's/:.*//' ) )
    fi

    # remove duplicates, but keep the same list order
    list=( $( printf "%s\n" "${list[@]}" | awk 'x[$0]++ == 0' ) )
    IFS="$saveIFS"    # restore original setting
    for x in "${list[@]}"; do
        x="${x%/}"    # remove potential trailing '/' and '//' due to `ls -p`
        x="${x%/}"
        if [[ ${BASH_VERSINFO[0]} -gt 4 ]] ||
           [[ ${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -ge 3 ]]; then
          _fuzzy_list+=( "${x/#$HOME/\~}" )   # replace leading '$HOME'  with '~'
        else
          _fuzzy_list+=( "${x/#$HOME/~}" )   # replace leading '$HOME'  with '~'
        fi
    done
    #echo -e "\nfuzzy_list: '${_fuzzy_list[*]}'\n"

    # restore the original 'nocaseglob' setting
    if [[ -n $restoreCaseGlob ]]; then
        shopt $restoreCaseGlob nocaseglob
    fi
}

# usage _fuzzy_complete <0|1>
# $1: 0 = complete files and dirs
#     1 = only complete dirs
#     2 = only complete files (not supported yet)
_fuzzy_complete() {
    local dirFileFlag=1     # only complete dirs
    if  [[ "$1" == "0" ]]; then
        dirFileFlag=0       # complete dirs and files
    elif  [[ "$1" == "2" ]]; then
        dirFileFlag=2       # only complete files (no dirs)
    fi

    local status=0
    local base_dir=${COMP_WORDS[COMP_CWORD]}
    local saveIFS="$IFS"    # save so we can restore the current setting before we exit
    IFS=$'\n'               # avoid problems with filenames with spaces in them
    if [[ "$base_dir" = \~* ]]; then
        # handle case where user forgot to put a '/' after the '~'
        if [[ ${BASH_VERSINFO[0]} -gt 4 ]] ||
           [[ ${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -ge 3 ]]; then
          base_dir="${base_dir/#\~\//\~}"      # replace leading '~/' with '~'
        else
          base_dir="${base_dir/#\~\//~}"      # replace leading '~/' with '~'
        fi
        base_dir="${base_dir/#\~/$HOME/}"   # replace leading '~'  with '$HOME'
    fi

    local search_string=""
    case $base_dir in
    ''|.)
        search_string="$base_dir"
        base_dir=""
        ;;
    '//')
        base_dir="/"
        ;;
    */*)
        search_string=${base_dir##*/}       # get everything after the last '/'
        base_dir=${base_dir%/*}/            # remove everything after the last '/'
        base_dir=${base_dir/#~\//$HOME/}    # replace leading '~/' with '$HOME'
        ;;
     *)
        search_string=$base_dir
        base_dir=""
        ;;
    esac
    #echo "base: '$base_dir', ss: '$search_string'"
    # base_dir should now have a trailing /, and search_string should either be
    # empty, or contain a pattern to search for relative to base_dir

    unset _fuzzy_list
    _fuzzy_list=()
    _gen_fuzzy_list $dirFileFlag "$base_dir" "$search_string"

    IFS="$saveIFS"      # restore the previous setting

    COMPREPLY=( "${_fuzzy_list[@]}" )
    #echo -e "\nresults: '${COMPREPLY[*]}'\n"
}

function _fuzzy_dirs_only() {
    _fuzzy_complete 1
}

function _fuzzy_dirs_and_files() {
    _fuzzy_complete 0
}

# TODO: bash 4.X? has a way to specify a default completion function - that
# would be easier than this long list of arbitrary commands, and would have the
# benefit of working with aliases as well.
complete -o filenames -F _fuzzy_dirs_only cd
complete -o filenames -F _fuzzy_dirs_and_files ls cp mv vi vim gvim ll la lla du meld rem


