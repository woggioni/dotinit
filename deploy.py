#!/usr/bin/env python3
import shutil
from os.path import join, dirname, islink, exists, abspath
from os import symlink, environ, makedirs, remove

user = environ['USER']
home = environ['HOME']
cwd = abspath(dirname(__file__))

files = {
    'gdbinit' : '.gdbinit',
    'astylerc' : '.astylerc',
    'vimrc' : '.vimrc',
    'my_zsh_config.sh' : '.oh-my-zsh/my_zsh_config.sh',
    'oh_my_zsh.sh' : '.oh-my-zsh/oh_my_zsh.sh',
    'gitconfig' : '.gitconfig',
}

def update_symlink(source, destination):
    if islink(destination):
        remove(destination)
    elif exists(destination):
        raise ValueError("File '%s' already exists and is not a symbolic link" % destination)
    symlink(source, destination)

for key, value in files.items():
    destination = join(home, value)
    update_symlink(join(cwd, key), destination)

makedirs(join(home, 'bin'), exist_ok=True)
update_symlink(join(cwd, 'compressor.py'), join(home, 'bin', 'compressor.py'))

