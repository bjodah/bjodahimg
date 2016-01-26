#!/bin/bash
# DEB package builder for GLFW
# Copyright (c) 2015 Björn Dahlgren
# Public domain, use it as you see fit.
export VERSION=3.1.2
FNAME="glfw-${VERSION}.zip"

# We assume this script is idempotent and side effects are
# left intact since last invocation:
# BEGIN CAHCE LOGIC
ABS_SCRIPT_DIR=$(unset CDPATH && cd "$(dirname "$0")" && echo $PWD)
SCRIPT_BASE=$(basename $0)
CACHE_BASE=$SCRIPT_BASE.cache
SOURCES="$SCRIPT_BASE $FNAME"
savehash() {
    cd $ABS_SCRIPT_DIR && md5sum $SOURCES > $CACHE_BASE
}
validhash() {
    cd $ABS_SCRIPT_DIR && md5sum -c $CACHE_BASE >/dev/null 2>&1 && return 0
    return 1
}
if validhash; then
    echo "Valid hash (in $ABS_SCRIPT_DIR/$SCRIPT_BASE, exiting early)"
    exit 0
fi
# END CACHE LOGIC

export NAME=libglfw
export DEBVERSION=${VERSION}-1
TIMEOUT=60  # 60 seconds
DEB_ORIG_FNAME="libglfw_${VERSION}.orig.tar.gz"
MD5="8023327bfe979b3fe735e449e2f54842"
URLS=(\
"http://hera.physchem.kth.se/~repo/${MD5}/${FNAME}" \
"https://github.com/glfw/glfw/releases/download/$VERSION/$FNAME" \
)
for URL in "${URLS[@]}"; do
    if echo $MD5 $FNAME | md5sum -c --; then
        echo "Found ${FNAME} with matching checksum, using this file."
    else
        echo "Downloading ${URL}..."
        timeout $TIMEOUT wget --quiet --tries=2 --timeout=$TIMEOUT $URL -O $FNAME || continue
    fi
    if echo $MD5 $FNAME | md5sum -c --; then
        rm -r deb-glfw-build
        mkdir deb-glfw-build
        cd deb-glfw-build
        unzip ../$FNAME
        tar czf $DEB_ORIG_FNAME glfw-${VERSION}/
        cd glfw-${VERSION}/
        mkdir -p debian
        cp COPYING.txt debian/copyright
        # Create the changelog (no messages - dummy)
        dch --create -v $DEBVERSION --package ${NAME} ""
        cat <<EOF>debian/control
Source: $NAME
Maintainer: None <none@example.com>
Section: libdevel
Priority: optional
Standards-Version: 3.9.2
Build-Depends: debhelper (>= 8), cmake, xorg-dev, libgl1-mesa-dev, cdbs

Package: $NAME
Architecture: amd64
Depends: \${shlibs:Depends}, \${misc:Depends}
Homepage: http://www.glfw.org/
Description: A multi-platform library for OpenGL, window and input
EOF
        cat <<EOF>debian/rules
#!/usr/bin/make -f
include /usr/share/cdbs/1/rules/debhelper.mk
include /usr/share/cdbs/1/class/cmake.mk
DEB_CMAKE_EXTRA_FLAGS := -DBUILD_SHARED_LIBS:BOOL="1"
EOF
        # Create some misc files
        mkdir -p debian/source
        echo "8" > debian/compat
        echo "3.0 (quilt)" > debian/source/format
        # Build it
        set +xe
        debuild -us -uc
        savehash
        exit 0
    fi
done
exit 1
