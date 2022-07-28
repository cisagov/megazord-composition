# megazord-composition :dragon_face:🐳 #

[![GitHub Build Status](https://github.com/xvxd4sh/megazord-composition/workflows/build/badge.svg)](https://github.com/xvxd4sh/megazord-composition/actions/workflows/build.yml)
[![CodeQL](https://github.com/xvxd4sh/megazord-composition/workflows/CodeQL/badge.svg)](https://github.com/xvxd4sh/megazord-composition/actions/workflows/codeql-analysis.yml)
[![Known Vulnerabilities](https://snyk.io/test/github/xvxd4sh/megazord-composition/badge.svg)](https://snyk.io/test/github/xvxd4sh/megazord-composition)

This is a docker composition of the megazord containers.

## Running ##

### Running with Docker-Compose ###

1. Create a `docker-compose.yml` file similar to the one below to use [Docker Compose](https://docs.docker.com/compose/).

    ```yaml
    ---
    version: "3.7"

    services:
      coredns:
      image: xvxd4sh/coredns:latest
      container_name: coredns
      hostname: coredns_megazord
      init: true
      restart: on-failure:5
      ports:
        - target: 53
          published: 53
          protocol: udp
          mode: host
      volumes:
        - ./src/coredns/config:/root
      networks:
        appNetwork:
          ipv4_address: 172.19.0.3

    apache:
      image: xvxd4sh/apache2:latest
      container_name: apache
      init: true
      restart: on-failure:5
      ports:
        - target: 80
          published: 80
          protocol: tcp
          mode: host
        - target: 443
          published: 443
          protocol: tcp
          mode: host
      volumes:
       - ./src/apache2/payload/:/var/www/uploads/
       - ./src/apache2/.htaccess:/var/www/html/.htaccess
       - ./src/apache2/apache2.conf:/etc/apache2/apache2.conf
      networks:
        appNetwork:
          ipv4_address: 172.19.0.4

    cobalt:
      image: debian:11
      container_name: cobalt
      init: true
      restart: on-failure:5
      command: >
        bash -c " apt-get update > /dev/null 2>&1 &&
                  apt-get install -y libfreetype6 > /dev/null 2>&1 &&
                  apt-get install -y default-jdk > /dev/null 2>1 &&
                  cd /opt/cobaltstrike/ &&
                  ./teamserver ${C2_IP} ${PASSWORD} ${C2_PROFILE} ${KILLDATE}"
      ports:
        - target: 50050
          published: 50050
          protocol: tcp
          mode: host
      expose:
        - "53"
        - "443"
        - "80"
      volumes:
        - /opt/cobaltstrike/:/opt/cobaltstrike/
        - ./${C2_PROFILE}:/opt/cobaltstrike/${C2_PROFILE}
      networks:
        appNetwork:
          ipv4_address: 172.19.0.5

  networks:
    appNetwork:
      driver: bridge
      ipam:
        driver: default
        config:
          - subnet: 172.19.0.0/16
    ```

1. Start the container and detach:

    ```console
    docker compose up --detach
    ```

## Updating your container ##

### Docker Compose ###

1. Pull the new image from Docker Hub:

    ```console
    docker compose pull
    ```

1. Recreate the running container by following the [previous instructions](#running-with-docker-compose):

    ```console
    docker compose up --detach
    ```
<!--
### Docker ###

1. Stop the running container:

    ```console
    docker stop <container_id>
    ```

1. Pull the new image:

    ```console
    docker pull cisagov/example:0.0.1
    ```

1. Recreate and run the container by following the [previous instructions](#running-with-docker).
-->
<!--
## Image tags ##

The images of this container are tagged with [semantic
versions](https://semver.org) of the underlying example project that they
containerize.  It is recommended that most users use a version tag (e.g.
`:0.0.1`).

| Image:tag | Description |
|-----------|-------------|
|`cisagov/example:1.2.3`| An exact release version. |
|`cisagov/example:1.2`| The most recent release matching the major and minor version numbers. |
|`cisagov/example:1`| The most recent release matching the major version number. |
|`cisagov/example:edge` | The most recent image built from a merge into the `develop` branch of this repository. |
|`cisagov/example:nightly` | A nightly build of the `develop` branch of this repository. |
|`cisagov/example:latest`| The most recent release image pushed to a container registry.  Pulling an image using the `:latest` tag [should be avoided.](https://vsupalov.com/docker-latest-tag/) |

See the [tags tab](https://hub.docker.com/r/cisagov/example/tags) on Docker
Hub for a list of all the supported tags.

## Volumes ##

| Mount point | Purpose        |
|-------------|----------------|
| `/var/log`  |  Log storage   |

## Ports ##

The following ports are exposed by this container:

| Port | Purpose        |
|------|----------------|
| 8080 | Example only; nothing is actually listening on the port |

The sample [Docker composition](docker-compose.yml) publishes the
exposed port at 8080.
-->
## Environment variables ##

### Required ###

All the necessary environment variables are defined in the, untracked, .env file

The environment variables are as follows:

- C2_IP -> the ip address of the C2 container, 172.19.0.5 by default

- PASSWORD -> the password to access the teamserver, "password" by default

- C2_PROFILE -> profile used with the teamserver, amazon.profile by default

- KILLDATE -> the killdate for the teamserver, 2022-12-30 by default

<!--
| Name  | Purpose | Default |
|-------|---------|---------|
| `REQUIRED_VARIABLE` | Describe its purpose. | `null` |
-->
 <!--
### Optional ###

| Name  | Purpose | Default |
|-------|---------|---------|
| `ECHO_MESSAGE` | Sets the message echoed by this container.  | `Hello World from Dockerfile` |
-->
## Secrets ##

| Filename     | Purpose |
|--------------|---------|
| `quote.txt` | Replaces the secret stored in the example library's package data. |
<!--
## Building from source ##

Build the image locally using this git repository as the [build context](https://docs.docker.com/engine/reference/commandline/build/#git-repositories):

```console
docker build \
  --build-arg VERSION=0.0.1 \
  --tag cisagov/example:0.0.1 \
  https://github.com/cisagov/example.git#develop
```
-->
<!--
## Cross-platform builds ##

To create images that are compatible with other platforms, you can use the
[`buildx`](https://docs.docker.com/buildx/working-with-buildx/) feature of
Docker:

1. Copy the project to your machine using the `Code` button above
   or the command line:

    ```console
    git clone https://github.com/cisagov/example.git
    cd example
    ```

1. Create the `Dockerfile-x` file with `buildx` platform support:

    ```console
    ./buildx-dockerfile.sh
    ```

1. Build the image using `buildx`:

    ```console
    docker buildx build \
      --file Dockerfile-x \
      --platform linux/amd64 \
      --build-arg VERSION=0.0.1 \
      --output type=docker \
      --tag cisagov/example:0.0.1 .
    ```

## New repositories from a skeleton ##

Please see our [Project Setup guide](https://github.com/cisagov/development-guide/tree/develop/project_setup)
for step-by-step instructions on how to start a new repository from
a skeleton. This will save you time and effort when configuring a
new repository!
-->
## Contributing ##

We welcome contributions!  Please see [`CONTRIBUTING.md`](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
