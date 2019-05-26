#!/bin/bash

generateOneDriveConfig(){
cat > $IDE_WORKSPACE/.vscode/onedrive/config <<'EOF'
# Directory where the files will be synced
sync_dir = "~/OneDrive"
# Skip files and directories that match this pattern
skip_file = "~*|.~*|*.tmp|*.log"
skip_dir = "node_modules|.m2|extensions|target|.cache|.npm|.git|.idea"
workspace_name=default 
EOF
}
parseConfig(){
    onedrive_cfg="$IDE_WORKSPACE/.vscode/onedrive/config"
    if [ ! -f "$onedrive_cfg" ];then
           echo "Workspace $onedrive_cfg is missing"
           echo "WARNING: this workspace is missing onedrive setting"
           current_onedrive_cfg=$HOME/onedrive/config
        if [  -f "$current_onedrive_cfg" ];then
            mkdir -p "$IDE_WORKSPACE/.vscode/onedrive"
            cp -fr $current_onedrive_cfg $onedrive_cfg
            echo  "use glabal onedrive config:$current_onedrive_cfg"
            sed -i  's/#workspace_name/workspace_name/g'  $onedrive_cfg
        else
             echo "current onedrive config is missing:$current_onedrive_cfg"
             mkdir -p "$IDE_WORKSPACE/.vscode/onedrive"
            generateOneDriveConfig
             echo "a default onedirve config file is generated: $onedrive_cfg"
        fi
    fi

    if [ -f  "$onedrive_cfg" ];then
        cat $onedrive_cfg | sed 's/ //g' > /tmp/config.tmp
        source /tmp/config.tmp
        sync_dir=`echo  "$sync_dir" | sed 's#~#/home/aima#'`
        sync_dir=`echo  "$sync_dir" | sed 's#$HOME#/home/aima#'`
        if [ ! -d "$sync_dir" ] || [ ! -d "$sync_dir/cloud-ide" ];then
            mkdir -p $sync_dir/cloud-ide
        fi
    else
        echo "ERROR: onedrive config file missing, may be you should enable onedrive first"
        exit 0
    fi
}
backup() {
    workspace_name=`getCurrentWorkspaceName`
    if [ "$workspace_name" != "" ]; then
        echo "try to backup workspace $workspace_name"
         # export extensin list
        /usr/bin/export-setting.sh
        updateWorkspaceName
    else 
         echo "try to backup original workspace $IDE_WORKSPACE"
          /usr/bin/export-setting.sh
         if [ -d "$HOME/ext_dir_bak" ] || [ -d "$HOME/user_data_bak" ];then
            echo "The backup has been done"
        else
            cp -fr $IDE_EXTENSIONS_DIR  $HOME/ext_dir_bak
            cp -fr $IDE_USER_DATA_DIR/User $HOME/user_data_bak
        fi
    fi
}

unlink() {
    rm -fr $IDE_WORKSPACE   $IDE_EXTENSIONS_DIR  $ $IDE_USER_DATA_DIR/User
}

link() {
        ln -s  $1/User  $IDE_USER_DATA_DIR/User
        ln -s  $1/workspace  $IDE_WORKSPACE
        ln -s  $1/extensions   $IDE_EXTENSIONS_DIR
        # install ext
        install-ext
        echo "Every thing is ok, please refresh browser"
        supervisorctl reload
}

restore() {
    if [ -d "$HOME/ext_dir_bak" ] && [ -d "$HOME/user_data_bak" ];then
        rm -fr   $IDE_WORKSPACE 
        ln -s /workspace $IDE_WORKSPACE 
        rm -fr $IDE_EXTENSIONS_DIR
        mv $HOME/ext_dir_bak  $IDE_EXTENSIONS_DIR
        rm -fr $IDE_USER_DATA_DIR/User
        mv $HOME/user_data_bak  $IDE_USER_DATA_DIR/User
    else 
        echo "backup dir is missing, reset can not be done"
    fi
}

list() {
    parseConfig
    if [ "$sync_dir" !=  "" ] ||  [ ! -d "$sync_dir" ];then
        echo "Available workspace:"
        echo 
        ls $sync_dir/cloud-ide
        echo 
        echo "Current workspace:"
        echo 
        echo `ls -l ~ |grep cloud-ide | sed 's#.*/cloud-ide/##g'| sed 's#/workspace$##g'`
    else 
        echo "ERROR: onedrive directory is missing, may be you should enable onedrive first"
    fi
    echo ""
}
getCurrentWorkspaceName(){
         echo `ls -l ~ |grep cloud-ide | sed 's#.*/cloud-ide/##g'| sed 's#/workspace$##g'`
}
updateWorkspaceName(){
    parseConfig
    current_name=`getCurrentWorkspaceName`
    if [ "$current_name" != "" ] &&  [ "$workspace_name" != "$current_name" ];then
        if [ -d "$onedrive_cfg" ]; then
            sed -i  '/workspace_name=/d'  $onedrive_cfg
            echo "workspace_name=$current_name" >> $onedrive_cfg
        else
            echo "$onedrive_cfg is missing"
        fi
        
    fi
    echo `ls -l ~ |grep cloud-ide | sed 's#.*/cloud-ide/##g'| sed 's#/workspace$##g'`
}

remove(){
    parseConfig
    current_name=`getCurrentWorkspaceName`

    if [ "$1" == "" ];then
        help
        exit 0
    fi

    if [ "$1" == "$current_name" ];then
        echo 
        echo "ERROR: $1 workspace is use, please leave it or use another workspace"
        echo ""
        echo "you can leave it:"
        echo ""
        echo "workspace leave"
        echo ""
        echo "or use another workspace:"
        echo ""
        workspace ls
        exit 0
    fi
    wp_path=$sync_dir/cloud-ide/$1
    if [ ! -d "$sync_dir" ] ||  [ ! -d "$wp_path" ];then

            echo "ERROR: $wp_path does not exist"

    else 
         rm -fr $wp_path
          echo "INFO: local workspace $1 was removed from the disk"
    fi
    echo ""

}

new () {
    parseConfig
    if [ "$sync_dir" != "" ] &&  [ -d "$sync_dir" ];then

        if [ "$1" != "" ]; then
             workspace_name="$1"
        fi

        if [ "$workspace_name" == "" ];then
            workspace_name="default"
        fi

        wp_path=$sync_dir/cloud-ide/$workspace_name
        if [  -d "$wp_path" ]; then
            echo "workspace $wp_path is already exist"
            echo "you can remove it via fllowing command"
            echo ""
            echo "workspace remove $workspace_name"
            echo ""
            exit 0
        fi 
        backup
        mkdir -p $wp_path/User
        mkdir -p $wp_path/workspace
        mkdir -p $wp_path/extensions
        cp  -fr $IDE_USER_DATA_DIR/User/*  $wp_path/User
        cp  -fr $IDE_EXTENSIONS_DIR/*  $wp_path/extensions
        cp -fr $IDE_WORKSPACE/.vscode  $wp_path/workspace
        unlink
        link $wp_path
    else 
        echo "ERROR: onedrive directory is missing, may be you should enable onedrive first"
    fi
}

use () {
    if [ "$1" == "" ]; then
        help
   fi
   parseConfig
   if [ "$sync_dir" != "" ] &&  [ -d "$sync_dir" ];then
        wp_path=$sync_dir/cloud-ide/$1
        echo "try to switch workspace to $wp_path"
        if [ -d "$wp_path" ] && [ -d "$wp_path/User" ] && [ -d "$wp_path/workspace" ] ;then
            mkdir -p $wp_path/extensions
            backup
            unlink
            link $wp_path
        else
                echo "ERROR: onedrive directory is missing, may be you should enable onedrive first"
                echo " if you still want to use an not exists workspace, please create bellow paths manually and retry"
                echo "mkdir -p $wp_path/User"
                echo "mkdir -p $wp_path/workspace"
                echo "mkdir -p $wp_path/extensions"
        fi 
   else 
        echo "ERROR: onedrive directory is missing, may be you should enable onedrive first"
   fi


}
save () {
    /usr/bin/export-setting.sh
}
leave () {
    restore
    echo "Every thing is ok, please refresh browser"
    supervisorctl reload
}
help () {

    echo "Usage:"
    echo "workspace"
    echo 
    echo "   list "
    echo "                 show current workspaces"
    echo
    echo "   new  [optional workspace name]"
    echo "                  create a new onedrive workspace , copy current workspace setting to the new workspace"
    echo "                  if workspace name is not exsit,the workspace_name in $HOME/workspace/.vscode/onedirve/config will be used"
    echo
    echo "   use  [workspace name] "
    echo "                  link to an exists or an empty workspace "
    echo
    echo "   remove [workspace name]"
    echo "                  remove a workspace from disk "
    echo 
    echo "   save   "
    echo "                 export extensions list to onedrive workspace"
    echo
    echo "   leave   "
    echo "                 leave onedrive workspace, use origin workspace seting"
    echo ""

}
if [ "$#" -gt  0 ]; then
    echo "action: $@"
    case $1 in
        new|create)	
            new $2
            ;;
        use)
            use $2
            ;;
        list|ls)	
           list
            ;;
        save)	
           save
            ;;
        leave|restore)	
           leave
            ;;
        delete|remove|rm)	
           remove $2
            ;;
        *) 
            help 
            ;;
    esac
    
else
   help
fi