#!/bin/env python3

from optparse import OptionParser, BadOptionError, AmbiguousOptionError
import subprocess
import re
import shutil
import sys

class ArgParser(OptionParser):

	def __init__(self, *args, **kwargs):
		super().__init__(*args, **kwargs)

	def _process_args(self, largs, rargs, values):
        	while rargs:
            		try:
                		OptionParser._process_args(self,largs,rargs,values)
            		except (BadOptionError, AmbiguousOptionError) as e:
                		largs.append(e.opt_str)

usage = "Usage: %prog "
parser = ArgParser(usage)
parser.add_option("-f", "--format", dest="format")
parser.add_option("-n", "--name", dest="archiveName")

optlist, args = parser.parse_args()

if len(args) < 1:
    parser.print_usage()
    sys.exit(-1)
if not optlist.format:
        optlist.format = 'gz'
if not optlist.archiveName:
	nameParser = re.compile("(?:/([\w_\\.-]+))+")
	for word in args:
		if word[0] == '-':
			continue
		m = nameParser.match(word)
		if m:
			name = ''.join(m.group(1).split('.')[:-1])
			optlist.archiveName = name
			break
	else:
		optlist.archiveName = 'archive'
		



if optlist.format == 'gz':
	if len(shutil.which('pigz')) > 0:
		print('Using parallel compression..')
		cmd = 'tar -c %s | pigz > "%s.tar.gz"' % (' '.join(args), optlist.archiveName)
	else:
		cmd = 'tar -czf %s.tar.gz %s' % (optlist.archiveName, ' '.join(args))

elif optlist.format == 'xz':
	if len(shutil.which('pixz')) > 0:
		print('Using parallel compression..')
		cmd = 'tar -c %s | pixz > "%s.tar.xz"' % (' '.join(args), optlist.archiveName)
	else:
		cmd = 'tar -cJf %s.tar.xz %s' % (optlist.archiveName, ' '.join(args))

elif optlist.format == 'lzma':
	cmd = 'tar -c --lzma -f %s.tar.lzma %s' % (optlist.archiveName, ' '.join(args))

elif optlist.format == 'bz2':
	cmd = 'tar -cjf %s.tar.bz2 %s' % (optlist.archiveName, ' '.join(args))

elif optlist.format == '7z':
	cmd = '7z a -m0=LZMA2  "%s.tar.7z" %s' % (optlist.archiveName, ' '.join(args))

else:
	raise ValueError('Unrecognized format: %s' % (optlist.format))


#print(cmd)
subprocess.check_call(cmd, stdout=sys.stdout, stderr=sys.stderr, shell=True)
