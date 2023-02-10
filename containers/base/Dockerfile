# [Choice] Node.js version (use -bullseye variants on local arm64/Apple Silicon): 18, 16, 14, 18-bullseye, 16-bullseye, 14-bullseye, 18-buster, 16-buster, 14-buster
ARG VARIANT=16-bullseye
FROM mcr.microsoft.com/vscode/devcontainers/typescript-node:${VARIANT}

#
# support vscode
RUN mkdir -p /home/vscode/.vscode-server/extensions \
    /home/vscode/.vscode-server-insiders/extensions \
    && chown -R vscode \
    /home/vscode/.vscode-server \
    /home/vscode/.vscode-server-insiders

COPY install-powershell.sh /home/vscode/install-powershell.sh
RUN /home/vscode/install-powershell.sh

COPY install-hashicorp.ps1 /home/vscode/install-hashicorp.ps1
RUN /home/vscode/install-hashicorp.ps1 waypoint
RUN /home/vscode/install-hashicorp.ps1 vault

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment if you want to install an additional version of node using nvm
# ARG EXTRA_NODE_VERSION=10
# RUN su node -c "source /usr/local/share/nvm/nvm.sh && nvm install ${EXTRA_NODE_VERSION}"

# [Optional] Uncomment if you want to install more global node packages
# RUN su node -c "npm install -g <your-package-list -here>"