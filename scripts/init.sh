#!//usr/local/bin/dumb-init /bin/sh

# proxy seting
#export http_proxy=socks5h://127.0.0.1:1080
#export https_proxy=socks5h://127.0.0.1:1080

# ssh setting


# git setting
git config --global credential.helper store
#git config --global http.proxy socks5h://127.0.0.1:1080
#git config --global https.proxy socks5h://127.0.0.1:1080
#git config --global user.name "user"
#git config --global user.email "user@aima.city"

#  yarn and npm setting
yarn config set registry https://registry.npm.taobao.org
yarn config set disturl https://npm.taobao.org/dist 
npm config set registry https://registry.npm.taobao.org
npm config set disturl https://npm.taobao.org/dist

# maven setting
mkdir -p  ~/.m2
if [ -f  "$IDE_WORKSPACE/.vscode/settings.xml" ];then
    cp $IDE_WORKSPACE/.vscode/settings.xml ~/.m2
fi





