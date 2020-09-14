ARG BASE_IMAGE=yitzikc/centos-cpp-eclipse-dev:centos-7.8-ec-2020-06

FROM $BASE_IMAGE

RUN yum install -y gmp-devel mpfr-devel libmpc-devel && yum clean -y all

WORKDIR /usr/src

ARG GCC_VERSION=7.4.0

RUN wget -nv http://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz && \
    tar zxf gcc-${GCC_VERSION}.tar.gz && \
    mkdir gcc-${GCC_VERSION}-build && \
    cd gcc-${GCC_VERSION}-build && \
    ../gcc-${GCC_VERSION}/configure --enable-languages=c,c++ --disable-multilib && \
    make -j$(nproc)

# FIXME: Work around LIBCXX issue which causes this to fail.

RUN make install && \
    gcc --version | grep -F " ${GCC_VERSION} " && \
    rm -rf gcc-${GCC_VERSION}.tar.gz gcc-${GCC_VERSION} gcc-${GCC_VERSION}-build

ARG CMAKE_VERSION=3.14.2

RUN wget -nv -c https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz && \
    tar xvf cmake-${CMAKE_VERSION}.tar.gz && cd cmake-${CMAKE_VERSION}/ && \
    ./bootstrap && \
    gmake && \
    gmake install && \
    ln -sf /usr/local/bin/cmake /usr/bin/ && \
    cmake --version | fgrep -F ${CMAKE_VERSION} && \
    rm -rf cmake-${CMAKE_VERSION}.tar.gz cmake-${CMAKE_VERSION}

LABEL org.gnu.gcc.version GCC_VERSION
LABEL org.cmake.version $CMAKE_VERSION

WORKDIR /root
