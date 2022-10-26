# kafka-lite

Single-node kafka cluster for local development and testing in an Alpine-based
Docker image, forked from [mvillarrealb/kafka-lite].

**⚠️ Not for production use! ⚠️**

## Docker images

Images are available at [mccutchen/kafka-lite] on Docker Hub, tagged with
specific Kafka versions.

## Usage

```sh
docker run --rm -P mccutchen/kafka-lite
```

Or, using docker-compose:

```yaml
version: '3.1'
services:
  kafka:
    image: mccutchen/kafka-lite
    ports:
      - 9092:9092 # Kafka port
      - 2181:2181 # Zookeeper port
    volumes:
      - kafka-data:/var/lib/kafka/data
```

## Building and releasing

See [VERSIONS](./VERSIONS) for build parameters.  Before releasing a new
version, bump the `RELEASE_REVISION` number.

```sh
# Build an image locally
make

# Build and push a "release" image, which will produce a multi-arch image
make release
```

## Credits

As noted above, this repo is based on [mvillarrealb/kafka-lite]. Differences
from the upstream image:
- No kafka-connect
- Builds on arm64 (e.g. M1 Macs)
- Uses non-deprecated JVM


[mccutchen/kafka-lite]: https://hub.docker.com/r/mccutchen/kafka-lite
[mvillarrealb/kafka-lite]: https://github.com/mvillarrealb/kafka-lite
