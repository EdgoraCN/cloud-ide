# Install the actual VSCode to download configs and extensions

sudo apt-get update 
sudo	apt-get install -y curl libnss3   libgtk-3-0  libxss1 libx11-xcb1 libasound2  jq
cd /tmp 
curl -o vscode-amd64.tar.gz -L  https://vscode-update.azurewebsites.net/latest/linux-x64/stable && \
tar  -zxvf  vscode-amd64.tar.gz
rm -f vscode-amd64.tar.gz 
sudo apt autoremove 
sudo  apt clean