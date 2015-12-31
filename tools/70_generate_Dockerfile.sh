#!/bin/bash -xu
# Remember to first run:
#    $ ./tools/download_python_packages.sh

TAG=${1}

# Extract absolute path of dir above script, from:
# http://unix.stackexchange.com/a/9546
absolute_repo_path_x="$(readlink -fn -- "$(dirname $0)/.."; echo x)"
absolute_repo_path="${absolute_repo_path_x%x}"

cd "$absolute_repo_path"

APT_PACKAGES=$(cat ./resources/apt_packages.txt)
DPKG_PKGS=$(cat ./resources/dpkg_packages.txt)
DPKG_MIRROR="http://hera.physchem.kth.se/~repo/bjodahimg/$TAG/dpkg"
PYPI_MIRROR="http://hera.physchem.kth.se/~repo/bjodahimg/$TAG/pypi"
echo "a"
read -r -d '' DPKG_DOWNLOAD <<EOF
    for FNAME in {$DPKG_PKGS}; do \\
        FILE=\$(mktemp); wget "$DPKG_MIRROR/\$FNAME" -qO \$FILE && sudo dpkg -i \$FILE; rm \$FILE; \\
    done
EOF
echo "b"
read -r -d '' PYPKGS <<EOF
    cd /tmp && \\
    wget --quiet $PYPI_MIRROR/$(cd pypi_download; ls setuptools-*.tar.gz) && \\
    tar xvzf setuptools-*.tar.gz  && \\
    cd setuptools-*  && \\
    python2 setup.py install && \\
    python3 setup.py install && \\
    hash -r  && \\
    for FNAME in $(cd pypi_download; ls * | grep -v "setuptools-" | tr '\n' ' '); do \\
        wget --quiet $PYPI_MIRROR/\$FNAME -O /tmp/\$FNAME; \\
    done && \\
    for PYPKG in $(cat ./resources/python_packages.txt | grep -v "setuptools" | tr '\n' ' '); do \\
        easy_install-2.7 --always-unzip --allow-hosts=None --find-links file:///tmp/ \$PYPKG; \\
        easy_install-3.4 --always-unzip --allow-hosts=None --find-links file:///tmp/ \$PYPKG; \\
    done
EOF
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
FROM bjodah/bjodahimgbase:v1.0
MAINTAINER Björn Dahlgren <bjodah@DELETEMEgmail.com>
RUN \\
    apt-get update && apt-get --quiet --assume-yes install ${APT_PACKAGES} && \\
    ${CLEAN}
RUN \\
    apt-get update && apt-get --quiet --assume-yes install libzmq3-dev libxslt1-dev libxml2-dev && \\
    ${CLEAN} && \\
    ${PYPKGS} && \\
    ${DPKG_DOWNLOAD} && \\
    ${CLEAN} && \\
    ${MATPLOTLIB}
RUN \\
    easy_install-2.7 /usr/local/lib/python2.7/dist-packages/*-py2.7.egg && \\
    easy_install-3.4 /usr/local/lib/python3.4/dist-packages/*-py3.4.egg && \\
    ipython2 kernel install
EOF

# the last RUN statement contain various fixes...
