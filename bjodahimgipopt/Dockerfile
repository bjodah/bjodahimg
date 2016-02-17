# DO NOT EDIT, This Dockerfile is generated from ./tools/10_generate_Dockerfile.sh
FROM bjodah/bjodahimg:latest
MAINTAINER Björn Dahlgren <bjodah@DELETEMEgmail.com>
RUN cd /tmp && \
    wget --quiet http://hera.physchem.kth.se/~repo/12a8ecaff8dd90025ddea6c65b49cb03/Ipopt-3.12.4.tgz && \
    tar xzf Ipopt-3.12.4.tgz && rm Ipopt-3.12.4.tgz && cd Ipopt-3.12.4/ThirdParty/ && \
    cd Metis && wget --quiet http://hera.physchem.kth.se/~repo/d3848b454532ef18dc83e4fb160d1e10/metis-4.0.3.tar.gz && \
    tar xzf metis-4.0.3.tar.gz && rm metis-4.0.3.tar.gz && mv metis-4.0.? metis-4.0 && cd .. && \
    cd Mumps && wget --quiet http://hera.physchem.kth.se/~repo/959e9981b606cd574f713b8422ef0d9f/MUMPS_4.10.0.tar.gz && \
    wget --quiet http://hera.physchem.kth.se/~repo/959e9981b606cd574f713b8422ef0d9f.sh -O unpack_patch.sh && \
    bash unpack_patch.sh && cd ../.. && mkdir build && cd build/ && ../configure --prefix /usr/local && \
    make && make install && cd ../../ && rm -r Ipopt-3.12.4/
RUN ldconfig && pip install git+https://github.com/bjodah/cyipopt.git
