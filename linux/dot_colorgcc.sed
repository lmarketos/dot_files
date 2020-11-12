#
#   Author: Dale Rowley
#
#   Usage:  This is a sed script for highlighting the output of make / scons / gcc.
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


# highlight gcc notes, warnings, and errors
s/error:/[01;31m&[0m/
s/undefined\ reference/[01;31m&[0m/
s/warning: .*/[01;32m&[0m/
s/note:/[01;33m&[0m/

# highlight "instantiated from" and lines such as "In member function..."
s/ In .*/[01;36m&[0m/
s/instantiated from /[01;33m&[0m/

# highlight everything between apostrophes, but only on lines that
# don't contain "instantiated from" or " In "
/instantiated from| In /! {s/ '[^']+'/[01;35m&[0m/g}

# This one highlights the file line numbers
s/:([0-9]+):/[01;35m&[0m/

# highlight everything up to the first colon (this is usually a file name)
s/^[^ ]+:/[01;34m&[0m/

# highlight "Entering directory XXX" and "scons: building XXX" lines
/Entering directory|Leaving directory|building/ {s/`[^']+'/[04;36m&[0m/}
/\*\*\*|Stepping into/ {s/.*/[00;37m&[0m/}

# highlight scons "Install file:" lines
/Install.*:/ {s/"[^"]+"/[04;35m&[0m/g}

# highlight lines with 'WARNING' or 'ERROR' (mostly JBuildSetup warnings/errors)
/^WARNING/ s/.*/[01;35m&[0m/
/^ERROR/ s/.*/[01;31m&[0m/

# highlight output from scons
s/^Evaluated.*nodes/[01;36m&[0m/
s/^Detected[ 0-9]*processors.*/[01;36m&[0m/
s/^Loading.*\.py"/[01;36m&[0m/
s/^Pruning scons cache dir.*/[01;36m&[0m/
s/^Done pruning the cache.*/[01;36m&[0m/

# cots helpful colors: automake (checking for xxx ... no)
s/^(checking.*\.\.\.)(.*)/\1[01;37m\2[0m/
# cots helpful colors: cmake % complete. 
s/^(\[.*\])(.*)/[01;37m\1[0m\2/

# scons have_XXX checks
/^(Check.*\.\.\.)(.*cached.*)/d
s/^(Check.*\.\.\.)(.*no.*)/\1[01;31m\2[0m/
s/^(Check.*\.\.\.)(.*yes.*)/\1[01;32m\2[0m/
