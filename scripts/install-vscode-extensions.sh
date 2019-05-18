#!/bin/bash

while IFS='' read -r line || [[ -n "$line" ]]; do
    echo "Installing $line using VSCode";
    $HOME/VSCode-linux-x64/bin/code --user-data-dir $HOME/.local/share/code-server --extensions-dir $HOME/.local/share/code-server/extensions   --install-extension $line
    #code --user-data-dir /root/.config/Code --install-extension $line
done < "$1"
