# Just use the code-server docker binary
FROM aimacity/code-server as coder-binary

FROM ubuntu:18.10 as vscode-env
ARG DEBIAN_FRONTEND=noninteractive

# Install the actual VSCode to download configs and extensions
RUN apt-get update && \
	apt-get install -y curl libnss3   libgtk-3-0  libxss1 libx11-xcb1 libasound2  jq&& \
	cd $HOME && curl -o vscode-amd64.tar.gz -L  https://vscode-update.azurewebsites.net/latest/linux-x64/stable && \
	tar  -zxvf  vscode-amd64.tar.gz || true && \
	rm -f vscode-amd64.tar.gz && \
	pwd && ls -ltr

COPY scripts /root/scripts
#COPY sync.gist /root/sync.gist

# This gets user config from gist, parse it and install exts with VSCode
##RUN $HOME/ -v --user-data-dir /root/.config/Code && \
# RUN  cd /root/scripts && \
# 	sh get-config-from-gist.sh && \
# 	sh parse-extension-list.sh && \
# 	sh install-vscode-extensions.sh ../extensions.list

# The production image for code-server
FROM aimacity/workspace-full 
LABEL author="ide@aima.city"

USER root

COPY scripts /root/scripts
# Install langauge toolchains
#RUN sh /root/scripts/install-tools-nodejs.sh
RUN sh /root/scripts/install-tools-dev.sh
#RUN sh /root/scripts/install-tools-golang.sh
#RUN sh /root/scripts/install-tools-cpp.sh
#RUN sh /root/scripts/install-tools-python.sh
#RUN sh /root/scripts/install-tools-java.sh


USER  aima
ENV IDE_USER_DATA_DIR="$HOME/.local/share/code-server"
ENV IDE_WORKSPACE="/workspace"
ENV IDE_EXTENSIONS_DIR="$HOME/.local/share/code-server/extensions"
ENV IDE_ALLOW_HTTP=false
ENV IDE_NO_AUTH=false
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

COPY  --from=coder-binary /usr/local/bin/code-server /usr/local/bin/code-server
RUN  mkdir -p $IDE_USER_DATA_DIR/User && sudo mkdir /workspace  && sudo chown aima:aima /workspace
#COPY  --chown=aima:aima  --from=vscode-env /root/settings.json $IDE_USER_DATA_DIR/User/settings.json
#COPY  --chown=aima:aima --from=vscode-env /root/.local/share/code-server/extensions $IDE_USER_DATA_DIR/extensions
#COPY  --chown=aima:aima --from=vscode-env /root/locale.json $IDE_USER_DATA_DIR/User/locale.json
#COPY  --chown=aima:aima --from=vscode-env /root/keybindings.json $IDE_USER_DATA_DIR/User/keybindings.json
COPY  --chown=aima:aima --from=vscode-env /root/VSCode-linux-x64/resources/app/out/nls.metadata.json  $IDE_USER_DATA_DIR/nls.metadata.json

WORKDIR /workspace

#RUN yarn config set registry https://registry.npm.taobao.org  && \
#yarn config set disturl https://npm.taobao.org/dist && \
#npm config set registry https://registry.npm.taobao.org &&\
#npm config set disturl https://npm.taobao.org/dist

#ENV JAVA_HOME=$HOME/.sdkman/candidates/java/current
#ENV M2_HOME=$HOME/.sdkman/candidates/maven/current
COPY --chown=aima:aima  config/settings.xml $M2_HOME/conf

# setup supervisord

EXPOSE 8443

# COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord
COPY config/supervisord.conf  /etc/supervisord.conf
COPY scripts/cloud-ide.sh  /usr/local/bin/cloud-ide

RUN  sudo wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 \ 
&&  sudo  chmod +x  /usr/local/bin/cloud-ide \
 && sudo  chmod +x /usr/local/bin/dumb-init \
&&  pip install supervisor  \
&& sudo ln -s $HOME/.pyenv/shims/supervisord /usr/local/bin/supervisord \
&& sudo ln -s $HOME/.pyenv/shims/supervisorctl /usr/local/bin/supervisorctl \
&& mkdir -p ${IDE_WORKSPACE}/.vscode  


# copy command to bin 
COPY scripts/install-vscode.sh /usr/bin/install-vscode
COPY scripts/install-ext.sh /usr/bin/install-ext
COPY --chown=aima:aima scripts/init.sh ${IDE_WORKSPACE}/.vscode
RUN sudo chmod +x  /usr/bin/install-vscode && sudo chmod +x  /usr/bin/install-ext

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["/usr/local/bin/supervisord","-n","-c","/etc/supervisord.conf"]
