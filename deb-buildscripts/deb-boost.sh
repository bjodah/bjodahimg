#!/bin/bash -e
export DEBVERSION=1.59.0-1
echo "6aa9a5c6a4ca1016edd0ed1178e3cb87  boost_1.59.0.tar.bz2" | md5sum -c -- \
    || wget "http://downloads.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.bz2?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fboost%2Ffiles%2Fboost%2F1.59.0%2F&ts=1385240128&use_mirror=switch" -O boost_1.59.0.tar.bz2
echo "6aa9a5c6a4ca1016edd0ed1178e3cb87  boost_1.59.0.tar.bz2" | md5sum -c -- || exit 1
mkdir -p deb-boost-build
cd deb-boost-build
rm -rf boost_1_59_0/
cp ../boost_1.59.0.tar.bz2 boost-all_1.59.0.orig.tar.bz2
tar xjvf boost-all_1.59.0.orig.tar.bz2
cd boost_1_59_0
#Build DEB
rm -rf debian
mkdir -p debian
#Use the LICENSE file from nodejs as copying file
touch debian/copying
#Create the changelog (no messages needed)
dch --create -v $DEBVERSION --package boost-all ""
#Create copyright file
touch debian
#Create control file
cat > debian/control <<EOF
Source: boost-all
Maintainer: None <none@example.com>
Section: misc
Priority: optional
Standards-Version: 3.9.2
Build-Depends: debhelper (>= 8), cdbs, libbz2-dev, zlib1g-dev

Package: boost-all
Architecture: amd64
Depends: \${shlibs:Depends}, \${misc:Depends}, boost-all (= $DEBVERSION)
Description: Boost library, version $DEBVERSION (shared libraries)

Package: boost-all-dev
Architecture: any
Depends: boost-all (= $DEBVERSION)
Description: Boost library, version $DEBVERSION (development files)

Package: boost-build
Architecture: any
Depends: \${misc:Depends}
Description: Boost Build v2 executable
EOF
#Create rules file
cat > debian/rules <<EOF
#!/usr/bin/make -f
%:
	dh \$@
override_dh_auto_configure:
	./bootstrap.sh
override_dh_auto_build:
	./b2 -j 1 --prefix=`pwd`/debian/boost-all/usr/
override_dh_auto_test:
override_dh_auto_install:
	mkdir -p debian/boost-all/usr debian/boost-all-dev/usr debian/boost-build/usr/bin
	./b2 --prefix=`pwd`/debian/boost-all/usr/ install
	mv debian/boost-all/usr/include debian/boost-all-dev/usr
	cp b2 debian/boost-build/usr/bin
        ./b2 install --prefix=`pwd`/debian/boost-build/usr/ install
EOF
#Create some misc files
echo "8" > debian/compat
mkdir -p debian/source
echo "3.0 (quilt)" > debian/source/format
#Build the package
nice -n19 ionice -c3 debuild -b -us -uc
