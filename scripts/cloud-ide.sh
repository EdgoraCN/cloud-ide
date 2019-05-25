#!//usr/local/bin/dumb-init /bin/sh
set -e

workspace="$HOME/workspace"
if [ "$IDE_WORKSPACE" !=  "" ] &&  [ -d "$IDE_WORKSPACE" ];then
      workspace="$IDE_WORKSPACE"
fi
allowhttp=""
if [ "$IDE_ALLOW_HTTP" = "true" ];then
      allowhttp="--allow-http"
fi

noauth=""
if [ "$IDE_NO_AUTH" = "true" ];then
      noauth="--no-auth"
fi

userdatadir="$HOME/.local/share/code-server"
if [ "$IDE_USER_DATA_DIR" !=  "" ] && [ -d "$IDE_USER_DATA_DIR" ];then
      userdatadir="$IDE_USER_DATA_DIR"
fi

extensionsdir="$HOME/.local/share/code-server/extensions"
if [ "$IDE_EXTENSIONS_DIR" != "" ] && [ -d "$IDE_EXTENSIONS_DIR" ];then
      extensionsdir="$IDE_EXTENSIONS_DIR"
fi

otherargs=""
if [ "$IDE_OTHER_ARGS" != "" ];then
      otherargs="$IDE_OTHER_ARGS"
fi

if [ -f  "$IDE_WORKSPACE/.vscode/init.sh" ];then
      echo "execute init  script for workspace"
      chmod +x  $IDE_WORKSPACE/.vscode/init.sh
      $IDE_WORKSPACE/.vscode/init.sh
fi

# link folders to fix issues  for some plugin


mkdir -p $HOME/.vscode
mkdir -p $HOME/.config

vsdata=$HOME/.config/Code
if [ -d "$vsdata" ];then
    echo "$vsdata exists"
else 
      ln -s $userdatadir $vsdata
      echo "$vsdata is created"
fi

vsext=$HOME/.vscode/extensions
if [ -d "$vsext" ];then
    echo "$vsext exists"
else 
      ln -s $extensionsdir $vsext
      echo "$vsext is created"
fi

echo "/usr/local/bin/code-server $workspace $allowhttp $noauth --user-data-dir $userdatadir --extensions-dir $userdatadir $otherargs"
# exec cmd
/usr/local/bin/code-server  $workspace $allowhttp $noauth --user-data-dir $userdatadir --extensions-dir $extensionsdir $otherargs