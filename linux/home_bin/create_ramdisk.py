#!/usr/bin/env python

import os
import sys
import commands
import optparse

username = commands.getoutput("whoami")

usage = """
  This script just mounts a ramdisk. 'root' priviledges are necessary to mount 
  filesystems, so the 'sudo' command will be used to execute the appropriate 
  command, and the user will have to enter the appropriate password.
  Use the 'umount' command to remove the ramdisk and free up memory. """

parser = optparse.OptionParser(usage=usage)
parser.add_option("-s", dest="size", default="100m",
                  help="The size of the ramdisk with a suffix of 'k', 'm', or 'g' to represent KB, MB, and GB respectively. [100m]")
parser.add_option("-u", dest="user", default=username,
                  help="Owner username of the ramdisk. ['`whoami`']")
parser.add_option("-g", dest="group", default="users",
                  help="Owner groupname of the ramdisk. ['users']")
parser.add_option("-m", dest="mount", default="/mnt/ramdisk",
                  help="Mount point for the ramdisk ['/mnt/ramdisk']")
(options, args) = parser.parse_args()

mode = "770"


if not os.path.exists(options.mount):
    print "*** Creating mount point: " + options.mount
    os.system("mkdir " + options.mount)


print "*** Mounting ramdisk: " + options.mount
os.system("sudo mount -t tmpfs tmpfs " + options.mount + " -o size=" + options.size + 
          ",mode=" + mode + ",uid=" + options.user + ",gid=" + options.group)

os.system("sudo chown -R " + options.user + ":" + options.group + " " + options.mount)

