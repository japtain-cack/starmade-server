# starmade-server
Run a starmade server in a Docker container.
Auto updates and remco config management.

[![Docker Automated build](https://img.shields.io/docker/automated/nsnow/starmade-server.svg)](https://hub.docker.com/r/nsnow/starmade-server)
[![Docker Stars](https://img.shields.io/docker/stars/nsnow/starmade-server.svg)](https://hub.docker.com/r/nsnow/starmade-server)
[![Docker Pulls](https://img.shields.io/docker/pulls/nsnow/starmade-server.svg)](https://hub.docker.com/r/nsnow/starmade-server)
[![Docker Build Status](https://img.shields.io/docker/build/nsnow/starmade-server.svg)](https://hub.docker.com/r/nsnow/starmade-server/builds)


This Dockerfile will download the StarMade Server app and set it up, along with its dependencies.
If you run the container as is, the `worlds` directory will be created inside the container, which is inadvisable.
It is highly recommended that you store your worlds outside the container using a mount (see the example below).
Ensure that your file system permissions are correct, `chown 1000:1000 /mount/path`, or modify the UID/GUID variables as needed.

It is also likely that you will want to customize your `server.cfg` file.
To do this, use the `-e <environment var>=<value>` for each setting in the `server.cfg`.
The `server.cfg` file will be overwritten every time the container is launched to prevent drift.


## Run the server
Use this `docker run` command to launch a container with a few customized `server.cfg`.

```
docker run -d -it --name=starmade1 \
  -v /opt/starmade/world1:/home/starmade/server \
  -p 4242:4242/tcp \
  -e STARMADE_WORLD=world1 \
  -e STARMADE_HOST-NAME-TO-ANNOUNCE-TO-SERVER-LIST=sm.example.com \
  -e STARMADE_SERVER-LIST-NAME=starmade \
  -e STARMADE_SERVER-LIST-DESCRIPTION="Starmade server" \
	-e STARMADE_PROTECT-STARTING-SECTOR="true" \
	-e STARMADE_SUPER-ADMIN-PASSWORD-USE="true" \
	-e STARMADE_SUPER-ADMIN-PASSWORD="secret" \
	-e STARMADE_MINING-BONUS=5 \
  nsnow/starmade-server:latest`
```

## Additional Docker commands

**kill and remove all docker containers**

`docker kill $(docker ps -qa); docker rm $(docker ps -qa)`

**docker logs**

`docker logs starmade1`

**attach to the starmade server console**

This will allow you to interact with the console
use `ctrl+p` then `ctrl+q` to quit.

`docker attach starmade1`

**exec into the container's bash console**

`docker exec starmade1 bash`

**NOTE**: referencing containers by name is only possible if you specify the `--name` flag in your docker run command.

## Set selinux context for mounted volumes

`chcon -Rt svirt_sandbox_file_t /path/to/volume`

## Server properties and environment variables
**Set user and/or group id (optional)**
* `STARMADE_UID=1000`
* `STARMADE_GUID=1000`

## Server properties and environment variables
Use [this file](https://github.com/japtain-cack/starmade-server/blob/master/remco/templates/server.cfg) for the full environment variable reference.
 
This project uses [Remco config management](https://github.com/HeavyHorst/remco).
This allows for templatization of config files and options can be set using environment variables.
This allows for easier deployments using most docker orchistration/management platforms including Kubernetes.

The remco tempate uses keys. This means you should see a string like `"/starmade/some-option"` within the `getv()` function.
This directly maps to a environment variable, the `/` becomes an underscore basically. The other value in the `getv()` function is the default value.
For instance, `"/starmade/some-option"` will map to the environment variable `STARMADE_SOME-OPTION`.

`getv("/starmade/some-option", "default-value")`

becomes

`docker run -e STARMADE_SOME-OPTION=my-value ...`

