FROM rootproject/root:6.26.10-ubuntu22.04
MAINTAINER YifanFei
WORKDIR /
RUN apt-get install -y wget
# install conda
COPY ./Anaconda3-2022.10-Linux-x86_64.sh /root/conda.sh
RUN chmod u+x ~/conda.sh
RUN bash ~/conda.sh -b -p /opt/conda
RUN rm ~/conda.sh
ENV PATH /opt/conda/bin:$PATH
# install development tool
RUN apt-get update
RUN apt -y install build-essential
# install MG5
WORKDIR /root/
COPY ./MG5*.tar.gz /root/MG5*.tar.gz
RUN tar -xzvf MG5*.tar.gz
RUN rm MG5*.tar.gz
# install tools
RUN apt -y install vim rsync
RUN apt-get -y install passwd openssl openssh-server
# initialize conda
RUN conda init
RUN conda config --set auto_activate_base True && conda config --set changeps1 True
# install pythia8 and Delphes
COPY ./install-script /root/install-script
RUN ./MG*/bin/mg5_aMC /root/install-script
RUN rm /root/install-script
# initialize
WORKDIR /root/
CMD /bin/bash