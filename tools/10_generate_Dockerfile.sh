#!/bin/bash -e
# Remember to first run:
#    $ ./tools/download_python_packages.sh

# Extract absolute path of dir above script, from:
# http://unix.stackexchange.com/a/9546
absolute_repo_path_x="$(readlink -fn -- "$(dirname $0)/.."; echo x)"
absolute_repo_path="${absolute_repo_path_x%x}"

cd "$absolute_repo_path"

APT_PACKAGES=$(cat ./environment/resources/apt_packages.txt)
cat <<EOF >environment/Dockerfile
# DO NOT EDIT, This Dockerfile is generated from ./tools/10_generate_Dockerfile.sh
FROM bjodah/bjodahimgbase:latest
MAINTAINER Björn Dahlgren <bjodah@DELETEMEgmail.com>
COPY resources /resources
RUN dpkg -i /resources/packages/*.deb && \\
    apt-get update && \\
    apt-get --quiet --assume-yes install \\
${APT_PACKAGES}
    pip install -r /resources/python_packages.txt --find-links file:///resources/pypi_download/ && \\
    pip3 install -r /resources/python_packages.txt --find-links file:///resources/pypi_download/ && \\
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \\
    mkdir -p /root/.config/matplotlib/ && \\
    echo "backend: Agg" > /root/.config/matplotlib/matplotlibrc && \\
    sed -i 's/TkAgg/Agg/g' /etc/matplotlibrc
EOF
