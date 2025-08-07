alias vim=nvim

eval "$(fzf --bash)"

run_wfzf() {
    ~/sirenv/scripts/wfzf.sh
}

bind -x '"\C-f": run_wfzf'
bind -x '"\C-o": "nohup nautilus . >/dev/null 2>&1 &"'


#eval "$(zoxide init bash)"

export EDITOR=nvim

export FLYCTL_INSTALL="/home/chris/.local/fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"



export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$(go env GOPATH)/bin
export PATH=$PATH:/home/chris/go  
export PATH="$HOME/.local/bin:$PATH"
export PATH=~/sirenv/bin:~/sirenv/scripts:$PATH

source <(mmctl completion bash)

function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
