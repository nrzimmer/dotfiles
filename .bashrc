#
# ~/.bashrc
#

# If not running interactively, don't do anything

export PATH=$PATH:$HOME/bin
export PATH="$HOME/.symfony5/bin:$PATH"

[[ $- != *i* ]] && return

export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

alias ls='ls --color=auto'
alias ll='ls --color=auto -lah'
alias cd..='cd ..'

get_git_branch() {
	git branch --show-current 2>/dev/null | sed -e '/^$/d' -e 's/\(.*\)/ (\1)/'
}

PS1='[\u@\h \[\e[32m\]\w\[\e[91m\]$(get_git_branch)\[\e[00m\]]$ '
. "$HOME/.cargo/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
