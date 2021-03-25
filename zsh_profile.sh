function svndiff () { svn diff $@ | colordiff }

alias mmake="nice make -j8"

# Prefer ipython for interactive shell
smart_python () {
    version="$1"
    shift
    # this function is actually rather dumb
    if [[ -n $1 ]]; then
        python${version} $argv
    else
        #if no parameters were given, then assume we want an ipython shell
        if [[ -n $commands[ipython${version}] ]]; then
            ipython${version}
        else
            python${version}
        fi
    fi
}

for suffix in '' '3' '2'
do
    alias py${suffix}="smart_python \"${suffix}\""
    # compdef _python py${suffix}
done

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
# compdef _sudo smart_sudo


extract_archive () {
    local old_dirs current_dirs lower
    lower=${(L)1}
    old_dirs=( *(N/) )
    if [[ $lower == *.tar.gz || $lower == *.tgz || $lower == *.tar.xz || $lower == *.txz ]]; then
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
# compdef '_files -g "*.gz *.tgz *.bz2 *.tbz *.zip *.rar *.tar *.lha"' extract_archive    

alias tar.7z="compressor.py -f 7z"
alias tar.lzma="compressor.py -f lzma"
alias tar.bz2="compressor.py -f bz2"
alias tar.gz="compressor.py -f gz"
alias tar.xz="compressor.py -f xz"
alias llh="ls -lh"

if [[ -e /usr/share/zsh/site-contrib/powerline.zsh ]]; then
	# Powerline support is enabled if available, otherwise use a regular PS1
	. /usr/share/zsh/site-contrib/powerline.zsh
	VIRTUAL_ENV_DISABLE_PROMPT=true
fi

# add ~/.config/zsh/completion to completion paths
# NOTE: this needs to be a directory with 0755 permissions, otherwise you will
# get "insecure" warnings on shell load!
fpath=("$XDG_CONFIG_HOME/zsh/completion" $fpath)


# Color aliases
if command -V dircolors >/dev/null 2>&1; then
	eval "$(dircolors -b)"
	# Only alias ls colors if dircolors is installed
	alias ls="ls -F --color=auto"
	alias dir="dir --color=auto"
	alias vdir="vdir --color=auto"
fi

alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
# make less accept color codes and re-output them
alias less="less -R"

# Make ctrl-e edit the current command line
#autoload edit-command-line
#zle -N edit-command-line
#bindkey "^e" edit-command-line

# Make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
	function zle-line-init {
		printf "%s" ${terminfo[smkx]}
	}
	function zle-line-finish {
		printf "%s" ${terminfo[rmkx]}
	}
	zle -N zle-line-init
	zle -N zle-line-finish
fi

# typing ... expands to ../.., .... to ../../.., etc.
rationalise-dot() {
	if [[ $LBUFFER = *.. ]]; then
		LBUFFER+=/..
	else
		LBUFFER+=.
	fi
}
zle -N rationalise-dot
bindkey . rationalise-dot
bindkey -M isearch . self-insert # history search fix


##
# Aliases
#

# some more ls aliases
alias l="ls -CF"
alias ll="ls -l"
alias la="ls -A"
alias lh="ls -lh"
alias lash="ls -lAsh"
alias sl="ls"

# Make unified diff syntax the default
alias diff="diff -u"

# simple webserver
alias mkhttp="python3 -m http.server"

# json prettify
alias json="python -m json.tool"

# octal+text permissions for files
alias perms="stat -c '%A %a %n'"
alias tarxz="tar -I 'xz -9 -T 0'"

##
# Functions
#

# make a backup of a file
# https://github.com/grml/grml-etc-core/blob/master/etc/zsh/zshrc
bk() {
	cp -a "$1" "${1}_$(date --iso-8601=seconds)"
}

# display a list of supported colors
function lscolors {
	((cols = $COLUMNS - 4))
	s=$(printf %${cols}s)
	for i in {000..$(tput colors)}; do
		echo -e $i $(tput setaf $i; tput setab $i)${s// /=}$(tput op);
	done
}

# get the content type of an http resource
function htmime {
	if [[ -z $1 ]]; then
		print "USAGE: htmime <URL>"
		return 1
	fi
	mime=$(curl -sIX HEAD $1 | sed -nr "s/Content-Type: (.+)/\1/p")
	print $mime
}

# open a web browser on google for a query
function google {
	xdg-open "https://www.google.com/search?q=`urlencode "${(j: :)@}"`"
}

# print a separator banner, as wide as the terminal
function hr {
	print ${(l:COLUMNS::=:)}
}

# launch an app
function launch {
	type $1 >/dev/null || { print "$1 not found" && return 1 }
	$@ &>/dev/null &|
}
alias launch="launch " # expand aliases

# urlencode text
function urlencode {
	print "${${(j: :)@}//(#b)(?)/%$[[##16]##${match[1]}]}"
}

# get public ip
function myip {
	local api
	case "$1" in
		"-4")
			api="http://v4.ipv6-test.com/api/myip.php"
			;;
		"-6")
			api="http://v6.ipv6-test.com/api/myip.php"
			;;
		*)
			api="http://ipv6-test.com/api/myip.php"
			;;
	esac
	curl -s "$api"
	echo # Newline.
}

# Create short urls via http://goo.gl using curl(1).
# Contributed back to grml zshrc
# API reference: https://code.google.com/apis/urlshortener/
function zurl {
	if [[ -z $1 ]]; then
		print "USAGE: $0 <URL>"
		return 1
	fi

	local url=$1
	local api="https://www.googleapis.com/urlshortener/v1/url"
	local data

	# Prepend "http://" to given URL where necessary for later output.
	if [[ $url != http(s|)://* ]]; then
		url="http://$url"
	fi
	local json="{\"longUrl\": \"$url\"}"

	data=$(curl --silent -H "Content-Type: application/json" -d $json $api)
	
	# Match against a regex and print it
	if [[ $data =~ '"id": "(http://goo.gl/[[:alnum:]]+)"' ]]; then
		print $match
	fi
}



function +vi-git-stash() {
	if [[ -s "${hook_com[base]}/.git/refs/stash" ]]; then
		hook_com[misc]="%{$fg_bold[grey]%}~%{$reset_color%}"
	fi
}

# Syntax highlighting plugin
if [[ -e /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
	source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Check if $LANG is badly set as it causes issues
if [[ $LANG == "C"  || $LANG == "" ]]; then
	>&2 echo "$fg[red]The \$LANG variable is not set. This can cause a lot of problems.$reset_color"
fi

mkcd(){
    mkdir $1 && cd $1
}

json_less() {
    python3 -m json.tool "$@"  | less
}

gradlew() {
    local folder="."
    while true
    do
        if [ -f "${folder}/gradlew" ]
        then
            "${folder}/gradlew" "$@"
            return $?
        elif [[ "${folder}" ==  "/" ]]
        then
            gradle "$@"
            return $?
        else
            folder=$(realpath "${folder}/../")
        fi
    done
}

gradlew8() {
    gradlew -Dorg.gradle.java.home=/usr/lib/jvm/java-8-openjdk $@
}

gradlew11() {
    gradlew -Dorg.gradle.java.home=/usr/lib/jvm/java-11-openjdk $@
}

gradlew-j9-8() {
    gradlew -Dorg.gradle.java.home=/usr/lib/jvm/java-8-j9 $@
}

gradlew-j9-11() {
    gradlew -Dorg.gradle.java.home=/usr/lib/jvm/java-11-j9 $@
}

RunTestNode() {
    if [ -n "$1" ]
    then
        (cd build/nodes/$1 && rlwrap -H ~/.crash_history -a /usr/lib/jvm/java-8-openjdk/bin/java -jar corda.jar)
    else
        >&2 echo "This function needs the node name as the first command line argument"
        return -1
    fi
}

DebugTestNode() {
    if [ -n "$1" ]
    then
        (cd build/nodes/$1 && rlwrap -H ~/.crash_history -a /usr/lib/jvm/java-8-openjdk/bin/java -Dcapsule.jvm.args="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=$2" -jar corda.jar)
    else
        >&2 echo "This function needs the node name as the first command line argument and the debug port number as second argument"
        return -1
    fi
}

RunTestNode11() {
    if [ -n "$1" ]
    then
        (cd build/nodes/$1 && rlwrap -H ~/.crash_history -a /usr/lib/jvm/java-11-openjdk/bin/java -jar corda.jar)
    else
        >&2 echo "This function needs the node name as the first command line argument"
        return -1
    fi
}

DebugTestNode11() {
    if [ -n "$1" ]
    then
        (cd build/nodes/$1 && rlwrap -H ~/.crash_history -a /usr/lib/jvm/java-11-openjdk/bin/java -Dcapsule.jvm.args="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=$2" -jar corda.jar)
    else
        >&2 echo "This function needs the node name as the first command line argument and the debug port number as second argument"
        return -1
    fi
}
