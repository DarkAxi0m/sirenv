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

set -x PATH $PATH /usr/local/go/bin
set -gx PATH $PATH (go env GOPATH)/bin
set -U fish_user_paths ~/sirenv/scripts $fish_user_paths
#zoxide init fish | source  i

function yy
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		cd -- "$cwd"
	end
	rm -f -- "$tmp"
end
