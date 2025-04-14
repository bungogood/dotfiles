# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Color codes for customizing the prompt and aliases
# Normal Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

NC="\e[m"               # Color Reset

LightRed='\e[38;5;9m'   # Light Red

# Function to show the current Git branch in the prompt
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}

# Customize the prompt (username@machine dir (branch) $ )
PS1="\[${Cyan}\]\u\[${NC}\]@\[${Green}\]\h\[${NC}\] "  # "username@machine "
PS1=${PS1}"\[${NC}\]\W\[${NC}\] "  # "dir "
PS1=${PS1}"\[${Cyan}\]\$(parse_git_branch)\[${NC}\]$ "  # "(branch) $ "
export PS1

# History settings to ignore duplicates and commands starting with spaces
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000  # Maximum number of commands in the history
HISTFILESIZE=2000  # Maximum size of the history file

# Automatically update the values of LINES and COLUMNS after each command
shopt -s checkwinsize

LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32'
export LS_COLORS

# Additional ls aliases for convenience
alias ls='ls --color=always'
alias ll='ls -Alh'  # List detailed information about files
alias la='ls -A'  # List all files (including hidden ones)

# Aliases for convenient file management
alias config="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias uuidgen='uuidgen | tr "[:upper:]" "[:lower:]"'  # Generate lowercase UUID
alias cls='printf "\33c\e[3J"'
alias activate='source .venv/bin/activate'

# Custom Docker alias to support temporary containers
docker() {
  if [[ $1 == "tmp" ]]; then
    command docker run --rm -it "${@:2}"  # Automatically remove the container after exit
  else
    command docker "$@"
  fi
}

source $HOME/.cargo/env
