#!/bin/bash -xu

TAG=${1}

PYPI_MIRROR="http://hera.physchem.kth.se/~repo/bjodahimgbase/$TAG/pypi"

ABS_REPO_PATH=$(unset CDPATH && cd "$(dirname "$0")/.." && echo $PWD)
cd "$ABS_REPO_PATH"

APT_PACKAGES=$(cat ./resources_base/apt_packages.txt)

read -r -d '' PYPKGS_DOWNLOAD <<EOF
    cd /tmp && \\
    wget --quiet $PYPI_MIRROR/$(cd pypi_download_base; ls setuptools-*.tar.gz) && \\
    tar xvzf setuptools-*.tar.gz  && \\
    cd setuptools-*  && \\
    python2 setup.py install && \\
    python3 setup.py install && \\
    hash -r  && \\
    for FNAME in $(cd pypi_download_base; ls * | grep -v "setuptools-" | tr '\n' ' '); do \\
        wget --quiet $PYPI_MIRROR/\$FNAME -O /tmp/\$FNAME; \\
    done
EOF

read -r -d '' PYPKGS_INSTALL <<EOF
    for PYPKG in $(cat ./resources_base/python_packages.txt | grep -v "setuptools" | tr '\n' ' '); do \\
        easy_install-2.7 --always-unzip --allow-hosts=None --find-links file:///tmp/ \$PYPKG; \\
        easy_install-3.4 --always-unzip --allow-hosts=None --find-links file:///tmp/ \$PYPKG; \\
    done
EOF

cat <<EOF >bjodahimgbase-dockerfile/environment/Dockerfile
# DO NOT EDIT, This Dockerfile is generated from ./tools/05_generate_base_Dockerfile.sh
FROM ubuntu:14.04.3
MAINTAINER Björn Dahlgren <bjodah@DELETEMEgmail.com>
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen en_US.UTF-8 && \\
    echo "path-exclude /usr/share/doc/*" >/etc/dpkg/dpkg.cfg.d/01_nodoc && \\
    echo "path-include /usr/share/doc/*/copyright" >>/etc/dpkg/dpkg.cfg.d/01_nodoc && \\
    apt-get update && \\
    apt-get --assume-yes --no-install-recommends install ${APT_PACKAGES} && \\
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN \\
    ${PYPKGS_DOWNLOAD} && \\
    ${PYPKGS_INSTALL} && \\
    rm -r /tmp/*
EOF
