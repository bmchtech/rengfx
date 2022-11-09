set -e
export TAG=builder_$(head /dev/urandom | tr -dc a-z0-9 | head -c10)
podman build -t $TAG -f build.docker && podman run --rm -it -v $(pwd):/prj $TAG 