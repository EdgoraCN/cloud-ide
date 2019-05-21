## 项目介绍与用法 [Ｅnglish version](README.md)

#### 使用我的配置文件

```bash
docker run --name cloud-ide  -p 9981:8443 -v "${PWD}:/workspace"  aimacity/cloud-ide code-server --allow-http --no-auth
```

#### 使用自己的Ｓync gist 

```bash
mkdir -p ~/data-home/config

echo "novboy/45e990947d88fe1d1fa1bdbda94481cd" >> ~/data-home/config/sync.gist

docker run --rm \
  -v  ~/data-home/config:/config   \
  -v  ~/data-home:/output   \
  -e PUID=$(id -u) -e PGID=$(id -g) \
  -e TZ="Asia/Shanghai" \
  aimacity/cloud-ide:vscode

docker run --name cloud-ide  -p 8443:8443 -v "${PWD}:/workspace"  -v ~/data-home:/home/aima/.local/share/code-server aimacity/cloud-ide code-server --allow-http --no-auth
```

#### 直接从自己的glist构建镜像

- Fork 这个项目
- 修改 `sync.gist`的内容变成自己的 "USERNAME/GISTID"
- `docker build . -tag WHATEVER`
- `docker run -p 127.0.0.1:8443:8443 -v "${PWD}:/workspace" WHATEVER code-server --allow-http --no-auth`

## 主要特性

#### 支持 VSCode配置同步

- 直接从gist设置code server
- 直接使用vscode的配置文件
- VSCode 扩展从  `extensions.json`　文件提取并自动安装

#### 支持ＯneDrive同步配置和工作空间 (测试中)

#### 支持Ｍega同步配置和工作空间  (计划中)

#### [Syncthing](https://github.com/syncthing/syncthing)同步 配置和工作空间  (计划中)

#### VS Code 语言包支持 (中文已验证)

#### 工作空间设置以及工具连管理 (计划中)


#### 关于插件市场

- 目前来说插件是用的code-server过时的插件  
- 现在是通过官方版本提前预装的插件

### ssh code 用法

```bash

export VSCODE_CONFIG_DIR=$HOME/.config/Code
export VSCODE_EXTENSIONS_DIR=$HOME/.vscode/extensions
sshcode user@host  ~/code-server-workplace

```

#### 预装的开发语言支持
- Comes with 
  - Java
  - php
	- Golang
	- C++
	- Nodejs
	- Python
	- Rust
  - Ruby

工具连已经预装，并车对npm 和maven进行了更换国内阿里源操作.


## License
Credit goes to [code-server](https://github.com/codercom/code-server) project.  
Code for this configuration is licensed under Apache 2.0, detailed in [LICENSE.md](LICENSE.md)