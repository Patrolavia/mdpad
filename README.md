# MDPAD

MDPAD is a markdown document holder for small scale.

## Requirements for official backend and frontend

- Running `Redis` server.
- Google oauth key (in json format).
- [config.json](https://github.com/Patrolavia/darius/blob/master/config.example.json)

## Synopsis

We have a running instance installed using docker and hosted at linode. Here are steps we create it.

### Build docker image

```sh
wget -q -O /tmp/docker.sh https://raw.githubusercontent.com/Patrolavia/mdpad/master/docker.sh
bash /tmp/docker.sh mdpad /etc/apt/sources.list
```

This will create a docker image tagged as `mdpad:latest`.

### Prepare configuration files

Create `config.json` and put it into `~/mdpad/` along with Google oauth key (here we named it `google.json`)

```json
{
    "SiteRoot": "https://pad.patrolavia.com/",
    "FrontEnd": "/frontend",
    "Listen": ":8000",
    "DBType": "sqlite3",
    "DBConStr": "data.db",
    "RedisAddr": "redis:6379",
    "SessSecret": "MY-SECReT+NOt/GoIng=t0#L3t@y()U_KnoW",
    "SessName": "mdpad",
    "GoogleKeyFile": "google.json",
    "ValidEditors": "ronmi.ren@gmail.com,jscaem@gmail.com"
}
```

### Create docker containers

MDPAD will use redis to store session data. We prefer running redis in docker.

```sh
docker create --name redis redis
docker create --name mdpad -v ~/mdpad:/data -p 8000:8000 --link redis:redis mdpad
```

We have NGINX running in front of it to provide SSL/SPDY support, so we use port 8000 not 443.

### Start it

```sh
docker start redis mdpad
```

Start redis first or docker will panic about `--link` parameter of `mdpad`.

## Installation

### Docker

The best and most easy way to run MDPAD is using Docker. We provide a handy tool `docker.sh` helping you create docker image.

```sh
docker.sh image_tag_name [/optionally/path/to/sources.list]

# example
docker.sh mdpad
# another example
docker.sh mdpad /etc/apt/sources.list

# use the image, assume you set `Listen` to ":8000" in config.json
docker run -d -v /path/to/config.json:/data/config.json -p 8000:8000 mdpad
```

### From source

See [Frontend](https://github.com/Patrolavia/oscar) and [Backend](https://github.com/Patrolavia/darius).

## License

Any version of GPL, LGPL or MIT.
