alias vim=nvim

run_wfzf() {
    ~/sirenv/scripts/wfzf.sh
}

bind -x '"\C-f": run_wfzf'
bind -x '"\C-o": nautilus .'

export EDITOR=nvim


export PATH=~/sirenv/scripts:$PATH
