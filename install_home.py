#!/usr/bin/env python

import os
import sys
import glob
import argparse
import subprocess

echo "for reference only"
sys.exit(1)


usage = """
This script installs the contents of this directory into a target directory
(default = $HOME). By default, only the minimum set of bash and git
configuration files are installed, and only if the files don't already exist in
the target directory. To update files that already exist, either use the -f
option, or use the -d option to manually apply updates using a diff GUI such
as 'meld'.
"""

parser = argparse.ArgumentParser(description=usage)
parser.add_argument("-t", dest="targetDir", default=os.getenv('HOME'),
                    help="Target directory where files/dirs should be installed. [%(default)s]")
parser.add_argument("-f", dest="overwrite", action="store_true",
                    help="Toggle whether to overwrite files that already exist in "
                         "the target dir [%(default)s]")
parser.add_argument("-a", dest="installAll", action="store_true",
                    help="Toggle whether to install all files, instead of just the "
                         "minimal set of bash/git files. [%(default)s]")
parser.add_argument("-n", dest="dryRun", action="store_true",
                    help="Toggle whether to just print what would be done instead "
                         "of actually installing files. [%(default)s]")
parser.add_argument("-d", dest="diff", default=None,
                    help="Instead of installing files, run the given executable (eg, meld) to do "
                         "a diff on files that already exist in the target dir. [%(default)s]")
opts = parser.parse_args()


def install(sources):
  for src,dst in sorted(sources.iteritems()):
    if not os.path.exists(src):
      print('ERROR: Source file/dir does not exist: {}'.format(src))
      continue

    if os.path.isdir(src):
      # a good diff GUI will handle doing a recursive diff, so only drill down
      # into directories if we are not doing diffs, or if our diff tool is 'diff'
      if os.path.isdir(dst) and opts.diff and opts.diff != 'diff':
        subprocess.call(' '.join([opts.diff, src, dst, '>/dev/null 2>&1']), shell = True)
      else:
        for i in sorted(glob.glob(os.path.join(src, '*'))):
          install({ i : os.path.join(dst, os.path.basename(i)) })
    else:
      different = True
      if os.path.exists(dst):
        different = (0 != subprocess.call(' '.join(['diff', src, dst, '>/dev/null 2>&1']), shell = True))
        if different:
          print('Entries differ: {0}\tand\t{1}'.format(src, dst))

      if different:
        # If the user requested displaying diffs, then assume they will do
        # updates manually, so we don't need to install any files/dirs
        if opts.diff:
          if os.path.exists(dst):
            subprocess.call([opts.diff, src, dst])
        elif not os.path.exists(dst) or opts.overwrite:
          if not os.path.exists(os.path.dirname(dst)) and not opts.dryRun:
            subprocess.call('mkdir -p {}'.format(os.path.dirname(dst)), shell = True)
          cmd = 'cp "{0}" "{1}"'.format(src, dst)
          print(cmd)
          if not opts.dryRun:
            subprocess.call(cmd, shell = True)


if opts.diff:
  # make sure the executable is found in the PATH
  if 0 != subprocess.call(["which", opts.diff]):
    sys.exit(1)

opts.targetDir = os.path.expanduser( os.path.expandvars( opts.targetDir ) )
if not os.path.isdir(opts.targetDir):
  print('ERROR: Target directory does not exist: {}'.format(opts.targetDir))
  sys.exit(1)

# default minimum set of files/dirs to install
sources = [ "dot_bash",
            "dot_bashrc",
            "dot_bash_profile",
            "dot_bash_logout",
            "dot_gitconfig",
          ]
if opts.installAll:
  sources = glob.glob("dot_*")

sources = dict([x, os.path.join(opts.targetDir, x.replace('dot_', '.'))] for x in sources)

if opts.installAll:
  sources['home_bin'] = os.path.join(opts.targetDir, 'bin')

if opts.overwrite and not opts.dryRun:
  print('You are requesting to potentially overwrite files under ' + opts.targetDir + '!!')
  print('NOTE: You can use the -n option to see which files will be affected.\n')
  if raw_input("Are you sure you want to continue? (y/n) ") != "y":
    print('Aborting...')
    sys.exit(1)

if opts.dryRun:
  print("\nDry run... Commands will be printed but not executed.\n")

install(sources)
