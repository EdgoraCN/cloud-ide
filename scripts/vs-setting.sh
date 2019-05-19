#!/bin/bash

echo "try to down load config file from /config/sync.gist"

GLIST=/config/sync.gist

mkdir -p /output/{config,User,extensions}

if [ -f "$GLIST" ] ; then
    gistid=`cat /config/sync.gist`
    gisturl="https://gist.githubusercontent.com/${gistid}/raw"
    curl -o /output/config/extensions.json "${gisturl}/extensions.json"
    curl -o /output/User/settings.json "${gisturl}/settings.json"
    curl -o /output/User/locale.json "${gisturl}/locale.json"
    curl -o /output/User/keybindings.json  "${gisturl}/keybindings.json"
    echo "setting file downloaded successfully"
else 
    echo "$GLIST does not exist, skip download"
fi

echo "try to down load extensions to /output/extensions"
EXT_CFG=/output/config/extensions.json
EXT_LIST=/output/config/extensions.list
if [ -f "$EXT_CFG" ] ; then
jq -r ".[].metadata.publisherId" $EXT_CFG > $EXT_LIST
echo "$EXT_LIST generated successfully"
else 
    echo "$EXT_CFG does not exist, skip generate"
fi

if [ -f "$EXT_LIST" ] ; then
while IFS='' read -r line || [[ -n "$line" ]]; do
    echo "Installing $line using VSCode";
    $HOME/VSCode-linux-x64/bin/code --user-data-dir /output  --extensions-dir /output/extensions   --install-extension $line
    echo "extensions installed successfully"
done < "$EXT_LIST"
else 
    echo "$EXT_LIST does not exist, skip installation"
fi

cp -fr  /root/VSCode-linux-x64/resources/app/out/nls.metadata.json  /output/nls.metadata.json


chown -R $PUID:$PGID /output

echo "Done"
