#!/usr/bin/env bash

set -e # exit on error
if [ -n "$DEBUG" ]; then
    # echo all commands in debug mode
    set -x
fi

print_logo() {
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
}
# print_logo
print_info() {
    echo "REDBUILD v2.1.0"
    echo " container engine: $CONTAINER_ENGINE"
    printf " host: $(uname -s)/$(uname -m) $(uname -r)\n"
    printf "\n"
}

# get args passed to script
ARGS="$@"
CWD=$(pwd)
# custom args to container engine
CBUILD_ARGS=$CBUILD_ARGS
CRUN_ARGS=$CRUN_ARGS

testcmd () {
    command -v "$1" >/dev/null
}

# detect container engine, prefer podman but fall back to docker
CONTAINER_ENGINE="unknown-container-engine"
detect_container_engine() {
    if testcmd podman; then
        CONTAINER_ENGINE="podman"
    elif testcmd docker; then
        CONTAINER_ENGINE="docker"
        # i don't like docker
        printf "WARNING: docker is not recommended, use podman instead\n"
    else
        echo "ERROR: no suitable container engine found. please install podman or docker."
        exit 1
    fi
}

detect_container_engine
print_info

export BUILDER_TAG=builder_$(head /dev/urandom | tr -dc a-z0-9 | head -c10) # random tag to avoid name collisions

# build the builder image
build_builder_image() {
    printf "building builder image [tag: $BUILDER_TAG]"
    if [ -n "$CBUILD_ARGS" ]; then
        printf " [$CONTAINER_ENGINE args: $CBUILD_ARGS]"
    fi
    printf "...\n"

    $CONTAINER_ENGINE build -t $BUILDER_TAG $CBUILD_ARGS -f build.docker | sed 's/^/  /'
}
# run the build inside the builder image
run_build() {
    printf "running build in builder image [tag: $BUILDER_TAG]"
    if [ -n "$CRUN_ARGS" ]; then
        printf " [$CONTAINER_ENGINE args: $CRUN_ARGS]"
    fi
    if [ -n "$ARGS" ]; then
        printf " [script args: $ARGS]"
    fi
    printf "...\n"
    $CONTAINER_ENGINE run --rm -it -v $(pwd):/prj $CRUN_ARGS $BUILDER_TAG /bin/bash -l -c "cd /prj && ./build.sh $ARGS" | sed 's/^/  /'
}

build_builder_image
run_build