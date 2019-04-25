#!/bin/bash

gistid=`cat ../sync.gist`
gisturl="https://gist.githubusercontent.com/${gistid}/raw"

curl -o ../extensions.json "${gisturl}/extensions.json"
curl -o ../settings.json "${gisturl}/settings.json"
curl -o ../locale.json "${gisturl}/locale.json"
curl -o ../keybindings.json  "${gisturl}/keybindings.json"
