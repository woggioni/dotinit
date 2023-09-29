#!/usr/bin/env python3
from os.path import join, dirname, islink, exists, abspath
from os import symlink, environ, makedirs, remove

user = environ['USER']
home = environ['HOME']
config = environ.get('XDG_CONFIG_HOME', join(home, '.config'))
cwd = abspath(dirname(__file__))

files = {
    'gdbinit': '.gdbinit',
    'astylerc': '.astylerc',
    'vimrc': '.vimrc',
    'gitconfig': '.gitconfig',
    'zshrc.sh': '.zshrc',
    'zshenv.sh': '.zshenv',
    'zsh_profile.sh': join(config, 'zsh/profile'),
    'fish/functions/gradlew.fish': '.config/fish/functions/gradlew.fish',
    'fish/functions/gradlew8.fish': '.config/fish/functions/gradlew8.fish',
    'fish/functions/gradlew11.fish': '.config/fish/functions/gradlew11.fish',
    'fish/functions/gradlew17.fish': '.config/fish/functions/gradlew17.fish',
    'fish/functions/gradlew21.fish': '.config/fish/functions/gradlew21.fish',
    'fish/functions/mkcd.fish': '.config/fish/functions/mkcd.fish',
}


def update_symlink(source, destination):
    if islink(destination):
        remove(destination)
    elif exists(destination):
        raise ValueError("File '%s' already exists and is not a symbolic link" % destination)
    symlink(source, destination)


for key, value in files.items():
    destination = join(home, value)
    makedirs(dirname(destination), exist_ok=True)
    update_symlink(join(cwd, key), destination)

makedirs(join(home, 'bin'), exist_ok=True)
update_symlink(join(cwd, 'compressor.py'), join(home, 'bin', 'compressor.py'))
