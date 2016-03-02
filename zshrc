# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory autocd extendedglob notify
bindkey -e
# End of lines configured by zsh-newuser-install

function svndiff () { svn diff $@ | colordiff }

# Prefer ipython for interactive shell
smart_python () {
    # this function is actually rather dumb
    if [[ -n $1 ]]; then
        python $argv
    else
        #if no parameters were given, then assume we want an ipython shell
        if [[ -n $commands[ipython] ]]; then
            ipython
        else
            python
        fi
    fi
}

alias py=smart_python

smart_python2 () {
    # this function is actually rather dumb
    if [[ -n $1 ]]; then
        python2 $argv
    else
        #if no parameters were given, then assume we want an ipython shell
        if [[ -n $commands[ipython] ]]; then
            ipython2
        else
            python2
        fi
    fi
}

alias py2=smart_python2

# tab-complete options for smart_python just like for python
compdef _python smart_python

# Give us a root shell, or run the command with sudo.
# Expands command aliases first (cool!)

smart_sudo () {
    if [[ -n $1 ]]; then
        #test if the first parameter is a alias
        if [[ -n $aliases[$1] ]]; then
            #if so, substitute the real command
            sudo ${=aliases[$1]} $argv[2,-1]
        else
            #else just run sudo as is
            sudo $argv
        fi
    else
        #if no parameters were given, then assume we want a root shell
        sudo -s
    fi
}

alias sdo=smart_sudo
compdef _sudo smart_sudo


extract_archive () {
    local old_dirs current_dirs lower
    lower=${(L)1}
    old_dirs=( *(N/) )
    if [[ $lower == *.tar.gz || $lower == *.tgz || $lower == *.tar.xz ]]; then
        tar xfv $1
    elif [[ $lower == *.gz ]]; then
        gunzip $1
    elif [[ $lower == *.tar.bz2 || $lower == *.tbz ]]; then
        bunzip2 -c $1 | tar xfv -
    elif [[ $lower == *.bz2 ]]; then
        bunzip2 $1
    elif [[ $lower == *.zip ]]; then
        unzip $1
    elif [[ $lower == *.rar ]]; then
        unrar e $1
    elif [[ $lower == *.tar ]]; then
        tar xfv $1
    elif [[ $lower == *.lha ]]; then
        lha e $1
    else
        print "Unknown archive type: $1"
        return 1
    fi
    # Change in to the newly created directory, and
    # list the directory contents, if there is one.
    current_dirs=( *(N/) )
    for i in {1..${#current_dirs}}; do
        if [[ $current_dirs[$i] != $old_dirs[$i] ]]; then
            cd $current_dirs[$i]
            ls
            break
        fi
    done
}

alias ex=extract_archive
compdef '_files -g "*.gz *.tgz *.bz2 *.tbz *.zip *.rar *.tar *.lha"' extract_archive    

alias tar.7z="compressor.py -f 7z"
alias tar.lzma="compressor.py -f lzma"
alias tar.bz2="compressor.py -f bz2"
alias tar.gz="compressor.py -f gz"
alias tar.xz="compressor.py -f xz"
alias llh="ls -lh"
