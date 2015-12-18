#!/bin/bash

if [[ $1 == "" ]]
then
    echo "Usage: $0 docker_image_tag [/path/to/custom/sources.list]"
    echo ""
    echo "example 1: $0 mdpad:latest"
    echo "example 2: $0 mdpad:latest /etc/apt/sources.list"
    exit 1
fi

REPO=$(
    cat <<EOF | base64 -w 0
deb http://httpredir.debian.org jessie main
deb http://security.debian.org jessie/updates main
EOF
    )

if [[ -f "$2" ]]
then
    REPO=$(cat "$2" | base64 -w 0)
fi

# generate random 40 bytes string for session secret
SECRET=$(</dev/urandom tr -dc '!@$~#%+/*_a-zA-Z0-9,.' | head -c40)

echo "Building image $1 ..."

cat <<EOF | docker build -t "$1" -
FROM debian:jessie
ENV GO_VER 1.5.2
ENV NODE_VER 0.12
RUN export GOROOT=/go \\
 && export GOPATH=/gopath \\
 && export NVM_DIR=/nvm \\ 
 && export OSCAR=/oscar \\
 && export PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH \\
 && export deps="wget git build-essential python" \\
 && echo "$REPO" | base64 -d | tee /etc/apt/sources.list \\
 && apt-get update \\
 && apt-get install -y \$deps \\
 && wget -O /go.tgz https://storage.googleapis.com/golang/go\$GO_VER.linux-amd64.tar.gz \\
 && tar zxvf /go.tgz -C / \\
 && go get -v github.com/Patrolavia/darius \\
 && mv \$GOPATH/bin/darius / \\
 && wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash \\
 && . \$NVM_DIR/nvm.sh \\
 && nvm install \$NODE_VER \\
 && nvm use \$NODE_VER \\
 && git clone https://github.com/Patrolavia/oscar.git \$OSCAR \\
 && (cd \$OSCAR && npm install && ./node_modules/.bin/fly build) \\
 && mv \$OSCAR/build /frontend \\
 && apt-get purge -y \$deps \\
 && apt-get autoremove --purge -y \\
 && apt-get clean -y \\
 && rm -fr \$GOROOT \$GOPATH \$OSCAR /go.tgz \$NVM_DIR ~/.node-gyp ~/.babel.json ~/.npm ~/.bashrc \\
 && mkdir /data
WORKDIR /data
ENTRYPOINT ["/darius","/data/config.json"]
EOF

ERR=$?

if [[ $ERR != 0 ]]
then
    exit $ERR
fi

cat <<EOF
Your docker image is built and tagged as $1.

Path to config file: /data/config.json
Path to frontend: /frontend

Please ensure the "FrontEnd" entry in your config file is correct, and create container with correct volume/port.
EOF
