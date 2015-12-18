#!/bin/bash

if [[ $1 == "" && $DRY_RUN == "" ]]
then
    cat <<EOF
Usage: $0 docker_image_tag [/path/to/custom/sources.list]

  example 1: $0 mdpad:latest
  example 2: $0 mdpad:latest /etc/apt/sources.list

$(basename "$0") accepts two special environment variables:
  DRY_RUN:  Do not create image, output dockerfile instead.
  RUN_TEST: Run tests when building image.

  example: DRY_RUN=1 RUN_TEST=1 $0
EOF
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

cat <<EOF | (if [[ $DRY_RUN != "" ]]; then cat ; else docker build -t "$1" -; fi)
FROM debian:jessie
ENV GO_VER 1.5.2
ENV NODE_VER 0.12
RUN export GOROOT=/go \\
 && export GOPATH=/gopath \\
 && export NVM_DIR=/nvm \\ 
 && export OSCAR=/oscar \\
 && export RUN_TEST=$RUN_TEST \\
 && export PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH \\
 && export deps="wget git build-essential python redis-server libfreetype6 libfontconfig" \\
 && echo "$REPO" | base64 -d | tee /etc/apt/sources.list \\
 && apt-get update \\
 && apt-get install -y \$deps \\
 && wget -O /go.tgz https://storage.googleapis.com/golang/go\$GO_VER.linux-amd64.tar.gz \\
 && tar zxvf /go.tgz -C / \\
 && go get -v github.com/Patrolavia/darius \\
 && ([ "\$RUN_TEST" = "" ] || (service redis-server restart && cd \$GOPATH/src/github.com/Patrolavia/darius && go test -v ./... && service redis-server stop)) \\
 && mv \$GOPATH/bin/darius / \\
 && wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash \\
 && . \$NVM_DIR/nvm.sh \\
 && nvm install \$NODE_VER \\
 && nvm use \$NODE_VER \\
 && git clone https://github.com/Patrolavia/oscar.git \$OSCAR \\
 && (cd \$OSCAR && npm install && ./node_modules/.bin/fly build && ([ "\$RUN_TEST" = "" ] || ./node_modules/.bin/fly test)) \\
 && mv \$OSCAR/build /frontend \\
 && apt-get install -y ca-certificates \\
 && apt-get purge -y \$deps \\
 && apt-get autoremove --purge -y \\
 && apt-get clean -y \\
 && rm -fr \$GOROOT \$GOPATH \$OSCAR /go.tgz \$NVM_DIR ~/.node-gyp ~/.babel.json ~/.npm ~/.bashrc \\
           /var/lib/apt/lists/* /var/lib/dpkg/info/* /tmp/npm* ~/.qws ~/.config /var/cache/fontconfig \\
 && mkdir /data
WORKDIR /data
ENTRYPOINT ["/darius","/data/config.json"]
EOF

ERR=$?

if [[ $ERR != 0 ]]
then
    exit $ERR
fi

if [[ $DRY_RUN == "" ]]
then
    cat <<EOF
Your docker image is built and tagged as $1.

Path to config file: /data/config.json
Path to frontend: /frontend

Please ensure the "FrontEnd" entry in your config file is correct, and create container with correct volume/port.
EOF
fi
