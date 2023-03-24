FROM ubuntu:22.04 as builder

LABEL maintainer.name="Yifan Fei"
LABEL maintainer.email="20307130006@fudan.edu.cn"

ENV LANG=C.UTF-8

WORKDIR /opt

COPY buildPackages buildPackages

RUN apt-get update -qq \
 && ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
 && apt-get -y install $(cat buildPackages)\
 && rm -rf /var/lib/apt/lists/*
RUN git clone --branch latest-stable --depth=1 https://github.com/root-project/root.git root_src 
RUN mkdir root_build root && cd root_build
RUN cmake -DCMAKE_INSTALL_PREFIX=/opt/root /opt/root_src \
 && cmake --build . -- install -j16


# new stage
FROM ubuntu:22.04
COPY --from=builder /opt/root /opt/root
COPY imagePackages imagePackages
SHELL ["/bin/bash", "-c"]
# ENV DEBIAN_FRONTEND=noninteractive

# install packages
ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive
RUN apt-get update -q && \
    apt-get install -q -y --no-install-recommends bzip2 \
ca-certificates \
git \
libglib2.0-0 \
libsm6 \
libxext6 \
libxrender1 \
mercurial \
openssh-client \
procps \
subversion \
wget \
build-essential \
gfortran \
vim \
rsync \
passwd \
openssl \
openssh-server \
curl \
graphviz-dev \
libcfitsio-dev \
libfftw3-dev \
libftgl-dev \
libglew-dev \
libglu1-mesa-dev \
libgsl-dev \
libjpeg-dev \
libkrb5-dev \
libldap2-dev \
libmysqlclient-dev \
libpcre3-dev \
libpng-dev \
libssl-dev \
libtbb-dev \
libx11-dev \
libxext-dev \
libxft-dev \
libxi-dev \
libxml2-dev \
libxmu-dev \
libxpm-dev \
libxt-dev \
rsync \
tcl \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

ENV PATH /opt/conda/bin:$PATH

# Leave these args here to better use the Docker build cache
ARG CONDA_VERSION=py310_22.11.1-1

# export ROOT
RUN source /opt/root/bin/thisroot.sh \
 && echo /opt/root/lib >> /etc/ld.so.conf \
 && ldconfig
RUN yes | unminimize
ENV ROOTSYS /opt/root
ENV PATH $ROOTSYS/bin:$PATH
ENV PYTHONPATH $ROOTSYS/lib:$PYTHONPATH
ENV CLING_STANDARD_PCH none

# install miniconda
RUN UNAME_M="$(uname -m)" && \
    if [ "${UNAME_M}" = "x86_64" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh"; \
        SHA256SUM="00938c3534750a0e4069499baf8f4e6dc1c2e471c86a59caa0dd03f4a9269db6"; \
    elif [ "${UNAME_M}" = "s390x" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-s390x.sh"; \
        SHA256SUM="a150511e7fd19d07b770f278fb5dd2df4bc24a8f55f06d6274774f209a36c766"; \
    elif [ "${UNAME_M}" = "aarch64" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-aarch64.sh"; \
        SHA256SUM="48a96df9ff56f7421b6dd7f9f71d548023847ba918c3826059918c08326c2017"; \
    elif [ "${UNAME_M}" = "ppc64le" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-ppc64le.sh"; \
        SHA256SUM="4c86c3383bb27b44f7059336c3a46c34922df42824577b93eadecefbf7423836"; \
    fi && \
    wget "${MINICONDA_URL}" -O miniconda.sh -q && \
    echo "${SHA256SUM} miniconda.sh" > shasum && \
    if [ "${CONDA_VERSION}" != "latest" ]; then sha256sum --check --status shasum; fi && \
    mkdir -p /opt && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh shasum && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

# install MG5
WORKDIR /root/
COPY ./MG5*.tar.gz /root/MG5*.tar.gz
RUN tar -xzvf MG5*.tar.gz
RUN rm -f MG5*.tar.gz

# install pythia8 and Delphes
COPY MGInstallScript MGInstallScript
RUN ./MG*/bin/mg5_aMC MGInstallScript

# install Delphes dependence
RUN rm -f /root/MGInstallScript

# initialize
CMD /bin/bash

