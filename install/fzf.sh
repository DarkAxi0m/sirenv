#!/bin/bash

if [ -d "$HOME/.fzf" ]; then
  echo "Folder $HOME/.fzf exists."
  cd "$HOME/.fzf" && git pull && ./install
else
  echo "Folder $HOME/.fzf does not exist."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install"
fi


