#!/bin/bash

# setup folders
# config dir
mkdir -p ~/onedrive 

# update config file from workspace to ~/onedrive
if [ -d $IDE_WORKSPACE/.vscode/onedrive ];then
   cp  -fr $IDE_WORKSPACE/.vscode/onedrive/*  ~/onedrive 
fi

# save refresh_token to workspace ,so the config file can be update to onedrive cloud
#if [ -f ~/onedrive/refresh_token ];then
#      cp  -fr $IDE_WORKSPACE/.vscode/onedrive/*  ~/onedrive
#fi 

# read config files 
if [ -f ~/onedrive/config ];then
      cp  -fr $IDE_WORKSPACE/.vscode/onedrive/*  ~/onedrive
      cat ~/onedrive/config | sed 's/ //g' | sed 's#~ #/home/aima#g' > /tmp/config.tmp
        sync_dir=`echo  "$sync_dir" | sed 's#~#/home/aima#'`
        sync_dir=`echo  "$sync_dir" | sed 's#$HOME#/home/aima#'`
      source /tmp/config.tmp
fi 
echo "OneDrive Setting:"
echo
cat ~/onedrive/config 
echo

 # sync data dir
 if [ "$sync_dir" == "" ];then
    sync_dir="$HOME/OneDrive"
fi

mkdir -p $sync_dir

# check a refresh token exists
if [ -f ~/onedrive/refresh_token ]; then
  echo "Found onedrive refresh token..."
else
  echo
  echo "-------------------------------------"
  echo "ONEDRIVE LOGIN REQUIRED"
  echo "-------------------------------------"
  echo "To use this container you must authorize the OneDrive Client."

  if [ -t 0 ] ; then
    echo "-------------------------------------"
    echo
  else
    echo
    echo "Please execute flowing command in the terminal:"
    echo
    echo "get-onedrive-token"
    echo
    echo "Once token created, restart the onedrive service by fllowing command "
    echo
    echo " supervisorctl restart onedirve"
    echo
    echo "-------------------------------------"
    echo
    exit 1
  fi

fi


# turn on or off verbose logging
if [ "$DEBUG" = "1" ]; then
  VERBOSE=true
else
  VERBOSE=false
fi

echo "Starting onedrive client..."
sed -i  's/workspace_name/#workspace_name/g'  ~/onedrive/config
/usr/local/bin/onedrive --monitor --confdir=~/onedrive --syncdir=$sync_dir --verbose=${VERBOSE}
