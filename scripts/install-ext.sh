#!/bin/bash

if [ -f "/tmp/VSCode-linux-x64/bin/code" ] ; then
        echo "vscode portable version found at /tmp/VSCode-linux-x64/bin/code"
else
    echo "try to download vscode portable version"
    /usr/bin/install-vscode
fi

if [ "$#" -gt  0 ]; then
     echo "try to install  extensions: $@"
     for var in "$@"
    do
        /tmp/VSCode-linux-x64/bin/code --user-data-dir $IDE_USER_DATA_DIR  --extensions-dir $IDE_EXTENSIONS_DIR  --install-extension $var
    done
    echo "Done"
    exit 0;
fi

VS_DIR=$IDE_WORKSPACE/.vscode
GLIST=$VS_DIR/sync.gist

echo "try to down load config file from gist file $GLIST"

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
cat $EXT_LIST | sed  '/#/d'  > /tmp/extensions.list
while IFS="" read -r line || [ -n "$line" ]; do
    if [[ "$line"  =~ ^[a-zA-Z0-9] ]];then
        echo "Installing $line using VSCode";
        /tmp/VSCode-linux-x64/bin/code --user-data-dir $IDE_USER_DATA_DIR  --extensions-dir $IDE_EXTENSIONS_DIR  --install-extension $line
        echo "extensions installed successfully"
    else
        echo "skip plugin $line";
    fi
done < "/tmp/extensions.list"
else 
    echo "$EXT_LIST does not exist, skip installation"
fi

cp -fr  /tmp/VSCode-linux-x64/resources/app/out/nls.metadata.json  $IDE_USER_DATA_DIR/nls.metadata.json

echo "Done"
