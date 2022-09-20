# megazord-composition :dragon_face:🐳 #

[![GitHub Build Status](https://github.com/cisagov/megazord-composition/workflows/build/badge.svg)](https://github.com/cisagov/megazord-composition/actions/workflows/build.yml)
[![CodeQL](https://github.com/cisagov/megazord-composition/workflows/CodeQL/badge.svg)](https://github.com/cisagov/megazord-composition/actions/workflows/codeql-analysis.yml)
[![Known Vulnerabilities](https://snyk.io/test/github/cisagov/megazord-composition/badge.svg)](https://snyk.io/test/github/cisagov/megazord-composition)

This is a docker composition of the megazord containers.

## Running ##

### Running with Docker-Compose ###

1. Start the container in detached mode from the top-level directory of this repository:

    ```console
    docker compose up --detach
    ```

1. Stop the running containers from the top-level directory of this repository:

    ```console
    docker compose down
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

- PASSWORD -> the password to access the teamserver, "password123" by default

- C2_PROFILE -> profile used with the teamserver, domain.profile by default

- KILLDATE -> the killdate for the teamserver, 2022-12-30 by default

- KEYSTORE -> the name of the keystore holding the SSL certificate and key,
domain.com.store by default

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
| `cobalt.cert` | Replace this file in the `src/secrets/` directory with the appropriate certificate |
| `cobalt.key`  | Replace this file in the `src/secrets/` directory with the appropriate key |

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
