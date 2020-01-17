# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory autocd extendedglob notify
bindkey -e
# End of lines configured by zsh-newuser-install

export ZSH=/usr/share/oh-my-zsh
ZSH_THEME="agnoster"

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
        source /etc/profile.d/vte.sh
fi

source $ZSH/oh-my-zsh.sh

# User profile
if [[ -e "$XDG_CONFIG_HOME/zsh/profile" ]]; then
	source "$XDG_CONFIG_HOME/zsh/profile"
fi
