#!/bin/bash -e
# DEB package builder for GNU Scientific Library
# Copyright (c) 2015 Björn Dahlgren
# Public domain, use it as you see fit.

STUBNAME="gsl"
SRC_FNAME="gsl-2.0.tar.gz"

# We assume this script is idempotent and side effects are
# left intact since last invocation:
# BEGIN CAHCE LOGIC
ABS_SCRIPT_DIR=$(unset CDPATH && cd "$(dirname "$0")" && echo $PWD)
SCRIPT_BASE=$(basename $0)
CACHE_BASE=$SCRIPT_BASE.cache
SOURCES="$SCRIPT_BASE $GSL_FNAME"
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

export VERSION=2.0
export DEBVERSION=${VERSION}-1
TIMEOUT=60  # 60 seconds
DEB_ORIG_FNAME="lib${STUBNAME}_${VERSION}.orig.tar.gz"
SRC_MD5="ae44cdfed78ece40e73411b63a78c375"
SRC_URLS=(\
"http://hera.physchem.kth.se/~repo/${SRC_MD5}/${SRC_FNAME}" \
"http://pkgs.fedoraproject.org/repo/pkgs/gsl/${SRC_FNAME}/${SRC_MD5}/${SRC_FNAME}" \
"http://ftp.acc.umu.se/mirror/gnu.org/gnu/${STUBNAME}/${SRC_FNAME}" \
)
for URL in "${SRC_URLS[@]}"; do
    if echo $SRC_MD5 $SRC_FNAME | md5sum -c --; then
        echo "Found ${SRC_FNAME} with matching checksum, using this file."
    else
        echo "Downloading ${URL}..."
        timeout $(($TIMEOUT*3)) wget --quiet --tries=2 --timeout=$TIMEOUT $URL -O $SRC_FNAME || continue
    fi
    if echo $SRC_MD5 $SRC_FNAME | md5sum -c --; then
        rm -r deb-$STUBNAME-build
        mkdir deb-$STUBNAME-build
        cd deb-$STUBNAME-build
        cp ../$SRC_FNAME $DEB_ORIG_FNAME
        tar xzf $DEB_ORIG_FNAME
        cd $STUBNAME-*
        mkdir -p debian
        cp ../$STUBNAME-$VERSION/COPYING debian/copyright
        # Create the changelog (no messages - dummy)
        dch --create -v $DEBVERSION --package lib${STUBNAME} ""
        cat <<EOF>debian/control
Source: lib$STUBNAME
Maintainer: None <none@example.com>
Section: math
Priority: optional
Standards-Version: 3.9.2
Build-Depends: gawk | awk, debhelper (>= 8), libtool, gcc (>= 4:4.8), binutils (>= 2.12.90.0.9), autotools-dev, liblapack-dev, cdbs

Package: libgsl2
Architecture: amd64
Depends: \${shlibs:Depends}, \${misc:Depends}
Homepage: http://www.gnu.org/software/gsl/
Description: GNU Scientific Library
EOF
        cat <<EOF>debian/rules
#!/usr/bin/make -f
include /usr/share/cdbs/1/rules/debhelper.mk
include /usr/share/cdbs/1/class/autotools.mk
EOF
        # Create some misc files
        mkdir -p debian/source
        echo "8" > debian/compat
        echo "3.0 (quilt)" > debian/source/format
        # Build it
        debuild -us -uc
        savehash
        exit 0
    fi
done
exit 1
