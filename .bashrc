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
alias cpconf="rsync -av --progress ~/.config/ ~/github_backup/configs --exclude .git --exclude /Code\ -\ OSS --exclude dconf --exclude discord --exclude gtk-3.0 --exclude nvim "

alias cpbashrc="cp ~/.bashrc ~/github_backup"

alias gs="git status"
alias gp="git push"
alias gco="git commit -m"
alias g="git"
alias gaa="sudo git add ."
