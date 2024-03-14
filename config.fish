alias vim=nvim
alias v="nvim ."
alias gs="git status"
alias gp="git pull; git push"
alias gl="lazygit"

function gc --wraps git --description 'alias gc=git commit'
    git add .
    git commit -a -m "$argv"
end

bind \co "nautilus . &"
bind \cf ~/sirenv/scripts/wfzf.sh

#set -Ux FLYCTL_INSTALL "/home/chris/.local/fly"
#set -U fish_user_paths $FLYCTL_INSTALL/bin $fish_user_paths


set -U fish_user_paths ~/sirenv/scripts $fish_user_paths
#zoxide init fish | source  i
