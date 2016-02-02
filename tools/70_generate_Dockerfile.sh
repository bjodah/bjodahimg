#!/bin/bash -xu
# This is getting out of hand, turn this into a Mako template when time permits.

TAG=${1}

# Extract absolute path of dir above script, from:
# http://unix.stackexchange.com/a/9546
absolute_repo_path_x="$(readlink -fn -- "$(dirname $0)/.."; echo x)"
absolute_repo_path="${absolute_repo_path_x%x}"

cd "$absolute_repo_path"

APT_PACKAGES=$(cat ./resources/apt_packages.txt)
DPKG_PKGS=$(cat ./resources/dpkg_packages.txt | head -c -1)
BLOB_FNAMES=$(cat ./resources/blob_urls.txt | awk '{print $3}')
for FNAME in $BLOB_FNAMES; do
    echo $FNAME
done
echo "DPKG_PKGS=$DPKG_PKGS"
DPKG_MIRROR="http://hera.physchem.kth.se/~repo/bjodahimg/$TAG/dpkg"
PYPI_MIRROR="http://hera.physchem.kth.se/~repo/bjodahimg/$TAG/pypi"
BLOBS_MIRROR="http://hera.physchem.kth.se/~repo/bjodahimg/$TAG/blobs"
read -r -d '' DPKG_DOWNLOAD_INSTALL <<EOF
    cd /tmp && \\
    for FNAME in $DPKG_PKGS; do \\
        wget --no-verbose "$DPKG_MIRROR/\$FNAME"; \\
    done && \\
    dpkg -i $DPKG_PKGS && \\
    rm $DPKG_PKGS
EOF
read -r -d '' BLOBS_DOWNLOAD_INSTALL <<EOF
    cd /tmp && \\
    for FNAME in $BLOB_FNAMES; do \\
        wget --no-verbose "$BLOBS_MIRROR/\$FNAME"; \\
    done && \\
    bash miniconda2.sh -b -p /opt/miniconda2 && \\
    rm $BLOB_FNAMES
EOF
read -r -d '' PYPKGS_DOWNLOAD <<EOF
    cd /tmp && \\
    wget --quiet $PYPI_MIRROR/$(cd pypi_download; ls setuptools-*.tar.gz) && \\
    tar xvzf setuptools-*.tar.gz  && \\
    cd setuptools-*  && \\
    python2 setup.py install && \\
    python3 setup.py install && \\
    hash -r  && \\
    for FNAME in $(cd pypi_download; ls * | grep -v "setuptools-" | tr '\n' ' '); do \\
        wget --quiet $PYPI_MIRROR/\$FNAME -O /tmp/\$FNAME; \\
    done
EOF
read -r -d '' PYPKGS_INSTALL <<EOF
    for PYPKG in $(cat ./resources/python_packages.txt | grep -v "setuptools" | tr '\n' ' '); do \\
        easy_install-2.7 --always-unzip --allow-hosts=None --find-links file:///tmp/ \$PYPKG; \\
        easy_install-3.4 --always-unzip --allow-hosts=None --find-links file:///tmp/ \$PYPKG; \\
    done && \\
    for PYPKG in $(cat ./resources/python3_packages.txt | grep -v "setuptools" | tr '\n' ' '); do \\
        easy_install-3.4 --always-unzip --allow-hosts=None --find-links file:///tmp/ \$PYPKG; \\
    done && \\
    easy_install-2.7 /usr/local/lib/python2.7/dist-packages/*-py2.7.egg && \\
    easy_install-3.4 /usr/local/lib/python3.4/dist-packages/*-py3.4.egg && \\
    ln -s /usr/local/share/pyphen /usr/share/pyphen && \\
    ipython2 kernel install && \\
    ipython3 kernel install
EOF
# https://github.com/Kozea/Pyphen/issues/10

read -r -d '' CLEAN <<EOF
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EOF
read -r -d '' MATPLOTLIB <<EOF
    mkdir -p /root/.config/matplotlib/ && \\
    echo "backend: Agg" > /root/.config/matplotlib/matplotlibrc && \\
    sed -i 's/TkAgg/Agg/g' /etc/matplotlibrc
EOF


cat <<EOF >bjodahimg-dockerfile/environment/Dockerfile
# DO NOT EDIT, This Dockerfile is generated from ./tools/10_generate_Dockerfile.sh
FROM bjodah/bjodahimgbase:v1.1
MAINTAINER Björn Dahlgren <bjodah@DELETEMEgmail.com>
RUN \\
    apt-get update && apt-get --quiet --assume-yes install ${APT_PACKAGES} && \\
    ${CLEAN}
RUN \\
    apt-get update && apt-get --quiet --assume-yes install freeglut3-dev && \\
    ${CLEAN}
RUN \\
    ${DPKG_DOWNLOAD_INSTALL} && \\
    ${PYPKGS_DOWNLOAD} && \\
    ${PYPKGS_INSTALL} && \\
    ${CLEAN} && \\
    ${MATPLOTLIB}
RUN \\
    ${BLOBS_DOWNLOAD_INSTALL}    
EOF

# the last RUN statement contain various fixes...

    # apt-get update && apt-get --quiet --assume-yes -f install libfreetype6-dev libjpeg62 libjpeg62-dev; apt-get -f install && \\
    # ${CLEAN} && \\

#    apt-get update && apt-get --quiet --assume-yes install libsdl2-dev libsdl2-ttf-dev libsdl2-net-dev libsdl2-mixer-dev libsdl2-image-dev libsdl2-gfx-dev && \\
#    ${CLEAN}
