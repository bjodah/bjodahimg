#!/bin/bash -xu
IMAGE=${1:-"bjodah/bjodahimgbase:latest"}

absolute_repo_path_x="$(readlink -fn -- "$(dirname $0)/.."; echo x)"
absolute_repo_path="${absolute_repo_path_x%x}"
cd "$absolute_repo_path"

mkdir -p _build/
cp -LRu --preserve=all deb-buildscripts/* _build/
docker run --name bjodah-bjodahimgbase-build -e TERM -e HOST_UID=$(id -u) -e HOST_GID=$(id -g) -v $absolute_repo_path/_build:/build -w /build $IMAGE /build/build-all-deb.sh | tee $(basename $0).log
BUILD_EXIT=$(docker wait bjodah-bjodahimgbase-build)
docker rm bjodah-bjodahimgbase-build
if [[ "$BUILD_EXIT" != "0" ]]; then
    echo "Build failed"
    exit 1
else
    echo "Build succeeded"
    PKGS=_build/deb-*-build/*.deb
    echo -n "">./resources/dpkg_packages.txt
    for PKG in $PKGS; do
        echo -n "$(basename $PKG) " >>./resources/dpkg_packages.txt
    done
    cp $PKGS packages/
fi
