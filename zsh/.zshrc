# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

ZSH_THEME="robbyrussell"
# tryin something new
# ZSH_THEME="jnrowe"


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

HISTFILE=~/.zsh_history

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
#
#
# Recommended location for the cache file
ZSH_COMPDUMP="$HOME/.zcompdump"

# Load the completion cache if it exists and is valid
if [[ -s "$ZSH_COMPDUMP" && "$ZSH_VERSION" == "$(<"$ZSH_COMPDUMP")" ]]; then
    source "$ZSH_COMPDUMP"
else
    compinit
fi

# This line is crucial: tell compinit to use and update the cache
autoload -Uz compinit
compinit -C -d "$ZSH_COMPDUMP"

# Ensure this is after the compinit calls
# (The location might vary depending on how you load zsh-autosuggestions)
# Source your zsh-autosuggestions setup here, e.g.:
# source /path/to/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
#
##------------------CUSTOM CC--------------------------

bindkey -s ^f "tmux-sessionizer\n"
bindkey '^ ' autosuggest-accept

# others
alias ls='ls --color=auto'
alias grep='grep --color=auto'

#------------------GIT-Aliases-------------------------
alias gs="git status"
alias gp="git push"
alias g="git"
alias gaa="sudo git add ."
alias gss='git log --all --topo-order --graph --show-signature'

#-----------------Current Dir-------------------------
alias cdd="cd ~/Downloads/"
alias c="cd .."
alias dot="~/.dotfilesmacos/"

#-----------------------files------------------------
#alias a="ls -a"
alias a="ls -a"
alias cat="bat"

#---------------------terminal-----------------------
alias e="exit"

#-----------------------VIM--------------------------
alias oldvim="\vim"
alias vim="nvim"

#-----------------------TMUX-------------------------
alias t="tmux"
alias tk="tmux kill-server"

#-----------------------ICloud--------------------------
alias ic="~/Library/Mobile\ Documents/com~apple~CloudDocs/"

#----------------------- Obsidian --------------------------
#old one
#alias oo="~/Library/Mobile\ Documents/com~apple~CloudDocs/main/"
alias oo="~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/main/"

# 'tmux new-session -d -s my_session "vim /path/to/your/file" && tmux attach-session -t my_session'
# I don't use this.
# alias todo='tmux new-session -d -s TODO "nvim ~/Library/Mobile\ Documents/com~apple~CloudDocs/main/TODO/todo.org" && tmux attach-session -t TODO'



#----------------------- MACOS --------------------------
alias kill_animation_dock= 'defaults write com.apple.dock autohide-time-modifier -int 0;killall Dock'


#source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
export PATH="/usr/local/opt/mysql@8.4/bin:$PATH"

# Set up Qt -> CGAL basic Viewer environment
#export PATH="/opt/homebrew/opt/qt/bin:$PATH"
#export CMAKE_PREFIX_PATH="/opt/homebrew/opt/qt"
export PATH="$HOME/bin:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"

export PATH=$PATH:$HOME/go/bin

## bun completions
#[ -s "/Users/mlem/.bun/_bun" ] && source "/Users/mlem/.bun/_bun"
#
## bun
#export BUN_INSTALL="$HOME/.bun"
#export PATH="$BUN_INSTALL/bin:$PATH"
#PATH=$(pyenv root)/shims:$PATH
#
#export PYENV_ROOT="$HOME/.pyenv"
#[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
#eval "$(pyenv init - zsh)"
#
#export PATH=$PATH:$(npm config get prefix)/bin
#
