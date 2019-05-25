#!/bin/bash
parseConfig(){
    onedrive_cfg=$HOME/onedrive/config
    if [ ! -f $onedrive_cfg ];then
        echo "$onedrive_cfg is missing"
        onedrive_cfg="$IDE_WORKSPACE/.vscode/onedrive/config"
        if [  -f $onedrive_cfg ];then
            echo "use workspace onedrive config:$onedrive_cfg"
        fi
    else
        sed -i  's/#workspace_name/workspace_name/g'  $onedrive_cfg
    fi

    if [ -f  "$onedrive_cfg" ];then
        cat $onedrive_cfg | sed 's/ //g' > /tmp/config.tmp
        source /tmp/config.tmp
        sync_dir=`echo  "$sync_dir" | sed 's#~#/home/aima#'`
        sync_dir=`echo  "$sync_dir" | sed 's#$HOME#/home/aima#'`
        if [ ! -d "$sync_dir" ];then
            mkdir -p $sync_dir
        fi
    else
        echo "ERROR: onedrive config file missing, may be you should enable onedrive first"
    fi
}
backup() {

    if [ -d "$HOME/ext_dir_bak" ] || [ -d "$HOME/workspace_bak" ] || [ -d "$HOME/user_data_bak" ];then
        echo "The backup has been done"
    else
        cp -fr $IDE_WORKSPACE  $HOME/workspace_bak
        cp -fr $IDE_EXTENSIONS_DIR  $HOME/ext_dir_bak
        cp -fr $IDE_USER_DATA_DIR/User $HOME/user_data_bak
    fi
}

remove() {
    rm -fr $IDE_WORKSPACE   $IDE_EXTENSIONS_DIR  $ $IDE_USER_DATA_DIR/User
}

restore() {
    if [ -d "$HOME/ext_dir_bak" ] && [ -d "$HOME/workspace_bak" ] && [ -d "$HOME/user_data_bak" ];then
        rm -fr   $IDE_WORKSPACE 
        mv  $HOME/workspace_bak $IDE_WORKSPACE
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
}

new () {
    parseConfig
    echo "$sync_dir"
    if [ "$sync_dir" != "" ] &&  [ -d "$sync_dir" ];then
        if [ "$workspace_name" == "" ];then
            workspace_name="default"
        fi

        wp_path=$sync_dir/cloud-ide/$workspace_name
        if [  -d "$wp_path" ]; then
            echo "workspace $wp_path is already exist"
            exit 0
        fi 
        mkdir -p $wp_path/User
        mkdir -p $wp_path/workspace
        cp  -fr $IDE_USER_DATA_DIR/User/*  $wp_path/User
        # export extensin list
        /usr/bin/export-setting.sh
        cp -fr $IDE_WORKSPACE/.vscode  $wp_path/workspace
        backup
        remove
        ln -s  $wp_path/User  $IDE_USER_DATA_DIR/User
        ln -s  $wp_path/workspace  $IDE_WORKSPACE
        mkdir -p $IDE_EXTENSIONS_DIR
        # install ext
        install-ext
        echo "Every thing is ok, please refresh browser"
        supervisorctl reload
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
            /usr/bin/export-setting.sh
            backup
            remove
            ln -s  $wp_path/User  $IDE_USER_DATA_DIR/User
            ln -s  $wp_path/workspace  $IDE_WORKSPACE
            mkdir -p $IDE_EXTENSIONS_DIR
            # install ext
            install-ext
             echo "Every thing is ok, please refresh browser"
            supervisorctl reload
            
        else
                echo "ERROR: onedrive directory is missing, may be you should enable onedrive first"
                echo " if you still want to use an not exists workspace, please create bellow paths manually and retry"
                echo "mkdir -p $wp_path/User"
                echo "mkdir -p $wp_path/workspace"
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
    echo "   new "
    echo "                  create a new onedrive workspace , copy current workspace setting to the new workspace"
    echo "   use  [workspace name] "
    echo "                  link to an exists or an empty workspace "
    echo
    echo "   save   "
    echo "                 export extensions list to onedrive workspace"
    echo
    echo "   leave   "
    echo "                 leave onedrive workspace, use origin workspace seting"
    echo ""

}
if [ "$#" -gt  0 ]; then
    echo "params: $@"
    case $1 in
        new|create)	
            new
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
        *) 
            help 
            ;;
    esac
    
else
   help
fi