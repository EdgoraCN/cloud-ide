# Cloud IDE [English](README.md) 

本项目旨在为开发人员打造一套完整易用的云开发环境

## 快速启动

### 使用默认设置禁用https和密码登录

```bash
docker run --name cloud-ide   \
-p 8443:8443  \
-e IDE_ALLOW_HTTP=true \
-e IDE_NO_AUTH=true \
aimacity/cloud-ide
```

### 完整的环境变量列表

```bash
# code-server directory
 IDE_USER_DATA_DIR="$HOME/.local/share/code-server"
 # workspace directory
IDE_WORKSPACE="/workspace"
 # code-server extensions directory
IDE_EXTENSIONS_DIR="$HOME/.local/share/code-server/extensions"
 # allow http acess
IDE_ALLOW_HTTP=false
 # allow  anonymous access
IDE_NO_AUTH=false
```

### 一个复杂点的配置例子

```bash
docker run  -d  \
--name cloud-ide  \
--restart always \
-p 8443:8443  \
-e IDE_ALLOW_HTTP=true \
-e IDE_NO_AUTH=true \
-e IDE_EXTENSIONS_DIR=/extensions \
-e TZ="Asia/Shanghai"  \
-v ~/workspace/ermscloud:/workspace   \
-v ~/vwcode-data-dir:/home/aima/.local/share/code-server \
-v ~/extensions:/extensions \
aimacity/cloud-ide

```

## VS Code 设置

### 默认设置

* 默认安装的插件列表 [config/extensions.list](config/extensions.list)
* 默认中文语言 `zh-cn` [config/locale.json](config/locale.json)
* 默认maven设置 [config/setting.xml](config/setting.xml)

### 使用Settings Sync产生的gist文件配置IDE

```bash
#   创建一个文件 `$IDE_WORKSPACE/.vscode/sync.gist`, 将gist文件用户和token复制进去 
echo "novboy/45e990947d88fe1d1fa1bdbda94481cd" >> $IDE_WORKSPACE/.vscode/sync.gist
# 从 glist 加载配置并安装插件 
install-ext
# 从IDE终端重启IDE
restart-ide
```

### 使用 extensions.list 安装 VS Code 插件

```bash
# 创建一个文件`$IDE_WORKSPACE/.vscode/extensions.list `, 将要安装的插件id 放进去
cat > $IDE_WORKSPACE/.vscode/extensions.list <<'EOF'
felipecaputo.git-project-manager
donjayamanne.githistory
EOF
# 安装插件
install-ext
# 或者将插件ID 追加到命令后面进行安装
install-ext felipecaputo.git-project-manager donjayamanne.githistory
# 重启IDE服务
restart-ide
```

## 工作空间设置

### 在IDE启动之前从工作空间加载脚本

* 默认的初始化脚本位置为  `$IDE_WORKSPACE/.vscode/init.sh`

```bash
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
```

### Supervisord 服务管理

* 自定义服务必须以`.conf`结束，并且放到 `$IDE_WORKSPACE/.vscode/service` 下面 即可被Supervisord加载

* 下面是一个autossh建立稳定隧道的配置文件样例

```ini
[program:socks5AndDatabase]
command=/usr/bin/autossh  -M 31221   -i   %(ENV_IDE_WORKSPACE)s/.vscode/code.key  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  -o ServerAliveInterval=60  -o ServerAliveCountMax=3  -N  -L 5433:192.168.1.100:5433   -D  5555    user@aima.city
process_name=socks5AndDatabase
#numprocs=1
autostart=true
autorestart=true
startretries=999
redirect_stderr=true
```

* 加载服务

```bash
supervisorctl reread
supervisorctl  update
```

### 开发语言和工具支持

下面的开发工具已预先安装可以直接使用

```html
- Comes with
  - Java
  - php
  - Golang
  - C++
  - Nodejs
  - Python
  - Rust
  - Ruby
```

### 设置和工作空间同步

* OneDrive 同步 (进行中)

* Mega 同步 (未开始)

* [Syncthing](https://github.com/syncthing/syncthing) 同步  (未开始)

## 主要特性

* 工作空间和设置同步

* 工作空间服务、工具连管理 (计划中)

* VS Code 多语言支持  (中文已测)

* 网络设置（计划中）

## 许可协议

Credit goes to [code-server](https://github.com/aimacity/code-server) project.  
Code for this configuration is licensed under Apache 2.0, detailed in [LICENSE.md](LICENSE.md)