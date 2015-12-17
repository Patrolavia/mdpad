# MDPAD

MDPAD is a markdown document holder for small scale.

## Requirements for official backend and frontend

- Running `Redis` server.
- Google oauth key (in json format).
- [config.json](https://github.com/Patrolavia/darius/blob/master/config.example.json)

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
