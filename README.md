# starmade-server
Run a starmade server in a Docker container

[![Docker Automated build](https://img.shields.io/docker/automated/nsnow/starmade-server.svg)](https://hub.docker.com/r/nsnow/starmade-server)
[![Docker Stars](https://img.shields.io/docker/stars/nsnow/starmade-server.svg)](https://hub.docker.com/r/nsnow/starmade-server)
[![Docker Pulls](https://img.shields.io/docker/pulls/nsnow/starmade-server.svg)](https://hub.docker.com/r/nsnow/starmade-server)
[![Docker Build Status](https://img.shields.io/docker/build/nsnow/starmade-server.svg)](https://hub.docker.com/r/nsnow/starmade-server/builds)


This Dockerfile will download the StarMade Server app and set it up, along with its dependencies.

If you run the container as is, the `worlds` directory will be created inside the container, which is unadvisable. It is highly recommended that you store your worlds outside the container using a mount (see the example below). Ensure that your file system permissions are correct, `chown 1000:1000 mount/path`, or modify the UID/GUID variables as needed.

It is also likely that you will want to customize your `server.cfg` file. To do this, use the `-e <environment var>=<value>` for each setting in the `server.cfg`. The `server.cfg` file will be overwritten every time the container is launched.


## Example

Use this `docker run` command to launch a container with a few customized `server.cfg`.

 $ `docker run -d -it --name=sm1 -v /opt/starmade/world1:/home/starmade/server -p 4242:4242/tcp -e WORLD=world1 -e HOST_NAME_TO_ANNOUNCE_TO_SERVER_LIST=sm.example.com -e SERVER_LIST_NAME=starmade -e SERVER_LIST_DESCRIPTION="Starmade server" nsnow/starmade-server:latest`


## Additional Docker commands

**kil and remove all docker containers**

`docker kill $(docker ps -qa); docker rm $(docker ps -qa)`

**docker logs**

`docker logs sm1`

**attach to the minecraft server console**

`docker attach sm1`

**exec into the container's bash console**

`docker exec sm1 bash`


**NOTE**: referencing containers by name is only possible if you specify the `--name` flag in your docker run command.


## Set selinux context for mounted volumes

`chcon -Rt svirt_sandbox_file_t /path/to/volume`


## Server properties and environment variables
https://github.com/japtain-cack/starmade-server/blob/master/remco/templates/server.cfg
 
