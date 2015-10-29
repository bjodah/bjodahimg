#!/bin/bash
# DEB package builder for sundials
# Copyright (c) 2015 Björn Dahlgren
# Public domain, use it as you see fit.
export NAME=libsundials-serial
export VERSION=2.6.2
export DEBVERSION=${VERSION}-1
TIMEOUT=60  # 60 seconds
SUNDIALS_FNAME="sundials-2.6.2.tar.gz"
DEB_ORIG_FNAME="libsundials-serial_2.6.2.orig.tar.gz"
SUNDIALS_MD5="3deeb0ede9f514184c6bd83ecab77d95"
SUNDIALS_URLS=(\
"http://hera.physchem.kth.se/~bjorn/${SUNDIALS_FNAME}" \
"http://pkgs.fedoraproject.org/repo/pkgs/sundials/${SUNDIALS_FNAME}/${SUNDIALS_MD5}/${SUNDIALS_FNAME}" \
"http://computation.llnl.gov/casc/sundials/download/code/${SUNDIALS_FNAME}" \
)
for URL in "${SUNDIALS_URLS[@]}"; do
    if echo $SUNDIALS_MD5 $SUNDIALS_FNAME | md5sum -c --; then
        echo "Found ${SUNDIALS_FNAME} with matching checksum, using this file."
    else
        echo "Downloading ${URL}..."
        timeout $TIMEOUT wget --quiet --tries=2 --timeout=$TIMEOUT $URL -O $SUNDIALS_FNAME || continue
    fi
    if echo $SUNDIALS_MD5 $SUNDIALS_FNAME | md5sum -c --; then
        rm -r deb-sundials-build
        mkdir deb-sundials-build
        cd deb-sundials-build
        cp ../$SUNDIALS_FNAME $DEB_ORIG_FNAME
        tar xzf $DEB_ORIG_FNAME
        cd sundials-*
        mkdir -p debian
        cp ../sundials-$VERSION/LICENSE debian/copyright
        # Create the changelog (no messages - dummy)
        dch --create -v $DEBVERSION --package ${NAME} ""
        cat <<EOF>debian/control
Source: $NAME
Maintainer: None <none@example.com>
Section: libdevel
Priority: optional
Standards-Version: 3.9.2
Build-Depends: debhelper (>= 8), cmake, gfortran, liblapack-dev, cdbs

Package: $NAME
Architecture: amd64
Depends: \${shlibs:Depends}, \${misc:Depends}
Homepage: http://computation.llnl.gov/casc/sundials/main.html
Description: SUNDIALS - SUit of Nonlinear and DIfferential/ALgebraic equation Solvers
EOF
        cat <<EOF>debian/rules
#!/usr/bin/make -f
include /usr/share/cdbs/1/rules/debhelper.mk
include /usr/share/cdbs/1/class/cmake.mk
DEB_CMAKE_EXTRA_FLAGS := -DCMAKE_BUILD_TYPE:STRING="Release" -DBUILD_SHARED_LIBS:BOOL="1" -DBUILD_STATIC_LIBS:BOOL="0" -DEXAMPLES_ENABLE:BOOL="0" -DEXAMPLES_INSTALL:BOOL="0" -DLAPACK_ENABLE:BOOL="1" -DOPENMP_ENABLE:BOOL="0"
EOF
        # Create some misc files
        mkdir -p debian/source
        echo "8" > debian/compat
        echo "3.0 (quilt)" > debian/source/format
        # Build it
        debuild -us -uc
        exit 0
    fi
done
exit 1
