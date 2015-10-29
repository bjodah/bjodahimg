#!/bin/bash -x
TAG=${1:-latest}
REGISTRY_USER=bjodah
DOCKERFILE_NAME=bjodahimgbase

absolute_repo_path_x="$(readlink -fn -- "$(dirname $0)/.."; echo x)"
absolute_repo_path="${absolute_repo_path_x%x}"
cd "$absolute_repo_path"

mkdir -p build/
cp deb-buildscripts/*.sh build/
docker run --name bjodah-bjodahimgbase-build -e TERM -e HOST_UID=$(id -u) -e HOST_GID=$(id -g) -v $absolute_repo_path/build:/build -w /build $REGISTRY_USER/$DOCKERFILE_NAME:$TAG /build/build-all-deb.sh | tee 90_build_packages.sh.log
BUILD_EXIT=$(docker wait bjodah-bjodahimgbase-build)
docker rm bjodah-bjodahimgbase-build
if [[ "$BUILD_EXIT" != "0" ]]; then
    echo "Build failed"
    exit 1
else
    echo "Build succeeded"
fi
