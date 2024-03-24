#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

##-----------------------------------------------------
## synth-shell-prompt.sh
if [ -f /home/mlem/.config/synth-shell/synth-shell-prompt.sh ] && [ -n "$( echo $- | grep i )" ]; then
	source /home/mlem/.config/synth-shell/synth-shell-prompt.sh
fi

##------------------CUSTOM CC--------------------------

# cp confs to main local github repo
alias cpconf="rsync -av --progress ~/.config/ ~/github_backup/configs --exclude obsidian --exclude .git --exclude VisUAL2 --exclude /Code\ -\ OSS --exclude dconf --exclude discord --exclude gtk-3.0 --exclude BraveSoftware --exclude JetBrains"

cpbash() {
    cp ~/.bashrc ~/github_backup/bash
    cp ~/.bash_profile ~/github_backup/bash
    cp ~/.bashrc.backup  ~/github_backup/bash
    cp ~/.bash_logout  ~/github_backup/bash
}

alias cpbashrc="cp ~/.bashrc ~/github_backup"
#------------------GIT-Aliases-------------------------
alias gs="git status"
alias gp="git push"
alias gc="git commit -m"
alias g="git"
alias gaa="sudo git add ."

#-----------------Current Dir-------------------------
alias cdd="cd ~/Downloads/"
alias cdp="cd ~/projects/"
alias ads="cd ~/projects/ads/"
alias cdconfig="cd ~/.config/"
alias cdc="cd ~/Clearn/"
alias gh="cd ~/github_backup/"
alias c="cd .."

#-----------------------files------------------------
alias a="ls -a"
alias cat="bat"

#---------------------terminal-----------------------
alias e="exit"

#-----------------------sys--------------------------
alias sd="shutdown now"
alias rb="reboot"

#-----------------------scrot------------------------
alias sss="scrot --silent ~/Pictures/ss/%Y-%m-%d-%T-ss.png"
alias ssel="scrot --silent --select ~/Pictures/ss/%Y-%m-%d-%T-ss.png"

#-----------------------VIM--------------------------
alias oldvim="\vim"
alias vim="nvim"

# SourceApps
alias visual2="~/SourceApps/visualASM/VisUAL2"
