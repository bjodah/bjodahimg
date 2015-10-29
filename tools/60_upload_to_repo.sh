#!/bin/bash
TAG=${1:-latest}
for DPKG in $(cat ./resources/dpkg_packages.txt); do
    rsync -aur ./packages/$DPKG repo@hera.physchem.kth.se:~/public_html/bjodahimg/$TAG/dpkg
done

rsync -aur ./pypi_download/ repo@hera.physchem.kth.se:~/public_html/bjodahimg/$TAG/pypi
