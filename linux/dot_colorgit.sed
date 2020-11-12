#
#   Author: Dale Rowley / modified for git by cbaker
#
#   Usage:  This is a sed script for highlighting the output of git
#
#   Notes:  In most terminals, [XX;YYm is an escape sequence where XX;YY are
#           numbers representing text attributes and colors to apply to the text
#           following the escape sequence. The escape sequence [0m returns
#           subsequent text to default attribute and color.
#
#               XX = 0          Normal (default)
#               XX = 1 / 22     On / Off Bold (bright fg)
#               XX = 4 / 24     On / Off Underline
#               XX = 5 / 25     On / Off Blink (bright bg)
#               XX = 7 / 27     On / Off Inverse
#
#               YY = 30 / 40    fg/bg Black
#               YY = 31 / 41    fg/bg Red
#               YY = 32 / 42    fg/bg Green
#               YY = 33 / 43    fg/bg Yellow
#               YY = 34 / 44    fg/bg Blue
#               YY = 35 / 45    fg/bg Magenta
#               YY = 36 / 46    fg/bg Cyan
#               YY = 37 / 47    fg/bg White
#               YY = 39 / 49    fg/bg Default
#
#           Terminals that support 256 colors may use the following values
#           for additional colors.
#
#               YY = 38;5;ZZZ Set foreground color to ZZZ (0-255)
#               YY = 48;5;ZZZ Set background color to ZZZ (0-255)
#
#           Note that sed reads in a line and then executes all commands in
#           the script. So colors that are applied by commands later in the
#           script may override colors applied from commands earlier in the
#           script (or vice-versa). When debugging this script, it can be
#           helpful to do something like this:
#               cmd | sed -f [this_script] > temp.txt
#           and then open up temp.txt in an editor to see where the colored-text
#           escape sequences were actually inserted in the text output from 'cmd'.

# highlight when not on the master branch
/On branch master/ !s/On branch .*/[01;33m&[0m/
/\* master/ !s/\* .*/[01;33m&[0m/

# highlight untracked files
s/Untracked files:/[01;35m&[0m/

# highlight needs to push
s/Your branch is ahead.*/[01;35m&[0m/

# highlight fast forwards
s/Fast forward.*/[01;35m&[0m/

# highlight errors
s/error.*/[01;31m&[0m/
s/fatal.*/[01;31m&[0m/

# highlight modifies
s/\bM\b\s.*/[01;36m&[0m/
s/\bD\b\s.*/[01;31m&[0m/
s/\bA\b\s.*/[01;32m&[0m/
/\|/ s/.*/[01;36m&[0m/
/create mode/ s/.*/[01;32m&[0m/
/delete mode/ s/.*/[01;31m&[0m/
/needs update/ s/.*/[01;35m&[0m/

s/Changed but not updated.*/[01;31m&[0m/
s/modified.*/[01;31m&[0m/
