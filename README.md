## EvDev

My own configuration to run VSCode on the cloud for browser-based coding.

For the original EvDev which features EverVim and SpaceMacs, please see the [terminal](https://github.com/LER0ever/EvDev/tree/terminal) branch


## Usage
#### If you want to use my configuration:
```bash
docker run --name cloud-ide  -p 9981:8443 -v "${PWD}:/workspace"  aimacity/cloud-ide code-server --allow-http --no-auth
```

#### If you want to generate setings :
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

#### If you have your own VSCode Settings Sync setup
- Fork this project
- Change `sync.gist` into your gist id "USERNAME/GISTID"
- `docker build . -tag WHATEVER`
- `docker run -p 127.0.0.1:8443:8443 -v "${PWD}:/workspace" WHATEVER code-server --allow-http --no-auth`

## Features
#### Sync with VSCode Settings Sync
- Directly download VSCode configurations and extension lists from SettingsSync gist.
- VSCode settings is directly used for code-server
- VSCode extensions are parsed and installed automatically from `extensions.json`

#### Official VSCode Extension Market
- Code-server uses their own extensions registry and it is pretty limited and outdated, at least for now.  
- Here, Microsoft VSCode binary is used to install all the extensions before copying to code-server for final use, so they are up-to-date and official.

### ssh code usage

```bash

export VSCODE_CONFIG_DIR=$HOME/.config/Code
export VSCODE_EXTENSIONS_DIR=$HOME/.vscode/extensions
sshcode user@host  ~/code-server-workplace

```

#### Dev Tools Included out of the box
- Comes with 
	- Golang
	- C++
	- Nodejs
	- Python
	- Rust

toolings pre-installed and ready to use.

## CI and Docker Hub
This docker image is built and pushed to Docker Hub [EvDev](https://cloud.docker.com/repository/docker/ler0ever/evdev/tags) everyday with [Travis](https://travis-ci.org/LER0ever/EvDev) Cron.

## License
Credit goes to [code-server](https://github.com/codercom/code-server) project.  
Code for this configuration is licensed under Apache 2.0, detailed in [LICENSE.md](LICENSE.md)

