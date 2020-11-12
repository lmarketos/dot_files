#! /usr/bin/env python
#
# Author: Dale Rowley
#
# Usage: Run with -h/--help for instructions
#
# Notes:
#

import os
import re
import sys
import glob
import time
import optparse
import multiprocessing

abortOnKeypress = True
try:
    import myutils
except ImportError:
    abortOnKeypress = False

def systemCallWrapper(cmd):
    # have to use sys.exit() to get multiprocess.Process.exitcode to store the exit code.
    sys.exit( os.system(cmd) % 255 )


usage = """usage: %prog <command> [items to iterate over]

  Assume that the first argument is a valid shell command with '||', '::',
  and/or '++' tokens. Each subsequent arugment is assumed to be an item to use
  with executing the command. The command is executed once for each given item,
  with the '||' token(s) replaced by the item. The '++' token will be replaced
  by an auto- incremented integer (starting at 1 by default).  If the -p and -r
  options are given, then the '::' token is replaced with the modified item.

  NOTE: The given command should probably be enclosed in quotes so that it is
  passed in completely as the first argument. Pressing any key while the
  commands are being executed will cause %prog to abort (since ctrl+c will just
  abort the one command that it is currently executing)."""

parser = optparse.OptionParser(usage=usage)
parser.add_option("-c", dest="noconfirm", action="store_true",
                  help="Don't print out the commands and ask for confirmation before running them.")
parser.add_option("-x", dest="abortOnError", action="store_true",
                  help="Abort remaining commands if a command exits with a non-zero return code. [False]")
parser.add_option("-f", dest="files", default="",
                  help="Path/file(s) glob pattern to use instead of listing 'items to iterate over' on the commandline. " + \
                       "In other words, if a shell glob pattern produces a list of files that exceeds the shell's max number of arguments, " + \
                       "then set this option to the glob pattern, and it will be expanded by python (thus getting around the shell argument limit). " + \
                       "Don't forget to put the glob pattern in quotes to prevent the shell from expanding it.")
parser.add_option("-q", dest="quiet", action="store_true",
                  help="Don't print out each command before running it.")
parser.add_option("-p", dest="pattern",
                  help="Regular expression pattern to search for in each item [None]")
parser.add_option("-r", dest="replace",
                  help="Regular expression to use to replace the pattern (-p) in each item [None]")
parser.add_option("-a", dest="replaceAll", action="store_true",
                  help="Replace all instances of the regular expression (see -p and -r options).")
parser.add_option("-j", type="int", dest="numThreads", default=1,
                  help="Number of commands to execute simultaneously. [1]")
parser.add_option("-s", type="int", dest="startIndex", default=1,
                  help="The starting index to use for the '++' token. [1]")
parser.add_option("-S", type="int", dest="stopIndex", default=None,
                  help="The stopping index to use for the '++' token. This should only be used if no items were given to iterate over. [1]")
parser.add_option("-P", type="int", dest="padZeros", default=0,
                  help="Make index numbers use the given number of digits by padding with zeros where necessary. If set to 0, then no padding is done. [0]")
(options, args) = parser.parse_args()

metaCommand = args[0]
items       = args[1:]
commands    = []

if options.files != "":
    items = glob.glob(options.files)

if (options.pattern == None and options.replace != None) or \
   (options.pattern != None and options.replace == None):
    print "Missing a pattern or replacement option."
    sys.exit(1)

replaceCount = 1 # only replace the first occurence of the regexp by default
if options.replaceAll:
    replaceCount = 0

if len(args) < 2 and len(items) == 0:
    if options.stopIndex == None:
        print "Item list size is 0. Must provide items to iterate over, or use the -S or -f options."
        sys.exit(1)
    else:
        items = [str(x) for x in range(options.startIndex, options.stopIndex+1)]
elif len(args) >=2 and options.stopIndex != None:
    print "-S option was given and item list size is >0. Use one or the other, but not both."
    sys.exit(1)

# show what will happen
counter = options.startIndex
for item in items:
  if options.pattern != None:
    newItem = re.sub(options.pattern, options.replace, item, replaceCount) # only replace the first occurence
    item = metaCommand.replace("||", item).replace("::", newItem)
  else:
    item = metaCommand.replace("||", item)

  counterStr = str(counter)
  if options.padZeros > 0:
    i = options.padZeros - len(counterStr)
    if i > 0:
        counterStr = '0'*i + counterStr

  item = item.replace("++", counterStr)
  counter += 1

  commands.append(item)
  if not options.noconfirm:
    print commands[-1]

# give user a chance to cancel
if not options.noconfirm:
  if raw_input("Execute these commands? (y/n) ") != "y":
    print "Operation cancelled."
    sys.exit(0)

# execute the commands
tasks = []
exitCode = 0
for command in commands:
  # support executing multiple tasks at the same time
  if options.numThreads > 1:
    # spawn a thread to execute the given command
    if not options.quiet:
      print command
    t = multiprocessing.Process(target = systemCallWrapper, args=(command,))
    t.start()
    tasks.append(t)

    # if we've spawned the max number of requested threads, then wait until at
    # least one finishes
    while len(tasks) == options.numThreads:
      for t in tasks:
        if not t.is_alive():
          t.join()
          if t.exitcode != 0:
              exitCode = t.exitcode
          tasks.remove(t)
      time.sleep(0.1)

  else:  # just execute 1 task at a time
    if not options.quiet:
      print command

    exitCode = os.system(command) % 255

  #if a key was pressed while the command was running, then abort
  if options.abortOnError and exitCode != 0:
    print "Detected an error (non-zero exit code: " + str(exitCode) + "). Aborting batch commands."
    sys.exit(exitCode)

  if abortOnKeypress and myutils.getKey() != "":
    print "Detected a keypress - aborting batch commands."
    sys.exit(1)

