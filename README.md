# LachlanStone/apt-cacher-ng:2.0

- [LachlanStone/apt-cacher-ng:2.0](#lachlanstoneapt-cacher-ng20)
- [Introduction](#introduction)
  - [Contributing](#contributing)
  - [Building the Image](#building-the-image)
    - [Docker FIle Details](#docker-file-details)
  - [Build Scripts that are used](#build-scripts-that-are-used)
    - [Entrypoint.sh](#entrypointsh)
    - [Directory-build.sh](#directory-buildsh)
  - [Quickstart](#quickstart)
  - [Persistent Setup](#persistent-setup)
    - [Docker Compose](#docker-compose)
      - [ Docker compose ](#-docker-compose-)
      - [ acng.conf ](#-acngconf-)
  - [Usage](#usage)
    - [Step 1](#step-1)
    - [Step 2](#step-2)

# Introduction

Apt-Cacher-NG is a caching proxy, specialized for package files from Linux distributors, primarily for [Debian](http://www.debian.org/) (and [Debian based](https://en.wikipedia.org/wiki/List_of_Linux_distributions#Debian-based)) distributions but not limited to those.

This is a custom `DockerFile` used to create a [Docker](https://www.docker.com/) container image for [Apt-Cacher-NG](https://www.unix-ag.uni-kl.de/~bloch/acng/).

## Contributing

If you find this image useful here's how you can help:

- Send a pull request with your awesome features and bug fixes
- Help users resolve their [issues](../../issues?q=is%3Aopen+is%3Aissue).

## Building the Image

The `DockerFile` can be found under the [Image](../../tree/main/Docker-Image) section of this image.
~
You can run the script bellow to create a new version of the docker image with any modification that you have added.

    ./build-image.sh 

### Docker FIle Details

This Docker File has the [Proxmox HyperVisor](https://www.proxmox.com/en/proxmox-ve) and [Proxmox Backup Server](https://www.proxmox.com/en/proxmox-backup-server) Repository

| Distribution | URL Added | Location Files Added |
| ------------ | --------- | ---------------------|
| Proxmox HyperVisor | <http://download.proxmox.com/debian/pve> | backends_debian
| Proxmox Backup Server | <http://download.proxmox.com/debian/pbs> | backends_debian

If you want any other specific repository added please create a [issue](../../issues?q=is%3Aopen+is%3Aissue)

## Build Scripts that are used

### Entrypoint.sh

The `entrypoint.sh` is used to execute the APT-Cacher-NG Service

### Directory-build.sh

The `directory-build.sh` is used to setup the following directories

- `pid`
- `cache`
- `logs`

It also setups the directory for the correct permission for writing the required files for the container

## Quickstart

Start Apt-Cacher-NG using the `Docker-Compose.yml` file located under the [Docker-Compose-Example](../../tree/main/Docker-Compose-Example).

The Compose file can be modified and then ran via

Docker Compose

    Docker-Compose Up -d

Docker Compose Script

    ./Deploy-Container.sh

## Persistent Setup

### Docker Compose

To run Apt-Cacher-NG with Docker Compose, create the following `docker-compose.yml` file
  
#### <b> Docker compose </b>

```yaml
version: "3"

services:
  apt-cacher-ng:
    image: custom-apt-cacher-ng:latest
    container_name: apt-cacher-ng
    restart: unless-stopped
    environment:
      - VOL_Path=
      - ACNGCONF_PATH=
    volumes:
    # Mapping for the Cache Directory
      - "${VOL_PATH}/cache:/var/cache/apt-cacher-ng"
    # Mapping for the Logs Folder
      - "${VOL_PATH}/logs:/var/log/apt-cacher-ng"
    # Mapping the Local ACNG Conf File to the Container ACNG.conf file
      - "${ACNGCONF_PATH}/acng.conf:/etc/apt-cacher-ng/acng.conf:ro"
    ports:
      - 3142:3142/tcp

```

#### <b> acng.conf </b>

The `acng.conf` file is the main configuration file for apt-cacher-ng, this is were all of the settings are put into the apt-cacher-ng Service.
> Note: The `acng.conf` file that I use under my directory has been provided

The file location is set under the `docker-compose.yml` via the `ACNGCONF_PATH` environmental variable
> Your internal path can be determined via the `pwd` command in Linux

Link to documented version of the `acng.conf` under the [Documentation](../../tree/main/Apt-Cacher-NG_Documentation)

## Usage

To start using Apt-Cacher-NG on your Debian (and Debian based) host you either need to setup a HTTP Proxy forward or direct mapping under the APT `sourcelists` file.

This method will use the HTTP Proxy Forward method as we can automate the detection of the apt proxy via shell scripts.

### Step 1

Save and make executable the `apt-proxy-detect.sh` file located under the [Apt-Proxy-Setup](../../tree/main/Apt-Proxy-Setup)

This script performs a port check of the `Apt-Cacher-NG` proxy each time you perform a APT update or install or upgrade. You can change both the port and IP via the Variable to specific your apt-cacher-ng location.

```bash
# !/bin/bash
# Apt Cacher NG
IP=10.27.30.200
PORT=3142
if nc -w1 -z $IP $PORT; then
    echo -n "http://${IP}:${PORT}"
else
    echo -n "DIRECT"
```

### Step 2

Save the `01proxy` file located under the [Apt-Proxy-Setup](../../tree/main/Apt-Proxy-Setup)

This file will tell apt that we have to go though a HTTP Proxy for all apt requests. The File will then execute the script and if the Apt-Cacher-NG Container is up it will pull though cache and if down will pull straight from the web.

```properties
# This Points to the Script
Acquire::http::Proxy-Auto-Detect "/mnt/apt-script/apt-proxy-detect.sh";
```
