#!/bin/bash

echo "try to down load config file from /config/sync.gist"

VS_DIR=$IDE_WORKSPACE/.vscode
GLIST=$VS_DIR/sync.gist
mkdir -p $IDE_USER_DATA_DIR/{config,User,extensions}

if [ -f "$GLIST" ] ; then
    gistid=`cat $GLIST`
    gisturl="https://gist.githubusercontent.com/${gistid}/raw"
    curl -o $VS_DIR/extensions.json "${gisturl}/extensions.json"
    curl -o $IDE_USER_DATA_DIR/User/settings.json "${gisturl}/settings.json"
    curl -o $IDE_USER_DATA_DIR/User/locale.json "${gisturl}/locale.json"
    curl -o $IDE_USER_DATA_DIR/User/keybindings.json  "${gisturl}/keybindings.json"
    echo "setting file downloaded successfully"
else 
    echo "$GLIST does not exist, skip download"
fi

echo "try to down load extensions to $IDE_USER_DATA_DIR/extensions"
EXT_CFG=$VS_DIR/extensions.json
EXT_LIST=$VS_DIR/extensions.list
if [ -f "$EXT_CFG" ] ; then
jq -r ".[].metadata.publisherId" $EXT_CFG > $EXT_LIST
echo "$EXT_LIST generated successfully"
else 
    echo "$EXT_CFG does not exist, skip generate"
fi

if [ -f "$EXT_LIST" ] ; then
while IFS='' read -r line || [[ -n "$line" ]]; do
    echo "Installing $line using VSCode";
    /tmp/VSCode-linux-x64/bin/code --user-data-dir $IDE_USER_DATA_DIR  --extensions-dir $IDE_EXTENSIONS_DIR  --install-extension $line
    echo "extensions installed successfully"
done < "$EXT_LIST"
else 
    echo "$EXT_LIST does not exist, skip installation"
fi

cp -fr  /tmp/VSCode-linux-x64/resources/app/out/nls.metadata.json  $IDE_USER_DATA_DIR/nls.metadata.json

echo "Done"
