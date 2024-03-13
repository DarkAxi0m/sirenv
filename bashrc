alias vim=nvim

run_wfzf() {
    ~/sirenv/scripts/wfzf.sh
}

bind -x '"\C-f": run_wfzf'
bind -x '"\C-o": nautilus .'

eval "$(zoxide init bash)"

export EDITOR=nvim

export FLYCTL_INSTALL="/home/chris/.local/fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"


export PATH=~/sirenv/scripts:$PATH
