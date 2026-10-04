# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
# /etc/omarchy.conf is written by omarchy-dev-link. When absent, force the
# package default instead of preserving a stale inherited dev-link value before
# we decide which rc file to source.
if [[ -f /etc/omarchy.conf ]]; then
    source /etc/omarchy.conf
    export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
else
    export OMARCHY_PATH=/usr/share/omarchy
fi
source "$OMARCHY_PATH/default/bash/rc"

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
# tmux-sessionizer shortcut
bind '"\C-f":"tmux-sessionizer\n"'
# alias vim="nvim"
alias a="ls -la"
alias c="cd .."
alias e="exit"
alias t="tmux"
alias tk="tmux kill-server"
alias gs="git push"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/ml3m/.lmstudio/bin"
# End of LM Studio CLI section

export PATH="$HOME/.bin:$PATH"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# don't hit quota due to pip
export TMPDIR="$HOME/.tmp"
export PIP_NO_CACHE_DIR=1
export HSA_OVERRIDE_GFX_VERSION=10.3.0
