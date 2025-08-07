#!/bin/bash


get_url_from_clipboard() {
    local clipboard_content
    clipboard_content=$(xclip -selection clipboard -o)
    echo "$clipboard_content"
}
hr() {
    local term_width
    term_width=$(tput cols)
    for ((i=0; i<$term_width; i++)); do echo -n "‗"; done; echo

}

url=$(get_url_from_clipboard)

if [ "$#" -eq 1 ]; then
    url="$1"
fi

if [[ $url == *[$'\n\t\r']* ]]; then
    echo "🚫 $url"
    hr
    echo "Error: url contains one or more common control characters"
    exit 1
fi

TMPDIR=`mktemp -d`
download_path=$TMPDIR
hr
cd $download_path
pwd
echo "Getting: $url"

python3 "$HOME/sirenv/bin/youtube-dl" --rm-cache-dir
python3 "$HOME/sirenv/bin/youtube-dl" -v  --format 18 --no-warnings --verbose --no-call-home "$url"
