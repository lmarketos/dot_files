
# User specific aliases and functions
####  Git branch and colors
COLOR_RED="\033[01;31m"
COLOR_YELLOW="\033[0;33m"
COLOR_GREEN="\033[0;32m"
COLOR_OCHRE="\033[38;5;95m"
COLOR_BLUE="\033[0;34m"
COLOR_WHITE="\033[0;37m"
COLOR_RESET="\033[0m"

function git_color {
  local git_status="$(git status 2> /dev/null)"

  if [[ $git_status =~ "Changes not staged for commit" ]]; then
    echo -e $COLOR_RED
  elif [[ $git_status =~ "Changes to be committed" ]]; then
    echo -e $COLOR_YELLOW
  elif [[  $git_status =~ "working directory clean" ]]; then
    echo -e $COLOR_WHITE
  elif [[ $git_status =~ "Your branch is ahead of" ]]; then
      echo -e $COLOR_GREEN
  elif [[ $git_status =~ "but the upstream is gone" ]]; then
      echo -e $COLOR_GREEN
  elif [[ $git_status =~ "Your branch is up to date" ]]; then
      echo -e $COLOR_WHITE
  elif [[ $git_status =~ "nothing added to commit but untracked files present" ]]; then
      echo -e $COLOR_WHITE
  else
    echo -e $COLOR_OCHRE
  fi
}

#function git_branch {
#  local git_status="$(git status 2> /dev/null)"
#  local on_branch="On branch ([^${IFS}]*)"
#  local on_commit="HEAD detached at ([^${IFS}]*)"
#
#  if [[ $git_status =~ $on_branch ]]; then
#    local branch=${BASH_REMATCH[1]}
#    echo "($branch)"
#  elif [[ $git_status =~ $on_commit ]]; then
#    local commit=${BASH_REMATCH[1]}
#    echo "($commit)"
#  fi
#}

# I like putting angle-brackets around the branch name.  Customize to taste by
# changing the punctuation around the \1 at the end of the line.
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/<\1> /'
}

# Finally, add magic to your prompt.
#export PS1="\[\$(git_color)\]\$(parse_git_branch)"
# You probably want other stuff on your prompt; just put it in the quotes along with the above.
# Personally, I like some spaces, the cwd, and a colon:
export PS1="\h:\[\$(git_color)\]\$(parse_git_branch)\[\033[0;32m\]\w\[\033[0;37m\]$ "
