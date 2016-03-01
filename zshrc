# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory autocd extendedglob notify
bindkey -e
# End of lines configured by zsh-newuser-install

export PATH=/home/walter/bin:$PATH

export EDITOR=vim

export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'

OGGIOGIT="ssh://git@oggio88.silksky.com:2022/srv/git"

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

function parse_name()
{
    while getopts ":n:" opt; do
        case $opt in
    	n)
            echo "name is $OPTARG" 
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            ;;
        esac
    done
}

parse_name()
{
    local o_name=(-n .)
    local o_file=()
    zparseopts -K -D -E -- n:=o_name -name:=o_name i+:=o_file -input+:=o_file h=o_help
    if [[ $? != 0 || "$o_help" != "" ]]; then
        echo Usage: $(basename "$0") "[(-n|--name) FILENAME]"
    fi
    local name=$o_name[2]
    if [[ $name = "." ]]; then
        [[ $1 =~ "(\w+)\.*" ]] 
        name="$match[1]"
    fi
    ifile=o_file
    fname=$name
    echo $@ 
}


function dumb_gz() {    
    name=($(parse_name $@))
    opts="$name[2,-1]"
    fname="$name[1]"
    if ! type "pigz" > /dev/null; then
	echo Using parallel compression.. 
        tar -c "$opts" | pigz > "$fname.tar.gz"
    else
        tar -czf "$fname.tar.gz" "$opts"
    fi
}

function dumb_xz() {    
    name=($(parse_name $@))
    opts="$name[2,-1]"
    echo  "$opts" --- "$fname" --- "$name"
    echo tar -c "$opts" "$fname" "|" pixz ">" "$fname.tar.xz"
    if ! type "pixz" > /dev/null; then
	echo Using parallel compression.. 
	tar -c "$opts" "$fname" | pixz > "$fname.tar.xz"
    else
    	tar -cJf "$fname.tar.xz" "$opts" "$fname"
    fi
}

function dumb_lzma() {    
    name=($(parse_name $@))
    opts="$name[2,-1]"
    name="$name[1]"
    tar -c --lzma -f  "$name.tar.lzma" "$opts"
}

function dumb_bzip2() {    
    name=($(parse_name $@))
    opts="$name[2,-1]"
    name="$name[1]"
    tar -cjf  "$name.tar.bz2" "$opts"
}

function dumb_7z() {    
    name=($(parse_name $@))
    opts="$name[2,-1]"
    name="$name[1]"
    echo 7z a -m0=LZMA2  \"$name.tar.7z\" \"$opts\"
    7z a -m0=LZMA2  "$name.tar.7z" "$opts"
}

alias tar.7z=dumb_7z
alias tar.lzma=dumb_lzma
alias tar.bz2=dumb_bzip2
alias tar.gz=dumb_gz
alias tar.xz=dumb_xz
alias llh="ls -lh"
