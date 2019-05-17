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
COPY sync.gist /root/sync.gist

# This gets user config from gist, parse it and install exts with VSCode
#RUN $HOME/ -v --user-data-dir /root/.config/Code && \
RUN  cd /root/scripts && \
	sh get-config-from-gist.sh && \
	sh parse-extension-list.sh && \
	sh install-vscode-extensions.sh ../extensions.list

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

ENV LANG=en_US.UTF-8



USER aima
ENV DATA_HOME=$HOME/.local/share/code-server
COPY  --from=coder-binary /usr/local/bin/code-server /usr/local/bin/code-server
RUN mkdir -p $DATA_HOME/User && sudo mkdir /workspace  && sudo chown aima:aima /workspace
COPY  --chown=aima:aima  --from=vscode-env /root/settings.json $DATA_HOME/User/settings.json
COPY  --chown=aima:aima --from=vscode-env /root/.local/share/code-server/extensions $DATA_HOME/extensions
COPY  --chown=aima:aima --from=vscode-env /root/locale.json $DATA_HOME/User/locale.json
COPY  --chown=aima:aima --from=vscode-env /root/keybindings.json $DATA_HOME/User/keybindings.json
COPY --chown=aima:aima --from=vscode-env /root/VSCode-linux-x64/resources/app/out/nls.metadata.json  $DATA_HOME/nls.metadata.json

WORKDIR /workspace

#RUN yarn config set registry https://registry.npm.taobao.org  && \
#yarn config set disturl https://npm.taobao.org/dist && \
#npm config set registry https://registry.npm.taobao.org &&\
#npm config set disturl https://npm.taobao.org/dist

#ENV JAVA_HOME=$HOME/.sdkman/candidates/java/current
#ENV M2_HOME=$HOME/.sdkman/candidates/maven/current
COPY --chown=aima:aima  config/settings.xml $M2_HOME/conf

EXPOSE 8443
CMD code-server $PWD
