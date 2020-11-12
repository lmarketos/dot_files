#! /usr/bin/env python
#
# Author: Dale Rowley
#
# Usage: Run with -h/--help for instructions
#
# Notes: This script creates/uses a file in $HOME/.pathBookmarks
#        Change the 'bookmarkFile' variable below if you want to use a different file.
#

# Example bash function for using this script
# function cd() {
#    # Pass all options on to the python script and get the script output
#    local output=`bm.py $*`
#    echo $output
#
#    # if the script output is a "cd" command, then execute the command;
#    # otherwise, try to run the builtin cd command
#    if [[ "`echo $output | cut -f1 -d ' '`" == "cd" ]]; then
#        $output
#    else
#       builtin cd "$@"
#    fi
# }

import os
import sys
import commands
import optparse


home               = os.getenv("HOME")
bookmarkFile       = home + "/.pathBookmarks"
bookmarkBackupFile = home + "/.pathBookmarks.bak"

usage = """usage: %prog [ <option> | [name] ]

    This script manages filesystem bookmarks to facilitate directory navigation
    (instead of "cd ../../../some/path/way/out/there").  If no arguments are
    given, then do nothing.  If any options are given, only one of them will be
    honored and everything else will be ignored. If a bookmark name is given
    (and no options were specified), then print a command that can be used to
    change to the corresponding directory (since python scripts are executed in
    a sub-shell, they can't affect the PWD of the parent shell, so we can only
    print out the command so that the parent shell can execute it if
    it so chooses). """

parser = optparse.OptionParser(usage=usage)

parser.add_option("-l", dest = "list",      action = "store_true", help = "print current bookmarks")
parser.add_option("-c", dest = "clear",     action = "store_true", help = "clear the list of bookmarks")
parser.add_option("-p", dest = "printPath", action = "store_true", help = "just print the absolute directory path that is associated with the given bookmark (if any)")
parser.add_option("-d", dest = "delete",                           help = "name of bookmark to delete")
parser.add_option("-r", dest = "replace",                          help = "name of bookmark to replace with the PWD")
parser.add_option("-a", dest = "add",                              help = "name of new bookmark to insert for the PWD")

(options, args) = parser.parse_args()


# define some utility methods
def printBookmarks(bookmarks):
    if len(bookmarks) > 0:
        keys = bookmarks.keys()
        # sort the keys based on the corresponding directories
        keys.sort(key = lambda x: bookmarks[x])
        # print to stderr to prevent bash script wrapper from picking up the output
        for key in keys:
            print >> sys.stderr, key + " " * (10 - len(key)) + bookmarks[key]
        print >> sys.stderr, "\n"
    else:
        print >> sys.stderr, "Bookmark list is empty"

def parseBookmarks(text, bookmarks):
    bookmarks.clear()
    items = text.split("\n")
    if items == None:
        print >> sys.stderr, "no bookmarks!"
        return
    for pair in items:
        namePath = pair.split(":")
        if namePath != None and len(namePath) != 2:
            if len(namePath) != 0 and namePath[0] != "":
                # print to stderr to prevent bash script wrapper from picking up the output
                print >> sys.stderr, "invalid name/path pair: " + pair
            continue
        bookmarks[namePath[1]] = namePath[0]

def bookmarksToFile(fileName, bookmarks):
    text = ""
    keys = bookmarks.keys()
    # sort the keys based on the corresponding directories
    keys.sort(key = lambda x: bookmarks[x])
    for key in keys:
        text += bookmarks[key] + ":" + key + "\n"
    os.system("echo '" + text + "' > " + fileName)



bookmarks = {}
if os.path.exists(bookmarkFile):
    text = commands.getoutput("cat " + bookmarkFile)
    parseBookmarks(text, bookmarks)

if options.add != None:
    # interactively insert a bookmark
    if options.add in bookmarks:
        # print to stderr to prevent bash script wrapper from picking up the output
        print >> sys.stderr, "bookmark '" + options.add + "' already exists"
    else:
        bookmarks[options.add] = os.getenv("PWD").replace(home, "~")
        bookmarksToFile(bookmarkFile, bookmarks)

elif options.delete != None:
    # interactively delete a bookmark
    if options.delete not in bookmarks:
        # print to stderr to prevent bash script wrapper from picking up the output
        print >> sys.stderr, "bookmark '" + options.delete + "' does not exist"
    else:
        del bookmarks[options.delete]
        bookmarksToFile(bookmarkFile, bookmarks)

elif options.replace != None:
    # replace bookmark with pwd
    bookmarks[options.replace] = os.getenv("PWD").replace(home, "~")
    bookmarksToFile(bookmarkFile, bookmarks)

elif options.list:
    printBookmarks(bookmarks)

elif options.clear:
    # print to stderr to prevent bash script wrapper from picking up the output
    print >> sys.stderr, "Are you sure you want to delete all bookmarks? (y/n)"
    response = raw_input("")
    if "y" == response:
        bookmarksToFile(bookmarkBackupFile, bookmarks)
        bookmarks.clear()
        bookmarksToFile(bookmarkFile, bookmarks)
else:
    if len(args) > 0:
        if args[0] in bookmarks:
            if options.printPath != None:
                print         bookmarks[args[0]].replace("~", home) + "/"
            else:
                print "cd " + bookmarks[args[0]].replace("~", home) + "/"
        else:
            print >> sys.stderr, "Bookmark '" + args[0] + "' does not exist."

