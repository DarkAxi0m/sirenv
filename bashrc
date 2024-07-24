alias vim=nvim

run_wfzf() {
    ~/sirenv/scripts/wfzf.sh
}

bind -x '"\C-f": run_wfzf'
bind -x '"\C-o": nautilus .'

#eval "$(zoxide init bash)"

export EDITOR=nvim

export FLYCTL_INSTALL="/home/chris/.local/fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$(go env GOPATH)/bin
export PATH=~/sirenv/scripts:$PATH

function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
