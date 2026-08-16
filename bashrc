alias vim=nvim

eval "$(fzf --bash)"

MMCTL_COMPLETION_CACHE="$HOME/.cache/sirenv/mmctl-completion.bash"

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
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$HOME/go"
export PATH="$HOME/.local/bin:$PATH"
export PATH=~/sirenv/bin:~/sirenv/scripts:$PATH

if [ -r "$MMCTL_COMPLETION_CACHE" ]; then
    # Avoid generating completions on every shell startup.
    source "$MMCTL_COMPLETION_CACHE"
fi

function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
