FROM ubuntu
MAINTAINER Robert Tran <rtran@mit.edu>

# DEPS
RUN apt-get update && apt-get install  -y \
  wget build-essential m4 python3-pip pkg-config


# ENV
ENV SCHEME_VERSION mit-scheme-10.1.5
ENV SCHEME_TAR ${SCHEME_VERSION}-x86-64.tar.gz

# GET
WORKDIR /tmp
RUN wget https://ftp.gnu.org/gnu/mit-scheme/stable.pkg/10.1.5/${SCHEME_TAR}
RUN wget https://ftp.gnu.org/gnu/mit-scheme/stable.pkg/10.1.5/md5sums.txt
RUN cat md5sums.txt | awk '/${SCHEME_TAR}/ {print}' | tee md5sums.txt
RUN tar xf ${SCHEME_TAR}

RUN wget https://github.com/zeromq/libzmq/releases/download/v4.3.1/zeromq-4.3.1.tar.gz
RUN tar xvf zeromq-4.3.1.tar.gz

RUN wget https://github.com/rtran9/mit-scheme-kernel/archive/ubuntu.tar.gz
RUN tar xvf ubuntu.tar.gz

# BUILD
WORKDIR /tmp/${SCHEME_VERSION}/src
RUN cd /tmp/${SCHEME_VERSION}/src
RUN ./configure && make && make install

WORKDIR /tmp/zeromq-4.3.1
RUN cd /tmp/zeromq-4.3.1
RUN ./configure && make && make install

RUN pip3 install -vU setuptools
RUN pip3 install jupyter

WORKDIR /tmp/mit-scheme-kernel-ubuntu
RUN cd /tmp/mit-scheme-kernel-ubuntu
RUN make && make install

# CLEAN
WORKDIR /tmp/
RUN rm -rf ${SCHEME_VERSION} ${SCHEME_TAR} md5sums.txt
RUN apt-get remove -y wget build-essential m4
RUN apt-get -y autoremove

# WORKENV
VOLUME ["/work"]
WORKDIR /work

EXPOSE 8888
CMD jupyter notebook --no-browser --allow-root --ip=0.0.0.0 --port=8888
