# Flatline Prototype Development

This document provides instructions to locally test, build and deploy individual Flatline components.

## Requirements

To develop Flatline locally, ensure submodules are initialized and fetched:

```bash
git clone --recurse-submodules git@github.com:mollyim/flatline-platform.git
# Alternatively, for an existing repository:
# git submodule update --init --recursive
```

Testing and building this project relies on [Docker](https://docs.docker.com/engine/install/).

The Java compoments are intended to be built with the [Temurin 24 JDK](https://adoptium.net/installation/).

For the Maven builds to succeed, ensure that `JAVA_HOME` points to a valid Temurin 24 JDK installation.

## Testing

### Whisper Service

Requires a [FoundationDB client](https://apple.github.io/foundationdb/getting-started-linux.html).

```bash
cd flatline-whisper-service
./mvnw clean verify -e
```

Integration tests are excluded as they require an existing environment in which to run.

Tests for features that are disabled for the prototype are be excluded.

### Storage Service

```bash
cd flatline-storage-service
./mvnw clean test
```

### Contact Discovery Service

To test C dependencies:

```bash
cd flatline-contact-discovery-service
make -C c docker_tests
make -C c docker_valgrinds
```

To run minimal tests without Intel SGX:

```bash
cd flatline-contact-discovery-service
./mvnw verify -Dtest=\
\!org.signal.cdsi.enclave.**,\
\!org.signal.cdsi.IntegrationTest,\
\!org.signal.cdsi.JsonMapperInjectionIntegrationTest,\
\!org.signal.cdsi.limits.redis.RedisLeakyBucketRateLimiterIntegrationTest,\
\!org.signal.cdsi.util.ByteSizeValidatorTest
```

To run all tests with Intel SGX:

```bash
cd flatline-contact-discovery-service
# Set up Intel SGX on Ubuntu 22.04.
sudo ./c/docker/sgx_runtime_libraries.sh
./mvnw verify
```

### Calling Service

This component is built in Rust and requires its toolchain.

```bash
cd flatline-calling-service
cargo test
```

## Building

For Java components, this stage will build and locally store container images with
[Jib](https://github.com/GoogleContainerTools/jib), in addition to the JAR artifacts.

For other components, the provided Dockerfiles will be used instead.

### Whisper Service

```bash
cd flatline-whisper-service
./mvnw clean deploy \
  -Pexclude-spam-filter -Denv=dev -DskipTests \
  -Djib.to.image="flatline-whisper-service:dev"
```

### Storage Service

```bash
cd flatline-storage-service
./mvnw clean package \
  -Pdocker-deploy -Denv=dev -DskipTests \
  -Djib.to.image="flatline-storage-service:dev"
```

The `env` property is used as a prefix to fetch the relevant configuration files from `storage-service/config`.

### Contact Discovery Service

```bash
cd flatline-contact-discovery-service
./mvnw package \
  -Dpackaging=docker -DskipTests \
  -Djib.to.image="flatline-contact-discovery-service:dev"
```

### Calling Service

```bash
cd flatline-calling-service
TARGET_CPU=skylake # The target CPU family used to run the component.
docker build . -f frontend/Dockerfile \
  --build-arg rust_flags=-Ctarget-cpu=$TARGET_CPU \
  -t flatline-calling-service-frontend:dev
docker build . -f backend/Dockerfile \
  --build-arg rust_flags=-Ctarget-cpu=$TARGET_CPU \
  -t flatline-calling-service-backend:dev
```

The component should run on the target CPU family and others that support its features.

## Deploying to Kubernetes

Kubernetes expects container images to be served from a container registry.

You can deploy a simple container registry with the [Distribution Registry](https://distribution.github.io/distribution/) container image.

For example, to deploy an **insecure** registry for local testing:

```bash
docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v /tmp/registry:/var/lib/registry \
  registry:3
```

When building with Maven, push the resulting container images to a registry. For example:

```bash
# Whisper Service
( 
  cd flatline-whisper-service && \
  ./mvnw -e \
    deploy \
    -Pexclude-spam-filter \
    -Denv=dev \
    -DskipTests \
    -Djib.goal=build \
    -Djib.to.image=localhost:5000/flatline-whisper-service:dev \
    -Djib.allowInsecureRegistries=true
)

# Storage Service
( 
  cd flatline-storage-service && \
  ./mvnw -e \
    clean package \
    -Pdocker-deploy \
    -Denv=dev \
    -DskipTests \
    -Djib.goal=build \
    -Djib.to.image=localhost:5000/flatline-storage-service:dev \
    -Djib.allowInsecureRegistries=true
)

# Contact Discovery Service
(
  cd flatline-contact-discovery-service && \
  ./mvnw -e \
  deploy \
  -Dpackaging=docker \
  -DskipTests \
  -Djib.to.image=localhost:5000/flatline-contact-discovery-service:dev \
  -Djib.allowInsecureRegistries=true
)

# Calling Service
(
  cd flatline-calling-service
  docker build . -f frontend/Dockerfile \
    --build-arg rust_flags=-Ctarget-cpu=skylake \
    -t localhost:5000/flatline-calling-service-frontend:dev
  docker push localhost:5000/flatline-calling-service-frontend:dev
  docker build . -f backend/Dockerfile \
    --build-arg rust_flags=-Ctarget-cpu=skylake \
    -t localhost:5000/flatline-calling-service-backend:dev
  docker push localhost:5000/flatline-calling-service-backend:dev
)
```

Once the images are on the registry, override the Helm image values to reference these images.

For example, to do this for every core Flatline component, create `local.yaml` with the following:

```yaml
whisperService:
  image:
    repository: localhost:5000/flatline-whisper-service
    tag: dev
storageService:
  image:
    repository: localhost:5000/flatline-storage-service
    tag: dev
contactDiscoveryService:
  image:
    repository: localhost:5000/flatline-contact-discovery-service
    tag: dev
callingServiceFrontend:
  image:
    repository: localhost:5000/flatline-calling-service-frontend
    tag: dev
callingServiceBackend:
  image:
    repository: localhost:5000/flatline-calling-service-backend
    tag: dev
```

Finally, upgrade the Helm release to use these custom image values:

```bash
helm upgrade -f local.yaml $HELM_RELEASE ./charts/flatline
```
