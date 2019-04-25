# Just use the code-server docker binary
FROM codercom/code-server as coder-binary

FROM ubuntu:18.10 as vscode-env
ARG DEBIAN_FRONTEND=noninteractive

# Install the actual VSCode to download configs and extensions
RUN apt-get update && \
	apt-get install -y curl && \
	curl -o vscode-amd64.deb -L https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable && \
	dpkg -i vscode-amd64.deb || true && \
	apt-get install -y -f && \
	# VSCode missing deps
	apt-get install -y libx11-xcb1 libasound2 && \
	rm -f vscode-amd64.deb && \
	# CLI json parser
	apt-get install -y jq

COPY scripts /root/scripts
COPY sync.gist /root/sync.gist

# This gets user config from gist, parse it and install exts with VSCode
RUN code -v --user-data-dir /root/.config/Code && \
	cd /root/scripts && \
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
COPY  --from=coder-binary /usr/local/bin/code-server /usr/local/bin/code-server
RUN mkdir -p $HOME/.code-server/User && sudo mkdir /workspace  && sudo chown aima:aima /workspace
COPY  --chown=aima:aima  --from=vscode-env /root/settings.json $HOME/.code-server/User/settings.json
COPY  --chown=aima:aima --from=vscode-env /root/.vscode/extensions $HOME/.code-server/extensions
COPY  --chown=aima:aima --from=vscode-env /root/locale.json $HOME/.code-server/User/locale.json
COPY  --chown=aima:aima --from=vscode-env /root/keybindings.json $HOME/.code-server/User/keybindings.json

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
